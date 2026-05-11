# Prani Doctor — Profile module audit & implementation plan

**Project:** Prani Doctor / Animal Doctors — Flutter mobile only  
**Repo path:** `D:\PraniDoctor\pranidoctor_mobile`  
**Scope of this document:** Audit + phased plan. **No code changes** were made to produce this file.  
**Backend:** Do not implement backend changes in this mobile repo; §3 lists API/schema work for the web/API team (`pranidoctor-web`).

**Last updated:** 2026-05-11

---

## Executive summary

The customer profile feature is centered on `lib/src/features/profile/` with `GET` / `PATCH` `/api/mobile/me`. The profile header is `ProfileHeaderCard` inside `ProfileHomeScreen`; it currently shows an in-card brand row (logo + “প্রাণী ডাক্তার”) and uses `AppBar` title “প্রোফাইল”. Location is a single free-text `area` string synced with `CustomerProfile.addressJson.areaLabel` on the server. Profile/cover photos, cropping, structured location (division → village), and customer-facing uploads are **not** wired end-to-end. The existing `UploadRepository` + `POST /api/mobile/uploads` path is used for AI technician documents; the live API route is guarded for the AI technician module, not generic customers.

---

## 1. Existing file map

### 1.1 Profile feature (`lib/src/features/profile/`)

| Area | Path | Role |
|------|------|------|
| Hub screen | `presentation/profile_home_screen.dart` | `ProfileHomeScreen`: `AppBar` title “প্রোফাইল”, `RefreshIndicator`, `ProfileHeaderCard`, sectioned menu (`PraniProfileSectionHeader` + `PraniPremiumCard` + `ProfileSettingsListTile`), `SupportContactCard`, logout. |
| Header widget | `presentation/widgets/profile_header_card.dart` | `ProfileHeaderCard`: `PraniPremiumCard`, brand row (asset logo + title), avatar, name, role chip, phone/area rows, completion banner, `PraniPrimaryCtaButton`. |
| Edit profile | `presentation/edit_profile_screen.dart` | Single long form: photo placeholder (TODO snackbar), name, email, read-only phone note, free-text area; saves via `MobileUserPatch` + `profileRepositoryProvider`. |
| Area only | `presentation/area_setting_screen.dart` | Free-text area; `PATCH` with `MobileUserPatch(area: …)`. Copy notes division/upazila “later”. |
| Settings / static | `presentation/app_settings_screen.dart`, `help_support_screen.dart`, `about_screen.dart` | Related hub entry points (not core profile data). |
| Dialog | `presentation/widgets/logout_confirm_dialog.dart` | Logout confirmation. |
| List tile | `presentation/widgets/profile_settings_list_tile.dart` | Shared menu row styling. |
| Support | `presentation/widgets/support_contact_card.dart` | Footer support card. |
| Model | `data/mobile_user_model.dart` | `MobileUser`, `MobileUserPatch`, `MobileProfileLoadStatus`, JSON keys for `area` / `profilePhotoUrl`. |
| API | `data/mobile_user_repository.dart` | `GET`/`PATCH` `/api/mobile/me`, envelope unwrap, Bengali error mapping. |
| Mock | `data/mobile_user_repository_mock.dart` | Demo user when `USE_MOCK_PROFILE_API` (see `AppConfig`). |
| Exception | `data/profile_api_exception.dart` | Typed profile errors. |
| Providers | `application/profile_providers.dart` | `profileRepositoryProvider`, `mobileUserProvider` (25s timeout, `homeNetworkDeferProvider`). |

### 1.2 Routing

| Screen | Route constant | Registered in |
|--------|----------------|---------------|
| `EditProfileScreen` | `/profile/edit` | `lib/src/app/router.dart` |
| `AreaSettingScreen` | `/profile/area` | same |
| `AppSettingsScreen` | `/profile/settings` | same |
| `HelpSupportScreen` | `/profile/help` | same |
| `AboutScreen` | `/profile/about` | same |
| AI technician subtree | `/profile/ai-technician/*` | same |

`ProfileHomeScreen` is embedded from `lib/src/features/home/home_shell_screen.dart` (profile tab), not a standalone named route.

### 1.3 Related: locations (reuse candidates)

