# Phase 1: Design System Unification — Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Eliminate 3 parallel design systems (AppTheme, AppThemeData, XuiTheme), unify into single `lib/design/` token system.

**Architecture:** Add missing tokens to `AppColors` + `AppTypography`, replace all legacy references across 20+ files, extract `ClayContainer` as standalone widget, delete `lib/config/theme.dart` and XuiTheme from `lib/xui/x_design.dart`.

**Tech Stack:** Flutter/Dart, Material 3 Design Tokens, existing `lib/design/` module

**Design doc:** `docs/superpowers/specs/2026-05-14-zhiban-refactor-design.md`

---

## File Map

| Action | File | Responsibility |
|--------|------|----------------|
| Modify | `lib/design/colors.dart` | Add `fromHex()`, migrate AppTheme unique palette (matcha, slushie, lemon, ube, pomegranate, blueberry, oat, warmSilver etc.), add semantic aliases |
| Delete | `lib/config/theme.dart` | Old AppTheme — remove after all references migrated |
| Modify | `lib/xui/x_design.dart` | Strip XuiTheme class, keep only `ClayContainer` + `SectionTitle` with migrated token references |
| Modify | `lib/pages/home_page.dart` | Replace `_fromHex` with `AppColors.fromHex` |
| Modify | `lib/pages/module_detail_page.dart` | Replace `_fromHex` with `AppColors.fromHex` |
| Modify | `lib/widgets/daily_card.dart` | Replace `_fromHex` with `AppColors.fromHex` |
| Modify | `lib/widgets/module_grid_item.dart` | Replace `_fromHex` with `AppColors.fromHex` |
| Modify | `lib/pages/ai_career_page.dart` | Replace AppTheme + XuiTheme references |
| Modify | `lib/pages/poster_page.dart` | Replace AppTheme references |
| Modify | `lib/xui/pages/collections_list.dart` | Replace AppTheme + XuiTheme references |
| Modify | `lib/xui/pages/collections_grid.dart` | Replace AppTheme + XuiTheme references |
| Modify | `lib/xui/pages/home.dart` | Replace XuiTheme references |
| Modify | `lib/xui/pages/ai_chat_page.dart` | Replace XuiTheme references |
| Modify | `lib/xui/pages/ai_hero.dart` | Replace XuiTheme references |
| Modify | `lib/xui/pages/experts.dart` | Replace XuiTheme references |
| Modify | `lib/xui/pages/expert_detail.dart` | Replace XuiTheme references |
| Modify | `lib/xui/pages/search_result.dart` | Replace XuiTheme references |
| Modify | `lib/xui/pages/poster_widget.dart` | Replace XuiTheme references |
| Modify | `lib/xui/pages/poster_preview.dart` | Replace XuiTheme references |

---

### Task 1: Add unified tokens and `fromHex()` to AppColors

**Files:**
- Modify: `lib/design/colors.dart`

**Strategy:** `AppColors` becomes the single source of truth for all color tokens. We add:
1. `fromHex()` static method (the 4 duplicated `_fromHex` functions go away)
2. Unique palette colors from AppTheme that AppColors doesn't have (matcha, slushie, lemon, ube, pomegranate, blueberry, oatBorder, oatLight, warmSilver, warmCharcoal, darkCharcoal, lightFrost, focusRing, ghostBorder, dragonfruit, badgeBlueBg, badgeBlueText)
3. Semantic aliases that map old names to new tokens (pureWhite → surface, warmCream → background, clayBlack → foreground)

- [ ] **Step 1: Add `fromHex()` and palette extensions to AppColors**

Read the current file at `lib/design/colors.dart`. Add the following after the existing `darkScheme`:

