# AI Technician layout, service-area UX, and location dedupe — implementation plan

**Projects:** `pranidoctor_mobile` (Flutter), `pranidoctor-web` (Next.js + Prisma)  
**Status:** Plan only — **no implementation** in the session that produced this document.  
**Rules observed:** No file deletions; no whole-app rewrite; backend changes staged after investigation.

---

## 1. Mobile files affected (expected)

| Area | Path(s) |
|------|---------|
| Wizard shell, steps 3–4, scroll/footer | `lib/src/features/ai_technician_application/presentation/ai_technician_application_form_screen.dart` |
| Wizard footer actions | Same file (`_buildBottomActions`, `Material` footer block in `build`) |
| Step 3 (professional) | `_buildStepProfessional` in same file |
| Step 4 (address + service areas) | `_buildStepAddress`, `_addArea`, `_delArea` in same file |
| Location pickers | `lib/src/design_system/widgets/prani_searchable_select_field.dart` (bottom sheet list UI) |
| Location API client | `lib/src/features/locations/data/location_repository.dart` |
| Location DTO / labels | `lib/src/features/locations/data/location_models.dart` (`MobileLocationDto.displayLabelBn`) |
| Readable width helper | `lib/src/app/screen_padding.dart` (`pdReadableMaxWidth`) |
| Page insets | `lib/src/design_system/prani_page_insets.dart` |
| AI technician repo (service areas API) | `lib/src/features/ai_technician_application/data/ai_technician_repository.dart` |
| Router | `lib/src/app/router.dart` (new route for full-page service area flow) |
| Providers | `lib/src/features/ai_technician_application/application/ai_technician_providers.dart` |

**New files (planned, not created yet):** e.g. `ai_technician_service_area_screen.dart` (full-page add/select), optional small footer widget extracted from the form screen.

---

## 2. Backend files affected (expected)

| Area | Path(s) |
|------|---------|
| Prisma schema | `pranidoctor-web/prisma/schema.prisma` — `Division`, `District`, `Upazila`, `Union`, FKs from `AiTechnicianDivisionServiceArea` |
| Location master reads | `pranidoctor-web/src/lib/locations/location-master-service.ts` (`listDistrictsMaster`, `listUpazilasMaster`, `listUnionsMaster`) |
| Mobile location API | `pranidoctor-web/src/lib/mobile-locations/locations-service.ts`, `.../schemas.ts` |
| HTTP routes | `pranidoctor-web/src/app/api/mobile/locations/*/route.ts` (`districts`, `upazilas`, `unions`, `search`) |
| AI technician service areas | `pranidoctor-web/src/app/api/mobile/ai-technician/service-areas/route.ts`, `.../service-areas/[id]/route.ts` |
| Seed / import scripts | `pranidoctor-web/prisma/seed*.ts`, `scripts/locations/**`, `prisma/seed-data/**` (exact files TBD during dedupe investigation) |

---

## 3. Root cause of footer / form blocking (analysis)

**Current wizard structure** (post–recent footer move): `PraniScaffold` → `body: Column` → `[ header/progress, Expanded(Stack(PageView)), Material(footer) ]`. The wizard **no longer** uses `Scaffold.bottomNavigationBar` for the main flow.

Remaining risks for steps **3 (professional)** and **4 (address)**:

1. **Scroll bottom padding vs footer + keyboard**  
   `_scrollStep` uses `_kScrollBottomGap` (24) **+** `MediaQuery.viewInsets.bottom` only. It does **not** add a reserve equal to the **footer height** (~140–200+ px including buttons). The footer sits **below** the `Expanded` region, so it should not overlap the `SingleChildScrollView` **when the keyboard is closed**. When the **keyboard is open**, `resizeToAvoidBottomInset` shrinks the scaffold; the footer can consume space and/or the scroll viewport can become short — users may perceive content as “stuck” or the last fields hidden unless padding accounts for **footer height + keyboard** (or the scroll view uses a computed `padding.bottom` from a `LayoutBuilder` / measured footer).

2. **Tall step content**  
   Step 3 has many fields (dropdown, several text fields, switch). Step 4 adds three `PraniSearchableSelectField`s plus a list of coverage rows. Long content increases the chance the **last visible pixels** sit awkwardly above the footer without enough scroll slack.

3. **Perception / elevation**  
   The footer uses `Material` + `elevation: 8`, which can read as a **floating bar** over content even when layout is correct. Fine-tuning elevation/surface tint may be needed for clarity.

