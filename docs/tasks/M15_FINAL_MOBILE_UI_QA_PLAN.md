# M15 — Final Mobile UI Polish & QA

## Implementation status (2026-05-09)

**Status:** **Completed** with documented placeholders (shell logins, social login, mock billing/knowledge when configured).

### Fixes completed

| Area | Change |
|------|--------|
| **Home menu** | Removed duplicate **আমার পশু** row (tab already exists). **জরুরি ডাক্তার ডাকুন** → navigates to **ডাক্তার খুঁজুন** (same route as item 2 — fastest safe path to help). **চিকিৎসার ইতিহাস** → switches bottom nav to **অনুরোধ** tab via `homeShellTabIndexProvider`. |
| **Bottom nav ↔ home** | Added `homeShellTabIndexProvider` (`NotifierProvider`) so home tiles can select tab **১** without breaking `IndexedStack`. `HomeShellScreen` is now `ConsumerWidget` driven by this provider. |
| **Debug API URLs** | Customer login API footer, home API card, doctor login/home API lines, technician login API line — shown **only when `kDebugMode`** (`foundation.dart`). Release/profile builds hide them. |
| **Technician login copy** | Mock mode: Bengali **ডেমো মোড** message (no raw env var). Live: Bengali sentence about server endpoints. Disabled email hint → **টেক@উদাহরণ.কম**. |
| **Doctor login** | Email hint → **ডাক্তার@উদাহরণ.কম**; API line debug-only. |
| **Splash / app title** | Bengali-first: headline **প্রাণি ডাক্তার**, secondary **Prani Doctor**. `MaterialApp.title` → **প্রাণি ডাক্তার**. |
| **About** | English subtitle demoted to `labelLarge` for Bengali-first hierarchy. |
| **Onboarding** | **টেকনিশিয়ান** spelling normalized (matches rest of app). |
| **Profile edit** | Email hint → **যেমন: নাম@ডোমেইন.কম**. |
| **Service request detail** | Load error copy aligned to **লোড করা যায়নি** (matches list). |
| **Notifications** | Timestamps use `DateFormat('d MMM yyyy, HH:mm', Localizations.localeOf(context).toString())` for locale-aware formatting. |
| **Knowledge hub** | Inline retry button **রিফ্রেশ** → **আবার চেষ্টা করুন**. |
| **Booking wizard** | `MediaQuery.viewInsetsOf(context).bottom` padding on scaffold body to reduce keyboard overlap on narrow screens. |
| **Login OTP** | ListView bottom padding includes `viewInsets.bottom`. |
| **Logout dialog** | Icon, clearer Bengali body copy, primary actions **থাকুন** / **লগআউট**. |

### Files changed

- `lib/src/features/home/application/home_shell_tab_provider.dart` *(new)*
- `lib/src/features/home/home_shell_screen.dart`
- `lib/src/features/home/home_screen.dart`
- `lib/src/features/auth/login_entry_screen.dart`
- `lib/src/features/auth/doctor/presentation/doctor_login_screen.dart`
- `lib/src/features/auth/technician/presentation/technician_login_screen.dart`
- `lib/src/features/home/doctor/presentation/doctor_home_screen.dart`
- `lib/src/features/splash/splash_screen.dart`
- `lib/src/app/app.dart`
- `lib/src/features/profile/presentation/about_screen.dart`
- `lib/src/features/profile/presentation/edit_profile_screen.dart`
- `lib/src/features/profile/presentation/widgets/logout_confirm_dialog.dart`
- `lib/src/features/onboarding/onboarding_screen.dart`
- `lib/src/features/service_requests/presentation/service_requests_tab_screen.dart`
- `lib/src/features/service_requests/presentation/booking_wizard_screen.dart`
- `lib/src/features/notifications/presentation/notifications_list_screen.dart`
- `lib/src/features/knowledge_hub/presentation/knowledge_post_list_screen.dart`

### Plan vs code (conflict resolution)

- **Original plan** allowed snackbar-only for unimplemented home rows. **Implementation:** **জরুরি** opens **ডাক্তার খুঁজুন** (same as the adjacent menu item) so users reach doctors immediately instead of a dead tap—**smallest safe routing fix** with no new routes.