| Path | Role |
|------|------|
| `lib/src/features/locations/data/location_repository.dart` | `fetchDistricts({divisionId})`, `fetchUpazilas`, `fetchUnions` — **no** `divisions` or `villages` in Flutter yet. |
| `lib/src/features/locations/data/location_models.dart` | `MobileLocationDto` (`id`, `slug`, `nameBn`, `nameEn`). |
| `lib/src/features/locations/application/location_providers.dart` | `districtsProvider`, `upazilasForDistrictProvider`, `unionsForDistrictUpazilaProvider`. |
| `lib/src/features/locations/presentation/guest_location_selection_sheet.dart` | District → upazila → union sheet using `PraniSearchableSelectField`, `PraniAppHeader`, tokens — **pattern to extend**, not profile-specific persistence today. |

### 1.4 Related: uploads (existing client, customer gap)

| Path | Role |
|------|------|
| `lib/src/features/uploads/data/upload_repository.dart` | `POST /api/mobile/uploads` multipart (`purpose`, `file`), progress callback. |
| `lib/src/features/uploads/data/uploaded_file_model.dart` | `UploadedFileResult`, `MobileUploadPurpose` (AI technician purposes only in Dart). |
| `lib/src/features/uploads/application/upload_providers.dart` | `uploadRepositoryProvider`. |

### 1.5 Design system components to prefer (avoid duplicate widgets)

- **Layout / surfaces:** `PraniPremiumCard`, `PraniTokens` (`PraniSpacing`, `PraniRadii`), `prani_page_insets.dart`, `screen_padding.dart` (`pdScreenPadding`, `pdReadableMaxWidth`).
- **Profile sections:** `PraniProfileSectionHeader`, `ProfileSettingsListTile` for hub navigation into sub-screens.
- **Actions:** `PraniPrimaryCtaButton`, `PraniButtons` where appropriate.
- **Async UI:** `PraniLoadingState`, `PraniErrorState` (profile hub already uses `PraniLoadingState` on load).
- **Select / search fields:** `PraniSearchableSelectField` (proven in guest location sheet).
- **Headers elsewhere:** `PraniAppHeader` (bottom sheets), `PraniScaffold` / `PraniSafePage` if sub-pages need consistent chrome.

**Dependency note:** `pubspec.yaml` includes `file_picker` but **not** `image_picker` / `image_cropper`. Photo flows will need new dependencies or a deliberate choice (e.g. `image_picker` + `image_cropper` / `crop_your_image`).

---

## 2. Required frontend changes (by product ask)

| # | Ask | Current behavior | Planned direction |
|---|-----|------------------|-------------------|
| 1 | Remove top “প্রোফাইল” from body/top | `AppBar(title: Text('প্রোফাইল'))` on `ProfileHomeScreen`. | Use `AppBar` without title, `title: const SizedBox.shrink()`, or a transparent/`SliverAppBar` that only shows actions — **one** place for chrome; no duplicate heading in scroll body (body has no H1 today). |
| 2 | Remove small logo + tag inside profile card | `ProfileHeaderCard` rows 82–101: `Image.asset(PraniAssets.primaryLogo)` + “প্রাণী ডাক্তার”. | Delete that row from the header widget; keep brand on splash/marketing elsewhere. |
| 3 | Modern header: cover, overlapping avatar, name, role, phone | Flat card + circle avatar only. | Evolve `ProfileHeaderCard` (still on `PraniPremiumCard` or a dedicated header surface): top `Stack` with cover (network/asset placeholder), avatar overlapping bottom edge, then name/role/phone. Reuse `PraniRadii` and existing typography scale. |
| 4 | Location only if configured; no fake demo line; else “লোকেশন সেটআপ করুন” | `areaMissing` uses placeholders `kPlaceholderAreaBn` / “এলাকা সেট করা হয়নি”; server or seeds may return demo text like “ঢাকা, আশুলিয়া (ডেমো)”. | Treat **structured** “no location” as empty IDs + no custom village; for **legacy** `area` string, optionally treat known demo substrings or migrate to structured flags from API. Display copy: **“লোকেশন সেটআপ করুন”** (not `kPlaceholderAreaBn`) when unset. Tap should deep-link to location edit. |
| 5 | Split profile edit into multiple sections | `EditProfileScreen` is one `ListView` with multiple `_surfaceSection`s. | **Hub pattern:** keep `EditProfileScreen` as a short index (list tiles) **or** separate routes, e.g. `/profile/edit/photos`, `/profile/edit/basic`, `/profile/edit/location` — reuse `ProfileSettingsListTile` / `PraniPremiumCard` for consistency. |
| 6 | Profile photo + cover photo separately | Only avatar preview; button shows “coming soon” snackbar. | Two upload entry points, two model fields, two crop aspect ratios (square vs wide cover). |
| 7 | Crop before upload | No picker/crop. | Add crop screen (package TBD) after pick; output file passed to `UploadRepository` or new profile attach API. |
| 8 | Server validate + compress ≤ 500KB | Client cannot guarantee server output; `UploadRepository` already maps 413. | Client: pre-compress/heuristic; **server** must enforce final stored size (§3). |
| 9 | Location: Division, District, Upazila, Union, Village | `LocationRepository` lacks divisions/villages; `AreaSettingScreen` is free text. | Add `fetchDivisions`, `fetchVillages(unionId)` mirroring web `GET /api/mobile/locations/divisions` and `.../villages?unionId=`. Cascade UI: reuse `PraniSearchableSelectField` + provider families like existing upazila/union. |
| 10 | Custom Bengali village name persisted for future pick | No Flutter or API hook in mobile. | Needs **POST** (or PATCH) to create user-scoped or global village under union + Bengali name — **backend design required** (§3). |

