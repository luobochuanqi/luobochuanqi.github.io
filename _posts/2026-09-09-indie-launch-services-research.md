---
title: 独立开发者 SaaS 从 $0 起步：全套云服务选型与 $45–70/月上线清单
date: 2026-09-09 12:00 +0800
categories: [Blogs, Research]
tags: [cloud-services, saas, indie-developer, free-tier, tech-stack]
---
# 独立开发者产品发布云服务调研

> 面向独立/单人开发者：调研"从想法到上线"所需的云服务（托管、数据库、邮件、认证、存储、支付、后台任务、边缘、可观测性等），逐一给出核心功能、免费额度、付费起步价与定价变更，并在文末给出资深开发视角的推荐技术栈与策略。
>
> - 数据截至 **2026-09-09**，全部取自官方一手来源（官方定价页/文档），每条来源以 markdown 链接标注在对应位置。
> - 原则：只记录官方页面实际展示的数字；页面未能读取的数字明确标注"未能从官方来源确认"；由页面信息外推的结论标注 `[INFERENCE]`。
> - "免费额度"指**永久免费层**（free tier）；"起步价"指**最低付费档月费或按量单价**。

---

## 总览

| 类别 | 覆盖服务 | 一句话结论 |
|---|---|---|
| 托管/部署/Serverless | Vercel、Netlify、Railway、Render、Fly.io、Cloudflare Pages/Workers、Deno Deploy、GitHub Pages | Vercel/Netlify 管前端，Cloudflare 免费额度最激进，Railway/Render 适合跑任意容器 |
| 数据库 | Neon、Supabase、PlanetScale、Turso、Upstash、Cloudflare D1、CockroachDB | Supabase/Neon 是独立开发默认选择；PlanetScale 已无免费层 |
| 邮件 | Resend、Postmark、SendGrid、Mailgun、Amazon SES、Loops、Buttondown、Kit | 事务邮件 Resend（3k/月免费）；newsletter Kit（1 万订阅免费） |
| 认证 | Clerk、Auth0、Supabase Auth、Better Auth、Firebase Auth、Kinde、Stack Auth、Lucia | 随 Supabase 白送；独立托管选 Clerk；Lucia 已弃用、Stack Auth 已消失 |
| 存储 | Supabase Storage、Cloudflare R2、AWS S3、Backblaze B2、Vercel Blob | R2/B2 零/低出站费是卖点；S3 免费层 2025 年大改 |
| 支付 | Stripe、Paddle、Lemon Squeezy、Polar、Gumroad、Recurly | 省心选 MoR（Paddle/Lemon Squeezy），便宜选 Stripe（自担税务） |
| 后台任务 | Inngest、Trigger.dev、QStash、Temporal Cloud | 轻量用 QStash/Trigger.dev；复杂工作流再上 Inngest/Temporal |
| 边缘/CDN/缓存 | Cloudflare（KV/DO/R2）、Vercel Edge Config、Upstash Redis | Cloudflare 免费层 + 零出站费几乎无可替代 |
| 可观测性 | Sentry、Better Stack、Axiom、Vercel Analytics、PostHog、Umami、Tinybird | Sentry 免费层够用；PostHog 一个平台包揽分析+flags |
| 胶水层/特性开关/ORM | Arcjet、ngrok、Drizzle、Prisma、Vercel Flags、Unleash、PostHog Flags | Drizzle 免费开源 ORM；PostHog Flags 1M/月免费 |
| AI | OpenAI、Anthropic、Replicate、Modal、Workers AI、AI SDK、Helicone、LiteLLM | 模型按 token 计费无月费；LiteLLM/AI SDK 开源免费网关 |

---

## 1. 托管 / 部署 / Serverless

