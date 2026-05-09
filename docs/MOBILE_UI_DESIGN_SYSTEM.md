# Prani Doctor Mobile — UI Design System

**Product:** Prani Doctor (Animal Doctors) — Bangladesh-first, **Bengali-first** UX.  
**Implementation source of truth today:** `lib/src/app/theme.dart`, `lib/src/app/screen_padding.dart`, `lib/src/app/app.dart` (locale + themes).

This document codifies **tokens and rules** so parallel Cursor tasks produce a cohesive UI. When code and this doc disagree during migration, **update code to match this doc** (or amend this doc in the same task with rationale).

---

## 1. Brand direction

- **Trust and care:** veterinary / animal health; avoid aggressive reds except for destructive or critical alerts.
- **Bangladesh context:** mobile-first, variable network; prefer clear feedback, large touch targets, and forgiving forms.
- **Bengali-first:** default app locale `bn_BD`; user-facing labels in Bangla unless technical (OTP, IDs) or brand English “Prani Doctor” where appropriate.
- **Script:** LTR layout; Bengali uses `fontFamilyFallback` (Noto Sans Bengali, Noto Sans) on `textTheme` — ensure devices have readable Bengali fonts (system or bundled later if needed).

---

## 2. Color tokens

**Seed (brand anchor):** deep teal `#0F766E` — `ColorScheme.fromSeed(seedColor: ...)` for both light and dark (`AppTheme`).

| Token (conceptual) | Light implementation | Notes |
|--------------------|----------------------|--------|
| Primary | `ColorScheme.primary` from seed | CTAs, key icons, links |
| Surface | `ColorScheme.surface` | App bars, elevated surfaces |
| Scaffold background | `#F5FAF9` | Softer than flat white; calm clinic feel |
| Cards | `surfaceContainerLowest` | Filled cards, no harsh border |
| Outline / borders | `outlineVariant` | Enabled input borders |

| Token (conceptual) | Dark implementation | Notes |
|--------------------|----------------------|--------|
| Scaffold background | `#0C1211` | Deep, not pure black |
| Cards | `surfaceContainerHigh` | Slightly elevated from scaffold |

**Rules**

- Use **`ColorScheme`** roles (`primary`, `onSurface`, `onSurfaceVariant`, `error`) — avoid hard-coded colors in feature code except rare illustration.
- **Semantic color:** success/warning/info — prefer `Theme` extensions or a small `PdSemanticColors` class in a future M01 task if Material defaults are insufficient.

---

## 3. Typography

**Base:** Material 2021 typography (`Typography.material2021`), customized in `AppTheme._textTheme`.

| Style | Usage |
|-------|--------|
| `headlineMedium` / `headlineSmall` | Screen titles, hero headings |
| `titleLarge` / `titleMedium` | Section headers, card titles |
| `bodyLarge` / `bodyMedium` | Primary reading text, form hints |
| `bodySmall` | Captions, meta lines |

**Line height / density**

- Body: **~1.45** line height for Bengali readability.
- Titles: **1.2–1.35** line height; negative letter spacing on large headlines for Latin; keep Bangla paragraphs slightly looser if clipping occurs.

**Rules**

- Prefer **`Theme.of(context).textTheme`** over raw `TextStyle` duplication.
- **Minimum touch/read size:** avoid body text below ~12 logical px for primary content.

---

## 4. Spacing

| Rule | Value / pattern |
|------|-----------------|
| Screen horizontal padding | `pdScreenPadding(context)` — ~5.5% of width, clamped **16–28** px |
| Max readable width | `pdReadableMaxWidth` caps at **520** px (centers on wide devices later if needed) |
| Section gaps | Multiples of **4**; common: 8, 12, 16, 20, 24, 28 |
| List vertical padding | Bottom inset **≥ 28** on scroll views with FABs or bottom nav |

**Rules**

- Use **consistent vertical rhythm** between title → subtitle → first control (e.g. 8 → 28).
- Inside cards, **16** px internal padding unless dense lists.

