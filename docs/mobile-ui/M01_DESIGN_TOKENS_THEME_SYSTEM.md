# M01 — Design Tokens & Theme System

## Goal

Centralize app-wide color, spacing, radius, typography, and default component styling so future screens stay consistent without rewriting existing flows.

## Scope

**In scope**

- Expand **`PraniColors`**, **`PraniSpacing`**, **`PraniRadius`** (new canonical radius token class), and add **`PraniTextStyles`** in `lib/src/design_system/prani_tokens.dart`.
- Centralize light/dark **`ThemeData`** in `lib/src/app/theme.dart`: `ColorScheme` from semantic colors, `textTheme` via `PraniTextStyles`, and defaults for buttons, cards, inputs, dividers, navigation bar, snack bar, dialog.
- Delegate **`AppSpacing`** / **`AppRadius`** / **`AppTextStyles`** to the Prani tokens where appropriate (no second typography system).
- Document Bengali typography: **`pubspec.yaml`** does not bundle custom fonts — rely on Material typography + **`fontFamilyFallback`** (`Noto Sans Bengali`, etc.) as already used in theme; no new font packages.

**Out of scope**

- Backend/API, routing, new screens, broad page-by-page refactors, renaming files across the codebase, deleting widgets.

## Files Inspected

| File/Folder | Purpose | Notes |
|-------------|---------|--------|
| `pubspec.yaml` | Dependencies & assets | No bundled fonts; only assets globs. |
| `lib/src/app/theme.dart` | `AppTheme.light` / `dark` | M3; component themes; text via `PraniTextStyles.mergeMaterial2021`. |
| `lib/src/design_system/prani_tokens.dart` | Palette, spacing, `PraniRadii`, shadows | Needs semantic expansion + `PraniRadius` + typography API. |
| `lib/src/design_system/app/app_colors.dart` | Alias to `PraniColors` | Will forward new semantic entries. |
| `lib/src/design_system/app/app_spacing.dart` | Alias to `PraniSpacing` | Will add `pageHorizontal` / `pageVertical`. |
| `lib/src/design_system/app/app_radius.dart` | Alias to radii | Will delegate to `PraniRadius`. |
| `lib/src/design_system/app/app_text_styles.dart` | Screen/section helpers | Will delegate to `PraniTextStyles`. |
| `lib/src/design_system/app/app_semantic_colors.dart` | Success/warning helpers | Optional alignment with `PraniColors` success tones. |
| `lib/src/design_system/prani_color_scheme_ext.dart` | `ColorScheme` extensions | Unchanged behavior. |
| `lib/src/design_system/widgets/*.dart` | Shared DS widgets | Use tokens; no redesign. |
| `lib/src/features/home/`, `auth/login_entry_screen.dart`, `profile/` | Sample heavy UI | Audited for patterns; no mass edits. |

## Existing Problems Found

| Area | Problem | File(s) | Recommendation |
|------|---------|---------|----------------|
| Colors | Brand literals scattered in `ColorScheme.copyWith` and widgets; limited semantic names (success/warning/info). | `theme.dart`, `app_semantic_colors.dart` | Single **`PraniColors`** semantic set + map into `ColorScheme`. |
| Radius | Class named **`PraniRadii`** while product asks for **`PraniRadius`** scale (xxl, pill, card). | `prani_tokens.dart` | Introduce **`PraniRadius`**; keep **`PraniRadii`** as thin delegate for backward compatibility. |
| Spacing | No named **page** gutters in tokens (screens use `PraniPageInsets` math separately). | `prani_tokens.dart` | Add **`pageHorizontal`** / **`pageVertical`** constants. |
| Typography | `_textTheme` private in `theme.dart`; `AppTextStyles` duplicates intent. | `theme.dart`, `app_text_styles.dart` | Move merged Material+baseline tuning to **`PraniTextStyles.mergeMaterial2021`**, delegate **`AppTextStyles`**. |
| Theme completeness | No **`elevatedButtonTheme`**, **`textButtonTheme`**, **`snackBarTheme`**, **`dialogTheme`** defaults. | `theme.dart` | Add M01 defaults from tokens + `ColorScheme`. |
| Fonts | No bundled Bengali font file. | `pubspec.yaml` | Keep fallback list; document recommendation to bundle Noto later if needed. |