```dart
  /// Parse hex color string (with or without #)
  static Color fromHex(String hexString) {
    final buffer = StringBuffer();
    if (hexString.length == 6 || hexString.length == 7) buffer.write('ff');
    buffer.write(hexString.replaceFirst('#', ''));
    return Color(int.parse(buffer.toString(), radix: 16));
  }

  // ── Extended Palette (from legacy AppTheme) ──
  static const Color matcha300 = Color(0xFF84e7a5);
  static const Color matcha600 = Color(0xFF078a52);
  static const Color matcha800 = Color(0xFF02492a);
  static const Color slushie500 = Color(0xFF3bd3fd);
  static const Color slushie800 = Color(0xFF0089ad);
  static const Color lemon400 = Color(0xFFf8cc65);
  static const Color lemon500 = Color(0xFFfbbd41);
  static const Color lemon700 = Color(0xFFd08a11);
  static const Color lemon800 = Color(0xFF9d6a09);
  static const Color ube100 = Color(0xFFE9E2FF);
  static const Color ube200 = Color(0xFFD8CBFF);
  static const Color ube300 = Color(0xFFc1b0ff);
  static const Color ube800 = Color(0xFF43089f);
  static const Color ube900 = Color(0xFF32037d);
  static const Color pomegranate400 = Color(0xFFfc7981);
  static const Color blueberry800 = Color(0xFF01418d);
  static const Color oatBorder = Color(0xFFdad4c8);
  static const Color oatLight = Color(0xFFeee9df);
  static const Color warmSilver = Color(0xFF9f9b93);
  static const Color warmCharcoal = Color(0xFF55534e);
  static const Color darkCharcoal = Color(0xFF333333);
  static const Color lightFrost = Color(0xFFeff1f3);
  static const Color focusRing = Color(0xFF146EF5);
  static const Color ghostBorder = Color(0xFF717989);
  static const Color dragonfruit = Color(0xFFfc7981);
  static const Color badgeBlueBg = Color(0xFFf0f8ff);
  static const Color badgeBlueText = Color(0xFF3859f9);
  static const Color darkBorderVisible = Color(0xFF525a69);

  // ── Semantic aliases (backward compat) ──
  static const Color pureWhite = surface;
  static const Color warmCream = background;
  static const Color clayBlack = foreground;
```

- [ ] **Step 2: Run flutter analyze to verify no new issues**

```bash
cd e:/workspace/claw/zhiban/flutter_application_zhiban && flutter analyze lib/design/colors.dart
```

Expected: No new errors (only pre-existing issues in other files).

- [ ] **Step 3: Commit**

```bash
git add lib/design/colors.dart
git commit -m "refactor(design): add fromHex() and legacy palette to AppColors"
```

---

### Task 2: Replace duplicated `_fromHex` with `AppColors.fromHex`

**Files:**
- Modify: `lib/pages/home_page.dart`
- Modify: `lib/pages/module_detail_page.dart`
- Modify: `lib/widgets/daily_card.dart`
- Modify: `lib/widgets/module_grid_item.dart`
- Modify: `lib/xui/pages/collections_list.dart`
- Modify: `lib/xui/pages/collections_grid.dart`

- [ ] **Step 1: Fix home_page.dart**

In `lib/pages/home_page.dart`:
- Add import: `import '../design/colors.dart';`
- Replace line 377-382 (the private `_fromHex` method) — delete it entirely
- Replace line 171 `final c = _fromHex(m.color);` → `final c = AppColors.fromHex(m.color);`

- [ ] **Step 2: Fix module_detail_page.dart**

In `lib/pages/module_detail_page.dart`:
- Add import: `import '../design/colors.dart';`
- Replace line 36-41 (the private `_fromHex` method) — delete it entirely
- Replace line 57 `final mc = _fromHex(module.color);` → `final mc = AppColors.fromHex(module.color);`

- [ ] **Step 3: Fix daily_card.dart**

In `lib/widgets/daily_card.dart`:
- Add import: `import '../design/colors.dart';`
- Replace line 28-33 (the private `_fromHex` method) — delete it entirely
- Replace line 38 `final moduleColor = _fromHex(module.color);` → `final moduleColor = AppColors.fromHex(module.color);`

- [ ] **Step 4: Fix module_grid_item.dart**

In `lib/widgets/module_grid_item.dart`:
- Add import: `import '../design/colors.dart';`
- Replace line 13-18 (the private `_fromHex` method) — delete it entirely
- Replace line 24 `final moduleColor = _fromHex(module.color);` → `final moduleColor = AppColors.fromHex(module.color);`

