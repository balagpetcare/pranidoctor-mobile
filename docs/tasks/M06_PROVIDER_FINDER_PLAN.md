# Task M06 — Doctor & AI Technician Finder

**Product:** Prani Doctor (Animal Doctors) — Bangladesh-first veterinary mobile app.  
**Repo:** `pranidoctor_mobile` (local: `D:\PraniDoctor\pranidoctor_mobile`).  
**Domain:** https://pranidoctor.com/  
**Status:** **Implemented** (2026-05-09) — landing, lists, unified detail, shared card, repository unified detail + fixtures; see **§0 Implementation summary** below. Earlier sections (§1+) retain planning context.

**Isolation:** Mobile app only. No backend changes. No booking-flow implementation in M06 (placeholders / disabled CTAs only). Do not scope unrelated products.

**Related docs:** `docs/MOBILE_API_INTEGRATION_MAP.md`, `docs/MOBILE_UI_DESIGN_SYSTEM.md`, `docs/PROVIDER_FINDER_MOBILE_PLAN.md` (historical “Task Card 10” completion — some paths/names drift vs current `customer_home_screen.dart`; prefer **this M06 doc** for the next iteration).

**Depends on:** M01 (design system), M02 (shell), M03 (OTP + JWT for authenticated API calls), M04 (customer home entry points).

---

## 0. Implementation summary (2026-05-09)

### 0.1 What was built

- **Landing:** `ProviderFinderLandingScreen` at `/providers` — Bengali intro, name search (applies `ProviderListQuery.nameSearch` to doctor or technician query before navigation), CTAs to doctor/technician lists, emergency placeholder SnackBar.
- **Lists:** `DoctorListScreen` / `TechnicianListScreen` — top search field, `ProviderFilterPanel` (service categories via existing `serviceCategoriesProvider`, area/animal/home visit/emergency/online for doctors, AI technician service filter + online placeholder note for technicians), `ProviderCard`, `PdLoadingBody` / `PdErrorBody` / `PdEmptyState`, pull-to-refresh, client-side name filter on top of API results, client-side refinement for `aiTechnicianService` on technicians when true.
- **Detail:** `ProviderDetailScreen` + thin `DoctorDetailScreen` / `TechnicianDetailScreen` subclasses — badges (fee, availability, home/field, emergency, online, rating placeholders), area lists, bio, **জরুরি সহায়তা** `OutlinedButton` (SnackBar placeholder), primary **সেবা অনুরোধ** SnackBar only (“সেবা অনুরোধ করুন — পরবর্তী ধাপে যুক্ত হবে”).
- **Data:** `ProviderKind`, `ProviderProfile` / `ProviderProfileDetail` (view models from API DTOs), `ProviderFinderRepository.getProviderProfileDetail` (tries `GET /api/mobile/providers/:id`, then role-specific endpoints), `ProviderListQuery` extended (`search`, `aiTechnicianService`), `USE_PROVIDER_FIXTURES` + `ProviderFinderFallbackData` for isolated offline demo data.
- **Navigation:** `router.dart` registers landing; `customer_home_screen` “AI টেকনিশিয়ান” opens landing hub.

### 0.2 Files changed / added

