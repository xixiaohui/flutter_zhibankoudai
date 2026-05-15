# 多语言（i18n）支持 — 实现计划

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** 为智伴口袋 App 添加 12 种语言的国际化支持（Flutter 官方 `flutter_localizations` + ARB 方案）

**Architecture:** ARB 文件管理 UI 字符串（~183 条），JSON 文件管理模块配置（60 模块 × 12 语言），`LocaleProvider` 暴露当前 locale 给服务层，AI 接口传递 locale 参数控制生成语言

**Tech Stack:** flutter_localizations (SDK), intl (已有), ARB / flutter gen-l10n, Provider, JSON asset loading

---

### Task 1: 基础设施 — 依赖与 gen-l10n 配置

**Files:**
- Modify: `pubspec.yaml`
- Create: `l10n.yaml`
- Create: `lib/l10n/app_zh.arb`
- Create: `lib/l10n/app_en.arb`

- [ ] **Step 1: 添加 flutter_localizations 依赖并启用 gen-l10n**

编辑 `pubspec.yaml`，在 dependencies 中添加 flutter_localizations，在 flutter 段添加 generate: true 和 l10n assets：

```yaml
dependencies:
  flutter:
    sdk: flutter
  flutter_localizations:
    sdk: flutter
  # ... 其余不变
```

在 `flutter:` 段修改为：

```yaml
flutter:
  generate: true
  uses-material-design: true
  assets:
    - assets/images/
    - assets/data/
    - assets/cloudData/prompts/aiPrompts.json
    - assets/cloudData/modules/
    - assets/career/
    - .env
  # fonts 保持不变
```

- [ ] **Step 2: 创建 l10n.yaml 配置文件**

```yaml
arb-dir: lib/l10n
template-arb-file: app_zh.arb
output-localization-file: app_localizations.dart
nullable-getter: false
synthetic-package: false
output-dir: lib/l10n/gen
```

- [ ] **Step 3: 创建中文 ARB 模板（app_zh.arb），先放少量字符串验证**

```json
{
  "@@locale": "zh",
  "appName": "智伴口袋",
  "bottomNavHome": "首页",
  "bottomNavDiscover": "发现",
  "bottomNavAssistant": "助理",
  "bottomNavMine": "我的",
  "dailyUpdate": "每日更新",
  "personalKnowledgeBase": "您的个人专家知识库"
}
```

- [ ] **Step 4: 创建英文 ARB 文件（app_en.arb）用于验证**

```json
{
  "@@locale": "en",
  "appName": "PocketMind",
  "bottomNavHome": "Home",
  "bottomNavDiscover": "Discover",
  "bottomNavAssistant": "Assistant",
  "bottomNavMine": "Mine",
  "dailyUpdate": "Daily Update",
  "personalKnowledgeBase": "Your Personal Expert Knowledge Base"
}
```

- [ ] **Step 5: 运行 flutter gen-l10n 生成代码**

```bash
flutter gen-l10n
```

Expected: 生成 `lib/l10n/gen/app_localizations.dart`、`lib/l10n/gen/app_localizations_en.dart`、`lib/l10n/gen/app_localizations_zh.dart`

- [ ] **Step 6: 将 gen 目录加入 .gitignore**

```bash
echo "lib/l10n/gen/" >> .gitignore
```

- [ ] **Step 7: Commit**

```bash
git add pubspec.yaml l10n.yaml lib/l10n/ .gitignore
git commit -m "feat(i18n): add flutter_localizations, l10n config, and sample ARB files"
```

---

### Task 2: 基础设施 — main.dart 集成 + LocaleProvider

**Files:**
- Modify: `lib/main.dart`
- Create: `lib/providers/locale_provider.dart`

- [ ] **Step 1: 创建 LocaleProvider**

```dart
import 'package:flutter/material.dart';

class LocaleProvider extends ChangeNotifier {
  Locale _locale = WidgetsBinding.instance.platformDispatcher.locale;

  Locale get locale => _locale;

  String get languageCode => _locale.languageCode;

  void updateFromSystem() {
    final systemLocale = WidgetsBinding.instance.platformDispatcher.locale;
    if (_locale != systemLocale) {
      _locale = systemLocale;
      notifyListeners();
    }
  }
}
```

- [ ] **Step 2: 修改 main.dart — 添加导入和 MultiProvider**

在 `lib/main.dart` 顶部添加导入：

```dart
import 'package:flutter_localizations/flutter_localizations.dart';
import 'l10n/gen/app_localizations.dart';
import 'providers/locale_provider.dart';
```

在 `ZhiBanKouDaiApp.build` 的 MultiProvider providers 列表中添加 LocaleProvider：

```dart
providers: [
  ChangeNotifierProvider(create: (_) => ModuleProvider()),
  ChangeNotifierProvider(create: (_) => DailyContentProvider()),
  ChangeNotifierProvider(create: (_) => ThemeProvider()),
  ChangeNotifierProvider(create: (_) => LocaleProvider()),  // 新增
],
```

- [ ] **Step 3: 在 MaterialApp.router 添加本地化配置**

在 `return MaterialApp.router(...)` 中添加以下参数：

```dart
return MaterialApp.router(
  title: '智伴口袋',
  debugShowCheckedModeBanner: false,
  theme: AppThemeData.light,
  darkTheme: AppThemeData.dark,
  themeMode: themeProvider.mode,
  routerConfig: appRouter,
  // 新增 ↓
  locale: localeProvider.locale,
  supportedLocales: AppLocalizations.supportedLocales,
  localizationsDelegates: const [
    AppLocalizations.delegate,
    GlobalMaterialLocalizations.delegate,
    GlobalWidgetsLocalizations.delegate,
    GlobalCupertinoLocalizations.delegate,
  ],
  localeResolutionCallback: (locale, supportedLocales) {
    for (final supportedLocale in supportedLocales) {
      if (supportedLocale.languageCode == locale?.languageCode) {
        return supportedLocale;
      }
    }
    return supportedLocales.first; // fallback to zh
  },
);
```

同时修改 Consumer builder 以读取 LocaleProvider：

```dart
child: Consumer<ThemeProvider>(
  builder: (_, themeProvider, _) {
    // ... existing brightness code unchanged
    return MaterialApp.router(...);
  },
),
```

改为同时消费 LocaleProvider（用 Consumer2）：

```dart
child: Consumer2<ThemeProvider, LocaleProvider>(
  builder: (_, themeProvider, localeProvider, _) {
    final brightness = switch (themeProvider.mode) {
      ThemeMode.light => Brightness.light,
      ThemeMode.dark => Brightness.dark,
      ThemeMode.system => WidgetsBinding.instance.platformDispatcher.platformBrightness,
    };
    SystemChrome.setSystemUIOverlayStyle(AppThemeData.overlayStyle(brightness));

    return MaterialApp.router(
      title: '智伴口袋',
      // ... (existing theme config)
      locale: localeProvider.locale,
      supportedLocales: AppLocalizations.supportedLocales,
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      localeResolutionCallback: (locale, supportedLocales) {
        for (final supportedLocale in supportedLocales) {
          if (supportedLocale.languageCode == locale?.languageCode) {
            return supportedLocale;
          }
        }
        return supportedLocales.first;
      },
    );
  },
),
```

