---
title: 数据结构复习笔记 - 链式栈
date: 2026-05-13 20:45 +0800
categories: [Blogs, Learn]
tags: [cpp, stack, linked, data-structure]
---

# 数据结构复习笔记 - 链式栈

## 简单介绍

链式栈使用**单向链表**实现，`_topNode` 指向栈顶节点。链表从头节点向下生长，入栈操作在链表头部插入节点，出栈操作删除头节点。时间复杂度均为 O(1)，空间可动态扩展。

## 方法列表

| 方法 | 功能 | 返回值 |
|------|------|--------|
| `push(T entity)` | 入栈 | `void` |
| `pop()` | 出栈 | `bool` |
| `top()` | 获取栈顶元素 | `T` |
| `isEmpty()` | 判空 | `bool` |
| `clear()` | 清空栈 | `void` |

## 重点注意

- **必须实现三大安全函数**：析构函数、拷贝构造函数、赋值运算符重载
- `pop()` 时**必须先保存 next 指针再 delete**，否则会导致 use-after-free
- 拷贝构造和赋值运算符需要用 `const` 引用参数，避免无限递归
- 深拷贝时需要借助临时栈反转顺序，保证拷贝后栈顺序一致

## 完整代码

```cpp
/**
 * 链表节点结构体
 * @tparam T 数据域类型
 */
template <class T> struct Node {
  T data;           // 数据域，存储节点数据
  Node *next;       // 指针域，指向下一个节点

  // 构造函数，统一初始化数据域和指针域
  Node(T d) : data(d), next(nullptr) {}
};

/**
 * 链式栈模板类
 * 使用单向链表实现，_topNode 指向栈顶节点
 * @tparam T 元素类型
 */
template <class T> class LinkedStack {
private:
  Node<T> *_topNode;  // 栈顶指针，nullptr 表示空栈

  /**
   * 深拷贝辅助函数
   * 通过临时栈反转顺序，确保拷贝后栈顺序与原栈一致
   * @param original 要拷贝的源栈
   */
  void copyFrom(const LinkedStack<T> &original) {
    // 临时栈：中转元素，保证拷贝后顺序和原栈一致
    LinkedStack<T> tempStack;

    // 遍历原栈，压入临时栈（原栈栈顶 → 临时栈栈顶）
    Node<T> *curr = original._topNode;
    while (curr != nullptr) {
      tempStack.push(curr->data);
      curr = curr->next;
    }

    // 把临时栈弹出，压入当前栈（恢复正确顺序）
    while (!tempStack.isEmpty()) {
      push(tempStack.top());
      tempStack.pop();
    }
  }

public:
  /**
   * 默认构造函数
   * 初始化栈顶指针为 nullptr
   */
  LinkedStack() : _topNode(nullptr) {}

  /**
   * 析构函数
   * 清空栈，释放所有节点内存
   */
  ~LinkedStack() { clear(); }

  /**
   * 拷贝构造函数
   * 实现深拷贝，确保新栈与原栈数据独立
   * @param original 要拷贝的源栈
   */
  LinkedStack(const LinkedStack<T> &original) : _topNode(nullptr) {
    copyFrom(original);
  }

  /**
   * 赋值运算符重载
   * 实现深拷贝，处理自赋值情况
   * @param other 要拷贝的源栈
   * @return 引用，便于链式赋值
   */
  LinkedStack<T> &operator=(const LinkedStack<T> &other) {
    if (this == &other) {
      return *this;
    }
    clear();
    copyFrom(other);
    return *this;
  }

  /**
   * 出栈操作
   * 先保存 next 指针，再删除节点，避免 use-after-free
   * @return 成功返回 true，空栈返回 false
   */
  bool pop() {
    if (!isEmpty()) {
      Node<T> *old = _topNode;        // 1. 保存当前栈顶节点
      _topNode = _topNode->next;      // 2. 栈顶下移
      delete old;                     // 3. 释放原栈顶节点内存
      return true;
    }
    return false;
  }

  /**
   * 入栈操作
   * 在链表头部插入新节点，新节点成为栈顶
   * @param entity 要入栈的元素
   */
  void push(T entity) {
    if (_topNode == nullptr) {
      // 空栈情况：直接创建新节点作为栈顶
      _topNode = new Node(entity);
      return;
    }

    // 非空栈情况：
    // 1. 创建新节点
    Node<T> *toPush = new Node(entity);
    // 2. 新节点指向原栈顶
    toPush->next = _topNode;
    // 3. 更新栈顶指针
    _topNode = toPush;
  }

  /**
   * 判空操作
   * @return 栈为空返回 true，否则返回 false
   */
  bool isEmpty() { return _topNode == nullptr; }

  /**
   * 获取栈顶元素
   * @return 栈顶元素，空栈返回 T() 默认构造
   */
  T top() {
    if (isEmpty()) {
      return T();
    } else {
      return _topNode->data;
    }
  }

  /**
   * 清空栈操作
   * 循环调用 pop() 释放所有节点
   */
  void clear() {
    while (_topNode) {
      pop();
    }
  }
};
```