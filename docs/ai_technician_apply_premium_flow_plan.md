# AI Technician application flow — audit & premium UX plan (Prani Doctor mobile)

**Scope:** Flutter app only (`pranidoctor_mobile`). No backend changes in this document. **Implementation is out of scope for this file** — this is planning and root-cause analysis.

---

## 1. Problem statement

When registering or continuing an **AI Technician** application, the wizard body appears **almost blank or dark**: only the **sticky bottom actions** remain clearly visible (e.g. খসড়া সংরক্ষণ, ফিরে যান / পূর্ববর্তী, শুরু করুন / পরবর্তী). Step content (intro, forms, uploads, review) appears **missing, clipped, off-screen, or visually invisible**.

---

## 2. Exact affected files

### 2.1 Primary wizard & navigation

| Area | Path |
|------|------|
| **Landing / router entry** | `lib/src/features/ai_technician_application/presentation/ai_technician_entry.dart` |
| **Intro / benefits (pre-form)** | `lib/src/features/ai_technician_application/presentation/ai_technician_intro_screen.dart` |
| **Six-step wizard (main)** | `lib/src/features/ai_technician_application/presentation/ai_technician_application_form_screen.dart` |
| **Application status** | `lib/src/features/ai_technician_application/presentation/ai_technician_application_status_screen.dart` |
| **Routes** | `lib/src/app/router.dart` (paths under `/profile/ai-technician/*`) |

### 2.2 Data & API

| Area | Path |
|------|------|
| **Repository** | `lib/src/features/ai_technician_application/data/ai_technician_repository.dart` |
| **DTOs, `toApplyBody`, document types** | `lib/src/features/ai_technician_application/data/ai_technician_models.dart` |
| **Riverpod providers** | `lib/src/features/ai_technician_application/application/ai_technician_providers.dart` |

### 2.3 Supporting features

| Area | Path |
|------|------|
| **Locations (district / upazila / union)** | `lib/src/features/locations/application/location_providers.dart`, `lib/src/features/locations/data/location_models.dart` |
| **File upload** | `lib/src/features/uploads/application/upload_providers.dart`, `lib/src/features/uploads/data/upload_repository.dart`, `lib/src/features/uploads/data/uploaded_file_model.dart` |

### 2.4 Design system used by this flow

| Widget / token | Path |
|----------------|------|
| Scaffold, layout | `lib/src/design_system/widgets/prani_scaffold.dart` |
| Sticky bottom bar | `lib/src/design_system/widgets/prani_sticky_action_bar.dart` |
| Form cards | `lib/src/design_system/widgets/prani_form_card.dart`, `lib/src/design_system/widgets/prani_premium_card.dart` |
| Fields | `lib/src/design_system/widgets/prani_form_fields.dart`, `lib/src/design_system/widgets/prani_form_tokens.dart` |
| DOB (month/day/year) | `lib/src/design_system/widgets/prani_date_parts_field.dart` |
| Searchable selects | `lib/src/design_system/widgets/prani_searchable_select_field.dart` |
| Section titles | `lib/src/design_system/widgets/prani_section_header.dart` |
| Info / error / loading | `lib/src/design_system/widgets/prani_info_card.dart`, `prani_error_state.dart`, `prani_loading_state.dart` |
| Bottom sheet (add service area) | `lib/src/design_system/widgets/prani_bottom_sheet.dart` |
| Buttons | `lib/src/design_system/widgets/prani_buttons.dart` |
| Page insets | `lib/src/design_system/prani_page_insets.dart` |
| Readable width helper | `lib/src/app/screen_padding.dart` (`pdReadableMaxWidth`) |
| Theme | `lib/src/app/theme.dart` |
| Color semantics | `lib/src/design_system/prani_color_scheme_ext.dart` |

---

## 3. Step mapping (product vs code)

The intro screen (`AiTechnicianIntroScreen`) is **separate** from the wizard. Inside `AiTechnicianApplicationFormScreen`, **`totalSteps = 6`** pages are:

| Step index (0-based) | User-facing role | Builder |
|---------------------|------------------|---------|
| 0 | Intro / benefits inside wizard | `_buildStepIntro` |
| 1 | Personal information | `_buildStepPersonal` |
| 2 | Professional / training / experience | `_buildStepProfessional` |
| 3 | Address + division service areas | `_buildStepAddress` |
| 4 | Documents / photos | `_buildStepDocuments` |
| 5 | Review & submit | `_buildStepReview` |

