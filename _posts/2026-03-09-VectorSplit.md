---
title: C++ vector 字符串分割与 getline 用法
date: 2026-03-09 15:00 +0800
categories: [Blogs, Learn]
tags: [cpp, stl, string]
---

# C++ 字符串分割与 getline

## 字符串分割

### 自定义分隔符

```cpp
vector<string> split(const string &s) {
    vector<string> res;
    string tmp;

    for (char c : s) {
        if (c == ' ' || c == ',' || c == '.' || c == '!' || c == '?') {
            if (!tmp.empty()) {
                res.push_back(tmp);
                tmp.clear();
            }
        } else {
            tmp += c;
        }
    }
    if (!tmp.empty()) res.push_back(tmp);
    return res;
}
```

### stringstream 分割

```cpp
// 按空格分割
vector<string> split(const string &s) {
    vector<string> res;
    stringstream ss(s);
    string word;
    while (ss >> word) res.push_back(word);
    return res;
}

// 按指定分隔符分割
vector<string> split(const string &s, char delim) {
    vector<string> res;
    stringstream ss(s);
    string item;
    while (getline(ss, item, delim)) {
        if (!item.empty()) res.push_back(item);
    }
    return res;
}
```

## getline 用法

| 函数 | 说明 |
|:---:|:---|
| `getline(cin, str)` | 读取一行到换行符 |
| `getline(cin, str, delim)` | 读取到指定分隔符 |

### 读取多行

```cpp
int n;
cin >> n;
cin.ignore();  // 清除换行符

string line;
for (int i = 0; i < n; i++) {
    getline(cin, line);
}
```

### CSV 解析

```cpp
vector<string> parseCSV(const string &line) {
    vector<string> res;
    stringstream ss(line);
    string field;
    while (getline(ss, field, ',')) {
        res.push_back(field);
    }
    return res;
}
```

## 总结

| 方法 | 适用场景 |
|:---:|:---|
| 字符遍历 | 自定义多分隔符 |
| `stringstream` | 简单空格分割 |
| `getline` | 指定单一分隔符 |
| `cin.ignore()` | `cin >>` 后接 `getline` 必备 |