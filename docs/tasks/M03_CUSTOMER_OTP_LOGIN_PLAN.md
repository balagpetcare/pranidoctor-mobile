# M03 — Customer OTP Login & Auth State (Plan)

**Project:** Prani Doctor / Animal Doctors mobile app  
**Repo:** `balagpetcare/pranidoctor-mobile`  
**Domain:** https://pranidoctor.com/  
**Scope:** Mobile app only (no backend changes in this task).

---

## 1. Current project audit summary

| Area | Finding |
|------|---------|
| **Entry** | `lib/main.dart` → `ProviderScope` → `PraniDoctorApp`. |
| **State** | **Flutter Riverpod 3** (`NotifierProvider`, `Provider`). No BLoC/Provider package beyond Riverpod. |
| **Navigation** | **go_router** via `goRouterProvider`; `initialLocation` = splash; redirect uses `sessionNotifierProvider`. |
| **HTTP** | **Dio** with `dioProvider`: `AppConfig.apiBaseUrl`, JSON headers, **Bearer token** from `TokenStorage` on each request, **401 → `signOut()` + `go(/login)`**. |
| **Secure storage** | **`flutter_secure_storage`** wrapped by `SecureStorageService` → `TokenStorage` (`pd_access_token`, `pd_refresh_token`). **Already present — use it.** |
| **Session** | `SessionNotifier`: `hydrateFromStorage()` reads JWT cold start; `signInCustomer(token)` writes token + role customer; **`signInGuest()`** sets authenticated **without** persisting JWT (M02 demo bypass); `signOut()` clears secure storage. |
| **Auth UI** | `LoginEntryScreen` is a **placeholder**: Bengali copy + **“চালিয়ে যান”** calls `signInGuest()` + `go(/home)` — **no OTP yet**. |
| **Auth API (partial)** | `MobileOtpAuthRepository` already calls Dio for OTP but uses path **`/api/mobile/auth/otp/request`** (not `/otp/start`). Verify handler expects `{ ok, data }` and token at `data.accessToken`. |
| **Localization** | `MaterialApp.router`: **`locale: Locale('bn', 'BD')`**, supported `bn_BD` + `en_US` — **Bengali-first** at app level; strings are mostly inline Bangla. |
| **Theme / DS** | `AppTheme` (Material 3, teal–emerald), `PdTypography`, `PdPalette`, `design_system.dart` barrel; widgets: `PdTextField`, `PdLoadingBody` / `PdErrorBody`, `pdScreenPadding`, etc. |
| **Tests** | Single `test/widget_test.dart` — smoke test app build + splash delay. |

---

## 2. Existing files (relevant) and purpose

| File | Purpose |
|------|---------|
| `lib/main.dart` | Bootstraps Riverpod `ProviderScope`. |
| `lib/src/app/app.dart` | `MaterialApp.router`, theme, **locale bn_BD**. |
| `lib/src/app/router.dart` | `GoRouter` routes, **redirect**: unauthenticated users → `/login` except splash/onboarding/login public paths; **`/doctor/*` exempt** from customer auth; listens to session refresh. |
| `lib/src/app/theme.dart` | Prani Doctor light/dark themes. |
| `lib/src/app/screen_padding.dart` | Responsive horizontal padding. |
| `lib/src/app/navigation_keys.dart` | Root navigator key for global navigation from interceptors. |
| `lib/src/core/config/app_config.dart` | `API_BASE_URL` via `--dart-define` (default `http://localhost:3000`). |
| `lib/src/core/network/dio_provider.dart` | Shared Dio + auth header + 401 handling. |
| `lib/src/core/network/api_client.dart` | Thin Dio facade (optional reuse). |
| `lib/src/core/storage/secure_storage_service.dart` | `FlutterSecureStorage` wrapper. |
| `lib/src/core/storage/token_storage.dart` | Access/refresh keys for customer JWT. |
| `lib/src/features/session/application/session_notifier.dart` | Auth state, hydrate, `signInCustomer`, `signInGuest`, `signOut`. |
| `lib/src/features/auth/login_entry_screen.dart` | Customer login **placeholder** (guest entry). |
| `lib/src/features/auth/data/mobile_otp_auth_repository.dart` | OTP **start/request** + **verify** API calls (paths need alignment with product contract). |
| `lib/src/features/splash/splash_screen.dart` | Delay → `hydrateFromStorage()` → onboarding or home or login. |
| `lib/src/features/onboarding/onboarding_screen.dart` | Ends at `/login`. |
| `lib/src/features/home/home_shell_screen.dart` | Customer main shell (bottom nav). |
| `lib/src/features/home/presentation/customer_shell_tab_placeholders.dart` | Profile tab: **“প্রস্থান”** → `signOut()` + `go(/login)` — **logout hook exists**. |
| `lib/src/core/widgets/pd_text_field.dart` | Bangla-friendly labeled fields. |
| `lib/src/core/widgets/pd_async_states.dart` | `PdLoadingBody`, `PdErrorBody` for loading/error UX. |
| `lib/src/core/design_system.dart` | Design system exports. |
| `test/widget_test.dart` | Minimal widget smoke test. |

