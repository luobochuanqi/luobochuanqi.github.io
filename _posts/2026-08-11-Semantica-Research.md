---
title: Semantica 项目研究
date: 2026-08-11 12:00 +0800
categories: [Blogs, Research]
tags: [semantica, ai-agent, knowledge-graph, context-graph, provenance, accountability]
---
# Semantica 项目研究

> 研究日期：2026-08-11　|　研究对象：<https://github.com/semantica-agi/semantica>
> 资料来源均为项目自身的一手来源（仓库 README/源码/文档站点/许可证/发布记录）。凡无法直接核实者均标注 `[INFERENCE]`。

---

## 一、项目简介（这是干嘛用的）

Semantica 是一个开源的「AI 问责与上下文层（Accountability and Context Layer）」基础设施，定位是「面向 AI Agent 的开源版 Palantir（The Open Source Palantir for AI Agents）」。它不替代 LLM、向量库或 Agent 框架，而是**垫在这些组件之下**，把企业数据经「摄取 → 解析 → 归一化 → 切分 → 抽取 → 冲突检测 → 去重」构建成可查询的**上下文图（Context Graph）与知识图谱（KG）**，并在其上叠加**决策智能（Decision Intelligence）、确定性推理、本体管理（Ontology）、W3C PROV-O 溯源（Provenance）**，让每一个 AI 决策都可追溯、可审计、可问责。其核心承诺是：图构建、推理和溯源层**完全确定性、不依赖 LLM**。

- 仓库自述（README，`README.md` 头部）："Graph-Native Infrastructure for Context and Accountable AI Systems"。
- 官方文档站点（<https://docs.getsemantica.ai/>）同义表述："The Accountability and Context Layer for AI: Context Graphs · Decision Intelligence · Full Provenance"。

## 二、解决什么问题、为谁而做

**问题**：大多数 AI Agent「行动却无痕」——只存向量，不存意义；上下文无法解释，决策无法审计。在金融（如信贷审批）、医疗、法律、政府、国防等受监管场景，一个 AI 决策必须能在数月后回答监管者的「为什么」，向量库 + RAG / 纯 LLM 记忆都做不到。官方将其概括为五个结构性盲点：无记忆结构、无决策记录、无溯源、推理不可解释、无冲突检测（见 <https://docs.getsemantica.ai/> 的 "The Problem Every Production AI Team Hits"）。

**受众**（来自 `README.md` "Who it's for"）：
- 构建做重大决策 Agent 的 **AI/ML 平台团队**；
- 在 **Databricks / Snowflake** 上、想把湖仓中原有表直接转成有血缘的可治理知识图谱（无需先导出到第三方 SaaS）的数据平台团队；
- **合规/风险/审计团队**，需要以监管方可接受的形式回答「AI 为什么这么做」；
- 金融、医疗、法律、政府、国防等**受监管企业**；
- 需要 KG/推理/溯源栈**自托管、可替换、不锁定厂商**的平台与基础设施工程师；
- 在多源脏数据上构建 KG 的数据与知识工程师。

## 三、工作原理与技术架构

### 3.1 端到端流水线

`ARCHITECTURE.md` 给出了完整数据流（附 Mermaid 图）：

```
Sources → Ingest → Parse → Normalize → Split → Extract → Conflict Detection → Deduplication
   → Knowledge Graph → [ Ontology · Reasoning · Provenance · Decisions ] → Enriched KG
   → Vector Store + Polyglot Graph Store (RDF & LPG) → Export / Visualize / REST · MCP · CLI
```

决策智能生命周期（`ARCHITECTURE.md`）：Record（`record_decision()`）→ Link（`add_causal_relationship()`）→ Query（`find_similar_decisions()` / `trace_decision_chain()` / `analyze_decision_impact()`）→ Govern（`check_decision_rules()` 策略门禁）→ Audit（PROV-O/CSV/JSON 审计导出）。

### 3.2 模块划分（对应真实源码目录，见仓库根 `semantica/` 目录树）

