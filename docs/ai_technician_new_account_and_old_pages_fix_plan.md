# AI Technician — New Account, Blank Screens & Legacy Pages — Audit & Fix Plan

**Scope:** Prani Doctor / Animal Doctors only (`pranidoctor_mobile`, `pranidoctor-web` as needed).  
**Status:** Diagnostic audit only — **no implementation** in the audit pass that produced this document.

---

## 1. Executive summary

Several reported symptoms (cannot start application, “empty” wizard steps, only sticky bottom actions visible, dark vs white backgrounds) line up with **three parallel buckets**:

1. **Backend authorization prerequisites** — AI Technician mobile routes require an **active `CUSTOMER` user with a `CustomerProfile`** (`requireMobileAiTechnicianModuleUser` in `pranidoctor-web`). Users without that linkage get **403**; the mobile app surfaces generic failure (form load error or snackbar), which feels like “cannot apply.”
2. **Wizard layout composition** — `AiTechnicianApplicationFormScreen` uses **`Stack` → `Column` → `Expanded` → `PageView` → `SingleChildScrollView`** with **`PraniStickyActionBar`** as `bottomNavigationBar`. This is structurally valid but **sensitive to constraints, theme mode, and keyboard/viewInsets**; any miscalculation (or a full-screen overlay such as submit blocking layer) can present as “only bottom buttons” or a bare colored region.
3. **UX / design consistency** — Multiple surfaces (`ai_technician_application/*`, `technician_ai/*`, profile edit, dashboard) were evolved separately; **theme (light vs system dark), cards, and empty states** diverge, which reads as “broken old pages” even when APIs succeed.

---

## 2. Exact files inspected (primary)

### Mobile — routing & entry

| Path | Relevance |
|------|-----------|
| `lib/src/app/router.dart` | `GoRouter` redirects; AI technician routes are top-level (not nested under `HomeShellScreen`). |
| `lib/src/features/ai_technician_application/presentation/ai_technician_entry.dart` | **Single entry** from profile: `aiTechnicianMeProvider` → intro / form / dashboard / status. |
| `lib/src/features/profile/presentation/profile_home_screen.dart` | “এআই টেকনিশিয়ান আবেদন” tile → `openAiTechnicianApplicationEntry`. |
| `lib/src/features/profile/presentation/edit_profile_documents_screen.dart` | Secondary entry to same flow. |

### Mobile — AI Technician application UI

| Path | Relevance |
|------|-----------|
| `lib/src/features/ai_technician_application/presentation/ai_technician_application_form_screen.dart` | Multi-step form: `_bootstrap`, `Stack` + `PageView`, `_scrollStep` (keyboard bottom padding), `PraniStickyActionBar`. |
| `lib/src/features/ai_technician_application/presentation/ai_technician_intro_screen.dart` | Marketing intro; pushes form route. |
| `lib/src/features/ai_technician_application/presentation/ai_technician_application_status_screen.dart` | `aiTechnicianMeProvider`; null profile message. |
| `lib/src/features/ai_technician_application/presentation/ai_technician_dashboard_screen.dart` | Dashboard; empty profile branch. |
| `lib/src/features/ai_technician_application/presentation/ai_technician_dashboard_body.dart` | (Referenced by dashboard — verify scroll/cards in implementation phase.) |
| `lib/src/features/ai_technician_application/application/ai_technician_providers.dart` | `aiTechnicianMeProvider`, dashboard, job lists. |
| `lib/src/features/ai_technician_application/data/ai_technician_repository.dart` | `GET me`, `POST apply`, `POST submit`, documents. |

### Mobile — shell, theme, layout primitives

| Path | Relevance |
|------|-----------|
| `lib/src/features/home/home_shell_screen.dart` | Tab shell; **not** wrapping pushed `/profile/ai-technician/*` routes. |
| `lib/src/app/app.dart` | `ThemeMode.system` → dark/light flip. |
| `lib/src/app/theme.dart` | `scaffoldBackgroundColor` (`PraniColors.background` / `darkScaffold`) vs `ColorScheme.surface`. |
| `lib/src/design_system/widgets/prani_scaffold.dart` | `SafeArea(top: false)` when `AppBar` present; body padding. |
| `lib/src/design_system/widgets/prani_sticky_action_bar.dart` | Elevated bottom bar; surface-colored. |