- [ ] **Step 5: Fix collections_list.dart and collections_grid.dart**

Both files already import `config/theme.dart` and call `AppTheme.fromHex()`. Change to import `design/colors.dart` and call `AppColors.fromHex()`.

In `lib/xui/pages/collections_list.dart`:
- Replace `import 'package:flutter_application_zhiban/config/theme.dart';` → `import 'package:flutter_application_zhiban/design/colors.dart';`
- Replace all `AppTheme.fromHex(...)` → `AppColors.fromHex(...)`

In `lib/xui/pages/collections_grid.dart`:
- Replace `import 'package:flutter_application_zhiban/config/theme.dart';` → `import 'package:flutter_application_zhiban/design/colors.dart';`
- Replace all `AppTheme.fromHex(...)` → `AppColors.fromHex(...)`

- [ ] **Step 6: Run flutter analyze**

```bash
cd e:/workspace/claw/zhiban/flutter_application_zhiban && flutter analyze
```

Expected: No errors related to `_fromHex` or `fromHex`.

- [ ] **Step 7: Commit**

```bash
git add lib/pages/home_page.dart lib/pages/module_detail_page.dart lib/widgets/daily_card.dart lib/widgets/module_grid_item.dart lib/xui/pages/collections_list.dart lib/xui/pages/collections_grid.dart
git commit -m "refactor: replace duplicated _fromHex with AppColors.fromHex"
```

---

### Task 3: Migrate AppTheme references to AppColors

**Files:**
- Modify: `lib/pages/ai_career_page.dart`
- Modify: `lib/pages/poster_page.dart`

**Strategy:** Map each `AppTheme.xxx` to its `AppColors.xxx` equivalent. Since we added semantic aliases in Task 1, `AppTheme.pureWhite` → `AppColors.pureWhite`, `AppTheme.warmCream` → `AppColors.warmCream`, etc.

- [ ] **Step 1: Fix ai_career_page.dart**

Replace import `import '../config/theme.dart';` → `import '../design/colors.dart';`
Then replace all `AppTheme.xxx` → `AppColors.xxx` (all used tokens have aliases in Task 1):
- `AppTheme.warmCream` → `AppColors.warmCream`
- `AppTheme.pureWhite` → `AppColors.pureWhite`
- `AppTheme.clayBlack` → `AppColors.clayBlack`
- `AppTheme.oatLight` → `AppColors.oatLight`
- `AppTheme.oatBorder` → `AppColors.oatBorder`
- `AppTheme.warmCharcoal` → `AppColors.warmCharcoal`
- `AppTheme.warmSilver` → `AppColors.warmSilver`
- `AppTheme.radiusPill` → `AppRadius.pill` (add import for `../design/radius.dart`)
- `AppTheme.radiusCard` → `AppRadius.card`
- `AppTheme.clayShadow` → `AppElevation.card` (add import for `../design/elevation.dart`)

- [ ] **Step 2: Fix poster_page.dart**

Replace import `import '../config/theme.dart';` → `import '../design/colors.dart';` `import '../design/radius.dart';` `import '../design/elevation.dart';`

Map all `AppTheme.xxx` → new token:
- Colors: `AppTheme.pureWhite` → `AppColors.pureWhite`, etc.
- Radius: `AppTheme.radiusXxx` → `AppRadius.xxx`
- Shadows: `AppTheme.clayShadow` → `AppElevation.card`

- [ ] **Step 3: Run flutter analyze**

```bash
cd e:/workspace/claw/zhiban/flutter_application_zhiban && flutter analyze
```

- [ ] **Step 4: Commit**

```bash
git add lib/pages/ai_career_page.dart lib/pages/poster_page.dart
git commit -m "refactor: migrate AppTheme references to AppColors in pages"
```

---

### Task 4: Delete old AppTheme file

**Files:**
- Delete: `lib/config/theme.dart`

- [ ] **Step 1: Verify no remaining imports**

```bash
cd e:/workspace/claw/zhiban/flutter_application_zhiban && grep -r "config/theme.dart" lib/ || echo "No remaining imports"
```

