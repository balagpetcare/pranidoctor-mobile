# Prani Doctor — Mobile App Foundation Plan (Task Card 07)

## 1. Current audit summary

### 1.1 `pubspec.yaml`

- **Flutter SDK:** `^3.11.5`
- **Already present:** `flutter_riverpod`, `go_router`, `dio`, `flutter_secure_storage`, `shared_preferences`, `intl`, `cupertino_icons`
- **Missing for locale/Bengali UI:** `flutter_localizations` (SDK) — add for `MaterialApp` locale delegates and Bengali-friendly material strings where applicable

### 1.2 `lib` folder structure (pre-change)

| Area | Path | Notes |
|------|------|--------|
| Entry | `lib/main.dart` | `ProviderScope` + `PraniDoctorApp` — good baseline |
| App shell | `lib/app/app.dart`, `lib/app/router.dart` | Riverpod + GoRouter + themes wired |
| Theme | `lib/app/theme/app_theme.dart` | Material 3, emerald seed — no explicit BN locale/typography |
| Config | `lib/core/config/app_config.dart` | `API_BASE_URL` via `--dart-define` |
| Network | `lib/core/network/dio_provider.dart`, `api_client.dart` | Dio + auth interceptor reading access token |
| Storage | `lib/core/storage/token_storage.dart` | `FlutterSecureStorage` for access/refresh keys |
| Features | `lib/features/splash`, `role_selection`, `auth/customer|doctor`, `home/customer|doctor`, `session` | Customer flow: splash → role → customer login → customer home with placeholder sign-in |

### 1.3 Architecture already present

- **Riverpod:** `ProviderScope`, `ConsumerWidget`, `NotifierProvider` (`session_notifier`), `Provider` for router/Dio/API/token storage
- **GoRouter:** `goRouterProvider`, flat `GoRoute` list including splash, role selection, customer/doctor auth and home
- **Dio:** Central `dioProvider` with `AppConfig.apiBaseUrl`, timeouts, JSON headers, dispose hook, token interceptor
- **Flutter Secure Storage:** Used directly inside `TokenStorage` (no separate generic service class)

### 1.4 Gaps vs Task Card 07 (customer foundation)

- Physical layout uses `lib/app` and `lib/core` rather than the requested `lib/src/...` canonical tree (acceptable to migrate once to match card)
- No dedicated **onboarding** flow; splash navigates to **role selection** (card targets **customer-first** shell: splash → onboarding → login entry → home shell)
- No **bottom navigation shell** or **home menu skeleton** with the six Bengali menu items
- **Login** still performs **placeholder token write** (`completePlaceholderSignIn`) — conflicts with “no authentication logic yet”
- **Bengali typography / locale** not centralized on `MaterialApp` (no `flutter_localizations`, default locale)
- No **`SecureStorageService`** facade separate from token-specific API (optional clarity layer)

### 1.5 Preservation / non-duplication decisions

- **Do not** add duplicate packages; only add `flutter_localizations` if needed for delegates
- **Preserve** Dio base URL pattern, `ApiClient` wrapper, and secure storage behavior; extend with `SecureStorageService` + keep `TokenStorage` for token keys
- **Remove** customer-only **role selection** from the default path to match the customer app foundation; keep **doctor** screens as secondary routes for future parity (updated imports, sign-out target = login entry)
- **Delete** superseded customer-only screens (`customer_login_screen`, `customer_home_screen`, `role_selection_screen`) after replacement screens exist under `lib/src`

---

## 2. Target mobile app architecture

- **State:** Riverpod (`ProviderScope`, feature providers, session notifier slimmed for role/onboarding prefs only — no fake auth)
- **Navigation:** GoRouter with splash, onboarding, login entry, customer home shell (single route with internal bottom nav + `IndexedStack`), optional doctor routes
- **Network:** `AppConfig` + `dioProvider` + `ApiClient` (no new backend calls in this task)
- **Storage:** `SecureStorageService` (generic) + `TokenStorage` (token keys); `SharedPreferences` for onboarding completion flag
- **UI:** `MaterialApp.router` with BN-first `locale`, supported locales, theme tuned for Bengali line height; screens use **Bengali copy** per spec

---

## 3. Folder structure proposal (`lib/src`)

```
lib/
  main.dart
  src/
    app/
      app.dart
      router.dart
      theme.dart
    core/
      config/
        app_config.dart
      network/
        api_client.dart
        dio_provider.dart
      storage/
        secure_storage_service.dart
        token_storage.dart
    features/
      splash/
        splash_screen.dart
      onboarding/
        onboarding_screen.dart
      auth/
        login_entry_screen.dart
        doctor/
          presentation/
            doctor_login_screen.dart
      home/
        home_shell_screen.dart
        home_screen.dart
        doctor/
          presentation/
            doctor_home_screen.dart
      session/
        application/
          session_notifier.dart
```

---

## 4. Required packages

| Package | Action |
|---------|--------|
| `flutter_riverpod` | Keep (already in `pubspec.yaml`) |
| `go_router` | Keep |
| `dio` | Keep |
| `flutter_secure_storage` | Keep |
| `flutter_localizations` | **Add** (`sdk: flutter`) for delegates + locale support |

---

## 5. Implementation steps