### Mobile — “legacy” technician surfaces (naming overlap)

| Path | Relevance |
|------|-----------|
| `lib/src/features/technician_ai/**/*.dart` | **Separate** product surface (`/technician/*` routes in `router.dart`) — different role/shell; avoid mixing with customer AI Technician pipeline in UX copy. |
| `lib/src/features/providers/**/*.dart` | Provider listing/detail — distinct from AI Technician **application** flow. |

### Backend — auth guard & AI Technician APIs

| Path | Relevance |
|------|-----------|
| `src/lib/mobile-ai-technician/mobile-module-guard.ts` | **403** if `CUSTOMER` without `customerProfile`; JWT required. |
| `src/app/api/mobile/ai-technician/me/route.ts` | Returns `profile: null` + message when no technician profile. |
| `src/app/api/mobile/ai-technician/apply/route.ts` | `POST` JSON body validated by Zod; requires same guard as `me`. |
| `src/lib/mobile-auth/otp-service.ts` | **`ensureCustomerUserForPhone`** creates **`customerProfile`** on **new** user; **existing** user without profile → OTP verify fails (`LOGIN_NOT_ALLOWED`). |

---

## 3. Root cause — new account cannot apply

### 3.1 Backend guard (high confidence)

`requireMobileAiTechnicianModuleUser` requires:

- Valid Bearer JWT (`verifyMobileJwt`).
- `User.status === ACTIVE`.
- If `role === CUSTOMER`: **`customerProfile` must exist** or response is **403** — `"Customer profile required for this resource"`.

**Implication:** Any account that can complete OTP as a normal customer **should** have a profile (new signups create `customerProfile` in `ensureCustomerUserForPhone`). **Failures cluster as:**

- **403 / unauthorized** on `GET /api/mobile/ai-technician/me` or `POST .../apply` → interceptor missing token, wrong environment base URL, or **legacy/inconsistent DB row** (customer without profile).
- **403** with inactive user or non-customer role.

### 3.2 Mobile bootstrap (`AiTechnicianApplicationFormScreen._bootstrap`)

Flow:

1. `fetchMe()` → if `profile == null`, **`POST apply({})`** to create draft.
2. Any exception → full-screen **`PraniErrorState`** (“লোড ব্যর্থ”), not a silent failure.

**Implication:** “Cannot apply” is usually **visible** as load failure unless errors are swallowed elsewhere (e.g. user dismisses snackbar from `openAiTechnicianApplicationEntry`).

### 3.3 Entry routing (`openAiTechnicianApplicationEntry`)

- **`me.profile == null`** → **`AiTechnicianIntroScreen`** only (form not opened until user taps through intro).
- **`profile.isEditable`** → form.
- **`APPROVED` / `PUBLISHED`** → dashboard.
- Else → status screen.

**Implication:** New users with **no** technician profile always see **intro first** — not a bug, but can be mistaken for “blocked” if copy/testing expects landing directly on the wizard.

---

## 4. Root cause — blank / dark / white steps; only bottom buttons visible

### 4.1 Layout stack (high priority for investigation)

In `ai_technician_application_form_screen.dart` (editable path):

- `PraniScaffold`(`padding: EdgeInsets.zero`) → `body: Stack` →  
  - `Column`: header (`PraniStepProgressHeader`) + **`Expanded`** wrapping `Material` + **`PageView`** (steps).
  - Optional **`Positioned.fill`** overlay when `_submitting`.
- **`bottomNavigationBar`**: `PraniStickyActionBar` → `_buildBottomActions`.

**Why users report “only buttons”:**

