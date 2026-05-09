# M09 — Doctor Case Workflow Pages (Plan)

**Project:** Prani Doctor / Animal Doctors — Flutter mobile app only  
**Domain:** https://pranidoctor.com/  
**Repo:** `balagpetcare/pranidoctor-mobile`  
**Local path:** `D:\PraniDoctor\pranidoctor_mobile`  

**Status:** Planning / audit only (this document). **No implementation** in the command that produced this file. **No backend or admin changes** in M09 scope.

**Isolation:** Do not use or mix BPA/WPA, Quarbani 2026, or any other project data.

**Related:** `docs/tasks/M08_REQUEST_TRACKING_PLAN.md` (customer service requests), `docs/MOBILE_API_INTEGRATION_MAP.md`, `docs/MOBILE_PAGE_TASK_INDEX.md` (task M09 card), `docs/MOBILE_TASK_WORKFLOW_RULES.md`.

---

## 1. Current audit findings (exact file paths)

### 1.1 Auth, login, and role handling

| Finding | Evidence |
|---------|----------|
| **Riverpod `SessionNotifier`** holds `AppRole?` (`customer` \| `doctor`) and `isAuthenticated`. | `lib/src/features/session/application/session_notifier.dart` |
| **Customer OTP** stores JWT via `signInCustomer`, sets `pd_last_role` = customer, `isAuthenticated: true`. | Same file; OTP flow in `lib/src/features/auth/login_entry_screen.dart`, `otp_verify_screen.dart`, `lib/src/features/auth/data/mobile_otp_auth_repository.dart` |
| **Doctor stub “login”** calls `setRole(AppRole.doctor)` then `context.go(DoctorHomeScreen.routePath)`. **`setRole` sets `isAuthenticated: false`** while persisting role to SharedPreferences. | `lib/src/features/auth/doctor/presentation/doctor_login_screen.dart`, `session_notifier.dart` lines 54–58 |
| **GoRouter redirect:** paths under **`/doctor`** skip the “must be authenticated” redirect; customer paths require `auth.isAuthenticated`. | `lib/src/app/router.dart` lines 93–96 |
| **Logged-in customer** hitting `/login` is redirected to **`/home`** (customer shell), not doctor routes. | `router.dart` lines 80–84 |
| **Splash** hydrates token from storage, then if `auth` → **`HomeShellScreen`** only (no doctor branch). | `lib/src/features/splash/splash_screen.dart` lines 35–47 |
| **`hydrateFromStorage`:** if access token exists, restores `AppRole` from `pd_last_role` (defaults to customer if not doctor). | `session_notifier.dart` lines 28–38 |
| **401 on Dio:** clears session and `go(LoginEntryScreen.routePath)` — **customer** login route. | `lib/src/core/network/dio_provider.dart` lines 34–40 |
| **Doctor home “সাইন আউট”** calls full **`signOut()`** (clears secure token storage). | `lib/src/features/home/doctor/presentation/doctor_home_screen.dart` lines 24–31 |
| **Customer login** has no visible link to **`/doctor/login`**; doctor entry is effectively hidden unless navigated programmatically or deep-linked. | `login_entry_screen.dart` (full file review) |
| **`signInGuest`** sets customer role, authenticated, **no** persisted JWT. | `session_notifier.dart` lines 48–52 |

### 1.2 Routing and navigation

| Finding | Path / file |
|---------|-------------|
| **go_router** `Provider` with `refreshListenable` tied to `sessionNotifierProvider`. | `lib/src/app/router.dart` |
| **Customer shell:** `HomeShellScreen` — `IndexedStack` + bottom `NavigationBar` (হোম, আমার পশু, অনুরোধ, সহায়তা, প্রোফাইল). | `lib/src/features/home/home_shell_screen.dart` |
| **Doctor routes registered:** `/doctor/login`, `/doctor/home`. | `router.dart` |
| **Customer service request detail:** `/service-requests/:requestId` → `ServiceRequestDetailScreen`. | `router.dart` lines 229–240 |
| **Naming:** screens expose `routePath`, `routeName` statics (e.g. `DoctorHomeScreen.routePath`). | Doctor + service request screens |

