# Mobile UI — forms, keyboard, DOB, profile uploads (audit & implementation plan)

**Project:** Prani Doctor / Animal Doctors (`pranidoctor_mobile`, backend `pranidoctor-web`)  
**Scope:** AI technician application wizard, application status, technician service form, profile photos/cover, profile/settings entry points.  
**Status:** Audit complete — **implementation not started** in this task.

---

## 1. Exact Flutter files involved

### AI technician application flow

| Role | Path |
|------|------|
| Entry routing (intro / form / dashboard / status) | `lib/src/features/ai_technician_application/presentation/ai_technician_entry.dart` |
| Intro | `lib/src/features/ai_technician_application/presentation/ai_technician_intro_screen.dart` |
| 6-step wizard (`PageView`, draft/submit) | `lib/src/features/ai_technician_application/presentation/ai_technician_application_form_screen.dart` |
| Dashboard (links to services, jobs) | `lib/src/features/ai_technician_application/presentation/ai_technician_dashboard_screen.dart` |
| Router registration | `lib/src/app/router.dart` (paths under `/profile/ai-technician/…`, services `/new`, etc.) |

### Application status page

| Role | Path |
|------|------|
| Status UI + status copy | `lib/src/features/ai_technician_application/presentation/ai_technician_application_status_screen.dart` |
| Bengali titles/messages per status (incl. `PUBLISHED` → «প্রকাশিত») | `lib/src/features/ai_technician_application/data/ai_technician_models.dart` (`AiTechnicianStatusCopy`) |

### New service page

| Role | Path |
|------|------|
| Create/edit service form | `lib/src/features/ai_technician_application/presentation/ai_technician_service_form_screen.dart` |
| List → new/edit navigation | `lib/src/features/ai_technician_application/presentation/ai_technician_services_list_screen.dart` |

### Profile image / cover image

| Role | Path |
|------|------|
| Photos screen (pick/crop/save; upload gated by flag) | `lib/src/features/profile/presentation/edit_profile_photos_screen.dart` |
| Crop/compress helpers | `lib/src/features/profile/presentation/profile_photo_crop_flow.dart`, `local_profile_image_file.dart` |
| Contract + feature flags | `lib/src/features/profile/data/mobile_profile_api_contract.dart` |
| Repository (multipart upload when enabled) | `lib/src/features/profile/data/mobile_user_repository.dart` |
| Mock repository | `lib/src/features/profile/data/mobile_user_repository_mock.dart` |
| Existing doc (deps, stub behaviour) | `docs/profile_photos_crop_upload.md` |

### Profile/settings — links into these flows

| Role | Path |
|------|------|
| Profile tab hub | `lib/src/features/profile/presentation/profile_home_screen.dart` — «এআই টেকনিশিয়ান আবেদন» → `openAiTechnicianApplicationEntry`; «আমার প্রোফাইল» → edit hub |
| Edit profile hub | `lib/src/features/profile/presentation/edit_profile_screen.dart` — «ছবি ও কভার» → `EditProfilePhotosScreen` |
| Documents shortcut | `lib/src/features/profile/presentation/edit_profile_documents_screen.dart` — can open AI technician entry |

### Supporting API / uploads (AI technician)

| Role | Path |
|------|------|
| Technician HTTP client | `lib/src/features/ai_technician_application/data/ai_technician_repository.dart` |
| Providers | `lib/src/features/ai_technician_application/application/ai_technician_providers.dart` |
| Generic mobile uploads (documents in wizard) | `lib/src/features/uploads/data/upload_repository.dart`, `lib/src/features/uploads/application/upload_providers.dart` |

---

## 2. Design system widgets / tokens (existing)

Canonical tokens live in `lib/src/design_system/prani_tokens.dart`:

- **`PraniColors`** — brand + semantic colors  
- **`PraniSpacing`** / **`PraniRadius`** (`PraniRadii` alias)  
- **`PraniTextStyles`** — Bengali-friendly helpers (`body`, `label`, `caption`, `input`, `mergeMaterial2021`, etc.)

Related:

- **Theme wiring:** `lib/src/app/theme.dart` — global `InputDecorationTheme` (fill, `contentPadding`, `labelStyle`, `hintStyle`).  
- **`PraniScaffold`:** `lib/src/design_system/widgets/prani_scaffold.dart` — optional `AppBar` via `PraniAppHeader`, `resizeToAvoidBottomInset`, `bottomNavigationBar`.  
- **`PraniSectionHeader`:** `lib/src/design_system/widgets/prani_section_header.dart` — section title + subtitle (**subtitle uses `PraniTextStyles.caption` → 12px**).  
- **`PraniProfileSectionHeader`:** `lib/src/design_system/widgets/prani_profile_section_header.dart` — profile hub sections.  
- **Buttons:** **`PraniPrimaryButton` / `PraniSecondaryButton`** in `lib/src/design_system/widgets/prani_buttons.dart`. (`prani_primary_cta_button.dart` also exists — avoid duplicating patterns; pick one primary button API for forms.)  
- **Cards:** **`PraniPremiumCard`** (`lib/src/design_system/widgets/prani_premium_card.dart`) — **default `padding` is `EdgeInsets.zero`**; inner content defines spacing.  
- **Inputs / selects:** Theme + per-screen `InputDecoration`; **`PraniSearchableSelectField`** for locations (`lib/src/design_system/widgets/prani_searchable_select_field.dart`).  
- **Readable width:** `pdReadableMaxWidth` / `PraniPageInsets` (`lib/src/design_system/prani_page_insets.dart`, `lib/src/app/screen_padding.dart`).

Barrel: `lib/src/design_system/prani_design_system.dart` (re-exports).

---

## 3. Problems found (mapped to screenshots / code)

### Typography & Bengali labels

- **`PraniSectionHeader`** subtitles use **`PraniTextStyles.caption` (12px)** — matches reports of **small / cramped Bengali** on section subtitles.  
- **Global `InputDecorationTheme`** (`theme.dart`) sets **`labelStyle`** via **`PraniTextStyles.label` (14px)** and **`hintStyle`** via **`bodyMuted` (15px)** — acceptable for Latin-heavy apps but **may still feel small next to dense BN paragraphs**, especially when floating labels compete with outline borders.  
- **`PraniAppHeader`** subtitle uses **`bodyMuted`** with **`maxLines: 3`** — AppBar title stack can get **tall** next to the first card if body top padding is modest.

### Cards / padding inconsistency

- **`PraniPremiumCard`** has **no default inner padding**; **`ai_technician_application_form_screen`** nests raw **`TextFormField`** columns **without** consistent horizontal inset inside the card → **edge alignment vs screens that pad manually** differs.  
- **`AiTechnicianServiceFormScreen`** uses **`PraniScaffold` `padding`** + **`ListView`** fields **mostly without** wrapping each group in a padded card — **different rhythm** than the wizard’s card-heavy layout.

### Application status — «প্রকাশিত» / heading overlap

- First block uses **`headlineSmall` + `FontWeight.w800`** for **`AiTechnicianStatusCopy.titleBn`** (`ai_technician_application_status_screen.dart`). Combined with **`PraniScaffold` body padding** (`PraniSpacing.md` top) and **`PraniPremiumCard`** shadow/title, **visual collision with the app bar or the card top edge** is plausible on short viewports — treat as **spacing / hierarchy** fix (top padding, card `margin`, or slightly smaller status headline).

### Keyboard & bottom overflow (~29px)

- Wizard layout: **`Column`**: **[progress header] + `Expanded(PageView)` + `_buildBottomNav`**.  
- **`resizeToAvoidBottomInset: true`** on **`PraniScaffold`**.  
- Bottom bar **`Padding`** adds **`keyboardInset`** to bottom — good for **not hiding** buttons.  
- Each step uses **`SingleChildScrollView`** (`_scrollStep`). Overflow often remains when **viewport height after inset shrink** is slightly smaller than **non-scrollable interior** (e.g. **`SwitchListTile`**, **`DropdownButtonFormField` intrinsic height**, **`maxLines` text fields**) or when **scroll padding** does not include **extra inset** for the focused field.  
- **Likely hotspots:** **`_buildStepPersonal`** (step index **1**, user-facing **«ধাপ ২»**) — many fields + DOB row; **`_buildStepProfessional`** (index **2**, **«ধাপ ৩»**) — **`maxLines: 4`** bio + switches + several fields — **matches “step 2” if counting intro as step 1** or **professional as second form step**.

### Birth date

- Implemented as **`InputDecorator` + `InkWell` → `_pickDob` → `showDatePicker`** (`ai_technician_application_form_screen.dart`), stored in **`_dob` `TextEditingController`** as string (`AiTechnicianProfile.dateOfBirth`).  
- **Requirement:** replace with **three dropdowns** — month **1–12**, day **1–31**, year **1965–2015**, with **real calendar validation**.

### Profile / cover upload — incomplete end-to-end