## Implementation Plan

| Step | Action | File(s) |
|------|--------|---------|
| 1 | Add semantic **`PraniColors`**, spacing page tokens, **`PraniRadius`** + **`PraniRadii`** delegate, **`PraniTextStyles`**, optional **`PraniDurations`**. | `prani_tokens.dart` |
| 2 | Wire **`ColorScheme`**, **`PraniTextStyles.mergeMaterial2021`**, component themes (including elevated/text/snackbar/dialog). | `theme.dart` |
| 3 | Forward new colors / page spacing / radius in **`AppColors`**, **`AppSpacing`**, **`AppRadius`**. | `app_*.dart` |
| 4 | Delegate **`AppTextStyles`** to **`PraniTextStyles`**. | `app_text_styles.dart` |
| 5 | Align **`AppSemanticColors`** success/warning with **`PraniColors`** where safe. | `app_semantic_colors.dart` |
| 6 | Document decisions and verify. | This file |

## Acceptance Criteria Mapping

| Criteria | How It Will Be Met |
|----------|-------------------|
| PraniColors central semantic source | Expanded abstract class with primary/secondary/accent, primaryDark/Light, success/warning/danger/info, surfaces, text levels, border/divider/disabled, shadow. |
| PraniSpacing scale | xs–xxl, section, **pageHorizontal**, **pageVertical**; legacy **xxs**/**xxxl** retained. |
| PraniRadius scale | **sm…xxl**, **pill**, **card**, **homeServiceTile**; **`PraniRadii`** delegates without breaking imports. |
| PraniTextStyles + Bengali-friendly | Named styles + **`mergeMaterial2021`** with fallbacks and line heights ≥ 1.35 for body/caption. |
| Light theme centralized | **`AppTheme.light`** uses tokens + full component defaults. |
| Dark placeholder/minimal | **`AppTheme.dark`** same structure; scheme tuned for readability. |
| Button/card/input from ThemeData | Elevated/text/outlined/filled + **inputDecorationTheme** + **cardTheme**. |
| Existing UI stable | No route/feature changes; token values aligned with previous radii/spacing numbers. |
| No duplicate token system | **`App*`** remains thin aliases over **`Prani*`** / **`PraniTextStyles`**. |
| Task doc | This file updated. |

## Verification Plan

Commands:

- `dart format lib test`
- `flutter analyze`
- `flutter test`
- `flutter build apk --debug`
- `git status`

### Verification results (2026-05-10)

| Command | Result |
|---------|--------|
| `dart format lib test` | OK — `lib` + `test` formatted |
| `flutter analyze` | OK — `No issues found!` |
| `flutter test` | OK — 5 tests passed |
| `flutter build apk --debug` | OK — `build/app/outputs/flutter-apk/app-debug.apk` |
| `git status` | Used before commit (see repo state after staging) |

## Implementation Notes

- **Error color:** Light theme maps **`ColorScheme.error`** to **`PraniColors.danger`**; dark theme uses tuned on-surface reds for contrast on charcoal shells.
- **Page gutters:** `PraniSpacing.pageHorizontal` / `pageVertical` default to **16** — screens that use responsive `PraniPageInsets` unchanged.
- **Typography:** Minimum core body size stays **16**; caption **12** only for auxiliary text.
- **Dark mode:** Treated as first-class minimal palette (not empty placeholder).

## Risks / Skipped Items

- Individual screens may still contain **one-off** `Color(0x…)` values — not mass-replaced to avoid visual drift.
- Bundling **Noto Sans Bengali** as an asset would improve consistency offline; deferred (no dependency change in M01).
- **`PraniRadii`** name kept as backward-compatible delegate; new code should prefer **`PraniRadius`**.
