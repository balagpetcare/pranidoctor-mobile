# Mobile — guest-first onboarding & login fix (implementation plan)

**Scope:** `pranidoctor_mobile` only. No backend changes.

## Current audit

| Area | Finding |
|------|---------|
| Splash | Routes onboarding → Home when done; guest-first OK. |
| Onboarding | Completes to Home; slide 2–3 use icon-only placeholder cards; copy mentions login on last slide. |
| Router | Guest allowlist exists; login not forced at startup. |
| Dio 401 interceptor | Signs out + **`go(HomeShell)`** (not Login); OTP paths skipped so wrong OTP does not trigger shell redirect. |
| Dio connectivity | Replaced leaking helper with `dio_user_message.dart`; callers use `userFacingDioMessageBn` only (no `e.message` to UI). |
| OTP repo | Uses API envelope when present; Dio fallback still leaked via `e.message`. |

## Goals

1. Never show raw Dio/Flutter exception strings in UI.
2. Map HTTP status + connectivity to stable Bengali messages (404/5xx/network).
3. 401: sign out, **go Home** (not Login); guest browsing continues.
4. After OTP login: restore intent via query `tab=` (`profile` \| `notifications` \| `services`) or safe `next=` path.
5. Onboarding: premium visual consistency, spacing, guest-first copy, responsive layout.

## Implementation steps

1. Add `lib/src/core/network/dio_user_message.dart` — `userFacingDioMessageBn(DioException e)` (no `e.message` for users); OTP 404 log in dev via `debugPrint`.
2. Replace `bnUserFacingDioNetworkMessage` implementation to delegate to the new mapper (keep export for compat).
3. Extend `NetworkMessages` with OTP/server/404 strings.
4. Update `mobile_otp_auth_repository.dart` — wrap Dio errors through mapper; log technical detail only in development.
5. Update `dio_provider.dart` — on 401: `signOut` + `go(/home)` instead of login.
6. Add `lib/src/features/auth/application/post_customer_login_navigation.dart` — apply `tab` / safe `next` after success.
7. Update `LoginEntryScreen` — read `GoRouterState` query params; call post-login helper after `signInCustomer`.
8. Update `customer_auth_prompt.dart` + `home_shell_screen.dart` — pass `loginTab` when opening login from protected tabs.
9. **`onboarding_screen.dart`** — Prani primary CTA, constrained content width, gradient/icon slides, guest-first last slide copy, AppBar tint cleanup — **done**.
10. Run `dart format` on touched files + `flutter analyze`.

## Out of scope

- Backend API changes.
- Rewriting router structure wholesale.
- New illustration PNG assets (reuse `PraniAssets.onboardingFarmer` / icons).

## Acceptance mapping

| Requirement | How verified |
|-------------|--------------|
| No raw Dio text | Mapper never returns `e.message`; OTP repo uses mapper. |
| 404 OTP | Bengali “সেবা উপলব্ধ নয়…” + dev log. |
| Guest-first 401 | Interceptor → Home. |
| Return after login | `?tab=profile` etc. |
