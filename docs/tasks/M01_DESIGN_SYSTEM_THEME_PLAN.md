# Task M01 — Design System & Theme Foundation

**Product:** Prani Doctor (Animal Doctors) — Bangladesh-first veterinary mobile app.  
**Repo:** `pranidoctor_mobile`  
**Status:** **Implemented** (foundation code + this doc). Sections §1–§10 preserve the original audit/plan; **§11** describes what shipped and how to use it.

**Related docs:** `docs/MOBILE_UI_DESIGN_SYSTEM.md` (token and UX rules — keep aligned when extending the system).

---

## 1. Current audit findings

### 1.1 Flutter project layout

| Area | Finding |
|------|---------|
| **Entry** | `lib/main.dart` initializes bindings, wraps app in `ProviderScope`, mounts `PraniDoctorApp`. |
| **App shell** | `lib/src/app/app.dart` — `MaterialApp.router`, Go Router, **default locale `bn_BD`**, supported `en_US`, Material + Cupertino localization delegates. |
| **Routing** | `lib/src/app/router.dart` — `go_router` + Riverpod `goRouterProvider`; feature routes under `lib/src/features/**`. |
| **Theme** | Single source: `lib/src/app/theme.dart` — Material 3, `ColorScheme.fromSeed` with teal seed `#0F766E`, parallel **light + dark** `ThemeData`. |
| **Spacing helpers** | `lib/src/app/screen_padding.dart` — `pdScreenPadding(context)` (horizontal % width, clamp 16–28), `pdReadableMaxWidth` (max 520). |
| **Shared UI** | **`lib/src/core/`** — constants (`PdSpacing`, `PdRadii`, `PdShadows`), theme (`PdPalette`, `PdSemanticColors`, `PdTypography`), widgets (`PdPrimaryButton`, `PdAppCard`, async states, etc.), barrel `design_system.dart`. Feature-local widgets unchanged unless migrated later. |
| **Assets / fonts** | `pubspec.yaml` has **no** `flutter:` `assets:` or `fonts:` sections — Bengali relies on **system fonts** + `fontFamilyFallback` in theme (`Noto Sans Bengali`, `Noto Sans`). |
| **Tests** | `test/widget_test.dart` — smoke test that app builds and finds “Prani Doctor”. |

### 1.2 Theme behavior (summary)

- **Brand:** Deep teal seed (`0xFF0F766E`), clinic-like light scaffold `#F5FAF9`, dark scaffold `#0C1211`.
- **Components themed:** `AppBar`, `Card` (radius 16, elevation 0), `InputDecorationTheme` (filled, radius 12), `FilledButton` / `OutlinedButton` (min height 48, radius 12), `NavigationBar` (height 72, label styles).
- **Typography:** `Typography.material2021` with Bengali-friendly **line heights** and `fontFamilyFallback` on `textTheme` — **no explicit `fontFamily`** on `ThemeData` (platform default + fallback).
- **Locale:** Bengali-first is enforced at app level; RTL not required (Bengali in LTR UI).

### 1.3 Feature usage patterns (from codebase review)

- Screens consistently use `Theme.of(context).colorScheme` and `Theme.of(context).textTheme` — **good alignment** with a centralized theme.
- `pdScreenPadding` is widely used; **some** screens/tabs use **fixed** horizontal padding (e.g. `EdgeInsets.symmetric(horizontal: 20)` on profile tab) instead of `pdScreenPadding` — minor inconsistency to normalize **during** design-system rollout, not necessarily in the first token-only PR.
- Loading / empty / error UI is **implemented ad hoc** per screen (e.g. tutorials lists) — shared **`PdLoadingBody`**, **`PdErrorBody`**, **`PdEmptyState`** are available in `lib/src/core/widgets/pd_async_states.dart`; feature migration is optional follow-up.
- **`ThemeExtension`:** `PdSemanticColors` (success / warning / error / info, border, text primary/secondary, light/dark green, medical surface) — `context.pdSemanticColors`.

### 1.4 Dependencies relevant to UI

From `pubspec.yaml`: `flutter`, `flutter_localizations`, `cupertino_icons`, `flutter_riverpod`, `dio`, `go_router`, `flutter_secure_storage`, `shared_preferences`, `intl`. **No** UI kits (no flex_color_scheme, no google_fonts in tree). **M01 should avoid adding packages** unless a hard gap appears (e.g. bundled Bengali font — optional later).

---

## 2. Existing files found (inventory)

