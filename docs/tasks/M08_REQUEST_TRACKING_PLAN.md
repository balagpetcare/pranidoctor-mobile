# Task M08 — Request Tracking & Request Detail

**Product:** Prani Doctor (Animal Doctors) — Bangladesh-first veterinary mobile app.  
**Repo:** `pranidoctor_mobile` (local: `D:\PraniDoctor\pranidoctor_mobile`)  
**Status:** **Implemented** (2026-05-09). Previous sections below retain the planning audit as reference.

**Depends on / relates to:** M01 (design system), M02 (shell), M04 (customer home), M07 (booking wizard + success).  
**Related docs:** `docs/MOBILE_API_INTEGRATION_MAP.md`, `docs/MOBILE_PAGE_TASK_INDEX.md` (task M08).

**Isolation:** Scope is **only** this Flutter repo and Prani Doctor mobile UX — no BPA/WPA, Quarbani 2026, or other project data.

---

## 0. Implementation summary (M08)

### Delivered behavior

- **My Requests list:** `ServiceRequestsListScreen` + shared `ServiceRequestsListBody` — `PdAppCard` rows with service type, status badge, animal, location (`locationText` or fallback `areaId`), submitted date/time, preferred time / scheduled start when present; pull-to-refresh; `PdLoadingBody` / `PdErrorBody` (retry) / `PdEmptyState`; FAB **নতুন অনুরোধ**. Shell tab uses the same screen with `embeddedInShell: true` (title **অনুরোধ**, extra bottom padding).
- **Standalone list route:** `GET`-backed list is also reachable at **`/service-requests`** (stack-friendly push from home / success).
- **Request detail:** Moved to `service_request_detail_screen.dart` — header row with **status badge**, **timeline** (`buildServiceRequestTimeline`), **assigned doctor/technician** cards when id or nested map exists (phone from map keys `phone` / `mobile` / `phoneNumber` when present), fact sections (animal, location, urgency, problem, description, preferred time, category, timestamps), **three placeholder cards** (completion / prescription / billing), cancel per `canCustomerCancel` with PATCH + invalidate list/detail.
- **Timeline:** `domain/service_request_timeline.dart` maps API `ServiceRequestStatus` + timestamps to six Bangla steps plus terminal cancel/reject styling; **ASSIGNED** maps to step **পথে** (on the way); **IN_PROGRESS** → **চিকিৎসা চলছে**.
- **Navigation:** Home **দ্রুত পথ** adds **আমার অনুরোধ** → `/service-requests`. Booking success: **বিস্তারিত** uses `push` (back returns to success); new **আমার সব অনুরোধ** → list route; **হোমে ফিরুন** unchanged.
- **DTO robustness:** `ServiceRequest.fromJson` / category / animal parsing tolerate missing or loosely typed fields where reasonable; `urgencyDisplayBn` maps common enum-like strings to Bangla.

### Files added

| File |
|------|
| `lib/src/features/service_requests/domain/service_request_timeline.dart` |
| `lib/src/features/service_requests/presentation/service_requests_list_screen.dart` |
| `lib/src/features/service_requests/presentation/service_request_detail_screen.dart` |
| `lib/src/features/service_requests/presentation/widgets/service_request_status_badge.dart` |
| `lib/src/features/service_requests/presentation/widgets/service_request_timeline_view.dart` |
| `lib/src/features/service_requests/presentation/widgets/assigned_provider_card.dart` |
| `lib/src/features/service_requests/presentation/widgets/request_placeholder_sections.dart` |
| `test/service_request_timeline_test.dart` |

### Files updated

| File |
|------|
| `lib/src/features/service_requests/presentation/service_requests_tab_screen.dart` (thin wrapper → `ServiceRequestsListScreen(embeddedInShell: true)`) |
| `lib/src/features/service_requests/data/service_request_model.dart` (tolerant parsing; `urgencyDisplayBn`; phone getters) |
| `lib/src/app/router.dart` (register `/service-requests` before `:requestId`) |
| `lib/src/features/service_requests/presentation/booking_success_screen.dart` |
| `lib/src/features/home/presentation/customer_home_screen.dart` |
| `lib/src/features/home/presentation/widgets/customer_recent_request_card.dart` |

### Automated tests

- `flutter test` — includes `test/service_request_timeline_test.dart`.

### Explicit non-goals (unchanged)

- No backend changes; no real billing/prescription payloads; no doctor workflow (M09).

---

## 1. Current audit findings

