# M02 — Shared UI Components

**Freeze name:** Design System Frozen  
**Scope:** Prani Doctor / Animal Doctors Flutter (`pranidoctor_mobile`)

## Purpose

Provide reusable building blocks so every screen uses the same patterns for layout, headers, buttons, cards, async states, search, filters, and bottom sheets — **without** ad‑hoc colors, spacing, or duplicate widgets.

## Components (created or consolidated)

| Component | Location | Use when |
|-----------|---------|----------|
| **PraniScaffold** | `widgets/prani_scaffold.dart` | Full-page shell with optional app bar title/subtitle, FAB, bottom nav, safe padding (top omitted when an app bar is present). |
| **PraniAppHeader** | `widgets/prani_app_header.dart` | Title stack for `AppBar.title` or inline headers (subtitle, optional icon/actions). |
| **PraniPrimaryButton** / **PraniSecondaryButton** | `widgets/prani_buttons.dart` | Primary CTA (loading supported) and outline/text secondary actions. |
| **PraniPrimaryCtaButton** | `widgets/prani_primary_cta_button.dart` | Thin wrapper → `PraniPrimaryButton` (backward compatible). |
| **PraniSectionHeader** | `widgets/prani_section_header.dart` | Section titles with optional subtitle, leading icon, trailing action. |
| **PraniInfoCard** | `widgets/prani_info_card.dart` | Neutral info / settings-style elevated card (title, subtitle, optional leading icon, trailing, tap). |
| **PraniServiceCard** | `widgets/prani_service_card.dart` | Home/service tiles; optional **subtitle** and **badge** (existing grids unchanged if omitted). |
| **PraniProviderCard** | `widgets/prani_provider_card.dart` | Doctor/technician directory rows (name, role, area, tags, fee, rating, actions). |
| **PraniEmptyState** | `widgets/prani_empty_state.dart` | Friendly empty UI; optional boxed surface for lists. |
| **PraniEmptyStateCard** | `widgets/prani_empty_state_card.dart` | Wrapper: boxed `PraniEmptyState` + optional custom `action` widget. |
| **PraniErrorState** | `widgets/prani_error_state.dart` | User-facing error + retry; optional **detail** in debug / `APP_ENV=development` only; optional **boxed** strip. |
| **PraniLoadingState** | `widgets/prani_loading_state.dart` | Spinner + optional Bengali status line; optional fixed height for list placeholders. |
| **PraniAsyncEmptyCard / PraniAsyncErrorCard / PraniAsyncLoadingCard** | `widgets/prani_async_list_status.dart` | Legacy names kept; implemented via the states above. |
| **PraniAsyncListStatus** | `widgets/prani_async_list_status.dart` | Maps `PraniAsyncListPhase` → loading / empty / error / ready child. |
| **PraniSearchField** | `widgets/prani_search_field.dart` | Real text field with theme decoration + clear affordance. |
| **PraniFilterCard** | `widgets/prani_filter_card.dart` | Expandable filter shell (title, summary, reset, children). |
| **PraniBottomSheet** | `widgets/prani_bottom_sheet.dart` | `showPraniBottomSheet<R>(...)` modal helper with header + scroll body. |
| **PraniAppSearchBar** | `widgets/prani_app_search_bar.dart` | Non-editable search affordance (existing). |

## Barrel export

Import from:

`package:pranidoctor_mobile/src/design_system/prani_design_system.dart`

(or individual files under `widgets/`).

## Pages touched (foundation demo)

- **Home** — `PraniSectionHeader` now demonstrates optional **subtitle**.
- **Doctor finder** — `PraniScaffold`, `PraniLoadingState`, filters via **`PraniFilterCard`** (`ProviderFilterPanel`), list rows via **`PraniProviderCard`** (`DoctorSummaryCard`).
- **Profile** — loading uses **`PraniLoadingState`**.
- **Service requests** — loading/error use **`PraniLoadingState`** / **`PraniErrorState`** (retry + dev-only detail).

## Rules for future pages

### Do

- Use **`Theme.of(context).colorScheme`** / **`PraniColors`** / **`PraniSpacing`** / **`PraniRadius`** / **`PraniTextStyles`** for visuals.
- Use **`PraniPrimaryButton`** / **`PraniSecondaryButton`** for actions.
- Use **`PraniEmptyState`**, **`PraniErrorState`**, **`PraniLoadingState`** (or **`PraniAsyncListStatus`**) for async UX.
- Put doctor/technician rows on **`PraniProviderCard`** (or thin mappers like `DoctorSummaryCard`).
- Use **`PraniFilterCard`** for expandable filter panels.

### Don’t

- Don’t introduce **random `Color(0x…)`** or magic padding outside tokens/theme.
- Don’t create **one-off** full-width `ElevatedButton.styleFrom` unless extending the design system.
- Don’t duplicate **empty/error/loading** columns — compose from shared states.
- Don’t add **second** card/button systems alongside `Prani*` widgets.

## Design System Frozen

From this baseline, **new UI work should extend these components** or add thin feature-specific mappers (like `DoctorSummaryCard`) instead of forking new visual systems.

## Legacy / follow-up

- **`DoctorSummaryCard` / `TechnicianSummaryCard`** remain feature adapters over **`PraniProviderCard`** (call/book still placeholder snacks until product wiring).
- **`PraniAppSearchBar`** vs **`PraniSearchField`**: tap affordance vs real typing — both intentional; pick by UX.
