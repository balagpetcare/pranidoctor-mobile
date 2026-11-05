import 'package:flutter/material.dart';
import 'package:flutter_html/flutter_html.dart';
// ignore: implementation_imports — [ImageBuiltIn] is not exported from the public API.
import 'package:flutter_html/src/builtins/image_builtin.dart';
import 'package:url_launcher/url_launcher.dart';

import 'package:pranidoctor_mobile/src/features/ai_technician_application/presentation/template_content/template_html_sanitizer.dart';
import 'package:pranidoctor_mobile/src/features/ai_technician_application/presentation/template_content/template_html_typography.dart';

/// Renders sanitized admin HTML with Prani typography — never shows raw tags.
class TemplateRichContent extends StatelessWidget {
  const TemplateRichContent({
    super.key,
    required this.rawHtml,
    required this.apiBaseUrl,
    this.imageRequestHeaders,
    this.shrinkWrap = true,
  });

  final String? rawHtml;
  final String apiBaseUrl;
  final Map<String, String>? imageRequestHeaders;
  final bool shrinkWrap;

  @override
  Widget build(BuildContext context) {
    final sanitized = TemplateHtmlSanitizer.sanitize(
      rawHtml,
      apiBaseUrl: apiBaseUrl,
    );
    if (sanitized.isEmpty) {
      return const SizedBox.shrink();
    }

    final extensions = <HtmlExtension>[
      if (imageRequestHeaders != null && imageRequestHeaders!.isNotEmpty)
        ImageBuiltIn(networkHeaders: imageRequestHeaders),
    ];

    return Html(
      data: sanitized,
      shrinkWrap: shrinkWrap,
      style: TemplateHtmlTypography.stylesFor(context),
      extensions: extensions,
      onLinkTap: (url, _, _) async {
        if (url == null || url.isEmpty) return;
        final uri = Uri.tryParse(url);
        if (uri == null) return;
        final ok = await canLaunchUrl(uri);
        if (ok) {
          await launchUrl(uri, mode: LaunchMode.externalApplication);
        }
      },
    );
  }
}
