# 智伴口袋 系统级重构设计

> 2026-05-14 | 目标风格: OpenAI + Linear + Apple + Notion

## 策略

渐进式演进 — 7 个独立 Phase，每 Phase 保持项目可编译运行。

## Phase 1: 设计系统统一

消除 `AppTheme`（旧 Clay）/ `AppThemeData`（新 M3）/ `XuiTheme`（xui 独立）三套并行系统。

- 唯一设计系统: `lib/design/`（colors / typography / radius / elevation / spacing / animation / theme_data）
- 删除 `lib/config/theme.dart`
- 删除 `lib/xui/x_design.dart`，`ClayContainer` 独立为 widget
- `_fromHex()` 统一为 `AppColors.fromHex()`
- 深色模式语义色补全

## Phase 2: Widget 分层

Page 文件 ≤ 150 行，内联组件抽取为独立 widget。

- home_page: 抽取 8 个内联组件
- module_detail_page: 抽取 3 个内联组件
- mine_page: 抽取 7 个内联组件

## Phase 3: 状态管理

- 不可变状态类 (loading / data / error)
- Provider 构造函数注入 (解除 Service 硬依赖)
- `context.select` 精确 rebuild
- 模块分批懒加载

## Phase 4: 数据层

- Repository 模式 (ModuleRepository / ContentRepository)
- AiService 拆分为 AiGenerateService + AiPromptService
- 统一错误类型

## Phase 5: 路由 & i18n

- RoutePaths 全覆盖，消除硬编码路径
- MainShell 独立文件
- flutter_localizations + ARB 文件

## Phase 6: 性能

- const 审计
- RepaintBoundary
- cached_network_image
- 首屏 build 次数降低 60%+

## Phase 7: 代码质量

- strict-casts / strict-inference
- Repository + Provider 测试
- flutter analyze 零 warning