| Action | Path |
|--------|------|
| Added | `lib/src/features/providers/data/provider_kind.dart` |
| Added | `lib/src/features/providers/data/provider_profile_model.dart` |
| Added | `lib/src/features/providers/data/provider_finder_fallback_data.dart` |
| Added | `lib/src/features/providers/presentation/provider_finder_landing_screen.dart` |
| Added | `lib/src/features/providers/presentation/provider_detail_screen.dart` |
| Added | `lib/src/features/providers/presentation/widgets/provider_card.dart` |
| Added | `test/provider_list_query_test.dart` |
| Updated | `lib/src/core/config/app_config.dart` (`useProviderFinderFixtures`) |
| Updated | `lib/src/features/providers/data/provider_list_query.dart` |
| Updated | `lib/src/features/providers/data/provider_finder_repository.dart` |
| Updated | `lib/src/features/providers/application/provider_finder_providers.dart` |
| Updated | `lib/src/features/providers/presentation/doctor_list_screen.dart` |
| Updated | `lib/src/features/providers/presentation/technician_list_screen.dart` |
| Updated | `lib/src/features/providers/presentation/doctor_detail_screen.dart` |
| Updated | `lib/src/features/providers/presentation/technician_detail_screen.dart` |
| Updated | `lib/src/features/providers/presentation/widgets/provider_filter_panel.dart` |
| Updated | `lib/src/app/router.dart` |
| Updated | `lib/src/features/home/presentation/customer_home_screen.dart` |
| Updated | `docs/MOBILE_API_INTEGRATION_MAP.md` |
| Removed | `lib/src/features/providers/presentation/widgets/doctor_summary_card.dart` |
| Removed | `lib/src/features/providers/presentation/widgets/technician_summary_card.dart` |

### 0.3 Fallback / mock decision

- **Default:** Real HTTP via existing `ApiClient` / Dio (no mock in release).
- **Optional:** `flutter run --dart-define=USE_PROVIDER_FIXTURES=true` uses **`ProviderFinderFallbackData`** only inside `ProviderFinderRepository` (lists + detail + unified detail path). Replace by disabling the flag when the backend is available.

### 0.4 Manual test notes

1. OTP login → Home → **AI টেকনিশিয়ান** card → should open **landing** (`/providers`).
2. From landing, **ডাক্তার খুঁজুন** / **এআই টেকনিশিয়ান খুঁজুন** → lists load; filters change results; pull-to-refresh.
3. Tap **বিস্তারিত** or card body → detail; **জরুরি সহায়তা** ও **সেবা অনুরোধ** — দুটোই শুধু SnackBar (বুকিং উইজার্ড নয়)।
4. With backend off or wrong URL: expect Bengali error + retry; with **`USE_PROVIDER_FIXTURES=true`** expect demo rows.

### 0.5 Remaining backend / API notes

- **`GET /api/mobile/providers/:id`:** Client attempts it first; **404** or unparseable body → falls back to `…/doctors/:id` or `…/technicians/:id` using route `ProviderKind`. Align unified JSON (`doctor` / `technician` / `provider` + `kind`) with backend when ready.
- **Query params** `search`, `aiTechnicianService`: sent when set; backend may ignore until documented. Technician list applies **extra client filter** when `aiTechnicianService == true`.
- **Area catalog:** still demo slug allow-list in repository + filter panel until a mobile areas API exists.

### 0.6 Commands run (latest)

```text
dart format .     → Completed
flutter analyze   → No issues found
flutter test      → All tests passed (18 tests; includes provider_list_query_test)
```

**Unrelated test failures:** None on this run. If CI fails elsewhere, triage per test file — M06-only tests live in `test/provider_list_query_test.dart`.

*(Re-run after each substantive M06 edit.)*

---

### 0.7 Final verification checklist (M06)

| # | Requirement | Verified |
|---|-------------|----------|
| 1 | Provider finder landing page exists (`/providers`, `ProviderFinderLandingScreen`) | Yes — `router.dart`, `provider_finder_landing_screen.dart` |
| 2 | Doctor list page exists | Yes — `doctor_list_screen.dart` |
| 3 | AI technician list page exists | Yes — `technician_list_screen.dart` |
| 4 | Provider card component exists | Yes — `widgets/provider_card.dart`, used by both lists |
| 5 | Provider detail page exists (unified + route wrappers) | Yes — `provider_detail_screen.dart`, `doctor_detail_screen.dart`, `technician_detail_screen.dart` |
| 6 | Search / filter UI exists | Yes — list search fields + `ProviderFilterPanel` (incl. service categories) |
| 7 | Bengali-first labels | Yes — app `bn_BD`; M06 strings in BN |
| 8 | Loading state | Yes — `PdLoadingBody` on lists + detail |
| 9 | Error state | Yes — `PdErrorBody` + retry on lists + detail |
| 10 | Empty state | Yes — `PdEmptyState` on lists |
| 11 | Availability badge | Yes — `_AvailabilityBadge` / schedule chip on card & detail |
| 12 | Fee / service badge | Yes — `_FeeBadge` / payments chip on card & detail |
| 13 | Area coverage display | Yes — card row + detail `_InfoRow` + area list when present |
| 14 | Emergency CTA | Yes — landing `OutlinedButton`; list cards emergency chip; detail `OutlinedButton.icon` + SnackBar placeholder |
| 15 | Booking flow **not** implemented | Yes — detail/list: SnackBar only; no `BookingWizardScreen` push from M06 |
| 16 | API / fallback isolated & documented | Yes — `provider_finder_repository.dart`, `provider_finder_fallback_data.dart`, `AppConfig.useProviderFinderFixtures`, §0.3 + `MOBILE_API_INTEGRATION_MAP.md` |

