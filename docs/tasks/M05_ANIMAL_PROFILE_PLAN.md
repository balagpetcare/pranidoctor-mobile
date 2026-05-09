# Task M05 — Animal Profile List / Add / Edit / Detail

**Product:** Prani Doctor (Animal Doctors) — Bangladesh-first veterinary mobile app.  
**Repo:** `pranidoctor_mobile` (local: `D:\PraniDoctor\pranidoctor_mobile`).  
**Domain:** https://pranidoctor.com/  
**Status:** **Implementation completed** (2026-05-09) — shell wired to real animals tab; list/detail/form polished; validators + tests added. See **§12 Implementation Completed** below.

**Isolation:** Mobile app only. Do not scope BPA/WPA, Quarbani 2026, or other products.

**Depends on:** M01 (design system), M02 (shell / navigation), M03 (OTP + JWT), M04 (customer home shortcuts).  
**Related docs:** `docs/ANIMAL_PROFILE_PLAN.md` (historical task card + some drift vs code), `docs/MOBILE_API_INTEGRATION_MAP.md`, `docs/MOBILE_UI_DESIGN_SYSTEM.md`, `docs/tasks/M04_CUSTOMER_HOME_PAGE_PLAN.md`.

---

## 1. Current audit findings (exact file paths)

### 1.1 Animal / customer feature code (present)

| Path | Role |
|------|------|
| `lib/src/features/animals/data/animal_profile_model.dart` | `AnimalProfile` + enums (`AnimalType`, `Gender`, `AnimalCategory`, `PregnancyStatus`). Maps API camelCase JSON. |
| `lib/src/features/animals/data/animal_profile_repository.dart` | `AnimalProfileRepository`: `list`, `getById`, `create`, `update`, `deactivate`; unwraps `{ ok, data }`; Bengali `AnimalApiException` messages. |
| `lib/src/features/animals/application/animals_providers.dart` | `animalRepositoryProvider`, `animalsListProvider` (`AsyncNotifier` + `includeInactive`), `animalDetailProvider` (`FutureProvider.family`). |
| `lib/src/features/animals/presentation/animals_tab_screen.dart` | Nested `Navigator` intended as tab root → `AnimalListScreen`. |
| `lib/src/features/animals/presentation/animal_list_screen.dart` | List UI: `AppBar`, `PopupMenu` (inactive toggle), `RefreshIndicator`, `AnimalCard`, FAB **যোগ করুন**, local `_EmptyBody` / `_ErrorBody`. |
| `lib/src/features/animals/presentation/animal_form_screen.dart` | Create + edit: `AnimalFormScreen.create()` / `.edit(animalId:)`; form fields + `_buildCreateBody` / `_buildPatchBody`; uses `animal_labels.dart`. |
| `lib/src/features/animals/presentation/animal_detail_screen.dart` | Detail + edit entry + deactivate confirmation; uses `animalDetailProvider`. |
| `lib/src/features/animals/presentation/widgets/animal_card.dart` | Card list row: photo, name/tag, type, breed, age/DOB, gender, inactive chip. |
| `lib/src/features/animals/presentation/widgets/animal_photo_placeholder.dart` | `Image.network` when `http(s)` URL else themed icon placeholder. |
| `lib/src/features/animals/presentation/widgets/animal_labels.dart` | Bengali labels for enums (UI). |

### 1.2 Shell / routing — **gap vs screens**

| Path | Finding |
|------|---------|
| `lib/src/features/home/home_shell_screen.dart` | **`IndexedStack` index 1** still builds **`AnimalsTabPlaceholderScreen()`**, not **`AnimalsTabScreen`**. So the **“আমার পশু”** tab shows the M02 placeholder; **`AnimalListScreen` is not reachable from the shell** despite existing implementation. |
| `lib/src/features/home/presentation/customer_shell_tab_placeholders.dart` | `AnimalsTabPlaceholderScreen` — Bengali placeholder copy (“প্লেসহোল্ডার”). |
| `lib/src/features/home/presentation/customer_home_screen.dart` | `onOpenAnimalsTab` switches shell index to **1** (animals tab) — still opens placeholder until shell is wired. |
| `lib/src/app/router.dart` | **No** `GoRoute` for `/animals` or nested `/home/animals/*`. Animals flow is designed to live **inside** the shell tab (see M04 plan: prefer tab index over duplicate top-level routes). |

