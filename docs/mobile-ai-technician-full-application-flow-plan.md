# AI Technician Application — Full System Audit & Implementation Plan

**Project:** Prani Doctor / Animal Doctors Flutter Mobile App  
**Path:** `D:\PraniDoctor\pranidoctor_mobile`  
**Scope:** Complete AI Technician application flow — create, edit, modify, review, submit, resubmit, status, and profile navigation  
**Date:** 2026-05-11  
**Status:** ✅ Core fixes and final QA polish completed (2026-05-11)

---

## Final QA Summary (2026-05-11)

### ✅ Final QA / polish pass completed

- Intro screen now uses a shorter, stable Bengali title and only one visible CTA.
- Wizard footer now follows step-aware button rules: first step `পরবর্তী`, middle steps `পূর্ববর্তী` + `পরবর্তী`, final step `পূর্ববর্তী` + `আবেদন জমা দিন`.
- Disabled submit now shows a clear Bengali reason from centralized review validation instead of a silent disabled button.
- Centralized status mapping now prevents raw enum leakage for application status, provider status, and technician service status fallbacks.
- Status/dashboard summary copy now uses more Bengali-first labels such as `যাচাই অবস্থা`.
- Final verification completed with:
  - `flutter analyze` ✅
  - `flutter test` ✅

## Implementation Summary (2026-05-11)

### ✅ Completed Fixes

1. **Intro Screen Title Fixed**
   - Changed from: "এআই টেকনিশিয়ান হিসেবে কাজ করুন" (too long, was truncating)
   - Changed to: "এআই টেকনিশিয়ান হিসেবে যুক্ত হন" (shorter, fits properly)
   - Subtitle simplified to: "কৃত্রিম প্রজনন সেবা"
   - Button label changed to: "আবেদন শুরু করুন" (clearer intent)

2. **Bottom Navigation Buttons Fixed**
   - First step now shows ONLY "পরবর্তী" button (no redundant "পূর্ববর্তী")
   - Middle steps show both "পূর্ববর্তী" and "পরবর্তী"
   - Final step shows "পূর্ববর্তী" and "আবেদন জমা দিন"
   - Added inline error message when submit is blocked: "সব আবশ্যক তথ্য পূর্ণ করুন"

3. **Empty Wizard Content Fixed**
   - Reduced bottom padding from `140 + viewInsets` to `max(100, 100 + keyboardHeight)` or `120` when no keyboard
   - Improved default step case to show meaningful error instead of empty shrink box
   - Better error message: "ধাপ লোড করা যায়নি"

4. **Raw Enum Values Fixed**
   - Changed `titleBn()` default case from returning raw `status` to Bengali: "প্রক্রিয়াধীন"
   - Added debug logging for unknown status codes
   - Added missing status mappings: ACTIVE, INACTIVE, VERIFIED

5. **Status Screen Improvements**
   - Edit button label now shows "তথ্য সংশোধন করুন" when status is NEEDS_CORRECTION/NEEDS_MORE_INFO
   - Shows "ফর্ম সম্পাদনা করুন" for DRAFT status
   - Refresh and back buttons already present and working

### 📝 Files Modified

1. `lib/src/features/ai_technician_application/presentation/ai_technician_intro_screen.dart`
2. `lib/src/features/ai_technician_application/presentation/ai_technician_application_form_screen.dart`
3. `lib/src/features/ai_technician_application/data/ai_technician_models.dart`
4. `lib/src/features/ai_technician_application/presentation/ai_technician_application_status_screen.dart`

### ✅ Quality Checks

- `flutter analyze`: ✅ No issues found
- All existing functionality preserved
- Bengali-first UX maintained
- No new dependencies added
- Design system components reused

---

## 1. Executive Summary

The AI Technician application system allows customers to apply as artificial insemination (AI) technicians on the Prani Doctor platform. The current implementation has several UX and stability issues that need to be addressed:

1. **Intro screen title truncation** — AppBar shows only "করুন" instead of full title
2. **Duplicated/confusing navigation buttons** — Bottom action bar layout issues
3. **Empty wizard content** — Step content not rendering properly on some devices
4. **Unclear submit blocking** — Disabled submit button without visible reason
5. **Raw enum values displayed** — Status codes showing in English instead of Bengali