**Note:** Step 0 duplicates some messaging from `AiTechnicianIntroScreen` by design (wizard onboarding vs profile marketing page).

---

## 4. Root cause analysis — blank / dark body

### 4.1 Observed layout structure (editable wizard)

For the editable state, the scaffold uses:

- `body: Stack` → `Column` with:
  - **Fixed header** (`Padding`): correction note, `_fieldError`, `_stepError`, step title **"ধাপ X / ৬"**, `LinearProgressIndicator`
  - **`Expanded`** → `Theme.copyWith(inputDecorationTheme: …)` → **`Form`** → **`PageView`** (`NeverScrollableScrollPhysics`) → per-step `_scrollStep` → **`SingleChildScrollView`**

- **`bottomNavigationBar`:** `PraniStickyActionBar` with `_buildBottomActions` (draft, back/prev, next/submit).

So the **visible “only bottom buttons”** symptom isolates failure to the **body’s scrollable/page region** (or its perceived emptiness), not the sticky bar itself — unless the bar were incorrectly placed over the body (here it is correctly **`bottomNavigationBar`**, not stacked on top of the form).

### 4.2 Likely causes (ordered for verification)

1. **Layout / viewport height**
   - **`Expanded` + `PageView`**: Normally correct; on edge-to-edge, IME, or rare device quirks, verify the **`Expanded`** child receives **non-zero height** (Flutter Inspector, debug paints).
   - **`resizeToAvoidBottomInset: true`** shrinks the body when the keyboard opens; combined with a large header block, the remaining area can become **very small**, feeling “empty” until the user scrolls.

2. **Scroll / inset interaction**
   - `_scrollStep` adds bottom padding: `PraniSpacing.section + MediaQuery.viewInsetsOf(context).bottom + 32`.
   - If **`viewInsets`** or **`padding`** is mis-read in a nested context (e.g. dialog or split-screen), content can be **pushed awkwardly** or feel clipped; verify on target Android versions.

3. **Theme / contrast (dark mode)**
   - Dark scaffold (`AppTheme` / `PraniColors.darkScaffold` via color scheme) vs elevated cards (`praniElevatedCard`) should still contrast. If any subtree accidentally uses **wrong `ColorScheme` brightness** or **hardcoded light-only colors**, body text could **blend into the background**.
   - Inner `Theme.of(context).copyWith(inputDecorationTheme: …)` **only** overrides input decoration; it should **not** strip `colorScheme`, but **merge behaviour** should be double-checked during implementation.

4. **Missing `Material` ancestor for inputs**
   - `PraniPremiumCard` uses `DecoratedBox`, not `Material`. `TextFormField` generally still paints, but **Material** is recommended for ink focus and consistent elevation; worth validating on devices showing odd painting.

5. **Progress indicator contrast**
   - `LinearProgressIndicator` uses `backgroundColor: scheme.surfaceContainerHighest` but **no explicit `color`** (value bar); low contrast may make progress feel “missing” (does not remove cards, but worsens perceived emptiness).

6. **Typography / fonts**
   - Bengali glyphs missing or failing on some devices could make content **appear blank**; validate **Noto Sans Bengali** (or configured font family) on rural/low-end devices.

7. **State / loading**
   - `_bootstrap` sets `_loading` then `_profile`; if `_profile` were null after load, the code uses `_profile!` — would **throw** rather than silent blank. So **silent blank** more likely **layout/theme/font** than **null profile** after successful load.

### 4.3 Root cause conclusion (for implementation phase)

Treat the bug as **multi-factor**: prioritize **(A) constrained height / keyboard interaction**, **(B) theme and text contrast in dark mode**, **(C) scroll padding and focus scroll-into-view**, then **(D) font / Material**.

---

## 5. Step-by-step form architecture (target)

**Goals:** One wizard controller (`PageController`), **one `Form`**, step validators, **draft via same payload shape** as submit prep, **Riverpod** for async server state.

**Suggested structure (incremental refactor when implementing):**