- [ ] **Step 4: 运行 flutter analyze 验证编译通过**

```bash
flutter analyze
```

Expected: No issues found.

- [ ] **Step 5: Commit**

```bash
git add lib/main.dart lib/providers/locale_provider.dart
git commit -m "feat(i18n): integrate flutter_localizations into main.dart, add LocaleProvider"
```

---

### Task 3: 导航栏 & 首页 header 本地化

**Files:**
- Modify: `lib/config/routes.dart`
- Modify: `lib/pages/home_page.dart`

- [ ] **Step 1: 修改 routes.dart — MainShell 导航标签本地化**

在 `lib/config/routes.dart` 顶部添加导入：

```dart
import '../l10n/gen/app_localizations.dart';
```

修改 `MainShell.build` 的 `destinations`：

```dart
destinations: [
  NavigationDestination(icon: Icon(Icons.home_outlined), selectedIcon: Icon(Icons.home), label: AppLocalizations.of(context)!.bottomNavHome),
  NavigationDestination(icon: Icon(Icons.explore_outlined), selectedIcon: Icon(Icons.explore), label: AppLocalizations.of(context)!.bottomNavDiscover),
  NavigationDestination(icon: Icon(Icons.bolt_outlined), selectedIcon: Icon(Icons.bolt), label: AppLocalizations.of(context)!.bottomNavAssistant),
  NavigationDestination(icon: Icon(Icons.person_outline), selectedIcon: Icon(Icons.person), label: AppLocalizations.of(context)!.bottomNavMine),
],
```

注意：MainShell 的 build 方法需要改为使用 Builder 包裹（已有的 Builder 已经提供 context）。

- [ ] **Step 2: 修改 home_page.dart — _header 方法**

在 `lib/pages/home_page.dart` 顶部添加导入：

```dart
import '../l10n/gen/app_localizations.dart';
```

修改 `_header` 方法中的硬编码字符串：

```dart
// 将：Text('智伴口袋', ...)
// 改为：Text(AppLocalizations.of(context)!.appName, ...)

// 将：Text('每日更新', ...)
// 改为：Text(AppLocalizations.of(context)!.dailyUpdate, ...)

// 将：Text('您的个人专家知识库', ...)
// 改为：Text(AppLocalizations.of(context)!.personalKnowledgeBase, ...)
```

- [ ] **Step 3: 验证 — 运行 flutter analyze**

```bash
flutter analyze
```

Expected: No issues found.

- [ ] **Step 4: Commit**

```bash
git add lib/config/routes.dart lib/pages/home_page.dart
git commit -m "feat(i18n): localize bottom nav and home page header"
```

---

### Task 4: 完善 ARB 文件 — 全部 ~183 条 UI 字符串

**Files:**
- Modify: `lib/l10n/app_zh.arb`（完整版）
- Modify: `lib/l10n/app_en.arb`（完整版）
- Create: `lib/l10n/app_ja.arb` ~ `lib/l10n/app_th.arb`（10 个文件，机器翻译初版）

- [ ] **Step 1: 更新 app_zh.arb 为完整版（~183 条字符串）**

