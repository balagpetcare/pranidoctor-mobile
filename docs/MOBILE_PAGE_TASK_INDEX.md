# Prani Doctor Mobile — Page Task Index

Use one **task card** per Cursor assignment. Each card lists goal, files, requirements, acceptance criteria, tests, and a **Git branch** suggestion.

**Global rules:** `MOBILE_TASK_WORKFLOW_RULES.md`, design: `MOBILE_UI_DESIGN_SYSTEM.md`, APIs: `MOBILE_API_INTEGRATION_MAP.md`.

**Test commands (default for every task):**

```bash
cd D:\PraniDoctor\pranidoctor_mobile
flutter pub get
flutter analyze
flutter test
```

---

## Task M01: Design system and theme foundation

**Goal:** Centralize visual tokens and shared UI primitives so later tasks do not fork one-off `TextStyle`s or colors.

**Files likely to inspect**

- `lib/src/app/theme.dart`
- `lib/src/app/screen_padding.dart`
- `lib/src/app/app.dart`
- `analysis_options.yaml`

**Files likely to create/update**

- `lib/src/app/theme.dart` (or new `lib/src/app/tokens.dart`, `lib/src/core/widgets/` as agreed)
- Optionally `lib/src/core/widgets/pd_async_body.dart` (loading/empty/error)
- `docs/MOBILE_UI_DESIGN_SYSTEM.md` (only if tokens change)

**UI requirements**

- Documented alignment with `MOBILE_UI_DESIGN_SYSTEM.md` (colors, type, radii, spacing).
- Optional `ThemeExtension` for semantic colors / spacing constants.

**Functional requirements**

- Light and dark themes still work; no regression in `MaterialApp.router`.
- Existing screens compile without visual breakage (minor intentional tweaks OK).

**API requirements**

- None.

**Acceptance checklist**

- [ ] No hard-coded hex in new feature code paths (use theme roles or extensions).
- [ ] `flutter analyze` clean; `flutter test` passes.
- [ ] Short note in PR describing token layout for future contributors.

**Git branch name suggestion:** `feature/M01-design-system-tokens`

---

## Task M02: App shell, splash, onboarding, bottom navigation

**Goal:** First-run and daily-open experience feels complete: splash branding, onboarding completion, bottom nav clarity, safe areas.

**Files likely to inspect**

- `lib/src/features/splash/splash_screen.dart`
- `lib/src/features/onboarding/onboarding_screen.dart`
- `lib/src/features/home/home_shell_screen.dart`
- `lib/src/app/router.dart`

**Files likely to create/update**

- Above screens; optional `assets/` + `pubspec.yaml` for logo/illustration
- `router.dart` only if shell navigation needs adjustment

**UI requirements**

- Splash: brand mark + Bangla tagline consistent with design system.
- Onboarding: clear steps, dismiss → login path; respects `pd_onboarding_done`.
- Bottom nav: four destinations, selected/unselected icon pattern per design doc.

**Functional requirements**

- Cold start: splash → (onboarding | home | login) per existing prefs + JWT hydrate.
- Back stack behavior sane when pushing modals from shell.

**API requirements**

- None (local prefs + session hydrate only).

**Acceptance checklist**

- [ ] Fresh install sees onboarding once.
- [ ] Returning authenticated user lands on `/home`.
- [ ] Unauthenticated user lands on `/login` after onboarding done.

**Git branch name suggestion:** `feature/M02-app-shell-onboarding-nav`

---

## Task M03: OTP login and auth state

**Goal:** Customer OTP flow is robust: validation UX, resend/timer, error messages, session edge cases (401, stale token).

**Files likely to inspect**

- `lib/src/features/auth/login_entry_screen.dart`
- `lib/src/features/auth/data/mobile_otp_auth_repository.dart`
- `lib/src/features/session/application/session_notifier.dart`
- `lib/src/core/network/dio_provider.dart`
- `lib/src/core/storage/token_storage.dart`

**Files likely to create/update**

- Login screen widgets; optional small `auth` presentation widgets
- `session_notifier.dart` / `dio_provider.dart` only if fixing auth lifecycle bugs

**UI requirements**

- Bengali copy for all user-visible errors and hints; loading states on buttons.
- Phone + OTP fields match input theme; keyboard types correct.

**Functional requirements**