### 1.3 Customer-side request / case / booking (prior tasks)

| Area | Files |
|------|--------|
| **List + detail + timeline + cancel** | `lib/src/features/service_requests/presentation/service_requests_list_screen.dart`, `service_request_detail_screen.dart`, `domain/service_request_timeline.dart`, `widgets/service_request_timeline_view.dart` |
| **Tab wrapper** | `lib/src/features/service_requests/presentation/service_requests_tab_screen.dart` |
| **Models / enums** | `lib/src/features/service_requests/data/service_request_model.dart` (`ServiceRequest`, `ServiceRequestStatus`, `ServiceRequestType`, animal ref, urgency display) |
| **Repository** | `lib/src/features/service_requests/data/service_request_repository.dart` — `create`, `list`, `getById`, `cancel`; `{ ok, data }` unwrap |
| **Riverpod** | `lib/src/features/service_requests/application/service_requests_providers.dart` — repository provider, `AsyncNotifier` list, `FutureProvider.family` detail |
| **Booking** | `booking_wizard_screen.dart`, `booking_success_screen.dart`, `domain/booking_submit_helpers.dart`, `domain/booking_urgency.dart` |
| **Home shortcuts** | `lib/src/features/home/presentation/customer_home_screen.dart`, `widgets/customer_recent_request_card.dart` |

**Note:** Customer APIs use **`/api/mobile/service-requests`**. Doctor task spec uses **`/api/mobile/doctor/...`** — separate surface; models may overlap by ID or shape but should not be assumed identical until backend contract is confirmed.

### 1.4 API client / service / repository patterns

| Layer | File |
|-------|------|
| **Dio + interceptors** | `lib/src/core/network/dio_provider.dart` |
| **Thin HTTP wrapper** | `lib/src/core/network/api_client.dart` (`get` / `post` / `patch`) |
| **Base URL** | `lib/src/core/config/app_config.dart` (`API_BASE_URL` dart-define) |
| **Repository pattern** | Private `_unwrap(Response)` → require `ok: true`, `data` map; typed `*ApiException`; `_mapDio` for errors with Bangla messages — see `service_request_repository.dart`, `animal_profile_repository.dart` |

**Integration map:** `docs/MOBILE_API_INTEGRATION_MAP.md` — doctor APIs explicitly **planned / not wired**; M09 should add rows when implemented.

### 1.5 Loading / error / empty state components

| Widget | File |
|--------|------|
| **`PdLoadingBody`**, **`PdErrorBody`**, **`PdEmptyState`** | `lib/src/core/widgets/pd_async_states.dart` |
| **Usage example** | `service_requests_list_screen.dart` (`RefreshIndicator` + `async.when`), `service_request_detail_screen.dart` |

### 1.6 Cards, forms, badges, design system

| Asset | File |
|-------|------|
| **Design system barrel** | `lib/src/core/design_system.dart` |
| **Cards** | `lib/src/core/widgets/pd_app_card.dart` — list pattern in `service_requests_list_screen.dart` (`_RequestCard`) |
| **Status chip** | `lib/src/features/service_requests/presentation/widgets/service_request_status_badge.dart` |
| **Text fields** | `lib/src/core/widgets/pd_text_field.dart` (login, booking wizard) |
| **Buttons** | `lib/src/core/widgets/pd_buttons.dart` (e.g. booking success) |
| **Page header** | `lib/src/core/widgets/pd_page_header.dart` |
| **Spacing / theme** | `lib/src/core/constants/pd_spacing.dart`, `lib/src/app/theme.dart`, `lib/src/app/screen_padding.dart` |
| **Provider summary card (reuse idea)** | `lib/src/features/service_requests/presentation/widgets/assigned_provider_card.dart` — pattern for summary rows |

