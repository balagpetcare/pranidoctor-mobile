# Provider finder — mobile (Task Card 10)

**Task title:** Task Card 10 — Doctor & AI Technician Finder (mobile)  
**Goal:** Customer-facing Flutter MVP to consume web **`/api/mobile/providers/*`** APIs: doctor/technician lists with filters, detail screens, placeholders for call/book/rating, without breaking existing navigation.

**Project:** Prani Doctor (`pranidoctor-mobile`)  
**Related web doc:** `pranidoctor-web/docs/PROVIDER_FINDER_PLAN.md`  
**Final status:** **COMPLETE** (2026-05-09)  
**Last updated:** 2026-05-09 (completion report)

---

## 0. Final completion status

### Final mobile status

- **Delivered:** `lib/src/features/providers/` (data, application, presentation, widgets), **`HomeScreen`** entry points, **`router.dart`** routes, **`ProviderFinderRepository`** + Riverpod.
- **Screens:** doctor list/detail, technician list/detail; loading / empty / error; pull-to-refresh on lists.
- **Filters (UI):** area (demo slug), animal type, home visit, emergency, online consultation (hidden on technician list).
- **Placeholders:** কল / বুক → SnackBar only; rating text when API `rating` is null.

### API endpoints used

Same as web plan §0: `GET /api/mobile/providers/doctors`, `GET …/technicians`, `GET …/doctors/[id]`, `GET …/technicians/[id]`.

### Test / analyze / build (final reproducible)

| Check | Result |
|-------|--------|
| `flutter pub get` | Pass |
| `flutter analyze` | No issues found |
| `flutter test` | All tests passed |
| `flutter build apk --debug` | Succeeded |

### Known limitations

- Customer **JWT** still required from outside the shell login flow.
- Area UI = **Ashulia demo slug** or all; repository strips unknown slugs before HTTP.
- No load-more pagination; no `serviceCategoryId` in filter UI.

### Task Card 10 — changed files (mobile repo, scoped)

| Path |
|------|
| `lib/src/features/providers/` (entire feature tree) |
| `lib/src/app/router.dart` |
| `lib/src/features/home/home_screen.dart` |
| `docs/PROVIDER_FINDER_MOBILE_PLAN.md` |

*Note: `git status` may show other modified files (e.g. animals, shell); the table is **Task Card 10** scope.*

### Next task recommendation

Align with web plan: **customer mobile auth** + token storage, then optional **areas** API + picker.

---

## 1. Mobile audit result

| Area | Finding |
|------|---------|
| **Layout** | `lib/src/app/` (router, theme, padding), `lib/src/core/` (config, network, storage), `lib/src/features/*` per feature (`application/`, `data/`, `presentation/`). |
| **Routing** | `go_router` with provider routes under `/providers/doctors` and `/providers/technicians` (+ nested `:id`). |
| **State** | `flutter_riverpod` v3 (`AsyncNotifierProvider`, `FutureProvider.family`, `NotifierProvider` for filter state). |
| **API** | `ApiClient` + `dioProvider`; `AppConfig.apiBaseUrl` from `--dart-define=API_BASE_URL` (default `http://localhost:3000`). Bearer from `TokenStorage`. |
| **Reference feature** | Animals: `AnimalProfileRepository` + `{ ok, data }` unwrap pattern mirrored in `ProviderFinderRepository`. |
| **Theme** | `AppTheme` (Material 3, Bengali locale in `MaterialApp.router`). |
| **Home** | `HomeScreen` wires “ডাক্তার খুঁজুন” / “AI টেকনিশিয়ান খুঁজুন” to provider list routes. |

---

## 2. Implemented screens

| Screen | Route | Purpose |
|--------|-------|---------|
| **Doctor list** | `/providers/doctors` | Filters + list + pull-to-refresh; tap card → detail. |
| **Doctor detail** | `/providers/doctors/:doctorId` | Full doctor payload from API. |
| **Technician list** | `/providers/technicians` | Filters (no online-consultation row) + list + refresh. |
| **Technician detail** | `/providers/technicians/:technicianId` | Full technician payload. |

**Navigation entry:** `HomeScreen` — “ডাক্তার খুঁজুন” → doctor list; “AI টেকনিশিয়ান খুঁজুন” → technician list (`context.push`). Bottom nav unchanged (four tabs).

---

## 3. API integration notes

| Endpoint | Use |
|----------|-----|
| `GET /api/mobile/providers/doctors` | List with query map from `ProviderListQuery.toQueryParameters()`. |
| `GET /api/mobile/providers/technicians` | Same. |
| `GET /api/mobile/providers/doctors/[id]` | Doctor detail. |
| `GET /api/mobile/providers/technicians/[id]` | Technician detail. |

