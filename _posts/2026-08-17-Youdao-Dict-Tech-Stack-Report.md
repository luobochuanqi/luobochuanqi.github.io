---
title: 有道词典 (Youdao Dictionary) 技术栈逆向分析报告
date: 2026-08-17 12:00 +0800
categories: [Blogs, Research]
tags: [youdao-dict, reverse-engineering, cef, chromium, vue3, tech-stack]
---

# 有道词典 (Youdao Dictionary) 技术栈逆向分析报告

- **分析对象**: 有道词典 11.2.7.0（安装目录 `D:\Program Files\Dict`）
- **分析日期**: 2026-08-12
- **分析方法**: 静态二进制分析（PE 结构解析、导入表/段名扫描、特征字符串匹配、资源文件审阅）
- **结论摘要**: 原生 C++ 多进程架构 + CEF(Chromium 127) 渲染 HTML5 UI，混合使用 Vue 3 / zepto，辅以 Go DLL、VSTO .NET Office 插件与自研 C++ OCR 引擎，全线加壳保护。

---

## 1. 总体架构

```
┌─────────────────────────────────────────────────────────────┐
│  YoudaoDict.exe (主程序, x86, 原生 C++, 11.6MB)              │
│  ├── 自研 XML 皮肤引擎 (skins/*.xml DirectUI 布局)            │
│  ├── Microsoft Detours 挂钩 (.detourc/.detourd 段)           │
│  ├── 内嵌: SQLite / zlib / libpng / libjpeg / protobuf       │
│  └── CEF 集成 (libcef.dll = Chromium 127.0.6533.89)          │
│        └── resultui/ HTML5 UI (Vue 3 + zepto, JSB 桥接)      │
├── 辅助进程 (多进程)                                           │
│  ├── YoudaoDictHelper.exe  (CEF Helper, x86)                 │
│  ├── YoudaoEH.exe           (取词辅助, x64)                   │
│  ├── Monitor.exe            (监控)                           │
│  ├── YoudaoOcr.exe          (OCR 引擎, OpenCL 加速)           │
│  └── YoudaoProxyServer.exe  (代理服务, 调用 Go DLL)           │
├── 钩子/取词 DLL                                              │
│  ├── XDLL.dll / TextExtractorImpl32/64.dll                  │
│  └── YoudaoCookieAssist.exe (MSVC2008 遗留)                  │
├── Go 组件: ydk-plus.dll (Go 1.22.1)                          │
├── Office 插件: officeaddin/ (VSTO, .NET)                     │
└── 数据: localdicts/*.db (SQLite 离线词典)                     │
```

## 2. 核心主程序技术栈

### 2.1 语言与编译器
- **原生 Win32 C++（MSVC 编译）**，x86 32 位，PE32 格式
- 主程序 **不依赖 MFC / Qt / .NET**（二进制中无 mfc140u、Qt5/6、CLR 头）
- 例外: `YoudaoEDIT.exe` 显式链接 **mfc140u.dll（MFC 14.0 / VS2015+）**；`YoudaoCookieAssist.exe` 链接 **MSVCR90.dll（MSVC 2008 / VC9）**，属遗留组件

### 2.2 自研 UI 框架（皮肤引擎）
- 窗口、菜单、托盘、弹窗全部由 **XML 布局文件**驱动（`skins/*.xml`，约 60 个）
- 布局语法: `<DictFrame>` 根节点 + `<HBoxLayout>` / `<VBoxLayout>` 容器 + `SizePolicy(Spring/Fix)` 弹性布局 + 明暗双主题属性（`Background`/`DarkBackground`、`ItemTextColor`/`DarkItemTextColor`）
- 字体: 微软雅黑；支持图标包、字体包（`icons/`、`fonts/`）
- 判定: 有道自研 DirectUI 风格框架，非 Qt、非 duilib

### 2.3 钩子与取词机制
- PE 段含 **`.detourc` / `.detourd`** → 使用 **Microsoft Detours** 做 API 挂钩（划词取词核心）
- 配套钩子 DLL: `XDLL.dll`（注入）、`TextExtractorImpl32/64.dll`（文本提取，x64 版含 `.shared` 共享内存段做 IPC）
- `YoudaoEH.exe` / `TextExtractorImpl64.dll` 为 **x64** 构建 → 支持在 64 位程序中取词

### 2.4 内嵌第三方库
| 库 | 用途 |
|---|---|
| SQLite | 离线词典 `localdicts/*.db`（英/日/韩/法/德/西/葡/俄 8 语种） |
| zlib / libpng / libjpeg | 图像处理 |
| protobuf | 序列化/通信 |
| OpenCL | 渲染/计算加速 |
| CrashRpt | 崩溃上报 |

### 2.5 网络
- WINHTTP / WININET（HTTP 服务）、WS2_32（Socket）、CRYPT32（加密）

### 2.6 保护与加壳
- 多数 EXE **导入表被隐藏/混淆**（Import Directory RVA = 0），PE 段名非标准
- 安装器/卸载器（YoudaoDictInstaller.exe、uninst.exe）段表异常，**非 NSIS 非 Inno**，为自研安装框架 + 加壳

## 3. UI 渲染层：CEF (Chromium Embedded Framework)

### 3.1 CEF 运行时
- **libcef.dll 170.7MB，Chromium 127.0.6533.89**（约 2024 年年中内核）
- 配套完整 Chromium 运行时: `chrome_elf.dll`、`resources.pak`、`chrome_100/200_percent.pak`、`en-US.pak`、`icudtl.dat`、`snapshot_blob.bin`、`v8_context_snapshot.bin`
- 图形栈: ANGLE（`libEGL.dll` + `libGLESv2.dll` + `d3dcompiler_47.dll`，OpenGL ES → DirectX 转换）

