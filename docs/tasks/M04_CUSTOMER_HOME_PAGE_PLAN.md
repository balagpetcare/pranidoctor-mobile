# Task M04 — Customer Home Page (Audit + Implementation Plan)

**Product:** Prani Doctor (Animal Doctors) — Bangladesh-first veterinary mobile app.  
**Domain:** https://pranidoctor.com/  
**Repo:** `pranidoctor_mobile` (local: `D:\PraniDoctor\pranidoctor_mobile`)

**Status:** **Implemented** (customer হোম ট্যাব dashboard + reusable widgets). See **§11 Implementation notes** below.

**Depends on:** M01 (design system / theme), M02 (app shell & bottom navigation), M03 (customer OTP login).  
**Related docs:** `docs/MOBILE_PAGE_TASK_INDEX.md` (Task M04), `docs/MOBILE_UI_DESIGN_SYSTEM.md`, `docs/tasks/M02_APP_SHELL_NAVIGATION_PLAN.md`.

---

## 11. Implementation notes (M04)

**Implemented in repo:** `pranidoctor_mobile` only. No backend changes.

### Files added

| File | Purpose |
|------|---------|
| `lib/src/features/home/presentation/customer_home_screen.dart` | Main dashboard: scrollable layout, wires sections + navigation. |
| `lib/src/features/home/presentation/widgets/customer_home_header.dart` | Greeting, mock এলাকা chip, notification tonal button. |
| `lib/src/features/home/presentation/widgets/customer_home_section_title.dart` | Section titles + optional subtitle. |
| `lib/src/features/home/presentation/widgets/customer_emergency_cta_card.dart` | জরুরি ডাক্তার card + `PdPrimaryButton` → booking wizard. |
| `lib/src/features/home/presentation/widgets/customer_service_action_card.dart` | Service discovery row (`PdAppCard`, optional muted style). |
| `lib/src/features/home/presentation/widgets/customer_shortcut_card.dart` | Compact shortcut rows (পশু, নলেজ). |
| `lib/src/features/home/presentation/widgets/customer_recent_request_card.dart` | `serviceRequestsListProvider` + empty/error + `context.push` to detail. |

### Files updated

| File | Change |
|------|--------|
| `lib/src/features/home/home_shell_screen.dart` | হোম tab: `CustomerHomeScreen` with `onOpenAnimalsTab` / `onOpenRequestsTab` (`IndexedStack` indices 1 and 2). |
| `lib/src/features/home/presentation/customer_shell_tab_placeholders.dart` | Removed obsolete `HomeTabPlaceholderScreen` (replaced by dashboard). |

### Files removed

| File | Reason |
|------|--------|
| `lib/src/features/home/home_screen.dart` | Unused legacy menu + debug API card; superseded by `CustomerHomeScreen` to avoid duplicate home UIs. |

### Behaviour summary

- **Mock data:** Greeting uses fixed Bangla strings; এলাকা chip shows **“এলাকা: ঢাকা (উদাহরণ)”** until prefs/API exist.
- **Recent requests:** Uses real **`serviceRequestsListProvider`** when authenticated; loading/error/empty states handled in Bangla.
- **Online consultation:** Muted card + **SnackBar** (“শীঘ্রই”) — no new route.
- **Icons:** `Icons.medical_services_outlined` used for home-visit card (`home_health_outlined` not available on current Flutter icon set).

### Checklists (post-implementation)

**UI (§6):** All items addressed in `CustomerHomeScreen` + widgets.

**Functional (§7):** All visible actions navigate or show intentional stub (SnackBar / secondary buttons).

**Tests (§8):** `flutter analyze` clean; `flutter test` passes.

### Intentional TODOs

- Pre-select `ServiceRequestType` via GoRouter `extra` or booking draft when product requests direct deep links from home CTAs.
- Replace mock এলাকা with saved location / picker.
- Optional widget test pumping `/home` with mocked session + providers.

---

## 1. Current audit findings

### 1.1 Flutter app structure (high level)

