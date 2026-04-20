---
title: CUDA 学习笔记（二）：编译流程与 PTX 架构
date: 2026-04-20 17:06 +0800
categories: [Blogs, Learn]
tags: [cuda, gpu, compilation, ptx]
---

## NVCC 编译流程

CUDA 程序使用 `nvcc` 编译器进行编译，从 `.cu` 源文件到可执行文件经历多个阶段：

```bash
# 一步到位编译
nvcc hello.cu -o hello

# 分步编译
nvcc -E hello.cu -o hello.i           # 预处理
nvcc -ptx hello.i -o hello.ptx        # 编译为 PTX
nvcc -c hello.ptx -o hello.cubin      # 编译为 SASS（二进制）
nvcc -dlink hello.cubin -o hello_dlink.o  # 设备链接
nvcc hello_dlink.o -o hello           # 主机链接
```

### 编译流程图

![CUDA 编译流程](assets/img/blog/cuda-compilation-from-cu-to-executable.png)

*从 CUDA 源代码到可执行文件的完整编译流程*

## PTX 的设计目的

**PTX（Parallel Thread Execution）** 是一种虚拟的 GPU 指令集架构，它的设计目的可以用一个通俗的比喻来理解：

> 想象你要写一本编程教程，但不知道读者会使用什么型号的电脑。于是你选择用一种"伪代码"来写，这种伪代码可以被翻译成任何型号的电脑都能理解的指令。PTX 就是这个"伪代码"。

### 为什么需要 PTX？

1. **向前兼容**：PTX 作为中间表示，使得同一份 CUDA 程序可以在不同代际的 GPU 上运行。NVIDIA 驱动程序中的 **JIT（Just-In-Time）编译器**会在程序运行时将 PTX 编译为当前 GPU 架构的原生 SASS 指令。

2. **向后兼容**：即使未来的 GPU 架构发生变化，只要支持 PTX，旧的 CUDA 程序仍然可以运行。

3. **抽象硬件细节**：开发者无需为每种 GPU 架构单独编译，只需指定目标计算能力（如 `-arch=sm_80`），nvcc 会自动生成对应的 PTX 和 SASS。

### JIT 编译

![即时编译](assets/img/blog/just-in-time-compilation.png)

*JIT 编译在运行时将 PTX 转换为特定 GPU 架构的 SASS 指令*

## 编译选项详解

| 选项 | 说明 |
|------|------|
| `-arch=sm_xx` | 指定目标 GPU 架构（如 sm_80 表示 Ampere） |
| `-code=sm_xx` | 生成特定架构的可执行代码 |
| `-ptx` | 只编译到 PTX 中间代码 |
| `-cubin` | 生成 CUDA 二进制文件（.cubin） |
| `-fatbin` | 生成包含多种架构的胖二进制文件 |

### 示例：生成多架构胖二进制

```bash
# 为多种 GPU 架构生成代码
nvcc -arch=sm_80 -code=sm_80,sm_86,sm_90 hello.cu -o hello
```

这样生成的可执行文件可以在不同代际的 GPU 上运行。

## 参考链接

- [NVIDIA 官方 NVCC 文档](https://docs.nvidia.com/cuda/cuda-compiler-driver-nvcc/index.html)