---

### 0.8 Known limitations (post-verification)

- **Area catalog:** Still demo slug allow-list (`ashulia-union-area`) in repository + filter until a mobile areas API exists.
- **Pagination:** List APIs support offset/limit; UI does not expose “load more” yet.
- **Unified `GET /api/mobile/providers/:id`:** Parser is best-effort; backend should document canonical `data` shape.
- **Query params** `search`, `aiTechnicianService`: May be ignored by server until documented; technician list adds client-side refinement for AI filter when true.
- **Guest / public browse:** `/providers/*` remains behind customer auth redirect (unchanged product rule).

---

### 0.9 Next recommended tasks (outside M06 scope)

1. **Mobile areas API** + picker — remove demo slug coercion.
2. **Service request from detail** — deep-link to booking wizard with `providerId` / `kind` when product approves (separate task; not in M06).
3. **Pagination / infinite scroll** on doctor & technician lists.
4. **Optional:** `url_launcher` or platform call UI for `ProviderCallAction` when API exposes numbers.

---

## 1. Task summary

Deliver and polish **customer-facing** doctor and AI technician finder UX:

- **Provider finder landing** — single entry hub to choose doctors vs technicians (currently missing as a dedicated screen).
- **Doctor list** and **AI technician list** — search/filter section, cards, async states, Bengali-first copy.
- **Shared presentation** — provider card pattern (today: separate doctor/technician cards), availability and fee as clear **badges**, area coverage, emergency affordances, online consultation and rating as **placeholders** where required.
- **Provider detail** — continue placeholder-safe actions (no real booking pipeline in M06).

**Expected HTTP surface (task brief):**

| Brief | Current mobile client |
|-------|------------------------|
| `GET /api/mobile/providers/doctors` | **Implemented** in `ProviderFinderRepository.listDoctors` |
| `GET /api/mobile/providers/technicians` | **Implemented** in `ProviderFinderRepository.listTechnicians` |
| `GET /api/mobile/providers/:id` | **Used first** in `getProviderProfileDetail`; on **404** or unparseable body, falls back to **`…/doctors/:id`** or **`…/technicians/:id`** using route `ProviderKind`. Align unified JSON with backend when contract is final. |

---

## 2. Audit findings

### 2.1 Flutter app structure (relevant areas)

| Path | Role |
|------|------|
| `lib/src/app/router.dart` | `GoRouter`: splash, onboarding, login+OTP, **`HomeShellScreen`**, provider routes, tutorials, notifications, booking wizard, service-request detail. |
| `lib/src/app/app.dart` | `MaterialApp.router`, default locale **`bn_BD`**. |
| `lib/src/app/theme.dart` | Material 3 theme. |
| `lib/src/app/screen_padding.dart` | `pdScreenPadding`, `pdReadableMaxWidth`. |
| `lib/src/features/providers/` | **Existing feature slice:** `data/`, `application/`, `presentation/`, `widgets/`. |
| `lib/src/features/home/` | `home_shell_screen.dart`, **`customer_home_screen.dart`** (shortcuts), tab placeholders. |
| `lib/src/features/session/application/session_notifier.dart` | Customer JWT session; guest mode. |
| `lib/src/core/network/dio_provider.dart` | `Dio` + Bearer + 401 → sign out + login redirect. |
| `lib/src/core/network/api_client.dart` | Thin `get` / `post` / `patch`. |
| `lib/src/core/design_system.dart` | Barrel: spacing, `pd_app_card`, **`pd_async_states`**, buttons, etc. |

