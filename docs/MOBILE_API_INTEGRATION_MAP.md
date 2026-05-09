# Prani Doctor Mobile — API Integration Map

**Purpose:** Map each HTTP surface the app uses to **repository**, **feature**, and **screens**. Use this when planning tasks M01–M15 so API work stays traceable.

**Base URL:** `AppConfig.apiBaseUrl` (`--dart-define=API_BASE_URL=...`, default `http://localhost:3000`).  
**Auth:** `Dio` interceptor adds `Authorization: Bearer <accessToken>` from `TokenStorage` when present. **401** clears session and navigates to customer login (`dio_provider.dart`).

**Response shape:** Most mobile routes return JSON with `{ "ok": true, "data": { ... } }` or `{ "ok": false, "error": { "message", "code"? } }`. Repositories unwrap `data` consistently.

---

## Legend

| Column | Meaning |
|--------|---------|
| **Method** | HTTP verb |
| **Path** | Path relative to base URL |
| **Repository** | Dart class / file |
| **Used by** | Typical UI entry points |

---

## Authentication (customer OTP)

| Method | Path | Repository | Used by |
|--------|------|------------|---------|
| POST | `/api/mobile/auth/otp/request` | `MobileOtpAuthRepository` — `mobile_otp_auth_repository.dart` | `LoginEntryScreen` |
| POST | `/api/mobile/auth/otp/verify` | same | same (returns `accessToken`, stored via `SessionNotifier.signInCustomer`) |

**Note:** Doctor login/home routes exist in the app but are **not** wired to doctor APIs in this map yet (stub UX).

---

## Animals (mobile)

| Method | Path | Repository | Used by |
|--------|------|------------|---------|
| GET | `/api/mobile/animals` | `AnimalProfileRepository` — `animal_profile_repository.dart` | Animals tab, lists |
| GET | `/api/mobile/animals/:id` | same | `AnimalDetailScreen` |
| POST | `/api/mobile/animals` | same | `AnimalFormScreen` (create) |
| PATCH | `/api/mobile/animals/:id` | same | `AnimalFormScreen` (edit) |
| PATCH | `/api/mobile/animals/:id/deactivate` | same | deactivate flow |

---

## Service categories

| Method | Path | Repository | Used by |
|--------|------|------------|---------|
| GET | `/api/mobile/service-categories` | `ServiceCategoryRepository` — `service_category_repository.dart` | `BookingWizardScreen`, `ProviderFilterPanel` |

---

## Service requests (mobile)

| Method | Path | Repository | Used by |
|--------|------|------------|---------|
| POST | `/api/mobile/service-requests` | `ServiceRequestRepository` — `service_request_repository.dart` | `BookingWizardScreen` |
| GET | `/api/mobile/service-requests` | same | `ServiceRequestsTabScreen` (list + pagination) |
| GET | `/api/mobile/service-requests/:id` | same | `ServiceRequestDetailScreen` |
| PATCH | `/api/mobile/service-requests/:id/cancel` | same | cancel from detail |

---

## Provider finder (doctors & AI technicians)

| Method | Path | Repository | Used by |
|--------|------|------------|---------|
| GET | `/api/mobile/providers/doctors` | `ProviderFinderRepository` — `provider_finder_repository.dart` | `DoctorListScreen` |
| GET | `/api/mobile/providers/doctors/:id` | same | `DoctorDetailScreen` → `ProviderDetailScreen` |
| GET | `/api/mobile/providers/technicians` | same | `TechnicianListScreen` |
| GET | `/api/mobile/providers/technicians/:id` | same | `TechnicianDetailScreen` → `ProviderDetailScreen` |
| GET | `/api/mobile/providers/:id` | same (`getProviderProfileDetail`) | `ProviderDetailScreen` — tried first; **404** falls back to role-specific `…/doctors/:id` or `…/technicians/:id` using the screen's `ProviderKind`. Unified `data` may contain `doctor`, `technician`, or `provider` plus `kind` (parser is best-effort). |

**Query notes:** `ProviderListQuery` → `areaSlug`, `areaId`, `animalType`, `homeVisit`, `emergency`, `onlineConsultation`, `serviceCategoryId`, `aiTechnicianService`, `search` (from `nameSearch`), pagination. Repository **coerces** unknown `areaSlug` values (only `ashulia-union-area` allowed in code today). **Offline fixtures:** `USE_PROVIDER_FIXTURES=true` — see `provider_finder_fallback_data.dart`.

---

## Tutorials / Knowledge Hub (mobile)

| Method | Path | Repository | Used by |
|--------|------|------------|---------|
| GET | `/api/mobile/tutorials/categories` | `TutorialRepository` — `tutorial_repository.dart` | `TutorialListScreen` |
| GET | `/api/mobile/tutorials` | same | list with `take` / `skip` / category filters |
| GET | `/api/mobile/tutorials/:slugOrId` | same | `TutorialDetailScreen` (slug or id URL-encoded) |

---

## Notifications (shared path prefix)

| Method | Path | Repository | Used by |
|--------|------|------------|---------|
| GET | `/api/notifications` | `NotificationRepository` — `notification_repository.dart` | `NotificationsListScreen` |
| PATCH | `/api/notifications/:id/read` | same | mark one read |
| PATCH | `/api/notifications/read-all` | same | mark all read |

**Note:** These paths use `/api/notifications` (not under `/api/mobile/`), per current client.

---

## Doctor APIs (planned / not in mobile client yet)

The app has **stub** doctor UI (`/doctor/login`, `/doctor/home`). There is **no** `Dio` usage for `/api/doctor/*` in this repo at audit time. Task **M09** should add integration map rows when endpoints are wired.

---

## Billing / payments

**No** billing or payment REST calls found under `lib/` at audit time. Task **M11** will define endpoints when product/backend agrees.

---

## Core networking files

| File | Role |
|------|------|
| `lib/src/core/config/app_config.dart` | `API_BASE_URL` |
| `lib/src/core/network/dio_provider.dart` | `Dio` instance, timeouts, auth header, 401 handler |
| `lib/src/core/network/api_client.dart` | Thin `get` / `post` / `patch` wrapper |
| `lib/src/core/storage/token_storage.dart` | Secure token read/write |
| `lib/src/features/session/application/session_notifier.dart` | Customer sign-in, hydrate, sign-out |

---

## Related planning docs (existing)

- `docs/MVP_AUDIT_AND_LAUNCH_CHECKLIST.md` — launch gaps  
- `docs/SERVICE_REQUEST_BOOKING_PLAN.md` — booking flow  
- `docs/PROVIDER_FINDER_MOBILE_PLAN.md` — finder  
- `docs/KNOWLEDGE_HUB_MOBILE_PLAN.md` — tutorials  
- `docs/MOBILE_NOTIFICATION_PLAN.md` — notifications  
- `docs/ANIMAL_PROFILE_PLAN.md` — animals  

Update **this file** whenever a new repository method or path is added.