```json
{
  "@@locale": "zh",
  "appName": "智伴口袋",
  "appNameEn": "PocketMind",
  "bottomNavHome": "首页",
  "bottomNavDiscover": "发现",
  "bottomNavAssistant": "助理",
  "bottomNavMine": "我的",
  "dailyUpdate": "每日更新",
  "personalKnowledgeBase": "您的个人专家知识库",
  "noContent": "暂无内容",
  "noModule": "暂无模块",
  "moreModules": "更多模块",
  "aiGenerate": "AI 生成",
  "aiRefresh": "AI 换一条",
  "generatePoster": "生成海报",
  "share": "分享",
  "sharePoster": "分享海报",
  "shareToFriend": "分享给朋友",
  "shareRecommend": "推荐给更多人",
  "shareText": "智伴口袋 — 每日知识，伴你成长！\n60+专家模块，每天为你推送优质内容。\n快来下载体验吧！",
  "cancel": "取消",
  "confirm": "确定",
  "delete": "删除",
  "retry": "重试",
  "save": "保存",
  "loading": "加载中...",
  "generating": "生成中...",
  "processing": "处理中...",
  "saveToAlbum": "保存相册",
  "savedToAlbum": "海报已保存至相册",
  "savedMultipleToAlbum": "{count} 张海报已保存至相册",
  "@savedMultipleToAlbum": {
    "placeholders": {
      "count": {"type": "int"}
    }
  },
  "savingImages": "保存中 {current}/{total}...",
  "@savingImages": {
    "placeholders": {
      "current": {"type": "int"},
      "total": {"type": "int"}
    }
  },
  "saveError": "保存出错: {error}",
  "@saveError": {
    "placeholders": {
      "error": {"type": "String"}
    }
  },
  "savePermissionRequired": "需要相册权限",
  "shareFailed": "分享失败: {error}",
  "@shareFailed": {
    "placeholders": {
      "error": {"type": "String"}
    }
  },
  "moduleNotFound": "模块不存在",
  "moduleNotFoundDesc": "未找到该模块",
  "loadFailed": "加载失败",
  "loadingMore": "加载更多",
  "noMoreData": "没有更多数据",
  "themeSettings": "主题设置",
  "notification": "通知提醒",
  "notificationDesc": "设置每日推送时间",
  "clearCache": "清除缓存",
  "clearCacheDesc": "清理本地缓存数据",
  "aboutUs": "关于我们",
  "aboutVersion": "版本 {version}",
  "@aboutVersion": {
    "placeholders": {
      "version": {"type": "String"}
    }
  },
  "rateUs": "给个好评",
  "rateUsDesc": "您的支持是我们前进的动力",
  "rateLater": "稍后再说",
  "clearCacheConfirm": "确定要清除所有本地缓存数据吗？\n这将清除已保存的内容和设置。",
  "cacheCleared": "缓存已清除",
  "aboutSlogan": "每日知识，伴你成长",
  "aboutVersionLabel": "版本",
  "aboutBuildLabel": "构建",
  "aboutDesignLabel": "设计",
  "aboutBuildValue": "Flutter · Tencent CloudBase",
  "aboutDesignValue": "Editorial Precision Design System",
  "aboutGotIt": "知道了",
  "rateTitle": "给个好评",
  "rateContent": "感谢您的支持！您的每一次好评都是我们前进的动力。\n\n请前往应用商店为我们评分，或分享给更多朋友。",
  "lightMode": "浅色模式",
  "darkMode": "深色模式",
  "followSystem": "跟随系统",
  "enableDailyPush": "开启每日推送",
  "selectPushTime": "选择每日推送时间（当前为示例设置，具体推送由后端支持）",
  "morningTime": "☀️ 早晨",
  "forenoonTime": "🌤 上午",
  "eveningTime": "🌙 晚间",
  "morningDesc": "开启活力一天",
  "forenoonDesc": "黄金学习时间",
  "eveningDesc": "睡前轻松阅读",
  "pushSet": "已设置每日 {time} 推送",
  "@pushSet": {
    "placeholders": {
      "time": {"type": "String"}
    }
  },
  "pushDisabled": "已关闭每日推送",
  "emotionalCompanion": "情感陪伴",
  "emotionalCompanionDesc": "和\"小智\"聊聊天，分享你的心情",
  "domainExpert": "领域专家",
  "domainExpertDesc": "与180+行业专家深度对话，获取专业见解",
  "hotPicks": "热门精选",
  "deleteChatHistory": "删除聊天记录",
  "deleteChatConfirm": "确定要删除所有聊天记录吗？删除后将无法恢复。",
  "typeHint": "说点什么...",
  "typeHintExpert": "向{name}提问...",
  "@typeHintExpert": {
    "placeholders": {
      "name": {"type": "String"}
    }
  },
  "sorryCannotReply": "抱歉，我暂时无法回复。请稍后再试。",
  "errorOccurred": "出错了：{error}",
  "@errorOccurred": {
    "placeholders": {
      "error": {"type": "String"}
    }
  },
  "aiFriendGreeting": "你好呀！我是小智，你的情感陪伴伙伴...",
  "chatMe": "我",
  "chatBot": "智",
  "emotionCrisis": "危机信号",
  "emotionHappy": "开心",
  "emotionSad": "难过",
  "emotionAnxious": "焦虑",
  "emotionAngry": "生气",
  "emotionCalm": "平静",
  "emotionNeutral": "中性",
  "emotionExcited": "兴奋",
  "emotionTired": "疲惫",
  "sceneFirstGreeting": "初次问候",
  "sceneCrisisIntervention": "危机干预",
  "sceneEmotionalComfort": "情绪安抚",
  "sceneShareJoy": "分享喜悦",
  "sceneDailyChat": "日常闲聊",
  "sceneDeepTalk": "深度交流",
  "sceneSilentCompany": "安静陪伴",
  "recentMemory": "最近的对话记忆",
  "memoryUser": "用户",
  "memoryBot": "小智",
  "memoryContinue": "请基于以上对话记忆继续交流，保持上下文连贯。",
  "userCardName": "智伴口袋用户",
  "quickEntry": "快捷入口",
  "hotQuestions": "热门问题",
  "marketTrends": "行情趋势",
  "recommendedFeatures": "推荐功能",
  "smartAssistant": "智能助手",
  "otherAssistants": "其他助手",
  "assistantSquare": "助手广场",
  "assistantList": "助手列表",
  "viewDataset": "点击查看该数据集",
  "aiAnalysis": "AI分析",
  "materialQuery": "材料查询",
  "priceTrend": "价格趋势",
  "supplier": "供应商",
  "aiMaterialAssistant": "AI材料助手",
  "aiAnalysisMaterial": "AI分析 · 材料查询 · 行情洞察",
  "aiMaterialAssistantDesc": "材料问题 · 行情趋势 · 采购建议",
  "trendAnalysis": "趋势分析",
  "materialDatabase": "材料数据库",
  "quoteTool": "报价工具",
  "materialQuestion": "请输入问题，例如：玻璃纤维的价格？",
  "searchHint": "继续提问...",
  "analyze": "分析",
  "searchPlaceholder": "请输入问题并点击分析",
  "questionPrefix": "问题：{question}",
  "@questionPrefix": {
    "placeholders": {
      "question": {"type": "String"}
    }
  },
  "inputMaterialQuestion": "输入材料问题，开始分析",
  "inputMaterialHint": "输入材料问题...",
  "requestFailed": "请求失败，请稍后再试。",
  "aiMaterialHero": "材料 AI 智能助手",
  "aiMaterialHeroDesc": "输入问题，获取材料数据与分析结果",
  "aiMaterialHeroHint": "请输入材料、价格、应用场景...",
  "posterPreview": "海报预览",
  "close": "关闭",
  "saveToPhotoAlbum": "保存到相册",
  "savedToPhotoAlbum": "已保存到相册",
  "saveToAlbumFailed": "保存失败，请检查相册权限",
  "posterBranding": "智伴口袋",
  "posterFooter": "每日知识陪伴",
  "posterFromApp": "来自「智伴口袋」的每日知识分享",
  "aiInterpretation": "AI解读",
  "compositeMaterialAiAssistant": "复合材料AI助手",
  "smartAnalysisMaterial": "智能分析材料问题",
  "marketAnalysisAssistant": "行情分析助手",
  "marketAnalysisDesc": "价格趋势与市场分析",
  "quoteAssistant": "报价助手",
  "quoteAssistantDesc": "成本估算与报价生成",
  "tradeAssistant": "外贸助手",
  "tradeAssistantDesc": "英文回复与客户沟通",
  "myAssistant": "我的助手",
  "cloudAssistantWaterfall": "云端助手瀑布流",
  "cloudAssistantList": "云端助手列表",
  "otherCategory": "其他",
  "weekdayMon": "周一",
  "weekdayTue": "周二",
  "weekdayWed": "周三",
  "weekdayThu": "周四",
  "weekdayFri": "周五",
  "weekdaySat": "周六",
  "weekdaySun": "周日",
  "fieldAuthor": "作者",
  "fieldSinger": "歌手",
  "fieldDirector": "导演",
  "fieldSource": "出处",
  "fieldEra": "年代",
  "fieldRegion": "地区",
  "fieldLocation": "位置",
  "fieldAlbum": "专辑",
  "fieldFortuneDirection": "吉利方位",
  "fieldFortuneNumber": "吉利数字",
  "fieldFortuneColor": "吉利颜色",
  "fieldCoreQuote": "核心金句",
  "identifyEmotion": "识别情绪",
  "confidence": "置信度"
}
```

- [ ] **Step 2: 创建 app_en.arb 完整版（人工校对）**

