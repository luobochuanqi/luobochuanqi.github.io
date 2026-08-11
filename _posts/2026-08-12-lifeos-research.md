---
title: LifeOS 项目研究
date: 2026-08-12 02:00 +0800
categories: [Blogs, Research]
tags: [lifeos, ai-harness, intent-engineering, ideal-state, personal-ai]
---

# LifeOS 项目研究

> 研究日期：2026-08-11　|　研究对象：<https://github.com/danielmiessler/LifeOS>
> 资料来源均为项目自身的一手来源（仓库 README/源码目录树/官方文档站点/官网/安装页/发布记录）。凡无法直接核实者均标注 `[INFERENCE]`。

---

## 一、项目简介（这是干嘛用的）

LifeOS 是一个通用的「AI 攀登式（hill-climbing）智能体框架（AI harness）」，官方一句话定位是：**"A General Hill-climbing AI harness that helps you move from Current State to Ideal State in both Life and Work."**（一个帮助你从「当前状态（Current State）」迈向「理想状态（Ideal State）」的通用爬山式 AI 框架，适用于生活与工作）——README 也自称 **"The AI-Powered Life Operating System"（AI 驱动的生命操作系统）**。

它不是另一个 Agent 框架或提示词库，而是**垫在既有 AI harness（如 Claude Code、Cursor、Codex）之上的一层"操作系统"**：捕获你是什么人、在意什么、想往哪去，然后让"了解你的 AI"帮你到达那里。官网（<https://ourlifeos.ai>）把它概括为一句口号「**Tell your AI what, not how**（告诉你的 AI「要什么」，而不是「怎么做」）」，并将其命名为一门学科：**Intent Engineering（意图工程）**——把提示词工程从"怎么做事（HOW）"的编排，提升到"精确表达要做的事（WHAT）"的层。整套系统围绕**一个核心概念**运转：「从当前状态向理想状态移动，追求 **Euphoric Surprise（欣悦惊喜）**」（README 注）。

- 仓库自述（`README.md` 头部）："A General Purpose AI Harness for doing anything you want to do in life and work with AI… The whole system works on one central concept: **moving from your Current State to your Ideal State** — in pursuit of Euphoric Surprise."
- 官网（<https://ourlifeos.ai>）meta 描述："LifeOS is the open-source AI harness that moves you from current state to ideal state… yours, local, sovereign."（开源、本地、主权属于你的 AI harness）
- 官网把项目定义为："It's an intent engineering platform: it captures what you're ultimately trying to achieve—your goals, your context, your definition of done—and conveys that intent to your AI on every task, then verifies the result against it."（意图工程平台：捕获最终目标、上下文与"完成"的定义，把意图传达给 AI，并对照它验证结果）

## 二、解决什么问题、为谁而做

**问题**：前沿模型已是「非凡的执行者」，但它们缺的是单次响应之外的一切——对你最终想要什么的持久了解、对"完成"的书面定义、对"没有证据就宣称完成"的机械约束，以及让工作所学跨越会话留存的能力。作者在 ISA 文档中用一句话点破：**AI 系统的头号问题不是执行，而是方向**——模型执行得极好，却很少收到"做成什么样才算 done"的清晰陈述，于是"在随机方向上自信地移动"（`ISA/ISASystem.md` The intent problem）。官网原文："Models are already extraordinary at executing. What they almost never get is clear direction on what to do."（模型执行已非凡，但几乎从不被告知该做什么）

**受众**（官网 <https://ourlifeos.ai> 首页用例列举）：寻找人生意义、成为真正的自己、写代码、创办公司、构建应用、追求人生目标——即**任何想用 AI 驱动生活与工作目标、且希望 AI"认识自己"的个人**。安装方式（见下）也决定了它面向能用编码 harness 的开发者/重度 AI 用户。

## 三、工作原理与技术架构

### 3.1 核心算法：一个循环

一切工作都是同一个循环：**把一件事从当前状态推向理想状态，方法是"边爬边定义的那座山"**。生命周期到任务级别完全同构：

