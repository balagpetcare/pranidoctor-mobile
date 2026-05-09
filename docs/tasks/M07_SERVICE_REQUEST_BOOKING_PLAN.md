# Task M07 — Service Request / Booking Flow

**Product:** Prani Doctor (Animal Doctors) — Bangladesh-first veterinary mobile app.  
**Repo:** `pranidoctor_mobile` (local: `D:\PraniDoctor\pranidoctor_mobile`)  
**Status:** **Implemented** (2026-05-09) — customer booking wizard, success screen, shell requests tab, home entry presets. See **§15** for deviations.

**Depends on / relates to:** M01 (design system), M02 (shell), M03 (OTP), M04 (customer home), M05 (animals), M06 (provider finder).  
**Related docs:** `docs/MOBILE_API_INTEGRATION_MAP.md`, `docs/SERVICE_REQUEST_BOOKING_PLAN.md` (root-level booking notes).

---

## 15. Implementation summary & deviations (M07 complete)

### Completed checklist

- [x] **Shell:** `ServiceRequestsTabScreen` replaces `RequestsTabPlaceholderScreen` in `home_shell_screen.dart`.
- [x] **Wizard steps (8):** service type → animal → area/location → provider (conditional) → problem (+ optional extra notes) → urgency → preferred time → review/submit.
- [x] **Emergency UX:** Inline warning before **জরুরি ডাক্তার** card; urgency **জরুরি** shows warning before chip; confirmation dialog before submit when emergency urgency **or** service type `EMERGENCY_DOCTOR`.
- [x] **Area selector:** Preset **আশুলিয়া ইউনিয়ন** (`ashulia-union-area`) + **অন্যান্য** + free-text detail; composed into API **`locationText`** (no `areaId` sent).
- [x] **Provider step:** Loads doctors or technicians from existing finder APIs; online placeholder copy only; optional selection merged into **`description`** (strict POST schema).
- [x] **Urgency:** সাধারণ / দ্রুত / জরুরি — merged into **`description`** (`জরুরিতা: …`).
- [x] **Success screen:** `/booking/success` with `extra: ServiceRequest`.
- [x] **Design system:** `PdAppCard`, `PdTextField`, `PdSpacing` on key surfaces.
- [x] **Home entry:** `?preset=<ServiceRequestType.name>` on `/booking/new`.
- [x] **Tests:** `test/booking_submit_helpers_test.dart`.

### Deviations / constraints

| Topic | Decision |
|-------|----------|
| **POST body (`strict` backend)** | **`urgency`** and **preferred provider** are **not** separate keys; appended to **`description`** as Bengali text. |
| **`areaId` / `villageId`** | Not sent — only **`locationText`** composed from preset + detail. |
| **AI home card** | Opens booking with **`preset=AI_SERVICE`** instead of provider finder landing (finder still at **`/providers`**). |

### Files added

| File |
|------|
| `lib/src/features/service_requests/domain/booking_urgency.dart` |
| `lib/src/features/service_requests/domain/booking_submit_helpers.dart` |
| `lib/src/features/service_requests/presentation/booking_success_screen.dart` |
| `test/booking_submit_helpers_test.dart` |

### Routes added / updated

| Route | Notes |
|-------|-------|
| `/booking/new?preset=…` | Parsed in `router.dart`. |
| `/booking/success` | Expects `extra` = `ServiceRequest`. |

---

## 1. Audit findings

### 1.1 Routing / navigation (`go_router`)

| Finding | Detail |
|--------|--------|
| **Router** | `lib/src/app/router.dart` — `goRouterProvider` with `refreshListenable` tied to `sessionNotifierProvider`; customer paths require auth except splash, onboarding, login (and `/doctor/*` bypass). |
| **Home shell** | `HomeShellScreen.routePath` = `/home` — **IndexedStack** with **5** bottom tabs (হোম, আমার পশু, অনুরোধ, সহায়তা, প্রোফাইল). |
| **Booking** | `BookingWizardScreen` — `routePath` **`/booking/new`**, `routeName` `bookingNew`. |
| **Service request detail** | **`/service-requests/:requestId`** — `ServiceRequestDetailScreen` (defined in `service_requests_tab_screen.dart`, registered in router). |
| **Provider finder** | `/providers`, `/providers/doctors`, `/providers/doctors/:doctorId`, `/providers/technicians`, `/providers/technicians/:technicianId`. |
| **Deep linking** | No query params on `/booking/new` today for pre-selected service type; **optional enhancement** for M07 (e.g. `?type=EMERGENCY_DOCTOR`). |

