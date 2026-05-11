# AI Technician application wizard — autosave, step persistence, uploads, publish gating (audit & plan)

**Mode:** Plan only — **no implementation** in this pass.  
**Scope:** Flutter mobile (`pranidoctor_mobile`) first; backend (`pranidoctor-web`) only where contract gaps block the UX goals.

---

## 1. Affected mobile files

| Role | Path |
|------|------|
| Wizard shell, steps, draft save, submit, uploads, DOB field | `lib/src/features/ai_technician_application/presentation/ai_technician_application_form_screen.dart` |
| Riverpod: `fetchMe` / repository | `lib/src/features/ai_technician_application/application/ai_technician_providers.dart` |
| API client + DTOs | `lib/src/features/ai_technician_application/data/ai_technician_repository.dart`, `ai_technician_models.dart` |
| Entry routing (no `initialStep` when opening form) | `lib/src/features/ai_technician_application/presentation/ai_technician_entry.dart` |
| Intro → form with `extra: 1` | `lib/src/features/ai_technician_application/presentation/ai_technician_intro_screen.dart` |
| GoRouter: `initialStep` from `state.extra` | `lib/src/app/router.dart` |
| Status screen → form / invalidate `me` | `lib/src/features/ai_technician_application/presentation/ai_technician_application_status_screen.dart` |
| Dashboard → form (no step extra) | `lib/src/features/ai_technician_application/presentation/ai_technician_dashboard_screen.dart` |
| Service area sub-route + invalidate | `lib/src/features/ai_technician_application/presentation/ai_technician_service_area_selection_screen.dart` |
| Multipart upload + progress | `lib/src/features/uploads/data/upload_repository.dart`, `uploaded_file_model.dart`, `upload_providers.dart` (if used) |
| DOB UI (already day/month/year + ISO) | `lib/src/design_system/widgets/prani_date_parts_field.dart` |
| Upload slot UI | `lib/src/design_system/widgets/prani_upload_card.dart` |
| **Reuse for crop** (customer profile) | `lib/src/features/profile/presentation/profile_photo_crop_flow.dart` |

**Stale doc (do not treat as source of truth for DOB):** `docs/AI_TECHNICIAN_FORM_STEPPER_UPLOAD_PLAN.md` still mentions `showDatePicker`; the live form uses `PraniDatePartsField`.

---

## 2. Affected backend files (only if contract extension is chosen)

Today the mobile contract is sufficient for **draft profile + documents**; there is **no** `currentStep` / `lastCompletedStep` on `AiTechnicianProfile` in the mobile DTO (`ai_technician_models.dart`).

| Area | Typical paths (web) |
|------|----------------------|
| Mobile apply / me / submit | `src/app/api/mobile/ai-technician/apply/route.ts`, `me/route.ts`, `submit/route.ts` |
| Serialization | `src/lib/mobile-ai-technician/application-service.ts` (or adjacent `serializeTechnicianProfile`) |
| Optional: persist wizard step | Prisma `AiTechnicianProfile` + migration — **only if** product requires server-authoritative step (not strictly required if mobile persists step locally). |

**Default recommendation:** fix step reset **client-side** first (loading overlay + local persistence). Add backend `wizardStep` **only** if you need cross-device continuity or admin visibility.

---

## 3. Root cause analysis — why the wizard “jumps” to the first / intro step

### 3.1 Wizard step 0 vs marketing intro

- **Step 0** inside the form is **“পরিচিতি”** (`_buildStepIntro`) — in-wizard copy, not `AiTechnicianIntroScreen`.
- Users often describe this as “intro” because it mirrors marketing content.

### 3.2 Primary technical suspect: `_bootstrap()` + `_loading` swaps out the `PageView`

In `ai_technician_application_form_screen.dart`:

- `_bootstrap()` starts with `setState(() { _loading = true; ... })`.
- While `_loading` is true, `build()` returns a **minimal** `PraniScaffold` with only `PraniLoadingState` — the **`PageView` is not built at all**.
- After upload, delete document, delete service area, or return from service-area selection, code calls **`await _bootstrap()`** again (e.g. `_uploadDocumentSlot` after `addDocument`, `_delDoc`, `_openServiceAreaSelection` on return).

**Why this resets the visible step:**

1. **`PageController` / `PageView` lifecycle:** When the `PageView` is removed from the tree, the scroll position attachment can be lost or **reinitialized** when the `PageView` is inserted again. The state field `_stepIndex` may still hold the old index, but the **controller’s page** can snap to **0** on re-attach, and/or `onPageChanged` may run with **0**, executing `setState(() => _stepIndex = i)` and **overwriting** `_stepIndex`.

2. **No explicit resync:** After `_bootstrap()` completes, there is **no** `_pageController.jumpToPage(_stepIndex)` (or `animateToPage`) to force the controller to match the intended step.

**Action for implementation phase:** Confirm with logging (`onPageChanged`, `_stepIndex`, `controller.page`) during upload → `_bootstrap()` → rebuild. Then fix by one or more of: (a) **non-destructive** refresh (keep `PageView` mounted, show a **Stack** overlay loader), (b) after every successful `_bootstrap()` when `_stepIndex > 0`, **`jumpToPage(_stepIndex)`**, (c) `AutomaticKeepAliveClientMixin` on page children — secondary to (a)/(b).

### 3.3 Route / `initialStep` — re-entry always step 0 except from intro

- `router.dart` passes `initialStep: state.extra is int ? state.extra as int : null`.
- `openAiTechnicianApplicationEntry` pushes **`AiTechnicianApplicationFormScreen.routePath` with no `extra`** → `initialStep == null` → `initState` uses **0**.
- `AiTechnicianIntroScreen` correctly passes **`extra: 1`** so users skip the in-wizard intro **only** when coming from that button.
- `ai_technician_dashboard_screen.dart` pushes the form **without** `extra` — same as entry.

So: any **new** navigation that **recreates** the `State` starts at step 0 unless callers pass `extra`.

### 3.4 `ref.invalidate(aiTechnicianMeProvider)` after save/upload

- The form screen **does not** `watch(aiTechnicianMeProvider)` in `build`; it keeps local `_profile`.
- Invalidate mainly affects **other** screens (`application_status_screen`, etc.). Low probability it alone pops the route; still worth avoiding redundant invalidates during wizard if they trigger parent rebuilds in future.

### 3.5 Submit / status — not the same as “upload reset”

- Successful **submit** uses `context.pushReplacement(AiTechnicianApplicationStatusScreen.routePath)` — intentional navigation off the wizard.
- If `profile.isEditable` becomes false after refresh, `build` shows a **read-only** scaffold — different from step 0, but can feel like “kicked out” of editing.

---

## 4. Correct wizard state model (target)

Separate concerns:

| Layer | Responsibility |
|-------|----------------|
| **Route `extra`** | Optional **initial** step only when **first** opening the screen (or explicit “resume here”). |
| **Ephemeral UI state** | `_stepIndex` + `PageController` must **stay in sync** across partial reloads. |
| **Authoritative draft payload** | Server profile via `GET me` / `POST apply` — fields, `documents`, `divisionCoverageAreas`. |
| **Local persistence (recommended)** | `SharedPreferences` (or secure storage): `lastWizardStep`, optional `lastWizardUpdatedAt`, until submit succeeds or user clears. Restores after kill/restart and complements `initialStep`. |
| **Optional server field** | `wizardLastStep` on profile — only if cross-device resume is required. |

**Invariant after fix:** Upload / save / `fetchMe` refresh must **not** change `_stepIndex` unless the user navigates steps or validation intentionally jumps (already used in `_submit` for missing NID/areas).

---

## 5. Auto-save strategy per step