### 1.7 Localization / Bengali-first UI

| Finding | File |
|---------|------|
| **Default locale `bn_BD`** | `lib/src/app/app.dart` |
| **Strings:** inline Bangla in widgets (no ARB / `flutter_gen` l10n in repo). | Across `presentation/` screens |
| **Domain labels on enums** | e.g. `ServiceRequestStatus.labelBn`, `ServiceRequestType.labelBn` in `service_request_model.dart` |

### 1.8 Test setup

| Item | Detail |
|------|--------|
| **Framework** | `flutter_test` in `pubspec.yaml` |
| **Tests present** | `test/widget_test.dart`, `test/otp_auth_test.dart`, `test/animal_form_validators_test.dart`, `test/booking_submit_helpers_test.dart`, `test/provider_list_query_test.dart`, `test/service_request_timeline_test.dart` |
| **Typical style** | Unit tests for parsers/helpers; minimal widget tests |

---

## 2. Existing patterns to reuse

1. **Feature layout:** `data/` (model + repository + `*ApiException`), `application/` (`*Repository` `Provider` + `AsyncNotifier` / `FutureProvider.family`), `presentation/` (screens + `widgets/`).
2. **HTTP:** `ApiClient` from `apiClientProvider`; same `{ ok, data, error }` unwrap as existing repositories.
3. **Lists:** `RefreshIndicator`, `ListView` with `pdScreenPadding`, `PdAppCard` rows, `async.when` loading/error/data.
4. **Detail:** `Scaffold` + `AppBar`, sections as titled blocks (see `ServiceRequestDetailScreen`), optional timeline if product maps statuses similarly.
5. **Forms:** `PdTextField`, validation messages in Bangla, `FilledButton` / `PdPrimaryButton` where appropriate.
6. **Badges:** mirror `ServiceRequestStatusBadge` styling for **priority / emergency** (new small widget or extend pattern with semantic colors from `pd_semantic_colors.dart` / `ColorScheme`).
7. **Navigation:** `go_router` `push` / `go`; static `routePathFor(id)` helpers on screens.

---

## 3. Proposed route / page structure

Keep all doctor workflow under **`/doctor/**`** to align with existing redirect exception and role clarity.

| Screen | Suggested path | Notes |
|--------|----------------|--------|
| Doctor dashboard (hub) | `/doctor/home` | **Replace** stub content in `DoctorHomeScreen` with stats + entry tiles (নতুন অনুরোধ, চলমান কেস, …). |
| New requests (pending assignment) | `/doctor/requests` | List from `GET …/doctor/requests`. |
| Accepted / active cases | `/doctor/cases` | List from `GET …/doctor/cases` (query or client filter for active vs all if API supports). |
| Case detail | `/doctor/cases/:caseId` | `GET …/doctor/cases/:id`. **Use `:caseId`** to avoid collision with customer `/service-requests/:requestId` naming confusion. |
| Accept / reject | **Actions on detail** (dialogs / bottom sheet) **or** dedicated confirm routes | Prefer **modal/dialog** on detail for fewer routes; optional `/doctor/cases/:id/accept` only if deep-link required. |
| Treatment note form | `/doctor/cases/:caseId/treatment` | POST/PATCH treatment — single-purpose form screen. |
| Prescription form | `/doctor/cases/:caseId/prescription` | POST/PATCH prescription. |
| Complete case | `/doctor/cases/:caseId/complete` | Confirmation + notes if API requires; then PATCH/POST complete. |

**Nested routes (optional):** `ShellRoute` for doctor with a simple `NavigationBar` is **not** present today; **MVP:** flat `GoRoute` list under `/doctor/...` with `AppBar` back navigation — matches current `DoctorHomeScreen` style and minimizes router churn.

---