---

## 5. Button styles

| Type | Spec |
|------|------|
| Primary action | `FilledButton` — min height **48**, horizontal padding **20**, vertical **14**, radius **12** |
| Secondary | `OutlinedButton` — min height **48**, radius **12** |
| Tertiary / low emphasis | `FilledButton.tonal` or `TextButton` for low-risk actions (e.g. sign out to login) |

**Rules**

- One **primary** action per screen region where possible.
- Show **loading/disabled** state on the same button during async work (`_busy` pattern).

---

## 6. Card styles

- **Elevation:** 0 (flat Material 3).
- **Shape:** **16** px corner radius.
- **Clip:** `Clip.antiAlias` for clean corners with images.
- **Margin:** default **zero** on theme card — spacing comes from parent `ListView` / `Column`.

---

## 7. Form / input styles

- **Filled** text fields (`InputDecorationTheme.filled: true`).
- **Content padding:** horizontal **16**, vertical **14**.
- **Radius:** **12** px on all borders.
- **Focused border:** **2** px `primary`; enabled uses `outlineVariant`.

**Rules**

- Always pair inputs with **Bangla** `labelText` / `hintText` where users type (phone, OTP, names).
- Validate with **inline snackbar or field error** — messages in Bangla.

---

## 8. AppBar / top bar

- **Material 3** `AppBar`: elevation **0**, `scrolledUnderElevation` **0**.
- **Title:** left-aligned (`centerTitle: false`), **20** sp, weight **600**, `onSurface`.
- **Background:** `ColorScheme.surface`.
- **Back:** standard `BackButton` / `context.pop` for pushed routes.

---

## 9. Bottom navigation

- **Widget:** `NavigationBar` (Material 3), height **72** (theme).
- **Labels:** **12** sp; selected **w600**, unselected **w500**.
- **Icons:** outlined when idle, filled when selected (pattern from `home_shell_screen.dart`).
- **Destinations:** four tabs — হোম, অনুরোধ, আমার পশু, প্রোফাইল.

**Rules**

- Do not hide the nav bar without a deliberate full-screen pattern (e.g. media); restore on pop.
- Deep-linked screens (lists, detail) use **push** so back returns to the correct tab context where possible.

---

## 10. Empty, loading, and error states

| State | Pattern |
|-------|---------|
| Loading | `CircularProgressIndicator` with `colorScheme.primary`; center or inline in list |
| Empty | Icon + Bangla title + short subtitle + optional primary CTA |
| Error | Bangla message + **retry** (`OutlinedButton` or `FilledButton.tonal`) |
| Network | Assume slow/offline; avoid silent failure — snackbar or inline banner |

---

## 11. Responsive 9:16 mobile layout

- **Primary target:** portrait phone **~9:16** (common Bangladesh Android devices).
- **Safe areas:** wrap scrollable body content with `SafeArea` where status bar / notch / gesture inset intrudes.
- **Keyboard:** use `resizeToAvoidBottomInset` appropriately on forms; scroll views should allow focusing low fields.
- **No tablet-first layouts** in MVP; `pdReadableMaxWidth` prevents ultra-wide stretched text on foldables.

---

## 12. Accessibility

- **Contrast:** rely on Material `ColorScheme` contrast pairs; do not place gray-on-gray for critical text.
- **Touch targets:** aim **≥ 48** dp for tappable rows and buttons.
- **Semantics:** set `Semantics` or meaningful `tooltip` on icon-only actions where label is not visible.
- **Screen reader:** preserve order (title before actions); announce loading completion when switching from spinner to content if using custom announcements.

---

## 13. Future extensions (task M01)

- Central **`PdSpacing`** / **`PdRadii`** constants mirroring this doc.
- `ThemeExtension` for app-specific tokens (e.g. hub banner colors).
- Optional **custom font** package for Bengali + Latin parity (evaluate binary size).
