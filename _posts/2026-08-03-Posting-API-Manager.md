---
title: 用 Posting 把一堆 AI 接口收进终端
date: 2026-08-03 12:00 +0800
categories: [Blogs, Share]
tags: [posting, api, cli, terminal, curl, tui]
---

# 终端 HTTP API 请求管理工具调研报告

> 调研日期：2026-08-03
> 目标平台：Windows 11 / 跨平台
> 场景：管理多个 AI API 订阅端点（图像生成、视频生成、TTS），保存请求（含 API Key、Headers、JSON Body），终端快速复用

---

## 一、核心候选工具对比

### 1. Posting — TUI API 客户端（推荐首选）

| 项目     | 详情                                                                 |
| -------- | -------------------------------------------------------------------- |
| GitHub   | [darrenburns/posting](https://github.com/darrenburns/posting)        |
| Stars    | ~12,216                                                              |
| 语言     | Python（基于 [Textual](https://github.com/textualize/textual) 框架） |
| 许可证   | Apache 2.0                                                           |
| 最新版本 | [v2.10.0](https://pypi.org/project/posting/)（PyPI，活跃维护中）     |
| 平台     | macOS / Linux / **Windows**（通过 `uv` 或 `pipx` 安装）              |

**核心功能**：

- **集合（Collections）**：目录即集合，请求存为 `.posting.yaml` 文件，Git 友好，可直接版本控制 [Collections Guide](https://posting.sh/guide/collections/)
- **请求存储**：每个请求保存 method、URL、headers、body、params、auth 全部信息，YAML 格式 [Requests Guide](https://posting.sh/guide/requests/)
- **环境变量**：通过 `.env` 文件加载变量（`${API_KEY}` 语法），支持多环境切换 [Environments Guide](https://posting.sh/guide/environments/)
- **认证**：支持 Basic Auth、Bearer Token 等 [auth.py](https://github.com/darrenburns/posting/blob/main/src/posting/auth.py)
- **导入导出**：支持导入 cURL 命令、Postman 集合、OpenAPI 规范；导出为 cURL 或 YAML
- **脚本**：Pre-request / Post-response Python 脚本（v2.0+）[Scripting Guide](https://posting.sh/guide/scripting)
- **键盘驱动**：Vim 键位、Jump Mode 导航、命令面板、自定义键映射
- **SSH 可用**：纯 TUI，可通过 SSH 远程使用

**与用户场景的匹配度**：

- ✅ 保存多个 AI API 请求（图像生成、视频生成、TTS）为独立 YAML 文件
- ✅ 每个请求可配置 API Key（Header 或环境变量）
- ✅ JSON Body 完整支持
- ✅ 终端原生 TUI，键盘驱动，快速切换和发送请求
- ✅ 可通过 `--collection` 按项目组织不同 API 端点的请求
- ✅ 从 cURL 命令粘贴导入（用户的现有 curl 命令可一键导入）
- ⚠️ Python 运行，非 Rust/Go 原生编译，启动速度中等（但 TUI 交互流畅）

**维护状态**：✅ **活跃维护**（2024 年 10 月发布 v2.0，PyPI 最新 v2.10.0，持续更新）

<img width="968" alt="image" src="https://github.com/user-attachments/assets/78359ab0-5e0c-4c0b-a60b-dce06b11bbf5" />

---

### 2. Bruno — 离线优先 API 客户端 + CLI

| 项目     | 详情                                                                          |
| -------- | ----------------------------------------------------------------------------- |
| GitHub   | [usebruno/bruno](https://github.com/usebruno/bruno)                           |
| Stars    | ~46,097                                                                       |
| 语言     | JavaScript（Electron 桌面应用）+ Node.js CLI                                  |
| 许可证   | MIT                                                                           |
| 最新版本 | CLI [v4.0.0](https://www.npmjs.com/package/@usebruno/cli)（npm，周下载 223K） |
| 平台     | **Windows** / macOS / Linux（桌面应用 + CLI）                                 |

**核心功能**：

- **集合存储**：使用 [Bru 标记语言](https://docs.usebruno.com/v2/bru-lang/overview) 存储请求为 `.bru` 纯文本文件，Git 原生友好
- **CLI 运行器**：`bru run` 命令执行集合中所有请求，适合 CI/CD 和自动化测试 [Bruno CLI](https://docs.usebruno.com/bru-cli/overview)
- **环境变量**：支持多环境切换（`--env` 参数）
- **认证**：Basic、Bearer、OAuth 1.0/2.0、AWS Signature 等
- **请求体**：JSON、Form、Multipart、GraphQL 等完整支持
- **离线优先**：无云同步，数据完全本地，隐私友好

**与用户场景的匹配度**：

- ✅ 集合存储为纯文本文件，Git 版本控制友好
- ✅ CLI 可快速运行保存的请求（`bru run request.bru`）
- ✅ 请求包含完整 headers/auth/body 配置
- ⚠️ **主要交互界面是 GUI 桌面应用**，创建/编辑请求需要在桌面应用中完成
- ⚠️ CLI 主要用于**运行已有的集合**，不是交互式终端工具——用户需要先打开桌面应用编辑请求，再用 CLI 执行
- ⚠️ Electron 桌面应用内存占用较大

**维护状态**：✅ **极度活跃**（2025-2026 年持续大量更新，CLI v4.0.0，社区活跃）

---

### 3. HTTPie — 人性化 CLI HTTP 客户端

| 项目     | 详情                                                                                     |
| -------- | ---------------------------------------------------------------------------------------- |
| GitHub   | [httpie/cli](https://github.com/httpie/cli)                                              |
| Stars    | ~38,380（注：曾因仓库短暂私有化丢失约 54K stars）[详见](https://httpie.io/blog/stardust) |
| 语言     | Python                                                                                   |
| 许可证   | BSD 3-Clause                                                                             |
| 最新版本 | [v3.2.4](https://pypi.org/project/httpie/)（2024-11-01）                                 |
| 平台     | 全平台（pip/brew/choco/apt）                                                             |

**核心功能**：

- **直观语法**：`http POST api.example.com/image prompt="cat" Authorization:"Bearer $TOKEN"`
- **会话（Sessions）**：`--session` 持久化 headers/auth/cookies 到 JSON 文件，同一 host 的后续请求自动复用 [Sessions Docs](https://httpie.io/docs/cli/sessions)
- **JSON 原生支持**：自动格式化彩色输出
- **认证**：`-a` 支持 Basic/Bearer/Digest
- **离线模式**：`--offline` 打印请求不发送

**与用户场景的匹配度**：

- ✅ 终端原生 CLI，语法简洁
- ⚠️ **会话是按 host 维度的**，不是命名集合——无法为每个 API 端点保存独立的请求配置
- ⚠️ 没有请求集合管理概念，每次仍需手动输入 URL 和 body
- ❌ 适合"单次快速请求"而非"保存多种 API 请求模板并快速复用"

**维护状态**：⚠️ **维护中但节奏放缓**（最新版 v3.2.4 发布于 2024-11-01，此后无新版本）

---

### 4. xh — Rust 版 HTTPie（curl 替代品）

| 项目   | 详情                                        |
| ------ | ------------------------------------------- |
| GitHub | [ducaale/xh](https://github.com/ducaale/xh) |
| Stars  | ~7,994                                      |
| 语言   | **Rust**                                    |
| 许可证 | MIT                                         |
| 平台   | 全平台（cargo/brew/scoop/choco/apt）        |

**核心功能**：

- HTTPie 兼容语法，但 Rust 编译，启动更快
- `--session` 支持会话持久化（与 HTTPie 兼容的 JSON 格式）
- HTTP/2、HTTP/3 支持
- 内置 cURL 命令转换（`--curl`）

**与用户场景的匹配度**：

- ✅ 高性能 Rust 编译，启动极快
- ⚠️ **没有请求集合管理**——本质是 curl 的替代品，每次仍需手写命令
- ⚠️ 会话功能与 HTTPie 相同局限（per-host 而非命名集合）
- ❌ 如果用户需要的是"保存请求模板并快速复用"，xh 不解决核心问题

**维护状态**：✅ **活跃**（Rust 生态，持续更新，最新 crates.io 版本活跃）

---

### 5. wuzz — 交互式 TUI HTTP 检查器

| 项目   | 详情                                              |
| ------ | ------------------------------------------------- |
| GitHub | [asciimoo/wuzz](https://github.com/asciimoo/wuzz) |
| Stars  | ~10,711                                           |
| 语言   | Go                                                |
| 许可证 | AGPL-3.0                                          |
| 平台   | Linux / macOS / Windows（Go 编译）                |

**核心功能**：

- TUI 分屏界面：上方编辑请求（method/URL/headers/body），下方显示响应
- 支持保存/加载请求（`Ctrl+S` 保存，`Ctrl+F` 加载）
- 类似 cURL 的命令行参数

**与用户场景的匹配度**：

- ✅ TUI 终端交互
- ⚠️ 保存/加载请求功能存在但**非常基础**（无集合管理、无环境变量、无命名请求）
- ❌ **项目已停滞**——最后一次 release 是 v0.6.0（2018 年），GitHub 提交活跃度极低
- ❌ Go 语言编写但项目已不再维护，有安全风险

**维护状态**：❌ **已停滞**（最后 release 2018 年，不建议使用）

---

### 6. Hoppscotch — 开源 API 开发生态系统

| 项目     | 详情                                                                                             |
| -------- | ------------------------------------------------------------------------------------------------ |
| GitHub   | [hoppscotch/hoppscotch](https://github.com/hoppscotch/hoppscotch)                                |
| Stars    | ~79,959                                                                                          |
| 语言     | TypeScript                                                                                       |
| 许可证   | MIT                                                                                              |
| 最新版本 | CLI [@hoppscotch/cli v0.31.3](https://www.npmjs.com/package/@hoppscotch/cli)（npm，周下载 3.4K） |
| 平台     | Web / Desktop / CLI                                                                              |

**核心功能**：

- 集合管理、环境变量、Pre-request Scripts、认证等完整 API 客户端功能
- **CLI**：`hopp test` 用于在 CI/CD 中运行集合测试，生成 JUnit 报告 [Hoppscotch CLI Docs](https://docs.hoppscotch.io/documentation/clients/cli/overview)

**与用户场景的匹配度**：

- ❌ **CLI 仅用于运行测试集合**，不是交互式请求管理工具
- ❌ 主要交互界面是 Web/Desktop GUI，CLI 是 CI/CD 辅助工具
- ❌ 产品定位与用户"终端快速复用"需求不匹配

**维护状态**：✅ **极度活跃**（80K stars，大型开源项目，持续更新）

---

### 7. Restish — API 感知型 CLI

| 项目     | 详情                                                  |
| -------- | ----------------------------------------------------- |
| GitHub   | [rest-sh/restish](https://github.com/rest-sh/restish) |
| Stars    | ~1,348                                                |
| 语言     | Go                                                    |
| 许可证   | MIT                                                   |
| 最新版本 | [v2.3.0](https://github.com/rest-sh/restish/releases) |
| 平台     | 全平台（Go 编译，brew 安装）                          |

**核心功能**：

- 直接发起 HTTP 请求，自动格式化输出
- 连接 OpenAPI 规范后生成 API 感知命令
- 配置文件 `restish.json` 管理 API 端点和认证 [Auth Guide](https://rest.sh/docs/guides/authentication/)
- 响应过滤、分页、多种输出格式（JSON/Table/CSV）

**与用户场景的匹配度**：

- ✅ Go 编译，性能优异
- ⚠️ **强依赖 OpenAPI 规范**——最佳体验需要 API 提供 OpenAPI spec
- ⚠️ 用户场景是多个不同的 AI API 端点（图像、视频、TTS），大部分没有 OpenAPI spec
- ⚠️ 配置方式偏向"连接一个 API 服务"而非"管理多个独立端点"
- ⚠️ Star 数量较低，社区较小

**维护状态**：✅ **活跃**（v2.3.0 近期发布，持续开发中）

---

## 二、零依赖基线方案

### curl `-K` 配置文件 + `.netrc`

这是最"无聊"但完全可靠的方案，适合不想安装任何额外工具的用户。

**实现方式**：

1. 为每个 API 端点创建独立的 curl 配置文件：

```bash
# ai-image-gen.cfg
url = "https://api.example.com/v1/images/generate"
request = "POST"
header = "Authorization: Bearer sk-xxxxxxxxxxxx"
header = "Content-Type: application/json"
data = {"prompt": "a cat", "size": "1024x1024"}
```

2. 快速调用：

```bash
curl -K ai-image-gen.cfg
```

3. 认证信息可分离到 `.netrc`：

```
machine api.example.com
  login apikey
  password sk-xxxxxxxxxxxx
```

**优点**：

- 零依赖，curl 预装于所有系统
- 配置文件纯文本，Git 版本控制友好
- 完全可控，无隐藏行为

**缺点**：

- ❌ 无交互式 TUI，需要手动编辑配置文件
- ❌ 无集合管理，需手动组织多个配置文件
- ❌ 无环境变量替换
- ❌ 响应无格式化高亮（除非通过 `jq` 管道）
- ❌ 修改请求参数需要编辑文件，不够快速

---

## 三、综合对比表

| 工具           | 类型    | Stars | 语言   | 集合管理       | 环境变量    | 终端原生      | 维护状态    | 适合场景                            |
| -------------- | ------- | ----- | ------ | -------------- | ----------- | ------------- | ----------- | ----------------------------------- |
| **Posting**    | TUI     | 12.2K | Python | ✅ YAML 目录   | ✅ `.env`   | ✅ 纯 TUI     | ✅ 活跃     | **保存多个 API 请求，终端快速复用** |
| **Bruno**      | GUI+CLI | 46.1K | JS     | ✅ `.bru` 文件 | ✅ 多环境   | ⚠️ CLI运行    | ✅ 极度活跃 | 团队协作、CI/CD 测试                |
| **HTTPie**     | CLI     | 38.4K | Python | ❌ 仅会话      | ❌          | ✅ 纯 CLI     | ⚠️ 放缓     | 单次快速 HTTP 请求                  |
| **xh**         | CLI     | 8.0K  | Rust   | ❌ 仅会话      | ❌          | ✅ 纯 CLI     | ✅ 活跃     | 高性能 curl 替代                    |
| **wuzz**       | TUI     | 10.7K | Go     | ❌ 基础        | ❌          | ✅ 纯 TUI     | ❌ 停滞     | 已不推荐                            |
| **Hoppscotch** | Web+CLI | 80.0K | TS     | ✅ 完整        | ✅          | ❌ CLI 仅测试 | ✅ 极度活跃 | Web/GUI 用户                        |
| **Restish**    | CLI     | 1.3K  | Go     | ⚠️ 需 OpenAPI  | ✅ 配置文件 | ✅ 纯 CLI     | ✅ 活跃     | OpenAPI 驱动的 API                  |
| **curl -K**    | CLI     | -     | C      | ⚠️ 手动文件    | ❌          | ✅ 纯 CLI     | ✅ 永恒     | 零依赖基线                          |

---

## 四、最终推荐

### 🥇 首选：Posting

**推荐理由**：

1. **精准匹配需求**：用户的需求是"保存多个 AI API 端点（图像生成、视频生成、TTS）的 curl 请求，终端快速复用"。Posting 的集合（Collection）机制正是为此设计——每个请求保存为独立的 `.posting.yaml` 文件，放在一个目录中即是一个集合。

2. **终端原生 TUI**：完全在终端中运行，键盘驱动，支持 SSH 远程使用。Vim 键位、Jump Mode 导航、命令面板，效率极高。

3. **环境变量分离**：API Key 等敏感信息可放入 `.env` 文件，通过 `${API_KEY}` 语法在请求中引用。支持多环境（dev/prod）切换。

4. **cURL 导入**：用户现有的 curl 命令可直接粘贴到 URL 栏，自动解析为 Posting 请求。

5. **Git 友好**：请求文件是纯文本 YAML，可直接版本控制。团队协作时，修改 API 请求就像修改代码一样。

6. **维护活跃**：2024 年发布 v2.0（引入脚本、键映射等重大功能），PyPI 最新 v2.10.0，持续更新。

7. **性能可接受**：虽然基于 Python（非 Rust/Go），但 TUI 交互流畅，启动时间在 1-2 秒内，对日常使用影响很小。

**典型的用户工作流**：

```bash
# 安装
uv tool install --python 3.13 posting

# 创建一个集合目录
mkdir ~/ai-api-endpoints

# 启动 Posting 加载集合
posting --collection ~/ai-api-endpoints

# 在 TUI 中：
# Ctrl+N → 创建新请求（如图像生成 API）
#   填写 URL、Headers（Authorization: Bearer $OPENAI_KEY）、JSON Body
# Ctrl+S → 保存为 image-gen.posting.yaml
# 重复创建 video-gen、tts 等请求
# 以后每次只需：posting --collection ~/ai-api-endpoints
# 在侧边栏选择请求 → Ctrl+Enter 发送
```

### 🥈 备选：Bruno（如果团队协作/CI 是刚需）

如果用户需要将 API 请求集合纳入 CI/CD 自动化测试流程，Bruno 的 `bru run` CLI 和 `.bru` 纯文本格式更合适。但需注意：创建/编辑请求依赖 GUI 桌面应用，终端体验不如 Posting 纯粹。

### 🥉 备选：curl -K 配置文件（零依赖基线）

如果用户不想安装任何工具，curl 的 `-K` 配置文件方案完全可行，只是没有交互式体验，修改请求参数需要手动编辑文件。

---

## 五、不推荐使用

- **wuzz**：项目已停滞（2018 年最后 release），有安全风险
- **Hoppscotch CLI**：定位是 CI/CD 测试运行器，不是交互式请求管理工具
- **Restish**：强依赖 OpenAPI 规范，用户场景（多个独立 AI API）不匹配
- **xh / HTTPie**：没有请求集合管理，每次仍需手写命令，不解决"保存复用"的核心需求

---

> 💡 **一句话总结**：如果你想要一个类似 Postman 但完全在终端中运行的 API 请求管理器，用来保存和快速复用多个 AI 图像/视频/TTS API 端点，**Posting** 是目前最匹配的选择。它活跃维护（2025-2026），12K+ stars，Apache 2.0 许可，Git 友好的 YAML 存储，支持环境变量和 cURL 导入。