| Path | Role |
|------|------|
| `lib/main.dart` | App entry |
| `lib/src/app/app.dart` | `MaterialApp.router`, locale, theme binding |
| `lib/src/app/theme.dart` | **Core** `AppTheme.light` / `AppTheme.dark` |
| `lib/src/app/screen_padding.dart` | Screen horizontal padding + readable width |
| `lib/src/app/router.dart` | Go Router setup |
| `lib/src/app/navigation_keys.dart` | Navigator keys |
| `pubspec.yaml` | Dependencies; **no** custom assets/fonts yet |
| `analysis_options.yaml` | `flutter_lints` |
| `test/widget_test.dart` | Smoke widget test |
| `docs/MOBILE_UI_DESIGN_SYSTEM.md` | Human-readable token/spec reference |

All feature screens under `lib/src/features/**` consume theme indirectly; **no separate theme fork** for doctor vs customer flows.

---

## 3. Architecture check (before changes)

- **State:** Riverpod (`ProviderScope`, feature providers).
- **Navigation:** GoRouter; shell uses `IndexedStack` + `NavigationBar` in `home_shell_screen.dart`.
- **Layering:** Features are grouped by domain (`auth`, `home`, `animals`, …). A design system should live **`under `lib/src/app/`** (next to theme) **or** `lib/src/shared/` **without** importing feature code — **depends only on Flutter SDK**.

**Recommendation:** Add a thin **`lib/src/app/design_system/`** (or `lib/src/shared/design_system/`) namespace for tokens + reusable primitives, re-export or reference from `AppTheme` where extensions attach cleanly. Keeps Riverpod/features untouched for M01.

---

## 4. Proposed design system structure

```
lib/src/app/
  theme.dart              # Extend: ThemeData.extensions, optional fontFamily bridge
  screen_padding.dart     # Optionally re-export spacing from tokens (or keep as-is)
  design_system/
    tokens.dart           # PdSpacing, PdRadii, PdDurations (compile-time constants)
    colors_extension.dart # ThemeExtension<PdAppColors> for semantic extras (optional)
    widgets/
      pd_primary_button.dart   # Thin wrappers: FilledButton / OutlinedButton presets
      pd_card.dart             # Card + consistent padding/margin helpers
      pd_text_field.dart       # Optional InputDecorator presets for repeated patterns
      pd_async_states.dart     # Loading / Error / Empty scaffold sections (Bangla props)