### 2.2 Routing / navigation pattern

- **App-level:** `go_router` (`goRouterProvider` in `router.dart`).
- **Auth redirect:** Non-public customer paths require `sessionNotifierProvider.isAuthenticated` → else `LoginEntryScreen`.
- **Provider routes (existing):**
  - `DoctorListScreen.routePath` → **`/providers/doctors`**
  - Nested **`/providers/doctors/:doctorId`** → `DoctorDetailScreen`
  - `TechnicianListScreen.routePath` → **`/providers/technicians`**
  - Nested **`/providers/technicians/:technicianId`** → `TechnicianDetailScreen`
- **Tab shell:** `HomeShellScreen` uses **`IndexedStack`** (home, animals, requests placeholder, knowledge placeholder, profile placeholder). Provider screens are **pushed via `context.push`** from home (not tab-local `Navigator`), consistent with tutorials/notifications.

### 2.3 API / client / repository / Riverpod pattern

- **HTTP:** `ApiClient` ← `dioProvider` ← `AppConfig.apiBaseUrl` (`--dart-define=API_BASE_URL`).
- **Envelope:** `{ "ok": true, "data": { … } }` unwrapped in repositories; Bengali messages on failure (`ProviderApiException` in `provider_finder_repository.dart`).
- **Provider finder:** `ProviderFinderRepository` + `providerFinderRepositoryProvider`; list state via **`AsyncNotifierProvider`** (`doctorsListProvider`, `techniciansListProvider`); filter state via **`NotifierProvider`** (`doctorListQueryProvider`, `technicianListQueryProvider`); detail via **`FutureProvider.family`** (`doctorDetailProvider`, `technicianDetailProvider`).
- **Query model:** `ProviderListQuery` → `toQueryParameters()` (`provider_list_query.dart`).

### 2.4 Auth / customer-area patterns

- Lists and details run **with the same Dio stack** as other mobile APIs; **401** clears session (see `dio_provider.dart`).
- **Guest:** If product allows guest browsing of providers, confirm backend policy; today **unauthenticated users are redirected to login** by router for any non-public path including `/providers/*`. Document: **finder is “customer authenticated”** unless product adds `/providers/*` to `_isPublicCustomerPath` (not recommended without API support).

### 2.5 Shared widgets / theme (available for M06)

| Asset | Location | M06 use |
|-------|----------|---------|
| Loading / error / empty | `lib/src/core/widgets/pd_async_states.dart` (`PdLoadingBody`, `PdErrorBody`, `PdEmptyState`) | Lists and details still use **ad-hoc** `CircularProgressIndicator` / local `_ErrorBody` / `_EmptyBody` — **align** for consistency. |
| Cards | `lib/src/core/widgets/pd_app_card.dart` | Optional visual alignment for list rows. |
| Buttons | `lib/src/core/widgets/pd_buttons.dart` | Optional for CTAs. |
| Page header | `lib/src/core/widgets/pd_page_header.dart` | Optional if landing page needs marketing-style header. |

### 2.6 Existing provider / doctor / technician / area / service / animal / booking files