- **Repository:** `ProviderFinderRepository` — `_coerceQuery` strips unknown `areaSlug` values before HTTP (keeps UI dropdown valid).
- **Models:** `DoctorSummary`, `DoctorDetail`, `TechnicianSummary`, `TechnicianDetail`, `PaginationInfo` in `provider_models.dart`.
- **Query:** `ProviderListQuery` + `withFilters()` (area slug vs id mutual exclusion on model, reset offset on filter change unless `keepOffset` used internally for coerce).
- **Providers:** `provider_finder_providers.dart` — `NotifierProvider` for list filters (`apply` / implied reset via `ProviderListQuery.initial`), list `AsyncNotifier`s, detail `FutureProvider.family`.
- **Auth:** Dio interceptor sends Bearer when present; backend requires **customer JWT** — without token, API returns **401** (error state in lists).

---

## 4. Known limitations

- **Customer login** is still mostly UI-only; real Bearer token is required for provider APIs (same as animals).
- **Area filter** UI only offers **demo slug** `ashulia-union-area` or “all”; unknown slugs are ignored for the HTTP request (state may still hold a bad slug until user clears filters — dropdown displays as “সব”).
- **`serviceCategoryId`** not exposed in filter UI (backend supports it).
- **Pagination “load more”** not implemented; first page only (`limit` default 20).
- **Technicians + online consultation = true** returns empty list (backend behavior).

---

## 5. Test checklist

- [ ] Manual: `flutter run --dart-define=API_BASE_URL=http://10.0.2.2:3000` with valid JWT in secure storage, open doctor/technician lists.
- [ ] Filter combinations (area + animal type + toggles) against seeded demo data (`PRANI_SEED_DEMO=true` on web).
- [x] `flutter analyze` — clean (integration pass).
- [x] `flutter test` — baseline widget test passes.
- [x] `flutter build apk --debug` — succeeds (integration pass).

---

## 6. Changed files (feature + integration)

| Path |
|------|
| `lib/src/app/router.dart` |
| `lib/src/features/home/home_screen.dart` |
| `lib/src/features/providers/data/provider_models.dart` |
| `lib/src/features/providers/data/provider_list_query.dart` |
| `lib/src/features/providers/data/provider_finder_repository.dart` |
| `lib/src/features/providers/application/provider_finder_providers.dart` |
| `lib/src/features/providers/presentation/doctor_list_screen.dart` |
| `lib/src/features/providers/presentation/doctor_detail_screen.dart` |
| `lib/src/features/providers/presentation/technician_list_screen.dart` |
| `lib/src/features/providers/presentation/technician_detail_screen.dart` |
| `lib/src/features/providers/presentation/widgets/provider_filter_panel.dart` |
| `lib/src/features/providers/presentation/widgets/doctor_summary_card.dart` |
| `lib/src/features/providers/presentation/widgets/technician_summary_card.dart` |
| `docs/PROVIDER_FINDER_MOBILE_PLAN.md` |

---

## 7. Integration verification (2026-05-09)

### 7.1 Automated results (this pass)

- `flutter pub get` — OK  
- `flutter analyze` — **No issues found**  
- `flutter test` — **All tests passed**  
- `flutter build apk --debug` — **Succeeded** (exit code 0)

### 7.2 Bugs fixed (this pass)

| Fix |
|-----|
| **Filter panel:** `DropdownButton` `value` must match an item — `_safeAreaSlug` + **repository `_coerceQuery`** so unknown slugs do not crash the widget or hit the API with invalid slugs. |

### 7.3 Code review checklist (static)

| Check | Result |
|-------|--------|
| Call / Book | SnackBar placeholders only; no unfinished workflows. |
| Loading / empty / error | Present on list + detail screens. |
| Existing tabs / shell | Unchanged; provider routes are pushed on top. |

---

## 8. Next task recommendation

1. **Customer auth:** `POST /api/mobile/auth/login` (or equivalent) + persist token so finder and animals work without manual JWT.  
2. **Area picker:** `GET /api/mobile/areas` when available on web, or config-driven slug list.  
3. **Booking / call:** replace snackbars with product flows when backend is ready.

---

## Document history

| Version | Date | Notes |
|---------|------|--------|
| 1.0 | 2026-05-09 | Initial mobile MVP + doc. |
| 1.1 | 2026-05-09 | Integration verification + filter/repository hardening. |
| 1.2 | 2026-05-09 | Task 10 completion | §0 final status + scoped changed-files note. |