---

## 3. Proposed minimal implementation plan

1. **Align OTP transport layer**  
   - Update `MobileOtpAuthRepository` to use the **canonical OTP start path** agreed for Prani Doctor mobile: **`POST /api/mobile/auth/otp/start`** per product spec.  
   - **Important:** The codebase currently implements **`/api/mobile/auth/otp/request`**. If the deployed API only exposes `request` until renamed, either (a) use **`start` in code** and document that the server must expose the same contract at `/otp/start`, or (b) use a **single constant** (e.g. `AppConfig.mobileOtpStartPath`) defaulting to `start`, overridable via `--dart-define` for staging — **without adding packages**.  
   - Keep **`verify`** as **`POST /api/mobile/auth/otp/verify`** (already matches).  
   - Preserve parsing of `{ ok, data }` and **`data.accessToken`** on verify; keep Bengali `OtpAuthException` messages.

2. **Login UI on `LoginEntryScreen` (incremental, low-risk)**  
   - Replace demo-first flow with **phone + OTP** while reusing **theme**, **`PdTextField`**, **`FilledButton`**, `pdScreenPadding`.  
   - **Step A:** Phone field + “কোড পাঠান” → calls start/request → success moves to OTP step (same screen or second section).  
   - **Step B:** OTP field + “নিশ্চিত করুন” → `verify` → `signInCustomer(token)` → `context.go(HomeShellScreen.routePath)`.  
   - **Remove or gate `signInGuest`:** For M03, **remove the primary “চালিয়ে যান” demo bypass** from the default UI so unauthenticated users cannot reach `/home` without a token; optional **debug-only** guest entry could remain behind `kDebugMode` + explicit label — only if needed for QA (narrow diff).

3. **Session & router**  
   - No structural change required: **`signInCustomer`** already persists JWT and sets authenticated customer.  
   - **Splash** already calls **`hydrateFromStorage()`** — users with a stored token skip login.  
   - **401** path already clears storage and returns to login.

4. **Logout**  
   - **No new hook required:** Profile tab already calls **`signOut()`** and navigates to **`LoginEntryScreen`**. Optionally shorten duplicate navigation if `signOut` is ever invoked without `go` (not required for M03).

5. **Validation & copy**  
   - Centralize **Bangladesh mobile** rules in a small pure helper (same file or `lib/src/core/validation/bd_phone.dart`) — **no new package**.

---

## 4. Exact files to create / update

| Action | Path |
|--------|------|
| **Update** | `lib/src/features/auth/login_entry_screen.dart` — OTP UI, states, Bengali strings. |
| **Update** | `lib/src/features/auth/data/mobile_otp_auth_repository.dart` — OTP **start** path + consistent error parsing (and documented JSON contract). |
| **Optional new** | `lib/src/core/validation/bd_phone.dart` — normalize/validate BD numbers (E.164 `+880` / local `01…`). |
| **Optional update** | `lib/src/core/config/app_config.dart` — only if using `dart-define` for OTP start path segment (minimal constant). |
| **Update** | `test/widget_test.dart` — extend or add focused test(s) (see §10). |

**Do not change:** backend repos, unrelated feature screens, doctor flows, or shell placeholders beyond what is necessary for login navigation.

---

## 5. Auth flow (target)

