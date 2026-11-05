import 'package:flutter/foundation.dart';

/// Analytics hooks for template learning / review flows.
///
/// Wire to Firebase / Segment / internal API in production.
abstract final class TemplateLearningAnalytics {
  static void sectionViewed(String sectionId, {String? templateId}) {
    if (kDebugMode) {
      debugPrint(
        '[template_learning] section_viewed $sectionId tpl=$templateId',
      );
    }
  }

  static void sectionExpanded(String sectionId, {String? templateId}) {
    if (kDebugMode) {
      debugPrint(
        '[template_learning] section_expanded $sectionId tpl=$templateId',
      );
    }
  }

  static void mediaCompleted(
    String mediaId,
    String kind, {
    String? templateId,
  }) {
    if (kDebugMode) {
      debugPrint(
        '[template_learning] media_completed $mediaId kind=$kind tpl=$templateId',
      );
    }
  }

  static void mediaSkipped(String mediaId, String kind, {String? templateId}) {
    if (kDebugMode) {
      debugPrint(
        '[template_learning] media_skipped $mediaId kind=$kind tpl=$templateId',
      );
    }
  }

  static void warningAcknowledged({
    required String templateId,
    bool skipped = false,
  }) {
    if (kDebugMode) {
      debugPrint(
        '[template_learning] warning_ack tpl=$templateId skipped=$skipped',
      );
    }
  }

  static void sopConfirmed({required String templateId}) {
    if (kDebugMode) {
      debugPrint('[template_learning] sop_confirmed tpl=$templateId');
    }
  }

  static void scrollMilestone(double fraction, {String? templateId}) {
    if (kDebugMode) {
      debugPrint(
        '[template_learning] scroll fraction=${fraction.toStringAsFixed(2)} tpl=$templateId',
      );
    }
  }

  /// Future: offline pack download started / finished.
  static void offlineDownloadQueued({String? templateId}) {
    if (kDebugMode) {
      debugPrint('[template_learning] offline_queued tpl=$templateId');
    }
  }
}