```json
{
  "@@locale": "en",
  "appName": "PocketMind",
  "appNameEn": "PocketMind",
  "bottomNavHome": "Home",
  "bottomNavDiscover": "Discover",
  "bottomNavAssistant": "Agent",
  "bottomNavMine": "Mine",
  "dailyUpdate": "Daily Update",
  "personalKnowledgeBase": "Your Personal Expert Knowledge Base",
  "noContent": "No content available",
  "noModule": "No modules",
  "moreModules": "More Modules",
  "aiGenerate": "AI Generate",
  "aiRefresh": "AI Refresh",
  "generatePoster": "Poster",
  "share": "Share",
  "sharePoster": "Share Poster",
  "shareToFriend": "Share with Friends",
  "shareRecommend": "Recommend to more people",
  "shareText": "PocketMind — Daily Knowledge, Growing with You!\n60+ expert modules delivering quality content every day.\nDownload now!",
  "cancel": "Cancel",
  "confirm": "OK",
  "delete": "Delete",
  "retry": "Retry",
  "save": "Save",
  "loading": "Loading...",
  "generating": "Generating...",
  "processing": "Processing...",
  "saveToAlbum": "Save to Album",
  "savedToAlbum": "Poster saved to album",
  "savedMultipleToAlbum": "{count} posters saved to album",
  "savingImages": "Saving {current}/{total}...",
  "saveError": "Save error: {error}",
  "savePermissionRequired": "Album permission required",
  "shareFailed": "Share failed: {error}",
  "moduleNotFound": "Module not found",
  "moduleNotFoundDesc": "This module could not be found",
  "loadFailed": "Load failed",
  "loadingMore": "Load more",
  "noMoreData": "No more data",
  "themeSettings": "Theme",
  "notification": "Notifications",
  "notificationDesc": "Set daily push time",
  "clearCache": "Clear Cache",
  "clearCacheDesc": "Clear local cache data",
  "aboutUs": "About",
  "aboutVersion": "Version {version}",
  "rateUs": "Rate Us",
  "rateUsDesc": "Your support drives us forward",
  "rateLater": "Later",
  "clearCacheConfirm": "Are you sure you want to clear all local cache data?\nThis will remove saved content and settings.",
  "cacheCleared": "Cache cleared",
  "aboutSlogan": "Daily knowledge, growing with you",
  "aboutVersionLabel": "Version",
  "aboutBuildLabel": "Build",
  "aboutDesignLabel": "Design",
  "aboutBuildValue": "Flutter · Tencent CloudBase",
  "aboutDesignValue": "Editorial Precision Design System",
  "aboutGotIt": "Got it",
  "rateTitle": "Rate Us",
  "rateContent": "Thank you for your support! Every rating helps us improve.\n\nPlease rate us in the app store, or share with your friends.",
  "lightMode": "Light",
  "darkMode": "Dark",
  "followSystem": "System",
  "enableDailyPush": "Enable daily push",
  "selectPushTime": "Select daily push time (currently demo settings, backend push coming soon)",
  "morningTime": "☀️ Morning",
  "forenoonTime": "🌤 Before Noon",
  "eveningTime": "🌙 Evening",
  "morningDesc": "Start your day with energy",
  "forenoonDesc": "Prime learning time",
  "eveningDesc": "Relaxed evening reading",
  "pushSet": "Daily push set to {time}",
  "pushDisabled": "Daily push disabled",
  "emotionalCompanion": "Emotional Companion",
  "emotionalCompanionDesc": "Chat with \"Xiao Zhi\" and share your feelings",
  "domainExpert": "Domain Experts",
  "domainExpertDesc": "Deep conversations with 180+ industry experts for professional insights",
  "hotPicks": "Hot Picks",
  "deleteChatHistory": "Delete Chat History",
  "deleteChatConfirm": "Are you sure you want to delete all chat history? This cannot be undone.",
  "typeHint": "Say something...",
  "typeHintExpert": "Ask {name}...",
  "sorryCannotReply": "Sorry, I'm unable to reply right now. Please try again later.",
  "errorOccurred": "Error: {error}",
  "aiFriendGreeting": "Hi! I'm Xiao Zhi, your emotional companion...",
  "chatMe": "Me",
  "chatBot": "Zhi",
  "emotionCrisis": "Crisis",
  "emotionHappy": "Happy",
  "emotionSad": "Sad",
  "emotionAnxious": "Anxious",
  "emotionAngry": "Angry",
  "emotionCalm": "Calm",
  "emotionNeutral": "Neutral",
  "emotionExcited": "Excited",
  "emotionTired": "Tired",
  "sceneFirstGreeting": "First Greeting",
  "sceneCrisisIntervention": "Crisis Intervention",
  "sceneEmotionalComfort": "Emotional Comfort",
  "sceneShareJoy": "Sharing Joy",
  "sceneDailyChat": "Daily Chat",
  "sceneDeepTalk": "Deep Conversation",
  "sceneSilentCompany": "Silent Companion",
  "recentMemory": "Recent Conversation Memory",
  "memoryUser": "User",
  "memoryBot": "Xiao Zhi",
  "memoryContinue": "Please continue the conversation based on the above memory, maintaining context coherence.",
  "userCardName": "PocketMind User",
  "quickEntry": "Quick Entry",
  "hotQuestions": "Hot Questions",
  "marketTrends": "Market Trends",
  "recommendedFeatures": "Recommended",
  "smartAssistant": "Smart Assistant",
  "otherAssistants": "Other Assistants",
  "assistantSquare": "Assistant Square",
  "assistantList": "Assistant List",
  "viewDataset": "Tap to view this dataset",
  "aiAnalysis": "AI Analysis",
  "materialQuery": "Material Query",
  "priceTrend": "Price Trend",
  "supplier": "Suppliers",
  "aiMaterialAssistant": "AI Material Assistant",
  "aiAnalysisMaterial": "AI Analysis · Material Query · Market Insights",
  "aiMaterialAssistantDesc": "Material Questions · Market Trends · Procurement Advice",
  "trendAnalysis": "Trend Analysis",
  "materialDatabase": "Material Database",
  "quoteTool": "Quote Tool",
  "materialQuestion": "Enter a question, e.g.: What is the price of fiberglass?",
  "searchHint": "Continue asking...",
  "analyze": "Analyze",
  "searchPlaceholder": "Enter a question and tap analyze",
  "questionPrefix": "Question: {question}",
  "inputMaterialQuestion": "Enter a material question to start analysis",
  "inputMaterialHint": "Enter material question...",
  "requestFailed": "Request failed. Please try again later.",
  "aiMaterialHero": "Material AI Smart Assistant",
  "aiMaterialHeroDesc": "Enter a question to get material data and analysis results",
  "aiMaterialHeroHint": "Enter material, price, application scenario...",
  "posterPreview": "Poster Preview",
  "close": "Close",
  "saveToPhotoAlbum": "Save to Album",
  "savedToPhotoAlbum": "Saved to album",
  "saveToAlbumFailed": "Save failed. Please check album permissions.",
  "posterBranding": "PocketMind",
  "posterFooter": "Daily Knowledge Companion",
  "posterFromApp": "Daily knowledge shared from \"PocketMind\"",
  "aiInterpretation": "AI Insights",
  "compositeMaterialAiAssistant": "Composite Material AI Assistant",
  "smartAnalysisMaterial": "Smart material analysis",
  "marketAnalysisAssistant": "Market Analysis Assistant",
  "marketAnalysisDesc": "Price trends and market analysis",
  "quoteAssistant": "Quote Assistant",
  "quoteAssistantDesc": "Cost estimation and quote generation",
  "tradeAssistant": "Trade Assistant",
  "tradeAssistantDesc": "English replies and customer communication",
  "myAssistant": "My Assistant",
  "cloudAssistantWaterfall": "Cloud Assistant Waterfall",
  "cloudAssistantList": "Cloud Assistant List",
  "otherCategory": "Other",
  "weekdayMon": "Mon",
  "weekdayTue": "Tue",
  "weekdayWed": "Wed",
  "weekdayThu": "Thu",
  "weekdayFri": "Fri",
  "weekdaySat": "Sat",
  "weekdaySun": "Sun",
  "fieldAuthor": "Author",
  "fieldSinger": "Singer",
  "fieldDirector": "Director",
  "fieldSource": "Source",
  "fieldEra": "Era",
  "fieldRegion": "Region",
  "fieldLocation": "Location",
  "fieldAlbum": "Album",
  "fieldFortuneDirection": "Lucky Direction",
  "fieldFortuneNumber": "Lucky Number",
  "fieldFortuneColor": "Lucky Color",
  "fieldCoreQuote": "Core Quote",
  "identifyEmotion": "Detected Emotion",
  "confidence": "Confidence"
}
```

