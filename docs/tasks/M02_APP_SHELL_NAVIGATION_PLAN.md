# Task M02 — App Shell, Splash, Onboarding & Navigation

**Product:** Prani Doctor (Animal Doctors) — Bangladesh-first veterinary mobile app.  
**Repo:** `pranidoctor_mobile` (local: `D:\PraniDoctor\pranidoctor_mobile`)  
**Status:** **Planning only** — this document is the audit + implementation plan. No code changes were made to produce it.

**Depends on:** M01 — Design System & Theme (`docs/tasks/M01_DESIGN_SYSTEM_THEME_PLAN.md`, implemented).  
**Related:** `docs/MOBILE_UI_DESIGN_SYSTEM.md`, `docs/KNOWLEDGE_HUB_MOBILE_PLAN.md` (tutorials / knowledge hub).

---

## 1. Current app entry / routing audit summary

### 1.1 Entry point

| File | Role |
|------|------|
| `lib/main.dart` | `WidgetsFlutterBinding.ensureInitialized()`, `runApp(ProviderScope(child: PraniDoctorApp()))`. |
| `lib/src/app/app.dart` | `ConsumerWidget` → `MaterialApp.router` with `ref.watch(goRouterProvider)`, `AppTheme.light` / `dark`, **default locale `bn_BD`**, `supportedLocales` `bn_BD` + `en_US`, standard Material/Cupertino localization delegates. |

### 1.2 Routing (GoRouter)

| File | Role |
|------|------|
| `lib/src/app/router.dart` | **`goRouterProvider`** (`Provider<GoRouter>`): `initialLocation: SplashScreen.routePath`, `navigatorKey: pdRootNavigatorKey`, **`refreshListenable`** driven by `sessionNotifierProvider` so auth changes re-run redirects. |
| `lib/src/app/navigation_keys.dart` | `pdRootNavigatorKey` — root `GlobalKey<NavigatorState>` for global navigation (e.g. 401 → login). |

**Customer flow (relevant to shell):**

- `/splash` → `SplashScreen` — hydrates session from storage, reads onboarding flag, then `go` to onboarding, home shell, or login.
- `/onboarding` → `OnboardingScreen` — paged Bengali copy; completion sets `SharedPreferences` flag and `go` to login.
- `/login` → `LoginEntryScreen` — OTP customer login; success `go` to `/home`.
- `/home` → `HomeShellScreen` — **local** `IndexedStack` + Material 3 `NavigationBar` (not a `ShellRoute` in GoRouter).

**Parallel routes:** `/doctor/*` (doctor login/home), provider lists/details, `/notifications`, `/tutorials` (+ `:slugOrId`), booking wizard, service-request detail. Redirect logic treats `/doctor` subtree as public for routing purposes; customer protected paths redirect to `/login` when `!auth.isAuthenticated`, except splash/onboarding/login.

**Auth-safe fallback:** `_isPublicCustomerPath` whitelists splash, onboarding, login. Any other customer path without session → **`LoginEntryScreen.routePath`**. Logged-in user hitting `/login` → redirect to **`HomeShellScreen.routePath`**. Doctor routes bypass customer auth redirect via `loc.startsWith('/doctor')`.

### 1.3 Bottom shell today

`lib/src/features/home/home_shell_screen.dart`:

- **Four** tabs (IndexedStack order): **Home** → **Service requests** → **Animals** → **Profile** (Bengali labels: হোম, অনুরোধ, আমার পশু, প্রোফাইল).
- **Gap vs M02 spec:** Spec asks for **five** tabs in order: Home, Animals, Requests, Knowledge/Help, Profile. Knowledge is **missing**; tab **order** differs from spec.

### 1.4 Splash / onboarding / login (existence)

| Screen | Path | Notes |
|--------|------|--------|
| Splash | `/splash` | Brand + loader; uses `Theme` + `pdScreenPadding`; session hydrate + onboarding prefs. |
| Onboarding | `/onboarding` | `PageView` + indicators; Bengali strings; finishes to **login always** (not home), which is acceptable for first-run; returning users skip via prefs in splash. |
| Login entry | `/login` | Full OTP flow; navigates to home on success. |

Route **names** already exist per screen (`routeName` statics, e.g. `splash`, `homeShell`) for `context.goNamed` where needed.

---

## 2. GoRouter — present or not?

**Present.** `pubspec.yaml` declares `go_router: ^17.2.3`. The app uses it in `router.dart` and feature screens (`go`, `push`) — **no change to package choice** for M02.