---

## 2. Current File Map

### 2.1 Presentation Layer

| File | Purpose |
|------|---------|
| `lib/src/features/ai_technician_application/presentation/ai_technician_intro_screen.dart` | Marketing intro page with benefits list |
| `lib/src/features/ai_technician_application/presentation/ai_technician_application_form_screen.dart` | 5-step wizard form (2654 lines) |
| `lib/src/features/ai_technician_application/presentation/ai_technician_application_status_screen.dart` | Read-only status/pipeline view |
| `lib/src/features/ai_technician_application/presentation/ai_technician_service_area_selection_screen.dart` | Service area picker (district → upazila → union) |
| `lib/src/features/ai_technician_application/presentation/ai_technician_dashboard_screen.dart` | Published technician dashboard |
| `lib/src/features/ai_technician_application/presentation/ai_technician_dashboard_body.dart` | Dashboard body content |
| `lib/src/features/ai_technician_application/presentation/ai_technician_entry.dart` | Entry routing logic |
| `lib/src/features/ai_technician_application/presentation/ai_technician_document_picker.dart` | Document upload picker |
| `lib/src/features/ai_technician_application/presentation/ai_technician_requests_list_screen.dart` | Job requests list |
| `lib/src/features/ai_technician_application/presentation/ai_technician_request_detail_screen.dart` | Request detail view |
| `lib/src/features/ai_technician_application/presentation/ai_technician_request_complete_screen.dart` | Request completion form |
| `lib/src/features/ai_technician_application/presentation/ai_technician_services_list_screen.dart` | Technician services list |
| `lib/src/features/ai_technician_application/presentation/ai_technician_service_form_screen.dart` | Service create/edit form |

### 2.2 Widgets

| File | Purpose |
|------|---------|
| `presentation/widgets/technician_status_summary_card.dart` | Status summary display |
| `presentation/widgets/technician_dashboard_stat_card.dart` | Dashboard statistics |
| `presentation/widgets/technician_quick_actions_grid.dart` | Quick action buttons |
| `presentation/widgets/technician_active_services_section.dart` | Active services list |
| `presentation/widgets/technician_earnings_summary_card.dart` | Earnings display |
| `presentation/widgets/technician_weekly_performance_card.dart` | Performance metrics |
| `presentation/widgets/technician_emergency_availability_card.dart` | Emergency toggle |
| `presentation/widgets/technician_request_status_grid.dart` | Request pipeline counts |

### 2.3 Application Layer (State/Providers)

| File | Purpose |
|------|---------|
| `application/ai_technician_providers.dart` | Riverpod providers for all AI Technician data |
| `application/ai_technician_dashboard_ui_helpers.dart` | UI helper functions |
| `application/ai_technician_dashboard_error_mapper.dart` | Error message mapping |
| `application/ai_technician_request_pipeline_counts.dart` | Pipeline count model |

### 2.4 Data Layer

| File | Purpose |
|------|---------|
| `data/ai_technician_models.dart` | DTOs: `AiTechnicianProfile`, `AiTechnicianDocument`, `AiTechnicianDivisionArea`, `AiTechnicianStatusCopy` |
| `data/ai_technician_repository.dart` | API calls: `fetchMe`, `apply`, `submit`, documents, service areas |
| `data/ai_technician_api_exception.dart` | Custom exception class |

### 2.5 Design System Widgets Used

| File | Purpose |
|------|---------|
| `design_system/widgets/prani_scaffold.dart` | Standard scaffold with AppBar |
| `design_system/widgets/prani_sticky_action_bar.dart` | Bottom action bar |
| `design_system/widgets/prani_step_progress_header.dart` | Step indicator with progress bar |
| `design_system/widgets/prani_form_card.dart` | Form section card |
| `design_system/widgets/prani_buttons.dart` | Primary/Secondary buttons |
| `design_system/widgets/prani_upload_card.dart` | Document upload UI |
| `design_system/widgets/prani_searchable_select_field.dart` | Location dropdowns |
| `design_system/widgets/prani_status_card.dart` | Status display card |
| `design_system/widgets/prani_error_state.dart` | Error display |
| `design_system/widgets/prani_loading_state.dart` | Loading indicator |
| `design_system/widgets/prani_empty_state.dart` | Empty state display |