## 4. Proposed data models / entities (mobile DTOs)

Define in **`lib/src/features/doctor_workflow/data/`** (folder name TBD — see §12) with **`fromJson` tolerant parsing** (same discipline as `ServiceRequest.fromJson`).

| Model | Purpose |
|-------|---------|
| **`DoctorIncomingRequest`** (name TBD) | Row for **নতুন অনুরোধ** list: id, linked serviceRequestId if applicable, status, submittedAt, priority/emergency flags, customer summary, animal summary, service type, location snippet. |
| **`DoctorCase`** | Row for **চলমান কেস**: id, status, animal/customer summary, assignedAt, scheduled window, flags. |
| **`DoctorCaseDetail`** | Extends or composes list DTO + sections for notes, prescription draft/history, timeline if API returns events. |
| **`TreatmentNoteDraft`** | Local form state + API payload fields (e.g. note text, visibility, datetime — **align to backend**). |
| **`PrescriptionDraft`** | Lines/items or free text — **product/backend driven**. |

**Relationship to customer `ServiceRequest`:** If API nests the same payload as `ServiceRequest`, consider a **shared partial parser** or embed `ServiceRequest.fromJson` behind a try/catch — only if contract is stable; otherwise **keep doctor DTOs separate** to avoid breaking customer screens when doctor fields evolve.

---

## 5. Proposed API service / repository methods

**Repository class:** e.g. `DoctorWorkflowRepository` in `doctor_workflow_repository.dart` using `ApiClient`.

**Expected paths (product spec — confirm verb + body with backend before coding):**

| UI action | Proposed client method | HTTP (expected) |
|-----------|------------------------|-------------------|
| Load new requests | `listIncomingRequests()` | `GET /api/mobile/doctor/requests` |
| Load cases | `listCases({...})` | `GET /api/mobile/doctor/cases` |
| Case detail | `getCaseById(String id)` | `GET /api/mobile/doctor/cases/:id` |
| Accept | `acceptRequest(String id, {Map? body})` | `POST` or `PATCH` — path e.g. `…/requests/:id/accept` or `…/cases/:id/accept` (**TBD with API**) |
| Reject | `rejectRequest(String id, {String? reason})` | `POST` or `PATCH` — **TBD** |
| Save treatment | `saveTreatmentNote(String caseId, Map body)` | `POST` or `PATCH` — **TBD** |
| Save prescription | `savePrescription(String caseId, Map body)` | `POST` or `PATCH` — **TBD** |
| Complete case | `completeCase(String caseId, {Map? body})` | `POST` or `PATCH` — **TBD** |

**Envelope:** mirror existing `ok` / `data` / `error.message` handling; Bengali fallbacks in `*ApiException`.

**When backend paths differ:** centralize path strings in **private constants** at top of repository file for one-place update.

---

## 6. Proposed state management approach

- **Riverpod 3** only: `Provider<DoctorWorkflowRepository>`, `AsyncNotifierProvider` for lists (`newRequests`, `activeCases`) with explicit **`refresh()`** after mutations, `FutureProvider.autoDispose.family` for **case detail** by id.
- **Mutation calls:** `ref.read(repository).accept(...)` then **`invalidate`** detail + both lists (or optimistic update if product requires — start pessimistic for lower risk).
- **Form screens:** `ConsumerStatefulWidget` with local `TextEditingController`s **or** small `Notifier` for multi-step if needed — prefer **local state** first.

---

## 7. UI component reuse plan

| Need | Reuse |
|------|--------|
| List cards | `PdAppCard` + row layout like `_RequestCard` in `service_requests_list_screen.dart` |
| Status / priority | New **`DoctorPriorityBadge`** / **`EmergencyBadge`** (small `Container` + `labelMedium` like `ServiceRequestStatusBadge`) |
| Doctor mode indicator | **`Chip` / `Badge` in `AppBar`** or next to title: text e.g. **«চিকিৎসক মোড»** on doctor screens |
| Customer + animal summary | Two-line pattern: icon + name/species (copy from list card animal line) |
| Forms | `PdTextField`, section titles with `TextTheme.titleSmall`, `pdScreenPadding` |
| Detail sections | Private `_DetailSection` pattern from `service_request_detail_screen.dart` |
| Timeline (optional) | Only if API provides ordered events; else static status + timestamps |

