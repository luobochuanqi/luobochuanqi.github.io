---
title: 算法初步-快速幂
date: 2026-03-02 13:00 +0800
categories: [Blogs, Learn]
tags: [cpp]
---

# 快速幂

```cpp
long long fastPower(long long a, long long n) {
  long long result = 1;

  while(n > 0) {
    if(n & 1) {
      result *= a;
    }

    a *= a;
    n >>= 1;
  }

  return result;
}
```