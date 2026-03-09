---
title: C++ vector 去重技巧
date: 2026-03-09 14:00 +0800
categories: [Blogs, Learn]
tags: [cpp, stl]
---

# C++ vector 去重

## erase + unique 组合

C++ STL 提供了简洁高效的去重方式，利用 `unique` 和 `erase` 的组合：

```cpp
#include <bits/stdc++.h>
using namespace std;

int main() {
    vector<int> v = {1, 1, 2, 2, 3, 3, 3, 4, 5, 5};
    
    // 1. 先排序（unique 只能去除相邻重复元素）
    sort(v.begin(), v.end());
    
    // 2. erase + unique 去重
    v.erase(unique(v.begin(), v.end()), v.end());
    
    // 结果: 1 2 3 4 5
    for (int x : v) cout << x << " ";
    
    return 0;
}
```

## 原理说明

| 函数 | 作用 |
|:---:|:---|
| `sort` | 先排序，让重复元素相邻 |
| `unique` | 将重复元素移到末尾，返回新逻辑末尾的迭代器 |
| `erase` | 删除从返回位置到真实末尾的冗余元素 |

## 完整示例

```cpp
#include <bits/stdc++.h>
using namespace std;

int main() {
    ios::sync_with_stdio(false);
    cin.tie(nullptr);
    
    int n;
    cin >> n;
    vector<int> a(n);
    
    for (int i = 0; i < n; i++) cin >> a[i];
    
    // 排序 + 去重
    sort(a.begin(), a.end());
    a.erase(unique(a.begin(), a.end()), a.end());
    
    cout << "去重后元素个数: " << a.size() << endl;
    for (int x : a) cout << x << " ";
    
    return 0;
}
```

## 注意事项

1. **必须先排序**：`unique` 只去除相邻重复元素
2. **时间复杂度**：排序 $O(n \log n)$ + 去重 $O(n)$
3. **空间复杂度**：$O(1)$，原地操作

## 对比 set 去重

```cpp
// set 方式（额外空间，自动排序）
set<int> s(v.begin(), v.end());
vector<int> res(s.begin(), s.end());

// erase+unique 方式（原地操作，效率更高）
sort(v.begin(), v.end());
v.erase(unique(v.begin(), v.end()), v.end());
```

**结论**：数据量大时，`erase+unique` 更高效且节省内存。
