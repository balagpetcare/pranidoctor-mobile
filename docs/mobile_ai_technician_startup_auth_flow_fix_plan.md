# Mobile: AI Technician startup, splash, and OTP/auth flow — audit & fix plan

**Scope:** Flutter app `pranidoctor_mobile` only. No backend changes. Bengali-first UX preserved.

**Audit date:** 2026-05-11 (Composer Agent, read-only code audit).

---

## 1. Executive summary

| Area | Symptom | Likely root cause(s) | Confidence |
|------|---------|----------------------|------------|
| Splash | Busy layout, not “production” polish | `Stack` + deferred hero PNG + `Center` + `SingleChildScrollView` + fixed delay; subjective hierarchy | Medium |
| OTP | “Warning” above OTP | **SnackBar** after send/verify + **floating** margin + keyboard; **dev OTP fallback** snack in dev builds; API `error.message` via `OtpAuthException` | High (SnackBar placement); Medium (exact copy) |
| AI Technician form | Blank body, only **পরবর্তী** visible | **No single line proven** without device repro; strongest code risks: **layout / scroll**, **invalid `DropdownButtonFormField` value** vs server data, **build-time exception** swallowed in release, **contrast** (lower priority) | Medium — needs runtime confirmation |
| Dashboard | Works for existing profiles | Confirms `GET me` + non-editable routing; **new path** differs (`apply` + wizard step 0) | High |

---

## 2. Navigation trace (Profile → AI Technician)

### 2.1 Route table (GoRouter)

| Step | Screen | Path | Source |
|------|--------|------|--------|
| A | `ProfileHomeScreen` | Tab body under `/home` | `HomeShellScreen` |
| B | `AiTechnicianApplicationEntryScreen` | `/profile/ai-technician/entry` | Profile tile → `openAiTechnicianApplicationEntry` (`ai_technician_entry.dart`) |
| C1 | `AiTechnicianApplicationFormScreen` | `/profile/ai-technician/form` | Entry: `me.profile == null` → **`pushReplacement` form `extra: 0`** (first-time apply path) |
| C1b | `AiTechnicianIntroScreen` | `/profile/ai-technician/intro` | Optional marketing route (e.g. status screen); **not** the default first-time path from entry |
| C2 | `AiTechnicianApplicationFormScreen` | `/profile/ai-technician/form` | Intro **“আবেদন শুরু করুন”** → `push(..., extra: 0)`; Entry: editable draft → `pushReplacement(..., extra: initialFromPrefs)` |
| C3 | `AiTechnicianApplicationStatusScreen` | `/profile/ai-technician/status` | Entry: submitted-like / rejected pipeline |
| C4 | `AiTechnicianDashboardScreen` | `/profile/ai-technician/dashboard` | Entry: `APPROVED` / `PUBLISHED` |

Router: `lib/src/app/router.dart` (routes ~265–305). **`AiTechnicianApplicationEntryScreen.routePath` is guest-accessible** so the resolver can show a Bengali login prompt; other `/profile/ai-technician/*` routes still require auth.

### 2.2 First-time vs returning user

| State | Entry resolver behavior |
|-------|-------------------------|
| Logged in, **no** technician `profile` (`GET …/me` → `profile: null`) | `pushReplacement` → **Form** (`extra: 0`) |
| Logged in, profile exists, **`isEditable`** (`DRAFT`, `NEEDS_CORRECTION`, `NEEDS_MORE_INFO`) | `pushReplacement` → **Form** (optional `SharedPreferences` step resume) |
| Logged in, `APPROVED` / `PUBLISHED` | → **Dashboard** |
| Logged in, other statuses (submitted pipeline, etc.) | → **Status** |
| Guest (not authenticated) | Entry screen: **লগইন প্রয়োজন** + navigates to `LoginEntryScreen` with `?next=/profile/ai-technician/entry` |
| Entry `fetchMe` failure | Entry screen error + retry (not blank form) |
| Form `_bootstrap` failure | Full-screen **PraniErrorState** + retry |

