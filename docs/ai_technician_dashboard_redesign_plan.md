# AI Technician Dashboard — Professional Redesign Plan

**Scope:** Planning only (no implementation in this task).  
**Project:** Prani Doctor / Animal Doctors Flutter app (`pranidoctor_mobile`).  
**Constraints:** No backend changes; preserve current behavior; Bengali-first UI; reuse design-system widgets; avoid duplicate components.

---

## 1. Existing screen analysis

### 1.1 Primary screen (in scope)

| Item | Detail |
|------|--------|
| **File** | `lib/src/features/ai_technician_application/presentation/ai_technician_dashboard_screen.dart` |
| **Route** | `/profile/ai-technician/dashboard` (`AiTechnicianDashboardScreen.routePath`, `routeName: aiTechnicianDashboard`) |
| **Registration** | `lib/src/app/router.dart` (nested under profile routes) |
| **Purpose** | Home for approved/published (and in-review) AI technicians: status messaging, KPIs, reviews teaser, emergency toggle, active services teaser, navigation to requests/services/status |

### 1.2 Naming collision (do not merge without product decision)

| Screen | Path | Role |
|--------|------|------|
| **AiTechnicianDashboardScreen** | `/profile/ai-technician/dashboard` | Customer-account AI technician application module (`ai_technician_application`). Uses `AiTechnicianRepository` + dashboard API. **This document targets this screen.** |
| **TechnicianDashboardScreen** | `/technician/home` | Separate `technician_ai` feature (different flows/API). Standard `Scaffold` + `AppBar`, not `PraniScaffold`. Not the subject of this redesign unless product explicitly unifies both. |

### 1.3 Widgets and patterns in use today

| Design-system / pattern | Usage on dashboard |
|-------------------------|-------------------|
| **PraniScaffold** | Yes — title `এআই টেকনিশিয়ান ড্যাশবোর্ড`, padded body. |
| **PraniAppHeader** | Indirect — `PraniScaffold` builds `AppBar` with `PraniAppHeader` when `title` is set. |
| **PraniPrimaryButton** / **PraniSecondaryButton** | Yes — CTAs (intro, requests, new service, services list, application status). |
| **PraniLoadingState** | Yes — `loading:` branch of `async.when`. |
| **PraniPremiumCard** | Primary surface for all content blocks (status, KPIs, reviews, emergency, services). |
| **PraniSectionHeader** | **Not used** — section titles are plain `Text` with `titleMedium` + bold. |
| **PraniInfoCard** | **Not used**. |
| **PraniEmptyState** | **Not used** — “no profile” and empty reviews/services use inline `Text`. |
| **PraniErrorState** | **Not used** — errors show raw `Text('লোড করা যায়নি।\n$e')`. |
| **PraniAsyncListStatus** | **Not used** — loading/error/data composed manually with `async.when`. |
| **RefreshIndicator** | Yes — invalidates `aiTechnicianDashboardProvider` and `aiTechnicianMeProvider`. |

**Local/private UI**

- **`_StatLine`** — label/value row for KPI lines; exists only in this file (no shared `PraniStatRow` today).

### 1.4 Data layer (no backend changes)

| Piece | Location |
|-------|----------|
| **Provider** | `aiTechnicianDashboardProvider` → `FutureProvider.autoDispose<AiTechnicianDashboardData>` in `lib/src/features/ai_technician_application/application/ai_technician_providers.dart` |
| **Repository** | `AiTechnicianRepository.fetchDashboard()` → `GET /api/mobile/ai-technician/dashboard` in `lib/src/features/ai_technician_application/data/ai_technician_repository.dart` |
| **DTO** | `AiTechnicianDashboardData` (+ nested `AiTechnicianProfile`, `AiTechnicianServiceRow`, `AiTechnicianReviewSnippet`) in `lib/src/features/ai_technician_application/data/ai_technician_models.dart` |
| **Settings mutation** | `patchSettings(acceptsEmergency: …)` — invalidates dashboard + `aiTechnicianMeProvider` after success |

### 1.5 Async / empty / error behavior

