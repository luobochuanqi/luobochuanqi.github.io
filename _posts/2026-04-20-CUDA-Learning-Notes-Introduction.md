---
title: CUDA 学习笔记（一）：入门与线程模型
date: 2026-04-20 16:40 +0800
categories: [Blogs, Learn]
tags: [cuda, gpu, parallel-computing]
---

## Hello World

```cuda
#include <stdio.h>

__global__ void helloCUDA() {
    printf("Hello from GPU! Thread ID: %d\n", threadIdx.x);
}

int main() {
    helloCUDA<<<1, 5>>>();
    cudaDeviceSynchronize();
    return 0;
}
```

### 编译命令

```bash
nvcc hello.cu -o hello
./hello
```

## CUDA 线程模型

CUDA 的线程层次结构分为三层：

- **Thread（线程）**：最基本的执行单元
- **Block（线程块）**：一组线程，共享共享内存
- **Grid（网格）**：一组 Block，构成整个 kernel 的执行

```
Grid (1D)
├── Block 0 (1D)
│   ├── Thread 0
│   ├── Thread 1
│   └── ...
├── Block 1 (1D)
│   ├── Thread 0
│   ├── Thread 1
│   └── ...
└── ...
```

## 线程唯一标识计算

### 1D Grid + 1D Block

```cuda
// GridDim: 网格中 Block 的数量
// BlockDim: 每个 Block 中线程的数量
int threadId = blockIdx.x * blockDim.x + threadIdx.x;
```

| 索引 | blockIdx.x | threadIdx.x | threadId |
|------|------------|-------------|----------|
| 0    | 0          | 0           | 0        |
| 1    | 0          | 1           | 1        |
| 2    | 1          | 0           | 2        |
| 3    | 1          | 1           | 3        |

### 2D Grid + 2D Block

```cuda
int blockId = blockIdx.x + blockIdx.y * gridDim.x;
int threadId = blockId * (blockDim.x * blockDim.y) +
               threadIdx.y * blockDim.x +
               threadIdx.x;
```

| blockIdx | blockIdx.y | threadIdx.x | threadIdx.y | threadId |
|----------|------------|-------------|-------------|----------|
| (0,0)    | 0          | 0           | 0           | 0        |
| (1,0)    | 0          | 0           | 0           | 1        |
| (0,1)    | 1          | 0           | 0           | 2        |
| (1,1)    | 1          | 0           | 0           | 3        |

### 3D Grid + 3D Block

```cuda
int blockId = blockIdx.x + 
              blockIdx.y * gridDim.x + 
              blockIdx.z * gridDim.x * gridDim.y;

int threadId = blockId * (blockDim.x * blockDim.y * blockDim.z) +
               threadIdx.z * (blockDim.x * blockDim.y) +
               threadIdx.y * blockDim.x +
               threadIdx.x;
```

| blockIdx | threadIdx | threadId 计算 |
|----------|-----------|---------------|
| (x,y,z)  | (x,y,z)   | `blockIdx.x + blockIdx.y * gridDim.x + blockIdx.z * gridDim.x * gridDim.y` 作为 blockId，再展开线程 |

## 完整示例

```cuda
#include <stdio.h>

__global__ void printThreadInfo() {
    int threadId = blockIdx.x * blockDim.x + threadIdx.x;
    printf("Thread %d: blockIdx=(%d,%d,%d) threadIdx=(%d,%d,%d)\n",
           threadId,
           blockIdx.x, blockIdx.y, blockIdx.z,
           threadIdx.x, threadIdx.y, threadIdx.z);
}

int main() {
    dim3 blockDim(2, 2, 2);      // 8 threads per block
    dim3 gridDim(2, 2, 2);       // 8 blocks
    printThreadInfo<<<gridDim, blockDim>>>();
    cudaDeviceSynchronize();
    return 0;
}
```

编译运行：
```bash
nvcc thread_info.cu -o thread_info
./thread_info
```
