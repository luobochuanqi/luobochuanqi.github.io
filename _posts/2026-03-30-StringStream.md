---
title: C++ stringstream 小技巧
date: 2026-03-30 08:00 +0800
categories: [Blogs, Learn]
tags: [cpp, string]
---

# C++ stringstream 与 cout 格式化输出技巧

## 一、stringstream 基础用法

`<sstream>` 库提供了 `stringstream`，可以像操作流一样操作字符串，非常适合类型转换和字符串解析。

### 1.1 字符串与其他类型的转换

```cpp
#include <iostream>
#include <sstream>
#include <string>
using namespace std;

int main() {
    // 数字转字符串
    stringstream ss1;
    ss1 << 12345;
    string str1 = ss1.str();
    cout << str1 << endl;  // 输出: 12345

    // 字符串转数字
    stringstream ss2("3.14159");
    double pi;
    ss2 >> pi;
    cout << pi << endl;    // 输出: 3.14159

    // 更简洁的写法：使用构造函数
    string str2 = to_string(42);        // C++11 起
    int num = stoi("123");              // C++11 起
    double d = stod("3.14");            // C++11 起

    return 0;
}
```

### 1.2 字符串分割

`stringstream` 默认以空白字符为分隔符，非常适合分割字符串：

```cpp
#include <iostream>
#include <sstream>
#include <string>
using namespace std;

int main() {
    string line = "Hello World from C++";
    stringstream ss(line);
    string word;

    while (ss >> word) {
        cout << word << endl;
    }
    // 输出:
    // Hello
    // World
    // from
    // C++

    return 0;
}
```

### 1.4 清空 stringstream

注意：`ss.str("")` 清空内容，`ss.clear()` 清除错误状态。两者常配合使用：

```cpp
stringstream ss;
ss << "first";
cout << ss.str() << endl;  // 输出: first

ss.str("");   // 清空字符串内容
ss.clear();   // 清除错误状态（重要！）
ss << "second";
cout << ss.str() << endl;  // 输出: second
```

## 二、cout 格式化输出

`<iomanip>` 库提供了丰富的格式化控制符，需要 `#include <iomanip>`。

### 2.1 设置宽度（setw）

`setw(n)` 设置下一个输出项的最小宽度为 n 个字符：

```cpp
#include <iostream>
#include <iomanip>
using namespace std;

int main() {
    cout << setw(10) << 42 << endl;      // 右对齐，占10格
    cout << setw(10) << left << 42 << endl;  // 左对齐，占10格
    cout << setw(5) << 1 << setw(5) << 2 << endl;

    // 输出:
    //         42
    // 42
    //     1    2

    return 0;
}
```

### 2.2 设置填充字符（setfill）

`setfill(c)` 设置填充字符，默认是空格：

```cpp
#include <iostream>
#include <iomanip>
using namespace std;

int main() {
    cout << setfill('0') << setw(5) << 42 << endl;    // 输出: 00042
    cout << setfill('*') << setw(8) << 123 << endl;   // 输出: *****123

    // 输出日期格式
    int year = 2026, month = 3, day = 30;
    cout << year << "-" 
         << setfill('0') << setw(2) << month << "-" 
         << setw(2) << day << endl;  // 输出: 2026-03-30

    return 0;
}
```

### 2.3 对齐方式

```cpp
#include <iostream>
#include <iomanip>
using namespace std;

int main() {
    cout << setw(10) << left << "Left" << "|" << endl;    // 左对齐
    cout << setw(10) << right << "Right" << "|" << endl;  // 右对齐（默认）
    cout << setw(10) << internal << -42 << "|" << endl;   // 符号左对齐，数字右对齐

    // 输出:
    // Left      |
    //      Right|
    // -       42|

    return 0;
}
```

### 2.4 设置精度（setprecision）

`setprecision(n)` 设置浮点数精度：

