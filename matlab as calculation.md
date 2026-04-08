---
title: matlab as calculation
category: 未分类
---
#台大郭彦甫
current folder ； workspace；layout-command history
命令窗口
===
快捷键操作：
---
CTRL+r 注释该行 几个r就是几级注释
CTRL+t取消注释 几个t就是取消几个
CTRL+C终止当前运算
“%“%”+ 空格 就是运行节
demo＋回车 调出安装在本地的帮助文件
help ＋函数 查找具体函数算法（helpwin ，helpdesk）
doc +函数
edit +函数 调出对应函数的内置函数
clc清除命令窗口的内容
clear清楚右边工作区变量（慎）
format 设置数据格式 format short long short e long e
ver 查看版本
who 显示当前所有变量的名字（工作区变量）
whos显示当前所有变量的详细信息（大小等）
pack整理工作间内存
load matlab表格名 导入表格（必须是.mat结尾）
save 把工作区所有变量存入文件中
cd改变当前工作目录
pwd显示当前目录地址
dir显示目录内容
computer返回当前计算机信息>> computer

ans =

    'PCWIN64' pc个人计算机 win windows操作系统 64 64位操作版本


echo 在命令行逐行显示代码（echo off all 退出所有代码）
command line
---
1 operators +-/^  enter
2 left-right
3 in-out
4 命令行在计算命令后加；就不会在命令行显示答案，答案存在变量区
5 变量区，单个变量显示值，矩阵显示矩阵大小
常用操作
---
手动更改变量：打开变量区，手动修改就可
前后命令复用：在命令行通过上下键选中历史指令，回车重新调用。clc不影响可选中的历史指令

编辑器窗口
===
脚本文件命名
---
1.与变量名要求相同
2.文件名不能与matlab内部的函数名重合（越复杂越不会与其重合）
3.存储路径最好是英文路径（？）
脚本语言
---
变量名：只能以字母开头，19字符为限
全局变量：global 声明
```matlab
global a b;

a=8;

b=9;

results=add(4,6);

disp(results) ;

function g=add(x,y)

	global a b;

	g=a*x+b*y;

end
```
必须先调用函数再进行函数声明，语句后面用分号，函数体前无后有end
循环体:在循环语句中，表达式不使用（），循环体不使用{} ，用end结束循环。