- [ ] **Step 3: 创建其余 10 个 ARB 文件（机器翻译初版）**

为 ja, ko, es, fr, de, pt, ru, ar, hi, th 各创建 ARB 文件，key 与实际设置一致沿用英文，value 用对应语言翻译。每个文件格式：

```json
{
  "@@locale": "ja",
  "appName": "PocketMind",
  "bottomNavHome": "ホーム",
  "bottomNavDiscover": "発見",
  ...
}
```

（注：完整翻译内容见下方"翻译资源"——这 10 个文件的完整内容由于篇幅过长，实际执行时用批量脚本生成机器翻译初版）

- [ ] **Step 4: 运行 flutter gen-l10n 验证所有 12 种语言生成成功**

```bash
flutter gen-l10n
```

Expected: 生成 12 个 `app_localizations_*.dart` 文件，无错误。

- [ ] **Step 5: Commit**

```bash
git add lib/l10n/
git commit -m "feat(i18n): add complete ARB files for all 12 languages (~183 strings)"
```

---

### Task 5: 迁移 lib/config/constants.dart — 模块配置 JSON 化

**Files:**
- Modify: `lib/config/constants.dart`
- Create: `assets/cloudData/modules/modules_zh.json`
- Create: `assets/cloudData/modules/modules_en.json`
- Create: `scripts/generate_modules_json.dart`（辅助脚本）

- [ ] **Step 1: 创建 modules_zh.json（从现有 constants.dart 提取）**

从 `AppConstants.defaultModules` 的 59 条数据和 `defaultModuleConfig.modules` 的 60 条数据中提取翻译键。以 `defaultModuleConfig` 中的 Module 模型为主要数据源（因为它是 AI 服务使用的），为每个模块创建一个翻译条目。

`assets/cloudData/modules/modules_zh.json`（以 quote 模块为例）:

```json
[
  {
    "id": "quote",
    "name": "时光絮语",
    "description": "名人名言，智慧启迪",
    "generate": "请生成一句经典名言，包含作者和出处",
    "icon": "📜",
    "storageKey": "dailyQuote",
    "collection": "dailyQuotes",
    "color": "#5C6BC0",
    "refreshText": "换一句",
    "loadingText": "名言正在送达...",
    "placeholderText": "点击「换一句」获取今日名言",
    "posterType": "quote",
    "slogan": "名人名言，智慧启迪",
    "aiTags": ["名言", "金句"],
    "categoryField": "热选精选"
  }
]
```

（注：完整 60 模块 JSON 过长，实际执行时用脚本从 `defaultModuleConfig` 和 `AppConstants.defaultModules` 合并生成）

- [ ] **Step 2: 创建 modules_en.json**

```json
[
  {
    "id": "quote",
    "name": "Timeless Quotes",
    "description": "Words of wisdom to light up your day",
    "generate": "Generate a classic quote with author and source",
    "icon": "📜",
    "storageKey": "dailyQuote",
    "collection": "dailyQuotes",
    "color": "#5C6BC0",
    "refreshText": "New Quote",
    "loadingText": "Wisdom is on its way...",
    "placeholderText": "Tap \"New Quote\" for today's inspiration",
    "posterType": "quote",
    "slogan": "Wisdom from great minds",
    "aiTags": ["quotes", "wisdom"],
    "categoryField": "Hot Picks"
  }
]
```

- [ ] **Step 3: 创建 JSON 生成辅助脚本**

创建 `scripts/generate_modules_json.dart`——一个独立的 Dart 脚本，读取 `defaultModuleConfig` 生成 12 个语言的 modules JSON 文件，非 zh/en 的用占位符标记：

```dart
// scripts/generate_modules_json.dart
// Run: dart run scripts/generate_modules_json.dart
// Generates modules_{lang}.json for all 12 languages in assets/cloudData/modules/

import 'dart:convert';
import 'dart:io';

// 从 lib/xui/utils/module.dart 复制 defaultModuleConfig 结构
// ...（完整的模块数据，因为无法直接 import 独立脚本）

void main() {
  final langs = ['zh', 'en', 'ja', 'ko', 'es', 'fr', 'de', 'pt', 'ru', 'ar', 'hi', 'th'];
  final dir = Directory('assets/cloudData/modules');
  if (!dir.existsSync()) dir.createSync(recursive: true);

  // For each language, write modules_{lang}.json
  // zh and en have real translations, others get machine-translated placeholders
}
```

- [ ] **Step 4: 确认 pubspec.yaml assets 包含 modules 目录**

确保 `pubspec.yaml` 中已有 `- assets/cloudData/modules/`（Task 1 中已添加）。

- [ ] **Step 5: 修改 constants.dart — 移除 defaultModules 硬编码数据**

将 `AppConstants.defaultModules` 的 59 条数据移除，改为一个空列表作为安全兜底。保留 `moduleTypes` 不变（仅作为 schema 索引参考）。

```dart
// 删除整个 defaultModules 的 static const List<Map<String, dynamic>>
// 替换为：
static const List<Map<String, dynamic>> defaultModules = [];
```

- [ ] **Step 6: Commit**

```bash
git add lib/config/constants.dart assets/cloudData/modules/ scripts/
git commit -m "feat(i18n): extract module configs to per-language JSON files"
```

---

### Task 6: 修改 ModuleProvider 和 DataService — 按语言加载模块

**Files:**
- Modify: `lib/providers/module_provider.dart`
- Modify: `lib/services/data_service.dart`

- [ ] **Step 1: 修改 data_service.dart — getModuleConfigs 按语言加载 JSON**

在 `lib/services/data_service.dart` 中修改 `getModuleConfigs`，添加 `locale` 参数并优先从 assets JSON 加载：

