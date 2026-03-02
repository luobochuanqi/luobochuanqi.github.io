---
title: 算法初步-二分查找
date: 2026-03-02 14:00 +0800
categories: [Blogs, Learn]
tags: [cpp]
---

# Binary Search

## SQUINT - 整数平方根

### 问题描述
给定一个整数 $n$，求最小的非负整数 $r$，使得 $r^2 \geq n$（即 $\lceil \sqrt{n} \rceil$）。

### 样例
| 输入 | 输出 |
|:---:|:---:|
| `122333444455555` | `11060446` |

验证：
- $11060445^2 = 122333443598025 < 122333444455555$ ❌
- $11060446^2 = 122333465718916 \geq 122333444455555$ ✓


```cpp
// 定义 long long 类型的简写，方便后续使用
typedef long long ll;

// 函数声明：计算整数平方根（向上取整）
// 参数 a: 输入的非负整数
// 返回值: 满足 r^2 >= a 的最小非负整数 r
long long squint(long long a);

int main() {
  // 关闭 C++ 流与 C 流的同步，提高输入输出效率
  ios::sync_with_stdio(false);
  // 解除 cin 与 cout 的绑定，进一步提升输入输出速度
  cin.tie(nullptr);

  long long a;      // 定义变量存储输入的整数
  cin >> a;         // 从标准输入读取整数

  cout << squint(a); // 调用 squint 函数并输出结果

  return 0;         // 程序正常结束
}

/**
 * 二分查找算法实现整数平方根
 * 
 * 算法思想：
 * 1. 在区间 [1, a] 中查找满足条件的值
 * 2. 对于中间值 mid，比较 mid^2 与 a 的大小
 * 3. 为避免 mid * mid 溢出，使用 mid <= a / mid 进行判断
 * 4. 最终返回满足 r^2 >= a 的最小 r
 */
long long squint(long long a) {
  // 定义二分查找的左右边界
  // left: 查找区间的左端点，初始值为 1
  // right: 查找区间的右端点，初始值为 a
  ll left = 1, right = a;
  
  // ans 用于存储当前找到的答案，初始化为 a（最坏情况下答案就是 a 本身）
  ll ans = a;

  // 二分查找的主循环，当左边界不超过右边界时继续查找
  while (left <= right) {
    // 计算中间位置，使用 left + (right - left) / 2 而非 (left + right) / 2
    // 目的是防止 left + right 可能导致的整数溢出
    ll mid = left + (right - left) / 2;

    // 判断条件：mid^2 <= a 等价于 mid <= a / mid（避免溢出）
    // 如果 mid 的平方小于等于 a，说明 mid 可能是答案，但还需要尝试更大的值
    if (mid <= a / mid) {
      // 将左边界右移，继续在右半区间查找是否存在更大的满足条件的值
      left = mid + 1;
    } else {
      // mid 的平方大于 a，说明 mid 太大，需要在左半区间查找更小的值
      right = mid - 1;
    }
    // 更新答案为当前的 mid
    // 注意：这里 ans 可能保存的是不满足条件的值，需要在循环后修正
    ans = mid;
  }

  // 循环结束后，需要验证 ans 是否真正满足 ans^2 >= a
  // 如果不满足（即 ans^2 < a），则将 ans 加 1
  // 这是因为二分查找过程中 ans 可能保存的是最后一个 mid <= a / mid 的值
  if (ans * ans < a) {
    ans += 1;
  }
  return ans;  // 返回最终的整数平方根（向上取整）
}
```