| Step | Behavior |
|------|----------|
| 1 | Unauthenticated user finishes onboarding or cold-starts without token → **`/login`**. |
| 2 | User enters **Bangladesh phone** (validated + normalized to API format). |
| 3 | User taps send OTP → **`POST …/otp/start`** (or configured start path) → show success feedback (“কোড পাঠানো হয়েছে”) and enable OTP entry. |
| 4 | User enters OTP → **`POST …/otp/verify`** with `phone` + `code`. |
| 5 | On success, **`SessionNotifier.signInCustomer(accessToken)`** → token in **secure storage**, role **customer**. |
| 6 | **`context.go('/home')`** → **`HomeShellScreen`**. |
| 7 | **Logout:** Profile → **“প্রস্থান”** → **`signOut()`** clears tokens → **`go('/login')`**. |

---

## 6. API abstraction (mobile-side)

**Use existing `Dio` via `dioProvider` / `MobileOtpAuthRepository`.** No new HTTP client package.

### Expected operations

| Operation | Method & path (product spec) | Request body | Success envelope |
|-----------|------------------------------|--------------|-------------------|
| Start OTP | `POST /api/mobile/auth/otp/start` | `{ "phone": "<string>" }` | `{ "ok": true, "data": { ... } }` (e.g. TTL / sent flag — optional UI) |
| Verify OTP | `POST /api/mobile/auth/otp/verify` | `{ "phone": "<string>", "code": "<string>" }` | `{ "ok": true, "data": { "accessToken": "<jwt>", ... } }` |

### Error envelope (already partially handled in repository)

```json
{
  "ok": false,
  "error": { "code": "STRING", "message": "Human-readable (prefer Bengali from server when available)" }
}
```

### Path note (contract assumption)

- Task naming uses **`/otp/start`**. Current mobile stub uses **`/otp/request`**. The implementation plan should pick **one** path for production and document the other as legacy/alias. **Backend changes are out of scope for M03** — if only `/request` exists in deployment, teams align via config or server route alias **outside** this mobile-only task.

### Refresh token

- `TokenStorage` supports **`pd_refresh_token`**, but verify response today may only return **access** token. **Do not block M03** on refresh — document **non-goal** unless API returns refresh.

---

## 7. Bengali-first UI rules

- **All user-visible labels, buttons, helper text, inline validation errors** on the login flow should be **Bangla** (e.g. “মোবাইল নম্বর”, “কোড পাঠান”, “যাচাই করুন”, “নেটওয়ার্ক ত্রুটি”) — matching **`LoginEntryScreen`**, splash, and onboarding tone.  
- Use **`Theme.of(context)`** / **`AppTheme`** — no ad-hoc colors outside scheme.  
- English **only** where unavoidable (e.g. technical debug line in `kDebugMode`), not in customer-facing strings.

---

## 8. Bangladesh phone validation rule

- **Accept** common inputs: local **`01XXXXXXXXX`** (11 digits after leading 0), **optional spaces/dashes**.  
- **Normalize** to API format: prefer sending **`+8801XXXXXXXXX`** (E.164) if the backend expects it; if backend expects local string, document one chosen format in repository comments.  
- **Reject** wrong length, non-mobile prefixes, or empty input — show **Bangla** validation messages (e.g. “সঠিক ১১ সংখ্যার মোবাইল নম্বর দিন”)।  
- Use **`intl`** only if needed for formatting; **no new package** required for digit checks.

---

## 9. Loading / error / success state plan

| State | UX |
|-------|-----|
| **Idle** | Form enabled; primary button enabled when phone valid (optional). |
| **Sending OTP** | Disable send button; **`PdLoadingBody`** inline or linear progress + Bengali “পাঠানো হচ্ছে…” |
| **OTP sent** | Snackbar or text: “কোড পাঠানো হয়েছে”; focus OTP field; optional countdown using `otpTtlSeconds` if returned. |
| **Verifying** | Disable verify button; show loading on primary action. |
| **Error** | **`OtpAuthException`** / Dio → show **`SnackBar`** or inline **`PdErrorBody`** pattern with **retry** where appropriate; preserve repository’s Bengali network fallback. |
| **Success (verify)** | Navigate to home; no extra modal if navigation is immediate. |

Accessibility: respect `minTapHeight` from theme on buttons (already in `AppTheme`).

---

## 10. Test plan

