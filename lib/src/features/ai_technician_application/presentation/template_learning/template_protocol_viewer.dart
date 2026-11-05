import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:open_filex/open_filex.dart';
import 'package:path_provider/path_provider.dart';
import 'package:url_launcher/url_launcher.dart';

import 'package:pranidoctor_mobile/src/core/network/api_client.dart';
import 'package:pranidoctor_mobile/src/design_system/prani_tokens.dart';
import 'package:pranidoctor_mobile/src/features/ai_technician_application/data/semen_template_models.dart';
import 'package:pranidoctor_mobile/src/features/ai_technician_application/presentation/template_learning/template_learning_analytics.dart';
import 'package:pranidoctor_mobile/src/features/ai_technician_application/presentation/template_learning/template_media_cache.dart';

/// Lists SOP / protocol PDF entries (external URL or authenticated upload).
class TemplateProtocolViewer extends ConsumerWidget {
  const TemplateProtocolViewer({
    super.key,
    required this.items,
    required this.title,
    required this.templateId,
    required this.onSopOpened,
  });

  final List<SemenCatalogMediaLine> items;
  final String title;
  final String templateId;
  final VoidCallback onSopOpened;

  static bool _isPdf(SemenCatalogMediaLine m) {
    final u = m.externalUrl?.trim().toLowerCase() ?? '';
    return u.endsWith('.pdf') ||
        u.contains('.pdf?') ||
        m.kind.toUpperCase().contains('PDF') ||
        m.kind.toUpperCase().contains('SOP') ||
        m.kind.toUpperCase().contains('PROTOCOL') ||
        m.kind.toUpperCase().contains('DOCUMENT');
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final rows = items.where(_isPdf).toList();
    if (rows.isEmpty) return const SizedBox.shrink();

    final scheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: PraniTextStyles.subheading(
            scheme,
            textTheme,
          ).copyWith(fontSize: 16),
        ),
        const SizedBox(height: PraniSpacing.sm),
        ...rows.map(
          (m) => ListTile(
            contentPadding: EdgeInsets.zero,
            leading: Icon(Icons.picture_as_pdf_rounded, color: scheme.error),
            title: Text(
              m.externalUrl?.isNotEmpty == true
                  ? 'প্রোটোকল (লিঙ্ক)'
                  : 'প্রোটোকল (ফাইল)',
            ),
            subtitle: Text(
              m.externalUrl ?? m.uploadedFileId ?? '',
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: PraniTextStyles.caption(scheme, textTheme),
            ),
            onTap: () async {
              onSopOpened();
              TemplateLearningAnalytics.sectionViewed(
                'protocol_open',
                templateId: templateId,
              );
              if (m.externalUrl != null && m.externalUrl!.trim().isNotEmpty) {
                final uri = Uri.tryParse(m.externalUrl!.trim());
                if (uri != null && await canLaunchUrl(uri)) {
                  await launchUrl(uri, mode: LaunchMode.externalApplication);
                }
                return;
              }
              final id = m.uploadedFileId?.trim();
              if (id == null || id.isEmpty) return;
              if (kIsWeb) {
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('ওয়েবে PDF খোলা সমর্থিত নয়'),
                    ),
                  );
                }
                return;
              }
              await _openUploadedPdf(context, ref, id);
            },
          ),
        ),
      ],
    );
  }

  static Future<void> _openUploadedPdf(
    BuildContext context,
    WidgetRef ref,
    String uploadId,
  ) async {
    try {
      final cached = TemplateMediaCache.instance.get(uploadId);
      Uint8List bytes;
      if (cached != null) {
        bytes = cached;
      } else {
        final dio = ref.read(apiClientProvider).dio;
        final res = await dio.get<List<int>>(
          'api/mobile/uploads/$uploadId',
          options: Options(
            responseType: ResponseType.bytes,
            headers: <String, dynamic>{
              Headers.acceptHeader: 'application/pdf,*/*',
            },
          ),
        );
        if ((res.statusCode ?? 0) < 200 ||
            (res.statusCode ?? 0) >= 300 ||
            res.data == null) {
          return;
        }
        bytes = Uint8List.fromList(res.data!);
        TemplateMediaCache.instance.put(uploadId, bytes);
      }
      final dir = await getTemporaryDirectory();
      final f = File('${dir.path}/protocol_$uploadId.pdf');
      await f.writeAsBytes(bytes, flush: true);
      await OpenFilex.open(f.path);
    } catch (_) {
      if (context.mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('PDF খোলা যায়নি')));
      }
    }
  }
}