Form bootstrap (`AiTechnicianApplicationFormScreen._bootstrap`): if `fetchMe()` has no profile, calls `repo.apply({})` to create draft, then `_fill` + sets `_profile`. **Dashboard path does not call `apply` on open** — only the form wizard does. So **first-time creation is unique to the form route**.

---

## 3. Splash screen audit

**File:** `lib/src/features/splash/splash_screen.dart`

**Behavior:**

1. Post-frame: sets `_heavyBrandDecorReady = true` (shows farm PNG + logo + gradient), then `_goNext()`.
2. `_goNext`: **waits 1400 ms**, `sessionNotifier.hydrateFromStorage()`, reads `SharedPreferences` `pd_onboarding_done`, then `context.go` onboarding or home.
3. Splash farm image uses `Image.asset` with `cacheWidth` / `cacheHeight` caps (`PraniAssetDecode`) — comment notes large PNG decode can jank first frame.

**Issues (UX / polish):**

- **Fixed delay** (1400 ms) regardless of hydrate/prefs speed — feels slow on fast devices.
- **Layout:** `SafeArea` → `Center` → `SingleChildScrollView` → `Column` with logo, two texts, spinner — on tall phones content sits mid-screen with heavy top/bottom farm crop; **not aligned to a clear “brand safe zone”** (subjective “unbalanced”).
- **No `errorBuilder`** on `Image.asset` — rare missing asset yields broken visual without friendly fallback.
- **Splash vs `scaffoldBackgroundColor`:** `AppTheme` sets `scaffoldBackgroundColor` to `PraniColors.background` while splash `Scaffold` uses default body; mostly covered by `Stack` — minor edge flicker possible.

**Files to touch (later implementation):** `splash_screen.dart`, optionally `prani_assets.dart` / asset pipeline docs only if adding fallbacks (no new duplicate widgets — reuse `PraniLoadingState` / design tokens).

---

## 4. OTP / auth “warning” audit

### 4.1 User-visible sources (exact)

1. **`LoginEntryScreen._sendOtp` / `_verify`** (`lib/src/features/auth/login_entry_screen.dart`)
   - Success SMS path: SnackBar — *“যাচাইকরণ কোড SMS এ পাঠানো হয়েছে।”*
   - **Dev fallback path:** when `requestOtp` returns `OtpSendChannel.devTerminalFallback`, SnackBar — *“ডেভেলপমেন্ট মোডে টেস্ট OTP তৈরি করা হয়েছে। টার্মিনাল/ডিবাগ কনসোল দেখুন।”* (`useDevOtpFallback` = `APP_ENV=development` **and** `ENABLE_DEV_OTP=true`, and API unreachable in repository branch — see `mobile_otp_auth_repository.dart`).
   - Errors: `OtpAuthException` → `_snack(e.message)`; generic catch → generic Bengali snack.

2. **`MobileOtpAuthRepository`** (`lib/src/features/auth/data/mobile_otp_auth_repository.dart`)
   - Maps `DioException` via `_messageFromDio` → envelope `error.message` or `userFacingDioMessageBn` (`lib/src/core/network/dio_user_message.dart`).
   - **429 / 401 / 403 / timeout** → user-facing Bengali strings (not English raw Dio).

3. **`_snack` implementation**
   - `SnackBarBehavior.floating`, `margin: EdgeInsets.fromLTRB(16, 0, 16, 16)` — **top margin is 0**. With keyboard open (`resizeToAvoidBottomInset: true` on login scaffold), **Material often lifts floating snackbars**; combined with hero + scroll layout, the snack can appear **visually high on the screen**, i.e. **above the OTP field** — reads as a “warning strip” even for neutral success copy.

4. **Non-SnackBar “debug” copy on login screen**
   - If `AppConfig.isDevelopmentEnv`, bottom of scroll shows *“API ভিত্তি (ডিবাগ): …”* — below OTP block, not above.