---

## 3. Required backend / API changes (spec only — implement in `pranidoctor-web`)

*This section documents gaps observed while auditing the mobile app against the current web API. No backend work is done in the mobile repo.*

### 3.1 `GET` / `PATCH` `/api/mobile/me`

- **Today:** Response builds `profilePhotoUrl: null` always; `area` is a single label from `addressJson.areaLabel` (`src/app/api/mobile/me/route.ts`).
- **Needed:** 
  - Persist and return **profile** and **cover** image URLs (or file IDs resolvable to CDN URLs).
  - Extend `addressJson` (or normalized columns) for **divisionId, districtId, upazilaId, unionId, villageId**, optional **customVillageNameBn**, and a computed **displayLabel** for maps/list UI.
  - `PATCH` validation for mutual consistency of hierarchy (reuse patterns from mobile locations service / `LOCATION_MISMATCH`).

### 3.2 `POST /api/mobile/uploads`

- **Today:** Route uses `requireMobileAiTechnicianModuleUser`; `MobileUploadPurpose` enum has only AI technician values (`prisma/schema.prisma`).
- **Needed for customers:** New purposes (e.g. `CUSTOMER_PROFILE_PHOTO`, `CUSTOMER_COVER_PHOTO`) **or** a dedicated profile-media endpoint; auth guard for **mobile customer** session; same storage pipeline with **final output capped at 500KB** after `sharp` (today resize/webp may already be small — enforce explicit max for these purposes).

### 3.3 Locations API vs Flutter

- **Exists on web:** `GET /api/mobile/locations/divisions`, `.../districts`, `.../upazilas`, `.../unions`, `.../villages?unionId=`, `.../search`.
- **Missing in Flutter:** `divisions` and `villages` client methods + Riverpod families.

### 3.4 Custom village creation

- **Today:** `GET /api/mobile/locations/villages` lists villages for a union; no create-from-mobile in the audited route.
- **Needed:** Authenticated endpoint to **propose/create** a village record (Bengali name, `unionId`, dedupe rules, moderation flag) and return `villageId` for profile save.

### 3.5 Demo / placeholder location strings

- Ensure seed/demo users do not populate `areaLabel` with fake geography unless marked; or return `area: null` when unset so the app can show “লোকেশন সেটআপ করুন” without string heuristics.

---

## 4. Safe step-by-step implementation sequence

1. **UI-only profile hub**  
   Remove redundant `AppBar` title; remove brand row from `ProfileHeaderCard`; implement cover + overlapping avatar + copy updates for location placeholder (**no API change** if using improved empty detection on existing `area` null/empty).

2. **Structured location read model**  
   Extend `MobileUser` / `fromJson` for optional location IDs + `coverPhotoUrl` (tolerant parsing with `??` fallbacks) **once** API contract is agreed; keep backward compatibility with flat `area` string.

3. **Location picker (read-only cascade)**  
   Add repository methods + providers for divisions and villages; build `AreaSettingScreen` (or `/profile/edit/location`) using the same UX patterns as `guest_location_selection_sheet.dart`.