```dart
import 'package:flutter/services.dart' show rootBundle;

// 修改方法签名，添加 locale 参数：
Future<List<ModuleConfig>> getModuleConfigs({String locale = 'zh'}) async {
  final cache = await _cache;
  final cacheKey = '${AppConstants.keyModuleConfig}_$locale';

  final cached = cache.getWithExpiry(cacheKey);
  if (cached != null) {
    try {
      final list = jsonDecode(cached) as List<dynamic>;
      return list
          .map((e) => ModuleConfig.fromJson(e as Map<String, dynamic>))
          .toList();
    } catch (e) {
      _logger.e('Cache parse error: $e');
    }
  }

  try {
    final modules = await _loadModulesFromAssets(locale);
    if (modules.isNotEmpty) {
      await cache.setWithExpiry(
        cacheKey,
        jsonEncode(modules.map((e) => e.toJson()).toList()),
        const Duration(hours: AppConstants.cacheExpireHours),
      );
      return modules;
    }
  } catch (e) {
    _logger.e('Asset load error for locale $locale: $e');
  }

  // Fallback to zh
  if (locale != 'zh') {
    return getModuleConfigs(locale: 'zh');
  }

  return AppConstants.defaultModules
      .map((e) => ModuleConfig.fromJson(e))
      .toList();
}

Future<List<ModuleConfig>> _loadModulesFromAssets(String locale) async {
  final path = 'assets/cloudData/modules/modules_$locale.json';
  try {
    final jsonStr = await rootBundle.loadString(path);
    final list = jsonDecode(jsonStr) as List<dynamic>;
    return list
        .map((e) => ModuleConfig.fromJson(e as Map<String, dynamic>))
        .toList();
  } catch (e) {
    _logger.w('Failed to load modules from $path: $e');
    return [];
  }
}
```

- [ ] **Step 2: 修改 module_provider.dart — 传入 locale**

```dart
import 'package:flutter/material.dart';
import '../providers/locale_provider.dart';

// 修改 loadModules 接受 locale 参数：
Future<void> loadModules({String locale = 'zh'}) async {
  _isLoading = true;
  _error = null;
  notifyListeners();

  try {
    _modules = await _dataService.getModuleConfigs(locale: locale);
    _isLoading = false;
    notifyListeners();
  } catch (e) {
    _error = e.toString();
    _isLoading = false;
    notifyListeners();
  }
}
```

- [ ] **Step 3: 在 home_page.dart 传递 locale 调用 loadModules**

在 `_HomePageState._loadData` 中传递 locale：

```dart
Future<void> _loadData() async {
  final mp = context.read<ModuleProvider>();
  final cp = context.read<DailyContentProvider>();
  final localeProvider = context.read<LocaleProvider>();
  if (mp.modules.isEmpty) await mp.loadModules(locale: localeProvider.languageCode);
  for (final m in mp.modules) {
    if (cp.getContent(m.id) == null) cp.loadContent(m);
  }
}
```

- [ ] **Step 4: 运行 flutter analyze 验证**

```bash
flutter analyze
```

Expected: No issues found.

- [ ] **Step 5: Commit**

```bash
git add lib/services/data_service.dart lib/providers/module_provider.dart lib/pages/home_page.dart
git commit -m "feat(i18n): load module configs per locale from JSON assets"
```

---

### Task 7: 迁移所有页面硬编码字符串 → AppLocalizations

**Files:**
- Modify: `lib/pages/home_page.dart`
- Modify: `lib/pages/mine_page.dart`
- Modify: `lib/pages/module_detail_page.dart`
- Modify: `lib/pages/poster_page.dart`
- Modify: `lib/pages/ai_friend_page.dart`
- Modify: `lib/pages/ai_career_page.dart`
- Modify: `lib/pages/ai_career_detail_page.dart`
- Modify: `lib/widgets/daily_card.dart`
- Modify: `lib/widgets/module_grid_item.dart`
- Modify: `lib/models/field_metadata.dart`
- Modify: `lib/providers/theme_provider.dart`

- [ ] **Step 1: 迁移 home_page.dart — 全部硬编码字符串**

需要修改的内容（已有部分在 Task 3 完成，补充剩余）：

```dart
import '../l10n/gen/app_localizations.dart';

// _moduleCategories 使用 ARB key（hotPicks 等）
// '热门精选' → 从模块 JSON 的 categoryField 读取（已是动态），
// 标题保留用模块 JSON 数据，不需要 AppLocalizations

// _sectionTitle 仍接受 title 参数，但调用处改为：
// '更多模块' → AppLocalizations.of(context)!.moreModules

// _aiFriendCard:
// '情感陪伴' → AppLocalizations.of(context)!.emotionalCompanion
// '和"小智"聊聊天，分享你的心情' → AppLocalizations.of(context)!.emotionalCompanionDesc

// _aiCareerCard:
// '领域专家' → AppLocalizations.of(context)!.domainExpert
// '与180+行业专家深度对话，获取专业见解' → AppLocalizations.of(context)!.domainExpertDesc

// _buildFeaturedRow:
// '🔥 ' → 保持不变（emoji 不需要翻译）
// '热门精选' → AppLocalizations.of(context)!.hotPicks

// _dateStr:
// '周一' → AppLocalizations.of(context)!.weekdayMon 等
// '${now.year}年${now.month}月${now.day}日' → 用 intl DateFormat
```

对于日期格式的本地化，需要根据当前 locale 格式化：

```dart
String _dateStr(BuildContext context) {
  final now = DateTime.now();
  final locale = Localizations.localeOf(context);
  
  // 中文用 x年x月x日 格式，其他用标准格式
  if (locale.languageCode == 'zh') {
    final wdKeys = [null, 'weekdayMon', 'weekdayTue', 'weekdayWed', 'weekdayThu', 'weekdayFri', 'weekdaySat', 'weekdaySun'];
    final wdKey = wdKeys[now.weekday];
    final wd = AppLocalizations.of(context)!.lookup(wdKey!);
    return '${now.year}年${now.month}月${now.day}日 $wd';
  }
  // 英文等用 DateFormat
  final fmt = DateFormat('yyyy/MM/dd EEEE', locale.toString());
  return fmt.format(now);
}
```

注意：需要在文件顶部添加 import `'package:intl/intl.dart'` 和 `'package:flutter_localizations/flutter_localizations.dart'`。

- [ ] **Step 2: 迁移 mine_page.dart — 全部硬编码字符串**

所有 Tab 和文字替换为 AppLocalizations 调用。关键修改点：

```dart
import '../l10n/gen/app_localizations.dart';

// AppBar: Text('我的') → Text(AppLocalizations.of(context)!.bottomNavMine)

// 菜单项:
// '主题设置' → AppLocalizations.of(context)!.themeSettings
// '通知提醒' → AppLocalizations.of(context)!.notification
// etc.

// _themeLabel:
// '浅色模式' → AppLocalizations.of(context)!.lightMode
// '深色模式' → AppLocalizations.of(context)!.darkMode
// '跟随系统' → AppLocalizations.of(context)!.followSystem

// 对话框:
// '清除缓存' → AppLocalizations.of(context)!.clearCache
// '确定要清除所有本地缓存数据吗？\n这将清除已保存的内容和设置。' → AppLocalizations.of(context)!.clearCacheConfirm
// etc.
```

- [ ] **Step 3: 迁移 module_detail_page.dart**