---

## 8. Empty / loading / error state plan

- **Lists:** Same three-way pattern as `ServiceRequestsListBody`: `PdLoadingBody` inside scrollable for pull-to-refresh; `PdErrorBody` with **«আবার চেষ্টা করুন»**; `PdEmptyState` with Bangla title/subtitle (e.g. no pending requests / no active cases).
- **Detail:** `async.when` with `PdLoadingBody` / `PdErrorBody` + invalidate retry.
- **Mutations:** `SnackBar` or inline banner on success/failure (Bangla); disable buttons while `submitting` flag.

---

## 9. Test plan

| Target | Type |
|--------|------|
| **JSON → DTO parsing** | Unit tests: sample JSON fixtures for `DoctorCaseDetail`, list items, edge missing fields |
| **Repository unwrap** | Optional: mock `ApiClient` / `Dio` adapter — only if team adds HTTP mocking pattern; otherwise keep parser tests |
| **Navigation** | Smoke: `widget_test` or small test pushing doctor route — low priority |
| **Regression** | `flutter analyze` + `flutter test` full suite |

---

## 10. Exact implementation checklist

1. Confirm **backend contract** (exact paths, verbs, bodies, id semantics: `caseId` vs `serviceRequestId`).
2. Add **`DoctorWorkflowRepository`** + DTOs + `*ApiException` + unwrap helpers.
3. Add **`doctor_workflow_providers.dart`** (repository + list notifiers + detail `FutureProvider.family`).
4. Expand **`router.dart`** with new `/doctor/...` routes; ensure **route order** (static paths before `:caseId` if any ambiguity).
5. Replace **`DoctorHomeScreen`** stub with dashboard (badges, tiles, optional summary counts).
6. Implement **`DoctorRequestsScreen`** (new requests list).
7. Implement **`DoctorCasesScreen`** (active cases list).
8. Implement **`DoctorCaseDetailScreen`** (summary + actions).
9. Wire **accept / reject** UI with confirmation dialogs (Bangla).
10. Implement **`DoctorTreatmentNoteScreen`** form + submit.
11. Implement **`DoctorPrescriptionScreen`** form + submit.
12. Implement **`DoctorCompleteCaseScreen`** confirm + submit.
13. Add **doctor mode badge** to doctor `AppBar`s (and optionally dashboard header).
14. Update **`SessionNotifier`** / **splash** / **401 handler** per §12 if adopting real doctor JWT (do not ship half-integrated auth).
15. Add **Profile** or **Login** entry point to **`/doctor/login`** (product decision — e.g. subtle link on customer login or profile placeholder).
16. Update **`docs/MOBILE_API_INTEGRATION_MAP.md`** with all new paths + repository methods.
17. Add **`test/doctor_workflow_model_test.dart`** (or similar) for parsers.
18. Run **`flutter analyze`** + **`flutter test`**.

---

## 11. Files expected to be created / modified

### Created (suggested)

- `lib/src/features/doctor_workflow/data/doctor_workflow_repository.dart`
- `lib/src/features/doctor_workflow/data/doctor_case_models.dart` (split if large)
- `lib/src/features/doctor_workflow/application/doctor_workflow_providers.dart`
- `lib/src/features/doctor_workflow/presentation/doctor_requests_screen.dart`
- `lib/src/features/doctor_workflow/presentation/doctor_cases_screen.dart`
- `lib/src/features/doctor_workflow/presentation/doctor_case_detail_screen.dart`
- `lib/src/features/doctor_workflow/presentation/doctor_treatment_note_screen.dart`
- `lib/src/features/doctor_workflow/presentation/doctor_prescription_screen.dart`
- `lib/src/features/doctor_workflow/presentation/doctor_complete_case_screen.dart`
- `lib/src/features/doctor_workflow/presentation/widgets/` — e.g. `doctor_case_card.dart`, `doctor_priority_badge.dart`, `doctor_mode_app_bar_title.dart`
- `test/doctor_workflow_model_test.dart` (or equivalent)