### 1.1 Flutter project structure (high level)

| Layer | Location | Pattern |
|-------|----------|---------|
| **App shell** | `lib/src/app/` | `router.dart`, `theme.dart`, `screen_padding.dart`, `navigation_keys.dart`, `router_error_screen.dart` |
| **Core** | `lib/src/core/` | Design tokens (`constants/`, `theme/`), `design_system.dart`, shared widgets (`widgets/`), networking (`network/`), `config/app_config.dart` |
| **Features** | `lib/src/features/<feature>/` | Typical split: `data/` (models + repositories), `application/` (Riverpod), `presentation/` (screens/widgets), optional `domain/` |
| **Session / auth** | `lib/src/features/session/`, `lib/src/features/auth/` | JWT in `TokenStorage`; `SessionNotifier`; OTP repository |

**Packages (no changes assumed for M08):** `flutter_riverpod`, `go_router`, `dio`, `flutter_secure_storage`, `shared_preferences`, `intl` — see `pubspec.yaml`.

### 1.2 Architecture pattern to follow

The established pattern for networked features is:

1. **DTO / enum** in `data/<entity>_model.dart` with `fromJson` aligned to mobile API camelCase.
2. **Repository** in `data/<entity>_repository.dart` using `ApiClient` → unwrap `{ ok, data }`, map `DioException` to typed/app exceptions.
3. **Riverpod** in `application/<feature>_providers.dart` — `Provider` for repository, `AsyncNotifier` or `FutureProvider.family` for list/detail.
4. **UI** — Material 3 + app spacing (`PdSpacing`), cards (`PdAppCard`), buttons (`PdPrimaryButton` / `PdSecondaryButton`) where polish matters; `go_router` for navigation.

**M08 should extend this pattern** rather than introducing a new state-management or networking stack.

### 1.3 What already exists vs M08 goals

| M08 expectation | Current state |
|-----------------|---------------|
| **GET /api/mobile/service-requests** | Implemented in `ServiceRequestRepository.list` with `limit`, `offset`, optional `status` query. |
| **GET /api/mobile/service-requests/:id** | Implemented in `ServiceRequestRepository.getById`. |
| **PATCH /api/mobile/service-requests/:id/cancel** | Implemented in `ServiceRequestRepository.cancel` (optional `cancelReason`); **409** mapped to Bangla message. |
| **My requests list** | **`ServiceRequestsTabScreen`** — pull-to-refresh, FAB “নতুন অনুরোধ”, list rows (`Card` + `ListTile`), empty + loading + error states (inline, not design-system widgets). |
| **Request detail** | **`ServiceRequestDetailScreen`** (same file as tab) — section list, status banner, cancel when `canCustomerCancel`. |
| **Status timeline** | **Not present** — only static status banner + text sections. |
| **Assigned doctor/technician card** | **Partial** — plain `_DetailSection` rows when `assignedDoctorDisplayName` / `assignedTechnicianDisplayName` exist; nested maps kept as `Map<String,dynamic>?`. |
| **Completion / prescription / billing summaries** | **Not present** — detail ends at cancellation fields and timestamps. |
| **Bengali-first labels** | **Yes** across list, detail, success, home recent card. |
| **Status badges** | **Partial** — banner colors by status; list subtitle uses `status.labelBn` text only (no chip). |
| **Pagination** | Repository supports pagination; **`ServiceRequestsListNotifier` loads a single page (`limit: 50`)** — no infinite scroll UI yet. |

### 1.4 Auth / session impact

- **`dio_provider.dart`:** Attaches `Authorization: Bearer` when token exists; **401** clears session and navigates to login.
- **`SessionNotifier`:** Customer sign-in stores token; guest mode possible without token — API calls may fail until OTP login; tracking screens should keep **clear error copy** (already partially true).

### 1.5 Routing / deep links

- **Detail:** `/service-requests/:requestId` registered in `router.dart`, builds `ServiceRequestDetailScreen(requestId: id)`.
- **Booking success:** `/booking/success` expects `GoRouterState.extra` as `ServiceRequest`; missing extra shows error scaffold.
- **Post-submit navigation:** `BookingWizardScreen` uses `context.pushReplacement(BookingSuccessScreen.routePath, extra: created)`.

---

## 2. Existing files discovered

### 2.1 Service requests / booking