- **`semantica/ingest`**：多源摄取——文件（PDF/DOCX/PPTX/HTML/CSV/JSON/Excel/XML）、Web、数据库（PostgreSQL/MySQL/SQLite/Oracle/SQL Server）、Databricks（Unity Catalog + Delta Lake）、Snowflake、Git、邮件、Kafka/Kinesis/Pulsar 流、MCP。`README.md` 的 `semantica.ingest` 一节有 `FileIngestor`/`WebIngestor`/`DBIngestor`/`DatabricksIngestor`/`SnowflakeIngestor` 等示例。
- **`semantica/parse`、`semantica/normalize`、`semantica/split`**：文档解析、文本/实体/日期/数字归一化、GraphRAG 原生的实体感知/关系感知/本体感知切分（`README.md` `semantica.split` 一节，支持 `entity_aware`/`relation_aware`/`graph_based`/`ontology_aware`/`hierarchical` 等方法）。
- **`semantica/semantic_extract`**：NER、关系抽取、事件检测、三元组抽取（`NamedEntityRecognizer`/`RelationExtractor`/`EventDetector`/`TripletExtractor`）。
- **`semantica/conflicts`**：冲突检测与解决（`ConflictDetector`/`ConflictResolver`/`SourceTracker`，策略如 `credibility_weighted`/`most_recent`/`voting`）。
- **`semantica/deduplication`**：实体分辨与去重（`DuplicateDetector`/`EntityMerger`，semantic + blocking）。
- **`semantica/kg`**：KG 构建与分析（`GraphBuilder`/`GraphAnalyzer`/`CentralityCalculator`/`CommunityDetector`/`PathFinder`/`LinkPredictor`/`BiTemporalFact`）。
- **`semantica/ontology`**：本体生成与校验（OWL 生成、SHACL 校验、SKOS 词汇表）。
- **`semantica/reasoning`**：确定性推理——前向链（forward chaining）、Rete 网络、Datalog、SPARQL，并带可解释路径（`ExplanationGenerator`）。
- **`semantica/provenance`**：W3C PROV-O 溯源，每条事实链接到来源（`ProvenanceManager`，含哈希链完整性校验 `verify_chain()`）。
- **`semantica/context`**：上下文图与决策智能（`ContextGraph`/`AgentContext`/`DecisionRecorder`/`CausalChainAnalyzer`/`PolicyEngine`）。
- **`semantica/vector_store`**：混合/过滤语义检索，后端 FAISS/Qdrant/Weaviate/Milvus/Pinecone/PgVector/SQLite/内存，RRF 融合。
- **`semantica/graph_store`、`semantica/triplet_store`**：多语言图存储——RDF（内嵌 Oxigraph、Blazegraph、Apache Jena、Eclipse RDF4J、Anzo）与 LPG（Neo4j、FalkorDB、Apache AGE、AWS Neptune）。
- **`semantica/export`**：导出 RDF/OWL/Parquet/Cypher/JSON-LD/GraphML/CSV 等。
- **`semantica/visualization` + `explorer/`（前端）**：交互式浏览器工作台（Knowledge Explorer）。
- **`semantica/mcp_server`、`semantica/cli.py`、`semantica/server`**：MCP Server（10+ 工具）、CLI（50+ 命令）、REST API（100+ 端点）。
- **`semantica/llms`、`semantica/embeddings`**：LLM 与嵌入（可选，非核心）。

### 3.3 语言 / 框架 / 依赖

- **语言**：Python（`pyproject.toml`，`requires-python = ">=3.8"`，classifier 标注 "Production/Stable"）；前端 Explorer 为 React/TypeScript；`explorer/` 目录为浏览器前端。
- **核心依赖**（`pyproject.toml` `dependencies`）：`numpy`、`pandas`、`scipy`、`scikit-learn`、`spacy`、`transformers`、`torch`、`sentence-transformers`、`rdflib`、`networkx`、`faiss-cpu`、`pydantic`、`click`、`rich`、`loguru`、`structlog` 等；REST 服务用 `fastapi` + `uvicorn`（extra `explorer`）。
- **可选集成**：Agno 多智能体框架（extra `agno`）、LiteLLM 多模型（OpenAI/Anthropic/Gemini/Mistral/DeepSeek 等）、各图/向量/数据库后端按 extra 安装。
- **入口命令**（`pyproject.toml` `[project.scripts]`）：`semantica`（CLI）、`semantica-server`、`semantica-worker`、`semantica-explorer`、`semantica-mcp`。