**Current:** `_saveDraft` only on explicit **“খসড়া সংরক্ষণ”**; `_goNext` validates locally but **does not** call `apply`.

**Target:**

| Event | Behavior |
|-------|----------|
| **Next** | After step validation passes, **`await apply(_collectApplyBody())`** (debounced or guarded by `_saving`), then advance page. On failure, stay on step + snackbar. |
| **Leaving step** (optional) | Same as Next for steps 1–4 if you want parity with “completed = saved”. |
| **Document attach / delete** | Already triggers server writes (`addDocument` / `deleteDocument`) + `_bootstrap`; optionally also **`apply`** if non-document fields must be persisted in same transaction (usually unnecessary). |
| **Service areas** | Sub-screen already persists via API; parent `_bootstrap` on return — keep step (see §3). |
| **Throttle** | Debounce `apply` if many toggles; show non-blocking “সংরক্ষিত” for autosave. |

**Do not** rewrite the whole form: extend `_goNext` / small helper `_persistDraftIfNeeded()`.

---

## 6. Document / image upload strategy

**Current flow:** `FilePicker` → size check → `UploadRepository.uploadMobileFile` (`onSendProgress`) → `AiTechnicianRepository.addDocument` → **`_bootstrap()`**.

**Gaps vs requested UX:**

| Requirement | Current | Plan |
|-------------|---------|------|
| Preview | `PraniUploadCard` + `_documentPreviewWidget` (network image / PDF row) | Keep; improve error placeholder for failed decode |
| Crop before upload | **None** | Pipe image slots through **`profile_photo_crop_flow.dart`** (or thin wrapper) → temp file → upload |
| Replace / re-upload | `onUpload` always available | Explicit **“পুনরায় আপলোড”** label when `existing != null` |
| Delete | `onRemove` → `_delDoc` | OK |
| Progress | `_uploadProgressFraction` → `PraniUploadCard` | OK |
| Retry on failure | User taps upload again | Add **retry** affordance on error state (same slot, last path optional) |

**Strict rule:** Reuse `PraniUploadCard` + existing upload repo; add crop as a **pre-upload** step only for raster slots (`PROFILE_PHOTO`, `COVER_IMAGE`, `NID_*`).

---

## 7. Image crop / preview strategy

- **Reuse** `profile_photo_crop_flow.dart` (or extract shared `PraniImageCropSheet` if profile flow is too customer-specific).
- Flow: pick → **optional** crop UI → write temp JPEG/PNG within cap → existing upload pipeline.
- PDF slots: no crop; keep picker as today.

---

## 8. DOB dropdown strategy

**Already implemented:** `PraniDatePartsField` in personal step:

- Day list respects month/year length (incl. Feb).
- Month 1–12 with Bengali month names.
- Year list **1965–2015** (see `prani_date_parts_field.dart` `itemsYear`).
- Emits **`YYYY-MM-DD`** or `null` when incomplete; validates invalid calendar dates.

**Plan work (small):**

- Confirm product wants DOB **optional** vs **required** for technicians (`optional: true` today).
- Ensure `_fill` ISO strings from API always parse (timezone-safe `DateTime.tryParse` on date-only).
- UX: helper text in Bengali for age band (50+ etc.) if compliance needs it.

---

## 9. Final review / publish gating strategy

**Current:**

- `_goNext`: steps **4** (documents) and **5** (review) — `_validateStep` returns **true** without checking required docs.
- **Review** shows `_reviewWarnings` but user can still land on review early.
- **`_submit`:** `FormState.validate()`, address, `_hasNid`, non-empty `divisionCoverageAreas`, then `apply` + `submit`.

**Gaps:**

- User can open **“আবেদন জমা দিন”** on the last step while warnings exist — `PraniPrimaryButton` is not disabled from `_reviewWarnings.isNotEmpty` (only loading flags).
- Form `validator`s are not attached to every business rule (e.g. service areas).

**Target:**

