import 'package:pranidoctor_mobile/src/features/enterprise_media_upload/domain/media_upload_kind.dart';
import 'package:pranidoctor_mobile/src/features/enterprise_media_upload/domain/media_upload_lifecycle.dart';

/// Hook for product analytics / observability (Datadog, etc.).
abstract class MediaUploadAnalyticsPort {
  void recordEnqueue({
    required String taskId,
    required MediaUploadKind kind,
    required String purpose,
  });

  void recordLifecycle({
    required String taskId,
    required MediaUploadLifecycle lifecycle,
    double? progress,
  });

  void recordTerminal({
    required String taskId,
    required bool success,
    String? errorCode,
  });
}

class NoOpMediaUploadAnalytics implements MediaUploadAnalyticsPort {
  const NoOpMediaUploadAnalytics();

  @override
  void recordEnqueue({
    required String taskId,
    required MediaUploadKind kind,
    required String purpose,
  }) {}

  @override
  void recordLifecycle({
    required String taskId,
    required MediaUploadLifecycle lifecycle,
    double? progress,
  }) {}

  @override
  void recordTerminal({
    required String taskId,
    required bool success,
    String? errorCode,
  }) {}
}
