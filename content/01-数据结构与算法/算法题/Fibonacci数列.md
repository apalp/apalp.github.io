---
title: Fibonacci数列
category: 算法
tags:
  - 408
  - 算法
status: published
created: 2026-06-26
updated: 2026-06-26
memory: false
publish: true
---

## 核心概念

斐波那契数列（Fibonacci Sequence）是以意大利数学家列昂纳多·斐波那契命名的数列，是计算机科学中经典的递归和动态规划问题。

### 数列定义
```
F(0) = 0
F(1) = 1
F(n) = F(n-1) + F(n-2)  (n ≥ 2)
```

### 数列前几项
```
0, 1, 1, 2, 3, 5, 8, 13, 21, 34, 55, 89, 144, ...
```

## 详细内容

### 一、递推公式

斐波那契数列满足线性齐次递推关系：
```
F(n) = F(n-1) + F(n-2)
```
初始条件：F(0) = 0, F(1) = 1

### 二、通项公式

斐波那契数列有优雅的闭式解：

```
F(n) = (φⁿ - ψⁿ) / √5
```

其中：
- φ = (1 + √5) / 2 ≈ 1.618（黄金分割比）
- ψ = (1 - √5) / 2 ≈ -0.618

**注意**：由于浮点数精度问题，这个公式不适合直接用于编程实现。

### 三、矩阵形式

斐波那契数列可以用矩阵乘法表示：

```
| F(n+1)  F(n)   |   | 1  1 |ⁿ
| F(n)    F(n-1) | = | 1  0 |
```

因此：
```
| F(n+1)  F(n)   |
| F(n)    F(n-1) | = Aⁿ
```
其中 A = `[[1,1],[1,0]]`

这使得可以用快速幂在 O(log n) 时间内求解。

### 四、相关性质

1. **相邻两项互质**：gcd(F(n), F(n+1)) = 1
2. **求和公式**：F(0) + F(1) + ... + F(n) = F(n+2) - 1
3. **平方性质**：F(n) × F(n+1) = F(n²) 不对，应该是 F(n)² + F(n+1)² = F(2n+1)
4. **模运算周期性**：称为 Pisano Period

## 例题与应用

### 例题1：基础递归实现
```c
int fib(int n) {
    if (n <= 1) return n;
    return fib(n-1) + fib(n-2);
}
```
**问题**：时间复杂度 O(2ⁿ)，效率极低，存在大量重复计算。

### 例题2：记忆化递归（自顶向下DP）
```python
def fib_memo(n, memo={}):
    if n in memo:
        return memo[n]
    if n <= 1:
        return n
    memo[n] = fib_memo(n-1, memo) + fib_memo(n-2, memo)
    return memo[n]
```
**时间复杂度**：O(n)
**空间复杂度**：O(n)（递归栈）

### 例题3：动态规划（自底向上）
```python
def fib_dp(n):
    if n <= 1:
        return n
    dp = [0] * (n + 1)
    dp[1] = 1
    for i in range(2, n + 1):
        dp[i] = dp[i-1] + dp[i-2]
    return dp[n]
```
**空间优化**：只用两个变量
```python
def fib_optimized(n):
    if n <= 1:
        return n
    a, b = 0, 1
    for _ in range(2, n + 1):
        a, b = b, a + b
    return b
```

### 例题4：矩阵快速幂
```python
def matrix_mult(A, B):
    return [[A[0][0]*B[0][0] + A[0][1]*B[1][0], A[0][0]*B[0][1] + A[0][1]*B[1][1]],
            [A[1][0]*B[0][0] + A[1][1]*B[1][0], A[1][0]*B[0][1] + A[1][1]*B[1][1]]]

def matrix_pow(M, n):
    result = [[1, 0], [0, 1]]
    base = M
    while n:
        if n & 1:
            result = matrix_mult(result, base)
        base = matrix_mult(base, base)
        n >>= 1
    return result

def fib_matrix(n):
    if n <= 1:
        return n
    M = [[1, 1], [1, 0]]
    result = matrix_pow(M, n)
    return result[0][1]
```
**时间复杂度**：O(log n)

### 应用场景

1. **爬楼梯问题**：n阶楼梯，每次走1或2步，有几种走法？答案就是 F(n+1)
2. **兔子繁殖问题**：经典 Fibonacci 问题
3. **算法复杂度分析**：有些算法（如 Euclid 算法）的复杂度与 Fibonacci 相关
4. **斐波那契查找**：一种优化查找算法
5. **动态规划入门**：经典的教学案例

### LeetCode 典型题目

| 题目 | 难度 | 考察点 |
|------|------|--------|
| 509. 斐波那契数 | 简单 | 基础递归/DP |
| 70. 爬楼梯 | 简单 | DP |
| 746. 使用最小花费爬楼梯 | 简单 | DP |
| 198. 打家劫舍 | 中等 | DP |
| 213. 打家劫舍 II | 中等 | DP |

## 相关链接
- [[杨辉三角]]
- [[算法设计与分析]]
- [[数据结构]]
- [[LeetCode刷题记录]]