### 1.2 Customer / home / service entry points

| Finding | Detail |
|--------|--------|
| **Customer home** | `lib/src/features/home/presentation/customer_home_screen.dart` — Bengali-first; **Emergency CTA** and **ডাক্তার — বাড়িতে পরিদর্শন** push **`BookingWizardScreen.routePath`**. |
| **AI টেকনিশিয়ান card** | Navigates to **`ProviderFinderLandingScreen`** (finder only), **not** into booking with service type pre-set. |
| **অনলাইন পরামর্শ** | **Muted** card; **`_onlineConsultationPlaceholder`** → SnackBar: *অনলাইন পরামর্শ শীঘ্রই চালু হবে।* (placeholder only). |
| **Recent requests** | `CustomerRecentRequestCard` uses `serviceRequestsListProvider`, design-system cards/buttons, navigates to detail or booking — **fully wired**. |

### 1.3 Requests tab — **implementation gap (critical)**

| Finding | Detail |
|--------|--------|
| **Code** | `home_shell_screen.dart` tab index **2** uses **`RequestsTabPlaceholderScreen`** (`customer_shell_tab_placeholders.dart`) — static placeholder text: *UI পরে যুক্ত হবে*. |
| **Existing implementation** | **`ServiceRequestsTabScreen`** exists in `service_requests_tab_screen.dart` (list, FAB, refresh, empty/error) but is **not** mounted in the shell. |
| **Docs drift** | `docs/SERVICE_REQUEST_BOOKING_PLAN.md` and `MOBILE_API_INTEGRATION_MAP.md` describe the tab as `ServiceRequestsTabScreen`. **Shell must be switched** during M07 implementation (one-line import + widget swap). |

### 1.4 Animal profile module (M05)

| Finding | Detail |
|--------|--------|
| **Present** | `features/animals/` — `AnimalProfileRepository`, `AnimalProfile` model, **`animalsListProvider`** (`AsyncNotifier`), **`animalDetailProvider`**. |
| **Booking usage** | `BookingWizardScreen` **`_AnimalStep`** uses `animalsListProvider`, filters **`active`** animals only; empty state points user to **“আমার পশু”** tab. |
| **Animals tab** | Shell uses **`AnimalsTabScreen`** (not placeholder) — aligned with M05. |

### 1.5 Provider / doctor / AI technician finder (M06)

| Finding | Detail |
|--------|--------|
| **Present** | `features/providers/` — `ProviderFinderRepository`, `ProviderListQuery` ( **`areaSlug`**, **`areaId`**, service filters), list/detail screens, `provider_finder_providers.dart`. |
| **Area filter** | `ProviderFilterPanel` / repository **`_allowedAreaSlugs` / `_knownAreaSlugs`** currently **`ashulia-union-area`** only — **hard-coded small set**. |
| **Booking integration** | **No** navigation from booking wizard to pick a **specific** doctor/technician; finder is a **separate** route from home. |
| **Provider landing** | **`_emergencyPlaceholder`** SnackBar — *জরুরি সেবা অনুরোধ — পরবর্তী আপডেটে যুক্ত হবে।* — overlaps M07 “emergency doctor” product goal. |

### 1.6 API client / repository patterns

