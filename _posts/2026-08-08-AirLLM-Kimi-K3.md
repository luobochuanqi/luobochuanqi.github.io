---
title: AirLLM 把 Kimi K3 压进 3.72GB 显存，8GB 笔记本还是没法用
date: 2026-08-08 12:00 +0800
categories: [Blogs, Research]
tags: [airllm, kimi-k3, llm, local-llm, gpu]
---

# AirLLM + Kimi K3 本地部署可行性研究

## 1. 结论先行

**RTX 5060 Laptop (8GB VRAM) 理论上可以通过 AirLLM 运行 Kimi K3，但实际体验极差，不推荐作为日常使用方案。**

AirLLM 官方声称 Kimi K3 (2.8T) 在 RTX 6000 Ada 上实测峰值 VRAM 为 3.72GB（来源：airllm README Updates [2026/07] 段落）。8GB VRAM 在数值上足够容纳模型权重 + 短上下文 KV cache，但存在以下硬性障碍：

- **flash-attn 依赖**：Kimi K3 的模型代码强制要求 flash attention，而 flash-attn 目前没有针对 Blackwell (sm_120) + CUDA 12 的预编译 wheel（来源：airllm README "K3 brings three requirements"）
- **速度极慢**：每个 token 需要从磁盘流式加载 93 层 × 16 个 expert 的权重，预期速度在 0.1-1 tok/s 量级（无官方 benchmark，见第 4 节推算）
- **磁盘需求 ~1.5TB**：完整模型下载 + 分层存储（来源：airllm utils.py 注释 "1.5TB+ for a 2.8T-parameter model"）
- **CPU RAM 需求 64GB+**：prefetching 机制会同时在内存中保持 2 个层的权重（来源：airllm_base.py `max_pinned_layer_bytes` 注释）

---

## 2. AirLLM 核心原理

### 2.1 Layer-wise Streaming 机制

AirLLM 的核心思想是：**永远只在 GPU 上保留当前正在计算的一层权重**，其余层的权重存储在磁盘上，按需加载。

具体实现（来源：`air_llm/airllm/airllm_base.py`）：

1. **Meta device 初始化**：使用 `accelerate.init_empty_weights()` 在 meta device 上实例化完整的 transformers 模型，此时不占用任何显存/内存：

   ```python
   with init_empty_weights(include_buffers=False):
       self.model = AutoModelForCausalLM.from_config(
           self.config, attn_implementation="sdpa", trust_remote_code=self.trust_remote_code)
   ```

2. **Forward hooks 注入**：对每个模块（embed → 每个 decoder layer → norm → lm_head）注册 `register_forward_pre_hook` 和 `register_forward_hook`：

   ```python
   module.register_forward_pre_hook(self._pre_hook)
   module.register_forward_hook(self._post_hook)
   ```

3. **Pre-hook（加载）**：在模块执行前，从磁盘 safetensors 文件读取该层权重 → 传输到 GPU：

   ```python
   def _pre_hook(self, module, args):
       state_dict = self._load_streamed_layer(idx)
       module._airllm_moved = self.move_layer_to_device(state_dict)
   ```

4. **Post-hook（释放）**：模块执行完毕后，将权重移回 meta device（即释放 VRAM）：

   ```python
   def _post_hook(self, module, args, output):
       for param_name in getattr(module, '_airllm_moved', []):
           set_module_tensor_to_device(self.model, param_name, 'meta')
       clean_memory()
   ```

5. **Prefetching（预取）**：使用 `ThreadPoolExecutor(max_workers=1)` 在当前层计算时，后台线程预读下一层的权重到 CPU 内存：
   ```python
   self._prefetch_future = self._executor.submit(self._load_streamed_layer, nxt)
   ```
   这带来约 10% 的速度提升（来源：airllm README changelog [2023/12/18]）。

### 2.2 磁盘分层存储

首次加载时，AirLLM 将原始 checkpoint 拆分为每层一个 safetensors 文件（来源：`air_llm/airllm/utils.py` 的 `split_and_save_layers` 函数）。对于 Kimi K3 这种已经每层一个 shard 的 checkpoint，AirLLM 使用 hard link 而非复制，避免磁盘空间翻倍：

```python
# 来源：utils.py 注释
# Some checkpoints are already sharded exactly one module per file (Kimi K3, for instance, ships
# one ~17GB shard per decoder layer). Re-writing those into per-layer files would duplicate the
# entire checkpoint on disk -- 1.5TB+ for a 2.8T-parameter model -- and take hours
```

