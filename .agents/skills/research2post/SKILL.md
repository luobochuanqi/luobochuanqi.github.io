---
name: research2post
description: 把 research 报告 md 转成博客 post，只加 Jekyll 抬头，正文不动。
argument-hint: "报告 md 文件的路径"
disable-model-invocation: true
---

# Research → Post

把一篇 research 报告 md 转成博客文章。**只加抬头，不动正文**：报告内容原样保留，你只做两件事——在文件开头套一个 Jekyll frontmatter 块，再按本站命名约定把文件落进 `_posts/`。

## 转换

1. **读报告**。用户给出路径；没给就问。
2. **定抬头四字段**。
   - `title`：取报告第一个 `# ` 标题。报告没有 H1，就向用户要一个标题。
   - `date`：今天的 `YYYY-MM-DD 12:00 +0800`，日期从系统取，不猜。
   - `categories`：`[Blogs, Research]`。
   - `tags`：从报告主题提炼 3–6 个小写英文关键词，kebab-case。
3. **套抬头**。把 frontmatter 块插到文件最前，正文一个字符都不动。报告头部若已有 `---` 块，先问用户怎么处理（它可能已经是 post），绝不叠两层抬头。
4. **落盘**。存为 `_posts/YYYY-MM-DD-Slug.md`。Slug 取源文件名去扩展名和日期前缀后的英文主体，保留原大小写，如 `airllm-kimi-k3.md` → `AirLLM-Kimi-K3`；文件名里没有英文，就用 `title` 里的英文词。源文件留在原地，不移动不删除。
5. **验证**。三条全过才算完成：
   - frontmatter 是合法 YAML，四字段齐全。
   - `---` 之后的正文与源文件逐字节一致，diff 只显示新增的抬头块。
   - 文件名里的日期与 `date` 字段一致。
6. **交差**。把新文件路径和四个字段值报给用户。`title`、`tags` 随时可改，改完重跑第 5 步。然后 commit & push。

## 本站约定

- research 类 post 一律 `categories: [Blogs, Research]`。
- `title` 是显示标题，可以比报告 H1 更抓人，H1 保留报告原标题。默认取 H1，用户想换就换。
- `tags` 小写英文 kebab-case，如 `[airllm, kimi-k3, llm, local-llm, gpu]`。
- 时区固定 `+0800`。
