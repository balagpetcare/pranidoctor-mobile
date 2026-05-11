# Prani Doctor — mobile profile backend API contract

**Scope:** Profile photo, cover photo, profile fields, structured location, village search/creation.  
**Audience:** Backend implementers; mobile client expectations.  
**Base:** All paths are relative to the mobile API host (no hardcoded origins in the app).

---

## 1. Profile photo upload

### Endpoint

`POST /api/mobile/me/profile-photo`

### Request

- **Content-Type:** `multipart/form-data`
- **Field name:** `image` (single file part)
- **Auth:** Authenticated customer session (same guard as `GET /api/mobile/me`).

### Accepted formats

- **MIME types:** `image/jpeg`, `image/png`, `image/webp`
- **Validation:** Inspect declared content type **and** magic bytes / decoder validation; reject mismatches and unknown types.

### Server processing (requirements)

1. **Safety**
   - Reject non-image payloads, executables, polyglots, and archives disguised as images.
   - Optional: virus/malware scan on upload pipeline (see [Security](#8-security)).

2. **Transform & derivatives**
   - Decode, normalize orientation (EXIF), strip risky metadata where appropriate.
   - Produce at minimum:
     - **Original optimized** — re-encoded within size budget where useful.
     - **Avatar** — **512×512** (center-crop or contain policy — document chosen policy in API changelog).
     - **Thumbnail** — **128×128** (same crop policy as avatar for consistency).

3. **Size budget**
   - **Each stored derivative** (or aggregate policy agreed by team) should respect a **final stored size ≤ 500 KB** per deliverable file as specified by product; if only one URL is returned, that asset must meet the budget. If multiple URLs are returned, define per-asset limits in implementation (e.g. each ≤ 500 KB).

4. **Persistence**
   - Store in object storage or outside the application source tree; serve via **CDN or signed/public URL** only (see [Security](#8-security)).

### Response (success)

Envelope: `{ "ok": true, "data": { ... } }` (align with existing mobile JSON conventions).

**Recommended `data` shape:**

```json
{
  "profilePhotoUrl": "https://cdn.example.com/.../profile.jpg",
  "profilePhotoUrl512": "https://cdn.example.com/.../profile_512.jpg",
  "profilePhotoUrl128": "https://cdn.example.com/.../profile_128.jpg"
```

- `profilePhotoUrl` — primary URL (may be 512 derivative or “display” URL).
- Additional keys are **optional**; mobile treats missing thumbnail URLs as nullable.

### Errors

See [Response examples](#6-response-examples).

---

## 2. Cover photo upload

### Endpoint

`POST /api/mobile/me/cover-photo`

### Request

- **Content-Type:** `multipart/form-data`
- **Field name:** `image`
- **Auth:** Authenticated customer session.

### Accepted formats

- **MIME types:** `image/jpeg`, `image/png`, `image/webp`
- Same validation and safety rules as profile photo where applicable.

### Server processing (requirements)

1. Target a **wide banner** — approximate **1200×450** (or equivalent aspect ratio, e.g. 8∶3), with server-side crop/resize policy documented in release notes.
2. **Final stored image ≤ 500 KB** (single delivered asset unless multiple sizes are product-required).
3. Optimize and store like profile photo (object storage / CDN).

### Response (success)

```json
{
  "ok": true,
  "data": {
    "coverPhotoUrl": "https://cdn.example.com/.../cover.jpg"
  }
}
```

`coverPhotoUrl` must be an `https` URL suitable for `Image.network` on mobile.

---

## 3. Profile update (basic fields)

### Endpoint

`PATCH /api/mobile/me/profile`

### Auth

Authenticated customer.

### Body (JSON)

| Field   | Type           | Rules |
|---------|----------------|--------|
| `name`  | string         | Optional; if present, validate length/format per product rules. |
| `email` | string \| null | Optional; **nullable** — omit to leave unchanged; `null` to clear if product allows; validate email format when non-null. |

### Behavior

- Partial update: only sent fields are applied.
- Must not require `location` fields on this route (split from location).

### Response

- Success: `{ "ok": true, "data": { ... } }` with updated user/profile subset or full `me` shape; mobile may refetch `GET /api/mobile/me`.

---

## 4. Location update (structured)

### Endpoint

`PATCH /api/mobile/me/location`

### Auth

Authenticated customer.

### Body (JSON)

| Field            | Type   | Rules |
|------------------|--------|--------|
| `divisionId`     | string | Required for a complete structured save (enforce per product). |
| `districtId`     | string | Required. |
| `upazilaId`      | string | Required. |
| `unionId`        | string | Required. |
| `villageId`      | string | Optional if creating/selecting by name. |
| `newVillageName` | string | Optional; Bangla name for a village not yet in DB — see [Village creation](#5-village-creation--search). Mutually exclusive with `villageId` **or** server resolves: if `villageId` set, ignore `newVillageName`. |

Server should:

- Validate IDs belong to the correct hierarchy (division → … → union).
- Persist a human-readable `area` / label line if the mobile or web UI depends on it (`GET /api/mobile/me`).
- **Never** persist or return **fake/demo** place names as if they were user-selected real locations.

### Response

- Success envelope + updated location fields on `me` or prompt client to refetch `GET /api/mobile/me`.

---

## 5. Village creation / search

### Search

`GET /api/mobile/locations/villages?unionId=<id>&q=<optional>`

- **unionId** — required.
- **q** — optional search string (trimmed); filter by Bangla name (prefix or contains — document choice).

Response (existing mobile pattern):

```json
{
  "ok": true,
  "data": {
    "items": [
      { "id": "...", "slug": "...", "nameBn": "...", "nameEn": "..." }
    ]
  }
}
```

### Create

`POST /api/mobile/locations/villages`

**Content-Type:** `application/json`

| Field     | Type   | Rules |
|-----------|--------|--------|
| `unionId` | string | Required; must reference a valid union. |
| `nameBn`  | string | Required; **Bengali name required** (reject if no Bengali script or per regex policy); **trim** whitespace; normalize repeated spaces. |

**Rules**

- **Duplicates:** Reject or return existing id if the **same normalized name** already exists under that **union** (idempotent `200` with existing village is acceptable).
- **Review:** Optional `PENDING` / admin moderation — if pending, return a stable `id` or a flag so `PATCH /api/mobile/me/location` can reference provisional state; document behavior.
- After approval (if any), village appears in `GET .../villages?unionId=&q=` for future users.

### Errors

Validation, duplicate, unauthorized — use same envelope as other mobile routes (see §6).

---

## 6. Response examples

Common envelope:

```json
{ "ok": false, "error": { "code": "STRING_CODE", "message": "Human message" } }
```

### Success (upload)

```json
{
  "ok": true,
  "data": {
    "profilePhotoUrl": "https://cdn.example.com/u/1/profile.jpg",
    "profilePhotoUrl512": "https://cdn.example.com/u/1/profile_512.jpg",
    "profilePhotoUrl128": "https://cdn.example.com/u/1/profile_128.jpg"
  }
}
```

### Validation error

```json
{
  "ok": false,
  "error": {
    "code": "VALIDATION_ERROR",
    "message": "অনুরোধ সঠিক নয়।",
    "details": { "field": "image" }
  }
}
```

### Unauthorized

```json
{
  "ok": false,
  "error": {
    "code": "UNAUTHORIZED",
    "message": "লগইন প্রয়োজন।"
  }
}
```

### File too large

```json
{
  "ok": false,
  "error": {
    "code": "FILE_TOO_LARGE",
    "message": "ফাইলের আকার অনুমোদিত সীমার চেয়ে বড়।"
  }
}
```

HTTP status: **413** or **400** per existing mobile client handling; document chosen status.

### Unsupported format

```json
{
  "ok": false,
  "error": {
    "code": "INVALID_TYPE",
    "message": "এই ধরনের ফাইল গ্রহণ করা হয় না।"
  }
}
```

HTTP status: **415** or **400** — document and keep consistent with `POST /api/mobile/uploads` if applicable.

---

## 7. Security

| Topic | Requirement |
|--------|-------------|
| **Authentication** | All endpoints in this document: **authenticated user only** (customer session / bearer token as per existing mobile auth). |
| **Rate limiting** | Apply stricter limits on `POST .../profile-photo` and `POST .../cover-photo` (per user / IP) to reduce abuse. |
| **Virus / MIME** | Validate MIME + content; optional async scanning before promoting file to “live”. |
| **Executables** | Reject non-image types and suspicious content; never execute uploaded bytes. |
| **Storage** | Store in **object storage** or path **outside** web app source tree; buckets private by default. |
| **URLs** | Return only **CDN or public/signed URLs** to clients; no raw internal paths or bucket keys in responses. |
| **Authorization** | User may only modify **own** profile media and location (enforce `userId` from session). |

---

## 8. Mobile app dependency notes

- **`profilePhotoUrl`**, **`coverPhotoUrl`**, and any thumbnail URLs must be **nullable / omitted** when unset; the Flutter app must not crash on missing keys.
- **Location fields** on `GET /api/mobile/me` should be optional; missing structured IDs should not break parsing.
- **Do not** return **fake or demo** location strings or IDs as real user data (e.g. no default “Dhaka” or QA labels in production `me` payloads).
- **Multipart field name:** this contract specifies **`image`**. The mobile client should send the part name **`image`** once backend is deployed; until alignment, document any temporary field name in release notes.

---

## Related (existing / legacy)

- `GET /api/mobile/me` — canonical read of customer profile after writes.
- `PATCH /api/mobile/me` — legacy monolithic patch (may coexist until clients switch to split routes).

---

*Document version: profile media + location + village contract for Prani Doctor mobile.*
