---
title: 最小向量点积
date: 2026-03-31 08:00 +0800
categories: [Blogs, Algorithm]
tags: [cpp, greedy]
---

# 1049. 最小向量点积

## 题目描述

### 定义

向量 $\mathbf{a} = [a_1, a_2, \dots, a_n]$ 与 $\mathbf{b} = [b_1, b_2, \dots, b_n]$ 的点积定义为：

$$
\mathbf{a} \cdot \mathbf{b} = \sum_{i=1}^{n} a_i b_i = a_1 b_1 + a_2 b_2 + \cdots + a_n b_n
$$

示例：向量 $[1, 3, -5]$ 与 $[4, -2, -1]$ 的点积：

$$
(1)(4) + (3)(-2) + (-5)(-1) = 4 - 6 + 5 = 3
$$

### 问题

允许对每个向量内部的坐标值重新排列，求所有可能排列组合中点积的最小值。

示例最优解：将 $[1, 3, -5]$ 排列为 $[3, 1, -5]$，将 $[4, -2, -1]$ 排列为 $[-2, -1, 4]$，点积为：

$$
3 \times (-2) + 1 \times (-1) + (-5) \times 4 = -6 - 1 - 20 = -27
$$

### 输入格式

- 第 1 行：整数 $T$（$1 \le T \le 10$），表示问题数
- 每个问题：
  - 第 1 行：整数 $n$（$1 \le n \le 1000$），维数
  - 第 2 行：向量 $\mathbf{a}$ 的 $n$ 个整数（$-1000 \le a_i \le 1000$）
  - 第 3 行：向量 $\mathbf{b}$ 的 $n$ 个整数（$-1000 \le b_i \le 1000$）

### 输出格式

每个问题输出一行：`case #k: min_dot_product`，其中 $k$ 从 0 开始。

## 题解

### 思路

根据**重排不等式**（Rearrangement Inequality）：

> 两个数列，一个升序排列、另一个降序排列时，对应项乘积之和最小。

证明直觉：让大的数和小的数配对，可以"抵消"掉更多的值，使总和最小。

### 代码

```cpp
#include <iostream>
#include <vector>
#include <algorithm>
using namespace std;

int main() {
    ios::sync_with_stdio(false);
    cin.tie(nullptr);

    int T;
    cin >> T;

    for (int k = 0; k < T; k++) {
        int n;
        cin >> n;

        vector<long long> a(n), b(n);
        for (int i = 0; i < n; i++) cin >> a[i];
        for (int i = 0; i < n; i++) cin >> b[i];

        // a 升序，b 降序
        sort(a.begin(), a.end());
        sort(b.begin(), b.end(), greater<long long>());

        long long ans = 0;
        for (int i = 0; i < n; i++) {
            ans += a[i] * b[i];
        }

        cout << "case #" << k << ": " << ans << "\n";
    }

    return 0;
}
```

### 复杂度分析

- 时间复杂度：$O(n \log n)$（排序）
- 空间复杂度：$O(n)$
