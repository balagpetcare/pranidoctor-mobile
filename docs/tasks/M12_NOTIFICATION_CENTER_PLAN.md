# Task M12 — Notification Center (Audit & Plan)

**Project:** Prani Doctor / Animal Doctors — **mobile app only**  
**Domain:** [https://pranidoctor.com/](https://pranidoctor.com/)  
**Repo:** [github.com/balagpetcare/pranidoctor-mobile](https://github.com/balagpetcare/pranidoctor-mobile)  
**Local path:** `D:\PraniDoctor\pranidoctor_mobile`

**Goal:** In-app **notification center** for mobile customers: list, read/unread, Bengali-first UI, integration with home/shell where it fits the existing shell pattern.

**Isolation:** No BPA/WPA, Quarbani 2026, or other products. **No backend changes** in this task’s scope (mobile aligns to whatever routes the deployed API exposes).

**Last updated:** 2026-05-09 — **M12 implemented** and **verified** (format + analyze + tests; see §20).

---

## 19. Implementation summary (2026-05-09)

### 19.1 Delivered behavior

- **HTTP:** All notification calls use **`/api/mobile/notifications`** (list, `/:id/read`, `/read-all`) via `NotificationRepository._basePath`.
- **Model:** `AppNotification` supports **`body` or `message`**, optional **`relatedRequestId`** (top-level or metadata), optional **`metadata`** (`metadata` map or JSON **`metadataJson`** string). **`message`** getter aliases **`body`**. **`userId`** optional when API omits it.
- **Unread count:** `unreadNotificationsTotalProvider` — `GET` list with `unreadOnly=true`, `limit=1`, uses **`total`**. Invalidated whenever the list notifier **`refresh()`** runs (including **`markRead`** / **`markAllRead`**) and after the list provider’s initial **`build()`** **`_load()`** completes.
- **List UI:** Bengali copy retained; **recent (7 days) / older** sections (**সাম্প্রতিক** / **পুরোনো**); **type → Bengali label + icon** for the eight expected types + safe fallback; **empty state** with icon + subtitle; **AppBar** chip **`N অপঠিত`** when count &gt; 0.
- **Detail:** **Modal bottom sheet** with full body, type, optional related request line, timestamp; **tap row** triggers **`markRead`** when unread (fire-and-forget with error **SnackBar**).
- **Home:** **`SliverAppBar.large`** **`NotificationBellIconButton`** (badge) → `/notifications`.
- **Profile tab:** **`ListTile`** trailing **Badge** with unread count when &gt; 0.
- **Routing:** Unchanged **`/notifications`** → **`NotificationsListScreen`** (existing **`router.dart`**).

### 19.2 Files touched / added

| File | Change |
|------|--------|
| `lib/src/features/notifications/data/notification_repository.dart` | `_basePath` → `/api/mobile/notifications` |
| `lib/src/features/notifications/data/notification_model.dart` | `message`/`body`, metadata, `relatedRequestId`, tolerant parsing |
| `lib/src/features/notifications/application/notifications_providers.dart` | `unreadNotificationsTotalProvider`; invalidate unread on refresh/build |
| `lib/src/features/notifications/presentation/notifications_list_screen.dart` | Grouping, types, empty state, AppBar chip, bottom sheet, auto mark-read on open |
| `lib/src/features/notifications/presentation/widgets/notification_type_labels.dart` | **New** — BN labels + icons per type |
| `lib/src/features/notifications/presentation/widgets/notification_bell_icon_button.dart` | **New** — bell + badge |
| `lib/src/features/home/home_screen.dart` | Bell action on home app bar |
| `lib/src/features/home/home_shell_screen.dart` | Profile notification row badge |

### 19.3 Follow-ups (not blocking)

- Align **`docs/MOBILE_NOTIFICATION_PLAN.md`** HTTP paths with `/api/mobile/notifications` when that doc is next edited (avoid drift).
- Optional **pagination** / **pull** efficiency if unread badge polling is added later.

---

## 1. Required product scope (notification kinds)

Placeholders and workflow notices (server-driven `type` string + copy):

| Kind | Intent |
|------|--------|
| OTP / login notice | Placeholder copy when backend emits (e.g. security/login alerts) |
| Request submitted | Service request lifecycle |
| Doctor accepted | Provider assignment |
| Technician accepted | Provider assignment |
| Request completed | Closure |
| Payment / billing update | Billing events |
| Follow-up reminder | Placeholder |
| Admin / system notice | Broadcast / ops messages |

**Note:** The mobile app does **not** create these events; it **displays** rows returned by the API. Client-side work is **mapping `type` → Bengali label** (and optional icon) where useful.

---

## 2. Expected API (task spec vs codebase)

| Operation | Task spec | Current mobile implementation |
|-----------|-----------|-------------------------------|
| List | `GET /api/mobile/notifications` | **Implemented** — `NotificationRepository._basePath` |
| Mark one read | `PATCH /api/mobile/notifications/:id/read` | **Implemented** |
| Mark all read | `PATCH /api/mobile/notifications/read-all` | **Implemented** |

**Query parameters (already implemented):** `limit`, `offset`, `unreadOnly` (`true` / `false`).

**Response envelope (already assumed):** `{ ok: true, data: { ... } }` with errors `{ ok: false, error: { message, code? } }` — same pattern as other mobile features (`NotificationRepository._unwrap`).

**Status:** Mobile client **uses `/api/mobile/notifications`** (see §19). Backend must expose these routes for the app to succeed end-to-end.

---

## 3. Audit — notification-related files

| Path | Role |
|------|------|
| `lib/src/features/notifications/data/notification_model.dart` | `AppNotification`: `id`, `userId`, `type`, `title`, `body`, `readAt`, `createdAt`; `isUnread` |
| `lib/src/features/notifications/data/notification_repository.dart` | HTTP + `NotificationApiException`; Bengali error mapping |
| `lib/src/features/notifications/application/notifications_providers.dart` | `notificationRepositoryProvider`, `notificationsListProvider` (`AsyncNotifier`) |
| `lib/src/features/notifications/presentation/notifications_list_screen.dart` | Full screen: loading/error/empty, filter chip, cards, dialog detail, mark read / mark all |

**Prior doc (overlap):** `docs/MOBILE_NOTIFICATION_PLAN.md` — describes older `/api/notifications` contract and MVP UI; **M12** supersedes for task alignment and remaining gaps (mobile paths, badge, grouping, type catalog).

---

## 4. Audit — home / topbar / entry points

| Location | Finding |
|----------|---------|
| `lib/src/features/home/home_screen.dart` | `SliverAppBar.large` title **হোম** — **no** trailing notification icon; menu tile **নোটিফিকেশন** navigates to `/notifications` |
| `lib/src/features/home/home_shell_screen.dart` | Bottom nav shell; **প্রোফাইল** tab `ListTile` **নোটিফিকেশন** → `context.push('/notifications')` |
| `lib/src/features/home/doctor/presentation/doctor_home_screen.dart` | Doctor shell — **no** notification entry (consistent with customer-only inbox in existing docs) |

**Gap vs M12 (resolved in §19):** Home **bell + badge**, profile **badge**, **সাম্প্রতিক / পুরোনো** grouping, type labels — **implemented**.

---

## 5. Audit — routing / navigation

| Path | Finding |
|------|---------|
| `lib/src/app/router.dart` | `GoRoute` `/notifications` → `NotificationsListScreen`; auth redirect sends unauthenticated users to login |
| `lib/src/app/navigation_keys.dart` | Root navigator key (used by Dio 401 → login) |

**Plan:** Keep **`NotificationsListScreen.routePath` = `/notifications`** unless product mandates a `/mobile/...` URL — path is internal to the app; **HTTP** paths are what must align with `/api/mobile/notifications`.

---

## 6. Audit — shared API / client / auth

| Path | Finding |
|------|---------|
| `lib/src/core/network/dio_provider.dart` | `Authorization: Bearer <access token>` from `TokenStorage`; **401** clears session and `go('/login')` |
| `lib/src/core/network/api_client.dart` | Thin `get` / `post` / `patch` wrapper |
| `lib/src/features/session/application/session_notifier.dart` | `signInCustomer` persists token; roles `customer` / `doctor` / `technician` |
| `lib/src/features/auth/data/mobile_otp_auth_repository.dart` | OTP verify returns `accessToken` |
| `lib/src/features/auth/login_entry_screen.dart` | Calls `signInCustomer(token)` after OTP — **JWT persistence is wired** for customers |

---

## 7. Audit — reusable UI patterns (loading / error / empty / cards)

| Pattern | Where | Applicable to M12 |
|---------|--------|-------------------|
| `AsyncValue.when(loading, error, data)` | `notifications_list_screen.dart` | Already used |
| Centered error + **আবার চেষ্টা করুন** | Notifications list | Already used |
| `RefreshIndicator` + `CustomScrollView` | Notifications list | Already used |
| Material 3 cards, radius **14–16**, `surfaceContainerLowest` | Notifications list, `AppTheme` | Match `AppTheme` card radius **16** where new widgets are added for consistency |
| `pdScreenPadding` | `screen_padding.dart` | Use for any new home app bar padding / sheets |
| No shared `lib/src/widgets/` empty-state component | — | Empty state is plain `Text` today; optional **illustration + headline + subtitle** in-feature |

---

## 8. Audit — Bengali UI patterns

- Screen title **নোটিফিকেশন**, actions **সব পড়া চিহ্নিত করুন**, chip **শুধু অপঠিত**, badges **অপঠিত / পঠিত**, **পড়া চিহ্নিত**, dialog **বন্ধ করুন**, empty **কোনো নোটিফিকেশন নেই**.
- Errors and network messages are Bengali in `NotificationRepository`.

---

## 9. Fallback / mock handling

**Finding:** There is **no** `NotificationRepositoryMock` or `USE_MOCK_NOTIFICATIONS` flag. Mock/fallback exists elsewhere (**technician jobs**, **billing demo**) via `AppConfig` (`useMockTechnicianApi`, `useMockBillingUi`).

**M12 guidance:** **Do not add** a notification mock layer unless product explicitly requires offline demo parity. If the API is unreachable in dev, rely on **existing error UI** and Bengali messages.

---

## 10. Files to create / update (implementation phase — not done in this audit step)

### 10.1 Planned updates — **done** (see §19)

| File | Status |
|------|--------|
| `notification_repository.dart` | `_basePath` constant → `/api/mobile/notifications` |
| `notification_model.dart` | Metadata / `relatedRequestId` / `message` alias |
| `notifications_providers.dart` | `unreadNotificationsTotalProvider` + invalidation |
| `notifications_list_screen.dart` | Sections, types, empty state, bottom sheet, AppBar chip |
| `home_screen.dart` | `NotificationBellIconButton` |
| `home_shell_screen.dart` | Profile row badge |

### 10.2 New widgets

| File | Purpose |
|------|---------|
| `presentation/widgets/notification_type_labels.dart` | BN labels + icons |
| `presentation/widgets/notification_bell_icon_button.dart` | Home bell + badge |

**No new packages** added.

---

## 11. Route / navigation plan

- **Keep** stack route **`/notifications`** → `NotificationsListScreen` (already registered).
- **Entry points (customer):**
  - **হোম:** add **AppBar action** (bell + badge) **in addition to** existing menu tile **নোটিফিকেশন**.
  - **প্রোফাইল:** keep existing **নোটিফিকেশন** `ListTile`; optional small trailing badge if count provider exists.
- **Doctor / technician shells:** **no change** unless product later specifies a shared inbox API.

---

## 12. Data model plan

| Field | Status | Notes |
|-------|--------|-------|
| `id`, `userId`, `type`, `title`, `body`, `readAt`, `createdAt` | Implemented | API may send **`message`** instead of **`body`** |
| `metadata` / `metadataJson`, `relatedRequestId` | Implemented | Parsed when present |

**Type strings:** UI maps **`otp_login`**, **`request_submitted`**, **`doctor_accepted`**, **`technician_accepted`**, **`request_completed`**, **`payment_billing_update`**, **`follow_up_reminder`**, **`admin_system_notice`** (case-insensitive; `-` normalized to `_`). Unknown types use a **safe string fallback**.

---

## 13. Repository / service plan

- **Single** `NotificationRepository` using existing `ApiClient` / Dio interceptors.
- **Unread count:** Prefer **`total` from list endpoint** with `unreadOnly: true` and minimal `limit` to avoid loading all rows.
- **Pagination:** `limit`/`offset` exist in repository; UI currently loads first page only (`limit: 50`). Defer “load more” until list volume requires it.

---

## 14. UI component plan

| Item | Status | Notes |
|------|--------|-------|
| Notification list | Done | **সাম্প্রতিক / পুরোনো** (7-day) grouping |
| Detail | Done | Modal **bottom sheet**; auto **mark read** when opening unread row |
| Unread visual | Done | Card tint + **অপঠিত / পঠিত** chip |
| Mark as read / read all | Done | Row action + AppBar **সব পড়া চিহ্নিত করুন** |
| Empty state | Done | Icon + headline + subtitle |
| Loading / error | Done | Retry button |
| Unread **badge** | Done | Home bell, profile `ListTile`, list AppBar chip |
| Bengali **type** labels | Done | `notification_type_labels.dart` (+ unknown fallback) |

---

## 15. Testing checklist (manual + automated)

- [ ] After customer OTP login, **GET** list succeeds (correct base path).
- [ ] **Unread-only** chip filters correctly.
- [ ] **Mark one** read updates row and badge/count.
- [ ] **Mark all** read clears unread styling and badge.
- [ ] **Pull-to-refresh** reloads list.
- [ ] **401 / network** shows Bengali error and retry (no crash).
- [ ] **Home** bell opens same route as profile/menu entries.
- [ ] **Badge** shows when `total > 0` for unread query; hides when zero.
- [ ] `flutter analyze` clean on touched files.
- [ ] `flutter test` — add/update widget test only if extracting small widgets (optional).

---

## 16. Out of scope

- **Firebase Cloud Messaging**, **push notifications**, **device token registration**, APNs, notification channels, background handlers — **not included** in M12.
- **Backend** schema changes, new server routes, or SMS providers — **not included** (mobile path alignment only).
- **Doctor / technician** notification inboxes unless API and product scope expand.

---

## 17. Risks / blockers

1. **Backend availability:** Client now calls **`/api/mobile/notifications`**. If an environment only exposes legacy **`/api/notifications`**, list/read will **404** until the API matches.
2. **`type` vocabulary:** If backend uses opaque or changing strings, Bengali labels need a **stable mapping** or fallback formatting.
3. **Unread badge churn:** Count derived from extra GET calls — acceptable at MVP volume; watch for rate limits if polling is added later (not planned here).

---

## 18. Recommended implementation approach (summary)

**Completed per §19:** repository **`_basePath`**, **`unreadNotificationsTotalProvider`**, home **bell**, profile **badge**, list **grouping / types / bottom sheet / empty state**, **`notification_type_labels`**.

Architecture remains **Riverpod + Dio + go_router**, **Bengali-first** copy.

---

## 20. Final verification (2026-05-09)

### 20.1 Commands run (project root `D:\PraniDoctor\pranidoctor_mobile`)

| # | Command | Result |
|---|---------|--------|
| 1 | `dart format .` | **Pass** — reformatted 4 files (notification + home touchpoints). |
| 2 | `flutter analyze` | **Pass** — no issues found. |
| 3 | `flutter test` | **Pass** — 5 tests (existing suite). |

### 20.2 Fixes made during verification

- **None required for failures** — all three commands succeeded on first run after M12.
- **`dart format`** applied standard formatting to: `home_screen.dart`, `home_shell_screen.dart`, `notification_model.dart`, `notifications_list_screen.dart` (no logic changes).

### 20.3 Manual code audit (M12 scope)

| Check | Status |
|-------|--------|
| Notification API base path **`/api/mobile/notifications`** for list | OK (`NotificationRepository._basePath`) |
| **`PATCH`** `…/{id}/read` for single mark-read | OK (`markRead`) |
| **`PATCH`** `…/read-all` for mark-all | OK (`markAllRead`) |
| Loading / error (+ retry) / empty states on list screen | OK |
| Unread visually distinct (tint + **অপঠিত** chip + badges) | OK |
| No Firebase / FCM / push provider code under `features/notifications` | OK (none added) |
| Unrelated modules | Not modified for this verification pass beyond **`dart format`** on the four files above |

### 20.4 Known limitations (unchanged)

- **Backend must expose** `/api/mobile/notifications` (and PATCH variants); legacy-only **`/api/notifications`** environments will fail until aligned (§17).
- **Unread total** uses an extra lightweight GET (`unreadOnly=true`, `limit=1`); no polling — badge updates when the user navigates or list refresh/mark-read runs.
- **Widget tests** do not yet cover `NotificationsListScreen` (existing tests only: billing badge, technician badge, app smoke).

