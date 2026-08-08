---
title: AirLLM 把 Kimi K3 压进 3.72GB 显存，8GB 笔记本还是没法用
date: 2026-08-08 12:00 +0800
categories: [Blogs, Share]
tags: [airllm, kimi-k3, llm, local-llm, gpu]
---

# AirLLM 把 Kimi K3 压进 3.72GB 显存，8GB 笔记本还是没法用

手上这台笔记本是 RTX 5060 Laptop，8GB 显存。Kimi K3 是 2.8T 参数的 MoE 模型，每 token 激活 104B，官方推荐 vLLM 多卡集群部署。这两个数差着三个数量级，本来不该放在一起想。直到我看见 AirLLM 的 README 说，Kimi K3 在单张 RTX 6000 Ada 上实测峰值显存 3.72GB。

这个数字太诱人了。8GB 减去 3.72GB 还剩一半多，我的显卡好像够得着。我把 AirLLM 的 README、源码和 GitHub issue 翻了一遍，又把 Kimi K3 的参数表对了一遍，最后得出的结论是显存确实够，但这台机器跑不动。下面把研究过程写下来，给同样想用 8GB 卡碰大模型的人参考。

## AirLLM 怎么把 2.8T 模型装进 3.72GB

AirLLM 的做法是把模型拆开，一次只在显存里放当前正在计算的那一层。

模型先挂在 meta device 上，只建结构，不占显存。每个模块，从 embedding、每一层 decoder 到最后的 norm 和 lm_head，都注册 forward 前后的两个 hook。pre-hook 在模块执行前把这一层的权重从磁盘读进显存，post-hook 算完立刻把权重移回 meta device，把显存清出来。下一层要用，再读一次。

光按层拆还不够。Kimi K3 一层有 896 个 expert，展开以后大约 55GB，整层读进来怎么都放不下。AirLLM 对每个 expert 单独注册 hook，只加载 router 当前选中的 16 个。safetensors 支持按 tensor 名字随机读取，一个 expert 的权重只有几十 MB，从 17GB 的分片文件里直接 seek 出来就行，不用读整个文件。

于是每层只承担这一小块账。16 个被选中的 expert 展开成 bf16 大约 1GB，attention、router 和 norm 占 0.5 到 1GB，KV cache 短上下文不到 1GB，再加上激活值缓冲和 CUDA 的固定开销。我按源码逐项估算，加起来正好落在 README 那个 3.72GB 附近。注意这是短上下文的情况，上下文一长 KV cache 就线性涨，Windows 桌面合成器还要占走 0.5 到 1GB，8GB 卡的余量很快就没了。

## 显存以外还有内存和磁盘

模型本身要 1.5TB 磁盘。Kimi K3 的 checkpoint 恰好每层一个分片，每个约 17GB，AirLLM 用 hard link 直接引用，省掉复制这一步，磁盘不用翻倍。

内存也不轻松。AirLLM 用后台线程预取下一层，当前层加预取层同时驻留内存，一层 17GB 的话就是 34GB。笔记本常见的 16 到 32GB 内存，默认就卡在这一关，除非关掉预取。

## 速度这一关过不去

3.72GB 显存是真的，速度是另一回事。AirLLM 仓库里没有可复现的 benchmark，GitHub issue #295 专门提过，README 声称的加速都没有配套数据。下面这段是我自己算的，不是官方数字。

每生成一个 token，模型要遍历 93 层，每层从磁盘读 16 个 expert 的 MXFP4 权重，加 attention 和 router。一层大约 1.2GB，93 层就是 112GB 磁盘读取。

磁盘决定上限。按 NVMe Gen4 标称 5GB/s 算，112GB 要 22 秒，也就是 0.045 token/s。SATA SSD 更慢，大约 224 秒一个 token。预取机制能重叠一部分 I/O，但最好情况也就是 0.05 token/s。生成一个 100 token 的回答，半小时起步。

对，显存只用了 3.72GB，剩下的时间都在等硬盘。

顺带一提，README 里那个 3 倍加速来自 4bit/8bit 压缩，Kimi K3 本身就是 MXFP4 量化，这条路用不上。

## 还有一个绕不过去的依赖

Kimi K3 的模型代码强制要求 flash attention，无论你设置什么注意力实现。flash-attn 没有 Blackwell 架构（sm_120）的预编译 wheel，要从源码编译，需要 CUDA 12 工具链加 MSVC。在 Windows 笔记本上基本是死路，换成 Linux 也要折腾一轮。

## 结论

结论是别折腾。flash-attn 装不上，第一关就过不去。速度没有实用价值，0.05 token/s 连验证都嫌慢。内存和磁盘也卡着，预取要 34GB，模型占 1.5TB。

这个方案还剩一个窄场景，就是实验性质的验证，比如确认某一层某个 expert 的输出对不对。真要日常对话，8GB 卡老老实实跑 7 到 14B 的量化模型，llama.cpp 一路通吃。Kimi K3 官方推荐 vLLM 集群部署，那是 H100 的事。

AirLLM 的分层流式设计本身值得看，源码写得清楚，per-expert 流式加载以后可能还会出现在别处。只是它救不了 8GB 显卡跑 2.8T 模型这件事。

## 参考来源

- [AirLLM 仓库 README](https://github.com/lyogavin/airllm)，3.72GB 显存声明、flash-attn 与 CUDA 12 要求
- [AirLLM issue #295](https://github.com/lyogavin/airllm/issues/295)，仓库缺乏可复现的性能数据
- [Kimi K3 官方仓库](https://github.com/MoonshotAI/Kimi-K3)，模型参数表与部署建议
- airllm 源码（airllm_base.py、utils.py、airllm_kimi_k3.py），流式加载与 per-expert 实现
