# Mobile location selection fix — plan

**Scope:** `pranidoctor_mobile` only. No backend changes.

## A) Data source (audit)

| Source | Detail |
|--------|--------|
| Districts | Remote `GET /api/mobile/locations/districts` via [LocationRepository](lib/src/features/locations/data/location_repository.dart) → `ApiClient` / Dio. |
| Upazilas | Remote `GET /api/mobile/locations/upazilas?districtId=` |
| Unions | Remote `GET /api/mobile/locations/unions?districtId=&upazilaId=` |
| Local fallback | **None** — no bundled JSON/assets for BD locations in repo. If API fails, show Bengali error + retry only (no invented data). |

## B) Root causes (hypothesis → fix)

1. **`id` JSON type** — If backend sends numeric `id`, `MobileLocationDto.fromJson` cast `as String` throws → entire list fails or partial failure. **Fix:** Coerce id (and optional fields) to `String` safely.
2. **`districtsProvider` autoDispose** — Sheet opens → fetch starts; rapid navigation can dispose/invalidate and **restart** loading, feeling like infinite spinner. **Fix:** Use non–auto-dispose `FutureProvider` + explicit `invalidate` on retry.
3. **`_maybeAutoPickSingleDistrict` in `build`** — Schedules post-frame `setState` from build path; fragile for rebuild loops. **Fix:** One-shot `_bootstrapSelection()` after first frame (hydrate saved guest IDs and/or single district).
4. **Nested picker errors** — `PraniSearchableSelectField` sheet shows generic error + `_error.toString()` as detail in dev (Dio noise). **Fix:** Map errors via `MobileApiEnvelopeException` / `userFacingDioMessageBn`; drop raw exception text from UI; `debugPrint` only.
5. **Timeout copy** — Central mapper used `bnServerUnreachable` for all unreachable types. **Fix:** Dedicated Bengali string for **timeout** types before generic unreachable.
6. **Doctor list vs location** — `/api/mobile/providers/doctors` timeout is independent; `DoctorsListNotifier` watches `homeNetworkDeferProvider` + query only. Location sheet does not watch `doctorsListProvider`. **Fix:** Document; optionally clarify nearby-doctors error copy (already separate widget).
7. **Android** — Add `android:enableOnBackInvokedCallback="true"` on `<application>`.

## C) Implementation checklist

- [x] `network_messages.dart` + `dio_user_message.dart` — timeout string.
- [x] `location_models.dart` — safe id coercion.
- [x] `location_repository.dart` — Dio → `userFacingDioMessageBn` / envelope messages.
- [x] `location_providers.dart` — `districtsProvider`: cache with `FutureProvider` (not autoDispose).
- [x] `guest_location_selection_sheet.dart` — placeholders, retry on district error, bootstrap hydrate / single district, empty-list hints for child dropdowns.
- [x] `prani_searchable_select_field.dart` — mapped error message; optional `emptyListMessage`; no leaking raw error strings.
- [x] `main.dart` — dev-only log `AppConfig.resolvedApiBaseUrl`.
- [x] `AndroidManifest.xml` — predictive back flag.

## D) Acceptance mapping

| # | Verification |
|---|----------------|
| District loads / error + retry | District branch uses `invalidate(districtsProvider)` + Bengali copy |
| Cascading clears | Existing `setState` on parent change; hydrate validates IDs |
| No infinite loading | Timeout-bound Dio + non-stuck provider cache |
| Doctors timeout ≠ location | No shared Future; separate HTTP calls |
| Analyze / test | `flutter analyze`, `flutter test` |

## E) Notes (post-fix)

- Nearby doctors section title updated for API failures; location HTTP remains independent (same Dio client, different endpoints/timeouts).
- `main.dart` logs `resolvedApiBaseUrl` when `kDebugMode` **or** `AppConfig.isDevelopmentEnv`.