### 2.6 Routing

| File | Relevant Routes |
|------|-----------------|
| `lib/src/app/router.dart` | `/profile/ai-technician/intro`, `/profile/ai-technician/form`, `/profile/ai-technician/status`, `/profile/ai-technician/dashboard`, `/profile/ai-technician/form/service-area` |

---

## 3. Current Navigation Flow Map

```
┌─────────────────────────────────────────────────────────────────────┐
│                        ENTRY POINTS                                  │
├─────────────────────────────────────────────────────────────────────┤
│  ProfileHomeScreen                                                   │
│       ↓                                                              │
│  "এআই টেকনিশিয়ান আবেদন" tile tap                                   │
│       ↓                                                              │
│  openAiTechnicianApplicationEntry(context, ref)                     │
│       ↓                                                              │
│  aiTechnicianMeProvider.future → AiTechnicianMeResult               │
└─────────────────────────────────────────────────────────────────────┘
                              │
          ┌───────────────────┼───────────────────┐
          ↓                   ↓                   ↓
┌─────────────────┐  ┌─────────────────┐  ┌─────────────────┐
│  profile == null │  │ profile.isEditable│ │ APPROVED/PUBLISHED│
│        ↓         │  │   (DRAFT or      │  │        ↓         │
│  IntroScreen     │  │ NEEDS_CORRECTION)│  │  DashboardScreen │
│        ↓         │  │        ↓         │  └─────────────────┘
│  "আবেদন ফর্মে যান" │  │   FormScreen     │
│        ↓         │  │  (resume step)   │
│  FormScreen      │  └─────────────────┘
│  (step 0)        │
└─────────────────┘
          │
          ↓ (else)
┌─────────────────┐
│  StatusScreen   │
│ (SUBMITTED,     │
│  UNDER_REVIEW,  │
│  etc.)          │
└─────────────────┘
```

### Form Screen Step Flow

```
Step 0: ব্যক্তিগত তথ্য (Personal Info)
    ↓ পরবর্তী (saves draft via POST /apply)
Step 1: পরিচয় ও প্রোফাইল মিডিয়া (Documents)
    ↓ পরবর্তী (validates NID front+back)
Step 2: পেশাগত তথ্য (Professional Info)
    ↓ পরবর্তী (saves draft)
Step 3: কাজের এলাকা ও সেবা এলাকা (Address & Service Areas)
    ↓ পরবর্তী (validates district/upazila + service areas)
Step 4: পর্যালোচনা ও জমা (Review & Submit)
    ↓ আবেদন জমা দিন (POST /submit)
    → StatusScreen (pushReplacement)
```

---

## 4. Current Data Model / API Usage Summary

### 4.1 API Endpoints

| Endpoint | Method | Purpose |
|----------|--------|---------|
| `/api/mobile/ai-technician/me` | GET | Fetch current user's technician profile |
| `/api/mobile/ai-technician/apply` | POST | Create/update draft application |
| `/api/mobile/ai-technician/submit` | POST | Submit application for review |
| `/api/mobile/ai-technician/documents` | POST | Add document to profile |
| `/api/mobile/ai-technician/documents/:id` | DELETE | Remove document |
| `/api/mobile/ai-technician/service-areas` | POST | Add service area |
| `/api/mobile/ai-technician/service-areas/:id` | DELETE | Remove service area |
| `/api/mobile/ai-technician/dashboard` | GET | Fetch dashboard data (approved techs) |
| `/api/mobile/ai-technician/services` | GET/POST | List/create services |
| `/api/mobile/ai-technician/settings` | PATCH | Update emergency availability |
| `/api/mobile/ai-technician/requests` | GET | List job requests |

### 4.2 Profile Status Flow

```
DRAFT → SUBMITTED → PENDING_VERIFICATION → APPROVED → PUBLISHED
                 ↓                      ↓
            NEEDS_CORRECTION        REJECTED
                 ↓
              (re-edit & resubmit)
```

### 4.3 Key Models