| Finding | Detail |
|--------|--------|
| **Stack** | `dio_provider.dart` → **`ApiClient`** (`get` / `post` / `patch`), Bearer token from `tokenStorageProvider`, **401** → sign out + `go(login)`. |
| **Envelope** | Repositories expect `{ ok: true, data: { ... } }` and unwrap `data`; errors → typed exceptions (`ServiceRequestApiException`, etc.). |
| **Service requests** | **`ServiceRequestRepository`**: `POST /api/mobile/service-requests`, `GET` list, `GET :id`, **`PATCH :id/cancel`** — **already implemented**. |
| **Categories** | **`ServiceCategoryRepository`**: `GET /api/mobile/service-categories` — used on submit to resolve **`serviceCategoryId`** from `ServiceRequestType.slug`. |
| **List pagination** | Repository supports `limit`/`offset`/`status`; UI list uses **`limit: 50`** only — **no infinite scroll** yet. |

### 1.7 Auth / session / token

| Finding | Detail |
|--------|--------|
| **Session** | `session_notifier.dart` — `signInCustomer`, `hydrateFromStorage`, `signOut`; **`AppRole.customer`**. |
| **Guest** | `signInGuest()` exists — **booking/API still require real JWT** for production APIs; behavior unchanged by M07 plan. |

### 1.8 Shared UI / design system

| Finding | Detail |
|--------|--------|
| **Barrel** | `lib/src/core/design_system.dart` exports spacing, palette, **`PdAppCard`**, **`PdPrimaryButton` / `PdSecondaryButton`**, **`pd_async_states`**, **`pd_page_header`**, etc. |
| **Booking wizard today** | Uses raw **`AppBar`**, **`LinearProgressIndicator`**, **`Card`/`ListTile`**, **`TextField`** — **partially** aligned with design system; **`CustomerRecentRequestCard`** uses **`PdAppCard`** + **`PdPrimaryButton`**. |
| **Theme** | `app/theme.dart`, **`pdScreenPadding`**, Bengali **`bn_BD`** default in `app.dart`. |

### 1.9 Tests

| Finding | Detail |
|--------|--------|
| **Existing** | `test/widget_test.dart`, `otp_auth_test.dart`, `animal_form_validators_test.dart`, `provider_list_query_test.dart`. |
| **Gap** | **No** dedicated tests for **`BookingWizardScreen`**, **`ServiceRequestRepository`**, or **`BookingDraft`** validation. |

### 1.10 Current booking wizard vs M07 required flow (gap analysis)

| Required step (M07) | Current `BookingWizardScreen` |
|---------------------|-------------------------------|
| 1. Service type | Step **2** (order is **animal first**, then type) |
| 2. Animal | Step **1** |
| 3. Area / location | **Free-text `locationText`** only — **no** structured area/`areaId` picker |
| 4. Provider (if applicable) | **Missing** — no optional doctor/technician id in draft or POST body |
| 5. Problem | Present (**step 3**) |
| 6. Urgency | **Missing** — `ServiceRequest` has **`urgency`** string in model; **not** in draft or POST |
| 7. Preferred time | Present (**step 6**); required only for `ONLINE_CONSULTATION_LATER` in validation |
| 8. Review | Present (**step 7**) |
| 9. Submit | Present |
| 10. Success page | **Missing** — **`context.pop()`** + SnackBar after submit |
| **Extra** | Optional **description** step — not listed in M07 numbered list but acceptable as sub-step or merged |

**Service types in code:** `DOCTOR_HOME_VISIT`, `EMERGENCY_DOCTOR`, `AI_SERVICE`, `ONLINE_CONSULTATION_LATER` — labels in **Bengali** (`ServiceRequestType.labelBn`). **AI** label is *AI সেবা* (maps to product “AI technician service”).

**Emergency / online UX:** No dedicated **emergency warning** banner in wizard; emergency type uses same location rules as home visit.

---

## 2. Existing files / modules (inventory)