- **TELOS**（生命尺度）：你的使命、目标、信念、挑战。LifeOS 装好后通过"访谈（Interview）"捕获，之后在每个任务上反推。是"生命尺度的理想状态陈述"（`ISA/ISASystem.md`、`SKILL.md`、官网 `/philosophy/telos`）。TELOS 目录在 `USER/TELOS/`。
- **ISA（Ideal State Artifact，理想状态工件）**：项目的中心原语，一份文档。把"done"写成**可证伪的测试性声明（ISC，Ideal State Criteria）**——每条声称都点名能推翻它的探针（falsifier），于是这份文档同时就是规范、测试套件、验收门与状态报告（`ISA/ISASystem.md`）。作者称"AI 的整个游戏就是理想状态的清晰表达（articulation of ideal state）"。
- **The Algorithm（爬山算法）**：把 ISA 写下来、打磨、追求、按它验证并回填学到的思考系统。核心设计是**"花费从工作中被发现，而非预先预测"**——系统里没有分类器、没有努力等级（E1–E5 已退役）、没有复杂度评判表；难度由工作的声称与其证据门自行暴露，简单工作秒级完成、大型工作自动拉入并行 agent 与跨厂商审计（`Algorithm/AlgorithmSystem.md`）。
- **验证法则**：**证据必须与声称的模态匹配**——"curl 返回 200"不能证明一个人类浏览器加载的页面。"should work"（应该没问题）是禁用词汇；一条声称要么凭正确模态的工具证据关闭，要么保持开启。
- **Euphoric Surprise（欣悦惊喜）**：一次运行的目标度量——"主人在对的时间、对的花费下，得到了他真正想要的输出"，三角目标：正确的输出、正确的时间、正确的成本（`AlgorithmSystem.md`）。

`AlgorithmSystem.md` 附 Mermaid 图可概括为：

```
Current state（有东西坏了/缺失）→ 把 done 写成可证伪声明（ISA）
→ 朝声明构建 → 用工具证据探针 → 通过=获得高度(关闭该声称) / 失败=问"声称错还是代码错"
→ 全部声称关闭 = Ideal state（done 是机械性质，不是观点）→ 新特性=新增不成立的声称，循环继续
```

### 3.2 模块划分（对应真实源码目录，见仓库 `LifeOS/` 目录树）

LifeOS 以**一个自包含 skill** 形式分发（`LifeOS/` 目录即整个发行物），其内部结构：

- **`LifeOS/`（skill 根）**：`SKILL.md`（编排器，v1.5.35）、`Workflows/`（Setup/Interview/Update/Uninstall）、`Tools/`（安装工具：`DetectEnv.ts`、`DeployCore.ts`、`ScaffoldUser.ts`、`InstallHooks.ts`、`Doctor.ts` 等）、`INSTALL.md`、`GETTING-STARTED.md`。
- **`LifeOS/install/`（发行负载）**：`LIFEOS/`（运行时）、`skills/`（52 个 skill）、`hooks/`（约 60+ 个 hook）、`agents/`（ClaudeResearcher/CodexResearcher/GeminiResearcher/PerplexityResearcher/Forge/Max）、`USER/`（个人模板树）、`commands/`、`install.sh`、`settings.*.json`、`CLAUDE.template.md`。
- **`LifeOS/install/LIFEOS/`**：`LIFEOS_SYSTEM_PROMPT.md`（宪法层）、`ALGORITHM/`（`LATEST`→`v8.17.3.md`）、`ATLAS/`（`Atlas.ts`/`Store.ts`/`collectors/*.ts`）、`HERMES/`（`Mount.ts`/`Health.ts`/`Policy.ts`/`RenderSoul.ts`/`plugin/guard.py`）、`PULSE/`、`RULES/`、`TOOLS/`（数十个确定性 CLI）、`USER_TEMPLATES/`、`DOCUMENTATION/`、`VERSION`。
- **`LifeOS/install/LIFEOS/PULSE/`（Life Dashboard）**：`pulse.ts`（守护进程，端口 31337）、`modules/*.ts`（atlas/bunker/conduit/doctor/hermes/hooks/ledger/memory/synapse/telos/work/wiki 等 30 个模块）、`Observability/`（Next.js 前端）、`MenuBar/`（macOS 菜单栏 app）、`VoiceServer/`、`Conduit/`、`adapters/`、`Schema/`、`Tools/`。
- **`LifeOS/install/LIFEOS/DOCUMENTATION/<子系统>/`**：每个子系统一份文档——`Algorithm`、`ISA`、`Arbol`、`Atlas`、`Ledger`、`Hermes`、`Pulse`、`Hooks`、`Skills`、`Memory`、`Agents`、`Conduit`、`Feed`、`Fabric`、`Delegation`、`Notifications`、`Observability`、`Security`、`Work`、`Config`、`Synapse`、`Freshness`、`LifeOs`、`Testing`、`Tools`、`Upgrades`、`Writing`、`Router`（已退役）等。