4. **Profile edit navigation split**  
   Introduce hub sub-routes; move free-text fields into “Basic info”; keep location on its own screen.

5. **Image pick + crop (client)**  
   Add dependencies; square crop for avatar, wide crop for cover; local validation (dimensions, rough size).

6. **Wire uploads**  
   After backend adds customer purpose + auth: call `uploadRepository` (or thin wrapper), then `PATCH /api/mobile/me` with returned `fileId` or URL fields per contract.

7. **Custom village**  
   After POST API exists: “Other village” flow → create → select new ID → save profile.

8. **Polish & migration**  
   Migrate old `areaLabel`-only users to structured JSON; remove heuristics for demo strings if server sends null.

Each step should be shippable behind feature flags or with graceful fallback to current `area` string.

---

## 5. Data model proposal (client + API contract)

### 5.1 `MobileUser` (extended)

```dart
// Conceptual — not implemented in this plan step.
class MobileUser {
  // existing: id, name, phone, email, role, loadStatus
  String? profilePhotoUrl;
  String? coverPhotoUrl;

  /// Legacy single-line label; may be derived server-side.
  String? areaDisplayLabel;

  String? divisionId;
  String? districtId;
  String? upazilaId;
  String? unionId;
  String? villageId;

  /// When user types a village not in list; server creates row and sets villageId.
  String? customVillageNameBn;
}
```

Server `serializeMe` should prefer structured fields; `area` key can remain as **display** string for old clients.

### 5.2 `CustomerProfile.addressJson` (server shape)

```json
{
  "divisionId": "…",
  "districtId": "…",
  "upazilaId": "…",
  "unionId": "…",
  "villageId": "…",
  "customVillageNameBn": "…",
  "areaLabel": "optional computed or legacy"
}
```

### 5.3 Upload metadata

- **Profile photo:** square crop, recommended min edge e.g. 512px; purpose enum for customer.
- **Cover photo:** aspect e.g. 16:9; separate purpose; independent revision timestamps optional.

### 5.4 Village create (request sketch)

`POST /api/mobile/locations/villages` (name TBD) with body `{ "unionId": "…", "nameBn": "…" }` → `{ "id", "nameBn", … }` with idempotent dedupe on normalized name + union.

---

## 6. Testing checklist

- **Profile hub:** Guest vs loaded user; pull-to-refresh; no duplicate “প্রোফাইল” title; header layout on small/large phones and RTL-safe Bengali truncation.
- **Location empty:** `area` null, empty string, and legacy placeholders → shows “লোকেশন সেটআপ করুন”; tap opens location editor.
- **Location cascade:** Division filters districts; changing division clears lower levels; `LOCATION_MISMATCH` surfaces Bengali error.
- **Villages:** List loads per union; empty list shows message; custom name flow creates and then appears in subsequent loads (once API exists).
- **Photos:** Pick cancel; crop cancel; permission denied; upload progress; 413/415 handling; offline retry messaging.
- **PATCH:** Partial updates (only name, only photos, only location); email validation unchanged; session expiry → user-facing Bengali error.
- **Regression:** `USE_MOCK_PROFILE_API` mock still works; AI technician uploads unchanged.

---

## 7. Risks and rollback notes

| Risk | Mitigation |
|------|------------|
| Backend `PATCH` / upload not ready when UI ships | Feature-flag photo buttons; keep text-only profile; show “শীঘ্রই আসছে” only if API missing — prefer runtime detection via 404/403 on new fields. |
| `addressJson` shape drift | Version key in JSON (`"version": 2`) or strict zod on server; client tolerant parsing. |
| Large images / memory on low-end devices | Resize before crop; avoid loading full-res into RAM where possible. |
| Duplicate village names | Server normalization + dedupe; optional admin review queue. |
| Breaking old app versions | Keep `area` string in `GET` response for one release cycle. |

**Rollback:** Revert to previous `ProfileHeaderCard` and single `EditProfileScreen`; server can ignore unknown `PATCH` keys if clients send extras (prefer explicit API versioning if needed).

---

## References in this repo

- Prior profile task doc: `docs/tasks/M14_PROFILE_SETTINGS_SUPPORT_PLAN.md`
- UI polish notes: `docs/tasks/profile-ui-polish-plan.md`
