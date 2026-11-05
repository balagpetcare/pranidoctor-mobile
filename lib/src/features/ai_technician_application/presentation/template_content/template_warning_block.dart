import 'package:flutter/material.dart';

import 'package:pranidoctor_mobile/src/features/ai_technician_application/presentation/template_content/template_clinical_alert.dart';
import 'package:pranidoctor_mobile/src/features/ai_technician_application/presentation/template_content/template_rich_content.dart';

/// Wraps [warningsContraindications] HTML in a high-visibility clinical frame.
class TemplateWarningBlock extends StatelessWidget {
  const TemplateWarningBlock({
    super.key,
    required this.rawHtml,
    required this.apiBaseUrl,
    this.imageRequestHeaders,
    this.title = 'সতর্কতা ও প্রতিবন্ধক',
  });

  final String? rawHtml;
  final String apiBaseUrl;
  final Map<String, String>? imageRequestHeaders;
  final String title;

  @override
  Widget build(BuildContext context) {
    if (rawHtml == null || rawHtml!.trim().isEmpty) {
      return const SizedBox.shrink();
    }
    return TemplateClinicalAlert(
      title: title,
      severity: TemplateClinicalSeverity.danger,
      child: TemplateRichContent(
        rawHtml: rawHtml,
        apiBaseUrl: apiBaseUrl,
        imageRequestHeaders: imageRequestHeaders,
      ),
    );
  }
}
