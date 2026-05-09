# Prani Doctor Mobile MVP Audit & Launch Checklist

## 1. Audit Date & Repo

| Field | Value |
|-------|-------|
| **Repository** | `balagpetcare/pranidoctor-mobile` (local folder: `pranidoctor_mobile`) |
| **Branch** | `main` (detected at audit time) |
| **Audit date** | 2026-05-09 |

---

## 2. Executive Summary

| Item | Assessment |
|------|------------|
| **Overall mobile MVP readiness** | **Low–partial.** UI foundations, navigation, and several **data repositories** (animals, service requests, providers, notifications, tutorials) are in place, but **real customer and doctor authentication is not implemented**; many flows are still **“খোলস” (shell)** with disabled inputs or no API calls. |
| **Launch risk level** | **High** for a real pilot without completing auth and token lifecycle; **Medium** for UI-only demos against a server with manually injected JWTs. |
| **Recommended launch decision** | **Not Ready** for end-user pilot; **Internal Alpha** for engineering demos only — **not** Public MVP or Pilot Ready until OTP/login and secured API access are complete. |

---

## 3. Completed Mobile Features

- [x] **Project setup** — Flutter 3.41.x, Dart 3.11, `pubspec.yaml` with Riverpod, Dio, go_router, flutter_secure_storage, shared_preferences, intl, flutter_localizations.
- [x] **App shell** — `lib/main.dart` → `PraniDoctorApp`; Material 3 theme (`lib/src/app/theme.dart`), BN locale, readable padding helpers (`screen_padding.dart`).
- [x] **Routing** — `GoRouter` (`lib/src/app/router.dart`): splash, onboarding, customer login entry, home shell, doctor login/home (stub), provider lists, tutorials, notifications, booking wizard, service request detail (deep link).
- [x] **Splash → onboarding → login** — timed splash; `SharedPreferences` for onboarding completion (`pd_onboarding_done`).
- [x] **Home shell** — bottom navigation: হোম, অনুরোধ, আমার পশু, প্রোফাইল (`home_shell_screen.dart`).
- [x] **Customer home** — menu tiles + links to doctor list, technician list, tutorials, notifications (`home_screen.dart`).
- [x] **Animals** — list / detail / create-edit flows within animals tab (`features/animals/`), wired to **`GET/POST/PATCH`** `/api/mobile/animals` via `AnimalProfileRepository`.
- [x] **Service requests** — list + FAB → booking wizard (`booking_wizard_screen.dart`); detail + cancel (`service_requests_tab_screen.dart`); **`POST/GET/PATCH`** `/api/mobile/service-requests` (`ServiceRequestRepository`).
- [x] **Provider finder** — doctor and technician list/detail with filters; **`GET`** `/api/mobile/providers/doctors` & `technicians` (`provider_finder_repository.dart`).
- [x] **Tutorials (Knowledge Hub)** — list + detail; public categories endpoint used where applicable.
- [x] **In-app notifications UI** — list; **`GET`** `/api/notifications`, **`PATCH`** read/mark-all (`notification_repository.dart`).
- [x] **API client** — `Dio` with JSON defaults, **`Authorization: Bearer`** interceptor reading `TokenStorage` (`dio_provider.dart`, `api_client.dart` — includes **get/post/patch**).
- [x] **Token storage** — `flutter_secure_storage` keys `pd_access_token` / `pd_refresh_token` (`token_storage.dart`).
- [x] **Repositories** — consistent `{ ok, data }` unwrap + localized Bengali error mapping for major APIs.
- [x] **Doctor-facing stub routes** — `/doctor/login`, `/doctor/home` (placeholder UX only).
- [x] **Tests** — default `test/widget_test.dart` passes; **`flutter analyze`** clean.
- [x] **Android debug build** — `flutter build apk --debug` succeeds (2026-05-09).

---

## 4. Incomplete Mobile Features

### P0 — launch blocker

- [ ] **Customer OTP / login integration** — `LoginEntryScreen` explicitly states no real auth; fields **disabled**; **no** call to backend auth; **no** `writeAccessToken` on success (`login_entry_screen.dart`).
- [ ] **Authenticated session model** — `SessionNotifier` never sets **`isAuthenticated: true`**; role-only persistence (`pd_last_role`) — session state does not reflect JWT presence.
- [ ] **End-to-end API access for customers** — All protected mobile APIs require a valid Bearer JWT from **pranidoctor-web**; without login routes on backend + mobile, production pilot **cannot** use animals/requests/notifications as designed.

### P1 — before pilot