- Request OTP and verify against live or mock API per environment.
- Successful verify → token stored → `context.go` home.
- 401 from API clears session and returns to login without stuck state.

**API requirements**

- `POST /api/mobile/auth/otp/request`, `POST /api/mobile/auth/otp/verify` (see map).

**Acceptance checklist**

- [ ] Invalid phone/OTP shows clear Bangla feedback.
- [ ] Success path matches router redirect rules.
- [ ] Analyze + tests pass; optional widget test for validators.

**Git branch name suggestion:** `feature/M03-otp-login-auth-state`

---

## Task M04: Customer home page

**Goal:** Home tab is the hub: quick actions, deep links to finder/tutorials/requests, no dead-end tiles (or clearly labeled “শীঘ্রই”).

**Files likely to inspect**

- `lib/src/features/home/home_screen.dart`
- `lib/src/features/home/home_shell_screen.dart`
- `lib/src/app/router.dart`

**Files likely to create/update**

- `home_screen.dart`; optional `home/presentation/widgets/`
- Router if new home-adjacent routes added

**UI requirements**

- Grid/list of tiles with icons, Bangla titles, consistent card/touch targets.
- Optional hero banner for campaigns (Bangladesh context).

**Functional requirements**

- Every visible CTA navigates (`go`/`push`) or shows planned stub dialog with copy.
- Links to doctors, technicians, tutorials, notifications work.

**API requirements**

- Optional future: home summary API — **do not add** unless backend task exists; use static/mock sections if needed.

**Acceptance checklist**

- [ ] No silent `default: break` on user-visible tiles without UX explanation.
- [ ] SafeArea + padding via `pdScreenPadding`.

**Git branch name suggestion:** `feature/M04-customer-home`

---

## Task M05: Animal profile list / add / edit / detail

**Goal:** Animals tab is visually polished and consistent: list, empty state, form validation, detail header/photo.

**Files likely to inspect**

- `lib/src/features/animals/presentation/*.dart`
- `lib/src/features/animals/presentation/widgets/*.dart`
- `lib/src/features/animals/data/animal_profile_repository.dart`
- `lib/src/features/animals/application/animals_providers.dart`
- `docs/ANIMAL_PROFILE_PLAN.md`

**Files likely to create/update**

- Presentation screens/widgets; repository only for client-side fixes

**UI requirements**

- List cards reuse design system; placeholder for photos (`animal_photo_placeholder.dart`).
- Forms: labels, errors, primary submit, discard/back.

**Functional requirements**

- CRUD + deactivate flows match repository capabilities.

**API requirements**

- `/api/mobile/animals` endpoints per map.

**Acceptance checklist**

- [ ] Empty list state + loading + error retry.
- [ ] Create/edit success returns to list or detail with feedback.

**Git branch name suggestion:** `feature/M05-animal-profiles-ui`

---

## Task M06: Doctor and AI technician finder

**Goal:** List and detail screens for doctors and technicians: filters, pagination, cards, detail hero.

**Files likely to inspect**

- `lib/src/features/providers/presentation/*.dart`
- `lib/src/features/providers/presentation/widgets/*.dart`
- `lib/src/features/providers/data/provider_finder_repository.dart`
- `docs/PROVIDER_FINDER_MOBILE_PLAN.md`

**Files likely to create/update**

- List/detail screens; `provider_filter_panel.dart`; optional loading skeletons

**UI requirements**

- Filter panel readable in Bangla; chips and area filter UX clear.
- Cards: `doctor_summary_card`, `technician_summary_card` aligned with tokens.

**Functional requirements**

- Pagination or “load more” if API supports; handle `hasMore`.
- Respect repository area-slug coercion rules or improve UX when filter dropped.

**API requirements**

- `GET /api/mobile/providers/doctors`, `.../technicians`, detail by id.

**Acceptance checklist**

- [ ] List empty/error states.
- [ ] Detail loads and shows meaningful sections (bio, services — per model).

**Git branch name suggestion:** `feature/M06-provider-finder-ui`

---

## Task M07: Service request / booking flow

**Goal:** Booking wizard steps are clear: category, animal, symptoms, location notes, review — aligned with MVP plan.

**Files likely to inspect**

- `lib/src/features/service_requests/presentation/booking_wizard_screen.dart`
- `lib/src/features/service_requests/data/service_request_repository.dart`
- `lib/src/features/service_requests/data/service_category_repository.dart`
- `docs/SERVICE_REQUEST_BOOKING_PLAN.md`