5. **`main.dart`**
   - Debug print of `resolvedApiBaseUrl` / `ENABLE_DEV_OTP` — logcat only, not in-widget.

**Root cause (OTP “warning”):** **Primary:** SnackBar channel + **floating positioning with `margin` top = 0** + **keyboard** makes feedback appear in the **upper content area** relative to OTP. **Secondary:** In dev builds, **dev OTP fallback** message is inherently “warning-like”. **Tertiary:** Server validation / rate-limit messages surface as the same SnackBar.

**Files to modify (implementation):**

- `lib/src/features/auth/login_entry_screen.dart` — SnackBar `margin` / `dismissDirection` / consider `SnackBarAction`, bottom padding from `MediaQuery.viewInsets`, or a small **inline info `Material`** under the OTP title for **success** messages only (reuse design system cards, e.g. `PraniInfoCard` / compact variant — **no duplicate component library**).
- Optionally `lib/src/features/auth/data/mobile_otp_auth_repository.dart` — only if changing when fallback is reported (keep Bengali copy).

---

## 5. AI Technician application form — blank body audit

**Primary file:** `lib/src/features/ai_technician_application/presentation/ai_technician_application_form_screen.dart`

### 5.1 Where **পরবর্তী** is built

- **`Scaffold.bottomNavigationBar`** → `PraniStickyActionBar` → `_buildBottomActions` → `PraniPrimaryButton(label: 'পরবর্তী')` for non-last steps (`~1757–1820`).
- So the green CTA is **by design** the bottom bar, not the `AppBar`. If users report it at the **top**, capture screenshot + device model: could be **mis-identification** (only visible interactive control under app bar on a **blank** middle), **safe-area / display cutout**, or a **Navigator overlay** — **not reproduced in static read**.

### 5.2 Layout checklist (per audit request)

| Construct | Usage | Notes |
|-----------|-------|------|
| `SingleChildScrollView` | Body scroll + bottom `scrollBottomPad` (`120 + kb`) | Intentional extra pad for sticky CTA |
| `Align` | Avoided inside step column per comment (`_wizardStepColumn`) | Good — known zero-height footgun |
| `ConstrainedBox` | `maxW` for readability | On phones `maxW` can be **`double.infinity`** (`_wizardContentMaxWidth`) — still OK with `SizedBox(width: vw)` |
| `Column` / `Expanded` | `Column` → `Expanded` → `LayoutBuilder` → `SingleChildScrollView` | **Bounded** height from `Expanded` — should not collapse to 0 unless parent constraint bug |
| `Flexible` | Not dominant in wizard body | — |
| `IntrinsicHeight` | Not used in audited paths | — |
| `bottomNavigationBar` | `PraniStickyActionBar` | Correct slot |
| `PageView` / `Stepper` | Not used — manual step index | — |
| `FutureBuilder` / `AsyncValue` | `districtsProvider` in address step uses `.when`; data branch `SizedBox.shrink()` | **Only address step**; step 0 does not depend on it |

### 5.3 Step 0 (`_buildStepPersonal`) — no intentional `SizedBox.shrink()` for main UI

Contains `PraniSectionHeader`, `PraniFormCard`, `PraniTextField`s, `PraniDatePartsField`, `PraniDropdownField` for gender.

**Risk — dropdown assertion / blank subtree:**

- `PraniDropdownField<String?>` gender items: `null`, `MALE`, `FEMALE`, `OTHER`, `UNKNOWN`.
- `_gender` is set from `AiTechnicianProfile.fromJson` → `p.gender`.
- If API ever returns **unexpected string** (typo, new enum, empty string stored as `""`), **`DropdownButtonFormField` value-not-in-items** can trigger **assert (debug)** or unstable behavior (release). **Verify** real `GET me` / `POST apply` payload for `gender` on fresh accounts.

### 5.4 Async / null draft

