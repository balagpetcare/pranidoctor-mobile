# Professional Workspace Entry System Plan

## Objective
Introduce a premium, enterprise-grade “Professional Workspace Entry System” that
keeps the **general Profile tab UX intact**. Professional dashboards must be
reachable only through dedicated workspace entry cards in the Profile screen and
by direct `/workspace/*` routes, never embedded inside the profile tab.

## Current State (Codebase Findings)
- Profile tab currently uses `ProfileGateScreen` to route by `DashboardContext.dashboardType`.
  - `DashboardType.aiTechnician` and `DashboardType.doctor` render professional dashboards
    directly in the Profile tab (`AiTechnicianDashboardScreen`, `VeterinaryDoctorDashboardScreen`).
- `workspaceSurfaceProvider` defaults to `WorkspaceSurface.professional` and
  `redirectForWorkspacePolicy` auto-redirects `/home` to professional shells
  for non-customer roles.
- Professional shells already exist and are separate routes:
  - `/workspace/ai-technician` and `/workspace/doctor`
  - Internal tabs and bottom nav are handled by `ProfessionalWorkspaceShellScreen`.
- Backend entry for professional status is
  `GET /api/mobile/profile/dashboard-context` with:
  - `dashboardType`, `aiTechnician`, `doctor`
  - `hasAiTechnicianApplication`, `aiTechnicianApplicationStatus`
- `GET /api/mobile/me` provides `role` string but is not multi-workspace aware.

## Goals
- Keep the **general Profile UI** always visible in the Profile tab.
- Add a **Professional Workspaces** section inside the Profile screen.
- Show workspace cards only when the user has a corresponding professional profile.
- Use dedicated `/workspace/*` routes for professional dashboards.
- Design scalable architecture for multiple roles/workspaces.

## Non-Goals (for this change)
- Redesigning existing professional dashboards.
- Removing current professional shell navigation.
- Reworking the general bottom navigation tabs.

## Proposed Architecture

### 1. Domain Models
Create new workspace domain models under `lib/src/features/workspace/domain/`:

- `ProfessionalRole`
  - Values: `aiTechnician`, `doctor`, `seller`, `pharmacy`, `ambulance`,
    `breeder`, `ngoWorker`.
  - Mapping helpers from API strings + to route paths.

- `WorkspaceStatus`
  - Values: `active`, `pending`, `suspended`, `rejected`, `inactive`.

- `WorkspaceBadge`
  - UI-oriented metadata: `label`, `tone`, `icon`.

- `WorkspaceEntry`
  - `role`, `title`, `subtitle`, `status`, `badge`
  - `routePath`, `canAccess`, `isVerified`
  - `metadata` (counts, rating, location, etc.)
  - `priority` or `sortOrder` for multi-workspace ordering

### 2. Providers & State Management
Place under `lib/src/features/workspace/application/`:

- `workspaceEntriesProvider`
  - Builds `List<WorkspaceEntry>` from `DashboardContext` (and future API).
  - Filters by access rules and enriches badges/status.

- `currentWorkspaceProvider`
  - Holds active workspace role when inside `/workspace/*`.
  - Stores last-selected workspace for deep links and resumes.

- `workspaceAccessProvider`
  - Returns `bool` for `role` access and profile availability.
  - Used by route guards and entry button visibility.

- `workspaceRouterProvider`
  - Maps `ProfessionalRole → routePath`.
  - Handles future additional workspace routes.

### 3. Routing & Permission Guard
Update `app_route_policy.dart` and router config:

- **Profile tab** must always render `ProfileHomeScreen`.
- Remove embedded professional dashboards from `ProfileGateScreen`.
- Add workspace guard:
  - Block `/workspace/*` if role not present in `workspaceEntriesProvider`.
  - Redirect unauthorized access to `SessionForbiddenScreen` or Profile.
- Update workspace redirects:
  - Stop auto-redirecting `/home` to professional shells.
  - Keep `WorkspaceSurface` only for internal professional ↔ general switching.

### 4. UI Hierarchy & Widgets
Add workspace section inside `ProfileHomeScreen` (after header card + banners):

- Section title: **Professional Workspaces**
- Each workspace as a premium card with:
  - Role title + subtitle
  - Verification badge
  - Active/inactive status chip
  - Gradient background + enterprise spacing
  - CTA: “Open {Role} Dashboard”

New widgets (under `lib/src/features/workspace/presentation/widgets/`):
- `WorkspaceSectionHeader`
- `WorkspaceEntryCard`
- `WorkspaceBadgeChip`
- `WorkspaceStatusPill`

### 5. Role Visibility Rules
Use `DashboardContext` rules (current backend):

- AI Technician:
  - Show entry if `aiTechnician != null` OR `hasAiTechnicianApplication == true`.
  - Status from `aiTechnician.status` or `aiTechnicianApplicationStatus`.
- Doctor:
  - Show entry if `doctor != null` OR `dashboardType == doctor`.
  - Status from `doctor.verificationStatus` when available.