---

## 3. Design system / theme references (M01)

Use these for any M02 UI polish (splash, onboarding, nav shell); **do not fork** styling.

| Asset | Path |
|--------|------|
| **Theme** | `lib/src/app/theme.dart` — `AppTheme.light` / `dark`, M3, `PdPalette`, `PdSemanticColors`, `PdTypography`, `PdRadii`, `PdSpacing`, `NavigationBar` theming. |
| **Barrel** | `lib/src/core/design_system.dart` — exports tokens + `Pd*` widgets (`pd_buttons`, `pd_page_header`, `pd_async_states`, etc.). |
| **Screen padding** | `lib/src/app/screen_padding.dart` — `pdScreenPadding`, `pdReadableMaxWidth`. |
| **Spec narrative** | `docs/MOBILE_UI_DESIGN_SYSTEM.md` |
| **M01 task record** | `docs/tasks/M01_DESIGN_SYSTEM_THEME_PLAN.md` |

**M02 guidance:** Prefer `Theme.of(context)` + `pdScreenPadding` already used on splash/onboarding/login; optionally adopt `PdPrimaryButton` / cards where it reduces duplication. Keep changes **minimal** unless a screen is actively being reworked.

---

## 4. Exact files to create / update (implementation phase)

Scope: **app shell and navigation only** — wire five tabs, align public flow, placeholders where a feature is not yet tab-first. **No backend** changes.

### 4.1 Splash screen

| Action | Path |
|--------|------|
| **Update** | `lib/src/features/splash/splash_screen.dart` — Optional: M01-aligned visuals (e.g. semantic colors, `Pd*` if justified), keep **same** routing contract (`routePath`, `routeName`, delay + hydrate + prefs logic). **Do not** change `initialLocation` in router without updating `widget_test` pump timing if needed. |

### 4.2 Onboarding sequence

| Action | Path |
|--------|------|
| **Update** | `lib/src/features/onboarding/onboarding_screen.dart` — Copy/flow tweaks only if required for product tone; keep `SharedPreferences` key in sync with splash (`pd_onboarding_done`). Preserve **`StatefulWidget`** + `PageController` pattern unless a small Riverpod hook is needed for tests only. |

### 4.3 Login entry route

| Action | Path |
|--------|------|
| **Update (minimal)** | `lib/src/features/auth/login_entry_screen.dart` — Only if M02 requires navigation copy or deep-link prep; route already registered in `router.dart`. |
| **Reference** | `lib/src/app/router.dart` — `LoginEntryScreen` route block; redirect rules for authenticated user. |

### 4.4 Bottom navigation shell

| Action | Path |
|--------|------|
| **Update** | `lib/src/features/home/home_shell_screen.dart` — (1) Reorder tabs to **Home → Animals → Requests → Knowledge/Help → Profile**. (2) Add fifth tab body. (3) Keep **`NavigationBar`** + `IndexedStack` to match M01 theme unless product explicitly requests `NavigationBar` vs `BottomNavigationBar` change. (4) Normalize profile tab padding with `pdScreenPadding` where trivial (M01 noted fixed `20` horizontal). |

### 4.5 Placeholder tabs (target behavior)

| Tab | Spec label (EN) | Suggested BN label | Implementation |
|-----|-----------------|---------------------|----------------|
| Home | Home | হোম (existing) | **Existing** `HomeScreen` — no feature expansion. |
| Animals | Animals | আমার পশু (existing) | **Existing** `AnimalsTabScreen`. |
| Requests | Requests | অনুরোধ (existing) | **Existing** `ServiceRequestsTabScreen`. |
| Knowledge / Help | Knowledge/Help | e.g. **সহায়তা** or **নলেজ** | **New thin tab screen** recommended: `lib/src/features/knowledge/presentation/knowledge_tab_screen.dart` (or `help/`) wrapping **`TutorialListScreen`** as child **or** a placeholder `Scaffold` + `FilledButton.tonal` / `ListTile` that `context.push(TutorialListScreen.routePath)` to reuse existing **Knowledge Hub** at `/tutorials` **without duplicating** heavy list logic in the shell file. Pick one: embedded list **or** hub entry — **minimal** is a short placeholder + push to `/tutorials`. |
| Profile | Profile | প্রোফাইল (existing) | **Existing** `_ProfileTab` in same file — notifications entry + sign-out only. |

### 4.6 Route names / constants

