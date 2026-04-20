---
title: 编译器的旅行
date: 2026-04-14 16:00 +0800
categories: [Blogs, Learn]
tags: [csapp]
---

## 程序编译的五个过程

1. **预处理（Preprocessing）**：处理宏定义、头文件包含、条件编译等
   - 命令：`gcc -E hello.c -o hello.i`

2. **编译（Compilation）**：将预处理后的代码转换为汇编代码
   - 命令：`gcc -S hello.i -o hello.s`

3. **汇编（Assembly）**：将汇编代码转换为目标机器码
   - 命令：`gcc -c hello.s -o hello.o`

4. **链接（Linking）**：将多个目标文件和库文件链接成可执行文件
   - 命令：`gcc hello.o -o hello`