- [ ] **Step 2: Delete the file**

```bash
rm lib/config/theme.dart
```

- [ ] **Step 3: Run flutter analyze**

```bash
cd e:/workspace/claw/zhiban/flutter_application_zhiban && flutter analyze
```

- [ ] **Step 4: Commit**

```bash
git rm lib/config/theme.dart
git commit -m "refactor: remove legacy AppTheme (unified into design/)"
```

---

### Task 5: Migrate XuiTheme references to AppColors + AppTypography

**Files:**
- Modify: `lib/xui/pages/home.dart`
- Modify: `lib/xui/pages/ai_chat_page.dart`
- Modify: `lib/xui/pages/ai_hero.dart`
- Modify: `lib/xui/pages/experts.dart`
- Modify: `lib/xui/pages/expert_detail.dart`
- Modify: `lib/xui/pages/search_result.dart`
- Modify: `lib/xui/pages/poster_widget.dart`
- Modify: `lib/xui/pages/poster_preview.dart`
- Modify: `lib/xui/pages/collections_list.dart`
- Modify: `lib/xui/pages/collections_grid.dart`

**Strategy:** All colors map via semantic aliases added in Task 1. Typography: `XuiTheme.bodyStd()` → `AppTypography.textTheme.bodyMedium`, etc. `ClayContainer` uses will be handled in Task 6.

**Token mapping table:**

| XuiTheme token | Replacement |
|---|---|
| `XuiTheme.warmCream` | `AppColors.warmCream` |
| `XuiTheme.pureWhite` | `AppColors.pureWhite` |
| `XuiTheme.clayBlack` | `AppColors.clayBlack` |
| `XuiTheme.oatBorder` | `AppColors.oatBorder` |
| `XuiTheme.oatLight` | `AppColors.oatLight` |
| `XuiTheme.slushie500` | `AppColors.slushie500` |
| `XuiTheme.slushie800` | `AppColors.slushie800` |
| `XuiTheme.ube300` | `AppColors.ube300` |
| `XuiTheme.ube800` | `AppColors.ube800` |
| `XuiTheme.ube900` | `AppColors.ube900` |
| `XuiTheme.blueberry800` | `AppColors.blueberry800` |
| `XuiTheme.lemon500` | `AppColors.lemon500` |
| `XuiTheme.lemon700` | `AppColors.lemon700` |
| `XuiTheme.pomegranate400` | `AppColors.pomegranate400` |
| `XuiTheme.warmSilver` | `AppColors.warmSilver` |
| `XuiTheme.warmCharcoal` | `AppColors.warmCharcoal` |
| `XuiTheme.darkCharcoal` | `AppColors.darkCharcoal` |
| `XuiTheme.lightFrost` | `AppColors.lightFrost` |
| `XuiTheme.focusRing` | `AppColors.focusRing` |
| `XuiTheme.ghostBorder` | `AppColors.ghostBorder` |
| `XuiTheme.dragonfruit` | `AppColors.dragonfruit` |
| `XuiTheme.darkBorder` | `AppColors.darkBorderVisible` |
| `XuiTheme.badgeBlueBg` | `AppColors.badgeBlueBg` |
| `XuiTheme.badgeBlueText` | `AppColors.badgeBlueText` |
| `XuiTheme.clayShadow` | `AppElevation.card` |
| `XuiTheme.cardDecoration(...)` | Replace with manual `BoxDecoration` using AppColors |
| `XuiTheme.inputDecoration(...)` | Replace with `InputDecoration` using AppColors |
| `XuiTheme.bodyStd()` | `Theme.of(context).textTheme.bodyMedium` or `AppTypography.textTheme.bodyMedium` |
| `XuiTheme.body()` | `Theme.of(context).textTheme.bodyLarge` |
| `XuiTheme.bodyMed()` | `Theme.of(context).textTheme.titleSmall` |
| `XuiTheme.bodyLarge()` | `Theme.of(context).textTheme.bodyLarge` |
| `XuiTheme.featureTitle()` | `Theme.of(context).textTheme.titleMedium` |
| `XuiTheme.subHeading()` | `Theme.of(context).textTheme.titleSmall` |
| `XuiTheme.displayHero()` | `AppTypography.textTheme.headlineLarge` |
| `XuiTheme.sectionHeading()` | `AppTypography.textTheme.headlineMedium` |
| `XuiTheme.cardHeading()` | `AppTypography.textTheme.headlineSmall` |
| `XuiTheme.uppercaseLabel()` | `AppTypography.textTheme.labelMedium` |
| `XuiTheme.badge()` | `AppTypography.textTheme.labelSmall` |

