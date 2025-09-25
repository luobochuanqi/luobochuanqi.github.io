---
title: 链表
date: 2025-09-25 21:00 +0800
categories: [Blogs, Learn]
tags: [cpp, linklist]
image:
  path: /assets/img/blog/LinkedList.png
  alt: 链表
---

# 数据结构的基石 —— 链表

> 实现操作集 **创、消、增、删、改、查**
{: .prompt-info }

## 结构体
```cpp
typedef struct LinkNode {
	int data;
	struct LinkNode* next;
} *LinkList;
```
## 创
```cpp
LinkList CreateList() {
	LinkList list = nullptr;
	return list;
}
```
## 消
```cpp
void DelList(LinkList &list) {
	free(list);
}
```
## 增、删、改、查
```cpp

```