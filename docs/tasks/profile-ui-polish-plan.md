# Profile UI polish + mobile API fallback — implementation plan

## Audit summary

| Area | Finding |
|------|---------|
| `profile_home_screen.dart` | Red error `Card`, raw `loadErrorMessage`, centered logo above header; short settings list; full-width logout always shown. |
| `profile_header_card.dart` | Centered layout; role labels outdated vs spec; no completion CTA; no in-card brand row. |
| `profile_settings_list_tile.dart` | Baseline `ListTile`; acceptable — minor padding for touch targets. |
| `mobile_user_repository.dart` | `404` → `ProfileApiException` → provider **error** → red UI chain. |
| `profile_providers.dart` | Timeout → exception; pairs with repository errors. |
| `mobile_user_model.dart` | Single placeholder; no distinction remote vs fallback guest. |
| `notification_repository.dart` | `404` throws → unread badge / list errors. |
| `provider_finder_repository.dart` | `404` throws → doctor list error UI. |
| `service_category_repository.dart` | No explicit `404` → empty list (booking wizard). |
| `home_feed_providers.dart` | Already swallows failures → `[]` / `MobileAppConfig.empty`. |
| `home_shell_screen.dart` | `NavigationBar` + `SafeArea`; theme drives teal selection on icons. |
| `theme.dart` | `NavigationBarTheme` selected label uses `onSurface` — optional tweak to `primary`. |

## Goals

1. **Profile tab**: Bengali-first polish, grouped menus, hero card with completion + CTA, soft info banner when profile is fallback (never alarming red for missing endpoints).
2. **Repositories**: Map HTTP **404** (and list-notification empty envelope) to **empty/fallback data**, not user-visible fatal errors on primary flows.
3. **No backend changes**; no new packages.

## Implementation steps (completed in branch)

1. Add `MobileProfileLoadStatus` + `MobileUser.guestFallback` + `missingProfileFieldsCount` on `MobileUser`.
2. `MobileUserRepositoryLive.fetchMe`: success → `fromJson`; failures → **guest fallback** + status (`404` vs other); **do not** surface raw HTTP text in UI.
3. `mobileUserProvider`: `TimeoutException` → guest fallback (same as repo soft failure).
4. `NotificationRepository.list`: `404` → empty page `(items: [], total: 0)`.
5. `ProviderFinderRepository.listDoctors` / `listTechnicians`: `404` → empty list + zero pagination.
6. `ServiceCategoryRepository.list`: `404` → `[]`.
7. `unreadNotificationsTotalProvider`: catch failures → `0`.
8. Refactor **Profile** UI: soft banner, grouped `Card` sections, redesigned `ProfileHeaderCard`, remove floating logo, auth-aware footer, retry guard.
9. Optional: `NavigationBar` selected label color → primary; `home_top_bar` area placeholder string alignment.
10. Add **`/animals`** `GoRoute` for “আমার প্রাণী” → `AnimalListScreen`.

## Testing

- `dart format .`
- `flutter analyze`
- `flutter test`

Manual: Profile tab with API stopped / `404` — no red wall of error; guest card + info banner; retry works once per tap; bottom nav clears content.