| Test | Description |
|------|-------------|
| **Widget / unit** | `MobileOtpAuthRepository`: mock `Dio` / handler — verify **`/otp/start`** and **`/verify`** paths, success **`data.accessToken`**, error **`ok: false`**. |
| **Unit** | BD phone helper: valid/invalid cases for `01…` and `+880…`. |
| **Widget** | `LoginEntryScreen` with **overridden providers**: fake repository + fake session — tap flow does not throw; **optional** golden not required for M03. |
| **Existing** | Keep **`PraniDoctor app builds`** smoke test; adjust timing/pump if login UI adds async **without** breaking CI stability. |

---

## 11. Risks and non-goals

### Risks

| Risk | Mitigation |
|------|------------|
| **`/otp/start` vs `/otp/request`** mismatch | Single configurable path constant + documentation; coordinate deployment separately. |
| **Guest bypass** left enabled | Users skip real auth — remove from release UI for M03. |
| **401 on expired JWT** | Already logs out; users must OTP again — acceptable for MVP. |
| **SMS rate limits / abuse** | Handled server-side; client shows generic Bengali error. |

### Non-goals (M03)

- Backend changes, new API routes, SMS provider config.  
- Social login, password login, doctor OTP.  
- **Refresh token** rotation unless API returns refresh.  
- Deep link / magic link login.  
- Changing unrelated tabs (animals, providers, booking) UI.  
- Adding **new pub dependencies** unless truly unavoidable (**secure storage already exists**).

---

## Dependencies (pubspec) — use existing only

Already declared: `flutter_riverpod`, `dio`, `go_router`, `flutter_secure_storage`, `shared_preferences`, `intl`, `flutter_localizations`. **No additional packages planned for M03** unless team standards require none and `intl` suffices.

---

## Summary

| Item | Outcome |
|------|---------|
| **Audit** | Riverpod + go_router + Dio + secure token storage + session hydrate/splash already fit OTP login; login UI is still guest/demo. |
| **Planned files** | Main work in **`login_entry_screen.dart`** + **`mobile_otp_auth_repository.dart`**; optional **`bd_phone.dart`** + **`app_config`** tweak; tests updated. |
| **API assumption** | **`POST /api/mobile/auth/otp/start`** + **`POST /api/mobile/auth/otp/verify`** with **`{ ok, data }`** and **`data.accessToken`**; align path constant with live server (`request` vs `start`). |

---

## 12. Implementation summary (M03 — completed in mobile repo)

### What was built

- **OTP start** via `POST /api/mobile/auth/otp/start` with body `{ "phone": "8801XXXXXXXXX" }` (digits only, no `+`).
- **OTP verify** via `POST /api/mobile/auth/otp/verify` with body `{ "phone": "…", "code": "<otp>" }`. The JSON key is **`code`** to match common existing Next.js mobile routes (strict JSON). Product docs that say `otp` refer to the same value; the **wire name** is `code` unless the server is changed to accept `otp`.
- **Token parsing** is defensive: `parseAccessTokenFromVerifyBody` checks `accessToken` / `token` at top level and under `data`.
- **Session:** `signInCustomer` + `TokenStorage` + splash `hydrateFromStorage` unchanged in behavior; **guest demo** remains only as **kDebugMode** “ডেমো প্রবেশ (শুধু ডিবাগ)” on the login screen.
- **UI:** Bengali-first **phone login** (`LoginEntryScreen`) and **OTP screen** (`OtpVerifyScreen` at `/login/otp`) with resend cooldown, loading states, and profile **logout** unchanged.
- **Routing:** `/login/otp` is a public sub-route; redirect sends missing **phone** extra back to `/login`; authenticated users hitting `/login` or `/login/otp` go to `/home`.
- **BD phone** helper `BdPhone` in `lib/src/core/validation/bd_phone.dart` — normalizes `01…` and `+880…` to `8801…` and validates with `^8801[3-9]\d{8}$`.

### Final files changed / added

| File | Change |
|------|--------|
| `lib/src/core/validation/bd_phone.dart` | **Added** — normalize/validate/mask display. |
| `lib/src/core/widgets/pd_text_field.dart` | **Updated** — optional `inputFormatters` for phone field. |
| `lib/src/features/auth/data/mobile_otp_auth_repository.dart` | **Updated** — `start` + `verify`, `OtpStartResult`, defensive token parse, `_ensureOk` treats missing `ok` as success. |
| `lib/src/features/auth/login_entry_screen.dart` | **Updated** — phone UI, send OTP, navigate to named OTP route. |
| `lib/src/features/auth/otp_verify_screen.dart` | **Added** — 6-digit OTP, verify, resend, change number. |
| `lib/src/app/router.dart` | **Updated** — nested `/login/otp`, public path + redirects, `extra` map for `phone` + `ttl`. |
| `test/otp_auth_test.dart` | **Added** — `BdPhone` + `parseAccessTokenFromVerifyBody` tests. |
| `docs/tasks/M03_CUSTOMER_OTP_LOGIN_PLAN.md` | **Updated** — this section. |