| Approach | Detail |
|----------|--------|
| **Current pattern** | Each screen owns `static const routePath` + `static const routeName` — **keep** for consistency. |
| **Optional (low priority)** | Add `lib/src/app/pd_routes.dart` (or similar) re-exporting path strings **only** if multiple features need the same constant without importing each other’s widgets — **not required** if imports stay acyclic. |

### 4.7 Safe fallback when auth is not completed

| Mechanism | Location |
|------------|----------|
| GoRouter `redirect` | `lib/src/app/router.dart` — unauthenticated users on protected paths → `/login`; public paths + `/doctor/*` excluded as today. |
| Splash | Sends to onboarding / login / home based on prefs + `sessionNotifierProvider` after `hydrateFromStorage()`. |
| **Preserve** | Do not remove `refreshListenable` / `sessionNotifierProvider` listen — required so shell and redirects update after OTP sign-in/sign-out. |

### 4.8 New file(s) — suggested

| Path | Purpose |
|------|---------|
| `lib/src/features/knowledge/presentation/knowledge_tab_screen.dart` | Fifth tab: placeholder **or** thin wrapper around tutorials hub (Bengali `AppBar` title consistent with hub). |

**No new dependency** expected for M02.

---

## 5. Implementation boundaries

- **In scope:** Shell tab count/order/labels, splash/onboarding/login **navigation and light UI** alignment with M01, route table consistency, minimal placeholders, `dart format` / `analyze` / `test` green.
- **Out of scope:** Backend APIs, web repo, doctor-flow redesign, deep linking product spec, full Knowledge Hub redesign (already has `TutorialListScreen`), booking/provider feature work, new packages.
- **Do not** replace GoRouter with another router; **do not** move shell to `ShellRoute` unless there is a clear need (deferred — higher risk for same milestone).

---

## 6. Testing plan

After implementation:

1. **`dart format .`** — repo-wide formatting.
2. **`flutter analyze`** — zero new issues; fix or suppress only with justification.
3. **`flutter test`** — `test/widget_test.dart` pumps `PraniDoctorApp` and expects **“Prani Doctor”** text after short delay; ensure splash timing / initial route still satisfy the test (adjust pump duration only if necessary).

**Optional later:** Widget test that mocks `SharedPreferences` / overrides `goRouterProvider` to assert tab indices — **not required** for minimal M02 if cost is high.

---

## 7. Risk notes

| Risk | Mitigation |
|------|------------|
| Breaking **entrypoint** | Keep `lib/main.dart` and `PraniDoctorApp` contract unchanged; only touch routing if adding routes — shell changes stay inside `HomeShellScreen` + optional new tab file. |
| **GoRouter** vs **IndexedStack** desync | Deep links to `/tutorials` remain full-screen routes; tab state is **in-memory** only — document that “return from tutorial” returns to pushed route stack, not a selected tab index, unless `go` with query is added later. |
| **Onboarding → login** always | Acceptable for first completion; splash already routes authenticated users to home when onboarding is done — **avoid** sending fresh installs with valid token to login-only without hydration order regression. |
| **Five tabs** on small screens | `NavigationBar` with five destinations is supported in M3; watch label length in Bengali — use short labels if overflow. |
| **Over-refactor** | Keep placeholders **minimal**; do not migrate all features to `Pd*` widgets in the same PR as tab shell work. |
| **router.dart import hygiene** | `ServiceRequestDetailScreen` is defined in `service_requests_tab_screen.dart` — already referenced by router; any new routes should follow existing import patterns. |

---

## 8. Deliverable checklist (for implementation PR)

- [ ] Five-tab shell: Home, Animals, Requests, Knowledge/Help, Profile (Bengali-first labels).
- [ ] Splash → onboarding → login / home flow unchanged in **behavior** unless fixing a documented bug.
- [ ] Auth redirect + doctor bypass unchanged in intent.
- [ ] M01 theme/design system referenced for touched UI.
- [ ] `dart format`, `flutter analyze`, `flutter test` pass.

---

## 9. Audit summary (executive)

The app **already** uses **GoRouter + Riverpod**, starts at **splash**, supports **onboarding** and **customer login**, and uses a **customer home shell** with **four** bottom-nav tabs. M02 work is primarily **extending and reordering** the shell to **five** tabs (add **Knowledge/Help**), aligning order with the product spec, and **lightly** aligning splash/onboarding with M01 tokens where appropriate — **without** backend changes or unrelated features.