### 2.3 MXFP4 解压流程

Kimi K3 使用 MXFP4 量化权重。AirLLM 的加载流程是：

1. 从磁盘读取 packed 4-bit 数据（体积小，PCIe 传输快）
2. 在 GPU 上解压为 bf16 权重（来源：`_decompress_state_dict` 方法）
3. 计算完成后释放

```python
# 来源：airllm_base.py _decompress_state_dict 注释
# The expansion happens on the GPU, after transferring the *packed* bytes. For MXFP4 that
# moves 4x less data across PCIe than transferring an already-expanded weight would.
```

---

## 3. MoE 专家流式加载

### 3.1 为什么 Kimi K3 2.8T 能压到 3.72GB

关键数据（来源：https://github.com/MoonshotAI/Kimi-K3 README "Model Summary" 表格）：

| 参数                              | 值                                      |
| --------------------------------- | --------------------------------------- |
| 总参数量                          | 2.8T                                    |
| 每 token 激活参数量               | 104B                                    |
| 层数                              | 93                                      |
| 每层 expert 数                    | 896                                     |
| 每 token 选中 expert 数           | 16                                      |
| 共享 expert 数                    | 2                                       |
| MoE hidden dimension (per expert) | 3072                                    |
| Attention hidden dimension        | 7168                                    |
| 量化方式                          | MXFP4 weights / MXFP8 activations (QAT) |

**核心数学**：

- 每层展开后 expert 权重 ≈ 55GB（来源：airllm_kimi_k3.py docstring "expanded, a layer's experts are ~55GB"）
- 每个 token 实际需要的 expert 权重 ≈ 1GB（来源：同上 "a token needs ~1GB of them"）
- 如果加载整层 → 需要 55GB VRAM → 不可能
- 如果只加载被路由的 16 个 expert → 约 1GB → 可行

### 3.2 Per-expert Streaming 具体实现

AirLLM 不是加载整层的所有 expert，而是**只加载被 router 选中的 expert**。实现机制（来源：`airllm_base.py` 的 `_setup_expert_streaming` 方法）：

1. **为每个 expert 模块注册独立的 forward hook**：

   ```python
   for expert_idx, keys in per_expert.items():
       expert_module = experts_container[expert_idx]
       expert_module._airllm_expert = (idx, expert_idx)
       expert_module.register_forward_pre_hook(self._expert_pre_hook)
       expert_module.register_forward_hook(self._expert_post_hook)
   ```

2. **利用 safetensors 的随机访问能力**：safetensors 格式支持按 tensor name seek 读取，不需要加载整个文件：

   ```python
   # 来源：utils.py load_layer_subset
   def load_layer_subset(local_path, layer_name, keys):
       """Read only `keys` from a layer shard.
       safetensors can seek to individual tensors, so a single MoE expert costs its own few MB
       rather than the whole ~16GB layer file."""
       with safe_open(str(Path(local_path) / (layer_name + ".safetensors")), framework="pt") as f:
           for k in keys:
               out[k] = f.get_tensor(k)
   ```

3. **Expert pre-hook**：当模型的 forward 调用到某个被选中的 expert 时，才从磁盘读取该 expert 的权重：

   ```python
   def _expert_pre_hook(self, module, args):
       layer_idx, expert_idx = module._airllm_expert
       keys = self._expert_keys[layer_idx][expert_idx]
       state_dict = load_layer_subset(self.checkpoint_path, self.layer_names[layer_idx], keys)
       module._airllm_moved = self.move_layer_to_device(state_dict)
   ```

4. **Expert post-hook**：计算完立即释放：
   ```python
   def _expert_post_hook(self, module, args, output):
       for param_name in getattr(module, '_airllm_moved', []):
           set_module_tensor_to_device(self.model, param_name, 'meta')
   ```

### 3.3 3.72GB VRAM 峰值的组成

根据源码分析，峰值 VRAM 包含：

| 组件                                               | 估算大小                                              |
| -------------------------------------------------- | ----------------------------------------------------- |
| 当前 expert 权重（解压后 bf16）                    | ~1GB（16 experts × ~60MB each）                       |
| 非 expert 层权重（attention, router, layernorm）   | ~0.5-1GB                                              |
| KV cache（短上下文 128-512 tokens）                | ~0.5-1GB                                              |
| 激活值 + 中间计算缓冲                              | ~0.5GB                                                |
| Resident 模块（vision tower, projector, attn_res） | <1GB（来源：airllm_kimi_k3.py 注释 "well under 1GB"） |
| CUDA context + PyTorch overhead                    | ~0.3-0.5GB                                            |
| **合计**                                           | **~3.72GB**                                           |