| Area | Location | Notes |
|------|-----------|--------|
| Entry | `lib/main.dart` | `ProviderScope` → `PraniDoctorApp`. |
| App shell | `lib/src/app/app.dart` | `MaterialApp.router`, `AppTheme`, **default locale `bn_BD`**. |
| Routing | `lib/src/app/router.dart` | `GoRouter` + `sessionNotifierProvider` refresh; root `pdRootNavigatorKey`. |
| Theme / tokens | `lib/src/app/theme.dart`, `lib/src/core/theme/*`, `lib/src/core/constants/*` | Green/teal seed (`PdPalette.primaryGreen`), rounded cards (`PdRadii.card`), medical surface. |
| Design barrel | `lib/src/core/design_system.dart` | Exports spacing, palette helpers, `PdAppCard`, `PdPageHeader`, buttons, placeholders. |
| Features | `lib/src/features/*` | Vertical slices: `auth`, `animals`, `home`, `notifications`, `onboarding`, `providers`, `service_requests`, `session`, `splash`, `tutorials`. |

### 1.2 Post-login “home” route (actual behavior)

| Step | Behavior |
|------|-----------|
| OTP success | `OtpVerifyScreen` calls `context.go(HomeShellScreen.routePath)` (`/home`). |
| Splash (returning user) | With valid stored token + onboarding done → `context.go(HomeShellScreen.routePath)`. |
| Router redirect | Authenticated user on `/login` (or OTP child) → redirected to `/home`. |

**Customer dashboard route:** **`HomeShellScreen`** at path **`/home`** — not a standalone `HomeScreen` route.

### 1.3 Home tab vs `HomeScreen` (important gap)

| Widget | File | Wired into shell? |
|--------|------|-------------------|
| **First tab body** | `CustomerHomeScreen` in `lib/src/features/home/presentation/customer_home_screen.dart` | **Yes** — `IndexedStack` index `0` in `home_shell_screen.dart`. |
| **Legacy `HomeScreen`** | *(removed)* | Was unwired; deleted to prevent duplicate home UIs. |
| Docs | `docs/tasks/M02_APP_SHELL_NAVIGATION_PLAN.md`, `docs/MOBILE_UI_IMPLEMENTATION_MASTER_PLAN.md` | Describe embedding **`HomeScreen`** in the shell; **implementation uses placeholders instead** (M02 divergence). |

**Implication for M04:** ~~Implement the Bengali-first dashboard on the **shell’s হোম tab**~~ **Done:** `CustomerHomeScreen` replaces the হোম placeholder. Legacy `HomeScreen` removed.

### 1.4 Routing / navigation setup

- **Package:** `go_router: ^17.2.3` (`pubspec.yaml`) — no new router dependency anticipated.
- **Shell navigation:** Local **`IndexedStack` + Material 3 `NavigationBar`** inside `HomeShellScreen` (not `ShellRoute`).
- **Customer feature pushes:** Screens expose `static const routePath` / `routeName`; features use `context.push` / `context.go`.

**Relevant existing routes for home CTAs:**

| Feature | Path constant | Screen |
|---------|----------------|--------|
| Notifications | `NotificationsListScreen.routePath` → `/notifications` | `notifications_list_screen.dart` |
| Knowledge / tutorials | `TutorialListScreen.routePath` → `/tutorials` | `tutorial_list_screen.dart` |
| Doctor finder | `DoctorListScreen.routePath` → `/providers/doctors` | `doctor_list_screen.dart` |
| AI technician finder | `TechnicianListScreen.routePath` → `/providers/technicians` | `technician_list_screen.dart` |
| New booking / service request | `BookingWizardScreen.routePath` → `/booking/new` | `booking_wizard_screen.dart` |
| Service request detail | `/service-requests/:requestId` | `ServiceRequestDetailScreen` in `service_requests_tab_screen.dart` |

**Animals:** `AnimalListScreen` is hosted inside a **nested `Navigator`** in `AnimalsTabScreen` — **no top-level GoRoute** for animals today. Shortcuts from হোম → “আমার পশু” need an explicit pattern (see §4).

### 1.5 Theme / design system / components (reuse for M04)

| Asset | Use on home |
|-------|----------------|
| `AppTheme` / `Theme.of(context).colorScheme` | Primary green, surfaces, cards. |
| `pdScreenPadding`, `pdReadableMaxWidth` | `screen_padding.dart` — consistent horizontal padding and readable width cap. |
| `PdAppCard` | Rounded cards; optional `useShadow` for elevated promo tiles. |
| `PdPageHeader` | Section titles; optional `trailing` for notification icon row. |
| `PdPrimaryButton` / `PdSecondaryButton` | Emergency CTA / secondary actions. |
| `PdRadii`, `PdSpacing`, `PdShadows` | Match M01/M02 rounded “green/white” mobile direction. |