**Files likely to create/update**

- Wizard screens/step widgets; minimal repository changes for field mapping only

**UI requirements**

- Step indicator, validation per step, Bangla labels.
- Submit progress and success navigation (e.g. to request detail or list).

**Functional requirements**

- Creates service request with body shape backend expects.
- Document any missing `areaId`/`villageId` vs plan (mobile-only task: UI placeholders OK if agreed).

**API requirements**

- `GET /api/mobile/service-categories`, `POST /api/mobile/service-requests`.

**Acceptance checklist**

- [ ] Cannot submit incomplete required fields.
- [ ] Success and failure paths show clear feedback.

**Git branch name suggestion:** `feature/M07-booking-wizard-ui`

---

## Task M08: Request tracking and request detail

**Goal:** Requests tab + detail screen show status, timeline, cancel rules, and pull-to-refresh if appropriate.

**Files likely to inspect**

- `lib/src/features/service_requests/presentation/service_requests_tab_screen.dart`
- `lib/src/app/router.dart` (detail route)
- `lib/src/features/service_requests/data/service_request_repository.dart`

**Files likely to create/update**

- Tab list UI; detail screen file(s); optional shared status chip widget

**UI requirements**

- List rows with status color via `ColorScheme`; detail with sections.

**Functional requirements**

- List with offset/limit; open detail by id; cancel when API allows (handle 409).

**API requirements**

- `GET /api/mobile/service-requests`, `GET .../:id`, `PATCH .../:id/cancel`.

**Acceptance checklist**

- [ ] Deep link `/service-requests/:id` works from list.
- [ ] Cancel confirmation dialog (Bangla).

**Git branch name suggestion:** `feature/M08-service-requests-tracking`

---

## Task M09: Doctor case workflow pages

**Goal:** Replace doctor stub with real navigation structure and screens for case list, case detail, actions — **once APIs exist**.

**Files likely to inspect**

- `lib/src/features/auth/doctor/presentation/doctor_login_screen.dart`
- `lib/src/features/home/doctor/presentation/doctor_home_screen.dart`
- `lib/src/app/router.dart`

**Files likely to create/update**

- New `features/doctor_cases/` (suggested) or extend `home/doctor/`
- New repositories under `data/` when API contracts are fixed

**UI requirements**

- Professional dense UI for doctor role; Bangla-first with medical terms as needed.
- Distinct color/badge for urgency if product requires.

**Functional requirements**

- Login → home → case flow; sign-out; role separation from customer session (careful with token storage if shared device).

**API requirements**

- **TBD** — define in backend milestone; update `MOBILE_API_INTEGRATION_MAP.md` when known.

**Acceptance checklist**

- [ ] No customer JWT used on doctor endpoints by mistake (document strategy).
- [ ] Stub removed or gated behind feature flag if partial.

**Git branch name suggestion:** `feature/M09-doctor-case-workflow`

---

## Task M10: AI technician service pages

**Goal:** Technician-specific post-booking UX: job list, job detail, status updates — **once APIs exist**.

**Files likely to inspect**

- `lib/src/features/providers/presentation/technician_*`
- `lib/src/app/router.dart`

**Files likely to create/update**

- New feature folder e.g. `features/technician_jobs/` with presentation + providers

**UI requirements**

- Clear status pipeline; maps/contact actions per product spec.

**Functional requirements**

- Mirrors technician operational flow agreed with backend.

**API requirements**

- **TBD** — not in current client grep; add map entries with first implementation.

**Acceptance checklist**

- [ ] Entry point from customer app documented (or intentionally none for v1).

**Git branch name suggestion:** `feature/M10-technician-service-pages`

---

## Task M11: Billing / payment summary pages

**Goal:** Screens summarizing estimate, charges, payment status, receipts — UI ready for API.

**Files likely to inspect**

- `lib/src/features/service_requests/` (link from request detail)
- `lib/src/app/router.dart`

**Files likely to create/update**

- New `features/billing/` or under `service_requests/presentation/`

**UI requirements**

- Currency display (BDT), date formatting with `intl`, Bangla labels.

**Functional requirements**

- Read-only summary v1 acceptable; payment deep links TBD.

**API requirements**

- **TBD** — coordinate with backend before wiring.

**Acceptance checklist**