各核心子系统的官方定位（`ARCHITECTURE_SUMMARY.md` 的 Pipeline Router 表 + 各子系统文档）：

| 子系统             | 定位                                                                                   | 文档                                         |
| ------------------ | -------------------------------------------------------------------------------------- | -------------------------------------------- |
| **The Algorithm**  | 结果驱动的 ISA 执行——说清 done、爬山、凭工具证据关闭声称                               | `DOCUMENTATION/Algorithm/AlgorithmSystem.md` |
| **ISA 系统**       | 中心原语，把"done"写成可证伪声明；ISA skill 提供 6 个工作流                            | `DOCUMENTATION/ISA/ISASystem.md`             |
| **Cortex（记忆）** | 记忆系统，热层捕获/分层整理/检索                                                       | `DOCUMENTATION/Memory/MemorySystem.md`       |
| **Hooks**          | 确定性强制与上下文注入（Claude Code 事件上）                                           | `DOCUMENTATION/Hooks/HookSystem.md`          |
| **Pulse**          | Life Dashboard 服务器（:31337）——语音、看板、wiki、iMessage/Siri                       | `DOCUMENTATION/Pulse/PulseSystem.md`         |
| **Bunker**         | 通用应用 harness——每个应用共享安全/在线时长/测试/部署底座                              | `DOCUMENTATION/LifeosSystemArchitecture.md`  |
| **Atlas**          | 基于图的资产图（SQLite）——"你所拥有一切的当前状态"；`atlas` CLI                        | `DOCUMENTATION/Atlas/AtlasSystem.md`         |
| **Ledger**         | 变更追踪权威——版本化 Major.Feature.Patch、更新注册、完整性门                           | `DOCUMENTATION/Ledger/LedgerSystem.md`       |
| **Arbol**          | 云端执行层（Cloudflare Workers）——Action/Pipeline/Flow 三原语；"你睡觉时运行的 LifeOS" | `DOCUMENTATION/Arbol/ArbolSystem.md`         |
| **Synapse**        | 输入路由——捕获一切并分级/路由/永久保存                                                 | 官网 `/philosophy/synapse`                   |
| **Conduit / Feed** | 内部/外部"感官"                                                                        | `DOCUMENTATION/Conduit`、`Feed`              |
| **Hermes Sidecar** | 可选第二入口——以 agent 身份在终端对话，同一宪法/身份/skill                             | `DOCUMENTATION/Hermes/HermesSidecar.md`      |
| **Skill 系统**     | 52 个自激活、可组合的领域能力单元                                                      | `DOCUMENTATION/Skills/SkillSystem.md`        |

**「生活目录（life directories）」**：`LifeOS/install/USER/` 个人树以文件组织人生领域——`TELOS/`、`WORK/`、`FINANCES/`、`HEALTH/`、`GEAR.md`、`PROJECTS.md`、`CONTACTS.md`、`OPINIONS.md`、`ABOUTME.md`、`BASICINFO.md`、`SECURITY/`、`SHARED/`、`CUSTOMIZATIONS/` 等（`ATLAS` 的 collectors 也读 `USER/PROJECTS.md`、`USER/GEAR.md`）。

### 3.3 语言 / 框架 / 依赖

- **语言**：TypeScript + Bash（README FAQ 明确 "The code is TypeScript and Bash"）；运行时依赖 **bun**（`INSTALL.md` 能力门要求 `bun --version`，安装工具皆为 TypeScript 脚本）。
- **harness 无关性**：LifeOS 建立在通用原语（hooks、skills、上下文文件、agentic 路由）上，不绑定某家厂商；但作者在 **Claude Code** 上构建与运行，故 Claude Code 是"测试最充分"的路径（README FAQ）。
- **与 fabric 的关系**：README 明确区分——fabric 是"针对具体任务问 AI 什么的提示词（pattern）集合"，LifeOS 是"你的 DA 如何运作的基础设施"（记忆、技能、路由、上下文、自我改进），两者互补，许多用户把 fabric 模式集成进 LifeOS skill。

