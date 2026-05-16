# Phase 2: Widget Layer Extraction — Implementation Plan

> **For agentic workers:** Use superpowers:subagent-driven-development. Steps use checkbox syntax.

**Goal:** Extract inline widgets from 3 oversized page files. Each page ≤ 150 lines. Establish layering: `widgets/` for shared, `pages/xxx/widgets/` for page-specific.

**Design doc:** `docs/superpowers/specs/2026-05-14-zhiban-refactor-design.md`

---

## File Map

### home_page.dart (389 → ~120 lines)

Extract to `lib/pages/home/widgets/`:

| New file | Extracted from | Lines |
|----------|---------------|-------|
| `home_header.dart` | `_header()` + `_dateStr()` λ | 327-382 |
| `featured_card.dart` | `_featuredCard()` | 171-206 |
| `featured_row.dart` | `_buildFeaturedRow()` | 143-168 |
| `promo_cards.dart` | `_aiFriendCard()` + `_aiCareerCard()` | 227-325 |
| `category_label.dart` | `_categoryLabel()` | 209-224 |
| `loading_grid.dart` | `_loadingGrid()` | 361-375 |

Also: delete `_sectionTitle()` (line 351-358) — use existing `lib/widgets/section_title.dart` `SectionTitle` instead.

### module_detail_page.dart (300 → ~160 lines)

Extract to `lib/widgets/` (these are generic, reusable):

| New file | Extracted from |
|----------|---------------|
| `action_button.dart` | `_actionButton()` |
| `outlined_button.dart` | `_outlinedButton()` |

Extract to `lib/pages/module_detail/widgets/`:

| New file | Extracted from |
|----------|---------------|
| `metadata_section.dart` | `_buildMetadataSection()` |

### mine_page.dart (451 → ~180 lines)

Extract to `lib/pages/mine/widgets/`:

| New file | Extracted from |
|----------|---------------|
| `user_card.dart` | `_UserCard` |
| `theme_sheet.dart` | `_ThemeSheet` + `_ThemeOption` |
| `notification_dialog.dart` | `_NotificationDialog` + `_TimeTile` |
| `menu_group.dart` | `_menuGroup()` + `_MenuItem` |
| `about_dialog.dart` | `_onAbout()` builder + `_AboutRow` |

---

### Task 1: Extract home_page widgets

**Files:**
- Create: `lib/pages/home/widgets/home_header.dart`
- Create: `lib/pages/home/widgets/featured_card.dart`
- Create: `lib/pages/home/widgets/featured_row.dart`
- Create: `lib/pages/home/widgets/promo_cards.dart`
- Create: `lib/pages/home/widgets/category_label.dart`
- Create: `lib/pages/home/widgets/loading_grid.dart`
- Modify: `lib/pages/home_page.dart`

**Steps:**

- [ ] Read `lib/pages/home_page.dart`
- [ ] Create `lib/pages/home/widgets/home_header.dart` — extract `_dateStr()` and `_header()` as public `HomeHeader` widget. Accept `TextTheme` + `ColorScheme` params.
- [ ] Create `lib/pages/home/widgets/featured_card.dart` — extract `_featuredCard()` as public `FeaturedCard`. Accept `ModuleConfig`, `TextTheme`, `ColorScheme`, `VoidCallback onTap`.
- [ ] Create `lib/pages/home/widgets/featured_row.dart` — extract `_buildFeaturedRow()` as public `FeaturedRow`. Accept `List<ModuleConfig>`, `TextTheme`, `ColorScheme`, `void Function(String) onTap`.
- [ ] Create `lib/pages/home/widgets/promo_cards.dart` — extract `_aiFriendCard()` as `AiFriendCard`, `_aiCareerCard()` as `AiCareerCard`. Both accept `BuildContext`, `TextTheme`, `ColorScheme`.
- [ ] Create `lib/pages/home/widgets/category_label.dart` — extract `_categoryLabel()` as public `CategoryLabel`.
- [ ] Create `lib/pages/home/widgets/loading_grid.dart` — extract `_loadingGrid()` as public `LoadingGrid`.
- [ ] Modify `lib/pages/home_page.dart`:
  - Add imports for new widget files
  - Add `import '../widgets/section_title.dart'`
  - Replace `_header(...)` → `HomeHeader(...)`
  - Replace `_aiFriendCard(...)` → `AiFriendCard(...)`
  - Replace `_aiCareerCard(...)` → `AiCareerCard(...)`
  - Replace `_sectionTitle(...)` → `const SectionTitle('更多模块')` (use existing widget)
  - Replace `_loadingGrid(...)` → `LoadingGrid(...)`
  - Replace `_buildFeaturedRow(...)` → `FeaturedRow(...)`
  - Replace `_categoryLabel(...)` → `CategoryLabel(...)`
  - Delete all extracted private methods
  - Move `_moduleCategories` to a separate file or keep as-is (it's a const)
- [ ] Run `flutter analyze`, fix errors
- [ ] Commit: `refactor(home): extract inline widgets from home_page`

### Task 2: Extract module_detail_page widgets

**Files:**
- Create: `lib/widgets/action_button.dart`
- Create: `lib/widgets/outlined_button.dart`
- Create: `lib/pages/module_detail/widgets/metadata_section.dart`
- Modify: `lib/pages/module_detail_page.dart`

- [ ] Read `lib/pages/module_detail_page.dart`
- [ ] Create `lib/widgets/action_button.dart` — `ActionButton` widget with label/icon/loading/onTap/colorScheme/textTheme
- [ ] Create `lib/widgets/outlined_button.dart` — `OutlinedButton` widget (renamed to `OutlinedActionButton` to avoid conflict with Material's OutlinedButton)
- [ ] Create `lib/pages/module_detail/widgets/metadata_section.dart` — `MetadataSection` widget
- [ ] Modify `lib/pages/module_detail_page.dart`:
  - Add imports
  - Replace `_actionButton(...)` → `ActionButton(...)`
  - Replace `_outlinedButton(...)` → `OutlinedActionButton(...)`
  - Replace `_buildMetadataSection(...)` → `MetadataSection(...)`
  - Delete extracted methods
- [ ] Run `flutter analyze`, fix errors
- [ ] Commit: `refactor(detail): extract inline widgets from module_detail_page`

### Task 3: Extract mine_page widgets

**Files:**
- Create: `lib/pages/mine/widgets/user_card.dart`
- Create: `lib/pages/mine/widgets/theme_sheet.dart`
- Create: `lib/pages/mine/widgets/notification_dialog.dart`
- Create: `lib/pages/mine/widgets/menu_group.dart`
- Create: `lib/pages/mine/widgets/about_dialog.dart`
- Modify: `lib/pages/mine_page.dart`

- [ ] Read `lib/pages/mine_page.dart`
- [ ] Create each widget file with extracted classes
- [ ] Modify `lib/pages/mine_page.dart` to import and use extracted widgets
- [ ] Run `flutter analyze`, fix errors
- [ ] Commit: `refactor(mine): extract inline widgets from mine_page`

### Task 4: Final verification

- [ ] `flutter analyze` — zero new errors
- [ ] `flutter build apk --debug` — BUILD SUCCESSFUL
- [ ] Verify all 3 page files are ≤ 180 lines
- [ ] Commit: `refactor: Phase 2 complete — widget layer extraction`