```dart
// '模块不存在' → AppLocalizations.of(context)!.moduleNotFound
// '未找到该模块' → AppLocalizations.of(context)!.moduleNotFoundDesc
// '暂无内容' → AppLocalizations.of(context)!.noContent
// '生成中...' → AppLocalizations.of(context)!.generating
// 'AI 换一条' → AppLocalizations.of(context)!.aiRefresh
// 'AI 生成' → AppLocalizations.of(context)!.aiGenerate
// '生成海报' → AppLocalizations.of(context)!.generatePoster
```

- [ ] **Step 4: 迁移 poster_page.dart**

```dart
// '生成海报' → AppLocalizations.of(context)!.generatePoster
// '分享海报' → AppLocalizations.of(context)!.sharePoster
// '处理中...' → AppLocalizations.of(context)!.processing
// '保存相册' → AppLocalizations.of(context)!.saveToAlbum
// '分享' → AppLocalizations.of(context)!.share
// '海报已保存至相册' → AppLocalizations.of(context)!.savedToAlbum
// etc.
```

- [ ] **Step 5: 迁移 ai_friend_page.dart 和 ai_career_detail_page.dart**

```dart
// '小智' → 留在代码中作为机器人 name（不变）
// '删除聊天记录' → AppLocalizations.of(context)!.deleteChatHistory
// '说点什么...' → AppLocalizations.of(context)!.typeHint
// emotion labels → AppLocalizations.of(context)!.emotionHappy etc.
// scene names → AppLocalizations.of(context)!.sceneFirstGreeting etc.
```

- [ ] **Step 6: 迁移 daily_card.dart, module_grid_item.dart, theme_provider.dart**

```dart
// daily_card.dart:
// '暂无内容' → AppLocalizations.of(context)!.noContent
// '换一条' → app 中使用，直接引用已完成
// 'AI 生成' → AppLocalizations.of(context)!.aiGenerate

// theme_provider.dart:
// 移除 modeLabel getter（不再需要硬编码字符串）
// 或改为接受 BuildContext 参数使用 AppLocalizations
```

- [ ] **Step 7: 运行 flutter analyze**

```bash
flutter analyze
```

Expected: No issues found.

- [ ] **Step 8: Commit**

```bash
git add lib/pages/ lib/widgets/ lib/models/ lib/providers/theme_provider.dart
git commit -m "feat(i18n): migrate all UI strings to AppLocalizations"
```

---

### Task 8: 服务层 — AI 服务传递语言参数

**Files:**
- Modify: `lib/services/ai_service.dart`
- Modify: `lib/providers/daily_content_provider.dart`

- [ ] **Step 1: ai_service.dart — generateContent 添加 locale 参数**

修改 `generateContent` 方法签名和 `_callHunyuanModel` 传递：

```dart
Future<DailyContent> generateContent({
  required String moduleId,
  required String prompt,
  required List<FallbackContent> fallback,
  String locale = 'zh', // 新增
}) async {
  // ... existing code
  final response = await _callHunyuanModel(moduleId, prompt, locale: locale);
  // ...
}

Future<Map<String, dynamic>?> _callHunyuanModel(
  String moduleId,
  String prompt, {
  String locale = 'zh', // 新增
}) async {
  // ...
  // 修改 userMessage 包含语言指令：
  var userMessage = locale == 'zh' 
    ? '生成今日内容' 
    : 'Generate today content in ${_localeName(locale)} language';
  
  // 在 system prompt 中添加语言指令：
  if (locale != 'zh') {
    systemPrompt = '$systemPrompt\n\n【语言要求】请使用${_localeName(locale)}输出所有内容。';
  }
  // ...
}

String _localeName(String locale) => switch (locale) {
  'en' => '英文',
  'ja' => '日文',
  'ko' => '韩文',
  'es' => '西班牙语',
  'fr' => '法语',
  'de' => '德语',
  'pt' => '葡萄牙语',
  'ru' => '俄语',
  'ar' => '阿拉伯语',
  'hi' => '印地语',
  'th' => '泰语',
  _ => '中文',
};
```

- [ ] **Step 2: daily_content_provider.dart — refreshWithAi 传入 locale**

```dart
Future<void> refreshWithAi(ModuleConfig module) async {
  // ...
  final localeProvider = // 需要获取 LocaleProvider
  final content = await _aiService.generateContent(
    moduleId: module.id,
    prompt: prompt,
    fallback: fallback,
    locale: localeProvider.languageCode,  // 新增
  );
  // ...
}
```

由于 DailyContentProvider 没有 BuildContext，这里有两种方式：
1. 在调用方（页面）传入 locale
2. DailyContentProvider 持有 LocaleProvider 引用

采用方式 2，在构造时传入或使用 BuildContext：

修改 `refreshWithAi` 添加 `locale` 参数：

```dart
Future<void> refreshWithAi(ModuleConfig module, {String locale = 'zh'}) async {
  // ...
}
```

在 `home_page.dart` 和 `module_detail_page.dart` 调用处传入 locale：

```dart
cp.refreshWithAi(fm, locale: localeProvider.languageCode);
```

- [ ] **Step 3: Commit**

```bash
git add lib/services/ai_service.dart lib/providers/daily_content_provider.dart
git commit -m "feat(i18n): pass locale parameter to AI service for language-aware content generation"
```

---

### Task 9: 其余 10 种语言 ARB 机器翻译生成

**Files:**
- Modify: `lib/l10n/app_ja.arb` ~ `lib/l10n/app_th.arb`（10 个文件）

- [ ] **Step 1: 创建翻译脚本 generate_arb_translations.dart**

由于手动创建 10 种语言 × ~183 条 = ~1830 条翻译工作量太大，创建一个 Dart 脚本使用内置翻译映射生成初版：

```dart
// scripts/generate_arb_translations.dart
// 以英文 ARB 为源，用预定义的翻译映射生成 10 个语言的 ARB 文件
// 运行: dart run scripts/generate_arb_translations.dart

import 'dart:convert';
import 'dart:io';

void main() {
  // 读取英文 ARB 作为模板
  final enFile = File('lib/l10n/app_en.arb');
  final enJson = jsonDecode(enFile.readAsStringSync()) as Map<String, dynamic>;
  
  final locales = ['ja', 'ko', 'es', 'fr', 'de', 'pt', 'ru', 'ar', 'hi', 'th'];
  
  for (final locale in locales) {
    final target = Map<String, dynamic>.from(enJson);
    target['@@locale'] = locale;
    // 为非 @@ 和 @ 元数据之外的 key 生成机器翻译占位
    // 这里实际执行时用内置映射表或调用翻译 API
    // 初版先使用 "[LC] ${enJson[key]}" 标记为待翻译
    
    final outFile = File('lib/l10n/app_$locale.arb');
    outFile.writeAsStringSync(const JsonEncoder.withIndent('  ').convert(target));
  }
}
```

- [ ] **Step 2: 用内置翻译映射表生成 10 种语言完整 ARB**

由于篇幅限制，实际执行时使用一个静态映射表将英文 value 翻译到对应语言。关键值示例：

