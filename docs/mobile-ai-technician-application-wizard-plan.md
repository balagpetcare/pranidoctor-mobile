# Mobile AI Technician Application Wizard Plan

Project: `pranidoctor_mobile` (Prani Doctor / Animal Doctors only)

## Exact Files Found (Audit)

- `lib/src/features/ai_technician_application/presentation/ai_technician_application_form_screen.dart`
- `lib/src/features/ai_technician_application/presentation/ai_technician_application_status_screen.dart`
- `lib/src/features/ai_technician_application/presentation/ai_technician_service_area_selection_screen.dart`
- `lib/src/features/ai_technician_application/presentation/ai_technician_document_picker.dart`
- `lib/src/features/ai_technician_application/presentation/ai_technician_entry.dart`
- `lib/src/features/ai_technician_application/presentation/ai_technician_intro_screen.dart`
- `lib/src/features/ai_technician_application/data/ai_technician_models.dart`
- `lib/src/features/ai_technician_application/data/ai_technician_repository.dart`
- `lib/src/features/ai_technician_application/application/ai_technician_providers.dart`
- `lib/src/design_system/widgets/prani_searchable_select_field.dart`
- `lib/src/design_system/widgets/prani_form_fields.dart`
- `lib/src/design_system/widgets/prani_step_progress_header.dart`
- `lib/src/design_system/widgets/prani_sticky_action_bar.dart`
- `lib/src/app/router.dart`

## Duplicate Rendering Root Cause

- The current form is a 6-step flow with an in-form intro step, while there is already a separate intro screen. This causes perceived duplicated sections/content for users.
- Profile refresh (`_bootstrap`) can rehydrate data during wizard movement, and repeated service-area rows from backend data can appear as duplicated visual rows in the UI.
- Service area listing is rendered directly from raw `divisionCoverageAreas` without a UI-level dedupe pass.

## Crash Root Cause

- SnackBar assertion crash:
  - In `ai_technician_application_form_screen.dart`, `SnackBar` uses `behavior: SnackBarBehavior.fixed` with `margin`, which violates Flutter constraint (`margin` requires `floating` behavior).
- Dropdown/context crash pattern risk:
  - Async flows around route/sheet/dialog returns need strict `mounted` guards and captured messenger/navigator usage.
  - Service-area selection route and document picker already mostly guarded, but flow consistency needs tightening to avoid ancestor lookup after deactivation in edge timing.

## Proposed Step Structure (5 Steps)

1. ব্যক্তিগত তথ্য
   - Display name, phone, email (optional), NID (optional), birth date, gender
2. পরিচয় ও প্রোফাইল মিডিয়া
   - Profile photo, NID front/back, upload state and helper copy
3. পেশাগত তথ্য
   - Experience level/years, training, certificate, skills, short bio
4. কাজের এলাকা / সেবা এলাকা
   - District, upazila, union (optional), area list management
5. পর্যালোচনা ও জমা
   - Summary cards, missing required warnings, final submit

## State Persistence Approach

- Keep a single `StatefulWidget` form state with persistent controllers in `initState` (already present pattern).
- Continue in-memory draft state plus existing step persistence via `SharedPreferences`.
- Preserve selected dropdown values, uploaded file references, and work-area selections across next/back and refresh.
- Keep autosave-to-server on step transition for editable steps; never recreate controllers inside `build`.

## Test Checklist

- Open AI Technician form and verify 5-step wizard labels and progress.
- Fill step 1, go next/back, confirm data remains.
- Use all dropdowns in personal/professional/location flow and confirm no crash.
- Upload profile/NID docs and verify upload state updates and no context crash.
- Add/delete service areas, go back/continue, confirm stable navigation and persisted selections.
- Trigger SnackBars in this flow and confirm no red screen (`margin` assertion gone).
- Submit from final step and verify navigation to status page.
- Verify status/provider labels are Bengali-friendly (no raw enum in UI).
- Run:
  - `flutter analyze`
  - `flutter test` (best effort if tests available)
