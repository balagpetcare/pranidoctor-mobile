# Prani Doctor Mobile — UI Implementation Master Plan

**Repository:** `https://github.com/balagpetcare/pranidoctor-mobile` (local: `pranidoctor_mobile`)  
**Scope:** Prani Doctor / Animal Doctors **mobile only** — no other products.  
**Companion docs:** `MOBILE_UI_DESIGN_SYSTEM.md`, `MOBILE_PAGE_TASK_INDEX.md`, `MOBILE_API_INTEGRATION_MAP.md`, `MOBILE_TASK_WORKFLOW_RULES.md`  
**Audit date:** 2026-05-09

---

## 1. Current project status (audit summary)

### 1.1 `lib/` layout

| Area | Path pattern | Notes |
|------|--------------|--------|
| Entry | `lib/main.dart` | `ProviderScope` + `PraniDoctorApp` |
| App shell | `lib/src/app/` | `app.dart`, `router.dart`, `theme.dart`, `screen_padding.dart`, `navigation_keys.dart` |
| Core | `lib/src/core/config/`, `network/`, `storage/` | `AppConfig`, `Dio` + `ApiClient`, secure token storage |
| Features | `lib/src/features/*/` | Each feature: `application/`, `data/`, `presentation/` (Riverpod + screens) |

**Features present:** `auth`, `auth/doctor`, `session`, `splash`, `onboarding`, `home`, `home/doctor`, `animals`, `service_requests`, `providers`, `tutorials`, `notifications`.

### 1.2 `pubspec.yaml`

- **SDK:** `^3.11.5`
- **Dependencies:** `flutter_riverpod`, `dio`, `go_router`, `flutter_secure_storage`, `shared_preferences`, `intl`, `flutter_localizations`, `cupertino_icons`
- **Dev:** `flutter_test`, `flutter_lints`
- **Assets:** default Material only (no `assets:` block yet — **opportunity** for logos/illustrations in M01/M02)

### 1.3 Routing (`go_router`)

| Path | Screen | Auth gate |
|------|--------|-----------|
| `/splash` | Splash | Public |
| `/onboarding` | Onboarding | Public |
| `/login` | Customer OTP login | Public |
| `/home` | Home shell (bottom nav + tabs) | Customer authenticated |
| `/doctor/login`, `/doctor/home` | Doctor stub | Public (`/doctor/*` bypass in redirect) |
| `/providers/doctors`, `/providers/doctors/:id` | Doctor list/detail | Auth |
| `/providers/technicians`, `/providers/technicians/:id` | Technician list/detail | Auth |
| `/notifications` | Notifications list | Auth |
| `/tutorials`, `/tutorials/:slugOrId` | Tutorial list/detail | Auth |
| `/booking/new` | Booking wizard | Auth |
| `/service-requests/:requestId` | Service request detail | Auth |

**Embedded (no top-level route):** `HomeScreen`, `ServiceRequestsTabScreen`, `AnimalsTabScreen`, profile tab inside `HomeShellScreen` `IndexedStack`.

### 1.4 Theme

- **Material 3** light/dark from seed teal `0xFF0F766E` (`theme.dart`).
- **Locale:** `bn_BD` default; `en_US` supported (`app.dart`).
- **NavigationBar** height 72; cards radius 16; inputs/buttons radius 12.

### 1.5 API / auth

- **OTP:** `MobileOtpAuthRepository` → `/api/mobile/auth/otp/request|verify`; `LoginEntryScreen` calls `SessionNotifier.signInCustomer` on success.
- **Session:** `SessionNotifier` hydrates JWT from storage on splash; `Dio` attaches Bearer token; **401** signs out and goes to login.
- **Repositories:** animals, service requests (+ categories), providers, tutorials, notifications — see `MOBILE_API_INTEGRATION_MAP.md`.

### 1.6 `docs/` folder (existing)

Includes `MVP_AUDIT_AND_LAUNCH_CHECKLIST.md`, `MOBILE_APP_FOUNDATION_PLAN.md`, feature plans (animals, booking, provider finder, knowledge hub, notifications), and delivery reports. **New** UI execution docs are listed in the companion docs line above.

### 1.7 Gaps vs polished product UI

- Doctor flows are **stub**; no `/api/doctor/*` client yet.
- **Billing/payment** screens and APIs not present.
- Some **home tiles** are placeholders (no navigation).
- **Design tokens** live mostly in `ThemeData` — no separate token file or `ThemeExtension` yet.
- **Tests:** default `widget_test` only — room for feature/widget tests per task.

---

## 2. Target app structure (north star)

**Customer (primary MVP)**

1. Splash → onboarding (first run) → OTP login → **Home shell**  
2. Bottom nav: **Home** | **Service requests** | **Animals** | **Profile**  
3. Stack/push flows: provider finder, tutorials, booking wizard, request detail, notifications, settings subpages  

