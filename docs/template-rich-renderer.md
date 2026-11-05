# Template rich renderer (Flutter mobile)

**Project:** Prani Doctor (`pranidoctor_mobile`)  
**Scope:** Semen service template detail — HTML authored in admin (Tiptap), consumed safely on technician devices.  
**Last updated:** 2026-05-12  

---

## Goals

- Render **paragraphs, headings, lists, emphasis, tables, blockquotes, and alert callouts** without ever showing **raw HTML tags** in the UI.
- Apply a **defense-in-depth sanitizer** before `flutter_html` parses content.
- Use **Bearer-authenticated** image requests for `/api/mobile/uploads/:id` embedded in HTML or loaded as cover/gallery/video.
- Provide **enterprise hierarchy**, **readable spacing**, and **light/dark** compatibility via `ColorScheme` + `PraniTextStyles`.

---

## Package dependencies

| Package | Role |
|---------|------|
| `flutter_html` ^3.0.0 | Renders sanitized HTML into Flutter layout (`Html` widget, `Style` map, `ImageBuiltIn` for network images + headers). |
| `html` ^0.15.6 | DOM parse + tree walk for sanitization. |
| `video_player` (existing) | In-sheet playback for `VIDEO_UPLOAD` after a one-shot download to a temp `.mp4` file. |
| `path_provider` (existing) | Temp directory for video bytes. |

---

## File map

| File | Responsibility |
|------|----------------|
| `template_html_sanitizer.dart` | Whitelist tags/attrs, strip scripts/event handlers, normalize `/api/admin/uploads/` → `/api/mobile/uploads/`, absolutize relative `/api/...` URLs with `apiBaseUrl`, unwrap unknown tags, escape plain text without markup. |
| `template_html_typography.dart` | Builds `Map<String, Style>` for `Html` (body, headings, lists, tables, `blockquote`, `hr`, and `*.pd-alert-*` selectors). |
| `template_rich_content.dart` | `TemplateHtmlSanitizer.sanitize` → `Html` + link launcher + optional `ImageBuiltIn(networkHeaders: …)`. |
| `template_warning_block.dart` | Wraps warnings HTML in `TemplateClinicalAlert` (danger severity) + `TemplateRichContent`. |
| `template_clinical_alert.dart` | Flutter-native alert (icon, title, semantic container) for non-HTML notices. |
| `template_info_card.dart` | Template metadata summary (provider, animal type BN label, semen kind, breed line, default price). |
| `expandable_content_section.dart` | `ExpansionTile`-based professional sections (collapsed by default except where overridden). |
| `template_detail_skeleton.dart` | Lightweight bone layout during initial fetch. |
| `template_media_strip.dart` | Cover + horizontal gallery (`dio` bytes → `Image.memory`), external video URL launcher, upload video bottom sheet player. |
| `ai_semen_template_detail_screen.dart` | Composes the above with Riverpod + access token for image headers. |

---

## Sanitization rules (summary)

**Allowed tags:** `p, br, strong, b, em, i, u, s, h1–h4, ul, ol, li, a, span, blockquote, table, thead, tbody, tfoot, tr, th, td, caption, colgroup, col, div, img, hr`.

**Removed entirely:** `script, style, iframe, object, embed, link, meta, base, form, input, button, textarea, select, option`.

**Attributes:** Global strip of `on*`, `style`, `id`. `a`: `href` (http/https/relative `/` or `#fragment` only), `title`, `target`, `rel`. `img`: `src`, `alt`, `width`, `height`. Table cells: `colspan`, `rowspan`, `align` (bounded). `class` only when token is one of: `pd-alert-info`, `pd-alert-warning`, `pd-alert-danger`, `pd-alert-success` on `p`, `blockquote`, `div`, `span` (spans with no class after filtering are unwrapped).

**Admin HTML → mobile uploads:** Relative `src`/`href` under `/api/admin/uploads/` are rewritten to `/api/mobile/uploads/` before absolutizing, so technician tokens can fetch the same `UploadedFile` rows when the API allows it.

---

## Admin authoring: alert callouts

To render **colored alert boxes** on mobile, editors may wrap copy in a `div` or `p` with one of the classes above, for example:

```html
<div class="pd-alert-warning">গরুর গর্ভাবস্থা যাচাই করুন…</div>
```

`flutter_html` matches CSS selectors in the style map (e.g. `div.pd-alert-warning`).

---

## Performance & UX notes

- `Html` uses `shrinkWrap: true` so it nests inside `ListView` without unbounded height issues.
- Sanitization runs on every `_hasRenderableHtml` check in the detail screen; keep payloads reasonable or memoize if profiling shows jank.
- Gallery images load via `dio` bytes (no `Image.network` auth header mismatch).
- Video upload preview writes a temp file per open; the OS clears temp storage periodically.

---

## Related backend

- Admin sanitizer: `pranidoctor-web/src/lib/sanitize-admin-html.ts` (DOMPurify allowlist). Mobile sanitizer is **aligned** but not identical (extra table tags + alert classes + URL rewrite).

---

## Future work

- Server endpoint returning **pre-sanitized mobile HTML** to avoid duplicate policy drift.
- Structured `warnings[]` rows (severity) instead of a single HTML blob.
- Optional `cached_network_image` + disk cache for template media.