### 1.3 Cross-feature consumers (must stay compatible)

| Path | Finding |
|------|---------|
| `lib/src/features/service_requests/presentation/booking_wizard_screen.dart` | Imports `animals_providers.dart`; uses **`animalsListProvider`** in `_AnimalStep` and review step. Expects same provider contract after M05 shell wiring. |
| `lib/src/features/providers/presentation/widgets/provider_filter_panel.dart` | Imports `animal_profile_model.dart` for `AnimalType` filter labels. |

### 1.4 Core: network, auth, config

| Path | Finding |
|------|---------|
| `lib/src/core/network/dio_provider.dart` | Shared `Dio`: `AppConfig.apiBaseUrl`, JSON headers; interceptor injects **`Authorization: Bearer`** from `TokenStorage`; **401** → `signOut` + `context.go(LoginEntryScreen.routePath)`. |
| `lib/src/core/network/api_client.dart` | **`get` / `post` / `patch`** (no `delete` — not required; deactivate uses PATCH). |
| `lib/src/core/config/app_config.dart` | `API_BASE_URL` via `--dart-define`. |
| `lib/src/core/storage/token_storage.dart` | Secure storage for access (and refresh) token — used by Dio. |
| `lib/src/features/session/application/session_notifier.dart` | `signInCustomer(accessToken)`, `hydrateFromStorage`, `signOut`, `signInGuest` (guest bypasses JWT — animals API will 401 until real OTP sign-in). |

### 1.5 Design system & reusable widgets (available for M05 polish)

| Path | Finding |
|------|---------|
| `lib/src/app/theme.dart` | `AppTheme` Material 3 light/dark. |
| `lib/src/app/app.dart` | Default **`locale: Locale('bn', 'BD')`** + `en_US` supported. |
| `lib/src/app/screen_padding.dart` | `pdScreenPadding`, `pdReadableMaxWidth` — already used on animal screens. |
| `lib/src/core/design_system.dart` | Barrel: spacing, radii, `pd_app_card`, **`pd_async_states`** (`PdLoadingBody`, `PdErrorBody`, `PdEmptyState`), buttons, page header. |
| `lib/src/core/widgets/pd_async_states.dart` | **Not yet used** by `animal_list_screen.dart` (uses ad-hoc `_EmptyBody` / `_ErrorBody` / `CircularProgressIndicator`). Strong candidate for **visual consistency** in M05. |
| `lib/src/core/widgets/pd_text_field.dart` | Shared field styling — animal form currently uses raw `TextFormField` / `InputDecoration`. |
| `lib/src/core/widgets/pd_page_header.dart` | Optional alignment for sub-pages if moving away from default `AppBar` only. |

### 1.6 Tests & dependencies

| Path | Finding |
|------|---------|
| `pubspec.yaml` | `flutter_riverpod`, `dio`, `go_router`, `flutter_secure_storage`, `shared_preferences`, `intl` — **no** `riverpod_generator`, **no** form_builder. |
| `test/otp_auth_test.dart` | Exists; **no** dedicated `test/*animal*` at time of audit. |

### 1.7 Legacy / duplicate planning doc

| Path | Note |
|------|------|
| `docs/ANIMAL_PROFILE_PLAN.md` | Mixed **historical audit** and **checkboxes** that **do not match** current `home_shell_screen.dart` (still placeholder tab). Use **this M05 doc** as the task source of truth; reconcile or trim `docs/ANIMAL_PROFILE_PLAN.md` in a later docs-only pass if desired. |

---

## 2. Existing architecture summary