- **Expanded + PageView + SingleChildScrollView** is standard, but combined with **`padding: EdgeInsets.zero`**, **`SafeArea(top: false)`** on scaffold body, and **large `_scrollStep` bottom padding** (`MediaQuery.viewInsetsOf(context).bottom + constants`), step content may sit **above the fold** or appear “empty” until scroll — especially with keyboard open or short phones.
- **`ThemeMode.system`** → **dark** scaffold (`PraniColors.darkScaffold`, teal primary) vs light — users describe **dark green/black** vs **white** backgrounds; both can occur **without** fixing missing widgets — it’s often **theme + empty-looking scroll region**.

### 4.2 Full-screen overlay

When **`_submitting`** is true, **`Positioned.fill`** scrim covers the stack — if submission hangs, UI looks “stuck” with only perceived chrome (in practice the overlay blocks interaction).

### 4.3 API empty state (medium)

If `_bootstrap` succeeds but **`PageView` builds with zero-height children** (unlikely if analyzer passes), that would be a layout bug — **verify in runtime** with Flutter inspector on failing devices.

### 4.4 Text vs background (lower unless proven)

Step builders set explicit `color: scheme.onSurface` / `onSurfaceVariant` in several places — **global “invisible text”** is unlikely unless a widget subtree uses **wrong `Theme`** or **`Colors.transparent`** text (spot-check `PraniSectionHeader`, `PraniFormCard` defaults during implementation).

### 4.5 Loading/error swallowed (medium)

- Form: loading and error paths are explicit (`PraniLoadingState`, `PraniErrorState`).
- **`openAiTechnicianApplicationEntry`**: failures → **SnackBar** only — easy to miss.

---

## 5. Pages / flows needing design repair (inventory)

Prioritize shared components over one-off screens.

| Surface | Issue pattern |
|---------|----------------|
| `AiTechnicianApplicationFormScreen` | Wizard density, keyboard padding, sticky footer vs scroll region; dark mode contrast on `Material` / `PageView`. |
| `AiTechnicianIntroScreen` vs intro step inside form | Duplicate “benefits” content — feels inconsistent. |
| `AiTechnicianApplicationStatusScreen` | Functional but minimal empty/error presentation; align with `PraniErrorState` / `PraniEmptyState`. |
| `AiTechnicianDashboardScreen` + body | Mixed `ListView` / cards — align section spacing with profile tab. |
| `ProfileHomeScreen` | Entry tile doesn’t explain prerequisites or failure modes. |
| `EditProfile*` screens | Older edit flows vs new AI Technician cards — typography/spacing drift. |
| `technician_ai/*` (worker app routes) | Different visual language — ensure navigation paths don’t confuse **customer AI Technician applicants**. |

---

## 6. Required UI / design-system fixes (directional)

**Without adding duplicate widgets — reuse:**

- **`PraniScaffold` / `PraniStickyActionBar`**: Standardize **minimum body padding** so `padding: EdgeInsets.zero` screens still respect horizontal rhythm where needed (or document when zero padding is intentional).
- **Wizard screens**: Prefer **one pattern**: either `column + expanded + scroll` **without** `Stack`, or keep `Stack` only for **loading overlay** — reduce layering.
- **Keyboard**: Centralize **bottom inset + sticky action bar** behavior (avoid double-padding scroll content and scaffold).
- **Dark mode**: Snapshot **Wizard + Profile + Status** in dark theme; align `Material` wrappers so step bodies use **`colorScheme.surface`** consistently (not only `scaffoldBackgroundColor`).
- **Typography**: Ensure Bengali **`titleMedium` / `bodyMedium`** contrast on **`surface` vs `surfaceContainer`** in all AI Technician cards.

---

## 7. Required state / routing / API fixes (directional)

1. **Confirm Dio** attaches **Bearer** token to `/api/mobile/ai-technician/*` (same as `/api/mobile/me`).
2. **Map 403** from technician guard to a **user-actionable message** (Bengali): complete customer profile / re-login — don’t rely on generic snackbars.
3. **Entry UX**: Consider **direct navigation** from profile tile to **form** when `me.profile == null` and intro is redundant — or make intro a **single** place (remove duplicate intro step in wizard) — **product decision**.
4. **`aiTechnicianMeProvider` invalidation**: After successful `apply` bootstrap, provider invalidation already exists — ensure **status/dashboard** screens refresh after submit across navigators (`push` vs `pushReplacement`).
5. **Backend (only if DB audit confirms gaps):** Ensure no production users lack `customerProfile`; optionally add **repair migration or lazy-create profile** on `GET /api/mobile/me` — **policy decision**, not mobile-only.

