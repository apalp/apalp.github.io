#Requires -Version 5.1
<#
.SYNOPSIS
    把 Obsidian 知识库中 status: published 的笔记单向发布到 Quartz 站点。

.DESCRIPTION
    以知识库为唯一源头，重建站点的 content/ 目录：
      1. 扫描知识库，筛出 front matter 中 status: published 的笔记
      2. 校验 wikilink 完整性，报告指向未发布笔记的悬空链接
      3. 重建 content/，复制笔记并补写 publish: true（Quartz 的 ExplicitPublish 闸门）
      4. 只复制被笔记真正引用到的图片
      5. 生成站点首页 index.md
      6. 可选：执行 npx quartz build 验证

    本脚本永不修改知识库中的任何文件，只读取。

.PARAMETER VaultPath
    Obsidian 知识库根目录。

.PARAMETER SitePath
    Quartz 站点仓库根目录。

.PARAMETER DryRun
    只扫描并输出报告，不写入任何文件。

.PARAMETER Build
    同步完成后执行 npx quartz build 验证。

.EXAMPLE
    .\publish.ps1 -DryRun
    预览哪些笔记会被发布、有哪些悬空链接。

.EXAMPLE
    .\publish.ps1 -Build
    正式同步并构建验证。
#>
[CmdletBinding()]
param(
    [string]$VaultPath = 'D:\用户\Desktop\CS-obsidian',
    [string]$SitePath  = 'D:\用户\Desktop\apalp.github.io',
    [switch]$DryRun,
    [switch]$Build
)

$ErrorActionPreference = 'Stop'
[Console]::OutputEncoding = [System.Text.UTF8Encoding]::new($false)

# ==================== 配置区 ====================
# 永不外发的顶层目录（相对知识库根目录）
$ExcludeDirs = @(
    '00-收件箱',
    '12-学习日志与规划',
    '13-读书笔记',
    '_templates',
    '_assets',
    '.obsidian',
    '.tools',
    '.trash',
    '.git'
)

# 哪些 status 取值算"已发布"
$PublishedValues = @('published', 'publish', '公开', '已发布')

# 图片目录名（相对知识库根目录）
$AssetDirName = '_assets'
# ===============================================

$ContentPath   = Join-Path $SitePath 'content'
$AssetSrcPath  = Join-Path $VaultPath $AssetDirName
$IndexTemplate = Join-Path $SitePath 'tools\index.template.md'
$Utf8NoBom     = New-Object System.Text.UTF8Encoding($false)

# -------------------- 工具函数 --------------------
function Split-Note {
    param([string]$Raw)
    $m = [regex]::Match($Raw, '(?s)^\uFEFF?---\r?\n(.*?)\r?\n---\r?\n?(.*)$')
    if ($m.Success) {
        return [pscustomobject]@{ Front = $m.Groups[1].Value; Body = $m.Groups[2].Value }
    }
    return [pscustomobject]@{ Front = ''; Body = $Raw }
}

function Get-Field {
    param([string]$Front, [string]$Name)
    if (-not $Front) { return $null }
    # 必须用 [ \t] 而非 \s：\s 会吞掉换行，令正则跨行匹配到下一个字段
    $m = [regex]::Match($Front, ('(?m)^{0}[ \t]*:[ \t]*(.*?)[ \t]*$' -f [regex]::Escape($Name)))
    if (-not $m.Success) { return $null }
    return $m.Groups[1].Value.Trim().Trim([char]34, [char]39)
}

function Set-Field {
    param([string]$Front, [string]$Name, [string]$Value)
    $line = ('{0}: {1}' -f $Name, $Value)
    if ([regex]::IsMatch($Front, ('(?m)^{0}[ \t]*:' -f [regex]::Escape($Name)))) {
        return [regex]::Replace($Front, ('(?m)^{0}[ \t]*:.*$' -f [regex]::Escape($Name)), $line)
    }
    return ($Front.TrimEnd() + "`n" + $line)
}

function Remove-Code {
    param([string]$Text)
    # 去掉围栏代码块与行内代码，避免把代码里的 [[1, 1]] 误判成 wikilink
    $t = [regex]::Replace($Text, '(?s)```.*?```', '')
    $t = [regex]::Replace($t,    '(?s)~~~.*?~~~', '')
    $t = [regex]::Replace($t,    '`[^`\r\n]*`',   '')
    return $t
}

function Get-GitFirstCommitDate {
    param([string]$Repo, [string]$RelPath)
    if (-not (Test-Path (Join-Path $Repo '.git'))) { return $null }
    try {
        $out = & git -C $Repo log --diff-filter=A --follow --format=%aI -- $RelPath 2>$null
        if ($LASTEXITCODE -ne 0 -or -not $out) { return $null }
        return ([datetime](@($out)[-1])).ToString('yyyy-MM-dd')
    } catch {
        return $null
    }
}