| File | Notes |
|------|--------|
| `lib/src/features/providers/data/provider_finder_repository.dart` | Real API calls; **`_allowedAreaSlugs`** only `ashulia-union-area`; unknown slugs stripped before HTTP. |
| `lib/src/features/providers/data/provider_list_query.dart` | `areaSlug`, `areaId`, `animalType`, `homeVisit`, `emergency`, `onlineConsultation`, `serviceCategoryId`, pagination. |
| `lib/src/features/providers/data/provider_models.dart` | `DoctorSummary` / `DoctorDetail`, `TechnicianSummary` / `TechnicianDetail`, pagination, `ProviderCallAction` / `ProviderBookAction` (API-driven; UI not wired). |
| `lib/src/features/providers/application/provider_finder_providers.dart` | Riverpod wiring. |
| `lib/src/features/providers/presentation/doctor_list_screen.dart` | Filters + list + loading/error/empty + refresh. |
| `lib/src/features/providers/presentation/technician_list_screen.dart` | Same; **`showOnlineConsultation: false`** on filter panel. |
| `lib/src/features/providers/presentation/doctor_detail_screen.dart` | Detail + chips; call/book **SnackBar placeholders**. |
| `lib/src/features/providers/presentation/technician_detail_screen.dart` | Same pattern. |
| `lib/src/features/providers/presentation/widgets/provider_filter_panel.dart` | Bengali labels; area demo slug; animal; home visit; emergency; optional online consultation. **No service-category UI.** |
| `lib/src/features/providers/presentation/widgets/doctor_summary_card.dart` | Card + fee/availability text; rating line; call/book **SnackBar**. **No explicit “badge” widgets** for availability/fee/emergency. |
| `lib/src/features/providers/presentation/widgets/technician_summary_card.dart` | Same; animal type chips from API strings. |
| `lib/src/features/home/presentation/customer_home_screen.dart` | **AI technician** → `TechnicianListScreen`; **ডাক্তার — বাড়িতে পরিদর্শন** → **`BookingWizardScreen`** (not doctor list). **No** `DoctorListScreen` shortcut. |
| `lib/src/features/service_requests/presentation/booking_wizard_screen.dart` | Booking flow — **out of scope** for M06 implementation; only referenced for “do not wire new booking steps from finder”. |
| `lib/src/features/service_requests/data/service_category_repository.dart` | `GET /api/mobile/service-categories` — **candidate** for “service type” filter dropdown (`serviceCategoryId` already on `ProviderListQuery`). |
| `lib/src/features/animals/data/animal_profile_model.dart` | `AnimalType` enum reused for provider animal filter. |

### 2.7 API integration status

- **Integrated in code:** list + detail endpoints documented in `MOBILE_API_INTEGRATION_MAP.md` match **`ProviderFinderRepository`**.
- **Gaps vs task wording:** unified **`GET /api/mobile/providers/:id`** not called — see §1 table.
- **Filter query params:** `serviceCategoryId` exists in model but **not exposed in UI**; **no text search** param in `ProviderListQuery` (add only when backend documents `q` / `search` / etc.).

### 2.8 Safest files to create / update (minimal blast radius)

| Action | Path | Reason |
|--------|------|--------|
| **Create** | `lib/src/features/providers/presentation/provider_finder_landing_screen.dart` (name TBD) | New landing hub only; no change to repository contracts. |
| **Update** | `lib/src/app/router.dart` | Add one `GoRoute` for landing path (e.g. `/providers`) and optional `name` for deep links. |
| **Update** | `lib/src/features/home/presentation/customer_home_screen.dart` | Point “ডাক্তার” and/or a new “খুঁজুন” shortcut to landing or `DoctorListScreen` per product choice. |
| **Update** | `provider_filter_panel.dart` | Add service category + (if API exists) technician-service filter; expand area list when API ready. |
| **Update** | `doctor_summary_card.dart` / `technician_summary_card.dart` | Badges, emergency row, optional shared private layout widget. |
| **Update** | `doctor_list_screen.dart` / `technician_list_screen.dart` | Use `pd_async_states`; optional search field; pagination “load more” later. |
| **Update** | `doctor_detail_screen.dart` / `technician_detail_screen.dart` | Retry on error; badges; disabled/emergency CTA policy. |
| **Optional new** | `lib/src/features/providers/presentation/widgets/provider_summary_layout.dart` | Shared row/badge layout consumed by both cards (**no new package**). |
| **Optional** | `lib/src/features/providers/application/…` | `FutureProvider` for service categories if filter needs async options. |

Avoid touching unrelated features (animals form, notifications, doctor-stub login) except tiny imports if sharing a label helper.

---

## 3. Existing architecture notes