```dart
class AiTechnicianProfile {
  String status;           // Application pipeline status
  String providerStatus;   // Provider verification status
  bool get isEditable => status == 'DRAFT' || status == 'NEEDS_CORRECTION';
  List<AiTechnicianDocument> documents;
  List<AiTechnicianDivisionArea> divisionCoverageAreas;
}
```

---

## 5. Root Cause Analysis

### 5.1 Issue: Intro Screen Title Broken (shows only "করুন")

**Current Code (`ai_technician_intro_screen.dart` line 57):**
```dart
return PraniScaffold(
  title: 'এআই টেকনিশিয়ান হিসেবে কাজ করুন',
  subtitle: 'কৃত্রিম প্রজনন (এআই) — Artificial Insemination',
```

**Root Cause Analysis:**
1. **Most Likely:** The `PraniScaffold` → `AppBar` → `PraniAppHeader` chain may have text overflow or line wrapping issues in Bengali fonts
2. **Possible:** The `subtitle` being too long causes the main title to be clipped
3. **Device-specific:** Some Android devices have font rendering issues with long Bengali text in AppBar

**Verified:** Title string is correct in code. Issue is in rendering/layout.

### 5.2 Issue: Duplicated/Awkward Previous/Next Buttons

**Current Code (`ai_technician_application_form_screen.dart` lines 1624-1682):**
```dart
Widget _buildBottomActions(BuildContext context, AiTechnicianProfile profile) {
  return LayoutBuilder(
    builder: (context, constraints) {
      final stackVertical = constraints.maxWidth < 380;
      // Creates prev and next buttons
      if (stackVertical) {
        return Column(children: [prev, SizedBox, next]);
      }
      return Row(children: [Expanded(prev), SizedBox, Expanded(next)]);
    },
  );
}
```

**Root Cause Analysis:**
1. **Primary:** No conditional hiding of "পূর্ববর্তী" button on step 0 — button is always visible but clicking does nothing on first step
2. **Secondary:** The vertical stacking when `maxWidth < 380` creates visual confusion on small phones
3. **Design Gap:** No visual distinction between disabled and enabled button states for navigation

### 5.3 Issue: Empty Wizard Content (Only Buttons Visible)

**Current Layout (`ai_technician_application_form_screen.dart` lines 1453-1599):**
```dart
body: Stack(
  fit: StackFit.expand,
  children: [
    ColoredBox(
      color: scheme.surface,
      child: Theme(
        child: Builder(
          builder: (context) {
            return SingleChildScrollView(
              controller: _wizardScrollController,
              padding: EdgeInsets.fromLTRB(hPad, PraniSpacing.md, hPad, bottomInset),
              child: Column(
                children: [
                  PraniStepProgressHeader(...),
                  Form(
                    child: KeyedSubtree(
                      key: ValueKey<int>(_stepIndex),
                      child: _buildWizardStepContent(...),
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    ),
    // Refresh indicator overlay
    // Submitting overlay
  ],
)
```

**Root Cause Analysis:**
1. **Primary:** `bottomInset` calculation uses `140 + mq.viewInsets.bottom` which can push content above visible area on short screens
2. **Secondary:** `KeyedSubtree` with `ValueKey<int>(_stepIndex)` causes rebuild on step change, but if state isn't properly preserved, content may not render
3. **Tertiary:** `_buildWizardStepContent()` returns `SizedBox.shrink()` for invalid step indices (line 1619)
4. **Device-specific:** `Stack` + `SingleChildScrollView` combination is sensitive to parent constraints

### 5.4 Issue: Disabled Submit Without Clear Reason

**Current Code (`ai_technician_application_form_screen.dart` lines 1647-1656):**
```dart
final submitBlockedOnReview = isLast && (blockingReview || !_reviewDeclarationAccepted);
// ...
onPressed: (_navSaving || _submitting || submitBlockedOnReview) ? null : _submit,
```

**Root Cause Analysis:**
1. **Primary:** When `blockingReview` is true, there's no inline error message shown near the submit button
2. **Secondary:** `_reviewDeclarationAccepted` checkbox status isn't visually prominent
3. **UX Gap:** The warning messages from `_reviewWarnings()` are displayed in cards above, but may be scrolled out of view