```
ja: { "appName": "PocketMind", "bottomNavHome": "ホーム", "cancel": "キャンセル", ... }
ko: { "appName": "PocketMind", "bottomNavHome": "홈", "cancel": "취소", ... }
es: { "appName": "PocketMind", "bottomNavHome": "Inicio", "cancel": "Cancelar", ... }
...
```

- [ ] **Step 3: 运行 flutter gen-l10n 验证**

```bash
flutter gen-l10n
flutter analyze
```

- [ ] **Step 4: Commit**

```bash
git add lib/l10n/app_ja.arb lib/l10n/app_ko.arb lib/l10n/app_es.arb lib/l10n/app_fr.arb lib/l10n/app_de.arb lib/l10n/app_pt.arb lib/l10n/app_ru.arb lib/l10n/app_ar.arb lib/l10n/app_hi.arb lib/l10n/app_th.arb scripts/
git commit -m "feat(i18n): add machine-translated ARB files for 10 additional languages"
```

---

### Task 10: XUI 页面本地化

**Files:**
- Modify: `lib/xui/pages/home.dart`
- Modify: `lib/xui/pages/collections_grid.dart`
- Modify: `lib/xui/pages/collections_list.dart`
- Modify: `lib/xui/pages/experts.dart`
- Modify: `lib/xui/pages/expert_detail.dart`
- Modify: `lib/xui/pages/search_result.dart`
- Modify: `lib/xui/pages/ai_chat_page.dart`
- Modify: `lib/xui/pages/ai_hero.dart`
- Modify: `lib/xui/pages/poster_preview.dart`

- [ ] **Step 1: 逐文件添加 import 并替换字符串**

每个文件添加：
```dart
import '../../l10n/gen/app_localizations.dart';
```

然后替换所有硬编码中文字符串为 `AppLocalizations.of(context)!.xxx`。

关键修改点：

`lib/xui/pages/home.dart`（~35 个字符串）:
```dart
// '智伴口袋' → AppLocalizations.of(context)!.appName
// '快捷入口' → AppLocalizations.of(context)!.quickEntry
// '热门问题' → AppLocalizations.of(context)!.hotQuestions
// '行情趋势' → AppLocalizations.of(context)!.marketTrends
// etc.
```

`lib/xui/pages/collections_grid.dart`:
```dart
// '助手广场' → AppLocalizations.of(context)!.assistantSquare
// '没有更多数据' → AppLocalizations.of(context)!.noMoreData
// '加载更多' → AppLocalizations.of(context)!.loadingMore
```

`lib/xui/pages/search_result.dart`:
```dart
// 'AI 分析结果' → AppLocalizations.of(context)!.aiAnalysis
// '继续提问...' → AppLocalizations.of(context)!.searchHint
// '分析' → AppLocalizations.of(context)!.analyze
```

`lib/xui/pages/ai_hero.dart`:
```dart
// '材料 AI 智能助手' → AppLocalizations.of(context)!.aiMaterialHero
// etc.
```

所有其他 xui 页面同模式替换。

- [ ] **Step 2: 运行 flutter analyze**

```bash
flutter analyze
```

- [ ] **Step 3: Commit**

```bash
git add lib/xui/
git commit -m "feat(i18n): localize all XUI pages"
```

---

### Task 11: 模块 JSON 10 种语言翻译 & AI 模块 prompt 翻译

**Files:**
- Modify: `assets/cloudData/modules/modules_ja.json` ~ `modules_th.json`（10 个文件）

- [ ] **Step 1: 创建 modules JSON 翻译脚本**

以 `modules_en.json` 为源，为 ja/ko/es/fr/de/pt/ru/ar/hi/th 生成对应 JSON：

```dart
// scripts/translate_modules.dart
// 读取 modules_en.json，用预定义翻译映射生成 10 个语言的 modules JSON
```

- [ ] **Step 2: 执行脚本并验证 JSON 格式**

```bash
dart run scripts/translate_modules.dart
```

验证每个 JSON 文件格式正确，60 个模块一个不少。

- [ ] **Step 3: Commit**

```bash
git add assets/cloudData/modules/
git commit -m "feat(i18n): add translated module configs for 10 additional languages"
```

---

### Task 12: 验证 & 最终清理

**Files:** 无新建，验证所有已修改文件

- [ ] **Step 1: 运行 flutter gen-l10n 确认所有语言生成成功**

```bash
flutter gen-l10n
```

- [ ] **Step 2: 运行 flutter analyze 确认全量编译通过**

```bash
flutter analyze
```

Expected: No issues found.

- [ ] **Step 3: 运行 flutter build apk --debug 确认构建成功**

```bash
flutter build apk --debug
```

- [ ] **Step 4: 手动验证清单**

- [ ] 中文 (zh) 环境 — 所有页面文字正确（应完全不变）
- [ ] 英文 (en) 环境 — 所有页面英文翻译正确，无中文残留
- [ ] 阿拉伯语 (ar) 环境 — RTL 布局正确，文字反向排列，UI 不错位
- [ ] 任意不支持语言（如 vi）— 回退到中文

- [ ] **Step 5: ARB 文件翻译一致性检查**

运行脚本检查所有 12 个 ARB 文件的 key 集合完全一致：

```bash
dart run scripts/check_arb_consistency.dart
```

- [ ] **Step 6: Commit**

```bash
git add -A
git commit -m "chore(i18n): final verification and cleanup"
```

---

## 翻译资源

以下为关键 UI 字符串在其余 10 种语言的翻译参考（其余字符串同模式处理）：

| Key | ja | ko | es | pt | fr | de | ru | ar | hi | th |
|-----|----|----|----|----|----|----|----|----|----|----|
| cancel | キャンセル | 취소 | Cancelar | Cancelar | Annuler | Abbrechen | Отмена | إلغاء | रद्द करें | ยกเลิก |
| confirm | 確認 | 확인 | Aceptar | Confirmar | Confirmer | Bestätigen | Подтвердить | تأكيد | पुष्टि करें | ยืนยัน |
| save | 保存 | 저장 | Guardar | Salvar | Sauvegarder | Speichern | Сохранить | حفظ | सहेजें | บันทึก |
| delete | 削除 | 삭제 | Eliminar | Excluir | Supprimer | Löschen | Удалить | حذف | हटाएं | ลบ |
| share | 共有 | 공유 | Compartir | Compartilhar | Partager | Teilen | Поделиться | مشاركة | साझा करें | แชร์ |
| home | ホーム | 홈 | Inicio | Início | Accueil | Startseite | Главная | الرئيسية | होम | หน้าแรก |
| settings | 設定 | 설정 | Ajustes | Configurações | Paramètres | Einstellungen | Настройки | الإعدادات | सेटिंग्स | การตั้งค่า |
| loading | 読み込み中... | 로딩 중... | Cargando... | Carregando... | Chargement... | Laden... | Загрузка... | جار التحميل... | लोड हो रहा है... | กำลังโหลด... |

