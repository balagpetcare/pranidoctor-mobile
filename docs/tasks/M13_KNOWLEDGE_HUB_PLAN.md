# Task M13 — Knowledge Hub / Tutorial Pages (Audit & Plan)

**Project:** Prani Doctor / Animal Doctors — **mobile app only**  
**Domain:** [https://pranidoctor.com/](https://pranidoctor.com/)  
**Repo:** [github.com/balagpetcare/pranidoctor-mobile](https://github.com/balagpetcare/pranidoctor-mobile)  
**Local path:** `D:\PraniDoctor\pranidoctor_mobile`

**Goal:** Approved educational **knowledge hub** for customers, doctors, and AI technicians — Bengali-first, modular, aligned with existing Flutter architecture.

**Isolation:** No other products. **No backend changes** in this task. Prior art: `docs/KNOWLEDGE_HUB_MOBILE_PLAN.md` (tutorials API on web). This file is the **M13 task plan + audit**; **§0** is the live implementation summary.

**Status:** **Implemented** in mobile (2026-05-09). Sections §1–§13 retain the pre-implementation audit and planning notes for history.

**Last updated:** 2026-05-09 (§14 branch verification + tutorials removal audit)

---

## 0. Implementation status (2026-05-09)

### 0.1 Delivered

| Area | Details |
|------|---------|
| **Feature folder** | `lib/src/features/knowledge_hub/` — `data/`, `application/`, `presentation/`, `presentation/widgets/` |
| **Routes** | `/knowledge` (home), `/knowledge/categories` (grid), `/knowledge/posts` (list + chips + search placeholder), `/knowledge/posts/:slugOrId` (detail) |
| **Legacy URLs** | `redirect` in `router.dart`: `/tutorials` → `/knowledge/posts`; `/tutorials/*` → `/knowledge/posts/*` |
| **Models** | `KnowledgeCategory`, `KnowledgePost`, `KnowledgePostDetail`, refs — flexible JSON keys for future `/content` API |
| **Repository** | `KnowledgeRepository` + `KnowledgeRepositoryLive` + `KnowledgeRepositoryMock`; **Live** calls documented paths first, **404-only** fallback to existing tutorials API |
| **Mock flag** | `AppConfig.useMockKnowledgeApi` — `flutter run --dart-define=USE_MOCK_KNOWLEDGE_API=true` |
| **UI (BN-first)** | Labels per spec: **জ্ঞানকেন্দ্র**, **খুঁজুন**, **জনপ্রিয়/ফিচার্ড লেখা**, **সব লেখা**, **বিস্তারিত পড়ুন**, **কোনো লেখা পাওয়া যায়নি**, **আবার চেষ্টা করুন**, **তথ্য লোড হচ্ছে**, topic chips for the seven themes |
| **Removed** | `lib/src/features/tutorials/**` (replaced by knowledge hub) |

### 0.2 API — expected vs actual (no backend edits)

| Documented expectation (M13 brief) | Deployed / wired behavior |
|-----------------------------------|---------------------------|
| `GET /api/mobile/content/categories` | Mobile **calls this first**. **Not implemented** in [pranidoctor-web](https://github.com/balagpetcare/pranidoctor-web) today (no `content` route files found). **404 →** `GET /api/mobile/tutorials/categories`. |
| `GET /api/mobile/content/posts` | Called first; **404 →** `GET /api/mobile/tutorials` (inner list key `tutorials`). |
| `GET /api/mobile/content/posts/:id` | Called first; inner keys `post` / `item` / `tutorial`; **404 →** `GET /api/mobile/tutorials/:slugOrId` (`data.tutorial`). |

When the backend later adds real **`/api/mobile/content/*`** handlers with the same `{ ok, data }` envelope, the app will use them **without** a mobile change (unless response shape differs — then adjust parsers only).

### 0.3 Entry points

- **Customer:** হোম menu **জ্ঞানকেন্দ্র** → `/knowledge`
- **Doctor:** চিকিৎসক হোম card **জ্ঞানকেন্দ্র** → `/knowledge`
- **Technician:** AI টেকনিশিয়ান ড্যাশবোর্ড → **জ্ঞানকেন্দ্র** → `/knowledge`

### 0.4 Checklist (M13 implementation)

- [x] Hub home, categories grid, post list, detail, search placeholder, featured card, article cards, loading/error/empty, repository + mock, `USE_MOCK_KNOWLEDGE_API`, legacy `/tutorials` redirect, technician entry, `flutter analyze` + `flutter test` clean

---

## 1. Task summary

> **Note:** Rows below are the **original audit snapshot** (before M13 implementation). Current behavior is in **§0**.

| Requirement | Status in codebase (2026-05-09) |
|-------------|----------------------------------|
| Knowledge hub home | **Partial** — `TutorialListScreen` acts as hub (title **নলেজ হাব**, intro copy); no separate landing with featured hero. |
| Category list | **Partial** — horizontal **FilterChip** row (`সব` + categories); no dedicated full-page category grid/list. |
| Tutorial/content list | **Done** — cards, pagination params exist in repo (`take`/`skip`); UI uses first page only. |
| Tutorial detail | **Done** — plain-text `body`, cover, metadata, retry. |
| Search/filter placeholder | **Missing** — no `TextField` / “খুঁজুন” stub. |
| Featured content card | **Missing** — no pinned/hero card at top of hub. |
| Bengali-first UI | **Done** — `locale: bn_BD`, BN strings in screens/repo errors; theme Bengali line-height / Noto fallback. |
| Category chips/cards | **Chips done**; **category cards** (grid) not present. |
| Article cards | **Done** — `_TutorialCard` (cover, title, meta, summary). |
| Readable detail | **Done** — `SelectableText`, `pdReadableMaxWidth`, spacing. |
| Loading / error / empty | **Done** on list + detail; categories use inline error + small spinner. |
| Veterinary education style | **Partial** — follows `AppTheme` (teal/emerald); could add subtle section icons / typography tweaks only if needed. |
| Content type coverage (animal care, emergency, vaccination, etc.) | **Data-driven** — depends on CMS/categories from API, not hardcoded tabs in app. |
| AI technician discoverability | **Gap** — technician flows under `/technician/*` have **no** link to knowledge hub (customer + doctor do). |

---

## 2. Current audit findings

### 2.1 Architecture

| Area | Location / pattern |
|------|---------------------|
| **Entry** | `lib/main.dart` → `ProviderScope` + `PraniDoctorApp`. |
| **Router** | `go_router` in `lib/src/app/router.dart` — `goRouterProvider`, auth redirect, top-level routes. |
| **Features** | `lib/src/features/<feature>/{data,application,presentation}/`. |
| **Networking** | `dioProvider` (`lib/src/core/network/dio_provider.dart`) — `AppConfig.apiBaseUrl`, JSON headers, Bearer from `tokenStorage`, 401 → sign out + `go(LoginEntryScreen)`. |
| **API wrapper** | `ApiClient` (`lib/src/core/network/api_client.dart`) — `get`/`post`/`patch`. |
| **Config** | `lib/src/core/config/app_config.dart` — `API_BASE_URL`, flags like `USE_MOCK_TECHNICIAN_API` (no tutorial mock flag today). |
| **State** | `flutter_riverpod` — `Provider` for repos; `FutureProvider.autoDispose` for lists/detail; `NotifierProvider` for selected category id. |
| **Layout helpers** | `lib/src/app/screen_padding.dart` — `pdScreenPadding`, `pdReadableMaxWidth`. |
| **Theme** | `lib/src/app/theme.dart` — Material 3, seed teal, cards 16px radius, Bengali-friendly `textTheme`. |
| **Shared async errors** | `lib/src/app/user_visible_async_error.dart` — **does not** include `TutorialApiException`; tutorials use `e.toString()` (Tutorial’s `toString()` returns message — OK). |

### 2.2 Localization

- **No** `flutter_gen` / ARB files — strings are **inline Bengali** in widgets (same pattern as home, notifications, booking).
- `MaterialApp.router` sets **`locale: Locale('bn', 'BD')`** (`lib/src/app/app.dart`).

### 2.3 API contract (mobile today vs M13 “expected”)

| M13 expected (stated) | Implemented in `TutorialRepository` |
|------------------------|-------------------------------------|
| `GET /api/mobile/content/categories` | `GET /api/mobile/tutorials/categories` |
| `GET /api/mobile/content/posts` | `GET /api/mobile/tutorials` |
| `GET /api/mobile/content/posts/:id` | `GET /api/mobile/tutorials/{slugOrId}` |

- **Grep:** no references to `/api/mobile/content` in the mobile repo.
- **Response shape** (mobile): envelope `{ ok, data }` with inner keys `categories`, `tutorials`, `tutorial`, `total` — see `tutorial_repository.dart`.

**Conclusion:** Mobile is **wired to `/api/mobile/tutorials/*`**, documented in `docs/KNOWLEDGE_HUB_MOBILE_PLAN.md` as matching pranidoctor-web. M13 spec paths **`/api/mobile/content/*`** are **not** used; treat as **naming drift** unless/until backend adds aliases — **document only**, no backend work here.

---

## 3. Existing files / features found

| Path | Role |
|------|------|
| `lib/src/features/tutorials/data/tutorial_repository.dart` | HTTP + `TutorialApiException` + `_unwrap` |
| `lib/src/features/tutorials/data/tutorial_models.dart` | `TutorialCategory`, list item, detail models |
| `lib/src/features/tutorials/application/tutorials_providers.dart` | Repo + category filter + providers |
| `lib/src/features/tutorials/presentation/tutorial_list_screen.dart` | Hub list, chips, cards, empty/error/loading |
| `lib/src/features/tutorials/presentation/tutorial_detail_screen.dart` | Detail, retry, back |
| `lib/src/app/router.dart` | `/tutorials`, `/tutorials/:slugOrId` |
| `lib/src/features/home/home_screen.dart` | Menu **টিউটোরিয়াল** → push list |
| `lib/src/features/home/doctor/presentation/doctor_home_screen.dart` | **নলেজ হাব (টিউটোরিয়াল)** → same route |
| `docs/KNOWLEDGE_HUB_MOBILE_PLAN.md` | Earlier knowledge hub spec (tutorials API) |

**Tests:** `test/` has **no** `tutorial*` tests (grep).

---

## 4. Proposed files to create / update (implementation phase — not done yet)

**Preferred:** extend **`features/tutorials`** (or rename folder later to `knowledge_hub` only if team agrees — **default: keep `tutorials`** to minimize churn).

| Action | Path | Notes |
|--------|------|-------|
| **Update** | `tutorial_list_screen.dart` (or split widgets file) | Featured card section; search **placeholder** (`TextField` read-only or disabled + hint **শীঘ্রই খোঁজা যাবে**); optional `SliverAppBar` subtitle. |
| **New (optional)** | `.../presentation/knowledge_hub_home_screen.dart` | Only if product wants **two-step** nav: short landing → “সব নিবন্ধ” → reuse list provider. Otherwise keep single screen with slivers. |
| **New (optional)** | `.../presentation/widgets/featured_content_card.dart` | Hero card: title, cover, CTA → detail route. Data: first item with `coverImageUrl` or explicit field when API adds `featured`. |
| **New (optional)** | `.../presentation/category_grid_screen.dart` | If full **category list** page is required — grid of `TutorialCategory` cards → sets filter + pops or pushes list with `categoryId`. |
| **Update** | `tutorial_repository.dart` | Only if backend later exposes `/content/*` — add parallel methods or config-driven base path; **or** adapter interface + two implementations. |
| **Update** | `app_config.dart` | Optional `USE_MOCK_TUTORIALS_API` mirror technician pattern. |
| **New (optional)** | `tutorial_repository_mock.dart` | Static BN sample posts + categories for offline/demo. |
| **Update** | `router.dart` | New routes only if hub home or category page is separate (e.g. `/knowledge` parent + child). |
| **Update** | Technician shell screens | Add one `ListTile`/button **নলেজ হাব** → `context.push(TutorialListScreen.routePath)` (public route already allowed when authenticated). |
| **New** | `test/tutorial_list_screen_test.dart` (or widget smoke) | Pump with **overridden** `tutorialRepositoryProvider` mock — avoid real HTTP. |

---

## 5. Route / navigation plan

| Screen | Route today | Proposal |
|--------|-------------|----------|
| List (hub + chips + posts) | `/tutorials` | Keep as canonical **knowledge hub** URL; optionally add redirect alias `/knowledge` → `/tutorials` later. |
| Detail | `/tutorials/:slugOrId` | Unchanged. |
| Hub home (optional) | — | `/knowledge` or `/tutorials/home` as **child** only if marketing wants two taps; else avoid extra depth. |
| Category list page (optional) | — | `/tutorials/categories` as sibling under tutorials parent route group. |

**Auth:** `router.dart` allows `/tutorials` for authenticated users (not in public-path whitelist — requires login like rest of app). Tutorials API is public on server; app still sends Bearer when present (harmless).

---

## 6. API integration plan

1. **Phase A (default):** Keep **`TutorialRepository`** paths **`/api/mobile/tutorials/*`**; align M13 acceptance criteria to **deployed** contract (see `KNOWLEDGE_HUB_MOBILE_PLAN.md`).
2. **Phase B (if `/api/mobile/content/*` ships):** Add repository method variants or a **`ContentApiConfig`** `String get categoriesPath`** without deleting old paths until backend deprecates tutorials routes.
3. **Query params:** Already support `categoryId`, `categorySlug`, `take`, `skip`. Future **search**: add `q` or `search` when API documents it — UI placeholder until then.
4. **Featured:** Until API returns `featured: true` or ordered list, client can **heuristic**: first post with cover, or pinned slug list in **dart-define** (last resort).

---

## 7. Mock / placeholder fallback (API missing or local dev)

| Strategy | Detail |
|----------|--------|
| **Flag** | `USE_MOCK_TUTORIALS_API` via `AppConfig` (same pattern as technician). |
| **Mock repo** | Returns 2–3 BN categories + 3–5 short posts matching content types (labels in BN). |
| **Empty** | Already user-friendly when server returns `[]`. |
| **404 detail** | Already mapped in repository. |

Do **not** add mock as default `true` — opt-in for dev/demo only.

---

## 8. UI component plan

| Component | Approach |
|-----------|----------|
| **Featured card** | `Card` + `InkWell`, 16:9 cover, title (BN), “পড়ুন →” — uses first list item or dedicated provider `featuredTutorialProvider` if split endpoint added later. |
| **Search placeholder** | `SearchBar` or `TextField` with `enabled: false`, `onTap: () => ScaffoldMessenger` snack **শীঘ্রই** — or `InputDecorator` + icon. |
| **Category “cards”** | If required: `GridView` / `Wrap` of compact cards with icon per slug (optional map slug → `Icons.*`) — else chips satisfy “chips/cards” minimally. |
| **Article row** | Reuse `_TutorialCard`; extract to `widgets/tutorial_article_card.dart` if file grows. |
| **Detail readability** | Keep `SelectableText`; consider `SelectionArea` wrapper if web/desktop; optional markdown later **out of scope** unless API sends MD. |

---

## 9. Loading / error / empty-state plan

| Surface | Current | Enhancement |
|---------|---------|-------------|
| List loading | Full-screen spinner for posts | Optional: shimmer **not** required for M13. |
| Categories loading | Small `CircularProgressIndicator` | OK. |
| Errors | BN + retry | Optionally route `TutorialApiException` through shared helper for consistency with `user_visible_async_error.dart`. |
| Empty filtered | BN copy exists | OK. |
| Detail error | Retry + **তালিকায় ফিরুন** | OK. |

---

## 10. Test plan

| Type | Scope |
|------|--------|
| **Widget** | `TutorialListScreen`: mock providers → loading → data with 1 card → tap navigates (use `ProviderScope` + `GoRouter` test harness or pump with `Navigator` push). |
| **Widget** | Empty state when `tutorials` list empty. |
| **Unit** | `TutorialCategory.fromJson` / list item parsing edge cases (null `nameBn`). |
| **Manual** | With real API + seed: chips, filter, detail, refresh, airplane mode (BN error strings). |
| **Manual** | Doctor home + customer home entry; after implementation, technician entry. |

---

## 11. Risks / notes

- **Path naming:** Stakeholders may expect **`/content/posts`** in docs while app uses **`/tutorials`** — clarify in API contract doc, not code, unless mobile dual-support is requested.
- **Plain text body:** Long articles need scroll performance — already `SingleChildScrollView`; fine for MVP.
- **Technician UX:** ~~Adding hub link must not break `/technician` redirect rules~~ — **Done:** technician dashboard links to **`/knowledge`** (§0.3).
- **i18n debt:** All BN in source; future ARB migration is a separate initiative.

---

## 12. Exact implementation checklist (superseded by §0.4)

The items below were pre-PR planning; **§0.4** reflects what shipped. Kept for traceability only.

- [x] ~~Product decision~~ — Hub home at `/knowledge`, list at `/knowledge/posts`.
- [x] Featured + catalog provider (`knowledgeCatalogPostsProvider` / `knowledgeFeaturedPostProvider`).
- [x] Search placeholder + BN snack on list + hub.
- [x] Category grid at `/knowledge/categories`.
- [x] `USE_MOCK_KNOWLEDGE_API` + `KnowledgeRepositoryMock`.
- [x] Technician entry → `/knowledge`.
- [x] Shared widgets in `knowledge_hub_widgets.dart`.
- [ ] Widget tests with mocked repository (optional follow-up).
- [ ] Optional: one-line cross-link in `docs/KNOWLEDGE_HUB_MOBILE_PLAN.md` to M13.
- [x] `flutter analyze` + `flutter test` (see **§14**).

---

## 13. Files inspected (audit)

`lib/main.dart`, `lib/src/app/app.dart`, `lib/src/app/router.dart`, `lib/src/app/theme.dart`, `lib/src/app/screen_padding.dart`, `lib/src/app/user_visible_async_error.dart`, `lib/src/core/config/app_config.dart`, `lib/src/core/network/api_client.dart`, `lib/src/core/network/dio_provider.dart`, `lib/src/features/home/home_shell_screen.dart`, `lib/src/features/home/home_screen.dart`, `lib/src/features/home/doctor/presentation/doctor_home_screen.dart`, `lib/src/features/knowledge_hub/**/*`, `pubspec.yaml`, `docs/KNOWLEDGE_HUB_MOBILE_PLAN.md`, `docs/tasks/M12_NOTIFICATION_CENTER_PLAN.md` (format reference), `test/*`.

---

## 14. Final verification (`feature/m13-knowledge-hub`, 2026-05-09)

### 14.1 Intentional removal of `lib/src/features/tutorials/**`

| Question | Answer |
|----------|--------|
| Was deleting the old **Dart** `tutorials` feature intentional? | **Yes.** The customer-facing UI, models, repository, and providers were **replaced** by `lib/src/features/knowledge_hub/**` (wider M13 scope: hub home, categories grid, `/content` first + **HTTP 404** fallback to **`/api/mobile/tutorials/*`** on the wire). |
| Do any **`lib/`** imports still point at `features/tutorials`? | **No.** Repo check: `rg 'features/tutorials' lib` → **0 matches**. Navigation uses `KnowledgeHubHomeScreen.routePath` etc.; `router.dart` only mentions the string **`/tutorials`** as a **legacy URL redirect** target → `/knowledge/posts`. |
| Do HTTP paths still use “tutorials”? | **Yes, by design** as the production fallback (see §0.2). That is the **backend route name**, not the removed Flutter folder. |

Historical audit tables in §3 / §4 still list old file paths for traceability; runtime truth is **§0** + **`knowledge_hub`**.

### 14.2 Commands run

| Step | Command |
|------|---------|
| Format | `dart format .` |
| Analyze | `flutter analyze` |
| Tests | `flutter test` |

### 14.3 Results

| Check | Result |
|-------|--------|
| **`dart format .`** | **Pass** — 85 files, **0** reformatted (already compliant) |
| **`flutter analyze`** | **Pass** — no issues |
| **`flutter test`** | **Pass** — 5 tests, all passed |

**Unrelated failures:** None. No fixes were applied outside M13 / knowledge hub scope.

### 14.4 M13 checklist (compile + navigation)

| Item | Status |
|------|--------|
| `go_router` defines `/knowledge` (home), `/knowledge/categories`, `/knowledge/posts`, `/knowledge/posts/:slugOrId` | OK |
| Legacy `/tutorials` → `/knowledge/posts` (+ `/tutorials/*` → `/knowledge/posts/*`) | OK |
| Customer **হোম** → **জ্ঞানকেন্দ্র** → `KnowledgeHubHomeScreen` | OK (`home_screen.dart`) |
| Doctor home card → `/knowledge` | OK (`doctor_home_screen.dart`) |
| Technician dashboard → **জ্ঞানকেন্দ্র** → `/knowledge` | OK (`technician_dashboard_screen.dart`) |
| List: loading / error / empty + refresh | OK |
| Detail: `_coerceBodyText` + empty body BN placeholder | OK |
| **`AppConfig.useMockKnowledgeApi`** | **Necessary & safe:** same pattern as `useMockTechnicianApi` / `useMockBillingUi` — compile-time `bool.fromEnvironment`, **default `false`**, no runtime env file dependency. |

### 14.5 Branch file summary (expected `git status` on `feature/m13-knowledge-hub`)

**Modified**

- `lib/src/app/router.dart` — knowledge routes + legacy `/tutorials` redirect
- `lib/src/core/config/app_config.dart` — `USE_MOCK_KNOWLEDGE_API` / `useMockKnowledgeApi`
- `lib/src/features/home/home_screen.dart` — entry **জ্ঞানকেন্দ্র**
- `lib/src/features/home/doctor/presentation/doctor_home_screen.dart` — entry **জ্ঞানকেন্দ্র**
- `lib/src/features/technician_ai/presentation/technician_dashboard_screen.dart` — entry **জ্ঞানকেন্দ্র**

**Added**

- `lib/src/features/knowledge_hub/**` — models, repository (+ mock), providers, screens, widgets
- `docs/tasks/M13_KNOWLEDGE_HUB_PLAN.md` — this document

**Deleted (replaced; do not restore unless rolling back M13)**

- `lib/src/features/tutorials/application/tutorials_providers.dart`
- `lib/src/features/tutorials/data/tutorial_models.dart`
- `lib/src/features/tutorials/data/tutorial_repository.dart`
- `lib/src/features/tutorials/presentation/tutorial_detail_screen.dart`
- `lib/src/features/tutorials/presentation/tutorial_list_screen.dart`

**Also under `knowledge_hub/` (implementation detail)**

- `knowledge_models.dart`, `knowledge_repository.dart`, `knowledge_repository_mock.dart`, `knowledge_hub_providers.dart`, presentation + widgets (see repo tree).

### 14.6 Remaining / optional

- Widget tests with mocked `KnowledgeRepository` (optional).
- Manual device QA: hub → categories → filtered list → detail; legacy `/tutorials/...` deep link; mock flag + airplane mode.
- Other **docs** (`docs/KNOWLEDGE_HUB_MOBILE_PLAN.md`, `MVP_AUDIT_*`) still mention old `/tutorials` **paths** in prose — **out of M13 scope** unless you want doc-only alignment in a follow-up.

### 14.7 Final status

**Ready to commit:** `dart format .`, `flutter analyze`, and `flutter test` all **green** on `D:\PraniDoctor\pranidoctor_mobile`; **no** stale `lib/` imports to `features/tutorials`; knowledge hub compiles and entries route to `/knowledge`.