注意：这是 `max_new_tokens` 较小、上下文较短时的峰值。随着上下文增长，KV cache 会线性增长。

---

## 4. RTX 5060 Laptop 可行性分析

### 4.1 硬件规格

RTX 5060 Laptop：

- VRAM：8GB GDDR7
- 架构：Blackwell (sm_120)
- 内存带宽：~256 GB/s（GPU 内部）
- PCIe：Gen 4/5 x8（笔记本通常 x8）
- 系统 RAM：通常 16-32GB（笔记本）

### 4.2 VRAM 是否够用

**数值上够，但余量紧张。**

- 模型峰值 VRAM：3.72GB（来源：airllm README，RTX 6000 Ada 实测）
- 剩余 VRAM：8 - 3.72 = 4.28GB
- KV cache 增长：Kimi K3 使用 MLA (Multi-head Latent Attention)，latent dimension = 3584，93 层。每 token KV cache ≈ 2 × 3584 × 93 × 2 bytes (bf16) ≈ 1.3MB/token
- 4.28GB 剩余 → 理论上可支持 ~3000+ tokens 上下文

**但实际风险**：

- RTX 6000 Ada 有 48GB VRAM，CUDA context 和 driver 开销比例更小
- 8GB 卡上 Windows 桌面合成器 (DWM) 会占用 0.5-1GB VRAM
- 实际可用可能只有 7-7.5GB，余量约 3.3-3.8GB
- 长上下文（>2K tokens）时可能 OOM

### 4.3 速度预期（推算）

**没有官方 benchmark 数据。** Issue #295 明确指出仓库缺乏可复现的性能证据（来源：https://github.com/lyogavin/airllm/issues/295）。

基于机制推算：

每个 token 的生成需要：

1. 遍历 93 层
2. 每层：从磁盘读取 16 个 expert 的 MXFP4 权重 + attention 权重
3. 每个 expert 约 60MB packed → 16 experts ≈ 960MB/层
4. 加上 attention/router/layernorm ≈ 额外 200-500MB/层
5. 每层总磁盘读取 ≈ 1-1.5GB
6. 93 层 × 1.2GB ≈ **112GB 磁盘读取/token**

磁盘速度决定上限：

- NVMe SSD (Gen4, ~5GB/s)：112GB / 5GB/s ≈ **22 秒/token** → ~0.045 tok/s
- SATA SSD (~500MB/s)：112GB / 0.5GB/s ≈ **224 秒/token** → ~0.004 tok/s
- 即使 prefetching 能 overlap 10%：**最好情况 ~0.05 tok/s (NVMe)**

这意味着生成一个 100 token 的回答需要 **30+ 分钟**。

对比：README 提到的 "3x speed up" 来自 4bit/8bit 压缩（减少磁盘读取量），但 Kimi K3 已经是 MXFP4，无法再压缩。

### 4.4 瓶颈分析

| 瓶颈              | 严重程度   | 说明                                                                                                   |
| ----------------- | ---------- | ------------------------------------------------------------------------------------------------------ |
| 磁盘 I/O          | **致命**   | 每 token 需读取 ~112GB，即使最快 NVMe 也需 20+ 秒                                                      |
| CPU RAM           | **严重**   | 笔记本通常 16-32GB，prefetching 需要同时保持 2 层权重 (~34GB pinned memory，来源：airllm_base.py 注释) |
| flash-attn 兼容性 | **阻断性** | 需要 CUDA 12 + sm_120 编译，目前无预编译 wheel                                                         |
| PCIe 带宽         | 中等       | 笔记本 PCIe x8 Gen4 ≈ 16GB/s，不是主要瓶颈（磁盘更慢）                                                 |
| VRAM 容量         | 可接受     | 短上下文 (<2K tokens) 下 8GB 够用                                                                      |

### 4.5 结论

**RTX 5060 Laptop 8GB 不能实际使用 AirLLM 运行 Kimi K3。** 原因：

1. flash-attn 在 Blackwell + Windows 上大概率无法安装（阻断性）
2. 即使解决依赖问题，~0.05 tok/s 的速度完全没有实用价值
3. 笔记本 16-32GB RAM 可能不够 prefetching 机制使用
4. 需要 ~1.5TB 磁盘空间存放模型

---

## 5. 限制与代价

### 5.1 速度

