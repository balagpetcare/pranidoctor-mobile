# Prani Doctor Mobile — Task Workflow Rules

These rules apply to **every** Cursor task that changes the Prani Doctor (`pranidoctor_mobile`) Flutter app. They keep work reviewable, Bengali-first, and aligned with the page-by-page plan in `MOBILE_PAGE_TASK_INDEX.md`.

---

## 1. Branch and sync

1. **Always pull the latest `main`** (or the agreed integration branch) before starting work on a task.
2. **Create a separate Git branch per task** — one branch maps to one task id (e.g. `M04-customer-home-ui`). Do not accumulate unrelated changes on one branch.
3. **Rebase or merge `main` into your task branch** before opening a PR if `main` has moved significantly, so CI runs on current code.

---

## 2. Scope control

1. **Do not mix unrelated pages or features in one task.** If a change touches two task cards, split the work or finish one task before starting the other.
2. **Do not change the backend** (`pranidoctor-web` or other repos) **unless the task explicitly says so.** Mobile tasks should consume existing APIs; if an endpoint is missing, document it in the task notes and follow up with a dedicated backend task.
3. **Do not implement “everything” in one go** — follow the master plan and task index; prefer small, mergeable PRs.

---

## 3. UI and code quality

1. **Keep UI components reusable** — shared widgets under `lib/src/` (e.g. feature `widgets/` or a future `core/widgets/`) instead of duplicating large build methods across screens.
2. **Bengali-first labels** — user-visible strings default to **Bangla (bn-BD)**; English may appear for proper nouns, codes, or where product copy is English-only. Match existing screens (`home_shell_screen.dart`, `login_entry_screen.dart`).
3. **Use existing packages** when they fit (`flutter_riverpod`, `go_router`, `dio`, `flutter_secure_storage`, `shared_preferences`, `intl`). **Do not add a new dependency** without a short justification in the PR/commit message and confirmation it is maintained and license-compatible.

---

## 4. Verification before “done”

1. Run **`flutter pub get`** if `pubspec.yaml` or lockfiles changed.
2. Run **`flutter analyze`** — **zero analyzer issues** in touched packages (warnings treated as fix or suppress with team agreement only).
3. Run **`flutter test`** — all tests must pass; add/update tests when the task changes behavior that is testable without a device farm.
4. **Manual smoke** on one target (e.g. Android emulator): cold start, navigate into the changed screen(s), and verify loading/error/empty states if applicable.

---

## 5. Commits and PRs

1. **Commit with clear messages** — imperative mood, scope implied or stated (e.g. `M07: align booking step chips with design system`).
2. PR description should state **task id** (e.g. M07), **what changed**, and **how to verify** (commands + short manual steps).

---

## 6. Documentation

1. **Update task-relevant docs** only when the task explicitly includes doc updates (e.g. API map when endpoints change). Do not rewrite unrelated planning files in the same PR as UI tweaks.

---

## 7. Project isolation

1. This repository is **only** Prani Doctor / Animal Doctors mobile. **Do not** import patterns, env names, or product copy from other products (BPA/WPA, Quarbani, etc.) unless explicitly requested in the task.

---

## Quick checklist (copy for PRs)

- [ ] Pulled latest `main` (or integration branch) before branch work  
- [ ] Branch name matches task (see `MOBILE_PAGE_TASK_INDEX.md`)  
- [ ] Single-task scope; no unrelated files  
- [ ] No backend changes unless task says so  
- [ ] `flutter analyze` clean  
- [ ] `flutter test` passing  
- [ ] Bengali-first copy where users read text  
- [ ] Clear commit message(s)