### Remaining placeholders (by design)

- Doctor / AI technician **খোলস** login (disabled email/password; proceed button for UX demo).
- Social login buttons disabled (**শীঘ্রই**).
- `AppConfig.useMockBillingUi`, mock knowledge posts, `USE_MOCK_TECHNICIAN_API` behavior — backend/feature flags.
- Support phone mask in **সাহায্য ও সহায়তা** until real number.
- Store version string manual until `package_info_plus` (see About screen).

### Manual QA notes

- Verify **release** build (`flutter build apk --release`) shows **no** debug API blocks on home/login/doctor/technician.
- On **360×800** emulator: OTP screen + booking wizard steps with keyboard open — confirm no overflow.
- Tap **চিকিৎসার ইতিহাস** on home → lands on **অনুরোধ** tab with list.
- Logout from profile → confirm dialog **থাকুন** dismisses, **লগআউট** clears session and returns to login.

---

## Final verification — Task M15 closure

**Verification run:** 2026-05-09 (local workspace `D:\PraniDoctor\pranidoctor_mobile`)

### Automated command results

| Command | Result | Notes |
|---------|--------|--------|
| `dart format .` | **PASS** | `Formatted 101 files (0 changed)` — exit code 0 |
| `flutter analyze` | **PASS** | `No issues found!` |
| `flutter test` | **PASS** | **5** tests passed (`billing_payment_summary_widget_test`, `technician_ai_badge_test` ×3, `widget_test`) |

### Final QA checklist status (20 items)

| # | Item | Status |
|---|------|--------|
| 1 | Splash / onboarding | **PASS** — routing + prefs; code-reviewed |
| 2 | Login / OTP | **PASS** — OTP flow; API base URL **debug-only** (placeholder documented for retail) |
| 3 | Bottom navigation | **PASS** — `IndexedStack` + `homeShellTabIndexProvider` |
| 4 | Home | **PASS** — menu links + tab switch for history |
| 5 | Animal profiles | **PASS** — list/detail/form + nested tab navigator |
| 6 | Provider finder | **PASS** — doctors/technicians lists + detail + filters |
| 7 | Booking flow | **PASS** — wizard + validation; keyboard inset padding |
| 8 | Request tracking | **PASS** — list, detail route, cancel, billing card |
| 9 | Doctor workflow vs customer | **PASS** — `/doctor/*` exempt from customer JWT redirect |
| 10 | AI technician vs customer | **PASS** — `/technician/*` exempt; stub login documented |
| 11 | Billing summary | **PASS** — customer card on detail; mock overlay via `AppConfig` when enabled |
| 12 | Notification center | **PASS** — list, filters, empty/error, locale-aware timestamps |
| 13 | Knowledge hub | **PASS** — hub, categories, posts, detail; mock fallback documented |
| 14 | Profile / settings / logout | **PASS** — edit, area, settings, help, about; logout dialog |
| 15 | Bengali labels | **PASS** — M15 orthography/hints/branding applied; minor English retained as secondary where noted |
| 16 | Loading / error / empty states | **PASS** — present on major async surfaces (prior audit + no regressions) |
| 17 | 9:16 Android safety | **PASS** (code) — scroll views + `viewInsets` on login/booking; **manual** device pass still recommended |
| 18 | `dart format` | **PASS** | 
| 19 | `flutter analyze` | **PASS** |
| 20 | `flutter test` | **PASS** |

### Known placeholders (unchanged)

- Doctor / technician **খোলস** login; disabled social login (**শীঘ্রই**).
- `AppConfig` mocks (billing UI preview, technician API, knowledge fallback) — enable only for QA/dev.
- Support phone mask; manual About version until `package_info_plus`.

### Known limitations (document only — out of M15 scope)

- **Device/emulator:** Automated tests do not exercise full gesture navigation or all API failure modes; manual RC checklist remains in master plan.
- **i18n:** No ARB/`gen-l10n`; locale is `bn_BD` with inline strings.
- **Duplicate `_ErrorBody` widgets:** Consolidation deferred (optional refactor).
- **Doctor “সাইন আউট”** label is English borrow — cosmetic follow-up if desired.