```cpp
#include <iostream>
#include <iomanip>
using namespace std;

int main() {
    double pi = 3.14159265358979;

    // 默认格式：有效数字位数
    cout << setprecision(4) << pi << endl;        // 输出: 3.142

    // 固定小数位数
    cout << fixed << setprecision(2) << pi << endl;  // 输出: 3.14
    cout << fixed << setprecision(4) << pi << endl;  // 输出: 3.1416

    // 科学计数法
    cout << scientific << setprecision(3) << pi << endl;  // 输出: 3.142e+00

    // 恢复默认
    cout.unsetf(ios::fixed | ios::scientific);

    return 0;
}
```

### 2.5 格式化输出表格示例

```cpp
#include <iostream>
#include <iomanip>
#include <string>
using namespace std;

int main() {
    // 表头
    cout << left << setw(15) << "姓名" 
         << right << setw(8) << "语文" 
         << setw(8) << "数学" 
         << setw(8) << "英语" << endl;

    // 分隔线
    cout << setfill('-') << setw(39) << "" << setfill(' ') << endl;

    // 数据行
    cout << left << setw(15) << "张三" 
         << right << setw(8) << 95 
         << setw(8) << 88 
         << setw(8) << 92 << endl;

    cout << left << setw(15) << "李四" 
         << right << setw(8) << 78 
         << setw(8) << 85 
         << setw(8) << 90 << endl;

    // 输出:
    // 姓名               语文    数学    英语
    // ---------------------------------------
    // 张三                  95      88      92
    // 李四                  78      85      90

    return 0;
}
```

## 三、其他常用技巧

### 3.1 进制转换

```cpp
#include <iostream>
#include <iomanip>
using namespace std;

int main() {
    int n = 255;

    cout << "十进制: " << dec << n << endl;    // 输出: 255
    cout << "十六进制: " << hex << n << endl;  // 输出: ff
    cout << "八进制: " << oct << n << endl;    // 输出: 377

    // 十六进制大写，带前缀
    cout << hex << uppercase << showbase << n << endl;  // 输出: 0XFF

    // 恢复默认
    cout << dec << nouppercase << noshowbase;

    return 0;
}
```

### 3.2 布尔值输出

```cpp
#include <iostream>
using namespace std;

int main() {
    bool flag = true;

    cout << flag << endl;              // 输出: 1（默认）
    cout << boolalpha << flag << endl; // 输出: true
    cout << noboolalpha << flag << endl; // 输出: 1

    return 0;
}
```

### 3.3 正负号显示

```cpp
#include <iostream>
using namespace std;

int main() {
    int a = 42, b = -42;

    cout << a << endl;           // 输出: 42
    cout << showpos << a << endl; // 输出: +42
    cout << b << endl;           // 输出: -42
    cout << noshowpos << a << endl; // 输出: 42

    return 0;
}
```

### 3.4 通过 stringstream 格式化字符串

结合 `stringstream` 和格式化控制符，可以生成格式化字符串：

```cpp
#include <iostream>
#include <sstream>
#include <iomanip>
using namespace std;

int main() {
    stringstream ss;

    // 格式化时间字符串
    int hour = 9, minute = 5, second = 3;
    ss << setfill('0') 
       << setw(2) << hour << ":" 
       << setw(2) << minute << ":" 
       << setw(2) << second;

    string timeStr = ss.str();
    cout << timeStr << endl;  // 输出: 09:05:03

    return 0;
}
```

## 四、常用格式化控制符速查表

| 控制符 | 作用 | 持续性 |
|:---|:---|:---:|
| `setw(n)` | 设置宽度为 n | 单次 |
| `setfill(c)` | 设置填充字符 | 持续 |
| `setprecision(n)` | 设置精度 | 持续 |
| `left` | 左对齐 | 持续 |
| `right` | 右对齐 | 持续 |
| `internal` | 符号左对齐，数值右对齐 | 持续 |
| `fixed` | 固定小数点格式 | 持续 |
| `scientific` | 科学计数法 | 持续 |
| `hex` / `oct` / `dec` | 进制转换 | 持续 |
| `showpos` | 显示正号 | 持续 |
| `boolalpha` | 布尔值输出 true/false | 持续 |
| `uppercase` | 十六进制大写 | 持续 |
| `showbase` | 显示进制前缀 | 持续 |

> **注意**：持续性控制符会一直生效，直到被修改；`setw` 只对下一个输出项有效。

