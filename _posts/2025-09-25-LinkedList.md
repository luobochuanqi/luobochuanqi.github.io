---
title: 链表
date: 2025-09-25 21:00 +0800
categories: [Blogs]
tags: [cpp]
---
# A linked list!

```cpp
#include <iostream>
#include <stdexcept>

template<typename T>
class LinkedList {
private:
    // 链表节点定义
    struct Node {
        T data;
        Node* next;
        Node(const T& value) : data(value), next(nullptr) {}
    };
    
    Node* head;    // 头指针
    Node* tail;    // 尾指针（便于尾部操作）
    size_t size;   // 链表大小

public:
    // 构造函数
    LinkedList() : head(nullptr), tail(nullptr), size(0) {}
    
    // 拷贝构造函数
    LinkedList(const LinkedList& other) : head(nullptr), tail(nullptr), size(0) {
        Node* current = other.head;
        while (current != nullptr) {
            pushBack(current->data);
            current = current->next;
        }
    }
    
    // 赋值运算符
    LinkedList& operator=(const LinkedList& other) {
        if (this != &other) {
            clear(); // 清空当前链表
            
            Node* current = other.head;
            while (current != nullptr) {
                pushBack(current->data);
                current = current->next;
            }
        }
        return *this;
    }
    
    // 析构函数
    ~LinkedList() {
        clear();
    }
    
    // 在链表头部添加元素
    void pushFront(const T& value) {
        Node* newNode = new Node(value);
        
        if (isEmpty()) {
            head = tail = newNode;
        } else {
            newNode->next = head;
            head = newNode;
        }
        size++;
    }
    
    // 在链表尾部添加元素
    void pushBack(const T& value) {
        Node* newNode = new Node(value);
        
        if (isEmpty()) {
            head = tail = newNode;
        } else {
            tail->next = newNode;
            tail = newNode;
        }
        size++;
    }
    
    // 在指定位置插入元素
    void insert(size_t index, const T& value) {
        if (index > size) {
            throw std::out_of_range("Index out of range");
        }
        
        if (index == 0) {
            pushFront(value);
            return;
        }
        
        if (index == size) {
            pushBack(value);
            return;
        }
        
        Node* newNode = new Node(value);
        Node* current = head;
        
        // 找到插入位置的前一个节点
        for (size_t i = 0; i < index - 1; i++) {
            current = current->next;
        }
        
        newNode->next = current->next;
        current->next = newNode;
        size++;
    }
    
    // 删除头部元素
    void popFront() {
        if (isEmpty()) {
            throw std::runtime_error("Cannot pop from empty list");
        }
        
        Node* temp = head;
        head = head->next;
        
        if (head == nullptr) {
            tail = nullptr;
        }
        
        delete temp;
        size--;
    }
    
    // 删除尾部元素
    void popBack() {
        if (isEmpty()) {
            throw std::runtime_error("Cannot pop from empty list");
        }
        
        if (size == 1) {
            delete head;
            head = tail = nullptr;
        } else {
            Node* current = head;
            while (current->next != tail) {
                current = current->next;
            }
            
            delete tail;
            tail = current;
            tail->next = nullptr;
        }
        size--;
    }
    
    // 删除指定位置的元素
    void erase(size_t index) {
        if (index >= size) {
            throw std::out_of_range("Index out of range");
        }
        
        if (index == 0) {
            popFront();
            return;
        }
        
        Node* current = head;
        for (size_t i = 0; i < index - 1; i++) {
            current = current->next;
        }
        
        Node* toDelete = current->next;
        current->next = toDelete->next;
        
        if (toDelete == tail) {
            tail = current;
        }
        
        delete toDelete;
        size--;
    }
    
    // 删除指定值的第一个出现
    void remove(const T& value) {
        if (isEmpty()) return;
        
        if (head->data == value) {
            popFront();
            return;
        }
        
        Node* current = head;
        while (current->next != nullptr && current->next->data != value) {
            current = current->next;
        }
        
        if (current->next != nullptr) {
            Node* toDelete = current->next;
            current->next = toDelete->next;
            
            if (toDelete == tail) {
                tail = current;
            }
            
            delete toDelete;
            size--;
        }
    }
    
    // 查找元素是否存在
    bool contains(const T& value) const {
        Node* current = head;
        while (current != nullptr) {
            if (current->data == value) {
                return true;
            }
            current = current->next;
        }
        return false;
    }
    
    // 获取指定位置的元素
    T& at(size_t index) {
        if (index >= size) {
            throw std::out_of_range("Index out of range");
        }
        
        Node* current = head;
        for (size_t i = 0; i < index; i++) {
            current = current->next;
        }
        return current->data;
    }
    
    const T& at(size_t index) const {
        if (index >= size) {
            throw std::out_of_range("Index out of range");
        }
        
        Node* current = head;
        for (size_t i = 0; i < index; i++) {
            current = current->next;
        }
        return current->data;
    }
    
    // 重载[]运算符
    T& operator[](size_t index) {
        return at(index);
    }
    
    const T& operator[](size_t index) const {
        return at(index);
    }
    
    // 获取链表大小
    size_t getSize() const {
        return size;
    }
    
    // 判断链表是否为空
    bool isEmpty() const {
        return size == 0;
    }
    
    // 清空链表
    void clear() {
        while (!isEmpty()) {
            popFront();
        }
    }
    
    // 打印链表（用于测试）
    void print() const {
        Node* current = head;
        std::cout << "LinkedList: ";
        while (current != nullptr) {
            std::cout << current->data;
            if (current->next != nullptr) {
                std::cout << " -> ";
            }
            current = current->next;
        }
        std::cout << " -> NULL" << std::endl;
    }
    
    // 迭代器支持（简单版本）
    class Iterator {
    private:
        Node* current;
        
    public:
        Iterator(Node* node) : current(node) {}
        
        T& operator*() {
            return current->data;
        }
        
        Iterator& operator++() {
            if (current != nullptr) {
                current = current->next;
            }
            return *this;
        }
        
        bool operator!=(const Iterator& other) const {
            return current != other.current;
        }
    };
    
    Iterator begin() {
        return Iterator(head);
    }
    
    Iterator end() {
        return Iterator(nullptr);
    }
};

// 测试示例
int main() {
    LinkedList<int> list;
    
    // 测试添加操作
    list.pushBack(1);
    list.pushBack(2);
    list.pushBack(3);
    list.pushFront(0);
    list.print(); // 0 -> 1 -> 2 -> 3 -> NULL
    
    // 测试插入操作
    list.insert(2, 99);
    list.print(); // 0 -> 1 -> 99 -> 2 -> 3 -> NULL
    
    // 测试访问操作
    std::cout << "Element at index 2: " << list[2] << std::endl; // 99
    
    // 测试删除操作
    list.popFront();
    list.popBack();
    list.print(); // 1 -> 99 -> 2 -> NULL
    
    // 测试查找操作
    std::cout << "Contains 99: " << list.contains(99) << std::endl; // 1 (true)
    std::cout << "Contains 100: " << list.contains(100) << std::endl; // 0 (false)
    
    // 测试迭代器
    std::cout << "Using iterator: ";
    for (auto it = list.begin(); it != list.end(); ++it) {
        std::cout << *it << " ";
    }
    std::cout << std::endl;
    
    // 测试拷贝构造
    LinkedList<int> list2 = list;
    list2.print();
    
    return 0;
}
```