| State | Current behavior | Gap vs design system |
|-------|------------------|----------------------|
| **Loading** | Centered `PraniLoadingState` | Acceptable; optional consistency with `PraniAsyncListStatus`-style wrapper if refactoring `when`. |
| **Error** | Scrollable `Text` with exception string | Should migrate to **PraniErrorState** with friendly Bengali title/message, optional `detail` in dev/debug only, **retry** wired to same refresh as pull-to-refresh. |
| **No profile (`profile == null`)** | Plain copy + `PraniPrimaryButton` → intro | Could align with **PraniEmptyState** + primary action for visual parity with rest of app. |
| **Empty reviews / empty services** | Inline muted copy inside cards | Could use **PraniEmptyState** `compact`/`boxed` patterns where it improves scanability without duplicating custom widgets. |

### 1.6 Design inconsistencies

1. **Section titling:** Other AI technician screens (e.g. form, intro) use **PraniSectionHeader** + **PraniInfoCard**; dashboard uses only **PraniPremiumCard** + raw **Text** headings — visual hierarchy differs from sibling flows.
2. **Error UX:** Technical exception exposed in default error UI path; rest of module prefers **PraniErrorState**.
3. **Information density:** KPI block mixes “today”, “pending”, “completed”, **total earnings**, and **rating** in one card — readable but crowded; professional redesign can separate **“আজ”** vs **“মোট / সামগ্রিক”** visually without new APIs (pure layout).
4. **Primary actions:** “কাজের অনুরোধ”, “নতুন সার্ভিস”, duplicate navigation to services (“সব দেখুন” vs “সার্ভিস তালিকা”) — opportunity to consolidate into a single **quick actions** row without removing destinations.
5. **Reviews:** Star glyphs inline — acceptable; optional alignment with shared typography tokens (`PraniTextStyles`) for consistency.

### 1.7 Duplicate components

- **No duplicate widgets** pulled from two implementations for this dashboard — only **one** dashboard implementation file.
- **`_StatLine`** is file-private; before extracting a shared widget, **search** `lib/` for existing KPI row / stat line components to avoid duplication (per project rules).

### 1.8 Improvements possible without backend changes

- Restructure layout into clear sections (see §2) using existing DTO fields only.
- **Profile completion / verification:** derive **client-side checklist** from `AiTechnicianProfile` already embedded in dashboard (`documents`, `providerStatus`, `verifiedAt`, location fields, etc.) — UI-only scoring/copy; no new fields required.
- **Earnings:** already have `totalEarningsBdt`; can give a dedicated summary subsection (still one number unless backend later adds breakdown).
- **Request summary:** dashboard exposes **counts** (`todayRequestsCount`, `pendingRequestsCount`, `completedServicesCount`) — present as a clearer status summary (chips, columns). Fine-grained counts per tab (new/accepted/ongoing/cancelled) are **not** on `AiTechnicianDashboardData`; optional **additional client-only calls** to existing list endpoints would multiply network traffic — flag as product/risk decision (§6).
- **Weekly performance:** true weekly aggregates are **not** in current JSON — UI can label **“সাম্প্রতিক রিভিউ”** honestly (already partially done) or show **last N reviews** with date — avoid implying “weekly stats” without data.
- **Alerts/notifications:** no alert payload on dashboard DTO — section can be **placeholder** (“শীঘ্রই”), **link-only** (e.g. to requests if pending &gt; 0), or **omitted** until backend supports it — must not fake live notifications.

---

## 2. Proposed dashboard sections (information architecture)

Order can be tuned during implementation; all copy stays Bengali-first.