**Blocking Conditions (from `_reviewWarnings`):**
- Display name < 2 characters
- Missing phone number
- Invalid DOB
- Invalid email format
- Invalid experience years
- Missing district/upazila
- No service areas added
- Missing NID documents

### 5.5 Issue: Raw Enum Values Still Appearing

**Current Code (`ai_technician_application_status_screen.dart` lines 177-179):**
```dart
PraniStatusCard(
  headline: AiTechnicianStatusCopy.titleBn(st),
  badgeLabel: AiTechnicianStatusCopy.titleBn(st),  // Correct
  message: AiTechnicianStatusCopy.messageBn(st),
```

**Root Cause Analysis:**
1. **Primary:** In `_StatusBody` (lines 232-247), `profile.providerStatus` is displayed using `AiTechnicianStatusCopy.providerStatusBn()` which has a fallback to `titleBn(status)` — but if `status` doesn't match known cases, it returns the raw string
2. **Secondary:** `AiTechnicianStatusCopy.titleBn()` has a `default: return status;` case (line 328) that returns raw enum value for unknown status codes
3. **API Issue:** If server returns unexpected status values not in the switch cases, raw values appear

**Existing Bengali Mappings (`ai_technician_models.dart`):**
```dart
abstract final class AiTechnicianStatusCopy {
  static String titleBn(String status) {
    switch (status) {
      case 'DRAFT': return 'খসড়া';
      case 'SUBMITTED': return 'জমা হয়েছে';
      case 'UNDER_REVIEW':
      case 'PENDING_VERIFICATION': return 'যাচাই অপেক্ষমান';
      case 'NEEDS_CORRECTION':
      case 'NEEDS_MORE_INFO': return 'আরও তথ্য প্রয়োজন';
      case 'APPROVED': return 'অনুমোদিত';
      case 'PUBLISHED': return 'প্রকাশিত';
      case 'REJECTED': return 'বাতিল';
      case 'SUSPENDED': return 'স্থগিত';
      default: return status;  // ← PROBLEM: Returns raw enum
    }
  }
}
```

---

## 6. Full Target Flow

### 6.1 Intro Screen
- Clear Bengali title: "এআই টেকনিশিয়ান আবেদন" (shorter)
- Subtitle as before
- Benefits list
- Single CTA: "আবেদন শুরু করুন"

### 6.2 Create New Application
- Entry via intro or profile tile
- Auto-creates draft via `POST /apply` with empty body
- Opens form at step 0

### 6.3 Edit Draft
- Entry detects `status == 'DRAFT'`
- Resumes from last saved step (SharedPreferences)
- All steps editable

### 6.4 Modify Existing (Needs Correction)
- Entry detects `status == 'NEEDS_CORRECTION'`
- Shows correction note prominently
- All steps editable
- Submit becomes "আবেদন পুনরায় জমা দিন"

### 6.5 Review (Step 5)
- Summary of all sections
- Edit links for each section
- Clear validation warnings with step navigation
- Declaration checkbox required
- Submit only enabled when all validations pass

### 6.6 Submit
- `POST /apply` (save final draft)
- `POST /submit` (status → SUBMITTED)
- Navigate to Status screen

### 6.7 Resubmit (from Needs Correction)
- Same as submit
- Status → SUBMITTED (again)

### 6.8 Status Screen
- Clear Bengali status label
- Progress timeline
- Admin/correction notes
- Actions: Refresh, Edit (if editable), Back

---

## 7. Bengali Status Mapping Table

