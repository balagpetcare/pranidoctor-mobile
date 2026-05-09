# Task M10 — AI Technician Service Pages (Audit & Plan)

**Project:** Prani Doctor / Animal Doctors — mobile app only  
**Domain:** [https://pranidoctor.com/](https://pranidoctor.com/)  
**Repo:** [github.com/balagpetcare/pranidoctor-mobile](https://github.com/balagpetcare/pranidoctor-mobile)  
**Local path:** `D:\PraniDoctor\pranidoctor_mobile`  

**Scope:** Artificial insemination (AI) **technician workflow** UI. **Planning** (§1–§17) plus **implementation delivery** (§18). **Do not** change backend. **Isolation:** No BPA/WPA, Quarbani 2026, or other products.

**Last updated:** 2026-05-09 (M10 screens + mock/live repository + test/fix verification)

---

## 1. Task summary

Deliver a **Bengali-first**, modular Flutter flow so an **AI technician** can:

- See a **dashboard** with entry points to new requests and active jobs.
- Browse **new AI service requests** assigned or offered to them (per API contract).
- Browse **active jobs** and open **job detail**.
- **Accept** or **reject** a job.
- Fill an **AI service record** (procedure details, placeholders for semen/breed, notes, date/time).
- **Complete** a service / job (with confirmation and optimistic refresh pattern).

This document captures **audit findings**, **architecture alignment**, **file/route/API plans**, **mock fallback**, **data/UI/state/test/acceptance** plans, and **§18 implemented delivery**.

---

## 2. Existing files audited (mobile repo)

| Area | Paths / notes |
|------|----------------|
| **App entry & shell** | `lib/main.dart`, `lib/src/app/app.dart` |
| **Routing** | `lib/src/app/router.dart`, `lib/src/app/navigation_keys.dart` |
| **Theme / design system** | `lib/src/app/theme.dart` (Material 3, teal seed, Bengali-friendly `fontFamilyFallback`) |
| **Layout helpers** | `lib/src/app/screen_padding.dart` (`pdScreenPadding`, `pdReadableMaxWidth`) |
| **HTTP** | `lib/src/core/network/dio_provider.dart` (Bearer from secure storage, 401 → sign out + `go(/login)`), `lib/src/core/network/api_client.dart`, `lib/src/core/config/app_config.dart` (`API_BASE_URL` dart-define) |
| **Storage** | `lib/src/core/storage/token_storage.dart`, `secure_storage_service.dart` |
| **Session / roles** | `lib/src/features/session/application/session_notifier.dart` |
| **Splash / onboarding** | `lib/src/features/splash/splash_screen.dart`, `lib/src/features/onboarding/onboarding_screen.dart` |
| **Auth (customer)** | `lib/src/features/auth/login_entry_screen.dart`, `lib/src/features/auth/data/mobile_otp_auth_repository.dart` |
| **Auth (doctor shell)** | `lib/src/features/auth/doctor/presentation/doctor_login_screen.dart`, `lib/src/features/home/doctor/presentation/doctor_home_screen.dart` |
| **Customer shell** | `lib/src/features/home/home_shell_screen.dart`, `lib/src/features/home/home_screen.dart` |
| **Service requests (customer)** | `lib/src/features/service_requests/data/service_request_model.dart`, `service_request_repository.dart`, `service_category_repository.dart`, `application/service_requests_providers.dart`, `presentation/service_requests_tab_screen.dart` (includes `ServiceRequestDetailScreen`), `presentation/booking_wizard_screen.dart` |
| **Provider / technician finder (customer)** | `lib/src/features/providers/data/provider_models.dart`, `provider_finder_repository.dart`, `application/provider_finder_providers.dart`, `presentation/technician_list_screen.dart`, `technician_detail_screen.dart`, widgets under `presentation/widgets/` |
| **Animals (types/breed precedent)** | `lib/src/features/animals/data/animal_profile_model.dart` (`species`, `breed`, enums) |
| **Dependencies** | `pubspec.yaml` — `flutter_riverpod`, `go_router`, `dio`, `flutter_secure_storage`, `shared_preferences`, `intl` |

---

## 3. Existing architecture & patterns found

### 3.1 Routing / navigation

- **go_router** (`go_router: ^17`) with `goRouterProvider` in `router.dart`.
- **Root navigator key** `pdRootNavigatorKey` for global navigation from interceptors.
- **Customer gate:** `redirect` sends unauthenticated users to `LoginEntryScreen` except public paths (`/splash`, `/onboarding`, `/login`) and **any path starting with `/doctor`** (doctor routes are not customer-auth gated).
- **Doctor routes:** `/doctor/login`, `/doctor/home` — parallel “provider shell” pattern.
- **Feature routes:** e.g. `/providers/technicians`, `/providers/technicians/:technicianId`, `/booking/new`, `/service-requests/:requestId`, notifications, tutorials.

**Implication for M10:** Add a **parallel top-level prefix** (recommended: `/technician/...`) with the **same redirect exception** as `/doctor` *or* gate technician routes on a **future technician JWT** once auth exists — see §7 uncertainties.

### 3.2 Auth / user role handling

- `AppRole` enum today: **`customer`**, **`doctor`** only (`session_notifier.dart`).
- Customer: OTP → `signInCustomer(accessToken)` → `isAuthenticated: true`, role `customer`, token in secure storage.
- Doctor login screen: **stub** — `setRole(AppRole.doctor)` then `go(DoctorHomeScreen)` with **`isAuthenticated: false`**; no real doctor API token yet.
- `hydrateFromStorage`: if token present, restores `customer` vs `doctor` from `SharedPreferences` key `pd_last_role` (defaults to customer).

**Implication:** Technician role + token persistence must be **designed** before wiring real APIs (extend `AppRole`, prefs key, `hydrateFromStorage`, and router redirect rules without breaking customer OTP flow).

### 3.3 Service request screens (customer)

- List: `ServiceRequestsTabScreen` — `AsyncNotifierProvider` + `RefreshIndicator`, **loading / error / empty** inline.
- Detail + cancel: `ServiceRequestDetailScreen` in same file as tab — `FutureProvider.family`, Bengali labels, `_StatusBanner`, `_DetailSection`, `SnackBar` on API errors.
- Booking: `BookingWizardScreen` — multi-step `PageController`, `BookingDraft` + `NotifierProvider`.

**Reusable ideas:** Card + `ListTile` rows, status banner colors tied to `ColorScheme`, `pdScreenPadding`, Bengali copy style.

### 3.4 Doctor workflow screens

- `DoctorHomeScreen`: minimal shell — AppBar, sign out, link to tutorials, debug “API client” card.

**Implication:** First technician **dashboard** can mirror this **low-risk shell** then add real lists/actions.

### 3.5 Provider / technician finder (customer-facing)

- `TechnicianListScreen` / `TechnicianDetailScreen`: `AsyncValue.when`, dedicated **`_EmptyBody`** / **`_ErrorBody`** with retry (`technician_list_screen.dart`).
- Data from `/api/mobile/providers/technicians` via `ProviderFinderRepository` — same **`{ ok, data, error }`** envelope as service requests.

**Implication:** Technician **job** UI can reuse **empty/error/retry** composition; **do not** conflate provider finder models with **job/workflow** DTOs (separate types under a new feature module).

### 3.6 Shared widgets / components

- No shared `lib/src/widgets/` barrel yet; patterns are **feature-local** private widgets (`_DetailSection`, `_StatusBanner`, `_EmptyBody`) or small cards (`technician_summary_card.dart`, `doctor_summary_card.dart`).
- Global: `AppTheme`, `pdScreenPadding`, Material 3 components.

**Implication:** Prefer **feature-local** widgets under `technician_ai/` (or chosen module name); extract shared pieces **only** after second duplication (keep diff small per project rules).

### 3.7 API client / repository patterns

- `ApiClient` wraps GET/POST/PATCH on shared `Dio`.
- Repositories (`ServiceRequestRepository`, `ProviderFinderRepository`) implement **`_unwrap`** on `Map` responses: `ok == true`, `data` is `Map`, errors → typed exceptions with **Bengali** default messages (`'অপ্রত্যাশিত উত্তর'`, `'লগইন প্রয়োজন বা সেশন শেষ'`, etc.).
- Riverpod: `Provider` for repositories, `FutureProvider` / `AsyncNotifierProvider` for lists.

**Implication:** Add `TechnicianJobRepository` (name TBD) with the same unwrap/error mapping; keep **camelCase** JSON parsing consistent with existing mobile DTOs.

### 3.8 Loading / error / empty states

- **List loading:** `Center` + `CircularProgressIndicator`.
- **List error:** icon + title + optional exception text + retry (`technician_list_screen` pattern is stronger than `service_requests_tab_screen` for retry).
- **Empty:** icon + explanatory Bengali + optional CTA (`RefreshIndicator` on lists where applicable).

### 3.9 Bengali UI labels & design system

- Copy is **inline Bengali** in widgets (not ARB / `flutter_gen` l10n yet).
- `AppTheme` documents intent (“Bengali-friendly line heights”, Noto Sans Bengali fallback).
- Domain strings for service types/statuses: `ServiceRequestType.labelBn`, `ServiceRequestStatus.labelBn` in `service_request_model.dart`.

**Implication:** M10 screens should use **Bangla primary** labels; keep English **only** for developer hints or API debug surfaces if needed.

### 3.10 AI / technician / service request — what already exists

| Item | Exists? | Where |
|------|---------|--------|
| `ServiceRequestType.AI_SERVICE` | Yes | `service_request_model.dart`, booking wizard (`_needsLocation` includes AI) |
| Customer service request APIs | Yes | `/api/mobile/service-requests` |
| Technician **finder** (browse providers) | Yes | `/api/mobile/providers/technicians`, list/detail UI |
| `assignedTechnicianId` / `assignedTechnician` on `ServiceRequest` | Yes | `service_request_model.dart`, detail UI shows “নিয়োজিত টেকনিশিয়ান” |
| **Technician workflow** (my requests, my jobs, accept/reject, record, complete) | **No** | — |
| `AppRole` / session for AI technician | **No** | Only `customer` / `doctor` |
| Mobile APIs under `/api/mobile/technician/*` | **Not audited in repo** (out of scope; assumed future per task) | — |

---

## 4. Safest implementation approach (low risk)

1. **New feature module** (suggested package path): `lib/src/features/technician_ai/`  
   - Subfolders: `data/`, `application/`, `presentation/` mirroring `service_requests` and `providers`.
2. **Do not** overload `providers/` (customer discovery) or rename existing provider models.
3. **Routing:** Register **`/technician/...`** routes in `router.dart`; mirror **`/doctor`** redirect exception until technician JWT + `requireMobileTechnician` behavior is defined — avoids blocking UI development behind customer login.
4. **Session:** When implementing, extend `AppRole` with **`technician`** (or `aiTechnician`) and persist alongside token; adjust `hydrateFromStorage` and 401 handling if technician uses **different** token storage key (optional `technicianAccessToken` vs reusing single bearer — see §7).
5. **Reuse** `ApiClient`, `AppTheme`, `pdScreenPadding`, Riverpod patterns, `AsyncValue.when` / `RefreshIndicator`.
6. **API boundary:** Single repository class; **mock implementation** behind the same interface for UI work (§8).
7. **Incremental screens:** Dashboard shell → list screens → detail → dialogs/forms → complete flow; each step mergeable without touching customer tabs.

---

## 5. Files to create (implementation phase; not done in audit step)

Under `lib/src/features/technician_ai/` (exact naming can be `technician_workflow` if preferred — pick one and stay consistent):

| File | Purpose |
|------|---------|
| `data/technician_api_exception.dart` | Typed errors + Bengali messages (mirror `ServiceRequestApiException` / `ProviderApiException`) |
| `data/technician_job_models.dart` | DTOs: request summary, job summary, job detail, AI record draft, enums aligned with backend strings |
| `data/technician_job_repository.dart` | HTTP calls to `/api/mobile/technician/*` + unwrap |
| `data/technician_job_repository_mock.dart` | In-memory / fixture implementation for dev |
| `application/technician_job_providers.dart` | `Provider`, `FutureProvider`, `AsyncNotifierProvider` for lists/detail/mutations |
| `presentation/technician_dashboard_screen.dart` | Dashboard entry |
| `presentation/technician_requests_screen.dart` | New / incoming requests list |
| `presentation/technician_jobs_screen.dart` | Active jobs list |
| `presentation/technician_job_detail_screen.dart` | Job detail + actions |
| `presentation/widgets/...` | Optional small widgets (status chip, job summary card) as duplication appears |
| `presentation/technician_ai_record_form_screen.dart` | Form for AI service record |
| `presentation/technician_complete_job_screen.dart` | Review + complete (or merged into detail with sheet — decide at implementation) |

**Auth (when required):**

| File | Purpose |
|------|---------|
| `features/auth/technician/presentation/technician_login_screen.dart` | Stub or real login once API exists |
| Optional: `features/auth/data/technician_auth_repository.dart` | Only if mobile technician auth endpoint is specified |

**Tests (see §13):**

| File | Purpose |
|------|---------|
| `test/technician_job_repository_test.dart` | Parse + unwrap with fake `Dio` / mocked adapter |
| `test/technician_*_screen_test.dart` | Smoke widget tests with `ProviderScope` + mock repo |

---

## 6. Files to modify (later; minimal touch)

| File | Change |
|------|--------|
| `lib/src/app/router.dart` | Register technician routes; extend `redirect` for `/technician` (same as `/doctor` **or** auth-gated — finalize with §7) |
| `lib/src/features/session/application/session_notifier.dart` | Add `AppRole.technician`, prefs hydration, sign-in/out helpers if technician token is separate |
| `lib/src/core/network/dio_provider.dart` | **Only if** technician token must be sent differently (e.g. second interceptor or header); avoid changing customer behavior |
| `lib/src/features/auth/login_entry_screen.dart` or `home_screen.dart` | **Optional** deep link / “টেকনিশিয়ান লগইন” entry — only if product wants in-app entry from customer shell |

**Explicitly avoid** in M10 unless unavoidable: broad edits to `service_requests_tab_screen.dart`, `booking_wizard_screen.dart`, admin/doctor web, unrelated tabs.

---

## 7. Route / page plan

| Route | Screen | Notes |
|-------|--------|--------|
| `/technician/login` | Technician login (stub → real) | Parity with `DoctorLoginScreen` until auth API exists |
| `/technician/home` | AI technician dashboard | Cards: “নতুন অনুরোধ”, “চলমান কাজ”, optional stats placeholder |
| `/technician/requests` | New AI service requests | Backed by `GET .../requests` |
| `/technician/jobs` | Active jobs | Backed by `GET .../jobs` |
| `/technician/jobs/:jobId` | Job detail | `GET .../jobs/:id` |
| `/technician/jobs/:jobId/record` | AI service record form | POST/PATCH record |
| `/technician/jobs/:jobId/complete` | Complete service | PATCH complete; confirm dialog |

**Navigation:** Prefer `context.push` / `go` with **static** `routePath` constants on each `Screen` class (existing convention).

---

## 8. API integration plan (expected endpoints)

Assumed **JSON envelope** consistent with existing mobile APIs: `{ "ok": true, "data": { ... } }` and `{ "ok": false, "error": { "code", "message", ... } }`.

| Operation | Method & path (expected) | Notes |
|-----------|-------------------------|--------|
| List incoming / new requests | `GET /api/mobile/technician/requests` | Query params TBD (`limit`, `offset`, `status`) — mirror customer list if applicable |
| List active jobs | `GET /api/mobile/technician/jobs` | Filter “active” server-side or client-side once contract known |
| Job detail | `GET /api/mobile/technician/jobs/:id` | Returns job + linked `ServiceRequest` / animal summary if backend includes |
| Accept job | `PATCH /api/mobile/technician/jobs/:id` (or nested path) | Body e.g. `{ "action": "accept" }` — **exact path/body TBD** |
| Reject job | `PATCH` same or sibling | Body e.g. `{ "action": "reject", "reason": "..." }` |
| Upsert AI service record | `POST` or `PATCH` (TBD) | e.g. `.../jobs/:id/ai-record` or embedded in job PATCH — **contract TBD** |
| Complete job | `PATCH .../complete` or action on job | Terminal state; refresh lists after success |

**Repository responsibilities:**

- Parse list payloads (`jobs`, `requests`, `total`, pagination).
- Map HTTP errors to `TechnicianApiException` with Bengali messages and optional `code` for UI branching (`UNAUTHORIZED`, `INVALID_STATE`, etc.).

---

## 9. Fallback / mock handling (backend not ready)

1. **Interface:** `TechnicianJobRepository` abstract class or typedef for functions the UI needs (`listRequests`, `listJobs`, `getJob`, `acceptJob`, `rejectJob`, `saveAiRecord`, `completeJob`).
2. **Implementation switch:** Riverpod `Provider` selecting **live** vs **mock** via `bool.fromEnvironment('USE_MOCK_TECHNICIAN_API', defaultValue: false)` **or** debug-only flag in `AppConfig` (prefer dart-define to avoid accidental prod mock).
3. **Mock data:** 2–3 sample jobs in various statuses (`ASSIGNED`, `IN_PROGRESS`, …) using strings compatible with existing `ServiceRequestStatus` if the job wraps the same lifecycle.
4. **Network failure UX:** If live API returns 404 on base path, show Bengali **“সেবাটি এখনও চালু হয়নি”** + retry (optional) — without crashing.

---

## 10. Data model plan (Flutter DTOs)

Design **mobile DTOs** to tolerate extra JSON fields (`fromJson` defensive parsing like `ServiceRequest.fromJson`). Align names with **camelCase** mobile conventions.

| Concept | Fields / approach |
|---------|-------------------|
| **Animal type** | Prefer `animal.species` / `animal.animalType` string from nested animal on job; display Bengali label in UI layer or map enum if backend sends enum |
| **Breed** | `animal.breed` optional `String?` — mirrors `AnimalProfile.breed` |
| **Semen / breed type (placeholder)** | `String? semenTypeOrStrawId` or `Map<String, dynamic>?` until API stabilizes; UI label: “বীজ/ধরন (পরে সংযুক্ত হবে)” if null |
| **Service date/time** | `DateTime? servicePerformedAt` or separate `scheduledStart` / `completedAt` from parent request |
| **Technician note** | `String? technicianNote` / `procedureNotes` |
| **Follow-up reminder (placeholder)** | `DateTime? followUpAt` nullable; UI: “ফলো-আপ (শীঘ্রই)” when null |
| **Payment / billing (placeholder)** | `String? billingStatus` or bool `isPaid` optional; UI disclaimer that billing is not finalized |

**Job vs request:** If API separates “requests” (offers) from “jobs” (accepted work), use two list models; if unified, single model with `status` discriminator.

---

## 11. UI plan (Bengali-first)

| Screen | Primary Bengali labels / content |
|--------|----------------------------------|
| **Dashboard** | Title: “AI টেকনিশিয়ান”; sections: “নতুন অনুরোধ”, “চলমান কাজ”; short subtitle explaining AI service |
| **New requests** | AppBar: “নতুন অনুরোধ”; list row: animal name, area, time submitted, status chip |
| **Active jobs** | AppBar: “চলমান কাজ”; same card pattern as customer requests |
| **Job detail** | Sections: পশু, ঠিকানা, গ্রাহকের বার্তা, স্ট্যাটাস, নিয়োগের সময়; actions: “গ্রহণ করুন”, “প্রত্যাখ্যান”, “রেকর্ড সংশোধন”, “সেবা সম্পন্ন করুন” |
| **Accept / reject** | `AlertDialog` or bottom sheet: confirm; reject optional reason field (reuse cancel dialog pattern from `ServiceRequestDetailScreen`) |
| **AI service record form** | Fields: তারিখ/সময়, প্রজাতি/ধরন, জাত (breed), বীজ/স্ট্র অ placeholder, নোট, ফলো-আপ placeholder |
| **Complete service** | Summary + “নিশ্চিত করুন” / “ফিরে যান”; success `SnackBar`: “সেবা সম্পন্ন হয়েছে” |

---

## 12. Bengali-first label plan

- All **user-visible** strings on M10 screens in **Bengali** by default.
- Reuse existing domain labels from `service_request_model.dart` where the entity is the same `ServiceRequest` / status enum.
- **Errors:** User-facing Bengali; log `code` in debug only.
- **Consistency:** Use same tone as `ServiceRequestsTabScreen` / `TechnicianListScreen` (short, polite).

---

## 13. Loading / error / empty state plan

| State | Pattern |
|-------|---------|
| Loading | `CircularProgressIndicator` centered; keep `RefreshIndicator` on scrollable lists |
| Error | Icon `error_outline`, Bengali title, exception message in `bodySmall` if safe, **“আবার চেষ্টা”** button invalidating provider |
| Empty | Icon + “কোনো অনুরোধ নেই” / “কোনো চলমান কাজ নেই” + hint to pull refresh |
| Mutation in flight | Disable primary buttons or show `LinearProgressIndicator` on `AppBar.bottom` / overlay |

---

## 14. Test plan

| Test | Goal |
|------|------|
| **Repository parse** | Given sample JSON maps, `fromJson` produces expected models; `unwrap` throws on `ok: false` |
| **Repository errors** | 401/403/404 map to correct Bengali messages |
| **Widget smoke** | Dashboard renders with mock provider; one navigation push to detail |
| **Golden (optional)** | Only if team adopts goldens elsewhere; skip initially |

Run: `flutter test` from repo root; keep tests **hermetic** (no real network).

---

## 15. Acceptance checklist

- [ ] AI technician can open **dashboard** from app without breaking customer login flow.
- [ ] **Requests** and **jobs** lists show loading, empty, and error states with Bengali copy and retry.
- [ ] **Job detail** shows animal, location, status, and key timestamps when API/mock provides them.
- [ ] **Accept** and **reject** flows confirm intent and refresh list/detail state.
- [ ] **AI service record** form captures date/time, animal context, breed, semen placeholder, technician note; validates required fields before submit.
- [ ] **Complete job** confirms and updates UI after success.
- [ ] **Mock mode** works with `--dart-define` (or equivalent) when backend is unavailable.
- [ ] No regressions to **customer** home, service requests tab, booking wizard, or technician **finder** screens.
- [ ] No backend / web repo changes as part of M10 mobile delivery.

---

## 16. Open questions / missing backend & API details

1. **Auth:** Whether `/api/mobile/technician/*` uses the **same** `Authorization: Bearer` as customer with role `AI_TECHNICIAN`, a **separate** mobile login (OTP/email), or a different scheme — **not defined** in this mobile repo; **dio** currently attaches a single stored token.
2. **Exact REST paths** for accept/reject/record/complete (nested vs `PATCH` with `action` body) — task lists concepts, not final URLs.
3. **Response shapes** for `requests` vs `jobs` lists (`data.requests` vs `data.jobs`, pagination keys) — must match server when shipped.
4. **Id mapping:** Whether “job id” equals `ServiceRequest.id` or a separate `TechnicianJob` id — affects routing and deep links.
5. **Web vs mobile parity:** Separate web cookie APIs for technicians (`/api/technician/...` on the server product) are **not** the same as the **expected** mobile paths in this task; mobile plan assumes **`/api/mobile/technician/...`** will exist or be mocked.

---

## 17. Audit summary (for stakeholders)

| Question | Answer |
|----------|--------|
| What was audited? | Full `lib/src` structure: routing, session, Dio, service requests, provider finder, doctor shell, theme, padding, animals model, pubspec. |
| What exists for AI technicians today? | Customer **AI_SERVICE** booking type, `ServiceRequest` technician assignment fields, **technician finder** screens/APIs — **not** a technician work queue or job workflow. |
| What plan file was created/updated? | **`docs/tasks/M10_AI_TECHNICIAN_SERVICE_PLAN.md`** (this file). |
| Main risks / gaps? | **Technician auth** and **exact mobile API contracts** are undefined in-repo; use **mock repository** and **`/technician` routing** mirroring doctor shell until backend is ready. |

---

## 18. Implementation delivery (M10 — shipped in mobile repo)

### 18.1 Summary

- **Feature root:** `lib/src/features/technician_ai/` (data, application, presentation, widgets) plus **stub login** at `lib/src/features/auth/technician/presentation/technician_login_screen.dart`.
- **Routing:** `/technician/*` routes registered in `router.dart`; redirect allows `/technician` without customer JWT (same pattern as `/doctor`).
- **Session:** `AppRole.technician` added; `hydrateFromStorage` restores `technician` when `pd_last_role` is `'technician'` (string literals, no `.name` in const context).
- **API:** `TechnicianJobRepositoryLive` calls the expected `/api/mobile/technician/*` paths. **`TechnicianJobRepositoryMock`** singleton provides Bengali-friendly demo jobs when `USE_MOCK_TECHNICIAN_API=true` (`AppConfig`, compile-time `dart-define`, **default `false`**).
- **Entry:** Login screen adds **পেশাদার প্রবেশ** links: চিকিৎসক (`/doctor/login`) and **AI টেকনিশিয়ান** (`/technician/login`).

### 18.2 Implemented files (created)

| Path |
|------|
| `lib/src/features/technician_ai/data/technician_api_exception.dart` |
| `lib/src/features/technician_ai/data/technician_job_models.dart` |
| `lib/src/features/technician_ai/data/technician_job_repository.dart` |
| `lib/src/features/technician_ai/data/technician_job_repository_mock.dart` |
| `lib/src/features/technician_ai/application/technician_job_providers.dart` |
| `lib/src/features/technician_ai/presentation/widgets/technician_ai_widgets.dart` |
| `lib/src/features/technician_ai/presentation/technician_dashboard_screen.dart` |
| `lib/src/features/technician_ai/presentation/technician_requests_screen.dart` |
| `lib/src/features/technician_ai/presentation/technician_jobs_screen.dart` |
| `lib/src/features/technician_ai/presentation/technician_job_detail_screen.dart` |
| `lib/src/features/technician_ai/presentation/technician_ai_record_form_screen.dart` |
| `lib/src/features/technician_ai/presentation/technician_complete_job_screen.dart` |
| `lib/src/features/auth/technician/presentation/technician_login_screen.dart` |
| `test/technician_ai_badge_test.dart` |

### 18.3 Modified files

| Path | Change |
|------|--------|
| `lib/src/app/router.dart` | Technician routes + `/technician` redirect bypass; imports |
| `lib/src/core/config/app_config.dart` | `useMockTechnicianApi` (`USE_MOCK_TECHNICIAN_API`) |
| `lib/src/features/session/application/session_notifier.dart` | `AppRole.technician`; hydrate role branch |
| `lib/src/features/auth/login_entry_screen.dart` | Professional entry links (doctor + AI technician) |

### 18.4 Routes added

| Route | Screen |
|-------|--------|
| `/technician/login` | `TechnicianLoginScreen` |
| `/technician/home` | `TechnicianDashboardScreen` |
| `/technician/requests` | `TechnicianRequestsScreen` |
| `/technician/jobs` | `TechnicianJobsScreen` |
| `/technician/jobs/:jobId` | `TechnicianJobDetailScreen` |
| `/technician/jobs/:jobId/record` | `TechnicianAiRecordFormScreen` |
| `/technician/jobs/:jobId/complete` | `TechnicianCompleteJobScreen` |

### 18.5 Repository / API methods (live)

| Method | HTTP |
|--------|------|
| `listRequests` | `GET /api/mobile/technician/requests` |
| `listJobs` | `GET /api/mobile/technician/jobs` |
| `getJob` | `GET /api/mobile/technician/jobs/:id` |
| `acceptJob` | `PATCH /api/mobile/technician/jobs/:id` body `{ action: accept }` |
| `rejectJob` | `PATCH ...` body `{ action: reject, reason? }` |
| `saveAiRecord` | `PATCH /api/mobile/technician/jobs/:id/ai-record` body `TechnicianAiRecordInput.toJson()` |
| `completeJob` | `PATCH /api/mobile/technician/jobs/:id/complete` body `{}` |

**Response parsing:** expects envelope `{ ok, data }`; lists under `data.requests` or `data.items`; jobs under `data.jobs` or `data.items`; detail under `data.job` or `data.request`; PATCH responses may return `data.job` or the job map as `data`.

### 18.6 Mock / fallback behaviour

- **Toggle:** `flutter run --dart-define=USE_MOCK_TECHNICIAN_API=true`
- **Implementation:** `TechnicianJobRepositoryMock` — singleton, in-memory mutations (accept / reject / save record / complete).
- **Removal:** Delete mock class + provider branch when live API is stable; keep `AppConfig` flag until QA no longer needs mock.

### 18.7 Known limitations

- **No real technician auth:** Stub login mirrors doctor shell (`setRole` + `go` dashboard); JWT / OTP not implemented.
- **Live API contract:** Paths and JSON keys are **best-effort**; server may differ — adjust `TechnicianJobRepositoryLive` and `fromJson` when backend ships.
- **401 on live technician API:** Global `Dio` interceptor still clears **customer** token and sends user to customer login — acceptable until dedicated technician token storage exists.

### 18.8 Manual QA checklist

- [ ] From **লগইন**, tap **AI টেকনিশিয়ান** → stub login → **ড্যাশবোর্ড**.
- [ ] With **`USE_MOCK_TECHNICIAN_API=true`**: **নতুন অনুরোধ** shows `job-mock-1`; open detail → **গ্রহণ** / **প্রত্যাখ্যান** (reject returns to list after snack).
- [ ] **চলমান কাজ** lists active jobs; open `job-mock-2` → **AI সেবার রেকর্ড** → fill required fields → save → detail shows record / phase.
- [ ] Open `job-mock-3` (has record) → **সেবা সম্পন্ন করুন** → confirm → returns to detail with completed state.
- [ ] Pull-to-refresh on requests and jobs lists.
- [ ] With **`USE_MOCK_TECHNICIAN_API=false`** and server **without** routes: lists show error + **আবার চেষ্টা** (no crash).
- [ ] Customer OTP login, home shell, service requests tab, booking, technician **finder** unchanged.

### 18.9 Acceptance checklist (from §15 — re-check after QA)

- [x] Dashboard + lists + detail + record + complete screens present (Bengali UI, loading/error/empty).
- [x] Accept / reject + record + complete wired to repository (mock + live).
- [x] Mock mode via dart-define; isolated mock class.
- [x] Router + session role extended without removing doctor/customer flows.

---

## 19. Test + fix verification (M10)

### 19.1 Final command results (repo: `pranidoctor_mobile`)

| Command | Result |
|---------|--------|
| **`dart format .`** | **Exit 0.** Initial run: **70 files processed, 18 reformatted.** Final verification: **71 files processed, 0 changed** (includes new `test/technician_ai_badge_test.dart`). *Note: formatting is repo-wide; a few non–M10 files were line-wrapped in the first pass only.* |
| **`flutter analyze`** | **Exit 0.** **No issues found.** |
| **`flutter test`** | **Exit 0.** **All tests passed** (`2` tests: existing app smoke + M10 badge smoke). |

### 19.2 Known warnings

- **None** from `flutter analyze` at verification time.

### 19.3 Automated test added (M10, minimal)

| File | Purpose |
|------|---------|
| `test/technician_ai_badge_test.dart` | Widget smoke: `TechnicianAiBadge` renders Bengali copy (`টেকনিশিয়ান`). Matches existing **single-file `widget_test`** style (no new harness). |

**Not added (by design):** Full navigation/integration tests for technician flows — would need broader `ProviderScope` overrides and router tests; deferred to avoid fragile infra (see §13).

### 19.4 Manual QA checklist (repeat before release)

Same as **§18.8** — confirm on device/emulator:

- [ ] From **লগইন**, tap **AI টেকনিশিয়ান** → stub login → **ড্যাশবোর্ড**.
- [ ] With **`USE_MOCK_TECHNICIAN_API=true`**: **নতুন অনুরোধ** / **চলমান কাজ**, detail, accept/reject, AI record form, complete flow.
- [ ] Pull-to-refresh on lists; error + retry when live API missing (`USE_MOCK_TECHNICIAN_API=false`).
- [ ] Customer flows unchanged (OTP home, service requests, booking, technician finder).

### 19.5 Fixes applied in this step

- **No code fixes required** for analyze/test — tree was already clean after M10 implementation.
- **`dart format .`** normalized formatting (including M10 and a few adjacent touched files).
- **One small test** added for M10 UI visibility (`TechnicianAiBadge`).
