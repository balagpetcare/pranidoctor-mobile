# Prani Doctor — Mobile UI polish (Bengali-first)

**Scope:** Flutter app at `pranidoctor_mobile` only. No API or backend changes.

**Goal:** A shared, premium design system (tokens + reusable widgets) that fixes dark-mode contrast, spacing rhythm, and bottom-navigation overlap—without rewriting app architecture (Riverpod + `go_router` + feature folders stay as-is).

---

## Task P01 — Premium design system foundation (canonical API)

**Theme:** `lib/src/app/theme.dart` — `AppTheme.light` / `AppTheme.dark`, `ColorScheme` tuned for teal brand, Bengali `textTheme` (`Noto Sans Bengali` fallback), `chipTheme`, `dividerTheme`, card/input/button/navigation themes.

**Legacy / brand tokens:** `lib/src/design_system/prani_tokens.dart` — `PraniColors`, `PraniSpacing`, `PraniRadii`, `PraniShadows` (still used across features).

**P01 canonical names:** `lib/src/design_system/app/app_design_system.dart` — import one barrel for **App\*** tokens and typedefs:

| P01 name | Role |
|----------|------|
| `AppColors` | Brand constants (delegates to `PraniColors`) |
| `AppSpacing` | 4-based spacing scale |
| `AppRadius` | Corner radii |
| `AppShadows` | Card elevation shadows + `elevatedCard(brightness)` |
| `AppSemanticColors` | `success` / `warning*` helpers; **danger** → `ColorScheme.error` |
| `AppTextStyles` | Bengali-friendly helpers (always pair with `ColorScheme` colors) |
| `AppPageInsets` | Horizontal padding + `bottomNavContentPadding` (72 dp nav) |
| `ColorScheme.elevatedSurface` | Same as `praniElevatedCard` — not pure white in dark mode |

**Widgets (P01):** `lib/src/design_system/app/widgets/app_widgets.dart`

| Widget | Notes |
|--------|--------|
| `AppPageScaffold` | `typedef` → `PraniSafePage` (top safe area; bottom inset handled separately) |
| `AppBottomNavContentPadding` | Bottom pad for tab bodies above shell `NavigationBar` |
| `PremiumCard` | `typedef` → `PraniPremiumCard` |
| `SectionHeader` | `typedef` → `PraniSectionHeader` |
| `PrimaryActionButton` | `typedef` → `PraniPrimaryCtaButton` (filled, full width) |
| `SecondaryActionButton` | `OutlinedButton`, full width, matches radius/padding scale |
| `EmptyStateCard` | `typedef` → `PraniEmptyStateCard` |
| `AppIconBadge` | Icon on `primaryContainer` / `onPrimaryContainer` |

**Naming note:** New screens may import `app_design_system.dart` and use **App\*** / **PremiumCard** names; existing code may keep **Prani\*** until migrated — same behavior.

---

## 1. Project structure (audit)

| Area | Location |
|------|----------|
| Entry | `lib/main.dart` → `PraniDoctorApp` |
| App shell | `lib/src/app/app.dart`, `theme.dart`, `router.dart`, `screen_padding.dart` |
| Design system (existing) | `lib/src/design_system/prani_tokens.dart`, `widgets/prani_section_header.dart`, `widgets/prani_async_list_status.dart` |
| Customer shell | `lib/src/features/home/home_shell_screen.dart` — `Scaffold` + `NavigationBar` (5 tabs) |
| Features | `lib/src/features/*` — auth, home, profile, providers, service_requests, knowledge_hub, notifications, animals, technician_ai, onboarding, splash |

**Routing:** `go_router` in `lib/src/app/router.dart` with `sessionNotifierProvider` refresh; tab content is **not** routed—tabs swap widgets inside `HomeShellScreen`.

---

## 2. Screens / routes (inventory)

**Public / pre-auth**

- `SplashScreen` — `/`
- `OnboardingScreen` — `/onboarding`
- `LoginEntryScreen` — `/login`

**Customer shell (tab bodies, same route `/home`)**

- `HomeScreen` (tab 0)
- `DoctorTabScreen` → nested `DoctorListScreen` (tab 1)
- `ServiceRequestsTabScreen` (tab 2)
- `NotificationsListScreen` (tab 3)
- `ProfileHomeScreen` (tab 4)