| Area | Key paths |
|------|-----------|
| Router | `lib/src/app/router.dart`, `navigation_keys.dart`, `router_error_screen.dart` |
| Home shell | `lib/src/features/home/home_shell_screen.dart`, `customer_home_screen.dart`, `widgets/*` |
| Service requests | `lib/src/features/service_requests/presentation/booking_wizard_screen.dart`, `service_requests_tab_screen.dart` (includes **detail** screen class) |
| Data / state | `lib/src/features/service_requests/data/service_request_repository.dart`, `service_request_model.dart`, `service_category_repository.dart`, `lib/src/features/service_requests/application/service_requests_providers.dart` |
| Animals | `lib/src/features/animals/**` |
| Providers | `lib/src/features/providers/**` |
| Core network | `lib/src/core/network/api_client.dart`, `dio_provider.dart`, `lib/src/core/config/app_config.dart` |
| Session | `lib/src/features/session/application/session_notifier.dart`, `lib/src/core/storage/token_storage.dart` |
| Design system | `lib/src/core/design_system.dart`, `widgets/pd_*.dart`, `app/theme.dart`, `screen_padding.dart` |

---

## 3. Proposed files to create / update (implementation phase — not in this task)

| Action | Path | Purpose |
|--------|------|---------|
| **Update** | `lib/src/features/home/home_shell_screen.dart` | Replace **`RequestsTabPlaceholderScreen`** with **`ServiceRequestsTabScreen`**. |
| **Update** | `lib/src/features/service_requests/presentation/booking_wizard_screen.dart` | Reorder steps; add urgency, optional provider, area UI, emergency banner; optional **`Pd*`** widgets — or split into smaller widgets under `presentation/widgets/booking/`. |
| **Create** (optional) | `lib/src/features/service_requests/presentation/booking_success_screen.dart` | Dedicated success screen route **or** full-screen dialog after submit. |
| **Create** (optional) | `lib/src/features/service_requests/presentation/widgets/*.dart` | Step tiles, progress header, emergency alert, area selector, urgency chips — **modular** extraction from wizard. |
| **Update** | `lib/src/features/service_requests/application/service_requests_providers.dart` | Extend **`BookingDraft`** + notifier setters (provider ids, urgency, area ids, emergency flags). |
| **Update** | `lib/src/app/router.dart` | Register success route **and/or** `extra` for submitted request id. |
| **Update** | `lib/src/features/home/presentation/customer_home_screen.dart` | Optional: pass **`extra`/query** when opening booking for **AI** / **emergency** / **online** to pre-fill service type. |
| **Update** | `docs/MOBILE_API_INTEGRATION_MAP.md` | Only if new query params or routes — **traceability**. |
| **Add** | `test/booking_*_test.dart` | Validators / draft / repository mapping tests. |

**Explicit:** Do **not** modify `features/auth/doctor/**`, `features/home/doctor/**`, or doctor routes unless fixing an unrelated bug (out of scope).

---

## 4. Data model / DTO plan

### 4.1 Existing runtime models

- **`ServiceRequestType`**, **`ServiceRequestStatus`**, **`ServiceRequest`**, **`ServiceCategoryOption`** — `service_request_model.dart`. Response includes **`areaId`**, **`villageId`**, **`urgency`**, **`isEmergency`**, **`assignedDoctorId`**, **`assignedTechnicianId`**.

### 4.2 Extend `BookingDraft` (client-only)

Proposed fields (implementation validates against **existing** API acceptance — **no backend changes**):

| Field | Use |
|-------|-----|
| `urgency` | `String?` or small enum matching API allowed values — **confirm** against live/mobile OpenAPI or web handler **read-only** audit |
| `preferredDoctorId` / `preferredTechnicianId` | Optional **preference** only if API accepts; else **omit** from POST and keep UI as “note” in `description` **or** skip provider id until API documents it |
| `areaId` / `villageId` | If POST accepts — pair with area selector; else keep **`locationText`** as primary |
| `isEmergency` / `emergencyNotes` | For **EMERGENCY_DOCTOR** — set `isEmergency: true` if API supports on create |

**Risk reduction:** Start by extending **`create` body** only with fields **already** documented or observed in `pranidoctor-web` mobile route handler (repo audit **without** editing backend). If a field is rejected, **gate** it behind version check or remove from payload.

### 4.3 Submit mapping

- Keep **`serviceCategoryId`** resolution via **`serviceCategoriesProvider`** + **`ServiceRequestType.slug`** (current pattern).
- Append optional keys to the existing `Map<String, dynamic>` in **`_submit`** only when non-null.

