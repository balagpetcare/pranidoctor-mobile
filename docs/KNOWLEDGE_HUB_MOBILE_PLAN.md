# Prani Doctor — Knowledge Hub (Mobile)

Scope: [Prani Doctor](https://pranidoctor.com/) customer & doctor Flutter app only — no other products.

Backend reference: [pranidoctor-web](https://github.com/balagpetcare/pranidoctor-web) (`/api/mobile/tutorials/*`).

---

## 1. Current mobile audit (2026-05-09)

| Area | Finding |
|------|---------|
| **Structure** | Feature-first under `lib/src/features/*`; shared `lib/src/core/*`, `lib/src/app/*`. |
| **Routing** | `go_router` (`lib/src/app/router.dart`); `goRouterProvider` + `MaterialApp.router`. |
| **API** | `ApiClient` + `dioProvider` (`AppConfig.apiBaseUrl`, `--dart-define=API_BASE_URL=...`). Response envelope `{ ok, data }` / `{ ok: false, error }` — same as web mobile APIs. |
| **State** | `flutter_riverpod` (`Provider`, `FutureProvider.autoDispose`, `NotifierProvider` for category filter). |
| **Theme** | `AppTheme` — teal seed, Bengali `fontFamilyFallback`, `locale: bn_BD` in `PraniDoctorApp`. |
| **Home shell** | `HomeShellScreen` — bottom nav: হোম, অনুরোধ, আমার পশু, প্রোফাইল. Knowledge Hub is a **stack route** from হোম (not a fifth tab). |
| **Doctor** | `DoctorHomeScreen` minimal shell; same public tutorial routes as customer. |
| **Docs folder** | `docs/` exists (`MOBILE_APP_FOUNDATION_PLAN.md`, animal profile plans, etc.). |

---

## 2. API endpoints (web repo)

All **public** (no Bearer required). Base URL = `AppConfig.apiBaseUrl`.

| Method | Path | Purpose |
|--------|------|---------|
| `GET` | `/api/mobile/tutorials/categories` | Active categories (`data.categories[]`: `id`, `nameBn`, `nameEn`, `slug`, …). |
| `GET` | `/api/mobile/tutorials` | Published + approved list. Query: `take`, `skip`, optional **`categoryId`** *or* **`categorySlug`** (not both). |
| `GET` | `/api/mobile/tutorials/{slugOrId}` | Single published tutorial (`data.tutorial`, includes `body`). |

Server only returns **approved** and **published** posts on these routes.

**Seeded category labels** (after `npm run seed` on web): গরুর রোগ, ছাগলের রোগ, AI / প্রজনন, টিকা, কৃমিনাশক, খাদ্য ব্যবস্থাপনা, জরুরি চিকিৎসা — slugs such as `gorur-rog`, etc.

---

## 3. Screen list

| Screen | Route | Notes |
|--------|-------|--------|
| Tutorial list + category chips | `/tutorials` | Pull-to-refresh; filter by `categoryId`; cards with title, summary, category, date, optional cover. |
| Tutorial detail | `/tutorials/:slugOrId` | Full `body` (plain text), metadata, cover, retry + back on error. |

**Entry points**

- Customer: হোম → menu **টিউটোরিয়াল** → `/tutorials`.
- Doctor: চিকিৎসক হোম → **নলেজ হাব (টিউটোরিয়াল)** → `/tutorials`.

No separate “category-only” screen: categories are horizontal chips on the list (fits current `go_router` style).

---

## 4. State management

- `tutorialRepositoryProvider` → `TutorialRepository(ApiClient)`.
- `tutorialCategoriesProvider` — `FutureProvider.autoDispose` for `GET .../categories`.
- `selectedTutorialCategoryIdProvider` — `NotifierProvider<..., String?>`; `null` = “সব”.
- `tutorialsListProvider` — `FutureProvider.autoDispose` reads filter + calls `listPublishedTutorials(categoryId: ...)`.
- `tutorialDetailProvider(slugOrId)` — `FutureProvider.autoDispose.family` for detail.

---

## 5. Loading / empty / error

| State | Behavior |
|-------|----------|
| **Loading** | List: full-page `CircularProgressIndicator` for tutorials; small spinner in chip row for categories. Detail: centered spinner. |
| **Empty** | Bengali copy when no published items (all vs filtered category). |
| **Error** | List: message + **আবার চেষ্টা করুন** (`ref.invalidate`). Categories: inline error + **রিফ্রেশ**. Detail: retry + **তালিকায় ফিরুন**. |
| **Network** | `TutorialRepository` maps `DioException` to short Bengali messages. |

---

## 6. Testing checklist

**Manual (with running web API + seed)**

- [ ] `API_BASE_URL` points to dev server (e.g. emulator `http://10.0.2.2:3000`).
- [ ] Categories load; chip labels match API (seven BN categories when seeded).
- [ ] “সব” shows all published tutorials; each category chip filters list.
- [ ] Card opens detail with slug; approved content shows `body`.
- [ ] Pull-to-refresh reloads categories + list.
- [ ] Airplane mode / wrong URL → error UI + retry works.
- [ ] Doctor home entry opens same list as customer.

**Automated**

- [ ] `flutter analyze` clean.
- [ ] `flutter test` passes.
- [ ] `flutter build apk --debug` succeeds.

---

## 7. Changed files log (mobile)

| File | Change |
|------|--------|
| `lib/src/features/tutorials/data/tutorial_models.dart` | DTOs for category, list item, detail. |
| `lib/src/features/tutorials/data/tutorial_repository.dart` | Mobile tutorial API + `{ok,data}` unwrap. |
| `lib/src/features/tutorials/application/tutorials_providers.dart` | Riverpod providers. |
| `lib/src/features/tutorials/presentation/tutorial_list_screen.dart` | List, chips, cards, states. |
| `lib/src/features/tutorials/presentation/tutorial_detail_screen.dart` | Detail + states. |
| `lib/src/app/router.dart` | `/tutorials` + nested `:slugOrId`. |
| `lib/src/features/home/home_screen.dart` | হোম menu **টিউটোরিয়াল** → list. |
| `lib/src/features/home/doctor/presentation/doctor_home_screen.dart` | নলেজ হাব card → list. |
| `docs/KNOWLEDGE_HUB_MOBILE_PLAN.md` | This document. |

`dart format .` may touch additional `lib/` files without functional changes.

---

## 8. Current status (Task Card 14 — complete)

- [x] List + category filter + detail wired to **`/api/mobile/tutorials/*`**.
- [x] Loading / empty / error + retry; Bengali-first copy; theme-aligned cards.
- [x] Customer + doctor entry paths to **`/tutorials`**.

---

## 9. Final implementation summary

The Flutter app treats Knowledge Hub as **read-only public content**: categories and posts come from the web API; only **`APPROVED`** + **`isPublished`** posts appear. Doctors and customers share the same in-app catalog (no separate doctor-only tutorial list).

---

## 10. End-to-end scenario checklist

- [ ] **Admin** creates **category** (web UI or `POST /api/admin/content-categories`).
- [ ] **Admin** creates **post** draft (`POST /api/admin/tutorials`).
- [ ] **Doctor** creates **draft** (`POST /api/doctor/tutorials`).
- [ ] **Doctor** **submits** (`POST /api/doctor/tutorials/[id]/submit`).
- [ ] **Admin** **approves** → **`APPROVED`** + **`isPublished: true`** on server.
- [ ] **Admin** **rejects** with reason → doctor can revise and resubmit.
- [ ] **Mobile** lists tutorials (`GET /api/mobile/tutorials`) — only approved + published.
- [ ] **Mobile** **filters** by category (`categoryId` / `categorySlug`).
- [ ] **Mobile** **detail** (`GET /api/mobile/tutorials/[slugOrId]`).
- [ ] **Draft / pending / rejected** posts **never** appear on mobile public routes.

---

## 11. Verification (latest — Task Card 14 closure)

| Command | Result |
|---------|--------|
| `flutter pub get` | Pass |
| `dart format .` | Pass |
| `flutter analyze` | No issues |
| `flutter test` | Pass |
| `flutter build apk --debug` | Pass |

---

## 12. Known limitations

- **Body format:** Plain text (no Markdown renderer).
- **Pagination:** Single fetch (`take` 50) on list; no infinite scroll.
- **Offline:** No cached tutorial content on device.
- **Categories:** Inactive categories are omitted from the public category API; chips are driven from that response.

---

## 13. Next task — Task Card 15

**Notification system** for service-request status, optional editorial/approval alerts, and customer/doctor updates — build on existing Prani Doctor notification models and admin **বিজ্ঞপ্তি** patterns.