# -------------------- 1/6 扫描 --------------------
Write-Host ''
Write-Host '== 1/6  扫描知识库 ==' -ForegroundColor Cyan
if (-not (Test-Path $VaultPath)) { throw "知识库不存在: $VaultPath" }

$allNotes = Get-ChildItem -LiteralPath $VaultPath -Recurse -File -Filter *.md | Where-Object {
    $rel = $_.FullName.Substring($VaultPath.Length).TrimStart('\')
    $top = ($rel -split '\\')[0]
    $ExcludeDirs -notcontains $top
}

$published = New-Object System.Collections.Generic.List[object]
foreach ($n in $allNotes) {
    $raw    = Get-Content -LiteralPath $n.FullName -Raw -Encoding UTF8
    $parts  = Split-Note $raw
    $status = Get-Field $parts.Front 'status'
    if ($status -and ($PublishedValues -contains $status.ToLower())) {
        $published.Add([pscustomobject]@{
            Source = $n.FullName
            Rel    = $n.FullName.Substring($VaultPath.Length).TrimStart('\')
            Front  = $parts.Front
            Body   = $parts.Body
        })
    }
}

Write-Host ('   知识库笔记总数      : {0}' -f $allNotes.Count)
Write-Host ('   待发布 status:published : {0}' -f $published.Count) -ForegroundColor Yellow
if ($published.Count -eq 0) {
    Write-Warning '没有任何 status: published 的笔记，站点内容将是空的（这是安全的默认状态）。'
}

# -------------------- 2/6 链接校验 --------------------
Write-Host ''
Write-Host '== 2/6  校验 wikilink 完整性 ==' -ForegroundColor Cyan

$publishedNames = @{}
foreach ($p in $published) {
    $publishedNames[[System.IO.Path]::GetFileNameWithoutExtension($p.Rel)] = $true
    $t = Get-Field $p.Front 'title'
    if ($t) { $publishedNames[$t] = $true }
}

$dangling = New-Object System.Collections.Generic.List[object]
foreach ($p in $published) {
    # (?<!\!) 排除 ![[图片]] 嵌入语法 —— 它们不是笔记链接
    foreach ($m in [regex]::Matches((Remove-Code $p.Body), '(?<!\!)\[\[([^\]\|#]+)')) {
        $target     = $m.Groups[1].Value.Trim()
        $targetBase = [System.IO.Path]::GetFileNameWithoutExtension($target)
        if (-not $publishedNames.ContainsKey($target) -and -not $publishedNames.ContainsKey($targetBase)) {
            $dangling.Add([pscustomobject]@{ Note = $p.Rel; Target = $target })
        }
    }
}

if ($dangling.Count -gt 0) {
    Write-Host ('   悬空链接 {0} 条（目标笔记尚未标记为 published）：' -f $dangling.Count) -ForegroundColor Yellow
    $dangling | Group-Object Target | Sort-Object Count -Descending | Select-Object -First 25 |
        ForEach-Object { Write-Host ('     {0,3} x  [[{1}]]' -f $_.Count, $_.Name) }
    Write-Host '   Quartz 会把它们渲染为未解析链接，不影响构建，但阅读体验会有断点。' -ForegroundColor DarkGray
} else {
    Write-Host '   无悬空链接。' -ForegroundColor Green
}

# -------------------- 3/6 图片 --------------------
Write-Host ''
Write-Host '== 3/6  收集被引用的图片 ==' -ForegroundColor Cyan

$referenced = @{}
foreach ($p in $published) {
    foreach ($m in [regex]::Matches($p.Body, '!\[\[([^\]\|]+)')) {
        $referenced[$m.Groups[1].Value.Trim()] = $true
    }
    foreach ($m in [regex]::Matches($p.Body, '!\[[^\]]*\]\(([^\)]+)\)')) {
        $referenced[[System.IO.Path]::GetFileName($m.Groups[1].Value.Trim())] = $true
    }
}

$assets = New-Object System.Collections.Generic.List[string]
# 建立 文件名 -> 完整路径 的递归索引：
# Obsidian 的 ![[name.png]] 按文件名解析而非路径，而本库图片实际位于 _assets\images\ 下
$assetIndex = @{}
$assetDupes = New-Object System.Collections.Generic.List[string]
if (Test-Path $AssetSrcPath) {
    foreach ($f in Get-ChildItem -LiteralPath $AssetSrcPath -Recurse -File) {
        if ($assetIndex.ContainsKey($f.Name)) {
            $assetDupes.Add($f.Name)
        } else {
            $assetIndex[$f.Name] = $f.FullName
        }
    }
    if ($assetDupes.Count -gt 0) {
        Write-Host ('   警告：文件名重复，仅取第一个 -> {0}' -f (($assetDupes | Select-Object -Unique) -join ', ')) -ForegroundColor Yellow
    }
    foreach ($name in $referenced.Keys) {
        if ($assetIndex.ContainsKey($name)) {
            $assets.Add($assetIndex[$name])
        } else {
            Write-Host ('   [缺失] {0}' -f $name) -ForegroundColor DarkYellow
        }
    }
}
Write-Host ('   被引用图片: {0} 张（资源库共 {1} 个文件）' -f $assets.Count, $assetIndex.Count)

# -------------------- 4/6 写入 --------------------
Write-Host ''
Write-Host '== 4/6  生成站点内容 ==' -ForegroundColor Cyan

if ($DryRun) {
    Write-Host '   [DryRun] 跳过写入。' -ForegroundColor Yellow
    Write-Host ''
    Write-Host '   将发布以下笔记：' -ForegroundColor Cyan
    $published | ForEach-Object { Write-Host ('     + {0}' -f $_.Rel) }
} else {
    if (Test-Path $ContentPath) { Remove-Item -LiteralPath $ContentPath -Recurse -Force }
    New-Item -ItemType Directory -Path $ContentPath -Force | Out-Null

    $today = Get-Date -Format 'yyyy-MM-dd'

    foreach ($p in $published) {
        $front = $p.Front

        # 第二道闸门：Quartz 的 ExplicitPublish 要求 publish: true
        if (-not (Get-Field $front 'publish')) {
            $front = Set-Field $front 'publish' 'true'
        }

        # 补齐日期，避免 Quartz 回退到文件系统时间（=复制当天）
        if (-not (Get-Field $front 'updated')) {
            $front = Set-Field $front 'updated' $today
        }
        if (-not (Get-Field $front 'created')) {
            $created = Get-GitFirstCommitDate -Repo $VaultPath -RelPath $p.Rel
            if (-not $created) {
                $created = (Get-Item -LiteralPath $p.Source).LastWriteTime.ToString('yyyy-MM-dd')
            }
            $front = Set-Field $front 'created' $created
        }

        $target = Join-Path $ContentPath $p.Rel
        $dir    = Split-Path -Parent $target
        if (-not (Test-Path $dir)) { New-Item -ItemType Directory -Path $dir -Force | Out-Null }

        $text = '---{0}{1}{0}---{0}{0}{2}' -f "`n", $front.Trim(), $p.Body.TrimStart("`n")
        [System.IO.File]::WriteAllText($target, $text, $Utf8NoBom)
    }

    if ($assets.Count -gt 0) {
        $assetDst = Join-Path $ContentPath $AssetDirName
        New-Item -ItemType Directory -Path $assetDst -Force | Out-Null
        foreach ($a in $assets) { Copy-Item -LiteralPath $a -Destination $assetDst -Force }
    }

    Write-Host ('   已写入 {0} 篇笔记、{1} 张图片 -> {2}' -f $published.Count, $assets.Count, $ContentPath) -ForegroundColor Green
}

# -------------------- 5/6 首页 --------------------
if (-not $DryRun) {
    Write-Host ''
    Write-Host '== 5/6  生成首页 ==' -ForegroundColor Cyan
    # 不要命名为 $home —— PowerShell 中 $HOME 是只读自动变量，赋值会直接报错
    $indexFile = Join-Path $ContentPath 'index.md'
    if (Test-Path $IndexTemplate) {
        $tpl = (Get-Content -LiteralPath $IndexTemplate -Raw -Encoding UTF8).Replace('{{date}}', (Get-Date -Format 'yyyy-MM-dd'))
        [System.IO.File]::WriteAllText($indexFile, $tpl, $Utf8NoBom)
        Write-Host '   content/index.md 已生成。' -ForegroundColor Green
    } else {
        Write-Host ('   未找到首页模板: {0}（跳过）' -f $IndexTemplate) -ForegroundColor DarkYellow
    }
}

# -------------------- 6/6 构建 --------------------
if ($Build -and -not $DryRun) {
    Write-Host ''
    Write-Host '== 6/6  构建验证 ==' -ForegroundColor Cyan
    Push-Location $SitePath
    try {
        # 注意：本机 PowerShell 执行策略禁止 .ps1 垫片，必须走 npm.cmd / npx.cmd
        & npx.cmd quartz build
        if ($LASTEXITCODE -ne 0) { throw 'Quartz 构建失败，详见上方输出。' }
        Write-Host '   构建成功。本地预览：npx.cmd quartz build --serve' -ForegroundColor Green
    } finally {
        Pop-Location
    }
}

# -------------------- 汇总 --------------------
Write-Host ''
Write-Host '========== 发布汇总 ==========' -ForegroundColor Cyan
Write-Host ('  发布笔记   : {0} 篇' -f $published.Count)
Write-Host ('  悬空链接   : {0} 条' -f $dangling.Count)
Write-Host ('  图片       : {0} 张' -f $assets.Count)
if ($DryRun) { Write-Host '  模式       : DryRun（未写入）' -ForegroundColor Yellow }
Write-Host ''
if (-not $DryRun) {
    Write-Host '下一步：' -ForegroundColor Cyan
    Write-Host ('  cd "{0}"' -f $SitePath)
    Write-Host '  npx.cmd quartz sync'
    Write-Host ''
}