- **`kMobileProfilePhotoPostEndpointsEnabled`** is **`false`** in `mobile_profile_api_contract.dart` → uploads short-circuit with **`endpointNotReady`** (no HTTP).  
- **`MobileUserRepositoryLive._uploadPhoto`** sends multipart field **`image`** — while **`docs/profile_photos_crop_upload.md`** documents field **`file`** → **contract mismatch** to resolve when wiring backend.  
- **Backend `GET /api/mobile/me`** (`pranidoctor-web/src/app/api/mobile/me/route.ts`) sets **`profilePhotoUrl: null`** always — **no persistence** for customer photos yet; **`CustomerProfile`** has **no** `profilePhotoUrl` / cover columns in **`schema.prisma`** (only e.g. **`DoctorProfile.profilePhotoUrl`**). **Schema + API work required** for real URLs returned to the app.

### Duplicated form UI

- Repeated **`TextFormField` + `InputDecoration` + `SizedBox`** patterns across **`ai_technician_application_form_screen.dart`**, **`ai_technician_service_form_screen.dart`**, **`edit_profile_*_screen.dart`** — **should converge** on shared widgets/styles **without** creating parallel button/card variants unnecessarily.

---

## 4. Design system changes (planned)

| Change | Rationale |
|--------|-----------|
| **Section subtitles:** stop using **`caption`** for primary BN subtitles; use **`bodySmall`** or **`label`** with explicit **≥14–15px** and comfortable **line height** (`PraniSectionHeader`). | Fix small/clipped subtitle copy. |
| **Form labels / hints:** optionally add **`PraniTextStyles.formLabel` / tune `InputDecorationTheme`** for **minimum BN-readable** label & hint sizes while keeping **touch targets**. | Align wizard + service form + profile edits. |
| **`PraniPremiumCard` or new `PraniFormSection`:** standard **`padding: EdgeInsets.all(PraniSpacing.xl)`** (or tokenized) for **form sections** so cards don’t clip labels. | Horizontal/inner spacing consistency. |
| **Sticky actions:** document pattern **`Scaffold` `bottomNavigationBar`** vs **inline `Column`** + **`SafeArea`** + **`viewInsets`** — wizard may migrate to **`bottomNavigationBar`** slot for **consistent** keyboard behaviour with **`resizeToAvoidBottomInset`**. | Bottom bar + keyboard insets. |
| **Centralized field widget:** e.g. **`PraniTextField`** wrapping **`TextFormField`** with **default decoration**, **`scrollPadding`**, optional **`PraniSpacing`** — **one place** to adjust BN typography. | “All repeated form widgets centralized.” |

Reuse **`PraniColors` / `PraniSpacing` / `PraniTextStyles`** from `prani_tokens.dart`; extend tokens rather than hardcoding.

---

## 5. Application form fixes (planned)

**File:** `ai_technician_application_form_screen.dart`

- Apply **consistent card padding** and **section spacing** (`PraniSpacing` scale).  
- Replace **date picker** flow with **month/day/year dropdowns** + validation; map to API **`dateOfBirth`** string expected by **`AiTechnicianProfile`** / **`apply`** payload (confirm backend format: **ISO `YYYY-MM-DD`** vs localized — inspect **`ai_technician_repository`** / server validation).  
- **Keyboard / overflow:** add **`MediaQuery.viewInsetsOf(context).bottom`** (or `SafeArea` bottom) to **`SingleChildScrollView` `padding`**, increase **`scrollPadding`** on fields, consider **`Scrollable.ensureVisible`** on focus; optionally switch bottom actions to **`bottomNavigationBar`**.  
- Ensure **`Theme` `inputDecorationTheme`** override (`_inputDecorationTheme`) stays consistent with **global DS** after centralization.

---

## 6. Date-of-birth dropdown approach

1. **State:** `int? birthMonth, birthDay, birthYear` (or derive from `_dob` when loading profile).  
2. **Widgets:** three **`DropdownButtonFormField<int>`** (or **`Prani`** wrapper) with items **month 1–12**, **day 1–31**, **year 1965–2015**.  
3. **Validation:** on change, run **`DateTime(year, month, day)`** in **`try/catch`** or verify **day ≤ daysInMonth(month, year)** — show field-level error for impossible dates (e.g. 31 Feb).  
4. **Persistence:** serialize to **`YYYY-MM-DD`** (recommended) before **`apply`** / draft save.  
5. **Hydrate:** parse existing **`p.dateOfBirth`** when present.

---

## 7. Keyboard overflow fix approach

1. **Reproduce** on smallest target device with keyboard open on **personal** and **professional** steps.  
2. **Scroll padding:** `_scrollStep` bottom padding **`max(PraniSpacing.section, viewInsets.bottom + extra)`**.  
3. **Focus:** set **`scrollPadding: EdgeInsets.only(bottom: …)`** on **`TextFormField`** via theme or wrapper.  
4. **Layout:** consider **`bottomNavigationBar`** for **`_buildBottomNav`** so **`body`** is only scroll + header (Flutter lays out keyboard avoidance predictably).  
5. **Avoid nested fixed-height `Column`** inside **`PageView`** without scroll.