- `_bootstrap` ensures `_profile` non-null before main wizard build (or shows loading / error).
- **No** `SizedBox.shrink()` for whole step when profile null in normal flow.

### 5.5 Keyboard / `SafeArea` / `resizeToAvoidBottomInset`

- Form scaffold: **`resizeToAvoidBottomInset: false`** with explicit `_keyboardBottomForScroll` clamp (`~101–108`) — comment documents prior **zero-height body** issue when relying on scaffold resize.
- **Hypothesis:** On a **subset of devices**, if `MediaQuery` / `viewInsets` still interact badly with `bottomNavigationBar`, measure with Flutter DevTools **Layout Explorer** when IME opens on step 0.

### 5.6 Debug-only UI (release builds)

- `kDebugMode` banners in entry + form (`_debugAiFormBanner`, lime “STEP 0” strip) — **not** in release APK. User-reported “blank” on real Android is **unlikely** from these.

### 5.7 Strongest hypotheses for “blank + পরবর্তী”

1. **Runtime build failure** in step 0 subtree (dropdown value, `PraniDatePartsField`, or third-party assertion) — add **zone / FlutterError** logging already partially present in `main.dart`; reproduce on **profile** build.
2. **Paint / layer bug** (rare): `Stack` + overlay `_submitting` — only when submitting.
3. **User on intro skipped** and old route cache — low probability; `pushReplacement` from entry should clear.

**Files to modify (implementation phase):**

- `ai_technician_application_form_screen.dart` — layout hardening, **defensive normalization** for `gender` (map unknown → `null`), optional **Sentry-less** `Builder` error boundary pattern (minimal), step 0 smoke test.
- `ai_technician_models.dart` — only if normalizing enums in `fromJson`.
- `ai_technician_application_entry_screen.dart` — only if navigation race found.
- `prani_step_progress_header.dart` / `prani_sticky_action_bar.dart` — only if spacing tokens need tweak (reuse DS).

**Do not** duplicate large new wizard shells — extend existing `_wizardStepColumn` / `PraniFormCard` patterns.

---

## 6. Splash / startup blocking

- **Splash delay:** `1400 ms` **before** hydrate — extends perceived startup.
- **Hydrate failure:** caught; still navigates (onboarding vs home) — OK.
- **Image decode:** mitigated with post-frame + `cacheWidth`/`cacheHeight` — good; still optional polish (Lottie/simpler vector, or shorter copy block).

---

## 7. Implementation plan (step-by-step)

### Phase A — OTP / SnackBar UX (low risk, fast)

1. In `login_entry_screen.dart`, adjust `_snack`:
   - Use **bottom-anchored** margin: e.g. include `MediaQuery.of(context).padding.bottom` + optional `viewInsets` so snack stays **above nav/home indicator** but **below OTP** when keyboard closed; when keyboard open, prefer **dismiss previous** + `floating` margin with **non-zero top** only if needed, or **inline** success state for OTP sent.
2. Differentiate **success** (green/info tone or neutral `PraniInfoCard` inline) vs **error** (SnackBar or `PraniErrorState` compact) — reuse DS components.
3. For `OtpSendChannel.devTerminalFallback`, consider **shorter** dev-only copy + **icon**, gated on `AppConfig.isDevelopmentEnv` (not only `kDebugMode`) so **release** never shows dev terminal text.

### Phase B — AI Technician form blank (investigation-led)

1. Reproduce on **Android emulator + one physical device** with Flutter `run` + **layout overflow** paint.
2. Log **`p.gender` / `p.status`** after `apply` in debug (remove before merge or guard with `kDebugMode`).
3. Implement **dropdown safe value**: if `items` lacks `_gender`, set dropdown value to `null` once when filling profile.
4. Add **minimum body placeholder** when `stepBody` intrinsic height is suspiciously small (assert/debug only) — optional.
5. Re-test **entry → form** (prefs resume with `extra` step) and **intro → form** from intro screen button.

