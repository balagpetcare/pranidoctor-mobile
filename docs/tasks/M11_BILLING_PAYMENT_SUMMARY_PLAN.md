# Task M11 — Billing & Payment Summary Pages (Audit & Plan)

**Project:** Prani Doctor / Animal Doctors — **mobile app only**  
**Domain:** [https://pranidoctor.com/](https://pranidoctor.com/)  
**Repo:** [github.com/balagpetcare/pranidoctor-mobile](https://github.com/balagpetcare/pranidoctor-mobile)  
**Local path:** `D:\PraniDoctor\pranidoctor_mobile`  

**Scope:** Customer and provider **billing / payment summary UI** (receipt-style cards, badges, role-aware fields). **Implementation** delivered per §15–§17.  
**Isolation:** No BPA/WPA, Quarbani 2026, or other products.

**Last updated:** 2026-05-09 (implemented §17; verification §18)

---

## 1. Task summary

Deliver **Bengali-first**, modular Flutter UI to summarize billing for:

- **Customers:** what they pay (line items, discount, total), **payment method / status**, receipt-style layout — **without** exposing internal platform commission or provider payout unless product explicitly requires it later.
- **Providers (doctor / AI technician):** **earning summary** where appropriate — including **provider payout** and **platform commission** on provider-facing surfaces only.

Support **service requests** and **completed** workflows; align with existing **service request** and **technician job** features. **No real payment gateway** (Stripe/bKash SDK, etc.); **no backend changes** in this task’s scope; use **API-shaped models + graceful empty/mock fallback** until mobile APIs expose billing payloads.

---

## 2. Audit findings — project structure

| Layer | Pattern | Representative paths |
|--------|---------|----------------------|
| **Entry** | `main.dart` → `App` | `lib/main.dart`, `lib/src/app/app.dart` |
| **Routing** | `go_router`, `goRouterProvider` | `lib/src/app/router.dart`, `lib/src/app/navigation_keys.dart` |
| **Theme / DS** | Material 3, teal seed, 16px cards | `lib/src/app/theme.dart` |
| **Layout** | `pdScreenPadding` | `lib/src/app/screen_padding.dart` |
| **HTTP** | `ApiClient` + `Dio`, `{ ok, data, error }` unwrap | `lib/src/core/network/api_client.dart`, `dio_provider.dart` |
| **Config** | `AppConfig` dart-defines | `lib/src/core/config/app_config.dart` — `API_BASE_URL`, `USE_MOCK_TECHNICIAN_API` |
| **Session / roles** | `AppRole`: `customer`, `doctor`, `technician` | `lib/src/features/session/application/session_notifier.dart` |
| **State** | Riverpod `Provider`, `FutureProvider.family`, `AsyncNotifierProvider` | Feature `application/*_providers.dart` files |

**Feature layout (typical):** `lib/src/features/<feature>/{data,application,presentation}/`

---

## 3. Audit findings — relevant features & exact paths

### 3.1 Customer — service requests

| File | Relevance |
|------|-----------|
| `lib/src/features/service_requests/data/service_request_model.dart` | `ServiceRequest` DTO: workflow, animal, provider refs — **no billing numeric fields today** |
| `lib/src/features/service_requests/data/service_request_repository.dart` | `GET/PATCH /api/mobile/service-requests...` — **no billing-specific endpoints in client** |
| `lib/src/features/service_requests/application/service_requests_providers.dart` | `serviceRequestDetailProvider`, list notifier |
| `lib/src/features/service_requests/presentation/service_requests_tab_screen.dart` | **List + `ServiceRequestDetailScreen`**: `_StatusBanner`, `_DetailSection`, loading/error, cancel flow |

**Integration point:** **`ServiceRequestDetailScreen`** — primary place for **customer billing summary** / receipt block when `status == COMPLETED` (and optionally in-progress preview if product allows).

### 3.2 Customer — provider finder (fee display only)

| File | Relevance |
|------|-----------|
| `lib/src/features/providers/data/provider_models.dart` | `fee` as **string** on doctor/technician DTOs |
| `lib/src/features/providers/presentation/widgets/doctor_summary_card.dart` | Shows **ফি: … টাকা** when `fee != null` |
| `lib/src/features/providers/presentation/widgets/technician_summary_card.dart` | Same pattern |
| `lib/src/features/providers/presentation/doctor_detail_screen.dart`, `technician_detail_screen.dart` | **ফি** row — **not** case-level billing |

**Note:** These are **listing/profile** fees, not **per-case payment settlement**.

### 3.3 AI technician workflow

| File | Relevance |
|------|-----------|
| `lib/src/features/technician_ai/data/technician_job_models.dart` | `TechnicianAiServiceRecord.billingNote` — **free-text only** |
| `lib/src/features/technician_ai/data/technician_job_repository.dart` | Live API under `/api/mobile/technician/jobs/...` |
| `lib/src/features/technician_ai/data/technician_job_repository_mock.dart` | Mock jobs — sample `billingNote` string |
| `lib/src/features/technician_ai/application/technician_job_providers.dart` | `technicianJobDetailProvider` |
| `lib/src/features/technician_ai/presentation/technician_job_detail_screen.dart` | **`_PlaceholderSection` titled `পেমেন্ট / বিলিং`** — placeholder copy; **integration point** for structured billing + earning summary |
| `lib/src/features/technician_ai/presentation/widgets/technician_ai_widgets.dart` | `TechnicianJobStatusCard`, `TechnicianAnimalCustomerSummary`, `TechnicianAiBadge` |

### 3.4 Doctor (provider) shell

| File | Relevance |
|------|-----------|
| `lib/src/features/home/doctor/presentation/doctor_home_screen.dart` | **Minimal shell** (tutorials, sign out, debug API base) — **no case list or case detail** |
| `lib/src/features/auth/doctor/presentation/doctor_login_screen.dart` | Doctor login route exists |

**Gap:** There is **no mobile “doctor case detail”** screen in-repo yet. **Provider earning summary** for doctors should be planned as **reusable card/widget** + route hook once a doctor case/job API and screen exist — **do not** rewrite doctor home to fake data beyond a small entry if needed.

### 3.5 App shell & navigation

| File | Relevance |
|------|-----------|
| `lib/src/features/home/home_shell_screen.dart` | Bottom nav: Home, **অনুরোধ** (`ServiceRequestsTabScreen`), Animals, Profile |
| `lib/src/app/router.dart` | `/service-requests/:requestId`, `/technician/jobs/:jobId`, `/doctor/home`, etc. |

### 3.6 Dependencies (`pubspec.yaml`)

Existing: `flutter_riverpod`, `go_router`, `dio`, `intl`, `flutter_secure_storage`, `shared_preferences`. **No new packages required** for summary UI (use `intl` `NumberFormat` for amounts if needed).

---

## 4. Existing reusable patterns (not dedicated billing widgets)

| Pattern | Where | Use for M11 |
|---------|--------|-------------|
| **Status surfaces** | `_StatusBanner` (`service_requests_tab_screen.dart`), `TechnicianJobStatusCard` | Visual rhythm for payment status **badge** (different semantics — separate widget) |
| **Section layout** | `_DetailSection` (duplicated in service request + technician detail) | Receipt **line rows** can mimic label/body hierarchy |
| **Placeholder card** | `_PlaceholderSection` (`technician_job_detail_screen.dart`) | Replace/augment with structured billing card when data exists |
| **Card + Material 3** | `AppTheme` card radius 16 | Receipt container |
| **Async UI** | `.when(loading, error, data)` | Same for any `FutureProvider` for billing |
| **Chip** | `TechnicianAiBadge` uses `Chip` | Pattern for compact **paid/pending** badge |

**Gap:** No shared `lib/src/widgets/` billing library yet — M11 should introduce **small, focused widgets** under a **`billing` feature folder** (or `presentation/widgets` under `billing`) to avoid a wide refactor of unrelated files.

---

## 5. Data model design — billing / payment summary

### 5.1 Suggested domain type (client-only contract)

Single immutable model (names illustrative — align with future API):

```text
BillingPaymentSummary
  - serviceFee: Decimal? / int? (minor units or whole BDT — TBD with API)
  - travelCost: ...
  - medicineCost: ...
  - discount: ...              // positive number representing reduction
  - totalCollected: ...        // customer-facing “মোট”
  - platformCommission: ...    // provider-facing only
  - providerPayout: ...        // provider-facing only
  - paymentMethod: enum or string?   // e.g. CASH, MOBILE_BANKING, UNKNOWN
  - paymentStatus: enum        // e.g. PENDING, PAID, PARTIAL, REFUNDED, WAIVED
  - currency: default 'BDT'
  - notes: String?             // free-text bridge (e.g. legacy billingNote)
```

**Parsing strategy:**

- Prefer **`fromJson` nested under** future `request.billing` or top-level sibling keys on `ServiceRequest` / technician job — **tolerant** (`?.`, defaults).
- **Enums:** `.fromJson(String?)` with safe fallback to `UNKNOWN` so UI never crashes.

### 5.2 Mapping from current data

- **`ServiceRequest`:** today **no** billing object — UI shows **empty state** (“বিলিং এখনও যুক্ত হয়নি”) or **dev-only mock** behind a flag (see §7).
- **`TechnicianAiServiceRecord.billingNote`:** keep as **secondary “মন্তব্য”** line under structured fields when non-empty.

---

## 6. Role-aware display rules

| Role | Show | Hide / avoid |
|------|------|----------------|
| **Customer** | Service fee, travel, medicine, discount, **total collected**, payment method, payment status (and receipt ID/date if added later) | **Platform commission**, **provider payout** — unless product later adds an explicit “transparent pricing” mode |
| **Doctor / technician (provider)** | Customer-visible totals **where useful**, plus **provider payout** and **platform commission** on provider-only surfaces | Do not show provider-earning card on customer routes |
| **Implementation guard** | Pass `BillingViewAudience customer \| provider` into summary widgets | Single widget file can branch internally to reduce duplication |

---

## 7. API expectation & fallback / mock strategy

**Constraint:** **No backend changes** in M11 implementation phase — mobile must **not assume** live billing JSON exists.

1. **Forward-compatible parsing:** Extend or wrap detail models to read optional `billing` / `payment` maps when present.
2. **Empty state:** If JSON absent, show Bengali **empty** message (not an error).
3. **Mock / demo (optional, low-risk):** Mirror **`AppConfig.useMockTechnicianApi`** pattern — e.g. `USE_MOCK_BILLING_UI=true` **only if** needed for QA demos; default **false**; **no** fake data in production paths without flag.
4. **Technician mock repo:** `technician_job_repository_mock.dart` can later attach **sample `BillingPaymentSummary`** for screenshot tests — keep isolated from customer OTP flows.

**Documentation expectation:** When backend exposes fields, update **this doc** with exact JSON keys and one example payload.

---

## 8. UI component plan

| Component | Purpose |
|-----------|---------|
| **`PaymentStatusBadge`** | Small **pending / paid** (and variants) — `Chip` or `Container` + icon; Bengali labels |
| **`CasePaymentStatusSection`** | Title + badge + one-line explanation for “কেস” / অনুরোধ |
| **`BillingReceiptCard`** | Receipt-style **white/teal** card: rows for line items, divider, **bold total**, optional footer note |
| **`ProviderEarningSummaryCard`** | Provider-only: commission, payout, net emphasis |
| **`BillingSummaryBody`** | Orchestrator: audience enum + nullable `BillingPaymentSummary` → receipt + earning card or empty |

**UX:** Large **total** typography (`titleLarge` / `headlineSmall`), `Divider`, consistent **টাকা** suffix, `intl` formatting for integers.

---

## 9. Page integration points

| Flow | Screen | Action |
|------|--------|--------|
| **Customer** | `ServiceRequestDetailScreen` | Insert **billing block** after status / before or after timeline sections; for **COMPLETED**, emphasize receipt; for earlier statuses, optional “আনুমানিক” or hide totals |
| **Customer (list)** | `ServiceRequestsTabScreen` | Optional **trailing subtitle** or small badge “পেমেন্ট অপেক্ষমান” — **only if** list API later includes payment status (otherwise skip to avoid N+1) |
| **AI technician** | `TechnicianJobDetailScreen` | Replace/enrich **`পেমেন্ট / বিলিং`** placeholder with **`BillingReceiptCard`** + **`ProviderEarningSummaryCard`** when `audience == provider` |
| **Doctor** | `DoctorHomeScreen` | **No case detail today** — add **placeholder section** or FAB link **only when** doctor job API exists; otherwise document **deferred** |

**Optional route:** `go_router` child route e.g. **`/service-requests/:id/billing`** for full-screen receipt — only if stacked layout feels cramped; prefer **inline card** first for lower risk.

---

## 10. Bengali label list (primary copy)

| Concept | Suggested BN label |
|---------|---------------------|
| Billing section | বিলিং ও পেমেন্ট |
| Service fee | সেবা ফি |
| Travel cost | যাতায়াত খরচ |
| Medicine cost | ঔষধ খরচ |
| Discount | ছাড় |
| Total (collected) | মোট পরিশোধ |
| Platform commission | প্ল্যাটফর্ম কমিশন |
| Provider payout | প্রদানকারী পেআউট |
| Payment method | পেমেন্ট পদ্ধতি |
| Payment status | পেমেন্টের অবস্থা |
| Pending | অপেক্ষমান |
| Paid | পরিশোধিত |
| Receipt | রসিদ |
| Earnings summary | আয়ের সারাংশ |
| Cash | নগদ |
| Mobile banking | মোবাইল ব্যাংকিং |
| Not available yet | এখনও যুক্ত হয়নি |

*(English enum names in code; user-visible strings stay Bengali-first.)*

---

## 11. Loading, error, and empty state plan

| State | Behavior |
|-------|----------|
| **Loading** | If billing is **separate request**: `CircularProgressIndicator` or skeleton **inside card** only (avoid full-screen flash when detail already loaded) |
| **Error** | Bengali message + **আবার চেষ্টা** for retryable network errors — mirror `TechnicianJobDetailScreen` error pattern |
| **Empty** | Neutral icon + “বিলিং তথ্য এখনও উপলব্ধ নয়” when no payload and no mock flag |

---

## 12. Testing checklist (implementation phase)

- [ ] Widget tests: badge renders **pending vs paid** labels (golden or smoke).
- [ ] Model parsing: unknown JSON keys ignored; null-safe totals.
- [ ] Role test: `BillingViewAudience.customer` **never** builds commission/payout rows (assert widget `findsNothing`).
- [ ] Provider test: `audience.provider` shows payout + commission when values non-null.
- [ ] One integration-style test: `ServiceRequestDetailScreen` still builds when billing map absent.

---

## 13. Risks and safeguards

| Risk | Mitigation |
|------|------------|
| Backend missing fields | Tolerant models + empty states; no crashes on missing keys |
| Scope creep into payments | **No** gateway SDK, **no** card capture UI |
| Duplicating `_DetailSection` everywhere | Extract **only** shared billing row widget inside `billing` feature |
| Doctor flow undefined | Ship **reusable** earning card; wire doctor screen **later** |
| Fake amounts misleading users | No demo amounts unless **`USE_MOCK_BILLING_UI`** or dev banner |

---

## 14. Explicit out of scope

- **No** real **payment gateway** integration (bKash/Nagad/SSLCOMMERZ SDK, card vault, 3DS).
- **No** **backend** or **pranidoctor-web** changes from this mobile task.
- **No** unrelated **UI rewrite** of home, onboarding, or provider finder.
- **No** mixing other products (BPA/WPA, Quarbani 2026, etc.).

---

## 15. Proposed files to create / update — **DONE**

**Created:**

- `lib/src/features/billing/data/billing_payment_summary_model.dart`
- `lib/src/features/billing/presentation/widgets/billing_money_format.dart`
- `lib/src/features/billing/presentation/widgets/payment_status_badge.dart`
- `lib/src/features/billing/presentation/widgets/case_payment_status_section.dart`
- `lib/src/features/billing/presentation/widgets/customer_billing_summary_card.dart`
- `lib/src/features/billing/presentation/widgets/provider_earning_summary_card.dart`
- `test/billing_payment_summary_widget_test.dart`

**Updated:**

- `lib/src/core/config/app_config.dart` — `USE_MOCK_BILLING_UI`
- `lib/src/features/service_requests/data/service_request_model.dart`
- `lib/src/features/service_requests/presentation/service_requests_tab_screen.dart`
- `lib/src/features/technician_ai/data/technician_job_models.dart`
- `lib/src/features/technician_ai/data/technician_job_repository_mock.dart`
- `lib/src/features/technician_ai/presentation/technician_job_detail_screen.dart`

**Not created (architecture tweak vs §15):** `billing_receipt_card.dart` name — receipt UI lives in `customer_billing_summary_card.dart`. No separate `billing_summary_scope.dart`; customer vs provider separation is by **widget** (`CustomerBillingSummaryCard` vs `ProviderEarningSummaryCard`), not a shared audience enum file.

**Untouched as planned:** `router.dart`, `DoctorHomeScreen`.

---

## 16. Summary reference — architecture alignment

| Topic | Choice |
|-------|--------|
| **Navigation** | Stay on `go_router`; inline billing first |
| **State** | Riverpod; extend detail providers or add `.family` billing provider only if separate GET |
| **Design** | `AppTheme`, `Card`, 16px radius, Bengali copy |
| **Mock** | Follow `AppConfig` + repository mock pattern for technician; optional global billing demo flag |

---

## 17. Implementation completed (2026-05-09)

### Files changed

Same list as §15 **Created** + **Updated** above.

### How to view / test

| Surface | Steps |
|--------|--------|
| **Customer — request detail** | Log in as customer → tab **অনুরোধ** → open any request → **রসিদ / বিলিং** card below status banner. Without API `billing`, shows empty Bengali message. With `--dart-define=USE_MOCK_BILLING_UI=true`, shows demo amounts (marked ডেমো in notes). |
| **AI technician — job detail** | `flutter run --dart-define=USE_MOCK_TECHNICIAN_API=true` → navigate to technician jobs → open **job-mock-3** → **আয়ের সারাংশ** shows demo commission/payout from mock billing; legacy `billingNote` appears as footer when present. |
| **Tests** | `flutter test test/billing_payment_summary_widget_test.dart` |

### Assumptions / fallbacks

- JSON: optional nested maps `billing`, `payment`, or `paymentSummary`, plus tolerant camelCase/snake_case aliases on `BillingPaymentSummary.fromJson`. Whole-document fallback uses only recognized keys so normal service-request payloads do not synthesize fake billing.
- Amounts are **whole currency units** (BDT taka) as `double?`.
- **Customer UI** never renders commission/payout rows even if those keys appear on the wire (`CustomerBillingSummaryCard` only reads customer fields).
- **Doctor home:** still no case-detail route; **provider earning** is integrated on **AI technician job detail** only (same reusable card can be dropped onto a future doctor case screen).

### Out-of-scope confirmation

- No payment gateway, no backend edits, no unrelated page refactors.

---

## 18. Final verification (CI-style checks)

**Commands run:** `dart format .`, `flutter analyze`, `flutter test` (project root: `pranidoctor_mobile`).

| Check | Result | Notes |
|--------|--------|--------|
| **`dart format .`** | **PASS** | `Formatted 78 files (0 changed)` — working tree already conformed to formatter. |
| **`flutter analyze`** | **PASS** | `No issues found!` |
| **`flutter test`** | **PASS** | `All tests passed!` (5 tests: billing widget tests, technician badge tests, app builds). |

### Fixed issues summary

- None — no analyzer, test, or format drift required fixes after M11.

### Remaining known issues

- None from these verification runs. (Product/API gaps unchanged: billing JSON may still be absent from live APIs until backend exposes fields.)

---

*End of M11 audit & plan.*

