**GitHub Pages + 手动写 HTML 文件**，不需要装任何工具，直接在浏览器里操作就行。

---

## 第一步：创建一个专门的仓库

1. 登录 GitHub，点右上角 **+** → **New repository**
2. 仓库名填：`你的用户名.github.io`
    - 比如你的用户名是 `alice`，就填 `alice.github.io`    用户的github.pages(还有仓库的github.pages)
    - ⚠️ 这个名字很重要，必须和用户名一致
3. 选 **Public**（公开，GitHub Pages 免费版要求）
4. 勾选 **Add a README file**
5. 点 **Create repository**

---

## 第二步：开启 GitHub Pages

1. 进入刚创建的仓库，点上方 **Settings**
2. 左侧找到 **Pages**
3. Branch 选 **main**，文件夹选 **/ (root)**
4. 点 **Save**

稍等一两分钟，你就会看到一个网址，格式是：

```
https://你的用户名.github.io
```

这个网址就是你的网站了 🎉

---

做到这一步先告诉我，我们再继续讲怎么往上面放学习资料。

![[屏幕截图 2026-04-02 221130.png]]



![[屏幕截图 2026-04-02 221247.png]]

![[Pasted image 20260402221359.png]]

create new file
index,html
<!DOCTYPE html>
<html lang="zh">  
<head>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width, initial-scale=1.0">
  <title>Apalp 的学习笔记</title>
  <style>
    * { box-sizing: border-box; margin: 0; padding: 0; }
    body { font-family: -apple-system, sans-serif; background: #f9f9f7; color: #1a1a18; }
    .page { max-width: 720px; margin: 0 auto; padding: 2.5rem 1.25rem; }
    .hero { margin-bottom: 2.5rem; }
    .hero h1 { font-size: 26px; font-weight: 500; margin-bottom: 0.4rem; }
    .hero p { font-size: 14px; color: #888; }
    .section { margin-bottom: 2rem; }
    .section-header { display: flex; align-items: center; gap: 8px; margin-bottom: 1rem; }
    .dot { width: 10px; height: 10px; border-radius: 50%; flex-shrink: 0; }
    .section-title { font-size: 15px; font-weight: 500; }
    .tag { font-size: 11px; font-weight: 500; padding: 2px 8px; border-radius: 99px; }
    .cards { display: grid; grid-template-columns: repeat(auto-fill, minmax(180px, 1fr)); gap: 100px; }
    .card { background: #fff; border-radius: 10px; padding: 0.85rem 1rem; border: 0.5px solid #e5e4df; text-decoration: none; color: inherit; display: block; transition: background 0.15s; }
    .card:hover { background: #f1efe8; }
    .card-title { font-size: 13px; font-weight: 500; margin-bottom: 3px; }
    .card-sub { font-size: 12px; color: #999; }
  </style>
</head>
<body>
<div class="page">
  <div class="hero">
    <h1>Apalp 的学习笔记</h1>
    <p>数学 · 算法 · 网络 · 学习日志</p>
  </div>

  <div class="section">
    <div class="section-header">
      <div class="dot" style="background:#7F77DD"></div>
      <span class="section-title">数学</span>
      <span class="tag" style="background:#EEEDFE;color:#3C3489">6 篇</span>
    </div>
    <div class="cards">
      <a class="card" href="#"><div class="card-title">矩阵的知识</div><div class="card-sub">基础概念</div></a>
      <a class="card" href="#"><div class="card-title">矩阵的乘法</div><div class="card-sub">运算方法</div></a>
      <a class="card" href="#"><div class="card-title">矩阵元素的引用</div><div class="card-sub">索引与切片</div></a>
      <a class="card" href="#"><div class="card-title">抽屉原理</div><div class="card-sub">组合数学</div></a>
      <a class="card" href="#"><div class="card-title">洛必达法则</div><div class="card-sub">极限运算</div></a>
      <a class="card" href="#"><div class="card-title">列联表与卡方检验</div><div class="card-sub">统计学</div></a>
    </div>
  </div>

  <div class="section">
    <div class="section-header">
      <div class="dot" style="background:#1D9E75"></div>
      <span class="section-title">算法 / AI</span>
      <span class="tag" style="background:#E1F5EE;color:#085041">6 篇</span>
    </div>
    <div class="cards">
      <a class="card" href="#"><div class="card-title">分类神经网络模型</div><div class="card-sub">深度学习</div></a>
      <a class="card" href="#"><div class="card-title">感知器神经网络</div><div class="card-sub">基础模型</div></a>
      <a class="card" href="#"><div class="card-title">差分进化算法</div><div class="card-sub">优化算法</div></a>
      <a class="card" href="#"><div class="card-title">蒙特卡洛模拟</div><div class="card-sub">随机算法</div></a>
      <a class="card" href="#"><div class="card-title">滑动窗口相关性模型</div><div class="card-sub">时序分析</div></a>
      <a class="card" href="#"><div class="card-title">层次分析法</div><div class="card-sub">决策分析</div></a>
    </div>
  </div>

  <div class="section">
    <div class="section-header">
      <div class="dot" style="background:#378ADD"></div>
      <span class="section-title">网络</span>
      <span class="tag" style="background:#E6F1FB;color:#0C447C">2 篇</span>
    </div>
    <div class="cards">
      <a class="card" href="#"><div class="card-title">互联网是如何工作的</div><div class="card-sub">网络基础</div></a>
      <a class="card" href="#"><div class="card-title">静态网站与动态网站</div><div class="card-sub">Web 基础</div></a>
    </div>
  </div>

  <div class="section">
    <div class="section-header">
      <div class="dot" style="background:#888780"></div>
      <span class="section-title">学习日志</span>
      <span class="tag" style="background:#F1EFE8;color:#444441">2 篇</span>
    </div>
    <div class="cards">
      <a class="card" href="#"><div class="card-title">5.28 学习规划</div><div class="card-sub">2024-05-28</div></a>
      <a class="card" href="#"><div class="card-title">5.29</div><div class="card-sub">2024-05-29</div></a>
    </div>
  </div>
</div>
</body>
</html>
![[Pasted image 20260402222345.png]]