- **无官方 benchmark**：Issue #295 确认仓库没有任何可复现的性能数据（来源：https://github.com/lyogavin/airllm/issues/295）
- Prefetching 带来 10% 提升（来源：README changelog 2023/12/18）
- 4bit/8bit 压缩声称 3x 加速（来源：README "Model Compression" 段落），但仅适用于非量化模型，Kimi K3 已是 MXFP4 无法再用
- 实际速度完全受限于磁盘带宽，对于 2.8T 模型在消费级 SSD 上预期 <0.1 tok/s

### 5.2 磁盘需求

- Kimi K3 原始 checkpoint：~1.5TB（来源：utils.py 注释 "1.5TB+ for a 2.8T-parameter model"）
- 每层 shard 约 17GB（来源：utils.py 注释 "one ~17GB shard per decoder layer"）
- 使用 `delete_original=True` 可避免双倍空间，但 Kimi K3 使用 hard link passthrough，不需要额外空间（来源：utils.py `link_or_copy_file` 和 passthrough 逻辑）
- **最低磁盘需求：~1.5TB 可用空间**

### 5.3 CPU RAM 需求

- 非 prefetching 模式：一次只加载一层到 CPU → 峰值 ~17GB（最大层大小）
- Prefetching 模式：同时保持当前层 + 预取下一层 → 峰值 ~34GB
  - 来源：airllm_base.py 注释 "a frontier MoE checkpoint has ~17GB layers, and with prefetching two are in flight at once, which would lock up ~34GB of RAM"
- Pinned memory 上限：`max_pinned_layer_bytes = 2 * 1024 ** 3`（2GB），超过此大小的层使用 pageable memory
- **推荐系统 RAM：64GB+**（prefetching 模式）或 **32GB**（禁用 prefetching）

### 5.4 精度

- Kimi K3 使用 QAT (Quantization-Aware Training) 训练的 MXFP4 权重（来源：Kimi K3 README "Native MXFP4 Quantization" 段落）
- AirLLM 在 GPU 上将 MXFP4 解压为 bf16 进行计算，不引入额外精度损失
- 如果使用 AirLLM 自身的 4bit/8bit 压缩（bitsandbytes），会有 "almost ignorable accuracy loss"（来源：README），但 Kimi K3 不适用此路径

### 5.5 依赖限制

来源：`air_llm/setup.py` 和 README [2026/07] 段落：

| 依赖               | 要求            | 说明                                                   |
| ------------------ | --------------- | ------------------------------------------------------ |
| torch              | >=2.4           | 需要 CUDA 12 build                                     |
| transformers       | >=4.49, <5.13   | Kimi K3 remote code 不兼容 5.x                         |
| accelerate         | >=1.0           | meta device 支持                                       |
| safetensors        | 任意            | per-expert 随机读取依赖此格式                          |
| compressed-tensors | 必须（Kimi K3） | MXFP4 解压                                             |
| flash-attn         | 必须（Kimi K3） | 模型代码强制要求，无论用户设置什么 attn_implementation |
| CUDA               | 12.x            | "no prebuilt flash-attn wheel exists for CUDA 13 yet"  |
| bitsandbytes       | 可选            | 仅用于 4bit/8bit 压缩，Kimi K3 不需要                  |

**flash-attn 对 RTX 5060 Laptop (Blackwell, sm_120) 的问题**：

- flash-attn 官方预编译 wheel 通常只覆盖到 sm_90 (Hopper)
- sm_120 (Blackwell) 需要从源码编译，需要 CUDA 12 toolkit + 正确的 nvcc 版本
- Windows 上从源码编译 flash-attn 极其困难（需要 MSVC + CUDA 工具链）
- 这是一个**阻断性问题**，在 Windows 笔记本上基本无法解决

---

## 6. 与其他方案对比