1. **Shell:** `PraniScaffold` + optional compact **step header** (progress + step title) either **inside** scroll for small screens or fixed with **sliver** pattern if needed.
2. **Body:** Prefer **`PageView`** OR **`IndexedStack`** + explicit step widgets; each step returns **`SingleChildScrollView`** with **`LayoutBuilder`** / min height guard so content never “collapses”.
3. **Bottom:** `PraniStickyActionBar` — minimum tap height (≥ 48dp), clear primary/secondary hierarchy.
4. **State:** Local controllers + `_dirty`; **`apply`** on draft save; **`submit`** once validation passes.

**Scalability:** Extract step UI into **`ai_technician_application_steps/`** (optional) so future provider types can reuse **`PraniFormCard`**, **`PraniSectionHeader`**, and validation helpers without copying screens.

---

## 6. Reusable components (reuse — do not duplicate)

Already used and should stay central:

- **`PraniFormCard`**, **`PraniSectionHeader`**, **`PraniTextField`**, **`PraniTextArea`**, **`PraniDropdownField`**, **`PraniSearchableSelectField`**, **`PraniDatePartsField`**, **`PraniStickyActionBar`**, **`PraniPrimaryButton`**, **`PraniSecondaryButton`**, **`PraniInfoCard`**, **`PraniErrorState`**.

**Potential small additions (implementation phase only):**

- **`PraniWizardShell`** — header + scroll region + bottom bar spacing contract.
- **`PraniStepProgress`** — accessible progress (labels + semantics).
- **`PraniDocumentSlot`** — uniform upload row (label, status, actions).

---

## 7. Form fields per step

### Step 0 — Wizard intro (`_buildStepIntro`)

- Informational only (no inputs). Lists six steps and benefits.

### Step 1 — Personal (`_buildStepPersonal`)

| Field | Controller / state |
|-------|-------------------|
| Display name * | `_displayName` |
| Phone | `_phone` |
| Email (optional) | `_email` |
| NID number (optional) | `_nid` |
| Date of birth (optional) | `_dob` via **`PraniDatePartsField`** |
| Gender | `_gender` |

### Step 2 — Professional (`_buildStepProfessional`)

| Field | Controller / state |
|-------|-------------------|
| Bio / intro | `_bio` |
| Service fee BDT (optional) | `_fee` |
| Accepts emergency | `_acceptsEmergency` |
| Experience years (optional) | `_experienceYears` |
| Training provider | `_training` |
| Certificate number | `_certNo` |
| Certification notes | `_certification` |

### Step 3 — Address & service areas (`_buildStepAddress`)

| Field | State |
|-------|--------|
| Present address | `_presentAddress` |
| District * | `_selectedDistrict` |
| Upazila * | `_selectedUpazila` |
| Union / area (optional) | `_selectedUnion` |
| Division coverage areas | `p.divisionCoverageAreas` (+ add/remove via API) |

### Step 4 — Documents (`_buildStepDocuments`)

| Slot | Type constant |
|------|----------------|
| NID front * | `NID_FRONT` |
| NID back * | `NID_BACK` |
| Optional slots | `PROFILE_PHOTO`, `TRAINING_CERTIFICATE`, `AI_CERTIFICATE`, `COMPANY_ID`, `EXPERIENCE_PROOF`, `OTHER` |

### Step 5 — Review (`_buildStepReview`)

- Read-only summary of controllers + `p.documents` + `p.divisionCoverageAreas`.

---

## 8. Validation rules per step

Aligned with current code in `ai_technician_application_form_screen.dart`:

| Step | Rule |
|------|------|
| 0 | No validation (`_validateStep` returns true). |
| 1 | **`_validatePersonalStep`:** display name trim length ≥ 2; if email non-empty → basic email regex. |
| 2 | **`_validateProfessionalStep`:** if experience field non-empty → integer 0–80. |
| 3 | **`_validateAddressStep`:** district and upazila required. |
| 4–5 | No step gate in `_validateStep` (documents enforced on **submit**). |

**Submit (`_submit`):**

- Runs **`FormState.validate()`** (field validators).
- District + upazila non-null.
- **`_hasNid`:** both `NID_FRONT` and `NID_BACK` present in `p.documents`.
- **`divisionCoverageAreas` non-empty.**

---