| File | Role |
|------|------|
| `lib/src/features/service_requests/presentation/booking_wizard_screen.dart` | Multi-step wizard; POST create; navigates to success. |
| `lib/src/features/service_requests/presentation/booking_success_screen.dart` | Success summary; CTAs: push **detail**, push **list** (`/service-requests`), `go` **home**. |
| `lib/src/features/service_requests/presentation/service_requests_tab_screen.dart` | Shell tab → **`ServiceRequestsListScreen(embeddedInShell: true)`**. |
| `lib/src/features/service_requests/presentation/service_requests_list_screen.dart` | **My Requests** list (full route + shared body). |
| `lib/src/features/service_requests/presentation/service_request_detail_screen.dart` | **Detail** route widget. |
| `lib/src/features/service_requests/application/service_requests_providers.dart` | `serviceRequestRepositoryProvider`, `serviceRequestsListProvider`, `serviceRequestDetailProvider`, booking draft notifiers. |
| `lib/src/features/service_requests/data/service_request_repository.dart` | CRUD-style: `create`, `list`, `getById`, `cancel`; `ServiceRequestApiException`. |
| `lib/src/features/service_requests/data/service_request_model.dart` | `ServiceRequest`, `ServiceRequestStatus`, `ServiceRequestType`, refs. |
| `lib/src/features/service_requests/data/service_category_repository.dart` | Categories for booking (not tracking-specific). |
| `lib/src/features/service_requests/domain/booking_submit_helpers.dart` | Geo/provider step helpers for wizard. |
| `lib/src/features/service_requests/domain/booking_urgency.dart` | Wizard urgency enum. |
| `test/booking_submit_helpers_test.dart` | Domain tests for booking helpers. |

### 2.2 Home navigation & recent request

| File | Role |
|------|------|
| `lib/src/features/home/home_shell_screen.dart` | Bottom nav **IndexedStack**; tab index **2** = `ServiceRequestsTabScreen`. |
| `lib/src/features/home/presentation/customer_home_screen.dart` | Dashboard; shortcuts; **`CustomerRecentRequestCard`**. |
| `lib/src/features/home/presentation/widgets/customer_recent_request_card.dart` | Loads `serviceRequestsListProvider`; empty/loading/error; tap → detail push. |

### 2.3 API / client layer

| File | Role |
|------|------|
| `lib/src/core/network/api_client.dart` | Thin Dio wrapper (`get`/`post`/`patch`). |
| `lib/src/core/network/dio_provider.dart` | Base URL, timeouts, auth interceptor, 401 handling. |
| `lib/src/core/config/app_config.dart` | `API_BASE_URL` (`--dart-define`). |

### 2.4 Auth / session

| File | Role |
|------|------|
| `lib/src/features/session/application/session_notifier.dart` | `SessionState`, `signInCustomer`, `hydrateFromStorage`, `signOut`. |
| `lib/src/features/auth/data/mobile_otp_auth_repository.dart` | OTP request/verify. |
| `lib/src/core/storage/token_storage.dart` | Access token persistence (referenced from Dio). |

### 2.5 Shared widgets / design system

| File | Role |
|------|------|
| `lib/src/core/design_system.dart` | Barrel / entry for design system. |
| `lib/src/core/widgets/pd_async_states.dart` | **`PdLoadingBody`**, **`PdErrorBody`**, **`PdEmptyState`** (Bangla-oriented; optional retry). |
| `lib/src/core/widgets/pd_app_card.dart` | Card container + tap; used on home recent request. |
| `lib/src/core/widgets/pd_buttons.dart` | `PdPrimaryButton`, `PdSecondaryButton`. |
| `lib/src/core/widgets/pd_page_header.dart` | Page header pattern. |
| `lib/src/core/constants/pd_spacing.dart` | Spacing scale. |
| `lib/src/app/theme.dart` | Material theme wiring. |
| `docs/MOBILE_UI_DESIGN_SYSTEM.md` | Reference for tokens and patterns. |

### 2.6 Routing

| File | Role |
|------|------|
| `lib/src/app/router.dart` | Customer routes: **`/service-requests`** (list), **`/service-requests/:requestId`** (detail), booking, shell, etc. |

### 2.7 Documentation already mapping APIs

| File | Role |
|------|------|
| `docs/MOBILE_API_INTEGRATION_MAP.md` | Lists service-request endpoints ↔ repository ↔ screens. |

---

## 3. Proposed files to create / update (**done in M08**)

Original plan — implemented as follows:

| Action | Path | Result |
|--------|------|--------|
| Split presentation | `service_requests_list_screen.dart`, `service_request_detail_screen.dart`, `presentation/widgets/*` | Done |
| Domain timeline | `domain/service_request_timeline.dart` | Done |
| Providers | — | Unchanged (`service_requests_providers.dart` sufficient) |
| Tests | `test/service_request_timeline_test.dart` | Done |

**Explicit non-goals for file churn:** Repository method names and mobile API paths unchanged.

---

## 4. Data model / DTO approach

- **Keep** `ServiceRequest` as the single aggregate read model for list + detail, parsed from API JSON in `service_request_model.dart`.
- **Assigned provider:** Today exposes `assignedDoctor` / `assignedTechnician` as `Map<String,dynamic>?` and convenience getters for `displayName`. For a richer **card** (photo, phone, rating), either:
  - **Phase A (M08):** Card layout using **safe optional fields** from the map if present (`displayName`, `phone`, etc.) with graceful fallback — **no backend change** in mobile scope; or
  - **Phase B (later):** Introduce typed `AssignedProviderRef` when API contract is frozen (still client-only change).
- **Placeholders (prescription, billing, completion narrative):** No new DTOs required — UI sections gated on “always show placeholder” or on nullable future fields when APIs exist.
- **Status enum:** Remains **`ServiceRequestStatus`** (`PENDING`, `ACCEPTED`, `ASSIGNED`, `IN_PROGRESS`, `COMPLETED`, `CANCELLED`, `REJECTED`) — must stay aligned with API string values (`byName`).

---

## 5. API integration approach

- **No new endpoints** required for M08 beyond what is already wired; integration continues through `ServiceRequestRepository`.
- **List:** Use existing `list`; consider exposing **pull-to-refresh** + optional **“load more”** if product wants beyond 50 rows (uses same method with `offset`).
- **Detail:** `FutureProvider.autoDispose.family` — keep `ref.invalidate` after cancel (already done).
- **Cancel:** Keep PATCH body as today; surface **`ServiceRequestApiException.message`** in SnackBar (already done).
- **Errors:** Continue to rely on repository mapping; optionally unify list/detail error UI with `PdErrorBody` + retry that calls `refresh()` / `ref.invalidate`.

---

## 6. Navigation approach (home + booking success)

| Entry | Current behavior | M08 enhancement (UI only) |
|-------|------------------|---------------------------|
| **Home → requests** | Bottom tab opens `ServiceRequestsTabScreen`. | Optional banner CTA “সব অনুরোধ দেখুন” already satisfied by tab; home **recent card** already deep-links to detail. |
| **Booking success** | Primary button **`context.go(ServiceRequestDetailScreen.routePathFor(request.id))`**. | Ensure detail screen **back stack** feels correct after `go` (may land without shell underneath — **evaluate** `push` vs `go` in implementation if UX asks for tab context). |
| **List → detail** | `context.push(routePathFor(id))`. | Keep; preserves stack for back navigation. |
| **After cancel** | Invalidates providers + SnackBar. | Optionally scroll-to-top or emphasize updated timeline — polish only. |

---

## 7. UI structure — request list (`ServiceRequestsTabScreen`)

**Suggested layout (incremental on current):**

1. **AppBar:** Title “অনুরোধ” (or “আমার অনুরোধ” if product prefers stronger ownership copy).
2. **Body:** `RefreshIndicator` + scrollable list.
3. **Row content:** Lead with **service type** (`labelBn`); secondary line **status chip / badge** + submitted date; optional trailing chevron; tap → detail.
4. **FAB:** “নতুন অনুরোধ” → `/booking/new` (existing).
5. **Design alignment:** Replace ad-hoc empty/error with **`PdEmptyState`** / **`PdErrorBody`** inside scroll view with `AlwaysScrollableScrollPhysics` for refresh consistency (same pattern as recent request card’s quality).

**Optional:** Filter chips by status — repository already accepts `status` query; provider would need parameters (future enhancement if scope allows).

---

## 8. UI structure — request detail (`ServiceRequestDetailScreen`)

**Suggested section order:**

1. **Hero summary:** Service type + **status badge** (reuse chip widget).
2. **Timeline:** Vertical stepper — see section 9.
3. **Assigned provider card:** Doctor and/or technician — avatar placeholder, name, optional contact actions if data exists.
4. **Request facts:** Animal, category, problem/symptom, location, preferred time, timestamps (existing `_DetailSection` content).
5. **Completion summary (placeholder):** Static Bangla copy + “শীঘ্রই” when `status != COMPLETED`; when completed, either real fields later or richer placeholder.
6. **Prescription / treatment summary (placeholder):** Non-interactive card; no workflow.
7. **Billing summary (placeholder):** Align copy with `MOBILE_API_INTEGRATION_MAP.md` — billing APIs **not** in app yet.
8. **Actions:** **Cancel** button (existing rules); secondary **“সাহায্য”** or **“হোম”** only if product wants (optional).