1. Add `flutter_localizations` to `pubspec.yaml`.
2. Create `lib/src/core/config/app_config.dart` (same semantics as current).
3. Create `lib/src/core/storage/secure_storage_service.dart` + provider; refactor `token_storage.dart` to depend on it; keep `dio_provider` token interceptor.
4. Create `lib/src/core/network/dio_provider.dart` and `api_client.dart` (move logic, update imports).
5. Create `lib/src/app/theme.dart` (move `AppTheme`; add Bengali-friendly `textTheme` line heights / `fontFamilyFallback` hint list where safe).
6. Create `lib/src/app/app.dart` (wire `locale`, `supportedLocales`, `localizationsDelegates`).
7. Create feature screens: splash (prefs branch), onboarding (`PageView` + finish → prefs), login entry (navigate to home **without** token/auth), `HomeShellScreen` + `HomeScreen` (six menu rows/cards + bottom nav placeholders).
8. Create `lib/src/app/router.dart` with new route table; keep doctor routes with updated imports.
9. Update `lib/main.dart` to import `src/app/app.dart`.
10. Move/update doctor + session files under `lib/src`; remove obsolete `lib/app`, `lib/core`, and replaced feature files.
11. Update `test/widget_test.dart` imports and expectations if titles change.
12. Run `flutter pub get`, `dart format .`, `flutter analyze`, `flutter test`.

---

## 6. UI foundation plan

| Screen | Purpose |
|--------|---------|
| **Splash** | Brand + loader; after delay → onboarding **or** login based on `pd_onboarding_done` |
| **Onboarding** | 3 short Bengali pages; “শুরু করুন” sets flag → login entry |
| **Login entry** | মোবাইল সেকশন + disabled Google/Facebook placeholders + optional guest-to-home; **no** real auth or token writes |
| **Home shell** | `NavigationBar` + `IndexedStack`: **হোম**, **অনুরোধ**, **আমার পশু**, **প্রোফাইল** (skeleton tabs; sign-out on প্রোফাইল) |
| **Home** | List/grid skeleton with: জরুরি ডাক্তার ডাকুন, ডাক্তার খুঁজুন, AI টেকনিশিয়ান খুঁজুন, আমার পশু, চিকিৎসার ইতিহাস, টিউটোরিয়াল |

---

## 7. Testing checklist

- [x] `flutter pub get` succeeds
- [x] `dart format .` clean
- [x] `flutter analyze` — no errors
- [x] `flutter test` — widget test passes (app pumps, finds expected Bengali/brand text)
- [ ] Manual smoke: cold start → splash → onboarding (first) → login → home shell tabs

---

## 8. Changed files checklist (post-implementation)

- [x] `pubspec.yaml` — added `flutter_localizations`
- [x] `docs/MOBILE_APP_FOUNDATION_PLAN.md`
- [x] `lib/main.dart` — imports `package:pranidoctor_mobile/src/app/app.dart`
- [x] `lib/src/**` — new canonical tree (app, core, features)
- [x] Removed legacy `lib/app/**`, `lib/core/**`, old `lib/features/**` Dart sources
- [x] `test/widget_test.dart` — package import updated

### Commands run (2026-05-09)

| Command | Result |
|---------|--------|
| `flutter pub get` | Success |
| `dart format .` | 18 files touched |
| `flutter analyze` | No issues |
| `flutter test` | All tests passed |

---

## 10. Polish pass — customer UI & navigation (continuation)

**Audited (this step):** `lib/main.dart` → `ProviderScope` → `PraniDoctorApp` (`MaterialApp.router` + `routerConfig: goRouter`); `goRouterProvider` routes `/splash` → (`/onboarding` if `pd_onboarding_done` is false) → `/login` → `/home`; `docs/MOBILE_APP_FOUNDATION_PLAN.md` §1–9.

**Implemented**

- **Bottom nav:** four skeleton tabs — **হোম**, **অনুরোধ**, **আমার পশু**, **প্রোফাইল**; sign-out control only on **প্রোফাইল**.
- **Login entry:** heading **মোবাইল নম্বর দিয়ে লগইন**, disabled phone/OTP fields, **খোলস** primary to home; **Google** / **Facebook** as disabled outlined buttons (শীঘ্রই); guest shortcut to home for skeleton review.
- **Theme:** teal–emerald seed `0xFF0F766E`; dark `TextTheme` uses light-on-dark base; clearer app bar, inputs, `NavigationBar`, min button height 48.
- **Splash / onboarding:** stronger **Prani Doctor** branding; simpler customer-focused Bengali onboarding copy.
- **Responsive helper:** `lib/src/app/screen_padding.dart` — `pdScreenPadding`, `pdReadableMaxWidth`; home menu uses `ConstrainedBox` + sliver padding from screen width.

**Re-verified:** `flutter pub get`, `dart format .`, `flutter analyze`, `flutter test` — all green after polish.

---

## 11. Next task recommendation

**Task Card 08 — Customer onboarding persistence & deep links:** persist session/onboarding with a small `UserPrefs` Riverpod provider; add `redirect` in GoRouter for “logged-in vs guest” once real auth exists; prepare `deep_link`/`app_links` stub.

**Alternative:** **API contract & error mapping** — central `Dio` error interceptor, typed failure model, and environment-specific `AppConfig` profiles (dev/staging/prod).

---

*Plan written before initial application code changes; sections 6–8 and §10 updated after the polish pass (2026-05-09).*