- **Feature-first layout:** `data` → `application` → `presentation` mirrors animals/tutorials/notifications.
- **List invalidation:** Changing `doctorListQueryProvider` / `technicianListQueryProvider` triggers **`AsyncNotifier.build()`** refetch — correct for filter UX.
- **Detail:** `FutureProvider.family` — use **`ref.invalidate(doctorDetailProvider(id))`** on retry after error (today some error UIs lack retry).
- **Conflict with task “Provider card”:** Two concrete widgets exist; **least invasive** path is extract **internal** `_ProviderSummaryLayout` (file under `widgets/`) used by both, or rename to `provider_list_card.dart` while keeping doctor/technician-specific fields as small wrappers.
- **Design system:** Prefer `PdLoadingBody` / `PdErrorBody` / `PdEmptyState` over duplicated private classes in list screens.

---

## 4. Data model plan

- **Keep** `DoctorSummary`, `DoctorDetail`, `TechnicianSummary`, `TechnicianDetail` as the JSON source of truth (`provider_models.dart`).
- **Map task labels → fields:**
  - Area: `areaText` (summary), `areas` / `villages` (detail); filters: `areaSlug` / `areaId`.
  - Animal type (technician): `supportedAnimalTypes` (detail/list); filter uses **`AnimalType`** → `animalType` query (doctors + technicians APIs as supported today).
  - Service type: summary `serviceType` string + detail `serviceCategories`; filter → **`serviceCategoryId`** once UI loads categories.
  - Doctor home visit / emergency / online: `homeVisit`, `emergency`, `onlineConsultation`.
  - AI technician “service”: interpret as **service category** and/or free-text `serviceType` until API adds a dedicated flag — **document backend field** when known.
  - Rating: `rating` nullable — show **“শীঘ্রই”** or hide star row until M later.
- **Optional future:** Unified `MobileProviderSummary` discriminated union if backend merges lists — **not required for M06** if split APIs remain.

---

## 5. API / repository plan

| Work item | Detail |
|-----------|--------|
| **Keep** `listDoctors` / `listTechnicians` | Paths already match mobile map. |
| **Detail paths** | Keep `…/doctors/:id` and `…/technicians/:id`. If backend later exposes **`GET /api/mobile/providers/:id`**, add `getProviderById` that parses `kind` and returns a sealed type **or** delegates to existing parsers — **behind one repository method** to avoid UI churn. |
| **Query alignment** | When adding service filter, pass `serviceCategoryId` already supported in `ProviderListQuery`. |
| **Area expansion** | Replace hard-coded `_allowedAreaSlugs` / filter demo set when mobile **areas** endpoint exists (`MOBILE_API_INTEGRATION_MAP` update in implementation phase). Until then, either keep demo slug only **or** fetch allowed slugs from config endpoint if introduced. |
| **Search** | Extend `ProviderListQuery` + repository **only after** backend query contract is confirmed (`q`, `name`, etc.). Until then: UI can offer **client-side** filter on the **current page** of results (optional, low value) or a disabled search field with SnackBar “শীঘ্রই”. |

---

## 6. Fallback / mock strategy (if API unavailable)

**Default:** No mock in production builds — repository errors already surface as Bengali `ProviderApiException`.

If developers need **offline UI** or CI without backend:

1. **Tests:** Use `ProviderContainer` overrides — `providerFinderRepositoryProvider` → fake that returns `DoctorSummary` fixtures (preferred; **no new package**).
2. **Debug-only fixtures (optional):** Small `const` lists in `test/` or `lib/src/features/providers/data/dev_provider_fixtures.dart` imported only from `kDebugMode && const bool.fromEnvironment('USE_PROVIDER_FIXTURES')` — **do not** ship enabled in release. Document in README or `AppConfig` comment only if used.
3. **Avoid** large asset JSON unless product demands offline demo.

---

## 7. UI / page plan