## 9. DOB selector rule (product)

Implemented in **`PraniDatePartsField`**:

- **Month:** 1–12  
- **Day:** 1–31 (capped by real calendar month/year via `_daysInMonth`)  
- **Year:** **1965–2015** inclusive (`List.generate(2015 - 1965 + 1, …)` reversed)

Stored as ISO **`YYYY-MM-DD`** when complete; partial selection emits empty / null until valid.

---

## 10. Document upload UX plan

**Current behaviour:** `FilePicker` → `uploadRepository.uploadMobileFile` → `repository.addDocument` → `_bootstrap()` refresh.

**Premium / field-friendly improvements (implementation phase):**

1. **Per-slot clarity:** Required vs optional labels; max size messaging (raster ~5 MB, PDF slots ~10 MB — aligned with `_maxRasterUploadBytes` / `_maxDocumentSlotBytes`).
2. **States:** Idle / picking / uploading (determinate progress when available) / success / failed with **retry**.
3. **Preview:** Thumbnail for images; PDF icon + filename.
4. **Offline / failure:** Clear Bengali errors (`AiTechnicianApiException` / `UploadApiException` messages already surfaced via `_stepError`).
5. **Accessibility:** Large touch targets on **ফাইল বেছে নিন** / **পুনরায় আপলোড**.

---

## 11. Draft save / restore plan

**Create profile:** `_bootstrap` calls `fetchMe()`; if `profile == null`, **`POST …/apply` with `{}`** creates draft, then `_fill`.

**Save draft:** **`_saveDraft`** → **`apply(_collectApplyBody())`** → updates `_profile`, snackbar “খসড়া সংরক্ষিত হয়েছে।”, invalidates `aiTechnicianMeProvider`.

**Restore on open:** Same **`fetchMe`** + `_fill`; location hydration via **`_hydrateLocationSelections`**.

**Leave guard:** `PopScope` + `_dirty` → dialog if unsaved changes.

**Future hardening (optional):** Debounced auto-save; explicit “last saved at” line in subtitle.

---

## 12. Keyboard overflow fix plan

1. Keep **`resizeToAvoidBottomInset: true`** on wizard scaffold.
2. **`_scrollStep`:** retain `viewInsets` bottom padding; consider **`Scrollable.ensureVisible`** on focus for critical fields (implementation).
3. **`PraniTextField` / `PraniTextArea`:** already use **`scrollPadding`** via `PraniFormTokens.scrollBottomInset` — verify cumulative padding does not double-count with `_scrollStep`.
4. Avoid **`Stack`** overlays that steal taps during IME unless intentional.

---

## 13. Bengali typography & spacing plan

1. **Body line height** ~1.35–1.45 for paragraphs (already used in several places).
2. **Section rhythm:** `PraniSpacing.sm` / `md` / `lg` between sections; **`PraniFormTokens.fieldGap`** between inputs.
3. **Readable width:** `pdReadableMaxWidth` (~520 max) — keep centered **`ConstrainedBox`**.
4. **Numerals:** Step labels use Bengali numerals via `_bnStepNumeral` where applicable.
5. **Large touch targets:** Buttons already target ≥48dp in theme — keep sticky actions **full-width** on narrow phones.

---

## 14. Design goals checklist

- [ ] Premium, calm surfaces (`PraniFormCard`, consistent borders/shadows).
- [ ] Bengali-first copy and readable line lengths.
- [ ] Large tap targets and clear primary action per step.
- [ ] Obvious **progress** (step X/6 + linear indicator + semantics).
- [ ] Document uploads understandable in one glance per slot.
- [ ] Draft safety (save + dirty guard).
- [ ] Architecture ready for **other provider types** (shared form primitives, separate step modules).

---

## 15. Test commands

From repo root `pranidoctor_mobile`:

```bash
flutter analyze
flutter test
```

Optional on-device / emulator:

```bash
flutter run
```

---

## 16. Strict rules reminder (this initiative)

- Do **not** delete files.
- Do **not** rewrite the whole app.
- Do **not** duplicate design-system widgets.
- **Backend / API** changes are **out of scope** for the implementation tied to this plan unless separately requested.

---

*Document generated for audit and implementation planning — Prani Doctor / Animal Doctors mobile app only.*