- [ ] Placeholder state if API missing — behind clear “শীঘ্রই” or hidden route until ready (product decision).

**Git branch name suggestion:** `feature/M11-billing-payment-ui`

---

## Task M12: Notification center

**Goal:** Notifications list is polished: unread styling, mark read, mark all, empty state.

**Files likely to inspect**

- `lib/src/features/notifications/presentation/notifications_list_screen.dart`
- `lib/src/features/notifications/data/notification_repository.dart`
- `docs/MOBILE_NOTIFICATION_PLAN.md`

**Files likely to create/update**

- List screen; optional notification row widget; providers for optimistic UI

**UI requirements**

- Unread indicator; swipe or button actions per platform convention.

**Functional requirements**

- Pagination if needed; `markRead`, `markAllRead` wired with error handling.

**API requirements**

- `GET /api/notifications`, `PATCH .../:id/read`, `PATCH .../read-all`.

**Acceptance checklist**

- [ ] Empty + error + loading states.
- [ ] Tap opens deep link or detail if product adds payload URLs later.

**Git branch name suggestion:** `feature/M12-notification-center-ui`

---

## Task M13: Knowledge hub / tutorial pages

**Goal:** Tutorial list and detail match knowledge hub plan: categories, search/filter optional, readable article layout.

**Files likely to inspect**

- `lib/src/features/tutorials/presentation/*.dart`
- `lib/src/features/tutorials/data/tutorial_repository.dart`
- `docs/KNOWLEDGE_HUB_MOBILE_PLAN.md`

**Files likely to create/update**

- List/detail UI; markdown/html renderer **only if** backend returns rich content (add dependency only then — prefer existing packages).

**UI requirements**

- Category headers, list spacing, detail typography for long Bangla text.

**Functional requirements**

- Category filter and pagination (`take`/`skip`) per repository.

**API requirements**

- `/api/mobile/tutorials/categories`, `/api/mobile/tutorials`, `/api/mobile/tutorials/:slugOrId`.

**Acceptance checklist**

- [ ] 404 / slow network messaging per repository behavior.

**Git branch name suggestion:** `feature/M13-knowledge-hub-ui`

---

## Task M14: Profile / settings / support pages

**Goal:** Expand profile tab beyond placeholder: settings groups, language toggle (if product adds), support contact, legal links, sign out.

**Files likely to inspect**

- `lib/src/features/home/home_shell_screen.dart` (`_ProfileTab`)
- `lib/src/app/app.dart` (locale)
- `lib/src/features/session/application/session_notifier.dart`

**Files likely to create/update**

- New `features/profile/` or `presentation/profile_screen.dart` imported into shell
- Router subroutes only if profile needs full-screen routes

**UI requirements**

- List group cards; version/build info from `package_info_plus` **only if** dependency approved in workflow rules.

**Functional requirements**

- Sign out → login; optional locale persistence.

**API requirements**

- Optional `GET` user profile — **TBD**; do not invent paths without backend.

**Acceptance checklist**

- [ ] Support channel (phone/WhatsApp/web) copy approved by product.
- [ ] No dead links.

**Git branch name suggestion:** `feature/M14-profile-settings-support`

---

## Task M15: Final UI polish and QA

**Goal:** Cross-app consistency pass: typography audit, contrast, tap targets, strings, router edge cases, performance (jank, rebuilds).

**Files likely to inspect**

- All `lib/src/features/**/presentation/**/*.dart`
- `lib/src/app/router.dart`, `theme.dart`

**Files likely to create/update**

- Small fixes across many files; avoid large refactors unless necessary

**UI requirements**

- Meets `MOBILE_UI_DESIGN_SYSTEM.md` checklist section-by-section.

**Functional requirements**

- Smoke script documented in PR (bullet list of paths tested).

**API requirements**

- Regression only — no new endpoints unless explicitly scoped.

**Acceptance checklist**

- [ ] `flutter analyze` + `flutter test` on CI/local.
- [ ] MVP audit checklist re-reviewed; remaining gaps listed for backlog.

**Git branch name suggestion:** `feature/M15-ui-polish-qa`

---

## Suggested execution order (dependency-aware)

`M01` → `M02` → (`M03` in parallel with M01/M02 if separate owners) → `M04` → `M05` → `M06` → `M07` → `M08` → `M12` / `M13` / `M14` (often parallel) → `M09`–`M11` when APIs ready → `M15` last.