| Page | Current state | M06 target |
|------|---------------|------------|
| **Landing** | Missing | Two large actions: “ডাক্তার খুঁজুন” → `DoctorListScreen.routePath`; “AI টেকনিশিয়ান” → `TechnicianListScreen.routePath`; optional short copy on filters; **no booking**. |
| **Doctor list** | Exists | Add **search/filter header** (collapsible or persistent); **badges** on cards; wire **service category** filter; optional **emergency** banner CTA (e.g. `FilledButton` → SnackBar or disabled “জরুরি অনুরোধ” linking to booking **placeholder** only). |
| **Technician list** | Exists | Same; add **AI technician service** control once defined (likely service category); keep online consultation filter hidden or show as disabled “শীঘ্রই” per product. |
| **Provider card** | Two widgets | Extract shared visual structure; show **availability** as `Chip` / `Badge`; **fee** as tonal chip or outlined badge; **emergency** icon/badge when `emergency == true`; area as single line + “আরও এলাকা” on detail. |
| **Detail** | Exists | Richer area list; **retry** on error; call/book remain **SnackBar or disabled**; online consultation row as “শীঘ্রই” if false; align loading/error with `pd_async_states`. |

---

## 8. Routing / navigation plan

1. Add **`ProviderFinderLandingScreen`** (name aligned with codebase conventions) with `static const routePath = '/providers';`.
2. Register in **`router.dart`** **before** or as parent of nested doctor routes — two patterns:
   - **Flat (simplest):** `GoRoute(path: '/providers', builder: …)` plus existing sibling `/providers/doctors` — no nesting change.
   - **Shell (optional):** Nested routes under `/providers` — slightly more invasive; **prefer flat** for M06.
3. Update **`customer_home_screen.dart`:** e.g. one “প্রদানকারী খুঁজুন” card → landing; adjust doctor shortcut to **doctor list** or landing per PM.
4. **Deep links:** `context.push` / `pushNamed` with `routeName` for analytics later — optional.

---

## 9. Loading / error / empty state plan

| State | Approach |
|-------|----------|
| Loading | Replace raw `CircularProgressIndicator` with **`PdLoadingBody`** (optional Bangla “লোড হচ্ছে…”). |
| Error | **`PdErrorBody`** with title + `ProviderApiException.message` + **retry** (`invalidate` list provider or `refresh()` on notifier). |
| Empty | **`PdEmptyState`** or match animals/tokens for icon + title + subtitle + tonal refresh. |
| Pull-to-refresh | **Keep** `RefreshIndicator` on lists. |

---

## 10. Bengali label plan

- **Reuse** existing strings in filter panel and list app bars where correct.
- **New / adjusted copy (examples — finalize in implementation):**
  - Landing title: “ডাক্তার ও টেকনিশিয়ান খুঁজুন”
  - Service type label: “সেবার ধরন”
  - Search placeholder: “নাম দিয়ে খুঁজুন” (only if search is real)
  - Emergency CTA: “জরুরি সহায়তা” → SnackBar “শীঘ্রই” or navigate to existing emergency card policy (do **not** open booking wizard unless product explicitly asks — M06 says placeholder).
  - Badges: “হোম ভিজিট”, “জরুরি”, “অনলাইন”, “উপলব্ধতা”, “ফি”
- **Rating:** “রেটিং: শীঘ্রই” or hide stars until data exists.

---

## 11. What must NOT be implemented in M06

- **No** full booking wizard changes, new booking steps, or wiring **বুক** to `BookingWizardScreen` with real prefilled provider context (optional **disabled** button with tooltip/SnackBar OK).
- **No** backend / Next.js / API route changes.
- **No** `url_launcher` / real phone call integration unless already a separate approved task (today cards use SnackBar — keep or deliberately upgrade in a dedicated task).
- **No** new Dart packages unless unavoidable (none anticipated).
- **No** unified `GET …/providers/:id` **requirement** until backend exists — only document and optionally implement adapter.

---

## 12. Test plan