| Rule | Implementation idea |
|------|----------------------|
| Block **Submit** | `onPressed: null` when `_reviewWarnings(p).isNotEmpty` **or** `_saving` / `_submitting` |
| Block advancing **to** review (step 5) | In `_goNext`, if `next == 5`, require `_reviewWarnings.isEmpty` (or dedicated `_isWizardCompleteForSubmit`) |
| “Publish” wording | Product copy only — technically **submit application** (`POST submit`), not marketplace publish |

---

## 10. UI / spacing improvements

**Current mitigations already present:**

- `_scrollStep` adds `_kScrollBottomGap` + `viewInsets.bottom` so fields sit above keyboard.
- Footer is **outside** `Expanded` `PageView` in a `Column` — structurally avoids overlap; snackbars use `_snackBarBottomMargin`.

**Plan tweaks:**

- After removing full-screen `_loading` for refreshes, re-verify footer vs keyboard on small devices.
- Compact density: audit `PraniFormCard` stacks on steps 2–4 for long-scroll fatigue (Bengali-first labels already).
- Document step: distinguish **required** NID vs optional slots visually (already `requiredSlot`).

---

## 11. Testing checklist

- [ ] From intro (`extra: 1`), land on step **1**; complete personal → Next → **step index unchanged** after autosave if implemented.
- [ ] On step **4**, upload NID front → **remain step 4** (no jump to step 0 / intro content).
- [ ] Delete document → same.
- [ ] Add service area from step 3 → return from sub-route → **remain step 3**.
- [ ] Tap **খসড়া সংরক্ষণ** on step 3 → **remain step 3**.
- [ ] Kill app mid-step 4 → reopen from profile entry → **resume step** (once local persistence exists) or document expected behavior if only server persistence.
- [ ] Attempt **submit** on review with missing NID → button disabled or clear error; never silent pass.
- [ ] DOB: Feb 29 on non-leap year → `null` / validation message.
- [ ] DOB edge years **1965** and **2015** accepted.
- [ ] Upload failure (airplane mode) → error + **retry** path.
- [ ] Image crop cancel → no upload, prior file unchanged.

**Commands:**

```text
cd D:\PraniDoctor\pranidoctor_mobile
flutter analyze
flutter test   # if widget/integration tests exist for this flow
```

Optional after backend changes:

```text
cd D:\PraniDoctor\pranidoctor-web
npx prisma validate
npm run lint
```

---

## 12. Implementation order (when approved)

1. **Stop step reset:** refactor `_bootstrap` / loading so `PageView` stays mounted **or** resync `PageController` to `_stepIndex` after every refresh (verify with logs first).
2. **Persist step locally** (and optionally pass `extra` from dashboard/entry when resuming).
3. **Auto-save on Next** (and error handling).
4. **Submit / review gating** (disable submit + block jump to review until complete).
5. **Upload UX:** crop pipeline + retry affordance.
6. **Docs:** update `AI_TECHNICIAN_FORM_STEPPER_UPLOAD_PLAN.md` to match `PraniDatePartsField` and new behaviors.

---

## Summary

| Problem | Likely root cause |
|---------|-------------------|
| Wizard jumps to first step after upload/save | `_bootstrap()` sets `_loading` → **removes `PageView`**; controller/page desync + `onPageChanged`; no `jumpToPage` resync |
| Step not preserved after draft | No persisted step; route **`extra` often null**; `initialStep` only on first `initState` |
| No auto-save on Next | `_goNext` does not call `apply` |
| Submit before complete | `_validateStep` lax for steps 4–5; submit button not tied to `_reviewWarnings` |
| DOB | Largely **done** via `PraniDatePartsField` — verify optional/required and API format |
| Upload UX | Missing **crop** + explicit **retry**; preview/progress/remove already present |
| Footer overlap | Mostly addressed — re-verify after loading refactor |

This file is the single planning reference for the next implementation pass.
