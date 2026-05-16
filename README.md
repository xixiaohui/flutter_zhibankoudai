# 智伴口袋 (ZhiBanKouDai / PocketMind)

> 您的个人专家知识库 — 每日知识陪伴，60+ 模块内容聚合平台

## 功能概览

- 60+ 主题模块（名言、心理、财经、编程、SEO 等），每日推送优质内容
- AI 内容生成（腾讯混元大模型），含内容去重和领域知识增强
- 海报生成与分享
- AI 情感陪伴（小智） & 180+ 行业专家深度对话
- **12 种语言国际化支持**

---

## 多语言支持

应用自动跟随系统语言，无需手动切换。

| 序号 | 语言 | Locale | RTL |
| --- | --- | --- | --- |
| 1 | 中文（默认） | zh | |
| 2 | English | en | |
| 3 | 日本語 | ja | |
| 4 | 한국어 | ko | |
| 5 | Español | es | |
| 6 | Français | fr | |
| 7 | Deutsch | de | |
| 8 | Português | pt | |
| 9 | Русский | ru | |
| 10 | العربية | ar | ✓ |
| 11 | हिन्दी | hi | |
| 12 | ไทย | th | |

翻译文件位于 `lib/l10n/`（ARB 格式），模块配置位于 `assets/cloudData/modules/`（JSON 格式）。新增语言只需添加对应的 ARB 和 JSON 文件。

---

## 本地开发

```bash
# 安装依赖
flutter pub get

# 生成国际化代码
flutter gen-l10n

# 运行（需连接设备或模拟器）
flutter run

# 构建 APK
flutter build apk --release

# 构建 iOS
flutter build ios --release

# 代码检查
flutter analyze
```

---

## 架构概览

### 状态管理 & 路由

- **Provider**：`ModuleProvider`（模块列表）、`DailyContentProvider`（内容缓存+AI 刷新）、`ThemeProvider`（主题）、`LocaleProvider`（语言）
- **go_router**：`ShellRoute` 包裹四个 Tab（首页/发现/助理/我的），详情页和海报页在 Shell 外部

### 数据流（内容加载）

```text
1. 内存缓存 (_contents map) → 命中即返回
2. SharedPreferences 缓存（24h 过期）→ 命中即返回
3. CloudBase 云数据库 → 缓存本地并返回
4. AI 模型生成（混元）→ 缓存 + 持久化云数据库 + 返回
5. 兜底数据（assets JSON 或模块默认值）→ 返回
```

### 目录结构

```text
lib/
├── main.dart                  # App 入口，MultiProvider + MaterialApp.router
├── config/
│   ├── routes.dart            # go_router 配置（ShellRoute + 路由表）
│   ├── constants.dart         # 全局常量
│   └── env.dart               # 编译时环境变量
├── design/                    # 设计系统（颜色/排版/圆角/阴影/间距）
├── models/
│   ├── module_config.dart     # 模块配置模型
│   ├── daily_content.dart     # 每日内容模型
│   └── career.dart            # 职业模型
├── providers/
│   ├── module_provider.dart   # 模块列表状态
│   ├── daily_content_provider.dart  # 内容加载+AI 刷新
│   ├── theme_provider.dart    # 主题切换
│   └── locale_provider.dart   # 多语言（跟随系统）
├── services/
│   ├── cloudbase_client.dart  # CloudBase HTTP 客户端
│   ├── cloudbase_ai.dart      # 混元 AI 网关（流式+非流式）
│   ├── cloudbase_db.dart      # CloudBase 数据库操作
│   ├── ai_service.dart        # 内容生成（级联 prompt + JSON 解析）
│   ├── data_service.dart      # 数据服务（模块配置 + 内容缓存/云端）
│   └── cache_service.dart     # SharedPreferences 封装（TTL 过期）
├── pages/
│   ├── home_page.dart         # 首页：Hero 卡片 + 模块网格
│   ├── module_detail_page.dart # 模块详情：Markdown + AI 刷新
│   ├── poster_page.dart       # 海报生成与分享
│   ├── mine_page.dart         # 个人中心
│   ├── ai_friend_page.dart    # AI 情感陪伴
│   └── ai_career_page.dart    # 行业专家对话
├── widgets/                   # 可复用组件
├── l10n/                      # ARB 翻译文件（12 种语言）
│   └── gen/                   # flutter gen-l10n 自动生成（gitignore）
└── xui/
    ├── pages/                 # XUI 页面（助手广场、搜索等）
    └── utils/module.dart      # 扩展模块模型
```

### 设计系统

Clay-inspire 暖色设计语言：奶油色调背景 (`#faf9f7`)、燕麦色边框、多层内阴影、24px 卡片圆角。支持浅色/深色模式切换。

---

## 环境配置

项目根目录 `.env` 文件提供 CloudBase 凭证（不提交到版本控制）：

```text
CLOUDBASE_ENV_ID=<env-id>
CLOUDBASE_ACCESS_TOKEN=<jwt-token>
```

---

## 翻译贡献

如需为新语言贡献翻译：

1. 复制 `lib/l10n/app_en.arb` 为 `app_{locale}.arb`
2. 修改 `@@locale` 字段并翻译所有 value
3. 复制 `assets/cloudData/modules/modules_en.json` 为 `modules_{locale}.json`
4. 翻译模块名称、描述、提示词等字段
5. 更新 `lib/main.dart` 中 `supportedLocales` 列表
6. 运行 `flutter gen-l10n` 生成代码

---

## 技术栈

- **框架**：Flutter 3.x（Dart SDK ^3.11）
- **状态管理**：Provider + ChangeNotifier
- **路由**：go_router（ShellRoute）
- **网络**：Dio + http
- **存储**：SharedPreferences（本地缓存）
- **后端**：Tencent CloudBase（云数据库 + 云函数）
- **AI**：腾讯混元大模型（Hunyuan）
- **国际化**：flutter_localizations + ARB

---

## License

MIT
