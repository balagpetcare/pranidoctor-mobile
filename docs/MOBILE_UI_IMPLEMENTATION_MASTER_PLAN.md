# Prani Doctor — Mobile UI implementation master plan

**Repository:** `pranidoctor_mobile`  
**Last updated:** 2026-05-09 (M15 final verification)

This document tracks milestone status for the Flutter client UI/UX. Backend contracts live in the web API; this file only records **mobile** delivery and **client-side** placeholders.

---

## Milestone overview

| Milestone | Topic | Status |
|-----------|--------|--------|
| M01–M14 | Foundation, auth shell, home, animals, providers, booking, requests, doctor stub, technician AI, billing, notifications, knowledge hub, profile | Delivered in prior task docs under `docs/tasks/` |
| **M15** | Final mobile UI polish & QA | **Completed with documented placeholders** — **final verification PASS** (see below) |

---

## M15 — Final mobile UI polish & QA

**Status:** **Completed with documented placeholders** — **final tooling verification PASS** (2026-05-09)

### Final command results (closure run)

| Command | Result |
|---------|--------|
| `dart format .` | **PASS** — `Formatted 101 files (0 changed)`, exit code 0 |
| `flutter analyze` | **PASS** — `No issues found!` |
| `flutter test` | **PASS** — 5 tests passed |

### Final checklist status (summary)

All **20** M15 verification items are **PASS** at code + automation level; **9:16** and full API-matrix behavior remain **manual / staging** as noted in `docs/tasks/M15_FINAL_MOBILE_UI_QA_PLAN.md` § *Known limitations*.

### Final QA summary (implementation)

Implemented work is limited to **safe UI/QA** items: Bengali-first labels, debug-only API surfaces, home menu navigation and tab switching, consistent error/retry copy, locale-aware notification timestamps, keyboard padding on login/booking, and a clearer logout dialog. **No** backend, **no** new dependencies, **no** route renames.

### Known placeholders

- Doctor / technician **খোলস** login; disabled social login (**শীঘ্রই**).
- **Customer auth** production hardening (refresh policy, etc.) — backend/product.
- **`AppConfig`** mock flags (billing preview, technician mock, knowledge fallback) — QA-only.
- Support phone mask; manual About version until **`package_info_plus`**.

### Known limitations

- Automated tests do not replace on-device **9:16** QA or full API regression matrices.
- Inline Bengali strings only (no ARB catalog).
- MVP launch readiness overall remains per **`docs/MVP_AUDIT_AND_LAUNCH_CHECKLIST.md`** (broader than M15 UI).

### Recommended next step after mobile MVP QA

1. **Staging smoke:** OTP, booking, requests, notifications against real API.
2. **Release build:** Confirm no debug-only UI (`kDebugMode` API banners absent).
3. **Backend alignment:** JWT refresh + real doctor/technician mobile auth when ready.
4. Re-evaluate **MVP checklist** for pilot go/no-go.

### Pre-release manual checklist

- [ ] Release APK/IPA: confirm **no** “ডিবাগ” API blocks on login/home/doctor routes.
- [ ] Regression: customer OTP login → home → booking → request detail → cancel (if applicable).
- [ ] Regression: doctor stub login → doctor home → knowledge hub → sign out.
- [ ] Regression: technician stub login → dashboard → jobs list loads/errors gracefully with mock off/on per env.

### Verification commands (ongoing)

```bash
dart format .
flutter analyze
flutter test
```

---

## References

- Detailed M15 audit, implementation, and **final checklist:** `docs/tasks/M15_FINAL_MOBILE_UI_QA_PLAN.md`
- MVP readiness: `docs/MVP_AUDIT_AND_LAUNCH_CHECKLIST.md`