```

**Principles:**

- **Tokens** mirror `docs/MOBILE_UI_DESIGN_SYSTEM.md` (4px grid, 12/16 radii, 48 touch targets).
- **Widgets** are **thin** composables around Material 3 — not a parallel widget library.
- **Bengali-first:** empty/error/loading widgets take **Bangla** `title`/`message` strings from callers; no hard-coded English user strings in foundations.
- **Green/white medical identity:** continue **teal seed + soft mint scaffold**; semantic greens via `ColorScheme` / extension, not random hex in features.

---

## 5. Files to create / update (implementation phase — not done yet)

### 5.1 Create (proposed)

| File | Purpose |
|------|---------|
| `lib/src/app/design_system/tokens.dart` | `PdSpacing`, `PdRadii`, optional `PdElevation`/`PdIconSizes` |
| `lib/src/app/design_system/colors_extension.dart` | Optional `ThemeExtension` for success/warning/info/surfaceAccent |
| `lib/src/app/design_system/widgets/pd_primary_button.dart` | Shared primary/secondary/async button patterns |
| `lib/src/app/design_system/widgets/pd_card.dart` | Standard inset padding + optional `onTap` |
| `lib/src/app/design_system/widgets/pd_text_field.dart` | Optional wrapper for repeated `InputDecoration` overrides |
| `lib/src/app/design_system/widgets/pd_async_states.dart` | `PdLoadingBody`, `PdErrorBody`, `PdEmptyState` (icons + text + optional CTA) |
| `lib/src/app/design_system/design_system.dart` | Barrel export (optional, if team prefers single import) |

### 5.2 Update (proposed)

| File | Change |
|------|--------|
| `lib/src/app/theme.dart` | Register `extensions:` if `ThemeExtension` added; wire `inputDecorationTheme` / `chipTheme` / `dividerTheme` only if gaps found; ensure dark/light parity. |
| `lib/src/app/app.dart` | Only if theme assembly moves (e.g. single `theme` builder) — **minimal touch**. |
| `docs/MOBILE_UI_DESIGN_SYSTEM.md` | Cross-reference new token class names / widget names when implemented. |

### 5.3 Explicitly out of scope for M01 implementation passes

- **Do not** migrate every feature screen in the same PR as token creation — migrate **1–2 pilot screens** to validate APIs, then follow-up tasks.
- **Do not** add `google_fonts` or large asset packs without size review.

---

## 6. Exact implementation checklist (for developers)

Use this as the execution order when M01 coding starts:

1. [x] Add token files — `PdSpacing`, `PdRadii`, `PdShadows` under `lib/src/core/constants/`.
2. [x] Add `ThemeExtension<PdSemanticColors>` — `lib/src/core/theme/pd_semantic_colors.dart`; registered in `AppTheme`.
3. [x] Implement loading/error/empty widgets — `pd_async_states.dart`.
4. [x] Implement `PdPrimaryButton` / `PdSecondaryButton` — `pd_buttons.dart`.
5. [x] Implement `PdAppCard` — default padding **16** (`PdSpacing.md`).
6. [x] Run `flutter analyze` and `flutter test` — green.
7. [ ] Pilot: refactor **one** list screen’s loading/error/empty blocks (optional **M01b**).
8. [ ] Update `MOBILE_UI_DESIGN_SYSTEM.md` §13 with concrete class/widget names (optional follow-up).

---

## 7. What will NOT be changed

- **Backend / API** — not in this repo; no contract changes.
- **Go Router routes, auth, session** — no changes for M01 unless a theme bug blocks builds (unlikely).
- **No new feature pages** — M01 is foundation only; **no** new user-facing screens for product features.
- **No wholesale rewrite** of existing feature widgets — only add shared primitives and optional pilot migration.
- **No unrelated files** — avoid drive-by refactors outside `lib/src/app/design_system/**`, `theme.dart`, and agreed pilot files.
- **Packages:** no new dependencies unless explicitly approved (e.g. bundled font later).

---

## 8. Test commands to run

From repo root (`pranidoctor_mobile`):

```bash
flutter pub get
flutter analyze
flutter test
```

Optional manual QA (not CI-blocking for M01 plan):

```bash
flutter run
```

Verify: default locale **Bangla**, light/dark **readable Bengali**, primary buttons **48dp** min height, cards **16** radius.

---

## 9. Git branch / commit plan

| Step | Action |
|------|--------|
| Branch | `feature/m01-design-system-theme` (or `docs/m01-plan-only` if **only** this plan document lands first). |
| Commit 1 (this task) | `docs: add M01 design system and theme foundation plan` — **only** `docs/tasks/M01_DESIGN_SYSTEM_THEME_PLAN.md`. |
| Commit 2+ (future implementation) | `feat(theme): add design system tokens and async state widgets` — code + tests; small, reviewable PRs. |
| PR title suggestion | **M01: Design system & theme foundation** |

Keep plan-only PR separate from implementation PR so reviewers can approve direction without a large diff.

---

## 10. Alignment with product goals

| Requirement | Plan response |
|-------------|----------------|
| Bengali-first UI | Default locale + Bangla copy in foundation widgets; typography tuned for Bengali line height in existing `AppTheme`. |
| Clean green/white veterinary style | Existing teal seed + mint scaffold; extensions for semantic greens if needed. |
| Consistent colors, type, spacing, radius, shadows | Tokens file + `ThemeData` / extensions; Material 3 elevation mostly flat (elevation 0 cards). |
| Reusable buttons, cards, inputs, states | Widget folder as above; thin Material wrappers. |
| Reuse existing packages | Stay on Material 3 + Riverpod + go_router; **no** new UI packages by default. |

---

## 11. Implementation summary (completed)

### 11.1 What was delivered

- **Layout tokens:** `lib/src/core/constants/pd_spacing.dart`, `pd_radii.dart`, `pd_shadows.dart` (4px grid, card/button/input radii, soft card shadow).
- **Colors:** `pd_palette.dart` (primary/dark/light green, medical white, semantic accents) + `pd_semantic_colors.dart` (`ThemeExtension`, `BuildContext.pdSemanticColors`).
- **Typography:** `pd_typography.dart` — Bengali-friendly `TextTheme` (`PdTypography.textTheme`) with helpers mapping roles (heading/title/body/caption/button).
- **Theme assembly:** `lib/src/app/theme.dart` refactored to use the above; adds **divider**, **snackBar**, **elevated**, **text**, **bottomNavigationBar** themes; keeps **navigationBar** (Material 3 shell); registers `PdSemanticColors` for light/dark.
- **Widgets:** `pd_buttons.dart`, `pd_app_card.dart`, `pd_text_field.dart`, `pd_async_states.dart`, `pd_page_header.dart`.
- **Barrel import:** `lib/src/core/design_system.dart` — `import 'package:pranidoctor_mobile/src/core/design_system.dart';`
- **Integration:** `PraniDoctorApp` still uses `AppTheme.light` / `AppTheme.dark` from `lib/src/app/theme.dart` — **no** router/auth/splash changes.

### 11.2 Files changed / added

| Action | Path |
|--------|------|
| **Updated** | `lib/src/app/theme.dart` |
| **Added** | `lib/src/core/constants/pd_spacing.dart`, `pd_radii.dart`, `pd_shadows.dart` |
| **Added** | `lib/src/core/theme/pd_palette.dart`, `pd_semantic_colors.dart`, `pd_typography.dart` |
| **Added** | `lib/src/core/widgets/pd_buttons.dart`, `pd_app_card.dart`, `pd_text_field.dart`, `pd_async_states.dart`, `pd_page_header.dart` |
| **Added** | `lib/src/core/design_system.dart` |
| **Updated** | `docs/tasks/M01_DESIGN_SYSTEM_THEME_PLAN.md` |

### 11.3 How future screens should use the design system

1. **Colors:** Prefer `Theme.of(context).colorScheme` for Material roles. For banners, status chips, or explicit brand accents, use **`context.pdSemanticColors`** (extension on `BuildContext` from `pd_semantic_colors.dart`).
2. **Typography:** Prefer **`Theme.of(context).textTheme`** — tuned for Bengali line height. Optional role helpers: `PdTypography.body(textTheme)`, etc.
3. **Spacing / radius:** Import **`PdSpacing`**, **`PdRadii`** instead of magic numbers (e.g. `SizedBox(height: PdSpacing.md)`).
4. **Buttons:** Use **`PdPrimaryButton`** / **`PdSecondaryButton`** when you need consistent loading states and Bangla labels passed as `label:`.
5. **Cards:** Use **`PdAppCard`** for tap targets + optional **`useShadow: true`** soft elevation.
6. **Forms:** **`PdTextField`** wraps `TextField` / `TextFormField` with theme-aligned decoration; pass Bangla **`labelText`** / **`hintText`**.
7. **Async UI:** Replace one-off spinners with **`PdLoadingBody`**, failures with **`PdErrorBody`** (Bangla `title` / `retryLabel`), empty lists with **`PdEmptyState`**.
8. **Headers:** **`PdPageHeader`** for section or simple page titles + subtitle.
9. **Screen edges:** Keep using **`pdScreenPadding`** from `lib/src/app/screen_padding.dart` for horizontal gutters.

### 11.4 Follow-ups (optional)

- Migrate 1–2 existing screens (e.g. tutorials list) to **`PdLoadingBody` / `PdErrorBody` / `PdEmptyState`** for consistency.
- Amend **`docs/MOBILE_UI_DESIGN_SYSTEM.md`** §13 with links to these types.
- Evaluate bundled **Noto Sans Bengali** via `pubspec` fonts if devices show poor fallback.

---

## 12. Verification run (format / analyze / test)

**Machine-local run** — repository root `pranidoctor_mobile`.

### 12.1 Commands

```bash
dart format .
flutter analyze
flutter test
```

(Re-run after any fix; see §12.4.)

Follow-up run after updating §12 in this doc: **`dart format .`** — 0 files changed; **`flutter analyze`** — pass; **`flutter test`** — pass.

### 12.2 Results

| Step | Status |
|------|--------|
| `dart format .` | **Pass** — 69 files processed; 11 files reformatted on first verification (includes M01 widgets + other Dart files). Second run: **0** changes. |
| `flutter analyze` | **Pass** — no issues found. |
| `flutter test` | **Pass** — `test/widget_test.dart`: “Prani Doctor app builds”. |

*(Both verification passes succeeded.)*

### 12.3 Fixes applied during this verification

- **`dart format .`** only — normalized whitespace/style in formatted files. No logic changes. No analyzer-driven code edits were required (analyze was clean before and after).

### 12.4 Known unrelated issues

- **None observed** for this run: tests passed; analyzer reported no issues. If CI or another machine reports failures outside M01 paths, capture logs here with date and command output.

---

*Document version: 2.1 — adds verification run (§12).*
