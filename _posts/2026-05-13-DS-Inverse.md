---
title: 数据结构复习笔记 - 单链表逆置与双向链表搜索
date: 2026-05-13 20:53 +0800
categories: [Blogs, Learn]
tags: [cpp, linked-list, data-structure]
---

# 数据结构复习笔记 - 单链表逆置与双向链表搜索

## 简单介绍

本节包含两个重要操作：

1. **单链表逆置** `Inverse()`：使用三指针法（pre、curr、next）原地逆置单向链表，时间复杂度 O(n)
2. **双向链表搜索** `Search()`：在有序双向链表中从给定节点出发，根据 key 与当前节点的大小关系选择正向或反向搜索

## 方法列表

### 单链表逆置

| 函数 | 功能 |
|------|------|
| `Inverse(Node<T> *&first)` | 原地逆置单链表 |

### 双向链表搜索

| 函数 | 功能 | 参数 |
|------|------|------|
| `Search(head, p, key)` | 有序双向链表搜索 | head: 头指针, p: 搜索起点(引用), key: 关键字 |

## 重点注意

### 单链表逆置

- 必须使用**引用指针** `Node<T> *&first`，否则无法修改原链表头指针
- 三指针缺一不可：`pre` 记录前驱，`curr` 当前节点，`next` 保存后继
- 循环结束后 `pre` 指向原链表尾节点，即新链表头节点

### 双向链表搜索

- 利用有序表的**剪枝优化**：遇到不符合单调性的节点提前终止
- 参数 `p` 为**引用类型**，搜索成功时会更新为找到的节点位置
- key 大于当前节点往**后继方向**搜索，key 小于当前节点往**前驱方向**搜索

## 完整代码

```cpp
/**
 * 单链表节点结构体
 * @tparam T 数据域类型
 */
template <class T> struct Node {
  T data;           // 数据域
  Node *next;       // 指针域，指向下一个节点

  Node(T d) : data(d), next(nullptr) {}
};

/**
 * 单链表逆置函数
 * 使用三指针法原地逆置链表，不申请新节点
 * @param first 链表头指针的引用，逆置后指向新的头节点
 */
template <class T> void Inverse(Node<T> *&first) {
  Node<T> *pre =
      nullptr;  // 初始为空，因为原链表头节点的前驱不存在
  Node<T> *curr = first;   // 从原链表头节点开始遍历
  Node<T> *next = nullptr; // 初始为空，待保存当前节点的后继

  // 遍历链表，逐个逆转指针方向
  while (curr != nullptr) {
    next = curr->next;  // 1. 先保存下一个节点，避免断链
    curr->next = pre;   // 2. 让当前节点的 next 指向前驱（逆转方向）
    pre = curr;         // 3. pre 后移到当前节点
    curr = next;        // 4. curr 后移到下一个节点
  }

  // 循环结束时，pre 指向原链表的最后一个节点（即新的头节点）
  first = pre;
}

// ============================================================================

/**
 * 双向链表节点结构体
 * @tparam T 数据域类型
 */
template <class T> struct DblListNode {
  T data;                   // 数据域
  DblListNode<T> *prev;     // 前驱指针
  DblListNode<T> *next;     // 后继指针

  // 默认构造函数
  DblListNode();

  // 含参构造函数
  // @param item 数据值
  // @param p 前驱指针
  // @param n 后继指针
  DblListNode(const T &item, DblListNode<T> *p = nullptr,
              DblListNode<T> *n = nullptr);
};

/**
 * 在有序双向链表中搜索关键字
 * 利用有序表的单调性优化：key 大于当前节点往后继方向搜索，key 小于当前节点往前驱方向搜索
 *
 * @param head 链表头指针
 * @param p 上一次搜索成功的节点（引用），搜索成功时会更新为该节点
 * @param key 要搜索的关键字
 * @return 找到返回节点地址并更新 p，失败返回 nullptr
 */
template <class T>
DblListNode<T> *Search(DblListNode<T> *head, DblListNode<T> *&p, T key) {
  // 边界情况：链表为空或搜索起点为空，直接返回失败
  if (head == nullptr || p == nullptr) {
    return nullptr;
  }

  // 情况1：当前节点恰好是目标，直接返回
  if (p->data == key) {
    return p;
  }

  // 情况2：key 比当前节点大，往后继方向（正向）搜索
  // 利用有序性：数据是升序排列的，遇到比 key 大的节点提前终止
  if (key > p->data) {
    DblListNode<T> *current = p->next;
    while (current != nullptr && current->data < key) {
      // 数据仍小于 key，继续往后走
      current = current->next;
    }
    // 检查是否找到目标
    if (current != nullptr && current->data == key) {
      p = current;  // 更新搜索位置
      return current;
    }
  }
  // 情况3：key 比当前节点小，往前驱方向（反向）搜索
  // 利用有序性：遇到比 key 小的节点提前终止
  else {
    DblListNode<T> *current = p->prev;
    while (current != nullptr && current->data > key) {
      // 数据仍大于 key，继续往前走
      current = current->prev;
    }
    // 检查是否找到目标
    if (current != nullptr && current->data == key) {
      p = current;  // 更新搜索位置
      return current;
    }
  }

  // 未找到目标，返回 nullptr，p 保持不变
  return nullptr;
}
```