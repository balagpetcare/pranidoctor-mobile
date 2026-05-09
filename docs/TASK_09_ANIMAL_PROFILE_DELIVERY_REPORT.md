# Task Card 09 — Animal Profile Delivery Report

**Project:** Prani Doctor / Animal Doctors — [pranidoctor.com](https://pranidoctor.com/)  
**Scope:** Prani Doctor repositories only — no reuse of BPA/WPA, Quarbani 2026, or other projects.

---

## 1. Task title and goal

| Field | Detail |
|-------|--------|
| **Title** | Task Card 09 — Customer Animal Profile |
| **Goal** | Enable **customers** to **create and manage animal profiles** via **mobile APIs** and the **Flutter customer app**, with correct **ownership**, **validation**, and **soft deactivate** behavior aligned to Prisma and booking flows. |

---

## 2. Backend/API completed work

- **`AnimalProfile`** CRUD for **authenticated customers only**, scoped by **`CustomerProfile.id`** from JWT session — never from client-supplied ids.
- **`src/lib/mobile-auth/`**: Bearer JWT verification (`aud: mobile`, `role: CUSTOMER`), PostgreSQL load of active **`User`** + **`customerProfile`** (`requireMobileCustomer`).
- **`src/lib/mobile-animals/`**: Zod schemas (`.strict()`), mapper (**`AnimalJsonDto`**, age computation, `weightKg` as string), service (**list / create / get / patch / deactivate**).
- **Route handlers** under **`/api/mobile/animals`**: JSON envelope **`{ ok, data }`** via existing **`jsonOk` / `jsonError`**.
- **Deactivate** is **soft** (`active: false`); no hard **DELETE** on animals (aligns with **`ServiceRequest.animal` `onDelete: Restrict`**).
- **Documentation** in repo: `docs/ANIMAL_PROFILE_PLAN.md` (plan, implementation notes, **§14 verification report**).

---

## 3. Mobile completed work

- **Feature area** `lib/src/features/animals/`: model, repository, Riverpod providers, list / detail / add–edit form, card + photo placeholder + Bengali labels.
- **`ApiClient.patch`** for **PATCH** update and deactivate.
- **Home shell** tab **“আমার পশু”** replaced placeholder with **`AnimalsTabScreen`** (nested **`Navigator`** for stack inside tab).
- **Bengali-first** UI copy, Material 3 + existing **`AppTheme`** / **`pdScreenPadding`** patterns.
- **Docs:** `docs/ANIMAL_PROFILE_PLAN.md` (mobile sections + implementation adjustment).

---

## 4. Prisma / schema changes

| Change | Detail |
|--------|--------|
| **Enum** | **`PregnancyStatus`**: `UNKNOWN`, `NOT_APPLICABLE`, `NOT_PREGNANT`, `PREGNANT` |
| **`AnimalProfile`** | Nullable **`photoUrl`** (`String`), nullable **`pregnancyStatus`** (`PregnancyStatus`) |
| **Migration** | `prisma/migrations/20260508212430_animal_photo_pregnancy_status/` (applied in dev during implementation) |
| **Client** | `npx prisma generate` → `src/generated/prisma/` |

Existing **`AnimalProfile`** fields retained: **`species`** (required; derived on create from **`animalType`**), **`category`**, **`animalType`**, **`weightKg`**, **`dateOfBirth`**, **`sex`**, **`gender`**, **`microchipOrTag`**, **`notes`**, **`active`**, etc.

---

## 5. API endpoints

| Method | Path | Behavior |
|--------|------|----------|
| `GET` | `/api/mobile/animals` | List caller’s animals; query **`includeInactive=true`** optional; default active-only; order **active desc**, **createdAt desc** |
| `POST` | `/api/mobile/animals` | Create; **`customerId`** from session only |
| `GET` | `/api/mobile/animals/[id]` | Detail if owned |
| `PATCH` | `/api/mobile/animals/[id]` | Partial update if owned |
| `PATCH` | `/api/mobile/animals/[id]/deactivate` | Soft deactivate |

**Auth:** `Authorization: Bearer <JWT>` (mobile audience). Admin panel cookie auth does **not** authorize these routes.

---

## 6. Mobile screens

| Screen / widget | Role |
|-----------------|------|
| **`AnimalsTabScreen`** | Nested navigator root for the tab |
| **`AnimalListScreen`** | List, empty/loading/error, refresh, FAB, include-inactive menu |
| **`AnimalDetailScreen`** | Full fields, edit, deactivate + confirm |
| **`AnimalFormScreen`** | Create / edit: type, name/tag, breed, DOB vs age, gender, pregnancy, notes, optional photo URL |
| **`AnimalCard`**, **`AnimalPhotoPlaceholder`**, **`animal_labels`** | Card UI + BN labels |

---

## 7. Validation / security decisions

| Topic | Decision |
|-------|----------|
| **Ownership** | **`customerProfileId`** always from **`requireMobileCustomer`**; Prisma **`where`** includes **`customerId`** + **`id`** |
| **Body trust** | **`createAnimalBodySchema`** / **`patchAnimalBodySchema`** use **`.strict()`** — rejects **`customerId`**, **`userId`**, and other unknown keys |
| **JWT** | **`MOBILE_JWT_SECRET`** or **`AUTH_SECRET`** (≥32 chars); claims **`aud: mobile`**, **`role: CUSTOMER`** |
| **Roles** | Non-customer or inactive users → **403**; missing/invalid token → **401** |
| **Cross-role** | Doctors/admins cannot use customer animal routes without a customer JWT |
| **Deactivate** | Path **`PATCH .../deactivate`** preferred; **`PATCH .../[id]`** may still set **`active`** where schema allows |

---

## 8. Test / build / lint results

### pranidoctor-web

| Command | Result (as of final verification) |
|---------|-----------------------------------|
| `npm run lint` | Pass |
| `npm run build` | Pass (Next.js 16 + TypeScript) |
| `npx prisma generate` | Pass |
| `npm test` (Vitest) | **9** tests passed (**3** files) |

**Note:** Build may print existing Next.js **`middleware` → `proxy`** deprecation warning — unrelated to animal APIs.

### pranidoctor-mobile

| Command | Result (as of implementation) |
|---------|--------------------------------|
| `flutter analyze` | No issues |
| `flutter test` | Pass |
| `flutter build apk --debug` | Success (`app-debug.apk`) |

---

## 9. Changed files (grouped by repo)

### pranidoctor-web

| Path |
|------|
| `prisma/schema.prisma` |
| `prisma/migrations/20260508212430_animal_photo_pregnancy_status/migration.sql` |
| `.env.example` (mobile JWT secret notes) |
| `src/lib/mobile-auth/constants.ts` |
| `src/lib/mobile-auth/secrets.ts` |
| `src/lib/mobile-auth/jwt.ts` |
| `src/lib/mobile-auth/guard.ts` |
| `src/lib/mobile-animals/animal-mapper.ts` |
| `src/lib/mobile-animals/animal-service.ts` |
| `src/lib/mobile-animals/schemas.ts` |
| `src/lib/mobile-animals/schemas.test.ts` |
| `src/app/api/mobile/animals/route.ts` |
| `src/app/api/mobile/animals/[id]/route.ts` |
| `src/app/api/mobile/animals/[id]/deactivate/route.ts` |
| `docs/ANIMAL_PROFILE_PLAN.md` |
| `src/generated/prisma/**` (generated — do not hand-edit) |

### pranidoctor-mobile

| Path |
|------|
| `lib/src/core/network/api_client.dart` |
| `lib/src/features/animals/data/animal_profile_model.dart` |
| `lib/src/features/animals/data/animal_profile_repository.dart` |
| `lib/src/features/animals/application/animals_providers.dart` |
| `lib/src/features/animals/presentation/animals_tab_screen.dart` |
| `lib/src/features/animals/presentation/animal_list_screen.dart` |
| `lib/src/features/animals/presentation/animal_detail_screen.dart` |
| `lib/src/features/animals/presentation/animal_form_screen.dart` |
| `lib/src/features/animals/presentation/widgets/animal_card.dart` |
| `lib/src/features/animals/presentation/widgets/animal_photo_placeholder.dart` |
| `lib/src/features/animals/presentation/widgets/animal_labels.dart` |
| `lib/src/features/home/home_shell_screen.dart` |
| `docs/ANIMAL_PROFILE_PLAN.md` |

---

## 10. Known TODOs

| Item | Owner |
|------|--------|
| **Customer mobile login API** (`POST /api/mobile/auth/…`) + persist token on device | Web + mobile |
| **Roadmap / API index** mention of `/api/mobile/animals` | Docs |
| **Optional** integration tests hitting live route handlers | Web |
| **Photo upload** (multipart / storage): backend + mobile beyond URL placeholder | Full stack |

---

## 11. Recommended next task

**Customer Service Request / Doctor Call Request**

**Rationale:** Animal profiles exist to attach **`animalId`** (and **`customerId`**) to **`ServiceRequest`** in Prisma. The natural product progression is booking a visit or emergency call using those profiles, before polish items such as photo upload-only scope or doctor matching UX depth.

*(Alternatives for later cards: **animal profile photo upload**, **doctor matching by area and animal type**, **customer treatment history linked to animal profile**.)*

---

## Document history

| Date | Change |
|------|--------|
| 2026-05-09 | Final delivery report (Task Card 09) |
