# AI Technician — Stepper, locations & uploads (mobile)

**Project:** Prani Doctor / Animal Doctors  
**Repos:** `pranidoctor_mobile` (UI) · `pranidoctor-web` (API, storage, admin)

## Current implementation (post COMMAND 05–07)

- **Entry:** `openAiTechnicianApplicationEntry` → intro (no profile) → `AiTechnicianApplicationFormScreen` when editable → status/dashboard otherwise (`ai_technician_entry.dart`).
- **Stepper:** `AiTechnicianApplicationFormScreen` — **6 steps** (`PageView`, `totalSteps = 6`): intro → personal → professional → address & service areas → documents → review/submit. Next/Previous with validation; draft via **`POST /api/mobile/ai-technician/apply`**; submit via **`POST …/submit`**.
- **Locations:** `PraniSearchableSelectField` + `locationRepositoryProvider` — districts, upazilas (by district), unions (by district + upazila). Service areas: bottom sheet with same cascade; add/delete via API.
- **Uploads:** `file_picker` → `UploadRepository.uploadMobileFile` (`POST /api/mobile/uploads`) with **`onSendProgress`** → `addDocument` with **`uploadedFileId`**. Client size caps align with server defaults (**~5 MB** image slots, **~10 MB** certificate/PDF slots).
- **UX polish:** Date picker `showDatePicker` (`bn_BD`), gender `DropdownButtonFormField`, `InputDecorationTheme` with **`floatingLabelBehavior: auto`**, bottom bar **`viewInsets`** padding so the keyboard does not cover actions, document row **`LinearProgressIndicator`** with optional determinate value.

## Canonical documentation (web)

For API contracts, env vars, MinIO/S3, admin document review, and full QA matrices see:

- **`pranidoctor-web/docs/AI_TECHNICIAN_FORM_STEPPER_UPLOAD_PLAN.md`**
- **`pranidoctor-web/docs/UPLOAD_STORAGE_SETUP.md`**
- **`pranidoctor-web/docs/AI_TECHNICIAN_QA_CHECKLIST.md`**

## Related code (this repo)

| Area | Path |
|------|------|
| Form / stepper | `lib/src/features/ai_technician_application/presentation/ai_technician_application_form_screen.dart` |
| Intro | `…/ai_technician_intro_screen.dart` |
| Entry | `…/ai_technician_entry.dart` |
| API / models | `…/data/ai_technician_repository.dart`, `ai_technician_models.dart` |
| Uploads | `lib/src/features/uploads/data/upload_repository.dart`, `uploaded_file_model.dart` |
| Locations | `lib/src/features/locations/` |

---

NEXT COMMAND: COMPLETED — AI Technician Stepper, Location & Upload Flow Ready