---

## 8. Profile image / cover upload — end-to-end approach

### Mobile (`pranidoctor_mobile`)

1. Implement **`POST /api/mobile/me/profile-photo`** and **`POST /api/mobile/me/cover-photo`** consumption — align multipart **field name** with server (**`file`** vs **`image`** — fix repository + docs together).  
2. Set **`kMobileProfilePhotoPostEndpointsEnabled`** to **`true`** once backend is deployed.  
3. After success, **`ref.invalidate(mobileUserProvider)`** (already in **`edit_profile_photos_screen.dart`**).  
4. Optionally reuse **`UploadRepository`** (`/api/mobile/uploads`) + **`PATCH`** URL if product prefers **single upload pipeline** — **decision:** dedicated profile routes vs generic upload + patch **`me`** (document in API).

### Backend (`pranidoctor-web`)

1. **Persistence:** add **`profilePhotoUrl`** / **`coverPhotoUrl`** (or JSON **`media`** on **`CustomerProfile`** / **`User`**) in **Prisma** + migration.  
2. **Routes:** implement **`POST`** handlers (multipart), storage (**MinIO/S3** pattern like **`/api/mobile/uploads`**), return **`{ ok, data }`** with URLs; extend **`GET/PATCH /api/mobile/me`** to **read/write** URLs.  
3. **Security:** auth via **`requireMobileCustomer`**, validate mime/size, same-origin or signed URLs as existing uploads.

---

## 9. Application status screen polish

- Increase **top spacing** between **`AppBar`** and first **`PraniPremiumCard`** if overlap persists.  
- Optionally downgrade status title from **`headlineSmall`** to **`titleLarge`** or add **`Padding`** only for **long BN** status strings.  
- Keep **`AiTechnicianStatusCopy`** in **`ai_technician_models.dart`** — only adjust typography/layout on the screen.

---

## 10. New service form (`AiTechnicianServiceFormScreen`)

- Align **field typography** and **card/list structure** with wizard after DS updates.  
- **`resizeToAvoidBottomInset: true`** already set — add **`keyboardDismissBehavior`** / bottom **scroll padding** on **`ListView`** if keyboard covers bottom **`PraniPrimaryButton`**.

---

## 11. Backend endpoint changes (summary)

| Item | Detail |
|------|--------|
| **New (planned)** | `POST /api/mobile/me/profile-photo`, `POST /api/mobile/me/cover-photo` (multipart). |
| **Extend** | `GET` / `PATCH` `/api/mobile/me` — return and optionally accept **`profilePhotoUrl`**, **`coverPhotoUrl`** (names aligned with **`MobileUser`** parser in app). |
| **Schema** | **`CustomerProfile`** or **`User`** — persistent URL fields for customer-facing photos. |
| **Already used by AI technician docs** | `POST /api/mobile/uploads` — unchanged for technician **document** uploads; profile photos may share storage utilities (`ingestMobileUpload`, etc.). |

---

## 12. Test commands

From repo root **`pranidoctor_mobile`**:

```bash
cd D:\PraniDoctor\pranidoctor_mobile
flutter analyze
flutter test
```

Optional targeted analyze:

```bash
dart analyze lib/src/features/ai_technician_application lib/src/features/profile lib/src/design_system
```

Backend (when implementing routes):

```bash
cd D:\PraniDoctor\pranidoctor-web
npm run lint
npm run build
```

---

## 13. References (existing docs in repo)

- `docs/profile_photos_crop_upload.md` — crop/upload stub behaviour  
- `docs/AI_TECHNICIAN_FORM_STEPPER_UPLOAD_PLAN.md` — wizard + uploads overview  
- `pranidoctor-web/docs/AI_TECHNICIAN_API.md` — technician HTTP API  
- `pranidoctor-web/docs/UPLOAD_STORAGE_SETUP.md` — storage configuration  

---

## 14. Implementation order (suggested, future work)

1. Design tokens + **`PraniSectionHeader`** + **`InputDecorationTheme`** tweaks + **`PraniPremiumCard`** form padding convention.  
2. **`PraniTextField`** (or equivalent) + refactor **wizard + service form** to use it.  
3. DOB dropdowns + validation + API string format.  
4. Keyboard / scroll / bottom bar layout fixes on wizard.  
5. Backend **`me` photo** endpoints + Prisma + enable **`kMobileProfilePhotoPostEndpointsEnabled`**.  
6. Status screen spacing + regression pass on **profile hub** navigation.

---

*This document is audit-only; no production code was changed to produce it.*