### 3.4 安装方式（AI 原生）

LifeOS **由 AI 自己安装**，因此安装就是一个提示词。把下面这句粘贴到你的编码 harness（Claude Code、Cursor、Codex、Gemini CLI 等）即可：

```
Read https://ourlifeos.ai/install and install LifeOS for me.
```

或在 macOS/Linux 终端用一行命令（Claude Code 专用）：

```bash
curl -fsSL https://ourlifeos.ai/install.sh | bash
```

安装流程（`INSTALL.md`）：能力门（须能读写文件+执行命令）→ 前置（bun、git）→ `DetectEnv.ts` 探测 OS/harness → `ScanConflicts.ts` 只读扫描冲突 → `DeployCore.ts`（默认 dry-run，加 `--apply` 才写入）→ `ScaffoldUser.ts`/`LinkUser.ts` 搭 USER 树 → 按 harness 接 hooks（Claude Code 用 `InstallHooks.ts`，其他 harness 写 AGENTS.md）→ 接线 `lifeos` 启动命令（`lifeos.ts` 以 `--append-system-prompt-file` 加载 `LIFEOS_SYSTEM_PROMPT.md` 宪法）→ 组件菜单（hooks/statusline/tooltips/spinner verbs/agents/Pulse/worksweep，按需选）→ `Doctor.ts` 能力体检 → Setup 工作流 → Interview 工作流（命名 DA、捕获身份与 TELOS、拉入用户资料、播种 Pulse）。

## 四、项目状态

- **许可证**：MIT（GitHub 页面 License: MIT License；README "MIT License - see LICENSE"）。
- **热度**（GitHub 页面，2026-08-11 读取）：约 **18118 stars、2375 forks、45 issues**；主语言 TypeScript。
- **作者**：Daniel Miessler（<https://danielmiessler.com>），也是开源项目 **fabric** 的作者（README 明确"Daniel builds and runs it on Claude Code"；版本历史注明由作者与 LifeOS 社区共同构建）。
- **维护活跃度**：非常活跃。最新正式版 **v7.28.3**（发布于 **2026-08-01**，见 GitHub Releases/API，标题 "LifeOS 7.28.3 — Cortex, Hermes, and hardened releases"）。此前有 v7.1.1（Install Awareness）、v7.0.0（The Bitter Pill Release）、v6.0.0（One Skill One Install，2026-07-02，首次以 LifeOS 命名，前身叫 PAI——Personal AI Infrastructure）、v5.0.0（Life Operating System，2026-04-30）、v2.0.0（2025-12-28）等。
- **当前版本线**（`ARCHITECTURE_SUMMARY.md` frontmatter）：LifeOS 7.28.3 | Algorithm v8.17.3 | System Prompt v3.6.1 | Cortex (Memory) v8.3.0。
- **发布方式**：GitHub Releases；社区 PR 会被移植进私有源树并署名，而非直接合并（README Credits）。
- **生态**：官方文档站点 docs.ourlifeos.ai（52 篇文档、31 个分类）、官网 ourlifeos.ai（含 10 分钟介绍视频）、Discord 社区、YouTube 走查（youtu.be/Le0DLrn7ta0）、GitHub Discussions。

## 五、论文与官方资料

- **没有与之直接关联的 arXiv 论文**。`[INFERENCE 说明]` 我在 README、`ARCHITECTURE_SUMMARY.md`、`AlgorithmSystem.md`、`ISASystem.md` 及官网/文档站均未发现该项目自身的论文引用；官方定位为**工程基础设施/开源项目**，而非学术论文项目。其背后的思想散见于作者博客（如 "The Real Internet of Things"、"Building a Personal AI Infrastructure"、"Intent Engineering"）。
- **官方一手资料**：
  - 官网：<https://ourlifeos.ai>（首页、`/philosophy/*` 组件卡片、`/install` 安装页、介绍视频）
  - 官方文档站：<https://docs.ourlifeos.ai>（52 篇文档，覆盖 ISA/Algorithm/Memory/Skills/Hooks/Agents/Security 等）
  - 仓库文档：`README.md`、`LifeOS/INSTALL.md`、`LifeOS/GETTING-STARTED.md`、`LifeOS/SKILL.md`、`LifeOS/install/LIFEOS/DOCUMENTATION/*`（`ARCHITECTURE_SUMMARY.md` 为自动生成的架构总览）
  - 可运行产物：仓库 `LifeOS/` 目录树本身（52 个 skill、约 60 个 hooks、30 个 Pulse 模块、数十个确定性 TOOLS）