**Top-level named routes (non-tab)**

- Doctor auth: `DoctorLoginScreen`, `DoctorHomeScreen`
- Technician auth / AI jobs: `TechnicianLoginScreen`, `TechnicianDashboardScreen`, `TechnicianRequestsScreen`, `TechnicianJobsScreen`, `TechnicianJobDetailScreen` (+ record / complete child routes)
- Providers: `DoctorListScreen`, `DoctorDetailScreen`, `TechnicianListScreen`, `TechnicianDetailScreen`
- Profile / settings: `EditProfileScreen`, `AreaSettingScreen`, `AppSettingsScreen`, `HelpSupportScreen`, `AboutScreen`
- Knowledge hub: `KnowledgeHubHomeScreen`, categories, post list, post detail
- Service requests: `BookingWizardScreen`, `ServiceRequestDetailScreen`
- Animals: `AnimalListScreen`
- Notifications (also reachable from tab): `NotificationsListScreen`

---

## 3. Shared UI / state (audit)

| Concern | Mechanism |
|---------|-----------|
| Theme | `AppTheme.light` / `AppTheme.dark`, `ThemeMode.system` in `app.dart` |
| Tokens | `PraniColors`, `PraniSpacing`, `PraniRadii`, `PraniShadows` + **P01:** `AppColors`, `AppSpacing`, … (`app/app_design_system.dart`) |
| Tab index | `homeShellTabProvider` (`home_shell_tab_provider.dart`) |
| Session | `sessionNotifierProvider` |
| API | `dio` + repositories (unchanged in this work) |

---

## 4. Architecture compatibility

**Compatible (no conflict):**

- Adding files under `lib/src/design_system/` and tightening `AppTheme` component themes.
- Replacing hardcoded colors (e.g. `PraniColors.white` on cards) with `ColorScheme`-driven surfaces.
- Centralizing bottom inset math for the 72dp `NavigationBar` + device safe area.
- Gradually swapping local widgets for `PraniPremiumCard`, `PraniSectionHeader`, etc.

**Would conflict (not done without product decision):**

- Replacing `HomeShellScreen`’s single `Scaffold` with per-tab `Navigator` + nested `Scaffold` everywhere (large behavioral change).
- Changing `go_router` structure for tabs (e.g. `StatefulShellRoute`) — better for deep links later but out of scope for “polish foundation.”

---

## 5a. Design rules (P01)

1. **Surfaces:** Use `Theme.of(context).colorScheme` for backgrounds and text. For elevated cards/sheets use `scheme.elevatedSurface` (or `PraniPremiumCard` / `PremiumCard`), not `Colors.white` in dark mode.
2. **Text:** Primary copy → `onSurface`; secondary → `onSurfaceVariant` (avoid extra low opacity on dark backgrounds).
3. **Bengali:** Keep `height` ≥ 1.35 on body/title where possible; use `AppTextStyles` or theme `textTheme` — do not shrink below 12 sp for critical labels.
4. **Borders:** Prefer `outline` / `outlineVariant` from scheme, not ad-hoc greys.
5. **Semantic:** Errors → `colorScheme.error` / `errorContainer`; success/warning → `AppSemanticColors` or dedicated containers when you add UI.
6. **Bottom nav:** Tab roots above `HomeShellScreen`’s `NavigationBar` must add bottom padding via `AppPageInsets.bottomNavContentPadding` or `PraniPageInsets.bottomNavContentPadding` (same implementation).

## 5b. Shared widget usage (quick guide)

```dart
import 'package:pranidoctor_mobile/src/design_system/app/app_design_system.dart';

// Tab body
AppPageScaffold(
  child: SingleChildScrollView(
    padding: EdgeInsets.only(
      bottom: AppPageInsets.bottomNavContentPadding(context, comfortGap: 28),
    ),
    child: ...,
  ),
);

PremiumCard(
  padding: EdgeInsets.all(AppSpacing.xl),
  child: Text('…', style: AppTextStyles.body(Theme.of(context).textTheme, Theme.of(context).colorScheme)),
);

SectionHeader(title: 'আমাদের সেবা', actionLabel: 'সব দেখুন', onAction: () { ... });

PrimaryActionButton(label: 'চালিয়ে যান', onPressed: () { ... });
SecondaryActionButton(label: 'বাতিল', onPressed: () { ... });

EmptyStateCard(
  title: 'কিছু নেই',
  subtitle: 'আবার চেষ্টা করুন।',
  action: FilledButton.tonal(onPressed: () { ... }, child: Text('রিফ্রেশ')),
);
```