1. **Technician profile / status summary card** — Photo/initials (if available via profile or documents), **display name**, **provider/publication** state, short subtitle from `AiTechnicianStatusCopy` / `isPublished`.
2. **Profile completion & verification** — Progress or checklist: NID/docs, training certs, areas, `providerStatus`, `verifiedAt` — all from existing `profile`.
3. **Today vs total KPI overview** — Split visual groups: “আজ” (today requests) vs “সামগ্রিক” (pending, completed, earnings, rating) using existing numeric fields.
4. **Request status summary** — Summarize pipeline using **dashboard counts**; optional chips (“নতুন”, “অপেক্ষমাণ”, “সম্পন্ন”) mapped honestly to available numbers — avoid implying extra states without data.
5. **Emergency availability card** — Keep current **SwitchListTile** behavior; restyle with **PraniInfoCard** or structured layout inside **PraniPremiumCard** for consistency.
6. **Active services section** — Keep list/teaser; **PraniSectionHeader** + “সব দেখুন”; empty state via **PraniEmptyState** (compact) when list empty.
7. **Earnings summary section** — Highlight `totalEarningsBdt` (+ optional subtitle “মোট আয়”); remains single figure until API expands.
8. **Weekly performance / review section** — Title: **“সাম্প্রতিক রিভিউ”** or **“পারফরম্যান্স সংক্ষেপ”**; content = `recentReviews` only; no fabricated weekly charts.
9. **Alerts / notifications section** — Lightweight strip: e.g. “অপেক্ষমাণ অনুরোধ: N” linking to requests if `pendingRequestsCount &gt; 0`, or empty/disabled placeholder — **no mock notification list**.
10. **Quick action buttons** — Single row or **sticky-style** bar: অনুরোধ, নতুন সার্ভিস, সার্ভিস তালিকা, আবেদনের বিস্তারিত — deduplicate overlapping routes.

---

## 3. Reusable widgets / components (reuse vs create)

**Reuse (preferred)**

| Widget | Role |
|--------|------|
| **PraniScaffold** | Shell unchanged. |
| **PraniAppHeader** | Via scaffold title/subtitle; optional `subtitle` for dashboard tagline. |
| **PraniSectionHeader** | Each major section title/subtitle. |
| **PraniInfoCard** | Tips, emergency explanation, verification hints. |
| **PraniPremiumCard** | Continue for elevated grouped content. |
| **PraniPrimaryButton** / **PraniSecondaryButton** | CTAs and quick actions. |
| **PraniLoadingState** / **PraniErrorState** / **PraniEmptyState** | Standardize async and zero-data paths. |
| **PraniAsyncListStatus** | Optional refactor of `async.when` if it reduces branching without changing behavior. |

**Create only if missing elsewhere (search first)**

- **`PraniStatRow` / KPI row** — Only if no equivalent exists; otherwise extend existing pattern. Prefer extracting from **`_StatLine`** only after confirming no duplicate in `design_system` or other features.
- **`AiTechnicianDashboardViewModel` (see §4)** — Pure Dart helper/class in `presentation/` or `application/` — not a new widget file unless needed for testing.

**Avoid**

- New parallel cards that duplicate **PraniPremiumCard** / **PraniInfoCard** styling.
- Second dashboard screen for the same route.

---

## 4. Data model / view model for UI

**Source of truth (unchanged):** `AiTechnicianDashboardData` from `aiTechnicianDashboardProvider`.

**Recommended UI helpers (no API changes)**

Introduce a **read-only view model** or extension methods (naming illustrative):

| Derived UI field | Logic (examples) |
|------------------|------------------|
| `effectiveStatus` | `profileStatus ?? profile.status` (already in UI). |
| `isApprovedLike` | `status in { APPROVED, PUBLISHED }` (already implicit). |
| `completionSteps` | List of `{ labelBn, isDone }` from profile fields + document types present. |
| `verificationBadge` | From `providerStatus` + `verifiedAt`. |
| `earningsDisplay` | Format `totalEarningsBdt` with consistent ৳ prefix/suffix. |
| `ratingDisplay` | Existing average + count or “শীঘ্রই”. |
| `alertSummaries` | Derived booleans only (e.g. show pending CTA if `pendingRequestsCount &gt; 0`). |

Optional: **`AsyncValue&lt;AiTechnicianDashboardData&gt;` → widget** private method `buildBody` to keep `build()` thin — still one screen file unless size forces private widgets in same library (**no duplicate screen**).

---

## 5. Step-by-step implementation checklist