### Phase C — Splash polish

1. Replace fixed **1400 ms** with `Future.wait([hydrate, minDisplay])` where `minDisplay` is ~400–600 ms **cap** for brand flash.
2. Restructure layout: e.g. **top-aligned** brand block + bottom spinner, or use `PraniBoundedBrandImage`-style helper if already in codebase — **reuse** `PraniAssets` / tokens.
3. Add **`errorBuilder`** / fallback color for splash `Image.asset`.

### Phase D — Regression pass

- Existing **dashboard** users: open entry → must still reach **dashboard** without entering broken wizard.
- **Editable** correction flow: form still loads steps.

---

## 8. Risk notes

| Risk | Mitigation |
|------|------------|
| Changing SnackBar behavior affects all login messages | Scope `_snack` only; keep Bengali strings |
| `gender` normalization masks data bugs | Log once in debug; prefer backend contract alignment (mobile-only doc, no server change here) |
| Splash timing change feels “faster but flash” | A/B with `minDisplay` 500 ms |
| Over-refactoring wizard | Touch only confirmed failure paths |

---

## 9. Testing checklist (Android emulator + real device)

**OTP**

- [ ] Send OTP — success snack / inline message **does not cover** OTP field (keyboard closed).
- [ ] Open keyboard on OTP field — message position acceptable; no duplicate stacked snacks.
- [ ] Wrong code — error readable.
- [ ] Rate limit / server error — Bengali message, no English Dio leak.
- [ ] Dev build + unreachable API + `ENABLE_DEV_OTP` — fallback path understandable, not alarming in copy.

**AI Technician**

- [ ] Guest: profile tile → login prompt / redirect.
- [ ] New user: profile → AI technician entry → **form step 0** — **all fields visible**; পরবর্তী at **bottom** sticky bar.
- [ ] Resume wizard: kill app mid-form, reopen from profile — correct step, no blank.
- [ ] Existing approved user: entry → **dashboard** unchanged.
- [ ] Airplane mode on form: error / retry, not infinite loading.

**Splash**

- [ ] Cold start: no long frozen white frame; illustration appears smoothly.
- [ ] Missing asset (optional stress): graceful fallback.

---

## 10. Acceptance criteria

1. **OTP:** User always understands what happened (sent / failed / dev test) **without** mistaking feedback for a random “warning” above the OTP field; **no raw English** Dio strings.
2. **AI Technician form:** First-time path shows **full step 0** (headers + fields + cards); **পরবর্তী** remains in **bottom** sticky bar; **no regression** for dashboard / status routes.
3. **Splash:** Layout reads intentional on common phone sizes; startup does not feel **stuck** longer than necessary; asset failure does not white-screen.

---

## 11. Files reference (audit)

| Area | Files |
|------|--------|
| Splash / main | `lib/main.dart`, `lib/src/features/splash/splash_screen.dart`, `lib/src/core/assets/prani_assets.dart` |
| Router / gate | `lib/src/app/router.dart`, `lib/src/features/session/application/session_notifier.dart` |
| OTP | `login_entry_screen.dart`, `mobile_otp_auth_repository.dart`, **`otp_auth_user_messages.dart`**, `dio_provider.dart` |
| Profile entry | `lib/src/features/profile/presentation/profile_home_screen.dart`, `lib/src/features/ai_technician_application/presentation/ai_technician_entry.dart` |
| AI flow | `ai_technician_application_entry_screen.dart`, `ai_technician_intro_screen.dart`, `ai_technician_application_form_screen.dart`, `ai_technician_providers.dart`, `ai_technician_repository.dart`, `ai_technician_models.dart` |
| DS | `prani_sticky_action_bar.dart`, `prani_step_progress_header.dart`, `prani_form_card.dart`, `prani_buttons.dart`, `prani_info_card.dart` (pick existing for inline OTP success) |

---

## 12. Out of scope (explicit)

