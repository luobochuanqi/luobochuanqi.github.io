---
title: 用 Posting 把一堆 AI 接口收进终端
date: 2026-08-03 12:00 +0800
categories: [Blogs, Share]
tags: [posting, api, cli, terminal, curl, tui]
---

# 用 Posting 把一堆 AI 接口收进终端

## 先说痛点

订阅了几个 AI 服务，生图一个、视频一个、TTS 一个。每个本质上都是一条 curl 请求，带着长长一串 header 和 JSON body。

问题是这串命令太长了。每次要用，不是翻终端历史，就是从文档复制粘贴，改个 prompt 还得小心别碰坏引号。API key 经常直接写在命令里，散得到处都是。

我想要的，是个能把接口"存起来、随手调"的东西。要求不高：终端里能用、启动快、项目靠谱别跑路。

## 折腾了一圈

先试了 HTTPie 和 xh。语法确实比 curl 友好，但它们是"单次请求"的思路 —— 会话按 host 记，没有"命名集合"的概念。存几个接口当模板这事，它们不解决。

wuzz 是个 TUI，看着挺对路，翻了下仓库，最后 release 停在 2018 年，基本去世，不敢用。

restish 看起来专业，但它是 OpenAPI 驱动的 —— 得先有接口的 spec 才玩得转。我那堆 AI 接口大多没 spec，直接劝退。

Bruno 功能全，46K stars，但创建和编辑请求要在桌面 GUI 里做，CLI 只是拿来跑测试。纯终端党表示不合适。

最后落在 Posting 上。

## Posting 是什么

一个跑在终端里的 API 客户端，可以理解成"terminal 版的 Postman"。GitHub 上 darrenburns/posting，12K 出头 stars，Apache 2.0，维护挺勤快。

核心思路很朴素：**一个请求就是一个文件**。每个请求存成 `.posting.yaml`，method、URL、headers、body、auth 全在里面，一个目录就是一套集合。纯文本，能用 Git 管。

![从长 curl 到一键复用](assets/img/blog/posting-workflow.png)

配合环境变量，API key 单独放 `.env`，请求里写 `${API_KEY}` 引用，文件里就不用裸奔了。

## 装起来

```bash
uv tool install --python 3.13 posting
```

Python 跑的，不是 Rust/Go 原生编译，但 TUI 挺流畅，启动一两秒，日常用没什么感觉。

## 一天的工作流

```bash
mkdir ~/ai-api-endpoints
posting --collection ~/ai-api-endpoints
```

进去之后：

- `Ctrl+N` 新建请求，填 URL、Authorization header、JSON body
- `Ctrl+S` 存成 `image-gen.posting.yaml`，再建 `video-gen`、`tts` 各一个
- 以后每次 `posting --collection ~/ai-api-endpoints`，侧边栏点一下，`Ctrl+Enter` 发送

<!-- ![Posting 界面示意](assets/img/blog/posting-terminal.png) -->
<img width="968" alt="image" src="https://github.com/user-attachments/assets/78359ab0-5e0c-4c0b-a60b-dce06b11bbf5" />

原来那些长 curl 命令也不用重敲 —— 直接粘到 URL 栏，Posting 会自动解析成请求。

## 候选摆一块儿看

| 工具        | 类型    | Stars | 能存请求      | 终端原生        | 维护   |
| ----------- | ------- | ----- | ------------- | --------------- | ------ |
| **Posting** | TUI     | 12.2K | ✅ 集合       | ✅              | 活跃   |
| Bruno       | GUI+CLI | 46.1K | ✅ `.bru`     | ⚠️ 编辑靠 GUI   | 极活跃 |
| HTTPie      | CLI     | 38.4K | ❌ 仅会话     | ✅              | 放缓   |
| xh          | CLI     | 8.0K  | ❌ 仅会话     | ✅              | 活跃   |
| wuzz        | TUI     | 10.7K | ❌ 基础       | ✅              | 已停更 |
| Hoppscotch  | Web+CLI | 80K   | ✅            | ❌ CLI 只跑测试 | 极活跃 |
| restish     | CLI     | 1.3K  | ⚠️ 要 OpenAPI | ✅              | 活跃   |
| curl -K     | CLI     | —     | ⚠️ 手动文件   | ✅              | 永恒   |

## 兜底方案

实在不想装工具，curl 自带 `-K` 就能读配置文件：

```bash
# ai-image-gen.cfg
url = "https://api.example.com/v1/images/generate"
request = "POST"
header = "Authorization: Bearer sk-xxx"
data = '{"prompt": "a cat"}'
```

然后 `curl -K ai-image-gen.cfg`。零依赖，但没交互、没变量替换，适合当最后手段。

## 我的结论

我现在用 Posting 管着那几路 AI 接口，体验是"存一次、以后只点一下"。如果你也是一堆 curl 接口懒得每次手敲，值得试试。要上 CI 自动化测试就去 Bruno；纯终端党基本就是 Posting。