---

## 5. UI page / widget plan

| Piece | Description |
|-------|-------------|
| **Wizard shell** | Keep single route **`/booking/new`**; **PageView** + **LinearProgressIndicator** (or determinate step **n/total**). |
| **Step 1 — Service type** | Four options with Bengali labels; if **EMERGENCY_DOCTOR**, show **inline warning** (`AlertBanner` / `Material` + warning colors from theme). |
| **Step 2 — Animal** | Reuse list pattern from current **`_AnimalStep`**; link “পশু যোগ করুন” → **`/animals`** form route if exists **or** switch to animals tab via callback (shell has no `goBranch` — prefer **`context.push` animal form** if routed). |
| **Step 3 — Area / location** | **Phase A:** Improve UX with **dropdown** of known areas (reuse **same slugs/ids** as provider filter, localized Bengali labels) + **optional** village text; **Phase B:** Free-text `locationText` always available for nuance. |
| **Step 4 — Provider (conditional)** | Show **only** when type implies doctor/tech preference (e.g. home visit / AI): **“পছন্দের প্রদানকারী (ঐচ্ছিক)”** → **`push`** finder list with **`extra`** return **provider id + kind**, or compact embedded list via **`ProviderFinderRepository`** with filters. **Skip** for online placeholder / minimal emergency path if product prefers speed. |
| **Step 5 — Problem** | Current problem field + keep optional description (collapsed or same step). |
| **Step 6 — Urgency** | Segmented control / chips (Bengali labels, e.g. সাধারণ / দ্রুত / জরুরি) — map to API string. |
| **Step 7 — Preferred time** | Text field or date/time picker **when** product wants structured input; keep Bengali hints. |
| **Step 8 — Review** | Summary rows; **show emergency warning** again if applicable. |
| **Step 9 — Success** | New **full-screen** success with illustration/icon, request id short text, CTA **“অনুরোধ দেখুন”** → pop to **`ServiceRequestsTabScreen`** or **`go`** detail **`/service-requests/:id`**. |

**Online consultation:** Wizard already includes **`ONLINE_CONSULTATION_LATER`**; home card remains **placeholder** SnackBar **or** deep-links to wizard with that type selected — **no** video/session implementation.

---

## 6. API integration plan

| Endpoint | Already in client? | M07 action |
|----------|-------------------|------------|
| `POST /api/mobile/service-requests` | Yes | Extend body keys cautiously; handle validation errors via **`ServiceRequestApiException`**. |
| `GET /api/mobile/service-requests` | Yes | Wire tab via shell fix; optional pagination later. |
| `GET /api/mobile/service-requests/:id` | Yes | Success screen may navigate here. |
| `PATCH .../cancel` | Yes | No change required for M07 booking flow. |
| `GET /api/mobile/service-categories` | Yes | Keep pre-submit resolution. |

**No new endpoints** assumed.

---

## 7. Routing plan

| Route | Change |
|-------|--------|
| `/booking/new` | Keep; optional **query**: `serviceType`, `from=home` for analytics-free prefill. |
| `/booking/success` | **Optional** new route with **`extra`: `ServiceRequest` or `requestId`** — cleaner than stacking dialogs. |
| `/service-requests/:id` | Unchanged. |

**Redirect:** Authenticated users only (existing global redirect).

---

## 8. State management plan (existing pattern)

- **`NotifierProvider<BookingDraftNotifier, BookingDraft>`** — extend mutators; **`reset()`** on wizard open (already in `initState`).
- **`serviceRequestsListProvider`** — **`invalidate`** after successful create (already).
- **`FutureProvider`** / **`AsyncNotifier`** for categories — unchanged.
- Optional: **`family`** `StateProvider` for wizard **step index** only if extracting logic from `PageController` — **not required** if widget stays local.

---

## 9. Validation rules