### 1.6 Session / profile data for greeting & location

- **`SessionState`** (`session_notifier.dart`): `role`, `isAuthenticated` only — **no display name or area**.
- **No customer profile provider** found for “হ্যালো, {নাম}” without new API work (out of scope).
- **Location / এলাকা:** Not stored in session; treat as **mock or static placeholder** until a location picker + persistence task exists.

### 1.7 Service types (booking alignment)

`ServiceRequestType` (`service_request_model.dart`) includes:

- `EMERGENCY_DOCTOR`, `DOCTOR_HOME_VISIT`, `AI_SERVICE`, `ONLINE_CONSULTATION_LATER` (with Bangla `labelBn`).

Booking wizard does **not** currently read **route `extra` / query** to pre-select a type (verified by absence of `GoRouterState` usage in booking UI). CTAs should **`push` `/booking/new`** and let the user choose the type on the wizard’s flow **unless** a tiny follow-up passes initial selection via provider (optional future enhancement — not required for first M04 UI drop).

### 1.8 Existing tests that may be affected

| Test file | Scope | M04 risk |
|-----------|--------|----------|
| `test/widget_test.dart` | Pumps `PraniDoctorApp`, expects text containing **`Prani Doctor`** on first frame (splash). | **Low** — remains true unless splash/router initial route changes. |
| `test/otp_auth_test.dart` | Unit tests for phone + token parsing. | **None** — no UI. |

**Recommendation:** After implementation, optionally add a **`test/features/home/...`** widget test that pumps logged-in shell or home tab with **overridden `sessionNotifierProvider`** / router — not strictly required if `flutter test` stays green.

---

## 2. Files likely to be changed (implementation phase)

| Action | Path | Reason |
|--------|------|--------|
| **Update** | `lib/src/features/home/home_shell_screen.dart` | Optionally pass a **`VoidCallback`** or tab index callback into the হোম tab for “আমার পশু” shortcut (if avoiding new routes). |
| **Update** | `lib/src/features/home/presentation/customer_shell_tab_placeholders.dart` | Replace **`HomeTabPlaceholderScreen`** body with the new dashboard **or** make it a thin delegate to a new file. |
| **Create** | `lib/src/features/home/presentation/customer_home_screen.dart` (name flexible) | Main dashboard scaffold + scroll layout. |
| **Create** | `lib/src/features/home/presentation/widgets/*.dart` | Small reusable sections (header, service cards, status card). |
| **Update or remove** | `lib/src/features/home/home_screen.dart` | Merge useful navigation patterns then **delete** or slim to avoid duplicate home; update any docs that still claim this screen is embedded. |
| **Optional** | `lib/src/app/router.dart` | Only if adding a **minimal** `/animals` (or similar) push route for animal shortcut — prefer **tab-switch callback** first to avoid scope creep. |
| **Docs** | `docs/MOBILE_UI_IMPLEMENTATION_MASTER_PLAN.md` / task index | Small consistency fixes **only if** the team wants docs aligned after implementation (optional). |

**Explicitly out of scope:** Backend, web repo, `pranidoctor-web`, unrelated tabs’ full implementations.

---

## 3. Proposed screen / widget structure

### 3.1 Layout (9:16–friendly)

- **`CustomScrollView`** with **`SliverAppBar` / `SliverToBoxAdapter`** sections (or **`Scaffold` + single scroll**) so content stacks vertically on tall phones.
- **`SafeArea`** respected; horizontal padding via **`pdScreenPadding`**; optional **`Center` + `ConstrainedBox(maxWidth: pdReadableMaxWidth)`** for large phones.

### 3.2 Section breakdown (Bengali-first)

