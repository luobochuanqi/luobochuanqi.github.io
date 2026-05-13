---
title: 数据结构复习笔记 - 扩展队列
date: 2026-05-13 20:51 +0800
categories: [Blogs, Learn]
tags: [cpp, queue, extended, data-structure]
---

# 数据结构复习笔记 - 扩展队列

## 简单介绍

扩展队列继承自循环队列 `CirQueue`，新增了 `clear()` 方法用于清空队列。继承使用 `protected` 成员，使子类可以直接访问父类的 `_count` 等成员。

## 方法列表

继承自 `CirQueue` 的方法：

| 方法 | 功能 | 返回值 |
|------|------|--------|
| `eppend(const T &entity)` | 入队 | `bool` |
| `serve()` | 出队 | `bool` |
| `retrieve()` | 获取队首元素 | `T` |
| `isEmpty()` | 判空 | `bool` |
| `isFull()` | 判满 | `bool` |

新增方法：

| 方法 | 功能 | 返回值 |
|------|------|--------|
| `clear()` | 清空队列 | `void` |

## 重点注意

- 使用**公有继承** `public CirQueue<T>`
- 子类中访问父类成员需加 `this->` 或使用**命名空间** `CirQueue<T>::`
- `clear()` 只需将 `_count` 置 0，无需释放 `vector` 空间

## 完整代码

```cpp
#include "CirQueue.hpp"

/**
 * 扩展队列模板类
 * 公有继承自 CirQueue，新增 clear() 方法
 * @tparam T 元素类型
 */
template <class T> class ExtendedQueue : public CirQueue<T> {

public:
  /**
   * 清空队列操作
   * 仅需将计数 _count 置 0，vector 数据可保留待复用
   * 无需释放 vector 空间，避免重复分配开销
   */
  void clear() {
    this->_count = 0;
  }
};
```