### Recommended next steps after mobile MVP QA

1. Run **release** build smoke test (no debug API banners; OTP against staging API).
2. Complete **backend** customer JWT lifecycle (refresh/expiry) per product — mobile client already uses `TokenStorage` / Dio interceptor patterns.
3. Replace **stub** doctor/technician login when real mobile endpoints exist; keep router guards aligned.
4. Optional: add **`package_info_plus`** for dynamic version in About.
5. Pilot readiness: follow **`docs/MVP_AUDIT_AND_LAUNCH_CHECKLIST.md`** for go/no-go beyond UI.

### Files changed during final verification

- **None** — verification run passed without code edits; only this document and the master plan were updated.

---

## Goal (original)


After milestones **M01–M14**, perform a **whole-app audit** of the Flutter mobile client and produce a **safe, scoped** QA and polish plan: identify UI/copy/consistency gaps, loading/error/empty coverage, Bengali-first labeling issues, narrow-screen risks, and **non-invasive** consolidation opportunities—**without** shipping large features, backend changes, or architectural rewrites.

## Strict scope

- **In scope:** Read-only audit of `pranidoctor_mobile`; documentation of findings; listing **safe** UI/copy/state polish items; verification commands.
- **Out of scope:** Backend/API changes; new product features; package additions unless later proven unavoidable; renaming public routes without updating every reference; refactoring navigation architecture; changing doctor/AI technician **business** logic beyond safe UI/error/placeholder tweaks.

## Non-goals

- Replacing Go Router with another navigator, or merging doctor/technician stacks into the customer shell.
- Adding localization (ARB) files or full i18n infrastructure unless explicitly scheduled later.
- “Cleaning up” unrelated files or broad refactors.

---

## Current app audit summary

### Structure (high level)

- **Entry:** `lib/main.dart` → `PraniDoctorApp` (`lib/src/app/app.dart`).
- **Routing:** `go_router` in `lib/src/app/router.dart` — splash → onboarding (first run) → login or `/home`; `/doctor/*` and `/technician/*` bypass customer login redirect; legacy `/tutorials` paths remap to knowledge hub posts.
- **Customer shell:** `HomeShellScreen` — `IndexedStack` with **হোম**, **অনুরোধ**, **আমার পশু**, **প্রোফাইল** (`lib/src/features/home/home_shell_screen.dart`).
- **Animals tab:** Nested `Navigator` with `AnimalListScreen` as initial route (`animals_tab_screen.dart`) — detail/forms pushed on inner stack (no GoRouter for animal sub-routes by design).
- **Session:** `SessionNotifier` — customer OTP sets JWT + role customer; doctor/technician “খোলস” flows use `setRole` without treating them as JWT-authenticated customers (`lib/src/features/session/application/session_notifier.dart`).
- **Theme:** `lib/src/app/theme.dart`; locale pinned to **`bn_BD`** in `app.dart`.
- **Spacing:** `pdScreenPadding` / `pdReadableMaxWidth` (`lib/src/app/screen_padding.dart`) — horizontal padding scales with width; readable column capped (~520px).

### Tooling status (local verification, 2026-05-09)

| Command            | Result        |
|--------------------|---------------|
| `dart format .`    | **PASS** (0 files changed) — see **Final verification** |
| `flutter analyze`  | **PASS** — see **Final verification** |
| `flutter test`     | **PASS** (5 tests) — see **Final verification** |

### Cross-cutting findings

*Historical audit notes (pre-M15 implementation). Several items were addressed in M15 — see **Implementation status** and **Final verification** above.*