### Modified (expected)

- `lib/src/app/router.dart` — register new routes; imports
- `lib/src/features/home/doctor/presentation/doctor_home_screen.dart` — dashboard + navigation to lists
- `lib/src/features/auth/doctor/presentation/doctor_login_screen.dart` — real auth when API exists; until then keep stub **or** gate behind debug (product call)
- `lib/src/features/session/application/session_notifier.dart` — **if** doctor JWT / `signInDoctor` / session flags needed (see §12)
- `lib/src/features/splash/splash_screen.dart` — **if** cold-start routing for doctor role
- `lib/src/core/network/dio_provider.dart` — **if** 401 redirect should target doctor login
- `docs/MOBILE_API_INTEGRATION_MAP.md` — new rows for doctor endpoints
- Optional: `lib/src/features/auth/login_entry_screen.dart` or `customer_shell_tab_placeholders.dart` — discoverability link to doctor login

**Prefer not touching** customer `service_requests` files unless extracting a **shared** private widget into `core/widgets/` with zero behavior change — avoid scope creep.

---

## 12. Risks / conflicts and safe fallback approach

| Risk | Description | Safest approach |
|------|-------------|-----------------|
| **R1 — `isAuthenticated` vs doctor stub** | `setRole(doctor)` sets **`isAuthenticated: false`**. Doctor screens rely on **`/doctor` bypass**, not on a coherent “logged-in doctor” flag. | For **real** doctor JWT: add **`signInDoctor(accessToken)`** (or unified `signInMobile` with role from JWT decode if backend supports) that sets **`isAuthenticated: true`**, persists **`pd_last_role` = doctor**, writes token. **Update redirect** so authenticated **doctors** do not get forced from `/doctor/login` to `/home` without intent. |
| **R2 — Splash always sends authed users to customer `/home`** | After OTP, customer flow is correct; **doctor cold start** would incorrectly open **customer shell** if only token + role doctor exist. | In **`SplashScreen`**, after `hydrateFromStorage`, if `auth.isAuthenticated && role == AppRole.doctor` → **`context.go(DoctorHomeScreen.routePath)`** (or `/doctor/requests` if product prefers). |
| **R3 — 401 handler assumes customer login** | `dio_provider` navigates to **`LoginEntryScreen`**. | If `SessionState.role == doctor`, **`go(DoctorLoginScreen.routePath)`** instead; still **`signOut()`** to clear invalid token. |
| **R4 — Shared `TokenStorage` for customer vs doctor** | Single `pd_access_token` slot — **customer OTP token must not** call doctor endpoints if backend rejects. | **Document:** backend either issues **role-scoped JWT** for same store, or app needs **`pd_doctor_access_token`** (second key) + interceptor branch. Prefer **one token** with explicit claims if backend can unify. |
| **R5 — `DoctorHomeScreen` `signOut`** | Clears all tokens — correct for “full logout”, but **role switch** UX should be explicit (Bangla copy). | Keep one **`signOut`**; show dialog if needed before leaving doctor mode. |
| **R6 — API not ready** | M09 UI could ship with empty errors. | **Feature flag** or **`USE_DOCTOR_FIXTURES`** dart-define mirroring provider finder pattern (`provider_finder_fallback_data.dart`) — **optional**; only if product wants demo without backend. |
| **R7 — Folder naming** | `home/doctor` already hosts `DoctorHomeScreen`; new feature could live under `features/doctor_workflow/` to avoid mixing “home shell” with workflow. | **New feature folder** `doctor_workflow` (or `doctor_cases`) — **low coupling** to customer `home/`. |