## 六、局限与注意事项（作者/仓库自述）

1. **Claude Code 是"测试最充分"的路径，其他 harness 未完全接线**：README FAQ 直言 "Daniel builds and runs it on Claude Code, so that's the most-tested path today"；`INSTALL.md` 诚实表格显示——Cursor/Cline/Codex/Gemini 等只获得"每次会话经 AGENTS.md 加载上下文、按需运行工作流"，**always-on 行为（响应格式/记忆循环/上下文注入）尚未在他们上接线，属路线图上**；纯聊天助手（无文件/无命令）**无法安装**，安装止于能力门。
2. **安装前务必备份、`USER/` 永不被触碰**：README "What if I break something"——升级前 `cp -r ~/.claude ~/.claude-backup-$(date +%Y%m%d)`；你在 `USER/` 的自定义**绝不会**被安装器或升级覆盖；安装器只更新身份与版本字段，hooks/statusline/自定义配置保留（settings 合并而非覆盖）。
3. **安装是"增量、绝不破坏"的**：`INSTALL.md`/`SKILL.md` 硬规则——只添加缺失文件、从不覆盖或删除你未创建的文件；每次变更前展示并征得许可；`settings.json` 编辑前先备份；**拒绝在 LifeOS 源码仓库内运行安装**（避免污染维护者系统）。安装工具默认 dry-run，省略 `--apply` 会"报告成功却复制了 0 个文件"。
4. **Arbol、Ledger 等是"私有组件"，不在公开发行物中**：`ArbolSystem.md` 明确 "Private infrastructure — not included in the public LifeOS release"——OSS 发行物不含 Arbol 实现（本地 CLI 树被 rsync 排除），文档仅为参考与蓝图；`LedgerSystem.md` 同样注明其工具在私有 `_`-前缀 skill 中，公开安装上命令不可用。**这意味着 README/架构图宣传的部分能力比公开发行物实际完成度高**，`[INFERENCE]` 采用前需逐个验证。
5. **能力降级是"诚实且响亮"的**：`GETTING-STARTED.md`/`INSTALL.md`——外部工具（codex 跨厂商审计、真实浏览器 Interceptor、Cloudflare/wrangler、ElevenLabs 语音、gh、ripgrep 等）若缺失，相关功能**降级运行并明确标注**（如 "same-vendor audit only"），绝不静默伪装；`Doctor.ts` 是能力状态的活来源；`decline <name>` 是受支持的合法关闭方式。唯一例外：**Work System 依赖 `gh`，无回退，缺 `gh` 则工作捕获直接失败而非降级**。
6. **Hermes sidecar 的安全控制未全部完成**：`HermesSidecar.md` "Honest limits"——读守卫与写沙箱是真实强制，但**类型化写 API（控制 3）与溯源污染（控制 4）尚未构建**，且在控制 4 落地前**网关不得启用**；Hermes 文档也承认 deny 规则"不是针对蓄意对抗进程的沙箱"。
7. **"算法"是一份结果契约而非过程**：`AlgorithmSystem.md`——系统刻意禁止"脚本化的认知"（无思考下限、无自评分），因为"为强模型编码的过程会把它封顶在能力之下并随模型进步而腐烂"；但同时披露经验法则：**仅靠散文的声明规则测量到的真实合规率仅 11–22%**，因此每条声称都带强制等级（HOOK/CHECK/SELF），系统"被审计、不被信任"。
8. **项目仍在快速演进**：`ArbolSystem.md` 注明 "This system is under active development. APIs, configuration formats, and features may change without notice."；版本号近期多次结构性重命名（PAI→LifeOS、Ascent→the Algorithm、mode/层级系统退役），采用时应锁定版本。

---

_注：以上 "项目状态" 中 star/fork/issue 数字与最新版本号（v7.28.3，2026-08-01）为 2026-08-11 读取时的快照，会随时间变化。_