1. **Bengali-first vs English remnants:** Brand string **“Prani Doctor”** on splash and in About; **MaterialApp.title** English; email **hints** (`example@mail.com`, `doctor@example.com`, `tech@example.com`) in Bengali-first flows.
2. **টেকনিশিয়ান spelling:** Mixed **যি** vs **য়ি** forms (e.g. onboarding **টেকনিশিয়ান** vs many screens **টেকনিশিয়ান**) — pick one orthography for UI strings.
3. **Developer-oriented UI on customer paths:** **API base URL** on customer login and home “API ক্লায়েন্ট” card; technician login shows **`USE_MOCK_TECHNICIAN_API`** when mock mode — polish for production trust.
4. **Home menu incomplete wiring:** Several **হোম** tiles use `default: break` — taps do nothing (see module 4).
5. **Repeated small widgets:** Multiple files define similar **`_ErrorBody`** / retry layouts (providers, animals, technician lists). Safe consolidation possible under e.g. `lib/src/app/widgets/` without behavior change.
6. **Copy consistency:** Load failures sometimes **“লোড করা যায়নি”** vs **“লোড হয়নি”** (e.g. list vs detail).
7. **Date/time display:** Notifications use `DateFormat('yyyy-MM-dd HH:mm')` — Western digits/order; detail screens use custom `d/m/y` strings — optional **bn_BD**-friendly formatting later.
8. **9:16 / keyboard:** Login and booking wizard are long **ListView** / **PageView** flows — generally OK; worth spot-checking **`viewInsets` bottom padding** on smallest devices for OTP and wizard steps.

---

## Screen/module checklist (M01–M14)

Legend for **QA checklist status:**

| Status | Meaning |
|--------|---------|
| **pass** | Routing, states, and Bengali-first expectations largely met; only trivial nitpicks. |
| **needs safe fix** | Clear, low-risk UI/copy/navigation polish recommended before launch. |
| **placeholder documented** | Intentional scaffold/mock/disabled UI — document for users or hide in prod. |
| **not applicable** | Milestone not represented as a distinct surface in this repo. |

### 1. Splash / onboarding

| Item | QA status | Notes |
|------|-----------|--------|
| Splash delay + session hydrate + onboarding flag | **pass** | `SplashScreen` → prefs `pd_onboarding_done`, `hydrateFromStorage`. |
| Onboarding copy | **pass** | Bengali **PageView**; last step **শুরু করুন** → login. |
| Brand line English “Prani Doctor” | **needs safe fix** | Pair with বাংলা subtitle or use বাংলা-first title if product agrees. |
| Page 2–3 “শীঘ্রই / পরের আপডেট” | **placeholder documented** | Honest staging copy — acceptable; optional soften for production marketing. |

### 2. Login / OTP

| Item | QA status | Notes |
|------|-----------|--------|
| OTP request/verify + Bengali errors | **pass** | `LoginEntryScreen`; validation messages in Bengali. |
| Disabled social buttons | **placeholder documented** | Labeled **শীঘ্রই**. |
| API URL footer | **needs safe fix** | Hide behind **`kDebugMode`** or build flavor for retail builds. |
| Phone hint `01XXXXXXXXX` | **pass** | Acceptable pattern hint. |

### 3. Bottom navigation

| Item | QA status | Notes |
|------|-----------|--------|
| Four tabs, Bengali labels | **pass** | `NavigationBar` — হোম / অনুরোধ / আমার পশু / প্রোফাইল. |
| State preservation | **pass** | `IndexedStack` keeps tab state. |

### 4. Home

| Item | QA status | Notes |
|------|-----------|--------|
| Notifications bell → inbox | **pass** | |
| Wired menu items (ডাক্তার/টেকনিশিয়ান খুঁজুন, জ্ঞানকেন্দ্র, নোটিফিকেশন) | **pass** | |
| **জরুরি ডাক্তার ডাকুন**, **আমার পশু**, **চিকিৎসার ইতিহাস** | **needs safe fix** | **No navigation** in `switch` default — add route, “শীঘ্রই” snackbar, or remove until wired. |
| Debug “API ক্লায়েন্ট (ভিত্তি)” card | **needs safe fix** | Same as login: dev-only or remove for production. |
| Duplicate concept “আমার পশু” (home tile vs tab) | **needs safe fix** | Either deep-link to animals tab or remove tile to avoid confusion. |

### 5. Animal profiles