| API Status | Bengali Title | Bengali Message |
|------------|---------------|-----------------|
| `DRAFT` | খসড়া | আপনার তথ্য এখনো খসড়া। ফর্ম সম্পূর্ণ করে জমা দিন। |
| `SUBMITTED` | জমা হয়েছে | আপনার আবেদন জমা হয়েছে। অ্যাডমিন যাচাই করার পর আপনাকে জানানো হবে। |
| `UNDER_REVIEW` | যাচাই চলছে | আপনার আবেদন যাচাই চলছে। অনুগ্রহ করে অপেক্ষা করুন। |
| `PENDING_VERIFICATION` | যাচাই অপেক্ষমান | আপনার আবেদন যাচাই চলছে। অনুগ্রহ করে অপেক্ষা করুন। |
| `NEEDS_CORRECTION` | সংশোধন প্রয়োজন | অ্যাডমিন সংশোধন চেয়েছেন। নিচের নোট দেখে ফর্ম আপডেট করে আবার জমা দিন। |
| `NEEDS_MORE_INFO` | আরও তথ্য প্রয়োজন | অ্যাডমিন সংশোধন চেয়েছেন। নিচের নোট দেখে ফর্ম আপডেট করে আবার জমা দিন। |
| `APPROVED` | অনুমোদিত | অনুমোদিত হয়েছে। প্রকাশের পর খামারিদের কাছে দেখা যাবে। |
| `PUBLISHED` | প্রকাশিত | প্রোফাইল প্রকাশিত। এখন আপনি এআই টেকনিশিয়ান হিসেবে সেবা দিতে পারেন। |
| `REJECTED` | প্রত্যাখ্যাত | দুঃখিত, এই আবেদন প্রত্যাখ্যান করা হয়েছে। |
| `SUSPENDED` | স্থগিত | আপনার টেকনিশিয়ান প্রোফাইল স্থগিত করা হয়েছে। সাপোর্টে যোগাযোগ করুন। |

### Provider Status Mapping

| API Status | Bengali Label |
|------------|---------------|
| `PENDING_VERIFICATION` | যাচাই অপেক্ষমান |
| `APPROVED` | অনুমোদিত |
| `REJECTED` | প্রত্যাখ্যাত |
| `NEEDS_MORE_INFO` | আরও তথ্য প্রয়োজন |
| (unknown) | (fallback to titleBn or "অজানা") |

---

## 8. Exact Implementation Steps

### Phase 1: Fix Intro Screen Title (Priority: High)

**File:** `ai_technician_intro_screen.dart`

1. Shorten AppBar title to prevent overflow:
   ```dart
   title: 'এআই টেকনিশিয়ান আবেদন',  // Shorter
   subtitle: 'কৃত্রিম প্রজনন সেবা দিতে আবেদন করুন',
   ```

2. Move longer copy to page body

### Phase 2: Fix Bottom Navigation Buttons (Priority: High)

**File:** `ai_technician_application_form_screen.dart`

1. Hide "পূর্ববর্তী" button on step 0:
   ```dart
   Widget _buildBottomActions(...) {
     final isFirst = _stepIndex == 0;
     final isLast = _stepIndex == totalSteps - 1;
     
     if (isFirst) {
       return /* Only next button */;
     }
     // existing logic for prev + next
   }
   ```

2. Use consistent button heights:
   ```dart
   minimumHeight: 52,  // Consistent across all buttons
   ```

3. Add visual feedback for disabled state:
   ```dart
   // Add helper text below disabled submit button
   if (submitBlockedOnReview) {
     Text('সব আবশ্যক তথ্য পূর্ণ করুন', style: errorStyle);
   }
   ```

### Phase 3: Fix Empty Wizard Content (Priority: Critical)

**File:** `ai_technician_application_form_screen.dart`

1. Review bottom inset calculation:
   ```dart
   final bottomInset = max(100, 100 + mq.viewInsets.bottom);
   // Cap at reasonable value to prevent content push
   ```

2. Add debug logging for step content:
   ```dart
   Widget _buildWizardStepContent(...) {
     if (kDebugMode) {
       debugPrint('Building step $_stepIndex content');
     }
     // existing switch
   }
   ```

3. Ensure each step returns non-empty content:
   ```dart
   default:
     return _wizardStepColumn(context, maxW, [
       Text('ধাপ লোড করা যায়নি', style: errorStyle),
     ]);
   ```

4. Simplify layout — consider removing outer `Stack` for non-overlay content

### Phase 4: Fix Submit Button Feedback (Priority: Medium)

**File:** `ai_technician_application_form_screen.dart`

1. Add inline error summary near submit button:
   ```dart
   if (blockingReview) {
     Padding(
       padding: EdgeInsets.only(bottom: 8),
       child: Text(
         'আবশ্যক তথ্য বাকি আছে। উপরের সংশোধনী দেখুন।',
         style: TextStyle(color: scheme.error),
         textAlign: TextAlign.center,
       ),
     ),
   }
   ```

