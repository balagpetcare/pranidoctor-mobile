# Task M14 — Profile, Settings & Support Pages (Audit & Plan)

**Project:** Prani Doctor / Animal Doctors — **mobile app only**  
**Domain:** [https://pranidoctor.com/](https://pranidoctor.com/)  
**Repo:** [github.com/balagpetcare/pranidoctor-mobile](https://github.com/balagpetcare/pranidoctor-mobile)  
**Local path:** `D:\PraniDoctor\pranidoctor_mobile`

**Goal:** Bengali-first **user profile**, **app settings**, and **help/support** surfaces for **customers** (primary) and alignment notes for **doctor / technician** shells — without overbuilding account management.

**Isolation:** No BPA/WPA, Quarbani 2026, or other products. **No backend changes** in this task.

**Status:** **Implemented** in mobile (2026-05-09). Sections §1–§12 retain the original audit/plan; **§0** is the implementation summary.

**Last updated:** 2026-05-09 (M14 test/format gate)

---

## 0. Implementation status (2026-05-09)

### 0.1 Delivered

| Area | Details |
|------|---------|
| **Feature folder** | `lib/src/features/profile/` — `data/`, `application/`, `presentation/`, `presentation/widgets/` |
| **Customer hub** | `ProfileHomeScreen` embedded in `HomeShellScreen` profile tab — header card, menu, `SupportContactCard`, pull-to-refresh, logout with confirmation |
| **Routes** | `/profile/edit`, `/profile/area`, `/profile/settings`, `/profile/help`, `/profile/about` |
| **API** | `MobileUserRepositoryLive`: `GET /api/mobile/me`, `PATCH /api/mobile/me` (then re-fetch); `ProfileApiException`; tolerant `MobileUser.fromJson` |
| **Mock** | `AppConfig.useMockProfileApi` — `USE_MOCK_PROFILE_API` dart-define; `MobileUserRepositoryMock` |
| **Logout** | `showPdLogoutConfirmAndExecute` → `SessionNotifier.signOut` + `context.go(LoginEntryScreen.routePath)` |
| **Shared** | `user_visible_async_error.dart` includes `ProfileApiException`; widgets: `ProfileHeaderCard`, `ProfileSettingsListTile`, `SupportContactCard` |
| **About version** | Const `kPraniDoctorAppVersionLabel` in `about_screen.dart` (matches `pubspec.yaml` 1.0.0+1) |

### 0.2 Not in scope (unchanged)

| Item | Note |
|------|------|
| **Doctor / technician shells** | No new links in `doctor_home_screen` / `technician_dashboard` (plan: customer-first). |
| **`package_info_plus` / `url_launcher`** | Not added; WhatsApp = placeholder copy + clipboard. |

### 0.3 Checklist (M14)

- [x] Profile feature: models, repository live + mock, providers  
- [x] `GET` / `PATCH` unwrap + Bengali errors + 404-friendly message  
- [x] `USE_MOCK_PROFILE_API`  
- [x] Profile home (tab), edit, area, app settings, help, about  
- [x] go_router routes  
- [x] Logout confirmation (customer profile + app settings)  
- [x] `userVisibleAsyncErrorBn` + `ProfileApiException`  
- [x] `flutter analyze` + `flutter test` clean  

### 0.4 Quality gate (M14 test/fix pass)

Repo root `D:\PraniDoctor\pranidoctor_mobile` — **2026-05-09**:

| Command | Result |
|---------|--------|
| `dart format .` | **Pass** (11 files reformatted; profile + `home_shell_screen` and related M14 Dart files) |
| `flutter analyze` | **Pass** (no issues) |
| `flutter test` | **Pass** (5 tests) |

---

## 1. Task summary

| Item | Direction |
|------|-----------|
| **My profile** | Show name, phone, optional email, area, role, avatar **placeholder**; load from `GET /api/mobile/me` when available. |
| **Edit profile** | Form to update editable fields; submit via `PATCH /api/mobile/me`; keep validation light (phone read-only if product prefers). |
| **Address / area** | Dedicated screen or section: text / future structured area IDs — align with booking “location” copy where relevant (`docs/MVP_AUDIT_AND_LAUNCH_CHECKLIST.md` notes area IDs not yet wired app-wide). |
| **App settings** | Simple toggles/rows: e.g. notifications hint, language note (app is `bn_BD` default), theme follows system — avoid heavy preferences until product confirms. |
| **Help / support** | Static FAQ-style or “how to use” stub + link patterns consistent with knowledge hub entry. |
| **Contact / WhatsApp** | **Placeholder** card: support number or `wa.me` text; prefer **no new package** — copy-to-clipboard or `SelectableText`; optional `url_launcher` only if product insists. |
| **About Prani Doctor** | Version (`package_info_plus` **not** in `pubspec.yaml` today) — **prefer** hardcoded `1.0.0+1` from `pubspec.yaml` as const or manual “About” copy until versioning package is justified. |
| **Logout** | **Confirmation dialog** before `SessionNotifier.signOut` + navigate to login (replace instant sign-out on customer profile tab). |

**Constraints:** Reuse **Riverpod**, **go_router**, **Dio** + **`ApiClient`**, **`AppTheme`**, **`pdScreenPadding`**, **`{ ok, data, error }`** parsing style, Bengali strings inline (no ARB). Mock profile only behind **`AppConfig`** + repository swap **if** needed, mirroring `knowledge_hub`.

---

## 2. Current repo audit findings

### 2.1 Auth, session, tokens

| Finding | Location |
|--------|----------|
| **JWT** stored in **secure storage** (`pd_access_token`, `pd_refresh_token`). | `lib/src/core/storage/token_storage.dart`, `secure_storage_service.dart` |
| **Session state** (`AppRole?`, `isAuthenticated`) — **not** persisted except via token + `SharedPreferences` key `pd_last_role`. | `lib/src/features/session/application/session_notifier.dart` |
| **Cold start:** splash calls `hydrateFromStorage()` — if access token present, marks authenticated and restores role from `pd_last_role`. | `splash_screen.dart`, `session_notifier.dart` |
| **Customer OTP login** writes token via `signInCustomer(accessToken)`. | `login_entry_screen.dart`, `mobile_otp_auth_repository.dart` |
| **401 on API:** Dio interceptor clears session and `go(LoginEntryScreen.routePath)`. | `lib/src/core/network/dio_provider.dart` |
| **`signOut`:** `TokenStorage.clear()` + `SessionState()` reset (does **not** clear `pd_last_role` in SharedPreferences — acceptable for M14; note as optional cleanup). | `session_notifier.dart` |

### 2.2 Networking & API conventions

| Finding | Location |
|--------|----------|
| **`ApiClient`** exposes `get` / `post` / `patch` on shared Dio. | `lib/src/core/network/api_client.dart` |
| **Base URL** from `--dart-define=API_BASE_URL` (default `http://localhost:3000`). | `lib/src/core/config/app_config.dart` |
| **Envelope:** repositories expect `ok: true` and `data` map; errors use `error.message` (Bengali where implemented). | e.g. `notification_repository.dart`, `knowledge_repository.dart` |
| **No** existing `GET`/`PATCH` **`/api/mobile/me`** in the mobile repo (grep / audit). | — |

### 2.3 Routing & navigation

| Finding | Location |
|--------|----------|
| **`go_router`** with `goRouterProvider`, `pdRootNavigatorKey`, `refreshListenable` on session. | `lib/src/app/router.dart` |
| **Customer shell:** bottom nav in `HomeShellScreen` — tabs: হোম, অনুরোধ, আমার পশু, **প্রোফাইল**. | `home_shell_screen.dart` |
| **Profile tab today:** placeholder title/body, **notifications** `ListTile` → push `/notifications`, **sign-out** button **without** confirmation. | `_ProfileTab`, `_SignOutButton` |
| **Authenticated redirect:** non-public paths require `auth.isAuthenticated`; `/doctor/*` and `/technician/*` bypass customer gate. | `router.dart` |

### 2.4 Role-specific shells (providers)

| Role | UI | Sign-out today |
|------|-----|------------------|
| **Customer** | `HomeShellScreen` profile tab | `FilledButton.tonal` — no dialog |
| **Doctor** | `DoctorHomeScreen` | AppBar **TextButton** “সাইন আউট” — no dialog |
| **Technician** | `TechnicianDashboardScreen` | **OutlinedButton** “প্রস্থান / লগইন” — no dialog |

M14 should **standardize logout confirmation** at least for **customer**; doctor/technician can follow same pattern when touched.

### 2.5 Theme, layout, localization

| Finding | Location |
|--------|----------|
| **Material 3**, teal seed, cards 16px radius, Bengali-friendly `textTheme` + Noto fallbacks. | `lib/src/app/theme.dart` |
| **Default locale** `bn_BD` + `en_US` supported. | `lib/src/app/app.dart` |
| **Screen padding** helper. | `lib/src/app/screen_padding.dart` |

### 2.6 Loading / error / empty patterns

| Pattern | Example |
|---------|---------|
| **`AsyncValue`-style** via custom notifier state or `when` on providers. | `notifications_list_screen.dart` (loading spinner, error column + “আবার চেষ্টা করুন”, `RefreshIndicator`) |
| **Typed API exceptions** with Bengali `message`. | `NotificationApiException`, `KnowledgeApiException`, `OtpAuthException` |
| **Shared async error helper** (limited types). | `lib/src/app/user_visible_async_error.dart` — currently **only** `ServiceRequestApiException`, `TechnicianApiException`; profile should add **`ProfileApiException`** (or reuse a thin shared base) and optionally extend `userVisibleAsyncErrorBn`. |
| **Forms with load error** for edit mode. | `animal_form_screen.dart` (`_loadingExisting`, `_loadError`, local `setState`) |

### 2.7 Mock / feature-flag precedent

| Finding | Location |
|--------|----------|
| **`AppConfig.useMock*`** booleans + `Provider` returns Live vs Mock implementation. | `app_config.dart`, `knowledge_hub_providers.dart`, `technician_job_providers.dart`, billing mock flag |

### 2.8 Tests

| Finding | Location |
|--------|----------|
| **Widget tests** under `test/` — small number (`widget_test.dart`, `technician_ai_badge_test.dart`, `billing_payment_summary_widget_test.dart`). | `test/` |
| **Pattern:** pump app/widgets with **overridden** providers where needed. | Existing tests |

### 2.9 Gaps vs M14 scope

- No **`features/profile`** (or similar) module; profile UI is **inline** in `home_shell_screen.dart`.
- No **settings** persistence beyond session/token/onboarding flags.
- **WhatsApp / url_launcher** not in dependencies — use **placeholder** UX without new packages unless required.
- **`package_info`** not present — “About” version from const/manual string for MVP.

---

## 3. Existing files / components / routes to reuse

| Path | Reuse for M14 |
|------|----------------|
| `lib/src/core/network/api_client.dart` | `get` / `patch` for `/api/mobile/me`. |
| `lib/src/core/network/dio_provider.dart` | Auth header + 401 handling (no change expected). |
| `lib/src/core/config/app_config.dart` | Optional `USE_MOCK_PROFILE_API` (mirror other flags). |
| `lib/src/core/storage/token_storage.dart` | Logout clear (already used by `signOut`). |
| `lib/src/features/session/application/session_notifier.dart` | `signOut`, `sessionNotifierProvider`, role for labels. |
| `lib/src/features/home/home_shell_screen.dart` | Replace/compose **profile tab** with navigation to new sub-screens or embedded hub. |
| `lib/src/app/router.dart` | Register routes for profile home, edit, settings, support, about (paths below). |
| `lib/src/app/theme.dart`, `screen_padding.dart` | Visual consistency. |
| `lib/src/features/notifications/presentation/notifications_list_screen.dart` | List sections, `Card` + `ListTile`, error/retry patterns. |
| `lib/src/features/knowledge_hub/application/knowledge_hub_providers.dart` | **Pattern** for `profileRepositoryProvider` + mock. |
| `lib/src/features/animals/presentation/animal_form_screen.dart` | Form + load-existing error pattern for edit profile. |
| `lib/src/app/navigation_keys.dart` | If any global dialogs/snackbars need root context (rare). |

---

## 4. New files to create (implementation phase)

Suggested feature folder: `lib/src/features/profile/` (or `account/` — **prefer `profile`** to avoid clash with `features/providers` provider-finder).

| Path | Role |
|------|------|
| `lib/src/features/profile/data/mobile_user_model.dart` | Immutable user DTO: `name`, `phone`, `email?`, `areaLabel` or `area?`, `role` (string or enum), `profilePhotoUrl?`, `id?`. |
| `lib/src/features/profile/data/mobile_user_repository.dart` | `Future<MobileUser> fetchMe()`, `Future<MobileUser> patchMe(MobileUserPatch patch)` + `_unwrap` + `ProfileApiException`. |
| `lib/src/features/profile/data/mobile_user_repository_mock.dart` | Optional static BN user when `USE_MOCK_PROFILE_API`. |
| `lib/src/features/profile/application/profile_providers.dart` | Repository provider, `FutureProvider` / `AsyncNotifier` for profile state and `patch` mutation. |
| `lib/src/features/profile/presentation/profile_home_screen.dart` | Header card + list entries (edit, area, settings, support, about). |
| `lib/src/features/profile/presentation/edit_profile_screen.dart` | Form + save. |
| `lib/src/features/profile/presentation/area_setting_screen.dart` | Area editor (text or picker stub). |
| `lib/src/features/profile/presentation/app_settings_screen.dart` | Settings list (minimal). |
| `lib/src/features/profile/presentation/help_support_screen.dart` | Help content stub. |
| `lib/src/features/profile/presentation/about_screen.dart` | About + version text. |
| `lib/src/features/profile/presentation/widgets/profile_header_card.dart` | Avatar placeholder, name, role chip, phone. |
| `lib/src/features/profile/presentation/widgets/support_contact_card.dart` | WhatsApp / phone **placeholder**. |
| `lib/src/features/profile/presentation/widgets/logout_confirm_dialog.dart` | Reusable `showDialog` BN copy — or private method on shell. |
| `test/profile_home_screen_test.dart` (optional) | Widget smoke with mocked repository. |

Exact filenames may be adjusted to match team naming; **structure** should stay `data` / `application` / `presentation`.

---

## 5. Existing files to modify (implementation phase)

| File | Change |
|------|--------|
| `lib/src/features/home/home_shell_screen.dart` | Replace `_ProfileTab` body with **profile hub** (or `ProfileHomeScreen` embedded), keep notifications entry, wire **logout with confirmation**. |
| `lib/src/app/router.dart` | Add `GoRoute`s for new screens (authenticated customer paths). |
| `lib/src/core/config/app_config.dart` | Optional mock flag for profile API. |
| `lib/src/app/user_visible_async_error.dart` | Add `ProfileApiException` handling if profile screens use shared helper. |
| `lib/src/features/home/doctor/presentation/doctor_home_screen.dart` | Optional: link row “অ্যাকাউন্ট ও সেটিংস” → shared about/support routes **or** defer to avoid scope creep. |
| `lib/src/features/technician_ai/presentation/technician_dashboard_screen.dart` | Optional: same as doctor — only if product wants parity in this milestone. |

**Default M14 scope:** **customer `HomeShellScreen` profile tab** + routes; doctor/technician **only** if timeboxed and same components reused.

---

## 6. API contract assumptions — `GET /api/mobile/me` & `PATCH /api/mobile/me`

Assumptions align with existing mobile APIs (`notifications`, `knowledge_hub`, OTP):

### 6.1 Common

- **Auth:** `Authorization: Bearer <accessToken>` (already injected).
- **Envelope:**  
  - Success: `{ "ok": true, "data": { ... } }`  
  - Error: `{ "ok": false, "error": { "message": "...", "code": "..." } }`  
- **HTTP errors:** map `DioException` to Bengali message (same style as `NotificationRepository._mapDio` if extracted, or inline).

### 6.2 `GET /api/mobile/me`

- **Response `data` fields (mobile mapping):**

| JSON key (assumed) | Type | UI |
|--------------------|------|-----|
| `id` | string? | Internal / future |
| `name` | string | Profile header |
| `phone` | string | Display (masked optional — product) |
| `email` | string? | Optional row |
| `area` or `areaLabel` | string? | Area row |
| `role` | string (`customer` / `doctor` / `technician` / …) | Role chip |
| `profilePhotoUrl` | string? | Network image or placeholder |

- Parser should **tolerate** missing optional keys (null-safe defaults).

### 6.3 `PATCH /api/mobile/me`

- **Request body:** partial JSON, only changed fields, e.g.  
  `{ "name": "...", "email": "...", "area": "..." }`  
- **Response:** same shape as GET inside `data` (full user) **or** minimal patch echo — implementation should accept **either** by re-fetching GET after successful PATCH (simplest, one code path).

### 6.4 Until backend exists

- Repository may return **404** / network errors → show Bengali error + retry.
- Optional **`USE_MOCK_PROFILE_API`** returns static `MobileUser` — isolated in `MobileUserRepositoryMock`, selected in `profile_providers.dart` (same idiom as knowledge hub).

---

## 7. Logout / token clear flow

1. **User confirms** in `AlertDialog` (title/body BN): e.g. “প্রস্থান করবেন?” / “আপনার সেশন বন্ধ হবে।”  
2. On confirm: `await ref.read(sessionNotifierProvider.notifier).signOut()`  
   - Clears **secure** access + refresh tokens (`TokenStorage.clear()`).  
   - Resets `SessionState` to unauthenticated.  
3. `context.go(LoginEntryScreen.routePath)` (or `go` to splash if product prefers full reset — **default:** login, matching `_SignOutButton` and Dio 401).  
4. **No server revoke call** assumed for MVP (document if backend adds `POST /api/mobile/auth/logout` later).  
5. **401 interceptor:** already signs out — profile screens should not fight this; after patch errors with 401 user lands on login.

---

## 8. UI / page breakdown (Bengali-first copy suggestions)

| Screen / section | UI building blocks |
|------------------|-------------------|
| **Profile hub** (tab root) | `SafeArea` + `SingleChildScrollView` + `pdScreenPadding`; **profile header card**; `Card` with `ListTile` rows: সম্পাদনা, এলাকা/ঠিকানা, অ্যাপ সেটিংস, সাহায্য, আমাদের সম্পর্কে; existing **নোটিফিকেশন** row; **সাপোর্ট কার্ড** (WhatsApp placeholder); bottom **লগআউট** `OutlinedButton` or destructive `FilledButton.tonal`. |
| **Edit profile** | `AppBar` title “প্রোফাইল সম্পাদনা”; `Form` + `TextFormField` for name, email; phone **read-only** `Text` or disabled field; Save `FilledButton`. |
| **Area** | Title “এলাকা”; `TextFormField` or future `DropdownButton` for divisions; helper text if IDs not ready. |
| **App settings** | Title “সেটিংস”; rows: বিজ্ঞপ্তি (subtitle: “সিস্টেম অনুযায়ী” / deep link to OS), থিম (read-only: “সিস্টেম ডিফল্ট”), optional “ডেভ: API ঠিকানা” **do not duplicate** debug from home if removing later per MVP doc. |
| **Help** | Title “সাহায্য”; short numbered tips + link to **জ্ঞানকেন্দ্র** via `context.push(KnowledgeHubHomeScreen.routePath)`. |
| **Support card** | Title “যোগাযোগ”; body: “হোয়াটসঅ্যাপ (শীঘ্রই)” or static number; `SelectableText`; optional `IconButton` onCopy using `Clipboard` (framework only). |
| **About** | App name **প্রাণি ডাক্তার / Prani Doctor**, tagline, version string, link `https://pranidoctor.com/` as `SelectableText` or non-linked text to avoid `url_launcher`. |
| **Logout confirm** | `AlertDialog`: actions **বাতিল** / **প্রস্থান**. |

---

## 9. State / loading / error handling plan

| Concern | Approach |
|---------|----------|
| **Initial load** | `AsyncValue` from `FutureProvider.autoDispose` **or** `AsyncNotifier` if pull-to-refresh + optimistic patch needed. |
| **Pull-to-refresh** | Optional on profile hub `RefreshIndicator` invalidating provider. |
| **PATCH save** | `ElevatedButton`/`FilledButton` disabled while `isLoading`; success `SnackBar` “সংরক্ষিত হয়েছে”; on error show `SnackBar` with `ProfileApiException.message`. |
| **401** | Handled globally — show nothing extra beyond navigation to login. |
| **Empty photo** | `CircleAvatar` with `Icon(Icons.person)` or initials from name. |
| **Role label** | Map `AppRole` / API `role` string to BN: গ্রাহক, চিকিৎসক, টেকনিশিয়ান. |

---

## 10. Testing plan

| Test | Notes |
|------|--------|
| **Widget:** profile hub renders header + one `ListTile` when mock user provided. | Override `profileRepositoryProvider` or expose `FutureProvider` override. |
| **Widget:** logout dialog cancels vs confirm calls `signOut` (mock `SessionNotifier` or verify `Navigator.pop` + callback). | Use `ProviderScope` overrides. |
| **Unit (optional):** JSON parse `MobileUser.fromJson` with missing fields. | Pure Dart in `test/`. |
| **Manual:** cold start with token → profile loads; sign out → login; 401 from me → interceptor. | QA checklist. |

---

## 11. Risk notes

| Risk | Mitigation |
|------|------------|
| **Backend `/api/mobile/me` missing** | Mock flag + clear error UI; do not block shell. |
| **Role mismatch** between JWT claims and `me` payload | Prefer **display** from `me`; session `AppRole` for routing only. |
| **Scope creep** (doctor/technician full parity) | Ship **customer** first; reuse widgets only. |
| **Duplicate debug API URL** | Keep single place (home vs settings) — MVP doc already flags prod concern. |
| **`pd_last_role` not cleared on signOut** | Low risk for customer OTP; document optional `prefs.remove` in same `signOut` if stale role bugs appear. |
| **Adding `url_launcher` / `package_info_plus`** | Only if product requires; otherwise stay dependency-free. |

---

## 12. Implementation checklist (for the coding pass)

- [x] Add `profile` feature folder: models, repository (+ optional mock), providers.  
- [x] Implement `GET` / `PATCH` with `{ ok, data }` unwrap + `ProfileApiException`.  
- [x] Optional `AppConfig.USE_MOCK_PROFILE_API` + provider branch.  
- [x] `ProfileHomeScreen` with **header card**, settings-style list, support card, notifications link preserved.  
- [x] `EditProfileScreen`, `AreaSettingScreen`, `AppSettingsScreen`, `HelpSupportScreen`, `AboutScreen`.  
- [x] Wire **go_router** routes and `context.push` from profile tab.  
- [x] **Logout confirmation** on customer profile; align copy with existing “প্রস্থান” strings.  
- [x] Extend `userVisibleAsyncErrorBn` if any `AsyncValue` screens use it for profile.  
- [x] `flutter analyze` + `flutter test` green.  
- [ ] Update `docs/MVP_AUDIT_AND_LAUNCH_CHECKLIST.md` customer row for profile/settings (optional follow-up).

---

**End of M14 plan.**