1. **Baseline QA** — Document current flows: load, refresh, error network, no profile, approved with services, emergency toggle disabled when unpublished, snackbars on settings save.
2. **Design audit in code** — Replace plain section titles with **PraniSectionHeader** where applicable.
3. **Error path** — Swap error branch to **PraniErrorState** + retry calling same invalidate logic as `RefreshIndicator`.
4. **Empty paths** — “No profile”, empty reviews, empty services: adopt **PraniEmptyState** where it improves clarity (keep navigation behavior identical).
5. **Profile hero card** — Add summary card using `profile.displayName`, status, optional leading CircleAvatar (placeholder if no image URL — only if existing model exposes usable URL; otherwise initials).
6. **Completion / verification block** — Implement derived checklist from `AiTechnicianProfile` (copy-only / navigational hints to form sections — no new API).
7. **KPI layout** — Split “আজ” vs “মোট” groups; reuse **\_StatLine** or extracted shared row **after** duplicate search.
8. **Request summary** — Visual grouping of existing three metrics; honest labels.
9. **Emergency card** — Polish copy layout with **PraniInfoCard** or structured children; preserve `patchSettings` behavior.
10. **Services section** — **PraniSectionHeader** + list; empty state component.
11. **Earnings subsection** — Visual emphasis without new data.
12. **Reviews section** — Rename if needed to avoid “weekly” claim; keep `recentReviews` mapping.
13. **Alerts strip** — Minimal derived alerts or placeholder copy approved by product.
14. **Quick actions** — Consolidate buttons; maintain all current navigation targets.
15. **Accessibility / tokens** — Verify contrast, tap targets, **PraniSpacing** consistency.
16. **Regression pass** — Same routes, same invalidations, same Bengali strings unless intentionally improved copy.

---

## 6. Risk notes

| Risk | Mitigation |
|------|------------|
| **Confusion between two “technician” dashboards** | Document routes in release notes; optional deep-link audit; do not rename routes without coordination. |
| **Over-promising “weekly” or “notifications”** | Tie labels strictly to `recentReviews` and derived counts; placeholder alerts must be honest. |
| **Extra API calls for richer request breakdown** | Listing per tab increases load — defer unless product accepts cost; prefer dashboard counts only. |
| **Extracting shared KPI widget** | Grep-first to avoid duplicate components; small private widgets in the same file remain acceptable. |
| **Profile image** | If no stable image URL on model, use initials only — do not add network assumptions without backend contract. |

---

## 7. Acceptance criteria

1. **Route & data** — Uses `aiTechnicianDashboardProvider` + optional `aiTechnicianRequestPipelineCountsProvider` (existing list API only); emergency toggle still calls `patchSettings` and invalidates the same providers.
2. **Behavior parity** — Pull-to-refresh, navigation targets (intro, requests list, services list/new, application status), and snackbars for settings success/failure behave as today unless a deliberate UX fix is documented.
3. **Design system** — Screen uses **PraniScaffold**, header pattern, **PraniPrimaryButton** / **PraniSecondaryButton**, and incorporates **PraniSectionHeader**, **PraniInfoCard**, **PraniEmptyState**, **PraniErrorState**, **PraniLoadingState** (and **PraniAsyncListStatus** if adopted) — no one-off duplicate of these patterns for the same role.
4. **Bengali-first** — All user-visible strings remain Bengali (technical detail only in dev/debug via **PraniErrorState** `detail` pattern).
5. **No backend changes** — No new endpoints or DTO fields required for ship; any optional multi-fetch clearly labeled and justified.
6. **No orphan widgets** — No new duplicate dashboard screen; shared extracts justified by repo-wide search.

---

## 8. Pending backend / data support

Mobile consumes existing contracts only. The following remain **server-led** or **approximate on-device**:

| Area | Current app behavior | Backend / contract gap |
|------|----------------------|-------------------------|
| **Earnings period splits** | আজ / সপ্তাহ / মাস / পেমেন্ট অপেক্ষমাণ remain **৳০** in UI | Dashboard JSON has **`totalEarningsBdt`** only; no period buckets or pending payouts in `AiTechnicianDashboardData`. |
| **Request pipeline totals** | Tab counts loaded via **five** paginated `GET .../requests?tab=&limit=200` calls; **`truncated`** shows **`N+`** | Prefer **`counts`** object on dashboard or lightweight **`GET .../requests/summary`** to avoid N calls and truncation. |
| **Completion / SLA rate** | Derived only from **`completedServicesCount`** vs **`pendingRequestsCount`** on dashboard | Product-defined completion metric may need explicit fields. |
| **Response quality score** | Placeholder copy | No field in dashboard DTO. |
| **Rating count vs snippets** | KPI uses **`ratingCount`**; average may fall back to mean of **`recentReviews`** when server average null | Align counts if server guarantees consistency. |

---

*End of plan.*