## 四、项目状态

- **许可证**：MIT（`LICENSE`，版权 © 2026 Hawksight AI）。
- **热度**（GitHub 页面，2026-08-11 读取）：约 **4409 stars、494 forks、58 issues**；主语言 Python。
- **维护活跃度**：非常活跃。最新正式版 **v0.6.0**（发布日期 **2026-07-21**，见 GitHub Releases/API），v0.5.1（2026-06-29）、v0.5.0（2026-05-11）；`CHANGELOG.md` 显示处于持续迭代中（含大量近期修复与来自多个贡献者的 PR）。README 中 `semantica doctor` 示例显示的版本号 "semantica 0.6.0" 与最新版一致。
- **发布方式**：GitHub Releases 附带 `semantica-0.6.0-py3-none-any.whl` 与源码包；同时发布到 PyPI（`pip install semantica`）。
- **生态**：官方文档站点 docs.getsemantica.ai、官网 getsemantica.ai、Discord、40+ 个 runnable Jupyter notebook（`cookbook/`）。

## 五、论文与官方资料

- **没有与之直接关联的 arXiv 论文**。`[INFERENCE 说明]` 我在 README、`ARCHITECTURE.md`、`pyproject.toml` 及浏览搜索结果中均未发现该项目自身的论文引用；搜索 arXiv 到的相关条目（如 2604.14220、2505.20422）是无关的他人论文。官方定位为**工程基础设施/开源库**，而非学术论文项目。
- **官方一手资料**：
  - 官网：<https://getsemantica.ai/>（企业版、定价、部署服务）
  - 官方文档：<https://docs.getsemantica.ai/>（含 Quickstart、核心概念、模块参考、FAQ，Mintlify 构建）
  - 仓库文档：`README.md`、`ARCHITECTURE.md`（架构 Mermaid 图）、`CHANGELOG.md`、`RELEASE_NOTES.md`、`CONTRIBUTING.md`
  - 可运行示例：仓库 `cookbook/`（21 个入门 + 高级 cookbook notebook）

## 六、局限与注意事项（作者/仓库自述）

1. **Rete 引擎条件匹配器刻意简化**：`README.md` `semantica.reasoning` 一节明确标注 "**Current limitation**"——`ReteEngine` 的 alpha-node 条件匹配器在该版本中是有意保持简单的，作者提示在接入生产合规门禁前务必用真实规则集校验 `match_patterns()` 输出，更精细的条件求值在路线图上。
2. **部分模块存在未完成/未接线状态**：`CHANGELOG.md`（Unreleased）明确列出若干待办——例如 `PipelineWithProvenance` 从未可用（`semantica/pipeline/pipeline_provenance.py` 导入不存在模块、`Pipeline` 无 `run()` 方法）；多个 wrapper 模块其底层类缺失（如 `context.context_manager`、`deduplication.deduplicator`、`normalize.normalizer` 不存在）；向量存储后端存在已知缺口（如 Weaviate 两侧均未接线、Milvus 无 metadata 列、`include_vectors` 尚未实现）。**这意味着 README 宣传的能力比实际完成度略高，采用前需逐模块验证。**
3. **生产部署建议**：`README.md` "Installation" 一节建议生产环境用 Docker/Kubernetes 而非本地 `pip install`，需配置持久化 LPG 图存储/ RDF 三元组库与托管向量后端，并设置 `SEMANTICA_SECRET_KEY`。
4. **安全提示**：`README.md` 强调不要在代码中硬编码凭据（token/password/private_key），应走环境变量或密钥管理。
5. **依赖较重**：`pyproject.toml` 核心依赖包含 `torch`、`transformers`、`spacy`、`opencv`、`librosa` 等，安装体积与资源占用较大；项目也提供按需 extra 以裁剪依赖。

---

*注：以上 "项目状态" 中 star/fork/issue 数字为 2026-08-11 读取时的快照，会随时间变化。*