| Section | Widget idea | Notes |
|---------|-------------|--------|
| Top bar | `CustomerHomeHeader` | Greeting + **এলাকা** chip/text + **notification `IconButton`** (`context.push(NotificationsListScreen.routePath)`). |
| Emergency | Full-width **`PdPrimaryButton`** or prominent **`PdAppCard`** | `push(BookingWizardScreen.routePath)`; optional subtitle that user picks **জরুরি ডাক্তার** in wizard. |
| Doctor home visit | `ServicePromoCard` | Icon + title + short Bangla blurb → same booking route (type chosen in wizard). |
| AI technician | `ServicePromoCard` | Link to **`TechnicianListScreen`** and/or booking — product choice: **browse technicians** vs **book AI সেবা**; plan default: **`TechnicianListScreen`** for parity with existing finder. |
| Online consultation | `ServicePromoCard` (muted / “শীঘ্রই” or disabled) | Placeholder only per requirements — **`SnackBar`** or non-navigating **`onTap: null`** with explanatory text. |
| Animal profile shortcut | Compact row/card | Tab switch (preferred) or future route. |
| Recent request | `RecentRequestCard` | `ConsumerWidget` watching **`serviceRequestsListProvider`**; fallback mock when loading/error/empty. |
| Knowledge | Compact tile/card | `push(TutorialListScreen.routePath)`. |

### 3.3 Reusable widgets to extract (modular, low-risk)

- **`CustomerHomeHeader`** — greeting, location line, trailing actions.
- **`PdHomeSectionTitle`** — optional thin wrapper around `PdPageHeader` or `Text` + spacing for consistency.
- **`CustomerServiceCard`** — wraps `PdAppCard` with icon, title, subtitle, `onTap`.
- **`RecentServiceRequestSummaryCard`** — maps `ServiceRequest` / empty state to Bangla copy.

---

## 4. Route / navigation integration plan

| CTA | Navigation | Safety |
|-----|------------|--------|
| Notification bell | `context.push(NotificationsListScreen.routePath)` | Route exists. |
| জরুরি ডাক্তার | `context.push(BookingWizardScreen.routePath)` | Route exists; wizard selects type. |
| বাড়িতে ডাক্তার | `context.push(BookingWizardScreen.routePath)` | Same. |
| AI টেকনিশিয়ান | `context.push(TechnicianListScreen.routePath)` | Route exists. |
| ডাক্তার খুঁজুন (if exposed) | `context.push(DoctorListScreen.routePath)` | Route exists. |
| নলেজ / টিউটোরিয়াল | `context.push(TutorialListScreen.routePath)` | Route exists. |
| সাম্প্রতিক অনুরোধ → detail | `context.push(ServiceRequestDetailScreen.routePathFor(id))` (`service_requests_tab_screen.dart`) | Matches existing list behavior. |
| আমার পশু | **Option A:** `HomeShellScreen` exposes `ValueChanged<int> onTabSelected` and হোম tab calls `onTabSelected(1)`. **Option B:** add `GoRoute` `/animals` pushing `AnimalListScreen` / wrapper. | Prefer **A** to avoid router duplication and nested navigator conflicts. |
| অনলাইন পরামর্শ | No route until product defines flow | Placeholder UX only. |

---

## 5. Placeholder data strategy (API not required)

| Data | Strategy |
|------|-----------|
| User name | Generic greeting: e.g. **“হ্যালো!”** / **“স্বাগতম”** — no API. |
| এলাকা | Static mock: e.g. **“এলাকা: ঢাকা (উদাহরণ)”** or **“এলাকা নির্বাচন শীঘ্রই”** until saved prefs + picker exist. |
| Recent request row | **Preferred:** `ref.watch(serviceRequestsListProvider)` — first item summary + deep link; **empty:** Bangla empty state + button to booking or Requests tab. |
| Errors / offline | Use simple Bangla message + dismiss; **do not** add new backend endpoints. |

---

## 6. UI checklist

- [ ] Bengali-first strings for all visible labels (avoid English except brand where needed).
- [ ] Greeting section visible above the fold on typical phones.
- [ ] Location / এলাকা indicator (mock or “শীঘ্রই”).
- [ ] Notification icon in header → inbox.
- [ ] Distinct **জরুরি ডাক্তার** CTA (high contrast).
- [ ] **ডাক্তার — বাড়িতে পরিদর্শন** service card.
- [ ] **AI টেকনিশিয়ান** service card.
- [ ] **অনলাইন পরামর্শ** placeholder ( clearly non-production or “শীঘ্রই”).
- [ ] **আমার পশু** shortcut.
- [ ] **সাম্প্রতিক সেবা অনুরোধ** status/summary card.
- [ ] **জ্ঞান / টিউটোরিয়াল** shortcut.
- [ ] Green/white rounded aesthetic via **`PdAppCard`** + theme surfaces.
- [ ] Vertical layout suitable for **9:16** portrait; no reliance on landscape.