| Step | Rule |
|------|------|
| Service type | Required |
| Animal | Required; must exist in **active** list |
| Location | **Required** when type ∈ {home visit, emergency, AI service} — **`locationText` and/or `areaId`** per agreed payload |
| Provider | Optional — block submit only if partially filled (invalid id) |
| Problem | Required (non-empty trim) |
| Urgency | Required if API mandates; else default **“NORMAL”** string |
| Preferred time | Required for **`ONLINE_CONSULTATION_LATER`**; optional otherwise |
| Review | Run **`_validateAll`** before API call |

---

## 10. Loading / error / empty state rules

| Context | Rule |
|---------|------|
| **Animals list** | Keep loading spinner; empty → Bengali CTA to add animal; error → retry message |
| **Service categories** | On submit failure to load → SnackBar (existing); **block submit** until resolved |
| **Submit** | Button disabled + **small progress** on **`FilledButton`** (existing pattern on review) |
| **Provider picker** | Reuse list **async** patterns from doctor/technician screens (`PdAsyncStates` where applicable) |
| **Success** | No spinner; clear draft |

---

## 11. Test plan (Flutter)

| Test | Scope |
|------|-------|
| **Unit** | `BookingDraft` + validation helpers (urgency, location-required-by-type) |
| **Unit** | `ServiceRequestType.slug` → category mapping contract (mock categories list) |
| **Widget** | One smoke test: wizard renders first step with **pump** + optional tap next |
| **Repository** | Optional mock **`Dio`** — POST body shape (if team adds integration-style tests) |

Commands: `flutter analyze`, `flutter test` (per `MOBILE_PAGE_TASK_INDEX.md`).

---

## 12. Exact implementation checklist

- [x] **Shell:** Replace **`RequestsTabPlaceholderScreen`** with **`ServiceRequestsTabScreen`** in **`home_shell_screen.dart`**.
- [x] **Reorder wizard steps** to: service type → animal → area/location → optional provider → problem (± description) → urgency → preferred time → review → submit.
- [x] **Emergency UX:** Prominent warning when **EMERGENCY_DOCTOR** card is shown; confirmation dialog before submit for emergency paths; **`isEmergency`** not in POST (strict schema).
- [x] **Area selector:** Curated list + text fallback; **`locationText`** only on POST (no `areaId`/`villageId` without validated IDs).
- [x] **Provider step:** Inline list from finder APIs; preference stored in **`description`** text (no provider-id POST fields).
- [x] **Urgency:** UI + merged **`description`** line (`জরুরিতা: …`).
- [x] **Success screen:** Dedicated **`/booking/success`** + navigation actions.
- [x] **Design system:** **`PdAppCard`**, **`PdTextField`**, spacing tokens on wizard surfaces.
- [x] **Home entry:** **`?preset=`** on booking route for emergency, home visit, AI, online.
- [x] **Online consultation:** Placeholder type only — wizard + **`preferredTime`** required by API.
- [x] **Tests:** `booking_submit_helpers_test.dart`; **`flutter analyze`** / **`flutter test`** green.
- [x] **Docs:** **`MOBILE_API_INTEGRATION_MAP.md`** — M07 note for `/booking/success` + `preset` query.

---

## 13. Explicit non-goals

- **No doctor-side workflow** changes (doctor login/home, doctor APIs).
- **No backend / `pranidoctor-web` changes** in this task stream.
- **No payment / billing** implementation.
- **No real online consultation** (video/chat/scheduling server) — **placeholder + wizard type only**.
- **No unrelated UI redesign** of home, animals, or tutorials beyond thin wiring for booking entry points.
- **No** replacement of **Riverpod** / **go_router** stack.

---

## 14. Summary for implementers

**What works today:** Repositories and enums align with mobile API map; **booking wizard** and **request detail/cancel** are largely implemented; **recent requests** on home are wired.

**What blocks product parity:** **Requests tab placeholder** in shell; wizard **step order** vs spec; missing **urgency**, **provider**, structured **area**, **emergency** emphasis, and **success** screen; **home → AI** opens finder instead of **AI service booking** flow.

**Strategy:** Fix shell first (low risk), then extend **`BookingDraft`** and wizard steps incrementally, **feature-flag** optional POST fields until payload compatibility is verified **against existing API behavior** (read-only verification, no backend edits).
