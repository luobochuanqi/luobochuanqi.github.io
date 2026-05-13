---
title: 数据结构复习笔记 - 链式队列
date: 2026-05-13 20:47 +0800
categories: [Blogs, Learn]
tags: [cpp, queue, linked, data-structure]
---

# 数据结构复习笔记 - 链式队列

## 简单介绍

链式队列使用带头尾指针的单向链表实现，`_front` 指向队头，`_rear` 指向队尾。入队在队尾操作，出队在队头操作。队空时 `_rear == nullptr`。

## 方法列表

| 方法 | 功能 | 返回值 |
|------|------|--------|
| `append(const T &entity)` | 入队 | `void` |
| `serve()` | 出队 | `void` |
| `retrieve()` | 获取队首元素 | `T` |
| `isEmpty()` | 判空 | `bool` |
| `clear()` | 清空队列 | `void` |

## 重点注意

- **必须实现三大安全函数**：析构函数、拷贝构造函数、赋值运算符重载
- `serve()` 出队后若队列变空，**必须将 `_rear` 也置为 `nullptr`**
- 拷贝构造和赋值运算符参数必须为 `const` 引用，避免无限递归
- 赋值运算符需先判断自赋值，再清空旧数据，最后深拷贝
- `retrieve()` 和 `serve()` 操作前必须先判空

## 完整代码

```cpp
/**
 * 链表节点结构体
 * @tparam T 数据域类型
 */
template <class T> struct Node {
  T data;           // 数据域
  Node *next;       // 指针域，指向下一个节点

  // 构造函数，统一初始化
  Node(T d) : data(d), next(nullptr) {}
};

/**
 * 链式队列模板类
 * 使用单向链表实现，维护 _front（队头）和 _rear（队尾）两个指针
 * @tparam T 元素类型
 */
template <class T> class LinkedQueue {
private:
  Node<T> *_front;  // 队头指针，指向队首节点
  Node<T> *_rear;   // 队尾指针，指向队尾节点

  /**
   * 深拷贝辅助函数
   * 遍历原队列，逐个追加到当前队列
   * @param original 要拷贝的源队列
   */
  void copyFrom(const LinkedQueue<T> &original) {
    Node<T> *curr = original._front;  // 从原队列队头开始遍历
    while (curr != nullptr) {
      append(curr->data);
      curr = curr->next;
    }
  }

public:
  /**
   * 默认构造函数
   * 初始化队头和队尾指针为空
   */
  LinkedQueue<T>() : _front(nullptr), _rear(nullptr) {}

  /**
   * 拷贝构造函数
   * 实现深拷贝，确保新队列与原队列数据独立
   * @param original 要拷贝的源队列
   */
  LinkedQueue<T>(const LinkedQueue<T> &original)
      : _front(nullptr), _rear(nullptr) {
    copyFrom(original);
  }

  /**
   * 赋值运算符重载
   * 实现深拷贝，处理自赋值情况
   * @param other 要拷贝的源队列
   * @return 引用，便于链式赋值
   */
  LinkedQueue<T> &operator=(const LinkedQueue<T> &other) {
    if (this == &other) {           // 1. 防止自赋值
      return *this;
    }
    clear();                        // 2. 先清空旧数据
    copyFrom(other);                // 3. 再深拷贝新数据
    return *this;
  }

  /**
   * 析构函数
   * 清空队列，释放所有节点内存
   */
  ~LinkedQueue<T>() { clear(); }

  /**
   * 清空队列操作
   * 循环调用 serve() 释放所有节点
   */
  void clear() {
    while (!isEmpty()) {
      serve();
    }
  }

  /**
   * 判空操作
   * @return 队列为空返回 true，否则返回 false
   */
  bool isEmpty() { return _rear == nullptr; }

  /**
   * 获取队首元素
   * @return 队首元素，空队列返回 T() 默认构造
   */
  T retrieve() {
    if (isEmpty()) {
      return T();
    }
    return _front->data;
  }

  /**
   * 入队操作
   * 在队尾追加新节点
   * @param entity 要入队的元素（const 引用避免拷贝）
   */
  void append(const T &entity) {
    // 1. 创建新节点
    Node<T> *newNode = new Node<T>(entity);

    if (isEmpty()) {
      // 2a. 空队列情况：新节点既是队头也是队尾
      _front = newNode;
      _rear = newNode;
      return;
    }

    // 2b. 非空队列情况：将新节点追加到队尾
    _rear->next = newNode;  // 原队尾指向新节点
    _rear = newNode;        // 更新队尾指针
  }

  /**
   * 出队操作
   * 移除队首节点
   * 注意：出队后若队列变空，必须将 _rear 也置为 nullptr
   */
  void serve() {
    if (isEmpty()) {
      return;
    }

    // 1. 保存当前队头节点
    Node<T> *oldFront = _front;

    // 2. 队头指针后移
    _front = _front->next;

    // 3. 如果出队后队列变空，必须将 _rear 也置为 nullptr
    if (_front == nullptr) {
      _rear = nullptr;
    }

    // 4. 释放原队头节点内存
    delete oldFront;
  }
};
```