| Item | QA status | Notes |
|------|-----------|--------|
| List / detail / add–edit | **pass** | Loading, error, empty states; FAB **যোগ করুন**. |
| Nested tab navigator | **pass** | Documented pattern — inner stack independent of GoRouter. |
| Include inactive toggle | **pass** | Popup **নিষ্ক্রিয় গুলো দেখান**. |

### 6. Provider finder

| Item | QA status | Notes |
|------|-----------|--------|
| Doctor list + filters + detail | **pass** | `ProviderFilterPanel`, refresh, empty/error. |
| Technician list + detail | **pass** | Same patterns. |

### 7. Booking flow

| Item | QA status | Notes |
|------|-----------|--------|
| Multi-step wizard + validation (Bengali) | **pass** | `BookingWizardScreen` — 7 steps, `bookingDraftProvider`. |
| Submit/error handling | **pass** | SnackBars on validation/API errors. |
| Narrow screen / keyboard | **needs safe fix** | QA on smallest device; add bottom padding if overflow observed. |

### 8. Request tracking

| Item | QA status | Notes |
|------|-----------|--------|
| List + pull-to-refresh + FAB **নতুন অনুরোধ** | **pass** | |
| Detail route `/service-requests/:id` | **pass** | Registered in `router.dart`; class in `service_requests_tab_screen.dart`. |
| Billing block | **pass** | `CustomerBillingSummaryCard` + mock overlay per `AppConfig`. |
| Cancel flow | **pass** | Confirmation + optional reason. |
| Error copy list vs detail | **needs safe fix** | Align **যায়নি** vs **হয়নি** if desired. |

### 9. Doctor workflow

| Item | QA status | Notes |
|------|-----------|--------|
| Doctor login + doctor home | **placeholder documented** | Disabled email/password; **চালিয়ে যান (খোলস)** sets role → `/doctor/home`. |
| Customer flow isolation | **pass** | Router allows `/doctor` without customer JWT; doctor home sign-out → login. |
| Knowledge hub entry from doctor home | **pass** | |

### 10. AI technician workflow

| Item | QA status | Notes |
|------|-----------|--------|
| Technician login + dashboard + jobs/requests/detail | **pass** | Mock repository optional; screens have loading/error patterns. |
| Mock banner copy | **needs safe fix** | Replace raw env name with user-facing Bengali “ডেমো মোড” or hide when not mock. |
| Customer flow isolation | **pass** | Same redirect rules as doctor. |

### 11. Billing summary

| Item | QA status | Notes |
|------|-----------|--------|
| Customer card on completed/detail | **pass** | `CustomerBillingSummaryCard`, payment badge tests. |
| Provider earning placeholder | **placeholder documented** | `ProviderEarningSummaryCard` explains missing API data in Bengali. |
| Demo billing flag | **placeholder documented** | `AppConfig.useMockBillingUi` — document for QA builds only. |

### 12. Notification center

| Item | QA status | Notes |
|------|-----------|--------|
| List, filters, empty, mark read / mark all | **pass** | |
| Unread chip / grouping | **pass** | |
| Timestamp format | **needs safe fix** | Consider locale-aware or Bengali numerals for consistency. |

### 13. Knowledge hub

| Item | QA status | Notes |
|------|-----------|--------|
| Hub home, categories, list, detail | **pass** | Loading/error/retry; `/tutorials` redirect in router. |
| Mock posts flag | **placeholder documented** | `AppConfig` sample content when CMS unavailable. |
| Button wording **রিফ্রেশ** vs **আবার চেষ্টা করুন** | **needs safe fix** | Unify secondary actions labels app-wide (optional). |

### 14. Profile / settings / logout

| Item | QA status | Notes |
|------|-----------|--------|
| Profile load, edit, area, settings, about, help | **pass** | |
| Logout confirmation | **pass** | `LogoutConfirmDialog`. |
| Support phone placeholder | **placeholder documented** | `support_contact_card.dart` — masked number until real support line. |
| Email hint **example@mail.com** | **needs safe fix** | Bengali example or label-only field. |

---

