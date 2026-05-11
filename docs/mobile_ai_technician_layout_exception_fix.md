# AI Technician application form — layout exception / blank body fix

## Root cause

On Android, the editable wizard body lived under a **`SingleChildScrollView`** whose direct scroll child used **`SizedBox(width: double.infinity)` + `Align(alignment: Alignment.topCenter)`** (and related patterns) around the step column. Inside a vertical scroll view, the **main-axis maximum height is unbounded**. **`Align` / `Center`** participate in loose height layout for their child; on some devices this subtree could resolve to **effectively zero height** for the step content while the **bottom action bar** (e.g. **পরবর্তী**) still painted — matching the “white screen + green button only” symptom and stack traces involving **`LayoutBuilder.performLayout`** during layout flush.

Secondary risk: **`LayoutBuilder`** wrapping the scroll region tied step sizing to callbacks in a slot that already had fragile vertical constraints when combined with **`resizeToAvoidBottomInset`** and large IME insets.

## Anti-patterns removed

- **`Align` / `Center` as the root of scrollable wizard content** (replaced with **`Column(crossAxisAlignment: CrossAxisAlignment.stretch)`** + width **`ConstrainedBox`** where needed).
- **`LayoutBuilder` around the main `SingleChildScrollView`** body (removed from the scroll slot).
- **`PraniStickyActionBar` inside the scrollable body column** for primary navigation — actions moved to **`Scaffold.bottomNavigationBar`** with bounded **`LayoutBuilder`** + **`ConstrainedBox`** only for the bar width.

## Final layout structure (editable wizard)

- **`Scaffold`** with **`resizeToAvoidBottomInset: false`** and keyboard space handled via **scroll bottom padding** (`_keyboardBottomForScroll(context) + 120`).
- **`body`**: **`SafeArea(bottom: false)` → `Column` → `Expanded` → `SingleChildScrollView` → `Column`** (step header + **`Form` / `stepBody`**). No **`Expanded`/`Flexible`/`Spacer`** inside the scroll view’s inner column beyond normal non-flex children.
- **`bottomNavigationBar`**: **`Material` → `SafeArea` → `Padding` → `LayoutBuilder` → `Center` → `ConstrainedBox` → `_buildBottomActions`** (prev / next / submit).
- **Read-only** branch: same idea — no **`Align`** root inside **`SingleChildScrollView`**; **`Column` + `ConstrainedBox`**.

## Files changed

- `lib/src/features/ai_technician_application/presentation/ai_technician_application_form_screen.dart` — stable scaffold/body/bottom bar; **`_wizardStepColumn`** comment + no center/align root; read-only layout alignment; removed unused **`prani_sticky_action_bar`** import; **`kDebugMode`** layout log (route, step, profile, status, step body type, load error, submitting, nav saving, content width, scroll padding).

## Route flow (high level)

1. User opens AI Technician flow from profile / home entry resolver.
2. **`AiTechnicianApplicationEntryScreen`** (or equivalent resolver) routes **new / editable** applicants to **`AiTechnicianApplicationFormScreen`** (step from route `extra` or default 0).
3. **Existing approved / non-editable** technician continues to **`AiTechnicianDashboardScreen`** (unchanged by this fix).

## Debug logging (temporary, debug only)

When **`kDebugMode`**, the form prints one line including: URI, step index, **`profile` non-null**, **`status`**, **`stepBody` runtimeType**, load error flag, **`_submitting` / `_navSaving`**, **`contentMaxW`**, **`scrollBottomPad`**.

## Verification

### `flutter analyze`

Run in repo root: `flutter analyze` — **No issues found** (after `flutter pub get`).

### `flutter test`

Run: `flutter test` — **All tests passed** (5 tests: billing payment summary widget, technician AI badge, widget_test app builds).

Note: first analyzer run without resolved packages reported spurious `uri_does_not_exist` errors; use `flutter pub get` before CI/local analyze.

### Manual test checklist (Android device)

1. Fresh install or cleared app data; **OTP login**.
2. Open **profile** → **AI Technician application / create**.
3. Entry resolver runs → **new user** lands on **application form**, **step 0** visible (headers, fields, cards — not blank).
4. **পরবর্তী** appears in the **bottom** bar (not as the only “body” content).
5. **Next / previous** preserves field values; validation still blocks bad steps.
6. **Existing technician** still opens **dashboard**, not a broken form.

## Remaining risks

- **`_buildBottomActions`** still uses an inner **`LayoutBuilder`** for narrow-width stacked buttons; constraints come from **`ConstrainedBox(maxWidth: …)`** in the bottom bar — should remain bounded. If a future change removes that **`ConstrainedBox`**, re-verify bar layout.
- **`kDebugMode`** banners (`_debugAiFormBanner`, step 0 lime banner) should not ship to production verbosity; they are gated and harmless but can be removed when stable.