| 维度             | AirLLM                            | llama.cpp                    | vLLM                                               | HF transformers (直接)        |
| ---------------- | --------------------------------- | ---------------------------- | -------------------------------------------------- | ----------------------------- |
| **Kimi K3 支持** | ✅ 有专门适配 (airllm_kimi_k3.py) | ❌ 无 GGUF 转换支持 2.8T MoE | ✅ 官方推荐 (来源：Kimi K3 README Deployment 段落) | ⚠️ 需要足够 VRAM 加载全部权重 |
| **最低 VRAM**    | ~3.72GB                           | N/A                          | 多卡，数百 GB                                      | ~1.5TB (全精度)               |
| **速度**         | 极慢 (磁盘瓶颈, ~0.05 tok/s)      | N/A                          | 快 (GPU 并行, 数十 tok/s)                          | 快 (如果 VRAM 够)             |
| **硬件要求**     | 小 GPU + 大磁盘 + 大 RAM          | N/A                          | 多张高端 GPU (H100/A100)                           | 多张高端 GPU                  |
| **量化**         | MXFP4 原生                        | GGUF Q4/Q5/Q8                | FP8/AWQ/GPTQ                                       | 无/需额外库                   |
| **适用场景**     | 实验/验证，非生产                 | 消费级本地推理               | 生产级服务                                         | 研究/开发                     |
| **Windows 支持** | ⚠️ flash-attn 阻断                | ✅ 原生支持                  | ❌ Linux only                                      | ✅                            |
| **8GB GPU 可行** | 理论可行，实际不可用              | N/A                          | ❌                                                 | ❌                            |

### 关键对比分析

**vs llama.cpp**：llama.cpp 是消费级本地推理的标准方案，但 Kimi K3 的 2.8T 参数即使 Q4 量化也需要 ~1.4TB 磁盘，且 MoE 架构的 GGUF 支持尚不成熟。对于 8GB GPU，llama.cpp 可以运行 7-14B 模型获得良好体验，但无法运行 Kimi K3。

**vs vLLM**：Kimi K3 官方推荐的部署方案（来源：https://github.com/MoonshotAI/Kimi-K3 README "Deployment" 段落），需要多张高端 GPU（H100/A100 集群），面向生产环境，不适合个人笔记本。

**vs HF transformers 直接加载**：需要 ~1.5TB VRAM（全精度）或 ~700GB（FP8），完全不现实。AirLLM 的价值正是在于将 VRAM 需求从 "不可能" 降到 "理论可行"。

---

## 7. 参考来源

### 源码文件

- `air_llm/airllm/airllm_base.py` — 核心 streaming 机制、forward hooks、per-expert streaming、prefetching、MXFP4 解压
- `air_llm/airllm/airllm_kimi_k3.py` — Kimi K3 专用配置（layer names、expert prefix、resident modules）
- `air_llm/airllm/utils.py` — 磁盘分层、safetensors 随机读取、hard link passthrough、空间检查
- `air_llm/tests/test_kimi_k3_split.py` — Kimi K3 checkpoint 结构测试（验证 per-layer shard linking）
- `air_llm/setup.py` — 依赖约束（torch>=2.4, transformers>=4.49,<5.13）

### GitHub 仓库

- https://github.com/lyogavin/airllm — AirLLM 主仓库（README 含 VRAM 表格、Kimi K3 支持说明、依赖要求）
- https://github.com/lyogavin/airllm/issues/295 — "Headline VRAM and performance claims lack reproducible verification"
- https://github.com/lyogavin/airllm/issues/301 — Windows AMD GPU 不工作的案例
- https://github.com/lyogavin/airllm/issues/273 — 性能改进提案（含社区对速度的反馈）
- https://github.com/MoonshotAI/Kimi-K3 — Kimi K3 官方仓库（模型参数表、部署建议）

### 模型信息

- Kimi K3 Model Summary（来源：https://github.com/MoonshotAI/Kimi-K3 README）：
  - 2.8T 总参数，104B 激活参数
  - 93 层，896 experts/层，16 selected/token，2 shared experts
  - MXFP4 weights / MXFP8 activations (QAT)
  - 1M token context window
  - 官方推荐 vLLM / SGLang / TokenSpeed 部署

### 关键引用

- 3.72GB VRAM 声明：airllm README "[2026/07] Kimi K3 (2.8T) support: the largest open-source model runs on a single card in 3.72GB of VRAM, measured end to end on one RTX 6000 Ada"
- 每层 expert 大小：airllm_kimi_k3.py docstring "expanded, a layer's experts are ~55GB but a token needs ~1GB of them"
- 磁盘需求：utils.py 注释 "1.5TB+ for a 2.8T-parameter model"
- Prefetching RAM：airllm_base.py 注释 "a frontier MoE checkpoint has ~17GB layers, and with prefetching two are in flight at once, which would lock up ~34GB of RAM"
- flash-attn 要求：airllm README "its model code mandates flash attention regardless of what you request"
- CUDA 12 约束：airllm README "a CUDA 12 build of torch, since no prebuilt flash-attn wheel exists for CUDA 13 yet"
- transformers 版本：airllm README "transformers 4.56.x, as its remote code does not load on 5.x"