| Layer | Plan |
|-------|------|
| Unit | `ProviderListQuery.toQueryParameters()` when `serviceCategoryId` / filters toggled; optional `_coerceQuery` behavior if area rules change. |
| Widget | Golden or smoke: landing has two tappable targets navigating to correct paths (mock `GoRouter`). |
| Integration | Manual: login → landing → lists → detail → back; filters refetch; 401 → login. |
| CI | `flutter analyze`, `flutter test` (existing `otp_auth_test.dart` + any new small tests). |

---

## 13. Implementation checklist (for a future implementation pass)

- [ ] Add `ProviderFinderLandingScreen` + `routePath` + `router.dart` entry.
- [ ] Update `customer_home_screen` navigation to landing and/or `DoctorListScreen`.
- [ ] Extend `ProviderFilterPanel` with **service category** dropdown (`ServiceCategoryRepository.list` via new `FutureProvider`).
- [ ] Define “AI technician service” filter vs API; implement or document as SnackBar placeholder.
- [ ] Refactor list/detail async UI to **`pd_async_states`** + retry.
- [ ] Refactor cards: **availability badge**, **fee badge**, **emergency** visual, rating placeholder policy.
- [ ] Detail screens: emergency row / disabled online row; optional `ref.invalidate` retry.
- [ ] (If backend adds search) extend `ProviderListQuery` + repository + UI field.
- [ ] (When areas API exists) remove demo-only slug restriction in repository + panel.
- [ ] Update `docs/MOBILE_API_INTEGRATION_MAP.md` if new paths or query params.
- [ ] `flutter analyze` / `flutter test` green.

---

## 14. Recommended implementation path

1. **Landing + router + home links** — smallest vertical slice; unblocks UX clarity (“ডাক্তার খুঁজুন” no longer only via booking card).
2. **Filter panel: service categories** — uses existing `serviceCategoryId` + existing HTTP list API.
3. **Card / badge polish** — shared layout widget to avoid duplication.
4. **Async state consistency** — swap to `pd_async_states` on four screens (2 lists, 2 details).
5. **Defer** unified `providers/:id`, text search, pagination, and area catalog until backend/product specs land.

---

## 15. Files inspected (audit)

`lib/src/app/router.dart`, `lib/src/app/theme.dart`, `lib/src/app/screen_padding.dart`, `lib/src/core/network/api_client.dart`, `lib/src/core/network/dio_provider.dart`, `lib/src/core/widgets/pd_async_states.dart`, `lib/src/core/design_system.dart`, `lib/src/features/session/application/session_notifier.dart`, `lib/src/features/home/home_shell_screen.dart`, `lib/src/features/home/presentation/customer_home_screen.dart`, `lib/src/features/providers/data/provider_finder_repository.dart`, `lib/src/features/providers/data/provider_list_query.dart`, `lib/src/features/providers/data/provider_models.dart`, `lib/src/features/providers/application/provider_finder_providers.dart`, `lib/src/features/providers/presentation/doctor_list_screen.dart`, `lib/src/features/providers/presentation/technician_list_screen.dart`, `lib/src/features/providers/presentation/doctor_detail_screen.dart`, `lib/src/features/providers/presentation/technician_detail_screen.dart`, `lib/src/features/providers/presentation/widgets/provider_filter_panel.dart`, `lib/src/features/providers/presentation/widgets/doctor_summary_card.dart`, `lib/src/features/providers/presentation/widgets/technician_summary_card.dart`, `lib/src/features/service_requests/data/service_category_repository.dart`, `lib/src/features/animals/data/animal_profile_model.dart`, `docs/MOBILE_API_INTEGRATION_MAP.md`, `docs/PROVIDER_FINDER_MOBILE_PLAN.md`, `docs/tasks/M05_ANIMAL_PROFILE_PLAN.md` (structure reference), `docs/MOBILE_PAGE_TASK_INDEX.md`, `pubspec.yaml`.

---

## 16. Files created / updated (planning phase — superseded by §0.2)

| Action | Path |
|--------|------|
| **Created** | `docs/tasks/M06_PROVIDER_FINDER_PLAN.md` (this file) |

*(Optional follow-up, not done here: add a short row for M06 in `docs/MOBILE_PAGE_TASK_INDEX.md`.)*