---

## 8. Exact implementation steps (for a future PR — not executed in this audit)

1. **Reproduce** on physical device with **network logging** (Charles / Proxyman / server logs): capture `GET me`, `POST apply`, status codes for fresh OTP user.
2. **Flutter Inspector**: On “blank” step, inspect **`RenderFlex` / `PageView` viewport height** and **`SingleChildScrollView` scroll extent**.
3. **Adjust layout** of `AiTechnicianApplicationFormScreen` to eliminate ambiguity: e.g. replace inner `Stack` with `Column` + overlay via **`ModalBarrier`** only when submitting, or move submit overlay to **`Overlay`** / dialog.
4. **Tune `_scrollStep` bottom padding** — cap keyboard padding multiplier if excessive; test with IME open on smallest supported height.
5. **Unify empty/error** on `AiTechnicianApplicationStatusScreen` with design-system widgets.
6. **Profile entry**: Add short subtitle or dialog if `fetchMe` fails (403) explaining **customer profile required**.
7. **Regression:** Customer profile photo flows (`EditProfilePhotosScreen`) unchanged.
8. **Backend only if needed:** Align guard behavior with product — document or relax **only** with security review.

---

## 9. Testing checklist

### New account (fresh OTP)

- [ ] OTP verify succeeds; `GET /api/mobile/me` returns customer with profile.
- [ ] Profile tab → “এআই টেকনিশিয়ান আবেদন” → intro → form loads **without** red error state.
- [ ] `GET /api/mobile/ai-technician/me` returns `profile: null` then `POST apply` returns **200** with draft profile.
- [ ] Each wizard step shows **visible** header + scrollable fields + bottom actions (portrait + dark mode).

### Existing account — no technician application

- [ ] Same as above; **`openAiTechnicianApplicationEntry`** shows intro when `profile == null`.

### Draft (`DRAFT` or `NEEDS_CORRECTION`)

- [ ] Entry opens **form** directly (`isEditable`).
- [ ] Draft save restores controllers and location selections after kill/relaunch.

### Submitted / pending (`SUBMITTED`, `UNDER_REVIEW`, …)

- [ ] Entry routes to **status** (not form).
- [ ] Status screen shows status chip + narrative + optional admin notes.

### Approved / published

- [ ] Entry routes to **dashboard**.
- [ ] Dashboard refresh works; services/requests links behave.

### Rejected

- [ ] Status/copy accurate; user guided to support or re-apply per product rules.

### Regression — profile / uploads

- [ ] `EditProfilePhotosScreen` / documents screens unchanged for unrelated regressions.

---

## 10. Commands after implementation

From repo roots:

```bash
cd D:\PraniDoctor\pranidoctor_mobile
flutter analyze
flutter test
```

```bash
cd D:\PraniDoctor\pranidoctor-web
npx prisma validate
npm run lint
npm run build
```

---

## 11. Findings checklist (audit log)

| Finding | Severity | Where |
|---------|----------|--------|
| AI Technician APIs require **CustomerProfile** for `CUSTOMER` JWT | **High** | `mobile-module-guard.ts` |
| New OTP users get profile in **`ensureCustomerUserForPhone`** | Mitigation | `otp-service.ts` |
| Wizard uses **Stack + Expanded PageView + sticky bottom bar** — sensitive to keyboard/insets | **High** | `ai_technician_application_form_screen.dart` |
| **ThemeMode.system** explains dark vs light “background” reports | Medium | `app.dart`, `theme.dart` |
| Profile entry uses **SnackBar-only** errors for `fetchMe` failures | Medium | `ai_technician_entry.dart` |
| Intro duplicated (**intro screen + step 0 intro**) | Low / UX | `ai_technician_intro_screen.dart`, form step 0 |

---

*Document generated as an audit artifact — implementation should reference code review and device QA before merge.*