- **Layers:** Feature-first under `lib/src/features/animals/` — **data** (repository + model), **application** (Riverpod 3 `AsyncNotifier` / `FutureProvider`), **presentation** (screens + widgets).
- **HTTP:** `ApiClient` → `Dio` from `dioProvider`; JSON envelope `{ ok, data }` handled in repository.
- **Navigation:** **GoRouter** for app-level routes; **animals sub-stack** intended as **nested `Navigator`** in `AnimalsTabScreen` so list/detail/form do not require new top-level `GoRoute` entries (aligns with `docs/tasks/M04_CUSTOMER_HOME_PAGE_PLAN.md`).
- **Locale:** Bengali-first app locale; animal screens already use **Bangla** labels and messages in the audited files.

---

## 3. Screens / routes to add or update

| Item | Action |
|------|--------|
| `HomeShellScreen` | **Replace** `AnimalsTabPlaceholderScreen` with **`AnimalsTabScreen`** (or wrap equivalent) at **IndexedStack** child index **1**. |
| `AnimalsTabScreen` | **Review** nested `Navigator`: current `onGenerateRoute` **always** returns `AnimalListScreen` regardless of `settings.name` — acceptable MVP if all pushes use **root `MaterialPageRoute`** from list/detail; **optional hardening** later for named sub-routes inside tab. |
| `AnimalListScreen` / `AnimalDetailScreen` / `AnimalFormScreen` | **Polish** per M05 (design system async widgets, form sections, fields below); **no new route names in GoRouter** unless product explicitly needs deep links (`/animals/:id`) — if added, document conflict risk with nested navigator. |
| `router.dart` | **No change required** for baseline M05 if shell-only entry is enough. |

---

## 4. Data models / repositories / services / providers

| Component | File | M05 notes |
|-----------|------|-----------|
| Model | `animal_profile_model.dart` | Already maps server fields. **Gap:** no **`color`**; no **`vaccinationNotes`** — see §6 / §7. **`weightKg`** parsed as `String?` from JSON — align create/patch body with API numeric type when wiring weight field. |
| Repository | `animal_profile_repository.dart` | CRUD + deactivate complete for documented paths. **No DELETE** method — deactivate is **`PATCH .../deactivate`** (correct for backend). |
| Providers | `animals_providers.dart` | Sufficient for list + detail; consider **`invalidate`** helpers or a small **mutation notifier** if optimistic UI is added later. |

**New (optional) for implementation phase:**

- **`lib/src/features/animals/presentation/widgets/`** — e.g. `animal_identity_section.dart`, `animal_health_section.dart` (pure layout + controllers passed in) for reusable form sections.
- **Local DTO / form state class** (optional) — only if `AnimalFormScreen` grows too large; keep Riverpod as-is unless team prefers `Notifier` for form dirty state.

---

## 5. API endpoint mapping (mobile → repository)

| Expected (product brief) | Implemented in `AnimalProfileRepository` | Response keys used |
|--------------------------|------------------------------------------|----------------------|
| `GET /api/mobile/animals` | `list()` → `GET /api/mobile/animals` + optional `includeInactive=true` | `data.animals` (list) |
| `GET /api/mobile/animals/:id` | `getById(id)` | `data.animal` |
| `POST /api/mobile/animals` | `create(body)` | `data.animal` |
| `PATCH /api/mobile/animals/:id` | `update(id, body)` | `data.animal` |
| DELETE hard delete | **Not used** | Backend uses **soft deactivate**: `PATCH /api/mobile/animals/:id/deactivate` → `deactivate(id)` |

**Auth:** Bearer JWT via `TokenStorage` (after OTP verify / `signInCustomer`). **Guest session** (`signInGuest`) has no token — animals calls will fail with **401** (handled globally → login).

---

## 6. Mock / placeholder fallback plan (if API unavailable)

**Baseline:** Repository throws `AnimalApiException` / `DioException`; UI already shows error + retry on list and detail.