**Loading / error:** Prefer `PdLoadingBody` / `PdErrorBody` with retry calling `ref.invalidate(serviceRequestDetailProvider(id))`.

---

## 9. Request status — product labels vs API enum mapping

Product copy (Bengali-first) vs stored/API status:

| Product stage | Suggested mapping to `ServiceRequestStatus` | Notes |
|---------------|---------------------------------------------|--------|
| **Submitted** | Treat as **informational** right after POST | API returns **`PENDING`** for new requests; show copy “জমা হয়েছে” on success + first timeline node. |
| **Pending assignment** | **`PENDING`** | Until assignee exists; optional heuristic: `assignedDoctorId == null && assignedTechnicianId == null`. |
| **Accepted** | **`ACCEPTED`** | |
| **On the way** | **No dedicated enum value today** | Options: (a) UI-only step tied to a **future** backend flag/time range; (b) approximate with **`ACCEPTED`** or **`ASSIGNED`** + copy only — **document choice in implementation**; do not invent API values. |
| **In treatment** | **`IN_PROGRESS`** | Consider Bangla label tweak from “চলছে” to “চিকিৎসা চলছে” if product approves. |
| **Completed** | **`COMPLETED`** | |
| **Cancelled** | **`CANCELLED`** | |
| **Rejected** | **`REJECTED`** | Include in timeline as terminal failure (copy-sensitive). |

**Timeline logic:** Derive **completed steps** from `status` and timestamps (`assignedAt`, `startedAt`, `completedAt`, `cancelledAt`) where available; “On the way” step remains **disabled or hidden** until backend exposes a reliable signal.

---

## 10. Cancel request behavior

- **Eligibility:** `ServiceRequest.canCustomerCancel` — **`PENDING`, `ACCEPTED`, `ASSIGNED` only** (not `IN_PROGRESS` in current model). M08 UI should **match** this and hide/disable cancel otherwise, with short explanatory text if useful.
- **Flow:** Confirmation dialog (Bangla) + optional reason field → PATCH → invalidate list + detail → success SnackBar.
- **409:** Already mapped — show message; no stack trace to user.

---

## 11. Loading / error / empty state plan

| Surface | Current | Target polish |
|---------|---------|---------------|
| **List loading** | Center `CircularProgressIndicator` | `PdLoadingBody` or compact inline indicator consistent with home card. |
| **List error** | Icon + text in `ListView` | `PdErrorBody` + **retry** → `serviceRequestsListProvider.notifier.refresh()`. |
| **List empty** | Icon + copy | `PdEmptyState` + CTA to booking (FAB already exists — avoid duplicate primary actions). |
| **Detail loading** | Center progress | `PdLoadingBody`. |
| **Detail error** | Plain `Text` | `PdErrorBody` + retry invalidate. |
| **Recent request card** | Already strong pattern | Keep as reference for M08 list/detail alignment. |

---

## 12. Explicitly out of scope

- **Backend / API schema changes** — not part of M08 mobile task as specified.
- **Doctor treatment workflow, doctor app, M09** — no doctor-case screens.
- **Real prescription, treatment notes, or billing data** — placeholders only.
- **Push notifications** for status changes — not required for M08 (optional future).
- **New Flutter packages** — avoid unless a timeline widget cannot be built with Material + existing layout (default: custom `Column` / `Stepper` / intrinsic-height timeline).
- **Web repo, other products** — no mixing.

---

## 13. Test / checklist plan

### 13.1 Manual QA

- [ ] Logged-in customer: requests tab loads; pull-to-refresh works.
- [ ] Empty list shows helpful Bangla empty state and path to new request.
- [ ] Tap row → detail; system back returns to list.
- [ ] From `/booking/success`, primary CTA opens detail; fields match create response.
- [ ] Deep link or cold navigation to `/service-requests/:id` works when authenticated.
- [ ] Cancel flow: dialog → success updates status / timeline; list reflects change.
- [ ] Cancel blocked states: no button when `canCustomerCancel` is false.
- [ ] Error simulation (airplane mode): list and detail show retry-friendly UI.
- [ ] **Unauthorized:** 401 clears session and routes to login (regression).

