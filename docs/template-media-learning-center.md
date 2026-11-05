# Template media learning and preparation center (Flutter mobile)

**Project:** Prani Doctor (`pranidoctor_mobile`)  
**Scope:** Semen catalog template detail — enterprise media hub, professional section grouping, mandatory review gates, and analytics hooks before creating a service from a template.  
**Last updated:** 2026-05-12  

---

## Goals

- Present **instructional videos**, **preparation and diagram images**, **AI guidance visuals**, **SOP / veterinary protocol PDFs**, and **breeding workflow diagrams** in a consistent, touch-friendly layout.
- Group long-form HTML into **Clinical Safety**, **Preparation**, **AI Recommendations**, **Veterinary Guidance**, **Risk Factors**, **Storage**, **Heat Detection**, and **Insemination Timing** style shells (see `TemplateProfessionalLearningSections`).
- Enforce a **minimum engagement path**: scroll depth **or** explicit “I read manually”, **warning acknowledgment** when warnings exist, and **SOP/protocol confirmation** when PDF-class media exists. Optional row for **media completion** (recommended, not blocking).
- Provide **fullscreen image preview**, **LRU byte caching** for authenticated uploads, and **debug analytics** hooks ready to wire to production telemetry.

---

## Screen integration

`AiSemenTemplateDetailScreen` composes, in order:

1. `TemplateInfoCard` — metadata summary.  
2. `TemplateLearningCenter` — media hub (videos, galleries, protocols, static prep cards).  
3. `TemplateProfessionalLearningSections` — expandable rich HTML inside `TemplateLearningSectionShell`.  
4. `TemplateClinicalAlert` — non-substitute veterinary disclaimer.  
5. `BeforeYouProceedChecklist` — gates + optional media row + future AI narration affordance.  
6. `PraniPrimaryButton` — navigates to confirm route only when `_mandatoryOk` passes.

Scroll fraction comes from a `ScrollController` on the main `ListView` (throttled updates; **55%** depth logs a one-time milestone).

---

## Reusable components

| Widget | Path | Role |
|--------|------|------|
| `TemplateLearningCenter` | `template_learning/template_learning_center.dart` | Orchestrates partitioned media + `PreparationGuideCard` horizontal strip + section shells. |
| `TemplateMediaGallery` | `template_learning/template_media_gallery.dart` | Grid of authenticated images; opens fullscreen preview. |
| `showTemplateVideoPlayerSheet` | `template_learning/template_video_player.dart` | Bottom sheet with `VideoPlayer` for upload-backed MP4; `TemplateExternalVideoLauncher` for `VIDEO_URL`. |
| `TemplateProtocolViewer` | `template_learning/template_protocol_viewer.dart` | PDF rows (external `launchUrl` or Dio + temp file + `OpenFile`); web shows unsupported snackbar. |
| `BeforeYouProceedChecklist` | `template_learning/before_you_proceed_checklist.dart` | Scroll %, manual override, warning/SOP/optional checkboxes; exposes `mandatoryOk` / `readingGateOk`. |
| `PreparationGuideCard` | `template_learning/preparation_guide_card.dart` | Compact prep tips; optional `onFutureOffline` for download queue UX. |
| `TemplateLearningSectionShell` | `template_learning/template_learning_section_shell.dart` | Card shell with icon, title, optional subtitle, `AnimatedSwitcher`. |
| `TemplateProfessionalLearningSections` | `template_learning/template_professional_learning_sections.dart` | Enterprise grouping over existing template HTML fields. |
| `TemplateFullscreenMedia` | `template_learning/template_fullscreen_media.dart` | Fullscreen `InteractiveViewer` route for images. |
| `TemplateAuthenticatedImage` | `template_learning/template_authenticated_image.dart` | Dio + cache → `Image.memory`. |
| `TemplateMediaPartition` | `template_learning/template_media_partition.dart` | Maps `SemenCatalogMediaLine.kind` into UI buckets. |
| `TemplateMediaCache` | `template_learning/template_media_cache.dart` | LRU cache of upload bytes (images / PDF / video paths). |

---

## Media partition (`kind` strings)

`TemplateMediaPartition.fromRows` recognizes (case-insensitive) kinds including:

- **Videos:** `VIDEO_URL`, `VIDEO_UPLOAD`, `INSTRUCTIONAL_VIDEO` (PDF-looking URLs are routed to protocol).  
- **Gallery / prep images:** `GALLERY`, `PREPARATION_IMAGE`.  
- **AI visuals:** `AI_GUIDANCE_IMAGE`, `AI_GUIDANCE_VISUAL`.  
- **SOP / documents:** `SOP_DOCUMENT`, `DOCUMENT_PDF`.  
- **Protocols:** `PROTOCOL_PDF`, `VETERINARY_PROTOCOL`.  
- **Diagrams:** `DIAGRAM`, `BREEDING_WORKFLOW_DIAGRAM`.  
- **Cover:** `COVER` — excluded from the learning hub (used elsewhere).

New backend enum values can be added to this mapper **without** a mobile schema migration when they arrive as new `kind` strings.

---

## Mandatory review rules

| Gate | Required when | Satisfied by |
|------|----------------|---------------|
| Reading | Always | `scrollFraction >= 0.55` **or** “manually read” checkbox. |
| Warnings | Sanitized `warningsContraindications` non-empty | Warning checkbox. |
| SOP / protocol | Any row in `sopDocuments` or `protocolPdfs` | SOP checkbox (opening a PDF is tracked separately). |
| Optional media | Never blocks CTA | Checkbox + `mediaSkipped` analytics when user unchecks after acknowledging. |

`PraniPrimaryButton` shows a snackbar when pressed while gates fail.

---

## Analytics (`TemplateLearningAnalytics`)

Debug-only `debugPrint` stubs (replace with Firebase / Segment / internal API):

- `sectionViewed`, `sectionExpanded` — professional expandables + scroll milestone id `scroll_read_threshold`.  
- `mediaCompleted`, `mediaSkipped` — gallery / video taps and optional media uncheck.  
- `warningAcknowledged` — `skipped: true` when user clears the warning box.  
- `sopConfirmed` — checklist SOP confirmation.  
- `scrollMilestone` — first crossing of depth threshold.  
- `offlineDownloadQueued` — prep card “offline soon” tap.

`TemplateProtocolViewer` emits `sectionViewed('protocol_open', …)` on PDF open.

---

## Caching and loading

- `TemplateMediaCache` stores bytes keyed by upload id with an LRU eviction policy.  
- Images and PDF flows consult the cache before network.  
- Video sheet writes a temp file after fetch; cache key `__vid_<uploadId>` stores raw bytes for reuse within the session.

---

## Mobile UX and motion

- Horizontal `PreparationGuideCard` strip for thumb reach.  
- Section shells use `AnimatedSwitcher` / `AnimatedContainer` (checklist) with `PraniDurations` curves.  
- Fullscreen media uses a dedicated route with fade + scale transition (see `template_fullscreen_media.dart`).

---

## Future support (hooks in UI)

- **Multilingual media:** partition and rows are keyed by `kind` + URLs; swap labels or load locale-specific rows when backend provides them.  
- **AI narrated tutorials:** checklist `TextButton` + `sectionViewed('ai_narration_future')` placeholder.  
- **Offline download:** `PreparationGuideCard.onFutureOffline` + `offlineDownloadQueued`; extend with background download + local vault when product is ready.

---

## Related documentation

- [Template rich renderer](./template-rich-renderer.md) — HTML sanitizer, `TemplateRichContent`, warning block, typography.