| Scenario | Plan |
|----------|------|
| Local dev server down | Keep **real repository**; user sets `API_BASE_URL`; show existing Bengali error + retry. |
| Automated tests / CI | Prefer **`ProviderScope` overrides**: `animalRepositoryProvider` → fake returning fixed `AnimalProfile` list; **do not** ship a second production client unless product requests offline mode. |
| Missing endpoint in a fork | Document in PR; short-term **mock repository** behind same provider interface only in `test/` or debug flag (not default). |

**Photo upload not ready:** Keep **`AnimalPhotoPlaceholder`** + optional URL field (or read-only placeholder copy). No binary upload in M05 unless server contract exists.

**Color / vaccination (no API field today):** **UI-only** sections — e.g. disabled `TextField` with helper **“শীঘ্রই যুক্ত হবে”**, or static `ListTile` subtitle. **Do not** send unknown JSON keys to **`POST`/`PATCH`** (backend schemas are **`.strict()`** — extra keys fail validation). Optional interim: append human-readable lines into **`notes`** *only if product approves* (risk: pollutes clinical notes).

---

## 7. Validation rules (client-side, Bengali messages)

Align with existing `AnimalFormScreen` + extend when adding fields.

| Rule | Create | Edit (patch) |
|------|--------|----------------|
| `animalType` | Required (`DropdownButtonFormField` validator). | Optional change via dropdown. |
| Name / tag | **At least one** non-empty (trim); snackbar **নাম অথবা ট্যাগ লিখুন** if both empty. | `name` required min length on server for patch optional fields — follow API: patch sends `name` trimmed. |
| `dateOfBirth` vs `ageYears` | **Mutually exclusive** (UI switch); age **0–80** int; DOB via date picker ≤ today. | Same; patch body sets null for cleared side (see `_buildPatchBody`). |
| `photoUrl` | If set: valid **http/https** URI (create path validates). | Patch allows null to clear (trim empty → null). |
| `weightKg` | **When implemented:** positive number, max consistent with server (e.g. **99999**); send **number** in JSON, not string. | Same; nullable to clear. |
| `gender` / `pregnancyStatus` | Optional enums. | Optional / nullable. |
| `notes` | Max length — align with server (**8000** chars on web schema); client trim. | Same. |

**Form `validate()`:** Currently relies on dropdown validator + snackbars for XOR name/tag — consider moving XOR checks into **`FormField` / custom validator** for accessibility and inline errors during M05 polish.

---

## 8. UI component reuse plan

| Goal | Approach |
|------|----------|
| Loading / empty / error consistency | Replace ad-hoc bodies in `animal_list_screen.dart` with **`PdLoadingBody`**, **`PdEmptyState`**, **`PdErrorBody`** from `pd_async_states.dart` (Bangla `title` / `subtitle` / `retryLabel`). |
| Text fields | Gradually align with **`PdTextField`** where it does not fight `DropdownButtonFormField` patterns. |
| Cards | Optionally wrap list rows with **`PdAppCard`** if it matches list visual spec from `MOBILE_UI_DESIGN_SYSTEM.md`; current `Card` + `InkWell` is acceptable if tokens match. |
| Section headers inside long form | Reuse **`customer_home_section_title.dart`** pattern or small **`Text` + spacing** consistent with M04 section titles — extract **`PdFormSection`** (title + optional subtitle + child) in `lib/src/core/widgets/` only if reused ≥2 features. |
| FAB / primary CTA | Cross-check **`pd_buttons.dart`** for tonal / filled conventions. |

**Bengali-first:** All new user-visible strings in **Bangla**; keep technical logs in English if needed.

---

## 9. Testing plan

| Level | Scope |
|-------|--------|
| `flutter analyze` | Whole package; zero new warnings. |
| `flutter test` | Existing tests must pass. |
| **New widget tests** (recommended) | `AnimalFormScreen`: name+tag empty shows error path; age out of range; valid minimal create body (mock repository). |
| **Provider test** | `AnimalsListNotifier.setIncludeInactive` toggles and refetches (mock repo). |
| **Manual** | Shell tab → list → detail → edit → back; FAB add; deactivate; pull-to-refresh; inactive toggle; booking wizard still lists animals after invalidate. |
| **Auth** | With OTP: token present → list loads; after sign-out → redirect to login on 401. |