2. Highlight declaration checkbox when unchecked and user tries to submit:
   ```dart
   bool _highlightDeclaration = false;
   
   void _submit() {
     if (!_reviewDeclarationAccepted) {
       setState(() => _highlightDeclaration = true);
       _showWizardSnackBar('নিশ্চিতকরণ বাক্সে টিক দিন।');
       return;
     }
     // ...
   }
   ```

### Phase 5: Fix Raw Enum Values (Priority: High)

**File:** `ai_technician_models.dart`

1. Update `titleBn` fallback:
   ```dart
   static String titleBn(String status) {
     switch (status) {
       // existing cases
       default:
         // Log unknown status for debugging
         assert(() {
           debugPrint('Unknown AI Technician status: $status');
           return true;
         }());
         return 'প্রক্রিয়াধীন';  // Generic Bengali fallback
     }
   }
   ```

2. Update `providerStatusBn` fallback:
   ```dart
   static String providerStatusBn(String status) {
     switch (status) {
       // existing cases
       default:
         return titleBn(status);  // Already chains, but ensure no raw leak
     }
   }
   ```

3. Add missing status cases if API returns them:
   ```dart
   case 'VERIFIED':
     return 'যাচাইকৃত';
   case 'ACTIVE':
     return 'সক্রিয়';
   case 'INACTIVE':
     return 'নিষ্ক্রিয়';
   ```

**File:** `ai_technician_application_status_screen.dart`

4. Ensure all status displays use helpers:
   ```dart
   // Line 179 - Already correct
   badgeLabel: AiTechnicianStatusCopy.titleBn(st),
   
   // Line 241 - Verify providerStatus uses helper
   subtitle: Text(
     AiTechnicianStatusCopy.providerStatusBn(profile.providerStatus),
   ),
   ```

### Phase 6: UX Improvements (Priority: Medium)

1. **Step progress persistence:**
   - Already implemented via SharedPreferences
   - Verify `_mergeResumeStepFromPrefsIfNeeded` works correctly

2. **Correction note prominence:**
   - Move correction note to top of every step (not just step header)
   - Add visual indicator (red border/background)

3. **Refresh on status screen:**
   - Add pull-to-refresh
   - Auto-refresh on return from form

4. **Back navigation:**
   - Confirm unsaved changes dialog (already implemented)
   - Clear draft step prefs on successful submit

---

## 9. Validation Rules Per Step

### Step 0: ব্যক্তিগত তথ্য (Personal Info)

| Field | Required | Validation |
|-------|----------|------------|
| প্রদর্শন নাম | Yes | Min 2 characters |
| ফোন | Yes | Not empty (or profile has phone) |
| ইমেইল | No | Valid email format if provided |
| এনআইডি নম্বর | No | — |
| জন্মতারিখ | No | Valid date 1965–2015 or all empty |
| লিঙ্গ | No | — |

### Step 1: পরিচয় ও মিডিয়া (Documents)

| Slot | Required | Validation |
|------|----------|------------|
| NID_FRONT | Yes | File uploaded |
| NID_BACK | Yes | File uploaded |
| PROFILE_PHOTO | No | Max 3MB, image only |
| COVER_IMAGE | No | Max 5MB, image only |
| TRAINING_CERTIFICATE | No | Max 8MB |
| EXPERIENCE_PROOF | No | Max 8MB |

### Step 2: পেশাগত তথ্য (Professional Info)

| Field | Required | Validation |
|-------|----------|------------|
| অভিজ্ঞতার স্তর | No | — |
| এআই দক্ষতা | No | — |
| পরিচিতি/বায়ো | No | — |
| মূল সেবামূল্য | No | Numeric |
| ভিজিট ফি | No | Numeric |
| জরুরি ফি | No | Numeric |
| ফলো-আপ নীতি | No | — |
| জরুরি কল গ্রহণ | No | Boolean |
| অভিজ্ঞতা (বছর) | No | 0–80 range |
| প্রশিক্ষণ প্রতিষ্ঠান | No | — |
| সার্টিফিকেট নম্বর | No | — |
| সার্টিফিকেট বিস্তারিত | No | — |

### Step 3: ঠিকানা ও সেবা এলাকা (Address & Coverage)