| 服务 | 核心功能 | 免费额度 | 起步价 | 来源 |
|---|---|---|---|---|
| Vercel | 前端/全栈（Next.js 主场）部署：全球 CDN、Functions（Fluid compute）、预览部署、CI/CD | Hobby：1M 边缘请求/月、100GB FDT、1M Function 调用、Active CPU 4 小时/月、Blob 1GB；限 1 席位 | $20/月（Pro，含 $20 用量额度；Function 超量 $0.60/百万次） | [vercel.com/pricing](https://vercel.com/pricing) |
| Netlify | JAMstack 部署：Git 部署、无限预览、Functions、数据库、Blob、CDN | Free：300 积分/月（计量生产部署/计算/带宽），含自定义域名+SSL | $9/月（Personal，1000 积分；约 $0.13/GB 带宽） | [netlify.com/pricing](https://www.netlify.com/pricing) |
| Railway | 容器化 PaaS，任意语言按秒计费，内置对象存储与卷 | $0/月含 $1 用量额度（1 vCPU/0.5GB 单服务）；新用户另 $5 一次性额度 | $5/月（Hobby，含 $5 额度；CPU $20/vCPU-月、内存 $10/GB-月） | [railway.com/pricing](https://railway.com/pricing) |
| Render | PaaS：Web 服务、worker、静态站 + 托管 Postgres/Redis/Cron | Web Free（512MB/0.1CPU）$0/月；Postgres Free（256MB，**30 天期限**）；KV Free 25MB | Web Starter $7/月（512MB/0.5CPU）；Postgres Basic-256 $6/月 | [render.com/pricing](https://render.com/pricing) |
| Fly.io | Firecracker 微虚拟机，全球边缘运行容器 + 托管 Postgres，按秒计费 | 无长期免费层，仅试用：2 小时 VM 时长或 7 天、≤10 台机器 | 纯按量：shared-cpu-1x/256MB 约 $1.94/月（24/7 运行） | [fly.io 定价](https://fly.io/docs/about/pricing/)、[试用](https://fly.io/docs/about/free-trial/) |
| Cloudflare Pages + Workers | 边缘托管：Pages 静态站、Workers serverless，配套 KV/D1/R2/Durable Objects | Workers：100k 请求/天、10ms CPU/请求；Pages 免费；R2 10GB 免费 | 纯按量：Workers 付费 $0.30/百万请求 + $0.02/百万 CPU-ms | [cloudflare.com/plans](https://www.cloudflare.com/plans/) |
| Deno Deploy | Deno 官方 JS/TS 部署（V8 isolate，支持 Next/Fresh/Hono/SvelteKit）+ KV/Cron/Sandbox | Free：1M 请求/月、20GiB 出站、10 小时 Active CPU/月、KV 1GiB | $20/月（Pro，5M 请求后 $2/M） | [deno.com/deploy/pricing](https://deno.com/deploy/pricing) |
| GitHub Pages | 直接从 GitHub 仓库托管静态站点，支持自定义域名 | 完全免费（公开/私有仓库均可，随 GitHub Free 计划）；具体流量/存储限额未能从官方来源确认 | 本身无付费档 | [pages.github.com](https://pages.github.com/)、[docs.github.com/en/billing](https://docs.github.com/en/billing) |

**变更与注意**
- **Vercel**：Hobby **仅限个人非商业用途**且不能加购用量，商用必须 Pro；Pro 可设默认 $200 用量预算 + 硬限额（[来源](https://vercel.com/pricing)）。
- **Netlify**：定价已改为**积分（credit）计量制**（[来源](https://www.netlify.com/pricing)）。
- **Fly.io**：2026 年起卷快照开始收费（$0.08/GB/月，前 10GB 免费）；**删除应用不会删除 Managed Postgres**，可能产生意外账单（[来源](https://fly.io/docs/about/pricing/)）。
- **Render**：Postgres 免费实例仅 **30 天使用期限**、存储 1GB（[来源](https://render.com/pricing)）。

---

## 2. 数据库（Serverless / 托管）

| 服务 | 核心功能 | 免费额度 | 起步价 | 来源 |
|---|---|---|---|---|
| Neon | Serverless Postgres：按 CU-hour、scale-to-zero、Git 式分支、连接池 | Free：每项目 100 CU-hours/月、0.5GB 存储、5GB 出流量、100 个项目 | 按用量无月费：Launch 计算 $0.106/CU-hour、存储 $0.35/GB-月 | [neon.com/pricing](https://neon.com/pricing) |
| Supabase | 托管 Postgres + Auth + Storage + Edge Functions + Realtime 一体化后端 | Free：2 个活跃项目、每项目 500MB DB、1GB 文件、5GB 出流量、Auth 5 万 MAU | Pro $25/月（含 $10 计算额度≈1 Micro 实例）；Micro 计算 $10/月起 | [supabase.com/pricing](https://supabase.com/pricing) |
| PlanetScale | 托管 Vitess（MySQL 分支/分片）+ 托管 Postgres，按集群 SKU 计费 | **无免费层**（官方页面无任何免费档） | Postgres 单节点 PS-5 $5/月；Postgres HA $15/月起；Vitess HA $39/月起 | [planetscale.com/pricing](https://planetscale.com/pricing) |
| Turso | 边缘 SQLite（libSQL）：全球副本、数据库分支，按行数计费 | Free：100 个库、5GB 存储、5 亿行读/月、1000 万行写/月 | $5.99/月（Developer，9GB 存储、25 亿行读/月） | [turso.tech/pricing](https://turso.tech/pricing) |
| Upstash | Serverless Redis（按命令数）+ Kafka + QStash | Redis Free：256MB、50 万命令/月、10GB 带宽、10k 命令/秒 | 按量：命令 $0.20/10 万条 + 存储 $0.25/GB；最低固定档 $10/月 | [upstash.com/pricing/redis](https://upstash.com/pricing/redis) |
| Cloudflare D1 | 边缘 Serverless SQLite：按行读/写/存储，scale-to-zero | Workers Free 内含：500 万行读/天、10 万行写/天、5GB 存储 | 按量：行读超 250 亿/月 $0.001/百万行、行写超 5000 万/月 $1/百万行 | [CF D1 定价](https://developers.cloudflare.com/d1/platform/pricing/) |
| CockroachDB | 云原生分布式 SQL（Postgres 兼容）：Basic 档 serverless 按 RU 计费 | Basic $0/月起：5000 万 RU/月 + 10GiB 存储免费（另有 $400 试用额度） | Basic 超量按 RU 计费（超额单价未能从官方来源确认）；Standard preview 2vCPU $0.18/小时 | [cockroachlabs.com/pricing](https://www.cockroachlabs.com/pricing/) |

**变更与注意**
- **PlanetScale**：官方定价页**已无 Hobby 免费档**（此前免费档已取消，本次读取确认现状为无免费层）；集群价格不含超额 EBS/备份/出流量（[来源](https://planetscale.com/pricing)）。
- **Neon**：Free 档限额用尽会**挂起计算**直到下月，需升级恢复；可领 $20 额度试用付费（[来源](https://neon.com/pricing)）。
- **Supabase**：计费为 org 订阅 + 每项目独立计算（Pro org 2 个 Micro = $35/月）；**Free 项目 1 周不活跃自动暂停**（[来源](https://supabase.com/pricing)）。
- **Turso**：2025-03-19 后新订阅默认开启超额计费；行数是计算代理，schema 设计直接影响账单（[来源](https://turso.tech/pricing)）。
- **Cloudflare D1**：D1 不收出流量/额外计算费，但需搭配 Workers 使用（[来源](https://developers.cloudflare.com/d1/platform/pricing/)）。

---

## 3. 邮件（事务 + Newsletter）

| 服务 | 核心功能 | 免费额度 | 起步价 | 来源 |
|---|---|---|---|---|
| Resend | 开发者事务邮件 API（REST/SMTP/SDK/React Email） | 3000 封/月（另限 100 封/天）、3 个域名 | $20/月（Pro，5 万封/月，超量 $0.90/千封） | [resend.com/pricing](https://resend.com/pricing) |
| Postmark | 高送达率事务邮件 API，交易/批量流分离 | Developer 永久免费：100 封/月，不可超量 | $15/月（Basic，1 万封/月） | [postmarkapp.com/pricing](https://postmarkapp.com/pricing) |
| SendGrid | Twilio 旗下邮件 API：事务 + 营销 campaign | 60 天免费试用、100 封/天（**非永久免费层**） | $19.95/月起（Essentials，随发送量/功能浮动） | [twilio.com 邮件定价](https://www.twilio.com/en-us/products/email-api/pricing) |
| Mailgun | API 事务邮件：REST/SMTP + tracking + inbound 路由 | 永久免费：100 封/天、1 个域名 | $15/月（Basic，1 万封/月） | [mailgun.com/pricing](https://www.mailgun.com/pricing/) |
| Amazon SES | AWS 按量事务邮件，单价同类最低之一 | 无永久免费层；新 AWS 客户最高 $200 免费信用（12 个月内用完） | 按量：$0.10/千封（a la carte，0–10M 档）；Essentials 计划 $0.16/千封 | [aws.amazon.com/ses/pricing](https://aws.amazon.com/ses/pricing/) |
| Loops | Vercel 系 SaaS 营销邮件平台，按联系人数计费 | 1000 订阅 + 滚动 30 天 4000 次发送（含事务邮件） | $49/月（1001–5000 联系人，发送量不限） | [loops.so/pricing](https://loops.so/pricing) |
| Buttondown | 独立运营 newsletter：富文本/markdown、自定义域名、托管存档 | 前 100 个订阅者完全免费 | 未能从官方来源确认（付费档由 JS 滑块动态计算）；add-on $9/29/79 每月 | [buttondown.com/pricing](https://buttondown.com/pricing) |
| Kit (ConvertKit) | 创作者 newsletter + CRM：落地页、序列、分群、数字产品销售 | 最多 1 万订阅者免费（无限广播/落地页） | $33/月（Creator，1000 人起档） | [kit.com/pricing](https://kit.com/pricing) |

**变更与注意**
- **SendGrid**：定价页已迁至 twilio.com（原 sendgrid.com 定价 URL 现为合并重定向说明页）（[来源](https://www.twilio.com/en-us/products/email-api/pricing)）。
- **Amazon SES**：定价结构 2025-06-01 后变更——无计量活动的新账号自 2026-07-21 起默认进 Essentials 计划（单价高于 a la carte），可随时切回（[来源](https://aws.amazon.com/ses/pricing/)）。
- **Resend**：免费档有**每日 100 封限速**（月 3000 封顶）（[来源](https://resend.com/pricing)）。
- **Kit**：1 万订阅免费 + 无限广播，是独立开发者做 newsletter 最宽的免费层（[来源](https://kit.com/pricing)）。

---

## 4. 认证 / 用户管理

| 服务 | 核心功能 | 免费额度 | 起步价 | 来源 |
|---|---|---|---|---|
| Clerk | 托管认证 + 用户管理：预构建 UI、社交登录、MFA、passkey、B2B 多租户（按 MRU 计费） | Hobby：每应用 5 万 MRU、3 席位；不含 MFA/passkey/SMS | $25/月（Pro，年付 $20；5 万 MRU + 1 企业连接，超额 $0.02/MRU） | [clerk.com/pricing](https://clerk.com/pricing) |
| Auth0 | Okta 旗下企业级认证：SSO（SAML/SCIM）、B2C/B2B | Free：2.5 万 MAU、1 自定义域名、5 组织，B2C/B2B 免费层一致 | $35/月（B2C Essentials，500 MAU 起）；B2B Essentials $150/月起 | [auth0.com/pricing](https://auth0.com/pricing) |
| Supabase Auth | Supabase 内置认证（GoTrue）：邮箱/OAuth/魔法链接/匿名/基础 MFA | Free：无限注册用户、5 万 MAU 认证额度、基础 MFA | $25/月（Pro，10 万 MAU，超 $0.00325/MAU） | [supabase.com/pricing](https://supabase.com/pricing) |
| Better Auth | 开源 TypeScript 认证框架（20+ 框架，50+ 插件：2FA/passkey/SAML/SCIM） | 开源免费（MIT）+ 自托管 | 无（自托管）；官方托管（dash.better-auth.com）价格未能从官方首页确认 | [better-auth.com](https://www.better-auth.com)、[GitHub](https://github.com/better-auth/better-auth) |
| Firebase Auth | Google 托管认证：邮箱/电话/社交/匿名/MFA，深度集成 Firebase | 未能从官方来源确认（定价页持续超时）；[INFERENCE] 文档摘要称 5 万 MAU/月，未确认 | 未能从官方来源确认 | [firebase.google.com/pricing](https://firebase.google.com/pricing) |
| Kinde | 一站式认证 + B2B 组织 + RBAC + feature flags + 内置 Stripe 订阅计费 | Free：10500 MAU、5 MAO、10 flags、1 个 SSO | $25/月（Pro，10500 MAU，超 $0.0175/MAU） | [kinde.com/pricing](https://www.kinde.com/pricing) |
| Stack Auth | 曾为面向独立开发者的轻量认证（YC 项目） | 未能从官方来源确认（**站点已关闭**） | 未能从官方来源确认 | [stackauth.com/pricing](https://stackauth.com/pricing)、[stack-auth.com](https://stack-auth.com) |
| Lucia | 开源 TypeScript 认证库（会话/OAuth/邮箱密码原语） | 开源免费（MIT）+ 自托管 | 无（自托管） | [lucia-auth.com](https://lucia-auth.com)、[GitHub](https://github.com/lucia-auth/lucia) |

**变更与注意（本类别变动最大）**
- **Lucia：已弃用。** 官方 README 与官网均声明 2025 年 3 月 deprecated，提供单文件 `auth_session.ts` 替代；GitHub 最近提交（2026-08-08）仅维护性提交，无功能开发。**新建项目不建议采用**（[来源](https://lucia-auth.com)）。
- **Stack Auth：已消失。** 官方域名 404/403，旧域名现重定向到无关产品 Hexclave，未找到官方关闭公告。不再考虑（[来源](https://stackauth.com/pricing)）。
- **Better Auth**：官方首页公告 "Better Auth is joining Vercel"，有并入 Vercel 的动向；仓库 29.8k+ stars、938+ 贡献者，维护活跃（[来源](https://www.better-auth.com)）。
- **Clerk**：按 **MRU**（月度留存用户）而非 MAU 计费，超额有 1 个月宽限期；MFA/passkey/去品牌均需 Pro（[来源](https://clerk.com/pricing)）。
- **Supabase Auth**：免费层注册数不限、仅 MAU 计 5 万；Free 项目 1 周不活跃暂停（[来源](https://supabase.com/pricing)）。

---

## 5. 文件 / 对象存储

| 服务 | 核心功能 | 免费额度 | 起步价 | 来源 |
|---|---|---|---|---|
| Supabase Storage | Supabase 文件/对象存储：bucket 上传下载、图片转换、CDN | 1GB 文件 + 5GB egress；单文件 50MB 上限 | $25/月（Pro，100GB 存储，超 $0.0213/GB） | [supabase.com/pricing](https://supabase.com/pricing) |
| Cloudflare R2 | S3 兼容对象存储，与 Workers/CDN 深度集成 | 10GB 存储 + 100 万 Class A 操作；**egress 完全免费** | 按量：$0.015/GB-月（Standard）、Class A $4.50/百万 | [CF R2 定价](https://developers.cloudflare.com/r2/pricing/) |
| AWS S3 | 通用对象存储：多存储类、11 个 9 持久性 | 2025-07-15 起新账户：最高 $200 免费信用、Free plan 6 个月（旧口径 5GB/月 + 2 万 GET） | 按量无最低消费；S3 Standard 具体 $/GB 单价未能从官方来源确认（定价表 JS 渲染） | [aws.amazon.com/s3/pricing](https://aws.amazon.com/s3/pricing/)、[free](https://aws.amazon.com/free/) |
| Backblaze B2 | S3 兼容低成本 always-hot 对象存储 | 前 10GB 永久免费 + 每月 3 倍平均存储量的免费 egress | 按量：$6.95/TB/30 天（约 $0.0067/GB-月）；超额 egress $0.01/GB | [backblaze.com 存储定价](https://www.backblaze.com/cloud-storage/pricing) |
| Vercel Blob | Vercel 内置轻量对象存储：静态资源/用户上传，随项目部署 | Hobby：1GB 存储 + 1 万读操作 + 2 千写操作 + 10GB 传输 | Pro $20/月内含；Blob 存储 $0.023/GB、读 $0.40/百万 | [vercel.com/pricing](https://vercel.com/pricing) |

**变更与注意**
- **AWS S3 免费层 2025-07-15 重大变更**：固定免费用量 → **$200 信用金 + 6 个月期限**（注册即得 $100 + 使用服务再赚 $100，12 个月内用完）；IA/Glacier 类有 30–180 天最短存储期与取回费（[来源](https://aws.amazon.com/s3/pricing/)、[来源](https://aws.amazon.com/free/)）。
- **R2**：核心卖点 **egress 零费用**（含经 Workers/S3 API/r2.dev 出站）；免费层仅 Standard 类（[来源](https://developers.cloudflare.com/r2/pricing/)）。
- **B2**：与 Cloudflare/Fastly 等 CDN 伙伴的 egress 近乎免费，存储单价比 S3 低一个量级（[来源](https://www.backblaze.com/cloud-storage/pricing)）。
- **Vercel Blob**：不单独售卖，绑定 Vercel 套餐；Hobby 不可加购（[来源](https://vercel.com/pricing)）。

---

## 6. 支付 / 账单

| 服务 | 核心功能 | 免费额度 | 起步价（费用结构） | 来源 |
|---|---|---|---|---|
| Stripe | 支付处理器（PSP）：在线收款、订阅、100+ 支付方式；**商户自担税务合规** | 无月费（$0/月，纯按量） | 按量：结算卡 3.4% + $0.30/笔（CN 区域页面所读）；国际卡 +0.5% | [stripe.com 定价](https://stripe.com/en-cn/pricing) |
| Paddle | **Merchant-of-record**：收款 + 全球 VAT/销售税代缴 + 反欺诈 + 收入恢复 | 无月费（每笔抽成） | 按量：5% + $0.50/笔 Checkout 交易 | [paddle.com/pricing](https://www.paddle.com/pricing/) |
| Lemon Squeezy | MoR 数字产品/软件销售：托管结账、订阅、许可证、数字下载 | $0/月全部电商功能免费 | 按量：5% + $0.50/笔交易 | [lemonsqueezy.com/pricing](https://www.lemonsqueezy.com/pricing) |
| Polar | 开发者优先订阅/支付平台，含 MoR 选项（代缴 VAT/处理拒付） | Starter 免费（$0/月）：5% + $0.50/笔 | Pro $20/月（3.8% + 40¢/笔） | [polar.sh 定价](https://polar.sh/resources/pricing) |
| Gumroad | 数字商品/课程/模板销售：托管店铺、数字下载、订阅 | 无月费（仅按交易抽成） | 按量：10% + $0.50/笔（站内销售）*[来自官方页面搜索索引摘要，页面直接读取失败]* | [gumroad.com/pricing](https://gumroad.com/pricing)、[费用说明](https://gumroad.com/help/article/66-gumroads-fees) |
| Recurly | 企业级订阅计费/账单：生命周期、dunning、多网关、RevRec（非 MoR） | 90 天免费试用（Starter） | $249/月 + 0.9% 账单量（Starter，前 $40K 账单量免抽成） | [recurly.com/pricing](https://recurly.com/pricing/) |

**变更与注意**
- **Polar**：2026-05-27 定价调整——此后新建组织统一 5% + 50¢ 起（早期成员旧费率 4% + 40¢ 永久保留，升级付费档后失效）；出款费透传 Stripe（[来源](https://polar.sh/resources/pricing)）。
- **Stripe**：定价页按访问者地区显示不同费率，上表数字为 **CN 区域页面**所读值；非 MoR，销售税/VAT 责任在商户（[来源](https://stripe.com/en-cn/pricing)）。
- **MoR vs PSP**：Paddle/Lemon Squeezy/Polar 代缴全球 VAT/销售税（省心，抽成高）；Stripe 便宜但税务合规自理（[来源](https://www.paddle.com/pricing/)、[来源](https://www.lemonsqueezy.com/pricing)）。
- **Recurly**：偏企业，独立开发者起步 $249/月成本偏高（[来源](https://recurly.com/pricing/)）。
- **Gumroad**：官方定价页与帮助中心均无法直接读取（连接失败，read 与 MCP fetch 各重试 3 次），10% + $0.50 来自搜索引擎对官方页面的索引摘要（两处一致）；详情页未能一手确认（[来源](https://gumroad.com/pricing)）。

---

## 7. 后台任务 / 队列

| 服务 | 核心功能 | 免费额度 | 起步价 | 来源 |
|---|---|---|---|---|
| Inngest | Durable 后台任务/事件驱动工作流：函数跑在你自己的基础设施上，开源可自托管 | Hobby：5 万执行/月、5 并发、500k 事件摄入 | $99/月（Pro，100 万执行/月） | [inngest.com/pricing](https://www.inngest.com/pricing) |
| Trigger.dev | TypeScript 后台任务/AI 工作流：无超时、强容错，托管 worker 仅执行时计费 | Free：$0/月含 $5 用量额度、20 并发、无限任务 | $10/月（Hobby，含 $10 额度、50 并发） | [trigger.dev/pricing](https://trigger.dev/pricing) |
| QStash | Upstash 的 serverless 队列/webhook/cron：消息队列、延迟消息、定时、死信 | 1000 条消息/天、50GB 带宽、10 个 schedule | 按量：$1/10 万条消息；固定 1M 档 $180/月 | [upstash.com/pricing/qstash](https://upstash.com/pricing/qstash) |
| Temporal Cloud | Durable execution（持久化工作流）全托管：工作流即代码、自动重试恢复 | 无永久免费层；新账户 $1000 免费额度（90 天） | $100/月（Essentials，100 万 Actions/月） | [temporal.io/pricing](https://temporal.io/pricing) |

**注意**
- **Inngest**：开源可自托管；Pro 含 7 天 trace 保留，SAML/RBAC 需 Enterprise（[来源](https://www.inngest.com/pricing)）。
- **Trigger.dev**：开源可自托管；超免费额度后成本主要来自计算秒数 + 调用次数（[来源](https://trigger.dev/pricing)）。
- **Temporal**：套餐费取「最低月费 或 用量消耗的 5%」较大者；高可用副本 2× 计费（[来源](https://temporal.io/pricing)）。
- 独立开发者轻量场景（cron/重试/webhook）优先 QStash（Upstash 生态内）或 Trigger.dev（$10 档），复杂编排再上 Inngest/Temporal。

---

## 8. 边缘 / CDN / 缓存

| 服务 | 核心功能 | 免费额度 | 起步价 | 来源 |
|---|---|---|---|---|
| Cloudflare（KV/DO/R2/Queues） | 全球边缘平台：Workers、KV 键值、Durable Objects 有状态对象、Queues、R2，**无出口流量费** | Workers 100k 请求/天；KV 100k 读 + 1k 写/天；DO 10 万请求/天；Queues 1 万操作/天 | Workers Paid $5/月起（1000 万请求/月 + 超额 $0.30/百万） | [CF Workers 定价](https://developers.cloudflare.com/workers/platform/pricing/) |
| Vercel Edge Config | Vercel 边缘 KV 配置（定价页称 Global Config）：亚毫秒全球读配置，免重新部署 | Hobby：100K 读 + 100 写/月（仅限个人/非商业） | Pro $20/月起（含 $20 额度）；读超量 $3/100 万次 | [vercel.com/pricing](https://vercel.com/pricing) |
| Upstash Redis | Serverless Redis：HTTP/REST 访问、全球多区域复制 | Free：256MB、50 万命令/月、10GB 带宽 | 按量：命令 $0.20/10 万、存储 $0.25/GB；最低固定 $10/月 | [upstash.com/pricing/redis](https://upstash.com/pricing/redis) |

**注意**
- **Cloudflare**：免费额度按**天**重置（00:00 UTC），适合轻量原型；2024-03 起迁移至 Standard 用量模型；KV 付费超额读写 $0.50/百万（[来源](https://developers.cloudflare.com/workers/platform/pricing/)）。
- **Vercel Edge Config**：Hobby 层无法购买额外用量（封顶不可加购），超量需升 Pro（[来源](https://vercel.com/pricing)）。
- **Upstash Redis**：旧 Pro 固定吞吐套餐（$280/$680/月）已弃用，被 PAYG + Fixed + Prod Pack 取代；SLA/HA/SOC2/静态加密为 Prod Pack 附加项（[来源](https://upstash.com/pricing/redis)）。

---

## 9. 可观测性 / 监控 / 分析

| 服务 | 核心功能 | 免费额度 | 起步价 | 来源 |
|---|---|---|---|---|
| Sentry | 错误追踪 + APM：错误监控、tracing、会话回放、日志、profiling | Developer 永久免费：1 用户、5000 errors/月、5M spans/月、50 会话回放、30 天回看 | $26/月（Team 最低档，50K errors/月） | [sentry.io/pricing](https://sentry.io/pricing/) |
| Better Stack | 一体化可观测/运维：状态页、uptime、on-call + Logtail 日志 + traces | 个人免费：10 监控、10 万 exceptions/月、3GB 日志（保留 3 天） | 按量：日志摄入 $0.10/GB 起；最低固定 Nano $30/月 | [betterstack.com/pricing](https://betterstack.com/pricing/) |
| Axiom | 机器数据/日志平台：PB 级无 schema 摄入，APL 查询日志/traces/metrics | Personal 永久免费：25GB 存储、500GB/月加载、10 GB-hours 查询 | $25/月起（Axiom Cloud，含 100GB/1000GB 月加载） | [axiom.co 限额](https://axiom.co/docs/reference/limits)、[计费](https://axiom.co/docs/reference/usage-billing) |
| Vercel Analytics | 隐私友好网站分析 + Speed Insights 性能洞察，随 Vercel 部署开箱即用 | Hobby：Web Analytics 50K events/月、Speed Insights 10K events/月（仅非商业） | Pro $20/月起；Web Analytics 超量 $3/100K events | [vercel.com/pricing](https://vercel.com/pricing) |
| PostHog | 产品分析全家桶：事件分析、会话回放、特性开关、实验、错误追踪、日志（MIT 可自托管） | 每月永久免费：1M 分析事件、5K 会话回放、1M flags 请求、100K 错误、10GB 日志 | 纯按量：超 1M 事件后识别 $0.000198/条、匿名 $0.00005/条 | [posthog.com/pricing](https://posthog.com/pricing) |
| Umami | 开源（MIT）隐私优先轻量网站分析：流量/行为/漏斗，无 cookie | Cloud Hobby：100K events/月、1 网站、6 个月保留 | $20/月（Pro，1M events/月，超 $0.00003/条） | [umami.is/pricing](https://umami.is/pricing) |
| Tinybird | 实时 SQL 边缘数据 API：托管 ClickHouse，亚秒级查询 API 部署到边缘 | Free 永久免费（无需信用卡）：0.25 vCPU、1K 请求/天、10GB 存储 | $49/月（Developer，0.5 vCPU、25GB 存储） | [tinybird.co/pricing](https://www.tinybird.co/pricing) |

**注意**
- **Sentry**：免费层仅 1 用户且无 API/第三方集成；付费按事件量计费，需配 Spike Protection 防突发（[来源](https://sentry.io/pricing/)）。
- **PostHog**：免费额度每月刷新、用量到顶即停不会意外扣费，无席位费；97% 公司只用免费层（官方口径）（[来源](https://posthog.com/pricing)）。
- **Axiom**：定价主页读取超时，免费额度取自官方 docs 限额页、$25 起价取自 docs FAQ；超量单价未能确认（[来源](https://axiom.co/docs/reference/limits)）。
- **Umami**：超出免费/套餐额度**不中断采集**、按量扣费（[来源](https://umami.is/pricing)）。
- **Tinybird**：免费层 1K 请求/天对生产 API 明显不够（[来源](https://www.tinybird.co/pricing)）。

---

## 10. 胶水层 / 特性开关 / ORM

| 服务 | 核心功能 | 免费额度 | 起步价 | 来源 |
|---|---|---|---|---|
| Arcjet | API/应用安全防滥用：速率限制、Shield WAF、Bot 检测、邮箱校验、Prompt 注入扫描 | 无长期免费层，仅 15 天试用 | $25/月（Individual，按 app 计费）+ 请求 $5/百万次 | [arcjet.com/pricing](https://arcjet.com/pricing) |
| ngrok | 内网穿透/隧道：本地开发临时公网域名，支持 TLS/流量策略 | Free：3 端点、1 域名、1GB 出站、2 万 HTTP 请求/月 + $5 一次性额度 | $10/月（Hobbyist，年付 $8；含 $10 额度） | [ngrok.com/pricing](https://ngrok.com/pricing) |
| Drizzle ORM | 轻量类型安全 TS ORM：Schema、迁移、关系查询、RLS，支持 PG/MySQL/SQLite | 开源免费 + 自托管（35k+ stars，PlanetScale 团队维护） | 无官方托管定价（成本在所选数据库） | [orm.drizzle.team](https://orm.drizzle.team) |
| Prisma | 类型安全 ORM（开源核心）+ 托管 Postgres + Compute 应用托管 | ORM 开源免费；托管 Free：Postgres 20 万操作/月、500MB 存储 | $10/月（Starter，1M 操作/月、10GB 存储） | [prisma.io/pricing](https://www.prisma.io/pricing) |
| Vercel Feature Flags | Vercel 平台内置特性开关：flag、定向、灰度、A/B 测试 | Hobby：10K 请求/月；Flags Explorer 150 次覆盖/月 | Pro $20/月起；Flags $0.03/千次请求 | [vercel.com/pricing](https://vercel.com/pricing) |
| Unleash | 开源特性开关平台：flag 生命周期、A/B、分段、双人审批（25+ SDK） | 开源免费 + 自托管（13.8k stars）；托管无永久免费层，14 天试用 | 托管 PAYG $75/席位/月（5300 万 API 请求/月） | [getunleash.io/pricing](https://www.getunleash.io/pricing) |
| PostHog Feature Flags | PostHog 内置特性开关与实验：灰度、kill switch、统计严谨 A/B | 每产品每月免费 1M flags 请求（MIT 可自托管） | 按量：超 1M 后 $0.0001/次起，无基础月费 | [posthog.com/pricing](https://posthog.com/pricing) |

**注意**
- **Drizzle vs Prisma**：两者 ORM 核心均开源免费；差异在生态与数据库绑定——Drizzle 更轻、Prisma 提供托管 DB + Compute 一体化（[来源](https://orm.drizzle.team)、[来源](https://www.prisma.io/pricing)）。
- **PostHog Flags**：与产品分析**同计费同免费额度**，无需另购 flags 服务（[来源](https://posthog.com/pricing)）。
- **Unleash**：按**席位**计费而非按 flag 评估/MAU；Cloud 含 99.9% SLA（[来源](https://www.getunleash.io/pricing)）。
- **ngrok**：用量为「固定额度池」模式，Free/Hobbyist 额度用完即停用（不超额扣费）（[来源](https://ngrok.com/pricing)）。

---

## 11. AI 相关

| 服务 | 核心功能 | 免费额度 | 起步价（费用结构） | 来源 |
|---|---|---|---|---|
| OpenAI API | LLM 模型 API（GPT 系列、图像、语音、Realtime），按 token 计费 | 无免费层（无月费） | 按 token 无月费；示例 GPT-5.6 Luna 输入 $0.20/1M、输出 $1.20/1M | [openai.com/api/pricing](https://openai.com/api/pricing/) |
| Anthropic (Claude) API | Claude 模型 API（Opus/Sonnet/Haiku），prompt caching、batch、代码执行 | API 无免费层、无月费 | 按 token 无月费；示例 Sonnet 5 输入 $2/MTok、输出 $10/MTok；Haiku 4.5 $1/$5 | [anthropic.com/pricing](https://www.anthropic.com/pricing) |
| Replicate | 托管模型推理平台：数千模型按量调用，Cog 部署私有模型 | 无免费层（按用量） | 按用量无月费：cpu-small $0.09/hr、A100 80GB $5.04/hr；flux-1.1-pro $0.04/张 | [replicate.com/pricing](https://replicate.com/pricing) |
| Modal | Serverless GPU/CPU 计算：跑推理与训练，按秒计费、无空闲费 | Starter $0/月：每月 $30 免费额度 + 3 席位 | 纯按量无月费：H100 SXM5 $0.001097/sec、T4 $0.000164/sec | [modal.com/pricing](https://modal.com/pricing) |
| Cloudflare Workers AI | 边缘无服务器模型推理（LLM/嵌入/图像/音频），无需管 GPU | 每日 10,000 Neurons 免费（Free/Paid Workers 均含） | 按用量无月费：超免费后 $0.011/1000 Neurons（需 Workers Paid） | [CF Workers AI 定价](https://developers.cloudflare.com/workers-ai/platform/pricing/) |
| Vercel AI SDK | 开源 TS AI 框架/SDK：统一接口调用多家 LLM，不绑定 Vercel 平台 | 开源免费（Apache 2.0）+ 自托管 | 无平台费（token 费向模型提供商支付） | [ai-sdk.dev](https://ai-sdk.dev)、[LICENSE](https://api.github.com/repos/vercel/ai/license) |
| Helicone | LLM 可观测/代理网关：监控请求/成本/延迟、缓存、限流、fallback | Hobby：10K 请求/月 + 1GB 存储 + 7 天保留 | Pro $79/月（无限席位、HQL、告警） | [helicone.ai/pricing](https://www.helicone.ai/pricing) |
| LiteLLM | 开源 LLM 网关/代理：统一 OpenAI 格式调 100+ 提供商，虚拟密钥/预算/路由 | 开源免费 + 自托管（"free to self-host, forever"） | 无公开月费（Enterprise 年度报价，不按 token） | [litellm.ai/pricing](https://www.litellm.ai/pricing)、[docs](https://docs.litellm.ai/) |

**注意**
- **OpenAI**：openai.com/api/pricing 实际重定向到 openai.com/business/pricing/#api；GPT-6 Astra 标注为促销价（[来源](https://openai.com/api/pricing/)）。
- **Anthropic**：官方定价页的 Free/Pro/Max 是 **Claude 应用订阅**，非 API 额度；API 单价取自 Latest models 区块（[来源](https://www.anthropic.com/pricing)）。
- **Workers AI**：定价已更新为更细粒度按模型计价（后台仍按 Neuron）；部分前沿模型需付费付款方式（[来源](https://developers.cloudflare.com/workers-ai/platform/pricing/)）。
- **AI SDK / LiteLLM**：均开源免费，成本只在你接的模型 token 费上；LiteLLM 另有 Enterprise（SSO/审计/SLA）年度报价（[来源](https://ai-sdk.dev)、[来源](https://www.litellm.ai/pricing)）。

---

## 资深开发者推荐栈（从想法到上线，最小运维、最低成本）

面向独立开发者跑一个典型 SaaS（前端 + 后端 API + 数据库 + 邮件 + 认证 + 支付 + 可观测），按"免费/最低成本起步，收入上来再升档"给一套连贯、有主见的方案：

**起步栈（0 成本验证 → $45–70/月商业化）**

- **前端 + 后端部署：Vercel（Next.js + API Routes）。** 理由是它把 CDN、边缘函数、预览部署、CI/CD、Blob、Analytics、Feature Flags 打包成一件事，独立开发者少管 N 个供应商；但 Hobby **仅限个人非商业用途**，正式商用第一天就升 Pro（$20/月）。[来源](https://vercel.com/pricing) 替代：预算敏感用 Cloudflare Pages + Workers（$5/月起、零出站费、免费额度最激进），或 Deno Deploy（$0 档 1M 请求）。[来源](https://www.cloudflare.com/plans/)
- **数据库 + 认证 + 存储 + 边缘函数：Supabase。** 一个服务同时解决 Postgres（免费 500MB）+ Auth（5 万 MAU 免费）+ Storage（1GB）+ Edge Functions，免费额度几乎覆盖产品从 0 到早期用户；Pro $25/月。[来源](https://supabase.com/pricing) 这是本栈最大的省钱点——单独买 DB + 认证 + 存储至少三个供应商。
- **ORM：Drizzle（开源免费，类型安全，支持 PG）。** 无平台费、迁移工具成熟，配 Supabase/Neon 均可。[来源](https://orm.drizzle.team)
- **事务邮件：Resend。** 每月 3000 封免费 + 每天 100 封上限够验证期；商用升 Pro $20/月（5 万封/月）。[来源](https://resend.com/pricing) newsletter/营销另配 **Kit（1 万订阅免费、无限广播）**，[来源](https://kit.com/pricing) 比 Loops（$49/月起）宽得多。
- **收款：Stripe（3.4% + $0.30/笔，无月费）** 作为主支付；若不想碰全球 VAT/销售税合规，换 **Lemon Squeezy 或 Paddle（MoR，5% + $0.50/笔，代缴税）**，用 1.5–2% 的差价买"税务/拒付/合规"三件事清零。[来源](https://stripe.com/en-cn/pricing)、[来源](https://www.lemonsqueezy.com/pricing)
- **可观测性：Sentry（免费 5000 errors/月、1 用户）+ PostHog（免费 1M 事件 + 1M flags 请求 + 5K 会话回放）。** PostHog 一个平台同时给出产品分析、特性开关、会话回放，独立开发者不需要再单独买 flags 服务（Unleash $75/席位/月起、Vercel Flags 超 Hobby 要 Pro）。[来源](https://sentry.io/pricing/)、[来源](https://posthog.com/pricing)

**升级路径（随收入）**
1. 收入稳定（MRR ~$500–1k+）：Supabase 升 Pro（$25/月，注意**多项目各 +$10/月计算费**），Resend 升 Pro，Sentry 升 Team（$26/月，5 万 errors）。
2. 用户 >1 万 MAU 或需要 MFA/passkey/B2B：认证从 Supabase Auth 迁到 **Clerk Pro**（$25/月、5 万 MRU、含 MFA），[来源](https://clerk.com/pricing) 或自托管 **Better Auth**（MIT 免费、20+ 框架、50+ 插件，成本只在你自己的服务器）。[来源](https://www.better-auth.com)
3. 需要全球低延迟/自托管/极致成本：整体迁 **Cloudflare** 全栈（Workers + D1/KV + R2），免费额度 + 零出站费，[来源](https://www.cloudflare.com/plans/) 此时 Vercel 可退役。
4. 数据库成为瓶颈（高并发/读多）：**Neon**（serverless Postgres、分支、scale-to-zero）[来源](https://neon.com/pricing) 或 **CockroachDB**（分布式、水平扩展）[来源](https://www.cockroachlabs.com/pricing/)。
5. 后台任务/异步：轻量用 **QStash**（$1/10 万条、免费 1000 条/天）或 **Trigger.dev**（$10/月档）；复杂编排上 **Inngest Pro**（$99/月）。[来源](https://upstash.com/pricing/qstash)、[来源](https://trigger.dev/pricing)

**免费层陷阱（务必知道）**
- **计费冲击**：Vercel/Netlify/Supabase 免费额度用尽后要么**挂起**（Neon/Supabase Free 闲置暂停）要么**按量扣费**——升付费前先在控制台设**消费上限/预算硬限额**（Vercel 默认 $200 可改、Supabase Pro 默认开 spend cap、PostHog 每产品可设上限、Upstash PAYG 可设预算）。[来源](https://vercel.com/pricing)、[来源](https://supabase.com/pricing)
- **商用条款**：Vercel Hobby 与 Edge Config Hobby **明确仅限非商业用途**，商用即违规；Supabase Free 项目 **1 周不活跃自动暂停**。[来源](https://vercel.com/pricing)、[来源](https://supabase.com/pricing)
- **出站/流量费**：传统对象存储（S3、Vercel Blob）egress 单独计费，**R2/B2 零/低 egress 是真正的成本差异点**；S3 免费层 2025 年已从"固定用量"改为"$200 信用 + 6 个月期限"。[来源](https://developers.cloudflare.com/r2/pricing/)、[来源](https://aws.amazon.com/s3/pricing/)
- **供应商锁定 vs 可移植**：Supabase=Postgres（可导）、Drizzle 跨库、Better Auth/Lucia（已弃用）自托管，都是"可离开"的选择；Vercel Fluid compute、Workers Durable Objects 这类平台专属运行时锁定最深——**数据库和认证优先选可迁移的，计算层随平台走**。[来源](https://orm.drizzle.team)、[来源](https://lucia-auth.com)
- **水平 vs 垂直**：SaaS 早期几乎永远是**垂直**（单机/单实例够跑），别提前上 CockroachDB/分片；Fly.io/Render 的 worker + 队列是水平化的第一档。[来源](https://render.com/pricing)、[来源](https://fly.io/docs/about/pricing/)
- **已消失/已弃用的坑**：**Lucia 已弃用**（2025-03）、**Stack Auth 已消失**（域名被无关产品占用）、**PlanetScale 无免费层**——选型时别用 2023 年的印象。[来源](https://lucia-auth.com)、[来源](https://stackauth.com/pricing)、[来源](https://planetscale.com/pricing)

> 底线：**Vercel Pro + Supabase + Resend + Stripe + Sentry + PostHog + Drizzle**，商用化落地成本约 **$45–70/月**（不含支付抽成），免费期 $0。先跑起来，收入进来再按上面的阶梯升档，每一步都有明确的迁移路径。

---

## 附：数据可信度说明

- 所有定价均于 2026-09-09 从官方一手来源读取（官方定价页/文档），来源链接见各表。
- 以下条目**未能从官方来源确认**具体数字（页面 JS 渲染、超时或站点关闭），已在上文明确标注，未做臆测：
  - AWS S3 Standard 具体 $/GB 单价与出站长阶梯（定价表 JS 渲染）
  - Buttondown 付费档基础月费（JS 滑块动态计算）
  - Gumroad 10% + $0.50（官方页面直接读取失败，取自搜索引擎对官方页面的索引摘要，两处一致）
  - Firebase Auth 免费额度与计费（官方定价页持续超时）
  - Stack Auth（站点已关闭）
  - Axiom 超量按量单价（定价主页读取超时，免费额度与 $25 起价取自官方 docs）
- 标注 `[INFERENCE]` 的条目为基于搜索摘要的外推，非官方页面一手确认。