---

## 10. Risk notes & files that must not be touched

**Risks**

- **Nested `Navigator` vs `Navigator.push`:** Pushes from `AnimalListScreen` use the nearest `Navigator`. After shell wiring, verify pops return to list inside tab and **do not** pop the entire `HomeShellScreen` by mistake.
- **`signInGuest`:** Animals API on real backend **requires JWT** — QA must use real OTP flow for animal CRUD.
- **Strict API bodies:** Do not send **`color` / `vaccination`** keys until backend exposes them.
- **`weightKg` type:** JSON must be numeric for create/patch per server Zod (`z.coerce.number()` / number union).

**Do not touch (this task)**

- **`pranidoctor-web`** backend repo — **no** server/schema changes from M05 mobile task.
- Doctor-only flows unless a shared regression is found (isolate fixes).
- Unrelated shell tabs (requests/knowledge/profile) except incidental import cleanup.

**Safe to touch for M05 implementation**

- `lib/src/features/home/home_shell_screen.dart` (swap animals tab widget).
- `lib/src/features/animals/**` only as needed for UI/validation/tests.

---

## 11. Step-by-step implementation checklist

1. **Wire shell:** In `home_shell_screen.dart`, replace **`AnimalsTabPlaceholderScreen`** with **`AnimalsTabScreen`** (import from `features/animals/presentation/animals_tab_screen.dart`).
2. **Smoke test navigation:** From tab: list → detail → edit → back; FAB → create → pop; home shortcut **আমার পশু** still selects index 1.
3. **Design system pass — list:** Swap loading/empty/error for **`PdLoadingBody` / `PdEmptyState` / `PdErrorBody`**; verify FAB colors vs `AppTheme` / design doc.
4. **Form — `weightKg`:** Add field + validation; send **num** in JSON on create/patch; show on detail (`AnimalProfile.weightKg` already displayed on detail when present).
5. **Form — color / vaccination:** Add **read-only placeholder** UI blocks (Bangla helper text); **no** API keys until backend supports them.
6. **Form — reusable sections:** Extract 2–4 private widgets or files under `widgets/` (`identity`, `health`, `photo`) without changing repository contracts.
7. **Optional — `ageMonths`:** If API returns months, show on detail; optional field on form only if product requires.
8. **Validators:** Prefer inline `FormField` errors for name/tag XOR instead of snackbar-only.
9. **Booking wizard regression:** Run through wizard step 1 (animal selection) after provider invalidation from create/edit/deactivate.
10. **Tests:** Add `test/animal_form_test.dart` (or similar) with repository mock; run `flutter test` + `flutter analyze`.
11. **Docs:** Update `docs/MOBILE_PAGE_TASK_INDEX.md` M05 acceptance checkboxes when done; optionally add one line to `MOBILE_API_INTEGRATION_MAP.md` if request/response shapes change.

---

## Appendix A — Field coverage vs product brief

| Product field | Mobile today | M05 action |
|---------------|--------------|------------|
| Animal type | Yes (`animalType`) | Kept; sectioned form |
| Name/tag | Yes | **Validators** (`AnimalFormValidators` + inline `Form`) |
| Breed | Yes | — |
| Age / DOB | Yes (switch) | — |
| Gender | Yes | — |
| Weight | Form + detail + card | **Implemented** (`weightKg` as number in JSON) |
| Color | Placeholder only | **Implemented** (UI-only) |
| Health notes | `notes` | Label **স্বাস্থ্য নোট** |
| Vaccination placeholder | N/A | **Implemented** (UI-only) |
| Photo | URL + placeholder | Kept |

---

## 12. Missing API / Placeholder Notes