- [ ] **Structured area selection** — Booking wizard submits **`animalId`, `serviceCategoryId`, `serviceType`, symptoms, location text** — **no `areaId` / `villageId`** in submit body (`booking_wizard_screen.dart` `_submit`). Geography selection UX incomplete vs MVP scope.
- [ ] **Provider finder area coverage** — `ProviderFinderRepository` only allows **`ashulia-union-area`** as `areaSlug`; other slugs dropped (`_allowedAreaSlugs`) — intentional pilot lock but limits general rollout.
- [ ] **Doctor mobile workflow** — No integration with `/api/doctor/*` (login, service requests, treatment, prescriptions). Doctor screens are **stub only** (`doctor_login_screen.dart`, `doctor_home_screen.dart`).
- [ ] **Home menu dead ends** — Several `HomeScreen` tiles (`জরুরি ডাক্তার`, `আমার পশু`, `চিকিৎসার ইতিহাস`) have **`default: break`** — no navigation (`home_screen.dart`).
- [ ] **Doctor entry discovery** — No prominent link from customer login to **`/doctor/login`** (route exists but is easy to miss).

### P2 — after pilot

- [ ] **Push notifications (FCM)** — No Firebase / FCM dependencies or setup in `pubspec.yaml`.
- [ ] **Offline / retry UX** — No global connectivity banner or request retry queue beyond per-screen `RefreshIndicator` / SnackBars.
- [ ] **iOS release checklist** — `ios/` present but not build-verified in this audit.
- [ ] **Production application ID / signing** — Android still **`com.example.pranidoctor_mobile`** and release signing TODO (`android/app/build.gradle.kts`).

---

## 5. Bugs / Broken Areas

| Issue | Path / notes |
|-------|----------------|
| **Home tiles without navigation** | `lib/src/features/home/home_screen.dart` — indices 0, 3, 4 fall through `default` (no `onTap` action). |
| **“Login” bypasses security** | `LoginEntryScreen` — primary button **`context.go(HomeShellScreen.routePath)`** without setting tokens — gives full UI without API auth (acceptable only for dev demos). |
| **Doctor login bypass** | `doctor_login_screen.dart` — continues to doctor home **without** credentials or doctor JWT. |

*No compile-time or analyzer failures observed (`flutter analyze` clean).*

---

## 6. Mobile Security Risks

### Token storage risks

- **Secure storage is implemented** (`flutter_secure_storage`) but **tokens are never written** on the shell login path — risk is **missing auth**, not leakage yet.
- **`refresh` token** key exists but **no refresh flow** implemented in Dio interceptors.

### API base URL risks

- **Default `http://localhost:3000`** — wrong for device/emulator unless overridden (`AppConfig.apiBaseUrl` via `--dart-define=API_BASE_URL=...`). Misconfiguration → confusing failures or accidental cleartext to wrong host.
- **Production** must use **HTTPS** and correct host for **pranidoctor.com** API.

### OTP risks

- **No OTP entry flow** — no handling of rate limits, code expiry, or anti-enumeration on device (backend responsibility once APIs exist).

### Sensitive logging risks

- **API base URL shown** on login/doctor screens for debugging — acceptable in dev; **remove or gate** for production store builds.

### Production build risks

- **`android:usesCleartextTraffic="true"`** — convenient for local HTTP; **must be false** or network-security-config restricted for production HTTPS-only (`android/app/src/main/AndroidManifest.xml`).
- **Release signing** still on debug keys placeholder comment — store submission blocked until fixed.

---

## 7. Missing Environment / Config Values

| Config | Required For | Current Status | Example Value Needed | Risk |
|--------|--------------|----------------|----------------------|------|
| **`API_BASE_URL` (`--dart-define`)** | All REST calls via Dio | **Optional**; defaults to `http://localhost:3000` (`app_config.dart`) | `https://api.pranidoctor.com` or staging URL | **High** if unset on device (localhost unreachable) |
| **Emulator / LAN IP** | Android emulator → host machine | Documented in code comment pattern | `http://10.0.2.2:3000` | **High** for dev without `-d` flag |
| **(Future) OTP / auth flags** | Login flows | Not in codebase | N/A until backend contract | **High** when implementing auth |
| **FCM / push keys** | Push notifications | Not integrated | N/A | **Medium** post-MVP |

---

## 8. Customer App Readiness

- [x] Splash / onboarding — `splash_screen.dart`, `onboarding_screen.dart`
- [x] Login entry — **UI only**; **not real login**
- [ ] OTP start / verify — **Not implemented** (fields disabled; no screens)
- [x] Home — `home_screen.dart` (partial navigation — see §5)
- [x] Animal profile list / create / edit / detail — `animals_tab_screen.dart`, `animal_*_screen.dart`
- [ ] Area selection — **Not** wired into booking submit as structured IDs (free-text location step only)
- [x] Provider finder — doctor & technician list/detail
- [x] Service request create / list / detail / cancel — wizard + tab + detail
- [x] Notification — list + mark read (requires Bearer + backend)
- [ ] Payment / manual payment — **Not implemented** (no screens; fee display on provider cards only at UI level)
- [x] Profile / settings / logout — profile tab placeholder + **sign out** clears secure tokens (`home_shell_screen.dart`); **no** rich profile settings

---

## 9. Doctor App Readiness

**Status: not ready** — stub routes only.