**Doctor / AI technician (later phases)**

- Dedicated auth and home/case workflows (M09, M10) aligned with backend contracts.

**Shared**

- Single `GoRouter` + Riverpod; feature-first folders; reusable widgets and design tokens.

---

## 3. UI design implementation approach

1. **Design system first (M01)** — align `theme.dart` with `MOBILE_UI_DESIGN_SYSTEM.md`; add small shared primitives (spacing, states) without rebuilding every screen.
2. **Shell second (M02)** — splash, onboarding, bottom nav, profile tab entry points feel production-grade.
3. **Vertical slices** — each task (M03–M14) owns one **user journey** end-to-end for UI + wiring; avoid horizontal “change all buttons” across the whole app unless M01/M15.
4. **API-aware UI** — every screen documents loading/empty/error; repositories already map many errors to Bangla strings.
5. **Polish last (M15)** — motion, consistency pass, a11y spot-check, golden/screenshot optional later.

---

## 4. Page-by-page roadmap (high level)

| Order | Task id | Focus |
|-------|---------|--------|
| 1 | M01 | Design system & theme foundation |
| 2 | M02 | App shell: splash, onboarding, bottom nav |
| 3 | M03 | OTP login & auth state edge cases |
| 4 | M04 | Customer home |
| 5 | M05 | Animal profile list/add/edit/detail |
| 6 | M06 | Doctor & AI technician finder |
| 7 | M07 | Service request / booking flow |
| 8 | M08 | Request tracking & detail |
| 9 | M09 | Doctor case workflow pages |
| 10 | M10 | AI technician service pages |
| 11 | M11 | Billing / payment summary |
| 12 | M12 | Notification center |
| 13 | M13 | Knowledge hub / tutorials |
| 14 | M14 | Profile / settings / support |
| 15 | M15 | Final polish & QA |

Detailed acceptance criteria live in **`MOBILE_PAGE_TASK_INDEX.md`**.

---

## 5. Shared component roadmap

| Phase | Components (examples) |
|-------|------------------------|
| M01 | `PdScreenScaffold`, section header, `PdAsyncBody` (loading/error/empty), token constants |
| M02–M04 | Promotional banner, home tile, list skeleton |
| M05–M08 | Entity cards, status chips, timeline stepper for requests |
| M09–M11 | Case summary card, fee row, payment status badge |
| M12–M14 | Notification row, settings group card |
| M15 | Motion, haptics optional, global string audit |

Prefer **adding** widgets under `lib/src/features/<feature>/presentation/widgets/` or a new `lib/src/core/widgets/` once M01 establishes the pattern.

---

## 6. API integration roadmap

- **Stable:** OTP, animals, service categories, service requests, provider lists/details, tutorials, notifications — see map.
- **TBD / backend coordination:** doctor APIs, technician job execution APIs, billing, push notification payload handling.
- **Rule:** Mobile tasks **consume** APIs; extend `MOBILE_API_INTEGRATION_MAP.md` when adding methods.

---

## 7. Testing and verification rules

Per `MOBILE_TASK_WORKFLOW_RULES.md`:

1. `flutter pub get` when dependencies change  
2. `flutter analyze` — clean for touched code  
3. `flutter test` — all green  
4. Manual smoke on emulator for navigation/regressions on changed flows  

**Stretch goals (M15):** widget tests for router redirects; golden tests for key screens (optional, team decision).

---

## 8. Git branch workflow

| Step | Action |
|------|--------|
| 1 | `git checkout main && git pull` |
| 2 | `git checkout -b <branch>` — see per-task suggestions in `MOBILE_PAGE_TASK_INDEX.md` (e.g. `feature/M04-customer-home`) |
| 3 | Implement **single task** scope |
| 4 | Run analyze + test |
| 5 | Commit with task id in message; open PR to `main` |
| 6 | After merge, delete branch; next task repeats from step 1 |

**Naming convention:** `feature/Mxx-short-slug` or `ui/Mxx-short-slug` — team can pick one style and keep it consistent.

---

## 9. How to use this system in Cursor

1. Open **`MOBILE_PAGE_TASK_INDEX.md`** and pick the next task card.  
2. Follow **`MOBILE_TASK_WORKFLOW_RULES.md`**.  
3. For colors/type/spacing, follow **`MOBILE_UI_DESIGN_SYSTEM.md`**.  
4. For endpoints, follow **`MOBILE_API_INTEGRATION_MAP.md`**.  
5. Update MVP/feature docs only when the task explicitly includes documentation.

**Next recommended task after this planning drop:** **M01** (design system foundation) or **M03** if M01 is considered “good enough” and auth polish is higher priority — see MVP audit P0 items.