| Area | Mobile behaviour | Backend / API |
|------|------------------|---------------|
| **রং (color)** | Form shows read-only `AnimalServerFieldPlaceholder`; detail shows fixed Bangla copy that the value is not stored yet. **No JSON keys** sent on POST/PATCH (strict schemas would reject unknown keys). | No `color` field in mobile animal create/patch schemas today. |
| **টিকাদান (vaccination)** | Form + detail use informational placeholders; user may use **স্বাস্থ্য নোট** (`notes`) until a dedicated field exists. | No separate vaccination field in mobile animal API today. |
| **Photo** | Optional `photoUrl` string (http/https) only; `AnimalPhotoPlaceholder` for display / missing image. | No multipart upload in this task. |
| **Hard DELETE** | Not offered. **নিষ্ক্রিয়** uses existing `PATCH /api/mobile/animals/:id/deactivate`. | Matches backend soft-deactivate pattern (no DELETE required). |
| **Mock fallback** | **Not used in production code.** Repository remains the real `AnimalProfileRepository`; failures surface as error UI + retry. Tests may override providers. | N/A |

---

## 13. Implementation Completed (2026-05-09)

### Files created

| File | Purpose |
|------|---------|
| `lib/src/features/animals/presentation/animal_form_validators.dart` | Pure validation helpers + constants (`notesMaxChars`, `weightKgMax`, etc.). |
| `lib/src/features/animals/presentation/widgets/animal_form_section.dart` | Reusable Bangla section header + subtitle + child. |
| `lib/src/features/animals/presentation/widgets/animal_server_field_placeholder.dart` | Read-only callout for server-missing fields (color, vaccination copy). |
| `test/animal_form_validators_test.dart` | Unit tests for validators. |

### Files updated

| File | Change |
|------|--------|
| `lib/src/features/home/home_shell_screen.dart` | **“আমার পশু”** tab: `AnimalsTabPlaceholderScreen` → **`AnimalsTabScreen`** (nested navigator + list). |
| `lib/src/features/animals/presentation/animal_list_screen.dart` | **`PdLoadingBody`**, **`PdErrorBody`**, **`PdEmptyState`**; removed ad-hoc empty/error widgets. |
| `lib/src/features/animals/presentation/animal_detail_screen.dart` | **`PdLoadingBody` / `PdErrorBody`**; **স্বাস্থ্য নোট** label; **রং** + **টিকাদান** placeholders; deactivate unchanged. |
| `lib/src/features/animals/presentation/animal_form_screen.dart` | Sectioned form (`AnimalFormSection`); **ওজন** with numeric JSON; **`PdTextField`** + shared validators; color/vaccination placeholders; edit load/error via design-system async widgets; patch body omits empty `name`; `weightKg` as number or null. |
| `lib/src/features/animals/presentation/widgets/animal_card.dart` | Optional **ওজন** line in subtitle meta. |

### API used (unchanged repository contract)

- `GET /api/mobile/animals` (+ optional `includeInactive=true`)
- `GET /api/mobile/animals/:id`
- `POST /api/mobile/animals`
- `PATCH /api/mobile/animals/:id`
- `PATCH /api/mobile/animals/:id/deactivate` (soft deactivate; **no** `DELETE`)

### Placeholder / mock notes

- **No production mock repository:** all screens call **`AnimalProfileRepository`** via Riverpod as before.
- **Color & vaccination:** UI-only placeholders; documented in **§12**.
- **Photo:** URL field + placeholder widget only (no upload pipeline).

### Remaining backend dependencies

- Customer **JWT** in `TokenStorage` (OTP flow) for successful animal CRUD against a running Prani Doctor API (`API_BASE_URL`).
- Future backend fields (**`color`**, **`vaccinationNotes`**, etc.) require schema + mobile model/repository updates before persisting.

### Manual QA checklist