- Backend API contract / Prisma / Next.js.
- Deleting files unless later proven dead.
- New duplicate wizard frameworks.

---

## 13. Verification result (post-fix pass)

**Verification date:** 2026-05-11 (Composer Agent).

### 13.1 `flutter analyze`

- **Result:** `No issues found!` (full project).

### 13.2 `flutter test`

- **Result:** All tests passed (`5` tests: billing badge, technician AI badge ×3, widget app build).
- **Note:** Suite is small; does not cover AI wizard UI end-to-end.

### 13.3 Layout anti-pattern review (`ai_technician_application_form_screen.dart`)

| Pattern | Finding |
|---------|---------|
| `Align` inside `SingleChildScrollView` | **Read-only** branch and **wizard** scroll: `Align` is wrapped in **`SizedBox(width: double.infinity)`** with **`Alignment.topCenter`** so horizontal centering has a **bounded width**; not the “zero-height Align” footgun inside unconstrained scroll. |
| `Expanded` / `Flexible` inside scroll | **None:** wizard `Expanded` wraps **`SingleChildScrollView`**, not the reverse. |
| `Expanded` in bottom actions | Row of **পূর্ববর্তী / পরবর্তী** uses `Expanded` inside **`LayoutBuilder`** in **`PraniStickyActionBar`** (outside scroll) — OK. |
| `SizedBox.shrink` for null | **Address step:** `districtsProvider` **data** branch returns `SizedBox.shrink()` when list is ready — **intentional** (comment in code). **Image** error path uses shrink for broken preview only. |

### 13.4 Manual route checklist (code-confirmed)

| Step | Confirmed in code |
|------|-------------------|
| Profile tile → `/profile/ai-technician/entry` | `profile_home_screen.dart` pushes `AiTechnicianApplicationEntryScreen.routePath`. |
| Entry → form (new user, logged in, no profile) | `ai_technician_application_entry_screen.dart`: `pushReplacement(form, extra: 0)`. |
| Entry → dashboard (approved/published) | Same file: `pushReplacement(AiTechnicianDashboardScreen.routePath)`. |
| Guest on entry | `router.dart`: entry path **guest-accessible**; entry UI `_needsLogin` + `LoginEntryScreen` with `?next=…entry`. |
| Network / resolver error | `PraniErrorState` + **আবার চেষ্টা** → `_resolve`. |
| OTP wrong / expired | `otp_auth_user_messages.dart` + repository map **401** → Bengali; errors via `_snack` with bottom-weighted margin. |
| OTP loading | `_loginBusy` gates `_sendOtp` / `_verify`; buttons use `sendInitialInteractive` / `verifyInteractive`. |
| Form validation | `_goNext` runs `_formKey.currentState?.validate()` then `_validateStep`; `_submit` disables primary when `_submitting`. |

### 13.5 Splash / OTP UX (code-confirmed)

- **Splash:** `LayoutBuilder` + `Stack` + `ClipRect` hero; **`errorBuilder`** on assets; prefs failure → **retry** UI (not endless spinner only).
- **OTP:** SMS success = **`PraniInfoCard`** inline; dev fallback hint only if **`AppConfig.useDevOtpFallback`** (`development` + `ENABLE_DEV_OTP`); errors = **SnackBar** with padding from safe area + partial keyboard inset.

### 13.6 Remaining known issues

- **`MobileOtpAuthRepository._ensureOk`:** HTTP **200** with `ok: false` still throws **`OtpAuthException`** with server `error.message` (may be English) — not mapped by status code.
- **Professional step:** `_experienceLevelBn` vs dropdown item list could still mismatch rare persisted values (lower risk than `gender`, now normalized in **`AiTechnicianProfile.fromJson`**).

### 13.7 Next recommended command (optional)

```bash
flutter run
```

Then on a **physical Android** device: cold start splash → OTP → profile → AI Technician entry → form step 0 + bottom actions + IME.