### 13.2 Automated tests

- [x] Unit tests for **timeline** (`test/service_request_timeline_test.dart`).
- [ ] Optional: golden/widget tests for status chip colors (if complexity grows).

### 13.3 Design review

- [ ] Bengali labels reviewed for **status** and **timeline** steps.
- [ ] Badges use **`ColorScheme`** consistently (primary / tertiary / error containers).

---

## 14. Summary

The mobile app **already implements** the three service-request APIs and core navigation for list and detail. M08 implementation work is primarily **UX depth**: timeline, richer status presentation, assigned-provider card, completion/prescription/billing placeholders, alignment with **`Pd*`** async widgets, and a clear mapping from product statuses to the existing **`ServiceRequestStatus`** model — without backend changes and without doctor workflow scope.

---

## 15. Final verification (2026-05-09)

### Commands run

| # | Command | Result |
|---|---------|--------|
| 1 | `dart format .` | **Pass** — formatted 102 files; 7 files updated (M08-related Dart under `lib/…/service_requests/` and `test/service_request_timeline_test.dart`). |
| 2 | `flutter analyze` | **Pass** — no issues found. |
| 3 | `flutter test` | **Pass** — 27 tests, including `test/service_request_timeline_test.dart`. |

**Not run (not requested):** `flutter build` / release artifacts — no blocking failures inferred from analyze/tests.

### Manual code review (M08 scope)

| Area | Finding |
|------|---------|
| **List loading/error/empty** | `ServiceRequestsListBody` uses `RefreshIndicator` + scrollable `ListView`; `PdLoadingBody`, `PdErrorBody` (+ retry → `refresh()`), `PdEmptyState` (+ push booking). |
| **Detail loading/error** | `PdLoadingBody`; `PdErrorBody` + retry → `ref.invalidate(serviceRequestDetailProvider(id))`. |
| **Status badge** | `ServiceRequestStatusBadge` uses `status.labelBn` and `ColorScheme` containers (pending / active cluster / completed / error). |
| **Timeline order** | `kServiceRequestTimelineLabelsBn`: জমা → নিয়োগের অপেক্ষায় → গ্রহণ → পথে → চিকিৎসা চলছে → সম্পন্ন; maps `PENDING`→1, `ACCEPTED`→2, `ASSIGNED`→3, `IN_PROGRESS`→4, `COMPLETED` all completed; cancel/reject branches in `service_request_timeline.dart`. |
| **Cancel visibility** | Shown only when `r.canCustomerCancel` (`PENDING`, `ACCEPTED`, `ASSIGNED`). |
| **Cancel API UX** | PATCH via repository; success → invalidate detail + list + SnackBar; `ServiceRequestApiException` → SnackBar (includes 409 mapping from repository). |
| **Home navigation** | `CustomerShortcutCard` **আমার অনুরোধ** → `push(ServiceRequestsListScreen.routePath)`; bottom tab still opens embedded list. |
| **Booking success navigation** | `push` detail; `push` **আমার সব অনুরোধ**; `go` home — wizard still `pushReplacement` to success (unchanged). |
| **Doctor treatment workflow** | No M09/doctor-case UI added. |
| **Backend** | No `pranidoctor-web` or API route changes in this task. |

### Remaining known issues / caveats

- **Manual QA on device** (§13.1) not executed in this verification pass — only static review + automated checks.
- **Empty `id` from malformed JSON** — tolerant `fromJson` could yield `id == ''`; detail fetch would fail gracefully via error state.
- **`flutter build`** not verified — run before release if CI does not cover it.

### Files touched in this verification pass

| File | Change |
|------|--------|
| `lib/src/features/service_requests/data/service_request_model.dart` | `dart format` |
| `lib/src/features/service_requests/domain/service_request_timeline.dart` | `dart format` |
| `lib/src/features/service_requests/presentation/service_request_detail_screen.dart` | `dart format` |
| `lib/src/features/service_requests/presentation/service_requests_list_screen.dart` | `dart format` |
| `lib/src/features/service_requests/presentation/widgets/service_request_status_badge.dart` | `dart format` |
| `lib/src/features/service_requests/presentation/widgets/service_request_timeline_view.dart` | `dart format` |
| `test/service_request_timeline_test.dart` | `dart format` |
| `docs/tasks/M08_REQUEST_TRACKING_PLAN.md` | Added §15; ordered §14 before §15 |

