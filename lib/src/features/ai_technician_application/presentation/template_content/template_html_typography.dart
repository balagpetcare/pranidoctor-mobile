import 'package:flutter/material.dart';
import 'package:flutter_html/flutter_html.dart';

import 'package:pranidoctor_mobile/src/design_system/prani_tokens.dart';

/// Typography and spacing for [Html] template bodies — tuned for BN reading,
/// enterprise hierarchy, and light/dark [ColorScheme].
abstract final class TemplateHtmlTypography {
  static Map<String, Style> stylesFor(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final body = PraniTextStyles.body(scheme, textTheme);
    final bodySmall = PraniTextStyles.bodySmall(scheme, textTheme);
    final muted = PraniTextStyles.bodyMuted(scheme, textTheme);
    final h2 = PraniTextStyles.heading(
      scheme,
      textTheme,
    ).copyWith(fontSize: 18);
    final h3 = PraniTextStyles.subheading(
      scheme,
      textTheme,
    ).copyWith(fontSize: 16.5);
    final border = scheme.outlineVariant.withValues(alpha: 0.45);
    final tableBorder = Border.all(color: border, width: 1);
    final alertInfoBg = scheme.primaryContainer.withValues(alpha: 0.55);
    final alertWarnBg = scheme.tertiaryContainer.withValues(alpha: 0.5);
    final alertDangerBg = scheme.errorContainer.withValues(alpha: 0.55);
    final alertSuccessBg = scheme.secondaryContainer.withValues(alpha: 0.45);

    Style blockSpacing({double bottom = 10}) =>
        Style(margin: Margins.only(bottom: bottom));

    return {
      'body': Style(
        margin: Margins.zero,
        fontSize: FontSize(16, Unit.px),
        lineHeight: LineHeight.number(1.45),
        color: scheme.onSurface,
        fontFamilyFallback: PraniTextStyles.kFontFallback,
      ),
      'p': Style.fromTextStyle(body).merge(blockSpacing(bottom: 10)),
      'h1': Style.fromTextStyle(
        PraniTextStyles.pageTitleProminent(scheme, textTheme),
      ).merge(blockSpacing(bottom: 12)),
      'h2': Style.fromTextStyle(h2).merge(blockSpacing(bottom: 10)),
      'h3': Style.fromTextStyle(h3).merge(blockSpacing(bottom: 8)),
      'h4': Style.fromTextStyle(h3).merge(blockSpacing(bottom: 8)),
      'ul': Style(
        margin: Margins.only(bottom: 12, top: 4),
        padding: HtmlPaddings.only(left: 20, top: 2, bottom: 2),
      ),
      'ol': Style(
        margin: Margins.only(bottom: 12, top: 4),
        padding: HtmlPaddings.only(left: 20, top: 2, bottom: 2),
      ),
      'li': Style.fromTextStyle(
        body,
      ).merge(Style(margin: Margins.only(bottom: 6))),
      'a': Style(
        color: scheme.primary,
        textDecoration: TextDecoration.underline,
        fontWeight: FontWeight.w600,
      ),
      'strong': Style(fontWeight: FontWeight.w700, color: scheme.onSurface),
      'b': Style(fontWeight: FontWeight.w700, color: scheme.onSurface),
      'em': Style(fontStyle: FontStyle.italic),
      'i': Style(fontStyle: FontStyle.italic),
      'u': Style(textDecoration: TextDecoration.underline),
      's': Style(textDecoration: TextDecoration.lineThrough),
      'blockquote': Style(
        margin: Margins.only(bottom: 12, top: 4),
        padding: HtmlPaddings.symmetric(horizontal: 12, vertical: 10),
        border: Border(left: BorderSide(color: scheme.primary, width: 4)),
        backgroundColor: scheme.surfaceContainerHighest.withValues(alpha: 0.55),
      ).merge(Style.fromTextStyle(body)),
      'hr': Style(
        margin: Margins.symmetric(vertical: 14),
        border: Border(bottom: BorderSide(color: border, width: 1)),
      ),
      'table': Style(
        margin: Margins.only(bottom: 14, top: 6),
        border: tableBorder,
      ),
      'thead': Style(
        backgroundColor: scheme.surfaceContainerHighest.withValues(alpha: 0.65),
      ),
      'th': Style.fromTextStyle(bodySmall).merge(
        Style(
          border: tableBorder,
          padding: HtmlPaddings.symmetric(horizontal: 8, vertical: 8),
          fontWeight: FontWeight.w700,
        ),
      ),
      'td': Style.fromTextStyle(bodySmall).merge(
        Style(
          border: tableBorder,
          padding: HtmlPaddings.symmetric(horizontal: 8, vertical: 8),
        ),
      ),
      'caption': Style.fromTextStyle(muted).merge(
        Style(margin: Margins.only(bottom: 6), textAlign: TextAlign.start),
      ),
      'div.pd-alert-info': Style(
        margin: Margins.only(bottom: 12),
        padding: HtmlPaddings.symmetric(horizontal: 12, vertical: 10),
        backgroundColor: alertInfoBg,
        border: Border.all(color: scheme.primary.withValues(alpha: 0.35)),
      ).merge(Style.fromTextStyle(body)),
      'div.pd-alert-warning': Style(
        margin: Margins.only(bottom: 12),
        padding: HtmlPaddings.symmetric(horizontal: 12, vertical: 10),
        backgroundColor: alertWarnBg,
        border: Border.all(color: scheme.tertiary.withValues(alpha: 0.4)),
      ).merge(Style.fromTextStyle(body)),
      'div.pd-alert-danger': Style(
        margin: Margins.only(bottom: 12),
        padding: HtmlPaddings.symmetric(horizontal: 12, vertical: 10),
        backgroundColor: alertDangerBg,
        border: Border.all(color: scheme.error.withValues(alpha: 0.35)),
      ).merge(Style.fromTextStyle(body)),
      'div.pd-alert-success': Style(
        margin: Margins.only(bottom: 12),
        padding: HtmlPaddings.symmetric(horizontal: 12, vertical: 10),
        backgroundColor: alertSuccessBg,
        border: Border.all(color: scheme.secondary.withValues(alpha: 0.35)),
      ).merge(Style.fromTextStyle(body)),
      'p.pd-alert-info': Style(
        margin: Margins.only(bottom: 12),
        padding: HtmlPaddings.symmetric(horizontal: 12, vertical: 10),
        backgroundColor: alertInfoBg,
      ).merge(Style.fromTextStyle(body)),
      'p.pd-alert-warning': Style(
        margin: Margins.only(bottom: 12),
        padding: HtmlPaddings.symmetric(horizontal: 12, vertical: 10),
        backgroundColor: alertWarnBg,
      ).merge(Style.fromTextStyle(body)),
      'p.pd-alert-danger': Style(
        margin: Margins.only(bottom: 12),
        padding: HtmlPaddings.symmetric(horizontal: 12, vertical: 10),
        backgroundColor: alertDangerBg,
      ).merge(Style.fromTextStyle(body)),
      'blockquote.pd-alert-warning': Style(
        border: Border(left: BorderSide(color: scheme.tertiary, width: 4)),
        backgroundColor: alertWarnBg,
      ).merge(Style.fromTextStyle(body)),
      'blockquote.pd-alert-danger': Style(
        border: Border(left: BorderSide(color: scheme.error, width: 4)),
        backgroundColor: alertDangerBg,
      ).merge(Style.fromTextStyle(body)),
      'blockquote.pd-alert-info': Style(
        border: Border(left: BorderSide(color: scheme.primary, width: 4)),
        backgroundColor: alertInfoBg,
      ).merge(Style.fromTextStyle(body)),
    };
  }
}