---

## 7. Functional checklist

- [ ] Every actionable control either navigates to an **existing** route or shows an intentional **stub** (e.g. SnackBar / disabled card with Bangla explanation).
- [ ] No silent **`default: break`** on user-visible tiles (addressing prior audit in `MVP_AUDIT_AND_LAUNCH_CHECKLIST.md` for legacy `HomeScreen`).
- [ ] Mock/local data only where APIs are absent; **no backend changes**.
- [ ] Does not implement unrelated pages (profile tab, animals CRUD, full booking redesign).
- [ ] Widgets split for reuse (header, cards, recent status).

---

## 8. Test checklist

- [ ] `flutter analyze` clean.
- [ ] `flutter test` green (`widget_test`, `otp_auth_test`).
- [ ] (Optional) Widget test: home tab builds with **`ProviderScope`** + fake session authenticated.
- [ ] (Optional) Golden / screenshot tests — **not required** unless team adopts them elsewhere.

---

## 9. Risks / notes

- **Duplicate home:** `HomeScreen` vs new dashboard — resolve by consolidation to prevent future confusion.
- **Animals shortcut without GoRoute:** Tab index callback from `HomeShellScreen` is the lowest-risk pattern; avoid deep-link complexity in M04.
- **Booking wizard overload:** Multiple CTAs pushing the same route is acceptable; consider later **deep-link `extra`** for pre-selected `ServiceRequestType` (small follow-up).
- **`serviceRequestsListProvider` on home:** May trigger API calls when opening হোম tab — acceptable; handle loading/error gracefully without blocking the whole dashboard.
- **Online consultation:** Product/legal readiness unknown — keep strictly placeholder.

---

## 10. Implementation steps (ordered)

1. Add **`customer_home_screen.dart`** (and `widgets/` as needed) using **`PdAppCard`**, **`pdScreenPadding`**, **`Theme`** roles only (no stray hex).
2. Implement **header** (greeting, mock location, notification icon).
3. Implement **service cards** + **emergency CTA** with **`context.push`** to existing routes; online consultation = placeholder.
4. Wire **recent request** card to **`serviceRequestsListProvider`** with mock/empty fallback copy.
5. Add **tutorial** shortcut → **`TutorialListScreen`**.
6. Implement **animals** shortcut via **`HomeShellScreen`** tab callback **or** documented router addition — prefer callback.
7. Replace **`HomeTabPlaceholderScreen`** usage in **`IndexedStack`** with the new dashboard widget.
8. Remove or merge **`home_screen.dart`**; grep repo for stale imports/references.
9. Run **`flutter analyze`** + **`flutter test`**; fix regressions.
10. Quick manual pass on small + tall emulator (9:16).

---

## 12. Final verification (Task M04)

**Run date:** 2026-05-09 (local verification run).

| Command | Result |
|---------|--------|
| **`dart format .`** | **Pass** — formatted **81 files**; **5 files changed** (all under `lib/src/features/home/presentation/`, M04 customer home). |
| **`flutter analyze`** | **Pass** — `No issues found!` |
| **`flutter test`** | **Pass** — **9** tests passed (`otp_auth_test.dart`, `widget_test.dart`). |

**Fixes applied during this verification**

- Applied **`dart format`** only; no logic changes. Reformatted:
  - `lib/src/features/home/presentation/customer_home_screen.dart`
  - `lib/src/features/home/presentation/widgets/customer_emergency_cta_card.dart`
  - `lib/src/features/home/presentation/widgets/customer_home_header.dart`
  - `lib/src/features/home/presentation/widgets/customer_recent_request_card.dart`
  - `lib/src/features/home/presentation/widgets/customer_service_action_card.dart`

**Known unrelated / pre-existing issues**

- None observed during this run. Analyzer and full test suite completed successfully.

**M04 files status**

- M04 customer home sources are **clean** per analyzer and tests after format.

---

**End of plan.**