4. **Horizontal “empty” space**  
   `pdReadableMaxWidth` clamps to **520** but `MediaQuery.width` on phones is often 360–430; the **narrow column** is centered inside `ConstrainedBox`, which can leave **large side gutters** if another ancestor also applies horizontal padding (`hPad` from `PraniPageInsets` **and** inner scroll padding `hPad` — **double horizontal inset** effect). Any mismatch between `PraniPageInsets.horizontalPadding` and `screen_padding` formulas can worsen inconsistent side margins.

**Conclusion:** Blocking is likely a **combination** of (a) insufficient **dynamic** bottom padding under keyboard + sticky footer height, and (b) **visual/layout** density on steps 3–4—not necessarily restoration of `bottomNavigationBar`.

---

## 4. New footer layout strategy (recommended)

1. **Keep footer inside `body` `Column`** (not `Scaffold.bottomNavigationBar`) to preserve bounded `Expanded` for `PageView`.

2. **Reserve footer height in scroll padding** using one of:
   - **Measured footer:** `GlobalKey` on footer + `afterLayout` to read height and pass to `_scrollStep`, or
   - **Constant estimate:** document assumed footer height (e.g. 160–200) + `viewInsets.bottom` + safe gap, tuned per device.

3. **Keyboard:** Keep `resizeToAvoidBottomInset: true`; ensure scroll padding = `footerReserve + viewInsets.bottom + gap`.

4. **Optional:** Replace raw `Material` footer with a small reusable **`PraniWizardFooter`** widget (same visuals; encapsulates SafeArea + padding) for reuse and testing.

5. **SnackBar:** Continue **`SnackBarBehavior.fixed`** on this route (theme defaults to floating); call `hideCurrentSnackBar()` before show.

---

## 5. Responsive mobile spacing strategy

1. **Single source of horizontal gutter:** Align wizard with `PraniPageInsets.horizontalPadding(context)` only; avoid stacking redundant `pdScreenPadding` on the same axis unless intentionally different.

2. **Readable width:** Revisit `pdReadableMaxWidth` — options:
   - Use `min(screenWidth - 2*hPad, 520)` explicitly, or
   - On narrow widths (`< 400`), set `maxW = screenWidth` (full bleed inside padding only) to remove **excess side gutter**.

3. **Form cards:** Keep `PraniFormCard` / tokens (`PraniFormTokens.cardPadding`) consistent; audit step 3–4 for extra `Padding` wrappers.

4. **Location row:** Step 4 header row (“সেবা এলাকা” + button) — ensure `TextButton` doesn’t force overflow on small widths (wrap / `FittedBox` if needed).

---

## 6. Separate service area page — route design

**Goal:** Move “add service area” out of `showPraniBottomSheet` modal into a **dedicated full screen**.

**Proposed route:** e.g. `/profile/ai-technician/form/service-area` (exact path to match `GoRouter` style in `router.dart`).

**Screen responsibilities:**

- Full-screen title: e.g. “সেবা এলাকা যোগ করুন”.
- Same hierarchy: district → upazila → union (reuse `PraniSearchableSelectField` or full-page list variants).
- Primary action: “যোগ করুন” / “সংরক্ষণ” calling `AiTechnicianRepository.addDivisionServiceArea`.
- Secondary: close/back.

**Navigation:**

- From step 4: `context.push('/profile/ai-technician/form/service-area')` (or `push` with `extra` for preselected district if needed).
- On success: `context.pop()` and **refresh** technician profile (`ref.invalidate(aiTechnicianMeProvider)` + optional `_bootstrap()` or local state update from returned profile).

**Deep-link / state:** Pass minimal args (none if selections are picked on page); avoid heavy objects in `extra` if possible.

---

## 7. Service area data flow back to wizard

1. After successful `POST /api/mobile/ai-technician/service-areas`, server returns `areaId`; mobile already refreshes via existing patterns.

2. **Recommended:** On pop from service-area page, call `ref.invalidate(aiTechnicianMeProvider)` and/or `await _bootstrap()` on the form screen’s `RouteAware` / `.then` on `push` to reload `p.divisionCoverageAreas`.

3. Mark wizard `_dirty` when coverage list changes.

---

## 8. Location duplicate investigation method

**Symptom:** Same Bengali label appears multiple times in picker — **distinct rows** in API response with **different `id`/`slug`** but **same display label** (`nameBn` / `name` mapping).

**Mobile display:** `MobileLocationDto.displayLabelBn` prefers BN → EN → `name`; duplicates are therefore **data-level**, not Dart string duplication in UI.

**Backend investigation steps:**

1. Run SQL (PostgreSQL) grouping duplicates, e.g.:
   - `SELECT name_bn, COUNT(*) FROM "District" WHERE ... GROUP BY name_bn HAVING COUNT(*) > 1`  
   - Repeat for `Upazila`, `Union` (join parent ids as needed).
