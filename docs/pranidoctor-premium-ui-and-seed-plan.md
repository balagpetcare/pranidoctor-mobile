# Prani Doctor — premium UI + demo seed (QA notes)

Scope: **Prani Doctor / Animal Doctors** customer mobile app + `pranidoctor-web` APIs only.

## QA automation run (2026-05-09)

### Backend (`pranidoctor-web`)

| Check | Result |
|-------|--------|
| `npx prisma generate` | OK |
| `npm run lint` | OK |
| `npm run typecheck` | OK |
| `npm test` (Vitest) | OK (35 tests) |
| `npm run db:seed:demo` | OK (after fixes below) |

### Mobile (`pranidoctor_mobile`)

| Check | Result |
|-------|--------|
| `dart format .` | OK |
| `flutter analyze` | No issues |
| `flutter test` | All passed |

### Integration fixes applied during QA

1. **Public discovery APIs** — `GET /api/mobile/app-config`, `service-categories`, `providers/doctors`, `providers/technicians` (and `[id]` details) were incorrectly gated with `requireMobileCustomer`, returning **401** before OTP login and leaving home/doctor tabs empty. These handlers are now anonymous-safe (read-only catalog).
2. **`GET /api/mobile/app-config`** — Still avoids secrets; merges optional `Setting` key `mobile.app.config` from the demo seed and falls back `emergencyPhone` from support phone when env is unset.
3. **Demo seed ↔ OTP alignment** — Seeded `User.phone` must match **`normalizeBdMobilePhone`** output (**`8801701022274`**). The seed merges the customer by **unique phone** and resolves duplicate email rows so **`customer@pranidoctor.test`** attaches to the same row OTP uses. Notifications upserts refresh `userId` on update.

### Manual device QA (Pixel / emulator)

Not executed in CI. After pulling changes:

1. `npm run db:seed` then `npm run db:seed:demo` (or `db:seed:reset-demo` then `db:seed:demo` if migrating from older demo phone format).
2. `npm run dev` — point the Flutter app base URL at this host.
3. OTP login with **`01701022274`** — verify home categories populate without logging in first; after login verify profile, notifications, and service request lists show Bengali demo content.

### Known follow-ups (optional product/backend)

- **`GET /api/mobile/content/*`** — Knowledge hub still prefers content routes; **404** falls back to `/api/mobile/tutorials/*` in the app (no change required for MVP).
- **Admin OTP debug panel** — Dev OTP codes print to the Next.js terminal (`[PraniDoctor OTP DEV]`).

## Related docs

- Web: `docs/DUMMY_SEEDER.md` — demo data, commands, phone normalization troubleshooting.
