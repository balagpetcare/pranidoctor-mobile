# Profile Simplification Audit Report

## Goal
Deliver a clean, customer-first profile experience with a single professional
dashboard section while preserving professional roles, applications, and routes.

## Architecture Summary
- `ProfileHomeScreen` now renders only the profile header and the new
  professional dashboard section (plus system load banner when needed).
- A unified professional state model lives in
  `lib/src/features/profile/application/professional_profile_state.dart`.
- The new UI is modular:
  - `professional_dashboard_card.dart` orchestrates state rendering + actions.
  - `professional_state_views/*` contains the 5 state-specific view widgets.

## Unified Professional State
- `ProfessionalProfileStatus`: `none`, `draft`, `pending`, `rejected`, `approved`.
- `ProfessionalProfileRole`: `doctor`, `aiTechnician`.
- The state model merges dashboard context signals, prefers an active role, and
  chooses the most advanced status (approved > pending > draft > rejected).

## Navigation & Action Mapping
- **No application**
  - Apply as Doctor → `ProfessionalProfileHubScreen` (doctor persona)
  - Apply as AI Technician → `AiTechnicianApplicationEntryScreen`
- **Draft**
  - Continue Application → same as apply (role-specific draft flow)
- **Pending**
  - View Application → `AiTechnicianApplicationStatusScreen` (AI tech) or
    `ProfessionalVerificationWorkflowScreen` (doctor)
- **Rejected**
  - Update Application → draft flow
  - View Feedback → status flow
- **Approved**
  - Open Dashboard → switches workspace surface + routes to role dashboard

## UX Improvements
- Removes duplicated professional cards, workspace list, application banners,
  and role shortcuts from the customer profile.
- Introduces a single premium card with clear hierarchy, consistent spacing,
  and minimal actions.
- Adds loading and retry states for professional dashboard data.
- Uses wrap-based CTAs for responsive layouts.

## Migration Safety Notes
- No backend or API changes; all data sources remain intact.
- Application drafts, submission statuses, and role permissions are preserved.
- Professional workspace routing still uses existing workspace providers.