- [ ] **Step 1: Fix xui/pages/home.dart**

Replace import:
```dart
import 'package:flutter_application_zhiban/xui/x_design.dart' as xui;
```
→
```dart
import 'package:flutter_application_zhiban/design/colors.dart';
import 'package:flutter_application_zhiban/design/typography.dart';
import 'package:flutter_application_zhiban/design/elevation.dart';
```

Then replace all `xui.XuiTheme.xxx` references using the mapping table above.

For `xui.XuiTheme.cardDecoration(...)` calls (line 79-81):
```dart
// Before
decoration: xui.XuiTheme.cardDecoration(
  color: xui.XuiTheme.pureWhite,
  radius: 24,
),
// After
decoration: BoxDecoration(
  color: AppColors.pureWhite,
  borderRadius: BorderRadius.circular(24),
  border: Border.all(color: AppColors.oatBorder, width: 1),
  boxShadow: AppElevation.card,
),
```

For `xui.XuiTheme.inputDecoration(...)` calls — construct `InputDecoration` directly using `AppColors` tokens.

- [ ] **Step 2: Fix xui/pages/ai_chat_page.dart**

Same pattern: replace import, map all `xui.XuiTheme.xxx` → new tokens.

- [ ] **Step 3: Fix xui/pages/ai_hero.dart**

Same pattern.

- [ ] **Step 4: Fix xui/pages/experts.dart**

Same pattern.

- [ ] **Step 5: Fix xui/pages/expert_detail.dart**

Same pattern.

- [ ] **Step 6: Fix xui/pages/search_result.dart**

Same pattern.

- [ ] **Step 7: Fix xui/pages/poster_widget.dart**

Same pattern.

- [ ] **Step 8: Fix xui/pages/poster_preview.dart**

Same pattern.

- [ ] **Step 9: Fix xui/pages/collections_list.dart**

Already partially migrated in Task 2 (import changed to `design/colors.dart`). Now replace remaining `xui.XuiTheme.xxx` references.

- [ ] **Step 10: Fix xui/pages/collections_grid.dart**

Same as collections_list.

- [ ] **Step 11: Run flutter analyze**

```bash
cd e:/workspace/claw/zhiban/flutter_application_zhiban && flutter analyze
```

Expected: Zero errors from xui pages.

- [ ] **Step 12: Commit**

```bash
git add lib/xui/pages/
git commit -m "refactor: migrate xui pages from XuiTheme to AppColors"
```

---

### Task 6: Extract ClayContainer and strip XuiTheme

**Files:**
- Create: `lib/widgets/clay_container.dart`
- Modify: `lib/xui/x_design.dart` → strip to re-export only

**Strategy:** Move `ClayContainer` and `SectionTitle` to `lib/widgets/`. Strip `lib/xui/x_design.dart` of XuiTheme class (keep only what xui pages still need during transition, or delete entirely if nothing remains).

- [ ] **Step 1: Create lib/widgets/clay_container.dart**

Extract `ClayContainer` and `SectionTitle` classes from `lib/xui/x_design.dart`. Rewrite to use `AppColors` tokens instead of `XuiTheme`:

```dart
import 'package:flutter/material.dart';
import '../design/colors.dart';
import '../design/elevation.dart';

class ClayContainer extends StatefulWidget {
  final Widget child;
  final VoidCallback? onTap;
  final bool isButton;
  final double borderRadius;
  final Color? color;
  final EdgeInsetsGeometry? padding;
  final bool dashed;
  final BoxBorder? customBorder;

  const ClayContainer({
    super.key,
    required this.child,
    this.onTap,
    this.isButton = false,
    this.borderRadius = 24,
    this.color,
    this.padding,
    this.dashed = false,
    this.customBorder,
  });

  @override
  State<ClayContainer> createState() => _ClayContainerState();
}

class _ClayContainerState extends State<ClayContainer> {
  bool _hover = false;
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    final matrix = Matrix4.identity();
    if (_hover && widget.onTap != null) {
      final dy = widget.isButton ? -8.0 : -4.0;
      if (widget.isButton) {
        matrix
          ..translateByDouble(0.0, dy, 0.0, 1.0)
          ..rotateZ(-0.14);
      } else {
        matrix.translateByDouble(0.0, dy, 0.0, 1.0);
      }
    }
    if (_pressed && widget.onTap != null) {
      matrix.scaleByDouble(0.985, 0.985, 1.0, 1.0);
    }

    return MouseRegion(
      onEnter: (_) => setState(() => _hover = true),
      onExit: (_) => setState(() => _hover = false),
      child: GestureDetector(
        onTap: widget.onTap,
        onTapDown: widget.onTap == null ? null : (_) => setState(() => _pressed = true),
        onTapCancel: widget.onTap == null ? null : () => setState(() => _pressed = false),
        onTapUp: widget.onTap == null ? null : (_) => setState(() => _pressed = false),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          transform: matrix,
          transformAlignment: Alignment.center,
          padding: widget.padding,
          decoration: BoxDecoration(
            color: widget.color ?? AppColors.pureWhite,
            borderRadius: BorderRadius.circular(widget.isButton ? 24 : widget.borderRadius),
            border: widget.customBorder ?? Border.all(
              color: widget.dashed ? AppColors.oatLight : AppColors.oatBorder,
              width: 1,
            ),
            boxShadow: (_hover && widget.onTap != null)
                ? const [BoxShadow(color: AppColors.clayBlack, blurRadius: 0, offset: Offset(-7, 7))]
                : AppElevation.card,
          ),
          child: widget.child,
        ),
      ),
    );
  }
}

class SectionTitle extends StatelessWidget {
  final String title;
  const SectionTitle(this.title, {super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 32, 16, 12),
      child: Text(
        title.toUpperCase(),
        style: Theme.of(context).textTheme.labelMedium?.copyWith(
          letterSpacing: 1.08,
        ),
      ),
    );
  }
}
```

- [ ] **Step 2: Delete XuiTheme from x_design.dart**

After all xui pages are migrated in Task 5, `lib/xui/x_design.dart` should only contain `ClayContainer` and `SectionTitle` (which are now in `lib/widgets/clay_container.dart`). Replace the file content with a re-export for backward compatibility:

```dart
// Re-export — use lib/widgets/clay_container.dart directly in new code
export '../widgets/clay_container.dart';
```

- [ ] **Step 3: Run flutter analyze**

```bash
cd e:/workspace/claw/zhiban/flutter_application_zhiban && flutter analyze
```

Expected: Zero errors.

- [ ] **Step 4: Commit**

```bash
git add lib/widgets/clay_container.dart lib/xui/x_design.dart
git commit -m "refactor: extract ClayContainer, strip XuiTheme"
```

---

### Task 7: Final verification

- [ ] **Step 1: Full flutter analyze — zero errors**

```bash
cd e:/workspace/claw/zhiban/flutter_application_zhiban && flutter analyze
```

Fix any remaining issues.

- [ ] **Step 2: Verify no remaining XuiTheme/ApPTheme references**

```bash
cd e:/workspace/claw/zhiban/flutter_application_zhiban && grep -r "XuiTheme\." lib/ || echo "No XuiTheme references"
grep -r "AppTheme\." lib/ || echo "No AppTheme references"
grep -r "config/theme.dart" lib/ || echo "No config/theme.dart imports"
```

- [ ] **Step 3: Build APK (verify compilation)**

```bash
cd e:/workspace/claw/zhiban/flutter_application_zhiban && flutter build apk --debug
```

Expected: BUILD SUCCESSFUL.

- [ ] **Step 4: Commit**

```bash
git add -A
git commit -m "refactor: Phase 1 complete — unified design system"
```
