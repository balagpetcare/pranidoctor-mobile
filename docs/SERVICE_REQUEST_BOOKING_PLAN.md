# Service request / booking — mobile implementation plan

**Project:** [Prani Doctor](https://pranidoctor.com/)  
**App:** `pranidoctor_mobile` (Flutter, Riverpod, Dio, go_router)  
**Backend:** `pranidoctor-web` — `POST/GET /api/mobile/service-requests`, cancel route, enums per `docs/SERVICE_REQUEST_BOOKING_PLAN.md` (web repo)  
**Last updated:** 2026-05-09 (E2E code audit + cross-repo alignment; see §5)

---

## 1. Audit summary (pre-implementation)

### 1.1 `lib` structure

- **`src/core/`** — `config/app_config.dart` (`API_BASE_URL`), `network/api_client.dart`, `dio_provider.dart` (Bearer from `token_storage`), `storage/`.
- **`src/app/`** — `router.dart`, `theme.dart`, `screen_padding.dart`, `app.dart`.
- **`src/features/`** — `animals/` (repository + `AsyncNotifier` list + `FutureProvider` detail), `providers/` (finder), `home/` (`HomeShellScreen` with IndexedStack tabs), `auth/`, `session/`.

### 1.2 API client

- **`ApiClient`** wraps Dio: `get`, `post`, `patch`.
- **Envelope:** `{ ok: true, data: ... }` / `{ ok: false, error: { code, message } }` — mirrored in `AnimalProfileRepository._unwrap`.

### 1.3 Auth / token

- **`dio_provider`** adds `Authorization: Bearer <token>` when present.
- Session/sign-out via `sessionNotifierProvider`.

### 1.4 Animals (Task 09)

- **`AnimalProfileRepository`**, **`animalsListProvider`**, **`animalDetailProvider`** — reuse for booking animal step (`active` animals only).

### 1.5 Area / provider finder

- **No customer `Area` picker API** on mobile today. Booking MVP uses **`locationText`** (plus optional `areaId`/`villageId` later) to satisfy backend “at least one location signal” for field-visit types.

### 1.6 Navigation

- **`go_router`** with flat routes (splash, login, `/home`, doctors, technicians).
- **Bottom nav** uses **IndexedStack** — requests tab is **`ServiceRequestsTabScreen`** (list + FAB). Full-screen routes: **`/booking/new`**, **`/service-requests/:requestId`**.

### 1.7 Theme / UX

- Material 3, Bengali copy elsewhere — match **`screen_padding`**, **`Card`**, **`FilledButton`** patterns from home/animals.

### 1.8 Mobile feature (`pranidoctor_mobile`)

| Item | Status |
|------|--------|
| **Booking wizard** | **Implemented** — `BookingWizardScreen` (`/booking/new`): animal, service type, problem, description, location text, preferred time, review/submit. |
| **Requests tab** | **Implemented** — `ServiceRequestsTabScreen` with list, pull-to-refresh, empty/error states, FAB. |
| **Detail + cancel** | **Implemented** — `ServiceRequestDetailScreen` (`/service-requests/:id`), confirmation dialog, optional cancel reason. |
| **API** | Repositories mirror animals pattern; `GET /api/mobile/service-categories` required (implemented in `pranidoctor-web`). |

---

## 2. Mobile feature design

| Piece | Choice |
|-------|--------|
| **State** | Riverpod: `serviceRequestRepositoryProvider`, `serviceRequestsListProvider` (AsyncNotifier refresh), `serviceCategoriesProvider`, `bookingDraftProvider` (hold wizard fields). |
| **Types** | Dart enums / strings aligned with backend: `DOCTOR_HOME_VISIT`, `EMERGENCY_DOCTOR`, `AI_SERVICE`, `ONLINE_CONSULTATION_LATER`. |
| **Wizard** | Single **`BookingWizardScreen`** with **`PageView`** steps: animal → type → problem → description → location → preferred time → review/submit. |
| **List / detail** | **`ServiceRequestsTabScreen`**, navigate to **`ServiceRequestDetailScreen`**; cancel with confirmation dialog → `PATCH .../cancel`. |

### 2.1 Bengali status labels (API → UI)

| API status | BN label |
|------------|----------|
| PENDING | অপেক্ষমান |
| ACCEPTED | গ্রহণ হয়েছে |
| ASSIGNED | নিয়োগ হয়েছে |
| IN_PROGRESS | চলছে |
| COMPLETED | সম্পন্ন |
| CANCELLED | বাতিল |
| REJECTED | প্রত্যাখ্যাত |

---

## 3. API integration (mobile)

| Action | Method | Path |
|--------|--------|------|
| List categories | GET | `/api/mobile/service-categories` |
| Create | POST | `/api/mobile/service-requests` |
| List mine | GET | `/api/mobile/service-requests` |
| Detail | GET | `/api/mobile/service-requests/:id` |
| Cancel | PATCH | `/api/mobile/service-requests/:id/cancel` |

---

## 4. Implementation checklist

- [x] Plan doc (this file)
- [x] Models + repository + providers
- [x] Service requests tab + list/detail/cancel
- [x] Booking wizard (all steps)
- [x] Router + home shell tab swap
- [x] Web: `GET /api/mobile/service-categories` (customer-auth)

---

## 5. E2E verification (Task Card 11 — code audit)

Cross-checked with `pranidoctor-web`: customer scope, cancel rules, validation envelopes, and admin routes. **Live device / two-account QA** should still be run before release.

| Check | Notes |
|-------|--------|
| Create / list / detail / cancel | `ServiceRequestRepository` + `BookingWizardScreen` / tab / detail screen. |
| Isolation | Backend `customerId` on all mobile reads/writes; other user’s id → 404. |
| Cancel rules | UI gates cancel to PENDING / ACCEPTED / ASSIGNED; server rejects others with 409. |
| Validation | 422 + `error.message` shown in SnackBar on wizard submit. |
| Admin | Implemented in web only; use `/admin/service-requests` (session cookie). |

**Automated (2026-05-09):** `flutter analyze` — no issues; `flutter test` — pass.

---

## 6. Follow-ups (optional)

- Village/area picker when a public geography API exists for customers.
- `scheduledStart` / `scheduledEnd` pickers.
- Push notifications on status change.
