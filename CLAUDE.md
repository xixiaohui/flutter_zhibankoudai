# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Build / Run / Test

```bash
# Run on connected device/emulator
flutter run

# Build APK (release)
flutter build apk --release

# Build iOS
flutter build ios --release

# Analyze (lint)
flutter analyze

# Run tests (none currently exist)
flutter test
```

## Architecture Overview

This is **智伴口袋 (ZhiBanKouDai)** — a Flutter content-aggregation app delivering daily expert content across 60+ topic modules (quotes, psychology, finance, programming, SEO, etc.). It was migrated from a WeChat Mini Program and uses **Tencent CloudBase** as its backend.

### State Management & Routing

- **Provider** (`lib/providers/`): `ModuleProvider` manages module configs; `DailyContentProvider` manages per-module daily content with caching and AI generation.
- **go_router** (`lib/config/routes.dart`): `ShellRoute` wraps home/discover/agent/mine tabs in a `MainShell` with a `BottomNavigationBar`. Detail and poster pages live outside the shell.
- App entry (`lib/main.dart`) wraps everything in a `MultiProvider` with the two providers above.

### Data Flow (Content Loading)

```
1. Check in-memory cache (_contents map) → return if found
2. Check SharedPreferences cache (24h expiry) → return if valid  
3. Fetch from CloudBase cloud DB → cache locally and return
4. Call AI model (Hunyuan via CloudBase) → cache + persist to cloud DB + return
5. Use fallback data (shipped in assets or hardcoded in AppConstants) → return
```

The AI service (`lib/services/ai_service.dart`) has a cascading prompt strategy: tries local JSON prompts first, then cloud prompts, then system prompt.

### Config-Driven Module System

Modules are defined in two parallel places:
- **`lib/config/constants.dart`** `AppConstants.defaultModules` — hardcoded fallback with id/name/icon/color/generate prompt
- **`lib/xui/utils/module.dart`** `defaultModuleConfig` — richer config with storage keys, CloudBase collection names, poster types, slogans (this is the more complete one used by AI service for DB writes)

Module content JSON files live at `assets/cloudData/modules/*.json` with per-module fallback data arrays. AI prompts live at `assets/cloudData/prompts/aiPrompts.json`.

### Services Layer (`lib/services/`)

| File | Role |
|------|------|
| `cloudbase_client.dart` | HTTP client for Tencent CloudBase API (env-configured, JWT auth) |
| `cloudbase_ai.dart` | Calls Hunyuan model via CloudBase AI gateway (stream + non-stream) |
| `cloudbase_db.dart` | CloudBase DB operations (addData, callFunction) |
| `cloudbase_file.dart` | Fetches `aiPrompts.json` from CloudBase storage, parses into `AiPromptsConfig` |
| `cache_service.dart` | `SharedPreferences` wrapper with TTL expiry |
| `data_service.dart` | Singleton orchestrating module config + daily content cache/cloud flow |
| `ai_service.dart` | Content generation with cascade prompt resolution, JSON parsing, fallback |
| `local_config.dart` | Loads `aiPrompts.json` from local assets |

### Design System (Clay-Inspired)

Two parallel theme files both implementing a warm, artisanal Clay design language:
- **`lib/config/theme.dart`** (`AppTheme`): warm cream background (`#faf9f7`), oat borders, multi-layer inset shadows, named swatch palette (Matcha, Slushie, Lemon, Ube, etc.), used by main app pages
- **`lib/xui/x_design.dart`** (`XuiTheme`): duplicate palette + typography scale + `ClayContainer` widget with hover rotation/translation animations

Key design tokens: 24px card radius, light/dark theme support, `NotoSansSC-Bold` primary font.

### Directory Layout

```
lib/
├── main.dart                  # App entry, MultiProvider + MaterialApp.router
├── config/
│   ├── routes.dart            # go_router config with ShellRoute
│   ├── theme.dart             # AppTheme — Clay design tokens
│   ├── constants.dart         # App-wide constants + hardcoded fallback modules
│   └── env.dart               # Compile-time env vars (API_URL, etc.)
├── models/
│   ├── module_config.dart     # ModuleConfig, FallbackContent, ShareConfig
│   └── daily_content.dart     # DailyContent model
├── providers/
│   ├── module_provider.dart   # Module list state
│   └── daily_content_provider.dart  # Per-module content + AI refresh
├── services/                  # (see table above)
├── pages/
│   ├── home_page.dart         # Main feed: hero card + module grid
│   ├── module_detail_page.dart # Module detail with markdown + AI refresh
│   ├── poster_page.dart       # Screenshot-based poster generation + share
│   └── mine_page.dart         # User profile page
├── widgets/
│   ├── daily_card.dart        # Colored hero card with content + actions
│   ├── module_grid_item.dart  # Grid module tile
│   ├── clay_card.dart / clay_button.dart
│   └── ...
└── xui/
    ├── x_design.dart          # XuiTheme + ClayContainer
    ├── pages/                 # Additional pages (ai_chat, home, poster, etc.)
    └── utils/module.dart      # Extended Module model + defaultModuleConfig
```

### Environment

The `.env` file at the project root (included in Flutter assets) provides CloudBase credentials:
```
CLOUDBASE_ENV_ID=<env-id>
CLOUDBASE_ACCESS_TOKEN=<jwt-token>
```

A companion Node.js server lives in `ai-server/` for server-side operations.