2. Inspect **slug** and **code** for duplicate-name rows — often legacy import created `district-foo` vs `district-foo-2`.
3. Review **seed/import** scripts: idempotent **upsert** vs blind **create**.
4. Check **API** returns all active rows — `listDistrictsMaster` uses `findMany` with no dedupe by label.

**Flutter mitigation (short term, UI-only):** When rendering list items, show **disambiguator** — e.g. `labelBn (code)` or `labelBn · slug` when `nameBn` collisions exist in the same list (requires API to expose `code` / division context — already partially present on DTO).

---

## 9. Safe database backup command

**Before any dedupe migration or destructive SQL:**

- **Docker Compose Postgres** (if used):  
  `docker compose exec <db-service> pg_dump -U <user> <dbname> > backup_locations_$(date +%Y%m%d).sql`  
  (Exact service/user/db from `pranidoctor-web/docker-compose.yml` and `.env`.)

- **Hosted Postgres:** use provider snapshot + `pg_dump` with connection string from secure env.

Store backups **outside** the repo; verify restore on a **staging** DB first.

---

## 10. Dedupe strategy (high level)

**Constraint:** `District`, `Upazila`, `Union` rows are referenced by **FKs** (`AiTechnicianProfile`, `AiTechnicianDivisionServiceArea`, etc.). Deleting “duplicate” rows without **rewiring** FKs will break references.

**Safe approach:**

1. **Inventory** duplicate clusters (same logical admin unit, multiple IDs).
2. **Choose canonical row** per cluster (prefer verified, correct division linkage, older `createdAt`, or stable slug).
3. **Rewrite FKs** in a transaction: update child tables to `canonicalId`, then **deactivate** or delete obsolete rows (only if no remaining references).
4. **Enforce uniqueness** at DB level where product allows, e.g.:
   - Composite unique: `(divisionId, lower(nameBn))` **only if** business rules guarantee uniqueness within division — validate against real BD admin data first.
   - **Slug** is already globally `@unique` per model; duplicates often differ by slug — **business** dedupe may require merging slugs or keeping one slug and retiring others.

**Risk:** Administrative boundaries in Bangladesh datasets sometimes legitimately repeat names in **different** divisions — **do not** merge those incorrectly.

---

## 11. Unique constraint / upsert / import fix strategy

1. **Imports:** Switch to **upsert on stable natural key** (e.g. official BBS code if present) where available; document mapping CSV columns.

2. **Prisma:** Add migrations for new uniques **only** after duplicate report confirms no violating rows (or after cleanup).

3. **API:** Optionally add **server-side dedupe** for mobile lists: `DISTINCT ON` / group by normalized label — **prefer fixing data** over hiding duplicates in API long-term.

4. **Normalization:** Trim whitespace; normalize BN punctuation; store `code` from authoritative dataset.

---

## 12. Test checklist

**Mobile**

- [ ] Steps 3–4: scroll to bottom with keyboard open and closed; last field visible above footer.
- [ ] Add service area via **new full page**; list updates; draft save still works.
- [ ] Delete coverage row; validation on submit unchanged.
- [ ] Location pickers: verify duplicate labels show disambiguation if implemented.
- [ ] Small phone (±360dp) and large phone — no excessive side gutters.
- [ ] Dark/light readability on step cards.

**Backend**

- [ ] `/api/mobile/locations/districts` returns expected row counts vs DB.
- [ ] After dedupe (future): FK integrity; AI technician service areas still resolve.

---

## 13. Commands to run

**Mobile (`pranidoctor_mobile`):**

```bash
cd D:\PraniDoctor\pranidoctor_mobile
flutter analyze
flutter test
```

**Web / DB (`pranidoctor-web`):**

```bash
cd D:\PraniDoctor\pranidoctor-web
npx prisma validate
npm run lint
npm run build
```

**Investigation (read-only):**

```bash
npx prisma studio
# or SQL client against DATABASE_URL — duplicate GROUP BY queries from section 8
```

---

## Implementation order (suggested)

1. Mobile: fix scroll **footer + keyboard** padding for wizard `_scrollStep` (steps 3–4 priority); verify `LayoutBuilder` if constants fail on devices.  
2. Mobile: responsive `maxW` / horizontal padding audit.  
3. Mobile: new **service area** full page + router + return refresh.  
4. Mobile (optional): picker row subtitle for duplicate **labels** using `code`/slug.  
5. Backend: duplicate **report** SQL + seed/import trace; staging dedupe + migration plan; API/data fixes last.

---

## Notes

- **Do not modify backend** until duplicate inventory confirms safe merges (per project instruction for the implementation phase).
- This plan **does not delete** any repository files; new docs and future code follow existing Prani Doctor conventions.