---

## 13. Summary for the next implementation command

- **Implement** repository + DTOs + Riverpod + screens + router updates per §10–§11, following patterns in **`ServiceRequestRepository`**, **`service_requests_list_screen.dart`**, **`service_request_detail_screen.dart`**, and **`pd_async_states.dart`**.
- **Resolve R1–R4** as part of the same milestone if doctor APIs require Bearer auth (session + splash + 401 must be consistent).
- **Update** `docs/MOBILE_API_INTEGRATION_MAP.md` when endpoints are wired.
- **Add** parser/unit tests per §9.
- **Do not** modify pranidoctor-web backend or admin in this task.

---

## 14. Implementation note (2026-05-09, mobile only)

- **`lib/src/features/doctor_workflow/`** added: models, `DoctorWorkflowRepository`, Riverpod providers, screens (`DoctorRequestsScreen`, `DoctorCasesScreen`, `DoctorCaseDetailScreen`, treatment / prescription / complete forms), shared badges + queue card.
- **Session:** `signInDoctor(accessToken)` and **`signInDoctorDemo()`** (clears stored JWT, sets `AppRole.doctor` + `isAuthenticated: true`) replace the old stub `setRole(doctor)` path for the “খোলস” button on `DoctorLoginScreen`.
- **Splash:** After `hydrateFromStorage`, users with a stored JWT and **`pd_last_role` = doctor** go to **`DoctorHomeScreen`** instead of the customer shell.
- **Router:** Authenticated doctors hitting **`/login`** redirect to **`/doctor/home`**; authenticated users on **`/doctor/login`** redirect to **`/doctor/home`**.
- **401 (`dio_provider`):** Role is read **before** `signOut()`; navigation goes to **`DoctorLoginScreen`** when the role was doctor.
- **API verbs/paths:** Client uses **`PATCH`** on `…/requests/:id/accept`, `…/reject`, and `…/cases/:id/treatment`, `…/prescription`, `…/complete`. Backend was not modified; if the server differs, update path constants in **`doctor_workflow_repository.dart`** only.
- **Routing security:** `/doctor/**` remains reachable without customer auth (same bypass as pre-M09). Enforcing doctor-only access when the product requires it is a follow-up (e.g. redirect unauthenticated users away from `/doctor/requests`).

---

## 15. Implementation notes / assumptions (API & client)

- **HTTP verbs:** Mutations use **`PATCH`** on sub-resources (`…/requests/:id/accept`, `…/reject`, `…/cases/:id/treatment`, `…/prescription`, `…/complete`). If the backend uses **`POST`** or different segments, change only the path strings in **`doctor_workflow_repository.dart`**.
- **List JSON:** `GET` list responses unwrap `data` and accept arrays under **`requests`**, **`cases`**, or **`items`** (and `data` as a list key where used).
- **Detail JSON:** `GET …/cases/:id` unwraps a map from **`case`**, **`detail`**, **`doctorCase`**, or the whole `data` object.
- **Incoming → detail navigation:** Opens **`/doctor/cases/:id`** using **`caseId`** from the row when present; otherwise **`requestId`**. This assumes the case-detail endpoint accepts that identifier, or the UI will show load error until the backend aligns IDs.
- **Auth token:** **`signInDoctor`** and **`signInCustomer`** share **`TokenStorage`** (`pd_access_token`). **`signInDoctorDemo`** clears the token before doctor UI so a customer JWT is not sent to doctor endpoints during stub sessions.
- **401 handling:** Role is captured **before** `signOut()` so navigation can send doctors to **`/doctor/login`** instead of customer **`/login`**.

*Plan updated after M09 mobile implementation (2026-05-09).*