- [ ] Doctor login — UI placeholder; **disabled** fields; **no** `/api/doctor/auth/login` integration (`doctor_login_screen.dart`)
- [ ] Assigned request list — **not implemented** on mobile (doctor home shows tutorials + API base text only)
- [ ] Accept / reject — **not implemented**
- [ ] Treatment note — **not implemented**
- [ ] Prescription — **not implemented**
- [ ] Complete case — **not implemented**
- [ ] Billing visibility — **not implemented**
- [ ] Notification — shared **`/api/notifications`** could work **if** doctor JWT + cookie/session pattern were implemented — **currently no doctor token flow on mobile**

---

## 10. API Integration Readiness

| Topic | Status |
|-------|--------|
| **API client** | **Good** — Dio singleton, timeouts, JSON headers, Bearer interceptor. |
| **Auth token handling** | **Incomplete** — read on each request; **no** login writes token; **no** refresh; **no** 401 global handler → login. |
| **Endpoint coverage** | **Strong** for customer domains listed in repos; **zero** for doctor APIs on mobile. |
| **Error handling** | **Per-repository** Bengali messages + HTTP codes — consistent pattern. |
| **Loading / empty states** | **Present** on major async screens (`AsyncValue`, pull-to-refresh on requests list). |
| **Offline / poor network** | **Minimal** — Dio errors surfaced as SnackBars / error panels; no queued offline mode. |

---

## 11. Android / iOS Build Readiness

| Topic | Status |
|-------|--------|
| **Android** | **Debug APK builds successfully** (`flutter build apk --debug`). |
| **iOS** | **Folder present** — not built or signed in this audit; standard Flutter template assumed. |
| **App icon / splash** | Default Flutter / `@mipmap/ic_launcher`; splash uses **icon + text** in `SplashScreen` widget (no custom native splash audited). |
| **Permissions** | **INTERNET** implied; **no** camera/storage permissions declared for photo features (animal photo upload not audited as live). |
| **Package name / bundle ID** | Android **`com.example.pranidoctor_mobile`** — **must change** for production (`android/app/build.gradle.kts`). |
| **Production signing** | **Not ready** — release uses debug signing placeholder. |

---

## 12. Payment Readiness

| Topic | Status |
|-------|--------|
| **Current status** | **No payment screens**, no bKash/Nagad SDKs, no in-app billing. Provider detail shows fee-like UI affordances only. |
| **Manual pilot workaround** | Operator confirms payment outside app; customer sees status via **service request / admin** — document process for pilots. |
| **Future gateway** | Add dedicated payment feature module + backend **`/api/mobile/payments`** when web API exists; never store card PAN in app. |

---

## 13. Notification & SMS Readiness

| Topic | Status |
|-------|--------|
| **In-app notification UI** | **Implemented** — list, unread filter, mark read / mark all (`notifications_list_screen.dart`, repository). |
| **Push notifications** | **Not implemented** — no FCM. |
| **OTP SMS dependency** | **Fully backend-driven** — mobile has **no** OTP UI; SMS via **pranidoctor-web** once `/api/mobile/auth/*` exists. |

---

## 14. Pilot Launch Checklist

1. [ ] **Test install on Android device** — install debug/release APK; verify network to staging API (replace localhost).
2. [ ] **Login with OTP** — **blocked** until mobile + backend ship OTP and token storage on success.
3. [ ] **Create animal** — works **only with valid Bearer JWT** (manual token injection or future login).
4. [ ] **Create service request** — same; verify booking payload matches backend **required fields** (add **area IDs** when product requires).
5. [ ] **Receive notification** — verify in-app list after backend creates `Notification` rows for user.
6. [ ] **Admin sees request** — **web admin** (`pranidoctor-web`); out of mobile repo.
7. [ ] **Doctor accepts request** — **web doctor panel or future mobile doctor app** — mobile doctor stub **not** sufficient.
8. [ ] **Complete case** — same as above.
9. [ ] **Collect pilot feedback** — forms/process external to app.

---

## 15. Critical Fixes Applied

No code fixes were applied in this audit task.

*(Verification: `flutter pub get`, `flutter analyze`, `flutter test`, `flutter build apk --debug` — all succeeded on 2026-05-09.)*

---

## 16. Final Mobile MVP Status

| Dimension | % |
|-----------|---|
| Mobile app foundation readiness | **68%** |
| Customer workflow readiness | **42%** |
| Doctor workflow readiness | **12%** |
| API integration readiness | **48%** |
| Payment readiness | **5%** |
| Android readiness | **72%** |
| iOS readiness | **45%** *(folder exists; not build-verified)* |
| Pilot launch readiness | **28%** |

---

## 17. Next Recommended Task

**Task Card — Mobile customer OTP & session:** Implement **`LoginEntryScreen`** (and optional dedicated OTP screens) calling **`pranidoctor-web`** `POST /api/mobile/auth/otp/request` & `…/verify` once available; on success **`writeAccessToken`**, set **`SessionNotifier`** authenticated state, add **401 interceptor → logout**, and gate **`HomeShellScreen`** behind token presence (remove demo bypass). Align **`API_BASE_URL`** docs for emulator vs device.