### 3.2 前端技术
目录 `resultui/html/`，**新旧两代混合**:

| 代际 | 技术 | 证据 |
|---|---|---|
| 新版页面 | **Vue 3 + webpack** | `mainV2.js` 含 `withDirectives`（Vue 3 运行时助手）；`chunk-vendors.js` 为 webpack 产物（`webpackChunkdict_desk_10` 分包） |
| 旧版页面 | **zepto 1.1.6**（移动端风格 jQuery 精简版） | `zepto-1.1.6.js` |
| 页面模板 | HTML（20+ 个设置/生词本/VIP/翻译历史页面） | `setting*.html`、`wordbook*.html` 等 |

### 3.3 JS ↔ 原生桥
- `native.pc.jsb-1.4.9.js`：PC 端 JSB（JavaScript Bridge）协议，webpack 打包，2022-07-04 生成
- `native.mobile.jsb-1.4.9.js`：移动端变体
- `ydk-1.4.9.js`：有道 SDK 封装
- `inject_getword.js`：取词注入脚本

## 4. 辅助进程与组件

| 组件 | 架构 | 技术判定 |
|---|---|---|
| YoudaoDictHelper.exe (3.1MB) | x86 | CEF Helper 进程，原生 C++ |
| Monitor.exe (2.1MB) | x86 | 原生 C++ 监控进程 |
| YoudaoEH.exe (2.6MB) | **x64** | x64 环境取词辅助 |
| YoudaoEDIT.exe (432KB) | x86 | **MFC 14.0**，词条编辑工具 |
| YoudaoProxyServer.exe (300KB) | x86 | 代理服务，链接 ydk-plus.dll 与 YdAcademicAccProxy32.dll |
| YdAcademicAccProxy32.dll (5.0MB) | x86 | 学术搜索代理 |
| YodaoDict.exe (265KB) | x86 | 启动器桩程序（仅 KERNEL32/USER32） |
| YoudaoCookieAssist.exe (70KB) | x86 | **MSVC 2008**，Cookie 辅助 |

## 5. Go 组件（亮点）

- **`ydk-plus.dll` 为 Go 1.22.1 编译的 DLL**（含 Go Build ID 标记、Go runtime 字符串 429 处）
- 由 `YoudaoProxyServer.exe`（代理服务）与 `YdAcademicAccProxy32.dll` 调用
- 说明: 新版组件栈正在用 Go 替换 C++ 模块

## 6. OCR 子系统

- `YoudaoOcr.exe` (4.3MB) + `youdao_ocr_lib.dll` (9.7MB): 原生 C++ OCR 引擎，x86
- 链接 **OpenCL.dll** → GPU 加速
- `recognition/` 内置本地模型: `model`（4.2MB）、`model_jp`（日文）、`model_latin`（拉丁） + `label`/`label_jp`/`label_latin`
- 模型头部为自定义二进制格式（非 Tesseract traineddata），判定为自研 LSTM 识别模型

## 7. Office 插件（VSTO / .NET）

- `officeaddin/wordaddin|exceladdin|pptaddin` 三套插件
- 证据: `YdWordAddIn.vsto`、`Microsoft.Office.Tools.Word.dll`、`Microsoft.Office.Tools.v4.0.Framework.dll`、`Microsoft.VisualStudio.Tools.Applications.Runtime.dll`、`.manifest`
- 判定: **VSTO (Visual Studio Tools for Office)，C#/.NET Framework 4.x**，旧技术方案（微软已弃用 VSTO 但仍广泛存在）

## 8. 数据与杂项

- **离线词典**: SQLite 数据库 ×8 语种（`localdicts/dicten.db` 8.6MB 最大）
- **音频**: `NAudioPlayer.dll` (2.0MB) 为原生 C++ 播放器（导出 `NMP3Player` 类，走 winmm），**非 .NET NAudio 库**，仅命名相似
- **第三方集成 API**: `YodaoDict.api` / `YodaoDict7.api` 实为 PE DLL（x86，176KB），历代遗留的开发商接入接口
- **版本管理**: `versions.xml` 列出 50+ 模块化组件及独立版本号（如 OCR 引擎 ver 2090、CEF 组件 ver 170），支持模块级增量更新

## 9. 技术栈总结

| 层次 | 技术 |
|---|---|
| 主程序语言 | 原生 C++ (MSVC)，x86 为主 + x64 辅助 |
| 桌面 UI | 自研 XML DirectUI 皮肤引擎 |
| 内容 UI | CEF (Chromium 127) + HTML5 + **Vue 3 / zepto** |
| 原生桥 | JSB (JavaScript Bridge) 协议 |
| 取词/钩子 | Microsoft Detours + 注入 DLL |
| OCR | 自研 C++ 引擎 + OpenCL + 本地 LSTM 模型 |
| 新组件 | **Go 1.22** (ydk-plus.dll) |
| Office 插件 | **VSTO / .NET Framework (C#)** |
| 存储 | SQLite |
| 崩溃/网络 | CrashRpt / WINHTTP / WS2_32 |
| 安装/保护 | 自研安装器 + 自定义加壳混淆 |

## 10. 附注

1. 本报告基于静态分析，未动态调试；导入表混淆导致部分依赖细节无法穷尽，但已通过特征串扫描交叉验证。
2. 分析环境中无 `YoudaoIE.exe`、`YoudaoGetWord32/64.dll`、浏览器扩展（.crx）等 modules，仅在 `versions.xml` 中登记，未列入正文。
3. 所有二进制均未发现 Qt 标记 → 判定整个产品线不使用 Qt。