## Exact safe fix list (next implementation step)

Ordered by **user-visible impact** and **low regression risk**:

1. **Home (`home_screen.dart`):** Implement navigation or explicit “শীঘ্রই” feedback for **জরুরি ডাক্তার ডাকুন**, **আমার পশু** (or switch to tab index without breaking shell), and **চিকিৎসার ইতিহাস** (e.g. push service-requests tab or requests list — align with product intent).
2. **Remove or gate debug surfaces:** API base URL on **customer login** and **home** card; technician **mock env** string — use **`kDebugMode`** / flavor or Bengali “ডেমো”.
3. **Bengali orthography:** Normalize **টেকনিশিয়ান** vs **টেকনিশিয়ান** (and similar) to one spelling across `lib/`.
4. **Splash / About / `MaterialApp` title:** Decide single Bengali-first brand presentation; keep Latin subtitle only if required for store/legal.
5. **Profile edit:** Replace English email hint with neutral Bengali placeholder.
6. **Notification timestamps:** Format with `intl` + `locale: const Locale('bn', 'BD')` (or documented pattern) for consistent বাংলা numerals/date style.
7. **Optional:** Extract shared **`AsyncErrorScaffold`** / **`RetryBody`** to reduce duplicate `_ErrorBody` widgets (providers, animals, technician) — **pure UI move**, same strings and callbacks.
8. **Optional:** Unify “লোড করা যায়নি” vs “লোড হয়নি” in service request surfaces.
9. **Booking wizard:** Manual QA on **360×800** (or similar); add `SafeArea` / `Padding` with `MediaQuery.viewInsets` only if issues reproduced.

---

## Files likely to be changed (next step)

| File | Change type |
|------|-------------|
| `lib/src/features/home/home_screen.dart` | Menu wiring, remove/guard debug card |
| `lib/src/features/auth/login_entry_screen.dart` | Debug API line |
| `lib/src/features/auth/technician/presentation/technician_login_screen.dart` | Demo copy |
| `lib/src/features/splash/splash_screen.dart` | Brand line |
| `lib/src/app/app.dart` | `title` if Bengali app label desired |
| `lib/src/features/profile/presentation/about_screen.dart` | Brand text consistency |
| `lib/src/features/profile/presentation/edit_profile_screen.dart` | Email hint |
| `lib/src/features/notifications/presentation/notifications_list_screen.dart` | Date formatting |
| `lib/src/features/onboarding/onboarding_screen.dart` | টেকনিশিয়ান spelling (if normalizing) |
| Multiple feature files | Orthography pass |
| `lib/src/app/widgets/...` (new, optional) | Shared error empty helper |

**Avoid touching:** `router.dart` route paths unless a reference audit is done; `session_notifier.dart` unless fixing a confirmed bug (none found in this audit).

---

## Risks and rollback notes

| Risk | Mitigation |
|------|------------|
| Changing home menu behavior | Test all **switch** branches; ensure **IndexedStack** tab index navigation uses existing shell API if introduced. |
| Hiding API URL | Confirm staging/QA builds still expose URL via flavor if developers rely on it. |
| Shared error widget extraction | Keep widget parameters identical; run **`flutter test`** after move. |
| Date locale change | Verify grouping (“সাম্প্রতিক” / older) still sorts correctly. |

**Rollback:** Git revert per file; no migrations or schema involved.

---

## Final verification commands

Run from repository root `D:\PraniDoctor\pranidoctor_mobile`:

```bash
dart format .
flutter analyze
flutter test
```

All three should pass before merging polish PRs.

---

## Summary for stakeholders

- The app **analyzes cleanly** and **tests pass**; routing is coherent and **customer vs doctor/technician** paths remain separated by design.
- Main gaps are **polish, not architecture:** incomplete **হোম** menu actions, **debug-oriented UI** on customer surfaces, **mixed Bengali spelling** for technician wording, a few **English hints**, and optional **locale-aware dates** and **shared error widgets**.
- Next step is to implement only the **safe fix list** above, preserving Go Router paths, Riverpod providers, and existing theme tokens.
