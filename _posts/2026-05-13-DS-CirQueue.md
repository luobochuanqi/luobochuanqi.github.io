---
title: 数据结构复习笔记 - 循环队列
date: 2026-05-13 20:49 +0800
categories: [Blogs, Learn]
tags: [cpp, queue, circular, data-structure]
---

# 数据结构复习笔记 - 循环队列

## 简单介绍

循环队列使用**顺序存储结构**实现，通过 `% _max` 取余实现下标的循环绕回。`_front` 指向队首，`_rear` 指向队尾的下一个位置，`_count` 记录元素数量，避免假溢出问题。

## 方法列表

| 方法 | 功能 | 返回值 |
|------|------|--------|
| `eppend(const T &entity)` | 入队 | `bool` |
| `serve()` | 出队 | `bool` |
| `retrieve()` | 获取队首元素 | `T` |
| `isEmpty()` | 判空 | `bool` |
| `isFull()` | 判满 | `bool` |

## 重点注意

- `_rear` 初始化为 `_max - 1`，入队时 `_rear = (_rear + 1) % _max`
- `_count` 用于判断队空和队满，无法仅通过 `_front` 和 `_rear` 判断
- `eppend()` 成功入队后 `_count++`，`serve()` 出队后 `_count--`
- `_data` 需要预先分配空间，构造函数中使用 `_data.reserve(max)`

## 完整代码

```cpp
#include <vector>

/**
 * 循环队列模板类
 * 采用顺序存储，通过取余实现下标循环绕回
 * @tparam T 元素类型
 */
template <class T> class CirQueue {
protected:
  int _front;           // 队首下标，指向当前队首元素
  int _rear;            // 队尾下标，指向队尾的下一个位置
  int _count;           // 元素计数，用于判断队空/队满
  const int _max;       // 队列最大容量
  std::vector<T> _data; // 存储数据的 vector

public:
  /**
   * 构造函数
   * 初始化循环队列的各种状态
   * @param max 队列最大容量
   */
  explicit CirQueue(int max) : _front(0), _rear(max - 1), _count(0), _max(max) {
    _data.reserve(max);  // 预先分配空间，避免动态扩容开销
  }

  /**
   * 判空操作
   * @return 队列为空返回 true，否则返回 false
   */
  bool isEmpty() { return _count == 0; }

  /**
   * 判满操作
   * @return 队列已满返回 true，否则返回 false
   */
  bool isFull() { return _count >= _max; }

  /**
   * 入队操作
   * 将元素添加到队尾，_rear 循环后移
   * @param entity 要入队的元素
   * @return 成功返回 true，队列已满返回 false
   */
  bool eppend(const T &entity) {
    if (isFull()) {
      return false;  // 队列已满，入队失败
    }

    // 1. 元素计数加 1
    _count++;

    // 2. 队尾下标循环后移
    _rear = (_rear + 1) % _max;

    // 3. 写入数据
    _data[_rear] = entity;
    return true;
  }

  /**
   * 出队操作
   * 移除队首元素，_front 循环后移
   * @return 成功返回 true，队列为空返回 false
   */
  bool serve() {
    if (isEmpty()) {
      return false;  // 队列为空，出队失败
    }

    // 1. 元素计数减 1
    _count--;

    // 2. 队首下标循环后移
    _front = (_front + 1) % _max;

    return true;
  }

  /**
   * 获取队首元素
   * @return 队首元素，队列为空返回 T() 默认构造
   */
  T retrieve() const {
    if (isEmpty()) {
      return T();
    }
    return _data[_front];
  }
};
```