| Field | Required | Validation |
|-------|----------|------------|
| বর্তমান ঠিকানা | No | — |
| জেলা | Yes | Must select |
| উপজেলা | Yes | Must select |
| ইউনিয়ন | No | — |
| সেবা এলাকা | Yes | At least 1 area |

### Step 4: পর্যালোচনা (Review)

| Requirement | Validation |
|-------------|------------|
| All blocking issues resolved | `_reviewWarnings(p).isEmpty` |
| Declaration accepted | `_reviewDeclarationAccepted == true` |

---

## 10. Manual Test Checklist

### New User Flow

- [ ] Fresh OTP login → Profile tab → "এআই টেকনিশিয়ান আবেদন" tile
- [ ] Intro screen shows with correct full title (not truncated)
- [ ] Tap "আবেদন ফর্মে যান" → Form opens at step 0
- [ ] Step 0: No "পূর্ববর্তী" button visible (only "পরবর্তী")
- [ ] Fill required fields → tap পরবর্তী → step 1 loads
- [ ] Step 1: Upload NID front and back
- [ ] Step 2: Fill optional professional info
- [ ] Step 3: Select district/upazila → Add at least 1 service area
- [ ] Step 4: Review summary shows all data
- [ ] Declaration checkbox → Submit enabled
- [ ] Submit → Status screen shows "জমা হয়েছে"

### Resume Draft Flow

- [ ] Start form → fill step 0 → kill app
- [ ] Reopen → Profile → AI Technician tile
- [ ] Form opens at last saved step

### Needs Correction Flow

- [ ] (Simulate via admin) Set status to NEEDS_CORRECTION with note
- [ ] Profile → AI Technician tile → Form opens
- [ ] Correction note visible on step header
- [ ] Edit fields → Submit again
- [ ] Status screen shows "জমা হয়েছে"

### Status Display

- [ ] All statuses show Bengali labels (no SUBMITTED, PENDING_VERIFICATION raw)
- [ ] Provider status shows Bengali label
- [ ] Timeline progress matches status

### Edge Cases

- [ ] Form with keyboard open → content still visible
- [ ] Small phone (width < 380) → buttons stack vertically without overlap
- [ ] Offline → proper error states
- [ ] Submit with missing NID → clear error message
- [ ] Back navigation with unsaved changes → confirmation dialog

---

## 11. Risk Notes

1. **Layout Regression:** Changes to `_buildBottomActions` or bottom inset may affect other screens using similar patterns — test all wizard flows

2. **SharedPreferences Corruption:** If step index gets out of range, form may fail to load — add bounds checking in `_mergeResumeStepFromPrefsIfNeeded`

3. **API Status Mismatch:** If backend adds new status values, mobile will show fallback — maintain status mapping in sync

4. **Document Upload Race:** Rapid re-uploads may cause duplicate documents — existing code handles this but verify

5. **Service Area Duplicates:** `_isDuplicatePick` logic may miss edge cases with IDs vs display names — test thoroughly

6. **Bengali Font Rendering:** Some devices may have issues with long Bengali text in AppBar — test on multiple devices

---

## 12. Files Requiring Modification

### Critical (Must Fix)

| File | Changes |
|------|---------|
| `ai_technician_intro_screen.dart` | Shorten AppBar title |
| `ai_technician_application_form_screen.dart` | Fix bottom navigation, empty content, submit feedback |
| `ai_technician_models.dart` | Fix status fallback to return Bengali instead of raw enum |

### Medium Priority

| File | Changes |
|------|---------|
| `ai_technician_application_status_screen.dart` | Verify all status displays use Bengali helpers |
| `ai_technician_entry.dart` | Add better error handling for 403 |

### Low Priority (UX Polish)

| File | Changes |
|------|---------|
| `prani_step_progress_header.dart` | Optional: Add step-tap navigation |
| `prani_sticky_action_bar.dart` | Optional: Add shadow toggle |

---

## 13. Commands After Implementation

```bash
# Mobile
cd D:\PraniDoctor\pranidoctor_mobile
flutter analyze
flutter test

# Visual test on device
flutter run -d <device_id>
```

---

*Document generated from full codebase audit — implementation should follow Flutter best practices and maintain existing design system patterns.*