Unchanged on purpose: `session_notifier.dart`, `token_storage.dart`, `dio_provider.dart`, `splash_screen.dart` (still hydrates then routes), profile logout placeholder.

### API assumptions (reference)

| Item | Detail |
|------|--------|
| **Start** | `POST /api/mobile/auth/otp/start` — `{ "phone": "8801XXXXXXXXX" }` |
| **Verify** | `POST /api/mobile/auth/otp/verify` — `{ "phone": "8801XXXXXXXXX", "code": "123456" }` |
| **Success** | Prefer `{ "ok": true, "data": { "accessToken": "…" } }`; also supports `data.token`, or top-level `accessToken` / `token`. |
| **Errors** | `{ "ok": false, "error": { "message": "…" } }` (and HTTP status). |
| **Backend path alias** | If production still exposes only **`/api/mobile/auth/otp/request`** for send, add a server-side alias or proxy to **`/otp/start`** — **not** changed in mobile as part of “no backend edits” here; mobile code targets **`/otp/start`**. |

### Test commands

```bash
cd D:\PraniDoctor\pranidoctor_mobile
flutter analyze lib test
flutter test
```

### Pending / notes

- **Wire field `otp` vs `code`:** Mobile sends **`code`** for verify. If a server only accepts **`otp`**, the API contract must be aligned on the server or mobile body updated in a follow-up.
- **OTP start path:** If **`/otp/start`** 404s against a given deployment, confirm whether **`/otp/request`** is still the live route and coordinate routing — without editing backend in-repo from this task.

**Original plan sections 1–11 are retained above for history; implementation matches their intent unless noted in §12.**

---

## 13. Verification run (automated — Task M03)

**When:** 2026-05-09  
**Machine:** Windows; project path `D:\PraniDoctor\pranidoctor_mobile`

### Commands run (in order)

| Step | Command | Result |
|------|---------|--------|
| 1 | `dart format .` | **Exit 0** — formatted **5 files** (M03-related: `bd_phone.dart`, `mobile_otp_auth_repository.dart`, `login_entry_screen.dart`, `otp_verify_screen.dart`, `otp_auth_test.dart`; total **75** files scanned). |
| 2 | `flutter analyze` | **Exit 0** — **No issues found!** |
| 3 | `flutter test` | **Exit 0** — **9 tests passed** (`otp_auth_test.dart` × 8 + `widget_test.dart` × 1). |

### Automated coverage vs manual checklist

| Check | Automated | Notes |
|-------|-----------|--------|
| App starts without auth crash | **Partial** | Widget smoke test pumps app + splash delay; does not replace `flutter run` on device/emulator. |
| Unauthenticated → login | **Partial** | Routing logic covered by integration tests only if added; recommend manual cold start without token → `/login`. |
| Phone `017…` / `880171…` / invalid short | **Partial** | `BdPhone` unit tests cover normalization and rejection of invalid short input; manual entry in UI still recommended once per release. |
| OTP loading/error UI | **Partial** | Logic in widgets; no golden/integration test in repo. |
| Token storage compiles | **Yes** | Analyzer + existing imports resolve `TokenStorage` / secure storage. |
| Home shell routing intact | **Partial** | Widget test builds full app; does not navigate every shell tab. |

### Known limitations

- **`/api/mobile/auth/otp/start`** must exist on the deployed API (or a proxy to legacy **`/otp/request`**); otherwise OTP send fails at runtime — not detectable by unit/widget tests alone.
- **Verify body** uses JSON key **`code`**; servers expecting **`otp`** need a contract alignment (see §12).
- **Full login → OTP → home** flow requires a running backend or mock server — not executed in `flutter test`.

### Fixes applied during this verification

- **None required for analyzer/tests.** Only **`dart format`** reapplied consistent formatting to the five files listed above.

---
