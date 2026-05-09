# Mobile notifications — Prani Doctor (Flutter)

Scope: [Prani Doctor](https://pranidoctor.com/) **customer mobile app** (`pranidoctor_mobile`). **Isolation:** no BPA/WPA, Quarbani 2026, or other projects.

---

## 1. Current mobile structure (audit)

| Area | Finding |
|------|---------|
| **Entry** | `lib/main.dart` → `app.dart` → `GoRouter` (`lib/src/app/router.dart`). |
| **State** | Riverpod 3 (`NotifierProvider`, `AsyncNotifierProvider`). |
| **HTTP** | **Dio** via `dioProvider` (`lib/src/core/network/dio_provider.dart`): `AppConfig.apiBaseUrl`, JSON headers; **Interceptor** adds `Authorization: Bearer <token>` from `TokenStorage`. |
| **Tokens** | `lib/src/core/storage/token_storage.dart` — secure storage keys `pd_access_token` / `pd_refresh_token`; cleared on `SessionNotifier.signOut`. |
| **Auth wiring** | **`writeAccessToken` is not yet called from a login flow** — store JWT when mobile auth lands; until then `/api/notifications` returns **401** (shown in Bengali on this screen). |
| **Session** | `session_notifier.dart` — role / auth flags; **no automatic token refresh** in this MVP. |
| **Customer shell** | `HomeShellScreen` — bottom nav: হোম, অনুরোধ, আমার পশু, প্রোফাইল (`IndexedStack`). |
| **Home** | `HomeScreen` — menu tiles; API base URL debug card; **নোটিফিকেশন** tile (index 6); টিউটোরিয়াল corrected to index **5**. |
| **Profile tab** | **নোটিফিকেশন** list tile + sign-out (`home_shell_screen.dart`). |

---

## 2. API contract (web backend)

Base URL: same as app (`API_BASE_URL` dart-define, default `http://localhost:3000`).

| Method | Path | Notes |
|--------|------|--------|
| GET | `/api/notifications` | Query: `limit`, `offset`, `unreadOnly` (`true`/`false`). Response `{ ok, data: { items: Notification[], total } }`. Auth: **Bearer** (mobile). |
| PATCH | `/api/notifications/[id]/read` | Marks one read. Response `{ ok, data: { notification } }`. |
| PATCH | `/api/notifications/read-all` | Marks all read for user. Response `{ ok, data: { updatedCount } }`. |

Notification JSON (aligned with Prisma): `id`, `userId`, `type`, `title`, `body`, `readAt` (nullable ISO), `metadataJson`, `createdAt`.

---

## 3. Notification list UI (MVP — implemented)

- List with title/body preview, **অপঠিত / পঠিত** badge, timestamp (`intl`).
- **শুধু অপঠিত** filter (query param).
- Refresh (`RefreshIndicator`), **পড়া চিহ্নিত করুন** per row (if unread), **সব পড়া চিহ্নিত করুন** (AppBar).
- Tap row → dialog with full body.
- Bengali errors for 401 / network (`NotificationRepository`).

---

## 4. Navigation

- **Route:** `/notifications` (`NotificationsListScreen`).
- **Entry:** প্রোফাইল tab — list tile **নোটিফিকেশন**; **হোম** menu — tile **নোটিফিকেশন** (index 6).

---

## 5. Future push notifications (not in Task Card 15)

- Firebase Cloud Messaging (FCM) + backend device registration.
- Deep links from notification payload to service request / tutorials.
- Preference toggles per channel.

See also web `docs/NOTIFICATION_SMS_PLAN.md` §12.5.

---

## 6. Testing checklist

- [ ] Logged-in customer with valid JWT — list loads from GET `/api/notifications`.
- [ ] Mark one read — PATCH single; list refreshes / row shows পঠিত.
- [ ] Mark all read — PATCH read-all.
- [ ] Unread-only filter toggles query.
- [ ] No token / 401 — user-visible error (not crash).
- [x] `flutter analyze` clean (verified in Task Card 15 final pass).
- [x] `flutter test` — existing widget test passes (verified in Task Card 15 final pass).

---

## 7. Implementation status

- [x] Plan documented (this file).
- [x] `AppNotification` model + `NotificationRepository` + Riverpod providers.
- [x] `NotificationsListScreen` + router + home/profile navigation.
- [ ] Push / FCM — **out of scope**.

---

## 8. Task Card 15 — Final verification summary

### 8.1 Completed

- Model, repository, providers, screen, routing, হোম + প্রোফাইল entry; Bengali error UX.

### 8.2 Pending

- **`writeAccessToken`** when customer auth ships.
- Manual E2E vs running API (§6 unchecked rows).
- Push (§5).

### 8.3 Known limitations

- No JWT persistence yet → 401 until login wires token storage.
- No offline notification cache in MVP.

### 8.4 Push — future (aligned with web plan)

- Register FCM tokens via API; send pushes from same events as in-app notifications; deep link using `metadataJson`.

---

## 9. References

- Web plan: `pranidoctor-web/docs/NOTIFICATION_SMS_PLAN.md`.
- Dio + token: `lib/src/core/network/dio_provider.dart`, `token_storage.dart`.