## 5c. Page polish phases

| Phase | Scope |
|-------|--------|
| **P01** | Tokens (`app/`), theme/divider, color-scheme extensions, core widgets + typedefs — **done** (this repo state). |
| **P02** | Migrate remaining feature screens: replace hardcoded whites, local section headers, ad-hoc buttons. |
| **P03** | Lists / async: standardize on `EmptyStateCard`, `PraniAsyncErrorCard`, loading rows. |
| **P04** | Optional: `ThemeExtension` for marketing-only colors; golden tests for light/dark widgets. |

---

## 6. Root causes of reported issues

| Issue | Cause (found in code) |
|-------|------------------------|
| Dark mode text on cards | `PraniServiceCard` formerly used `PraniColors.white` with `onSurface` text (light in dark theme) → illegible; fixed with `praniElevatedCard` + `praniOnElevatedCard`. |
| Section titles too dark | `PraniSectionHeader` defaulted `titleColor` to `PraniColors.textDark` → invisible on dark scaffold. |
| White cards in dark mode | Same hardcoded surfaces; doctor preview / empty states used `cardLight` shadows on dark backgrounds (minor). |
| Service grid inconsistency | Height derived from width `tileW/0.92` with clamp; white card fill not theme-aware. |
| Bottom nav covers content | Home already used `HomeLayout.scrollBottomPadding`; **Profile** used a smaller bottom pad → risk of overlap. |
| Home horizontal padding | `HomeLayout` (14–18) vs `pdScreenPadding` (16–28% width) → inconsistent gutters between Home and Profile. |
| Profile layout | Functional grouped `Card`s; opportunity to use shared premium card + section chrome. |
| Empty states | Mixed patterns; consolidate on `PraniEmptyStateCard` where appropriate. |

---

## 7. Foundation delivered

1. **`PraniColorSchemeX` + P01 aliases** — `praniElevatedCard`, `elevatedSurface`, `canvasBackground`, etc.
2. **`PraniPageInsets` / `AppPageInsets`** — `horizontalPadding`, `bottomNavContentPadding` (72 dp `NavigationBar`).
3. **Widgets:** `PraniSafePage`, `PraniPremiumCard`, `PraniServiceCard`, `PraniEmptyStateCard`, `PraniPrimaryCtaButton`, `PraniAppSearchBar`, plus **P01** `SecondaryActionButton`, `AppIconBadge`, and typedefs (`PremiumCard`, `SectionHeader`, …).
4. **Theme:** `chipTheme`, `dividerTheme`, dark `onSurfaceVariant`, dark cards use `surfaceContainerHigh`.
5. **Proof screens:** Home + Profile use shared insets/cards.
6. **P01 barrel:** `lib/src/design_system/app/app_design_system.dart` — canonical **App\*** API; also re-exported from `prani_design_system.dart`.

---

## 8. Rollout checklist (remaining screens)

Apply in small PRs per feature:

1. Prefer **`PremiumCard`** / `scheme.elevatedSurface` over `Colors.white` / `PraniColors.white` on cards.
2. Use **`SectionHeader`** or `PraniProfileSectionHeader` for grouped UI.
3. Tab bodies: **`AppPageInsets.bottomNavContentPadding`** (or `PraniPageInsets`).
4. Empty/error: **`EmptyStateCard`**, `PraniAsyncErrorCard`, `AppShadows.elevatedCard(brightness)`.
5. Buttons: **`PrimaryActionButton`** + **`SecondaryActionButton`** for paired CTAs.
6. Run **golden / widget tests** in a later phase if desired.

---

## 9. Verification commands

```bash
dart format .
flutter analyze
flutter test
```

---

*Last updated: Task P01 — App\* design system layer + docs.*