Future roles:
- Controlled by new backend `workspaces[]` array (see API section).

### 6. Professional Dashboard Separation
Keep professional dashboards under:
- `/workspace/ai-technician`
- `/workspace/doctor`

Remove their embedded rendering from the Profile tab.
Professional tabs remain in `ProfessionalWorkspaceShellScreen`.

### 7. Workspace Metadata & Badges
Enrich `WorkspaceEntry`:
- AI Technician: `rating`, `pendingRequestCount`, `serviceAreas`.
- Doctor: `rating`, `telemedicineCapable`, `appointmentQueueCount`.

Status-to-badge mapping examples:
- `active` → “Verified”
- `pending` → “Verification Pending”
- `suspended` → “Restricted”
- `rejected` → “Needs Update”

## Backend / API Analysis & Required Improvements

### Existing
- `GET /api/mobile/profile/dashboard-context`
  - `dashboardType`
  - `aiTechnician`, `doctor`
  - `hasAiTechnicianApplication`, `aiTechnicianApplicationStatus`
- `GET /api/mobile/me`
  - `role` (single role)

### Missing for Enterprise Workspaces
- Multi-workspace support (array of roles with status).
- Explicit permissions + workspace-level metadata.
- Consistent verification / suspension status per role.
- Role-specific display name and avatar.
- Workspace routing defaults and ordering.

### Proposed Backend Contract Extension
Add to `/api/mobile/profile/dashboard-context` (or a new `/profile/workspaces`):

```json
{
  "workspaces": [
    {
      "role": "AI_TECHNICIAN",
      "status": "ACTIVE",
      "verificationStatus": "VERIFIED",
      "displayName": "Rahim Technician",
      "metadata": {
        "rating": { "average": 4.8, "count": 120 },
        "pendingRequests": 4
      }
    }
  ],
  "primaryRole": "CUSTOMER"
}
```

Benefits:
- Multi-role visibility in Profile.
- Role-based access without relying on `dashboardType`.
- Future roles can be added without app changes beyond mapping.

## Migration Strategy
1. **Phase 1 (UI + Routing Only)**
   - Make `ProfileGateScreen` always return `ProfileHomeScreen`.
   - Add “Professional Workspaces” section.
   - Gate workspace cards using current `DashboardContext`.
   - Keep `/workspace/*` routes unchanged.

2. **Phase 2 (State & Routing Guards)**
   - Introduce `workspaceEntriesProvider`.
   - Add route guard using `workspaceAccessProvider`.
   - Stop automatic redirect from `/home` to `/workspace/*`.

3. **Phase 3 (Backend Alignment)**
   - Read `workspaces[]` from API when available.
   - Fall back to existing fields for backward compatibility.

## Backward Compatibility Strategy
- If `workspaces[]` is missing:
  - Derive workspaces from `dashboardType`, `aiTechnician`, and `doctor`.
- Do not break users without professional roles:
  - The workspace section stays hidden.
- Preserve current profile settings, wallet, notifications, and account sections.

## Future Scalability Strategy
- Use `ProfessionalRole` as a single entry point for new roles.
- Keep `WorkspaceEntry` data-driven with metadata map for role-specific UI.
- Allow multiple workspace cards in Profile, sorted by `priority`.
- Centralize routes in `WorkspaceRouter` so new roles only add:
  - `ProfessionalRole` mapping
  - `workspaceEntriesProvider` transform
  - workspace route definition (if needed)

## Implementation Steps (Planned, No Code Yet)

### A. Refactor Profile Gate
- `ProfileGateScreen` → always render `ProfileHomeScreen`.
- Remove embedded professional dashboards from profile tab.

### B. Add Workspace Domain Layer
- Add new models in `lib/src/features/workspace/domain/`.
- Create mapping helpers from `DashboardContext` to `WorkspaceEntry`.

### C. Add Workspace Providers
- `workspaceEntriesProvider`
- `workspaceAccessProvider`
- `currentWorkspaceProvider` (persist last workspace)

### D. Update Routing
- Update `redirectForWorkspacePolicy` to:
  - Always allow `/home` for all roles.
  - Enforce `/workspace/*` access based on `workspaceAccessProvider`.
- Keep existing `/workspace/ai-technician` and `/workspace/doctor`.

### E. Profile UI Enhancements
- Insert `Professional Workspaces` section under header.
- Add premium cards with gradient, badge, subtitle, status.
- Hook CTA to `GoRouter` routes.

### F. Quality & QA
- Verify no changes to:
  - Bottom navigation
  - Settings / profile edit flows
  - Notifications and wallet routes
- Test cases:
  - Customer only (no workspace cards)
  - AI Technician approved
  - Doctor approved
  - Mixed roles
  - Pending / suspended statuses

## Open Questions / Assumptions
- Keep existing 5-tab bottom nav unchanged (Home/Doctor/Services/Notifications/Profile).
- Professional workspace access should require authentication; guest users see no cards.
- For pending AI technician applications, show a “Pending” badge with a “View status”
  CTA instead of “Open dashboard”.

