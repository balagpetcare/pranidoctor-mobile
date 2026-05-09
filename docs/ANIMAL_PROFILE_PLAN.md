# Prani Doctor — Customer Animal Profile (Mobile) — Task Card 09

Implementation prep for **customer animal profiles** in the Flutter app ([Prani Doctor](https://pranidoctor.com/)). Scope: **Prani Doctor / Animal Doctors mobile only** — no reuse of other projects.

---

## 1. Audit summary (current repo)

| Area | Finding |
|------|---------|
| **Layout** | Feature-first under `lib/src/features/` (e.g. `auth`, `home`, `splash`, `onboarding`, `session`). Shared UI/app under `lib/src/app/` (`theme.dart`, `router.dart`, `screen_padding.dart`). Core under `lib/src/core/` (`config`, `network`, `storage`). |
| **Entry** | `lib/main.dart` → `PraniDoctorApp` (`ConsumerWidget`). |
| **State** | **Riverpod 3** (`flutter_riverpod`): `NotifierProvider` for session (`session_notifier.dart`). No codegen (`riverpod_generator` not used). |
| **Routing** | **GoRouter** (`lib/src/app/router.dart`): flat top-level routes (`/splash`, `/onboarding`, `/login`, `/home`, doctor routes). **No nested routes** under home yet. |
| **Shell** | `HomeShellScreen` uses **`IndexedStack` + `NavigationBar`** (4 tabs: হোম, অনুরোধ, আমার পশু, প্রোফাইল). Tab **“আমার পশু”** is **`_MyAnimalsPlaceholderTab`** — intended hook for this feature. |
| **Auth / tokens** | `TokenStorage` (`flutter_secure_storage`): `pd_access_token`, `pd_refresh_token`. **`dio_provider`** adds `Authorization: Bearer` when token present. **`LoginEntryScreen`** is UI-only shell — fields disabled; **no token written** on “continue”. **`SessionNotifier`** tracks role + `signOut()` clears tokens. |
| **API** | **`ApiClient`** wraps Dio with **`get` / `post` only** — **no `patch` / `delete`** yet; extend wrapper or call `_dio.patch` via accessor. Base URL: **`AppConfig.apiBaseUrl`** (`--dart-define=API_BASE_URL=...`, default `http://localhost:3000`). |
| **Theme / BN** | **`AppTheme`** Material 3, teal seed; **`locale: Locale('bn','BD')`** + `flutter_localizations`. **`fontFamilyFallback`**: Noto Sans Bengali / Noto Sans in `theme.dart`. Forms use themed **`InputDecorationTheme`** (filled, 12px radius). |
| **Shared spacing** | **`pdScreenPadding`**, **`pdReadableMaxWidth`** (`screen_padding.dart`) used on home/login. |
| **Loading** | **`CircularProgressIndicator`** on splash; no global loading widget. |
| **Errors** | No centralized API error mapper or `AsyncValue` UI helpers yet. |
| **Tests** | Default `test/widget_test.dart` only. **`flutter_lints`** in devDependencies. |
| **Docs** | **`docs/`** exists (`MOBILE_APP_FOUNDATION_PLAN.md`). |

---

## 2. Where the feature should live

Place customer animal UX under a dedicated feature folder (mirrors existing structure):

**Recommended root:** `lib/src/features/animals/` (or `customer_animals/` if you split customer vs doctor later).

- **Presentation:** screens + small widgets (list row, form sections).
- **Application:** Riverpod notifiers / controllers for list/detail/edit state.
- **Data:** repository calling `/api/mobile/animals` via `ApiClient` / Dio.
- **Domain (optional):** plain Dart models (`AnimalSummary`, `AnimalDetail`) parsed from API `{ ok, data }` envelope.

Replace **`_MyAnimalsPlaceholderTab`** body with a root widget for the animals flow (e.g. `AnimalsTabScreen`) that hosts **list** and uses **Navigator** inside the tab **or** sub-routes once router is extended.

---

## 3. Proposed folders / files

```
lib/src/features/animals/
  application/
    animals_list_notifier.dart      # AsyncNotifier / family for list (+ query includeInactive)
    animal_detail_provider.dart     # FutureProvider.family<String, Animal?>
    animal_form_notifier.dart       # create / edit submit state
  data/
    animal_repository.dart          # GET/POST/PATCH + deactivate
    animal_dto.dart                 # JSON ↔ models (matches backend DTO names)
  presentation/
    animals_tab_screen.dart         # entry from bottom nav tab
    animal_list_screen.dart
    animal_detail_screen.dart
    animal_form_screen.dart         # shared add + edit via mode flag or两个 thin wrappers
    widgets/
      animal_list_tile.dart
      animal_photo_placeholder.dart
      animal_empty_state.dart
lib/src/core/network/
  api_client.dart                   # add patch() [and delete if ever needed]
```

**Router:** Either (a) **nested `Navigator`** in the animals tab for list → detail → form without changing `go_router`, or (b) add **`StatefulShellRoute`** / child routes under `/home` for deep links (`/home/animals`, `/home/animals/:id`). Start with **(a)** for speed; document **(b)** for Phase 2.

---

## 4. Backend API endpoints to consume

Aligned with **pranidoctor-web** mobile animals API (Bearer customer JWT, `{ ok, data }` envelope).

| Method | Path | Notes |
|--------|------|--------|
| `GET` | `/api/mobile/animals` | Query: `includeInactive=true` optional. Response: `data.animals` (array). Order: active first, newest first. |
| `POST` | `/api/mobile/animals` | Create. Response: `data.animal`. |
| `GET` | `/api/mobile/animals/[id]` | Response: `data.animal`. |
| `PATCH` | `/api/mobile/animals/[id]` | Partial update. Response: `data.animal`. |
| `PATCH` | `/api/mobile/animals/[id]/deactivate` | Soft deactivate (`active: false`). Response: `data.animal`. |

**Auth:** Access token from `TokenStorage` → Dio interceptor (already). **401/403:** clear token + navigate to login when mobile auth is real.

---

## 5. Screens

| Screen | Purpose |
|--------|---------|
| **Animal list** | Tab root; cards/tiles; FAB or app bar action **“যোগ করুন”** → add form. Pull-to-refresh optional. Toggle or overflow for **inactive** (calls `includeInactive` or separate filter). |
| **Add animal** | Form → `POST`. Success → pop or show detail. |
| **Edit animal** | Form prefilled → `PATCH`. Block `customerId` / ownership fields (not in API). |
| **Animal detail** | Read-only summary + actions **সম্পাদনা**, **নিষ্ক্রিয় করুন** (confirm dialog) → deactivate PATCH. |

---

## 6. Fields (UI ↔ API)

Map to backend JSON (`animal` DTO): `animalType`, `category`, `name`, `microchipOrTag` (tag), `breed`, `dateOfBirth`, `ageYears`/`ageMonths` (read-only computed), `gender` / `sex`, `pregnancyStatus`, `notes`, `photoUrl`, `weightKg`, `active`.

| Product field | Mobile control |
|---------------|----------------|
| Animal type | Dropdown / segmented control → `animalType` enum string |
| Name or tag | Two fields or single field + chip “শুধু ট্যাগ” — backend requires **name or tag** on create |
| Breed | `TextField` → `breed` |
| Age / DOB | Date picker → `dateOfBirth` **or** integer age → `ageYears` on create (mutually exclusive per API) |
| Sex | `Dropdown` / choice chips → prefer **`gender`** enum; optional free **`sex`** if needed |
| Pregnancy | Dropdown → `pregnancyStatus` (hide or force **NOT_APPLICABLE** when type is pet dog/cat if product rules say so) |
| Notes | `TextField` multiline → `notes` |
| Photo | **Placeholder** only (network image if `photoUrl` non-null; else icon per Card 09 — no upload pipeline required yet) |

---

## 7. State management (match current style)

- Use **`flutter_riverpod`** without codegen:
  - **`AsyncNotifier`** or **`Notifier`** + **`AsyncValue`** for list/detail mutation consistency **or** simple **`FutureProvider`** + **`ref.invalidate`** after POST/PATCH/deactivate.
- Inject **`ApiClient`** via **`ref.watch(apiClientProvider)`** inside repository/providers.
- **`SessionNotifier`** stays source for sign-out; optionally set **`isAuthenticated`** when real login stores tokens.

---

## 8. Bengali UI copy plan

- **Reuse tone** from existing screens (short labels on nav: হোম, অনুরোধ, আমার পশু).
- Suggested strings (adjust with product):
  - List title: **আমার পশু**; empty: **কোনো প্রাণির তথ্য নেই**; FAB: **প্রাণি যোগ করুন**
  - Detail: **বিবরণ**, actions **সম্পাদনা**, **নিষ্ক্রিয় করুন**
  - Deactivate confirm: **এই প্রাণির প্রোফাইল নিষ্ক্রিয় করা হবে। চালিয়ে যাবেন?**
  - Errors: map API `error.code` to BN snippets (**সেশন মেয়াদ শেষ**, **যাচাইকরণ ব্যর্থ**, etc.).

Keep **`locale`** bn-BD; use **`Theme.of(context).textTheme`** for hierarchy (no hard-coded font sizes in scattered widgets).

---

## 9. Empty / loading / error plan

| State | Pattern |
|-------|---------|
| **Loading** | `Center(child: CircularProgressIndicator())` or `ListView` skeleton placeholders; **first frame** use `AsyncValue.when`. |
| **Empty** | Icon + title + subtitle + CTA (reuse placeholder layout ideas from `_PlaceholderScaffold`). |
| **Error** | `SelectableText` / `SnackBar` with message; **retry** button calling `ref.invalidate(...)` or notifier reload. |
| **401** | Future: `signOut()` + `context.go(LoginEntryScreen.routePath)`. |

Introduce a small **`pdAsyncBody`/`AsyncGap`** helper later if screens repeat the same `when` boilerplate.

---

## 10. Validation plan (client-side)

- **Create:** require **`animalType`**; require **name XOR tag** (non-empty trim), matching server rules.
- **DOB vs age:** not both; validate before submit.
- **URLs:** optional `photoUrl` — `Uri.tryParse` + scheme `http/https`.
- **Enums:** whitelist against Dart enums mirroring backend (`AnimalType`, `Gender`, `PregnancyStatus`, …).
- Use **`Form` + `GlobalKey<FormState>`** with **`TextFormField` validators** (project has no `flutter_form_builder` yet).

---

## 11. Test / build plan

| Step | Command |
|------|---------|
| Analyze | `flutter analyze` |
| Tests | `flutter test` |
| Run | `flutter run --dart-define=API_BASE_URL=<host>` (emulator: `http://10.0.2.2:3000` for Android) |

Add **widget tests** for form validation and one **repository unit test** with mocked Dio if introducing injectable HTTP client; minimum bar: keep **`flutter analyze`** clean.

---

## 12. Implementation checklist (mobile)

- [x] Extend **`ApiClient`** with **`patch`** (and optional **`delete`** unused for deactivate).
- [x] Add **`animal_repository.dart`** + DTOs parsing **`{ ok, data }`** and **`error.code`**.
- [x] Replace **`_MyAnimalsPlaceholderTab`** with real **`AnimalsTabScreen`** (list + navigation).
- [x] Implement list / detail / form / deactivate flows with Riverpod.
- [x] Wire **photo placeholder** and optional **`Image.network`** for `photoUrl`.
- [ ] After **real customer login** lands: ensure token write + authenticated-only flows.

---

## 13. Implementation adjustment (2026-05-09 — mobile build)

- **`AnimalsTabScreen`** wraps a nested **`Navigator`** (`initialRoute` + `onGenerateRoute`) so list/detail/forms stack **inside** the **“আমার পশু”** tab without changing root **`GoRouter`** (matches plan option “a”).
- **`ApiClient.patch`** added for **`PATCH /api/mobile/animals/[id]`** and **`PATCH .../deactivate`**.
- **Deactivate** uses **`PATCH /api/mobile/animals/[id]/deactivate`** (backend contract).
- **Photo:** UI shows **`AnimalPhotoPlaceholder`** + optional **`Image.network`** when `photoUrl` is http(s). **No image upload** — server accepts optional URL string only; upload pipeline remains **TODO**.

---

## 14. Document history

| Date | Change |
|------|--------|
| 2026-05-09 | Mobile audit + plan (Task Card 09) |
| 2026-05-09 | Mobile implementation + §13 adjustment |