- [ ] Login with OTP → open **আমার পশু** tab → list loads or error + retry.
- [ ] Empty list → **PdEmptyState** + CTA opens add form.
- [ ] FAB **যোগ করুন** → create form → validation (name/tag, weight, notes length, photo URL).
- [ ] Submit create → returns to list → new card appears after refresh.
- [ ] Tap card → detail → **সম্পাদনা** → edit form loads (**PdLoadingBody** briefly).
- [ ] Detail: **স্বাস্থ্য নোট**, **টিকাদান** placeholder, **রং** copy, photo placeholder / network image.
- [ ] Active animal → **প্রোফাইল নিষ্ক্রিয় করুন** → confirm → pops to list; inactive visible when menu toggle on.
- [ ] **Booking wizard** step 1 still lists animals after create/edit.
- [ ] Pull-to-refresh on list.

---

## 14. Verification (automated checks)

**Project root:** `D:\PraniDoctor\pranidoctor_mobile`

### Commands run (first pass)

| Step | Command | Result |
|------|---------|--------|
| 1 | `dart format .` | **Pass** — 6 files reformatted (M05-related Dart only; 85 files scanned). |
| 2 | `flutter analyze` | **Pass** — no issues found. |
| 3 | `flutter test` | **Pass** — 16 tests (including `animal_form_validators_test.dart`, `otp_auth_test.dart`, `widget_test.dart`). |

**Files touched by `dart format` (first pass only):**

- `lib/src/features/animals/presentation/animal_detail_screen.dart`
- `lib/src/features/animals/presentation/animal_form_screen.dart`
- `lib/src/features/animals/presentation/animal_list_screen.dart`
- `lib/src/features/animals/presentation/widgets/animal_form_section.dart`
- `lib/src/features/animals/presentation/widgets/animal_server_field_placeholder.dart`
- `test/animal_form_validators_test.dart`

### Commands run (second pass, after format)

| Step | Command | Result |
|------|---------|--------|
| 1 | `dart format .` | **Pass** — 0 files changed (already formatted). |
| 2 | `flutter analyze` | **Pass** — no issues found. |
| 3 | `flutter test` | **Pass** — 16 tests, all passed. |

### Remaining unrelated issues

- **None observed** in this repo for the commands above. No analyzer errors or test failures outside M05 scope were encountered.

### Known limitations (unchanged)

- **রং / টিকাদান:** UI placeholders only; not persisted via animal API (see §12).
- **Photo:** URL string only; no in-app upload.
- **Guest / no JWT:** animal APIs return **401**; global interceptor signs out and returns to login — QA with real OTP + `API_BASE_URL` pointed at a running server.
- **Nested `Navigator`:** animals stack is inside the bottom tab; no deep-link `GoRoute` for `/animals/:id` unless added later.

### Manual QA steps (recommended before commit)

1. **Open animal list** — After OTP login, bottom nav **আমার পশু** → list or loading state.
2. **Empty state** — With zero animals: `PdEmptyState` copy + **প্রাণি যোগ করুন** CTA.
3. **Add animal** — FAB **যোগ করুন** → form sections → submit valid minimal data (type + name or tag).
4. **View detail** — Tap card → header, photo placeholder/URL image, rows including **স্বাস্থ্য নোট**, placeholders.
5. **Edit animal** — App bar edit → form prefilled → save → back to detail/list refresh.
6. **Validation errors** — Clear both name and tag (submit); invalid weight; notes longer than 8000 characters; bad photo URL — expect inline/snackbar Bengali feedback.
7. **API error state** — Stop server or wrong `API_BASE_URL` → list/detail **PdErrorBody** + **আবার চেষ্টা করুন**; restore server and retry.

---

## Document history

| Date | Author | Change |
|------|--------|--------|
| 2026-05-09 | Cursor agent | M05 audit + consolidated plan (`docs/tasks/M05_ANIMAL_PROFILE_PLAN.md`). |
| 2026-05-09 | Cursor agent | M05 implementation: shell wiring, DS async states, form sections/validators/weight, placeholders, tests, §12–§13. |
| 2026-05-09 | Cursor agent | §14 Verification: `dart format` / `flutter analyze` / `flutter test` ×2 passes; format-only edits to 6 M05 files. |
