import 'package:pranidoctor_mobile/src/features/ai_technician_application/data/semen_template_models.dart';

/// Groups [SemenCatalogMediaLine] rows for the learning center UI.
///
/// New Prisma enum values (e.g. `DOCUMENT_PDF`) are recognized by [kind] string
/// when the backend rolls them out — no mobile schema change required.
final class TemplateMediaPartition {
  const TemplateMediaPartition({
    required this.instructionalVideos,
    required this.preparationImages,
    required this.aiGuidanceVisuals,
    required this.sopDocuments,
    required this.protocolPdfs,
    required this.workflowDiagrams,
  });

  final List<SemenCatalogMediaLine> instructionalVideos;
  final List<SemenCatalogMediaLine> preparationImages;
  final List<SemenCatalogMediaLine> aiGuidanceVisuals;
  final List<SemenCatalogMediaLine> sopDocuments;
  final List<SemenCatalogMediaLine> protocolPdfs;
  final List<SemenCatalogMediaLine> workflowDiagrams;

  static bool _isPdfUrl(String? url) {
    if (url == null) return false;
    final u = url.trim().toLowerCase();
    return u.endsWith('.pdf') || u.contains('.pdf?');
  }

  static TemplateMediaPartition fromRows(List<SemenCatalogMediaLine> media) {
    final videos = <SemenCatalogMediaLine>[];
    final prep = <SemenCatalogMediaLine>[];
    final ai = <SemenCatalogMediaLine>[];
    final sop = <SemenCatalogMediaLine>[];
    final protocol = <SemenCatalogMediaLine>[];
    final diagrams = <SemenCatalogMediaLine>[];

    for (final m in media) {
      final k = m.kind.toUpperCase();
      if (k == 'VIDEO_URL' ||
          k == 'VIDEO_UPLOAD' ||
          k == 'INSTRUCTIONAL_VIDEO') {
        if (_isPdfUrl(m.externalUrl)) {
          protocol.add(m);
        } else {
          videos.add(m);
        }
        continue;
      }
      if (k == 'GALLERY' || k == 'PREPARATION_IMAGE') {
        prep.add(m);
        continue;
      }
      if (k == 'AI_GUIDANCE_IMAGE' || k == 'AI_GUIDANCE_VISUAL') {
        ai.add(m);
        continue;
      }
      if (k == 'SOP_DOCUMENT' || k == 'DOCUMENT_PDF') {
        sop.add(m);
        continue;
      }
      if (k == 'PROTOCOL_PDF' || k == 'VETERINARY_PROTOCOL') {
        protocol.add(m);
        continue;
      }
      if (k == 'DIAGRAM' || k == 'BREEDING_WORKFLOW_DIAGRAM') {
        diagrams.add(m);
        continue;
      }
      if (k == 'COVER') {
        continue;
      }
    }

    return TemplateMediaPartition(
      instructionalVideos: videos,
      preparationImages: prep,
      aiGuidanceVisuals: ai,
      sopDocuments: sop,
      protocolPdfs: protocol,
      workflowDiagrams: diagrams,
    );
  }

  bool get hasAnyLearningMedia =>
      instructionalVideos.isNotEmpty ||
      preparationImages.isNotEmpty ||
      aiGuidanceVisuals.isNotEmpty ||
      sopDocuments.isNotEmpty ||
      protocolPdfs.isNotEmpty ||
      workflowDiagrams.isNotEmpty;
}
