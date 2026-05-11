import 'dart:convert';

import 'package:pranidoctor_mobile/src/features/enterprise_insights/application/offline_sync_monitoring_ports.dart';
import 'package:pranidoctor_mobile/src/features/profile/data/mobile_profile_api_contract.dart';

/// Typed helpers for repositories — enqueue REST replays without importing Dio.
///
/// Payload shape matches [ApiSyncActionExecutor] (`path`, `httpMethod`, `body`).
class ProfessionalSyncOutbox {
  ProfessionalSyncOutbox(this._sync);

  final SyncCoordinatorPort _sync;

  Future<void> enqueueProfileUpdate(Map<String, dynamic> body) async {
    await _sync.enqueue(
      resource: 'profile',
      operation: 'update',
      payloadJson: jsonEncode({
        'path': MobileProfileApiPaths.patchMeLegacy,
        'httpMethod': 'PATCH',
        'body': body,
      }),
    );
  }

  Future<void> enqueueAvailabilityChange(Map<String, dynamic> body) async {
    final path = body['path'] as String? ?? MobileProfileApiPaths.patchMeLegacy;
    await _sync.enqueue(
      resource: 'availability',
      operation: 'change',
      payloadJson: jsonEncode({
        'path': path,
        'httpMethod': 'PATCH',
        'body': body,
      }),
    );
  }

  Future<void> enqueueServiceStatusUpdate({
    required String path,
    required Map<String, dynamic> body,
  }) async {
    await _sync.enqueue(
      resource: 'service',
      operation: 'status',
      payloadJson: jsonEncode({
        'path': path,
        'httpMethod': 'PATCH',
        'body': body,
      }),
    );
  }

  Future<void> enqueueBookingDecision({
    required String path,
    required Map<String, dynamic> body,
  }) async {
    await _sync.enqueue(
      resource: 'booking',
      operation: 'decision',
      payloadJson: jsonEncode({
        'path': path,
        'httpMethod': 'POST',
        'body': body,
      }),
    );
  }

  Future<void> enqueueNotesUpload({
    required String path,
    required Map<String, dynamic> body,
  }) async {
    await _sync.enqueue(
      resource: 'notes',
      operation: 'upload',
      payloadJson: jsonEncode({
        'path': path,
        'httpMethod': 'POST',
        'body': body,
      }),
    );
  }

  Future<void> enqueueMediaUploadMetadata({
    required String path,
    required Map<String, dynamic> body,
  }) async {
    await _sync.enqueue(
      resource: 'media',
      operation: 'metadata',
      payloadJson: jsonEncode({
        'path': path,
        'httpMethod': 'POST',
        'body': body,
      }),
    );
  }

  /// Escape hatch for new APIs — caller supplies validated relative [path].
  Future<void> enqueueRawRest({
    required String resource,
    required String operation,
    required String method,
    required String path,
    Map<String, dynamic>? body,
  }) async {
    await _sync.enqueue(
      resource: resource,
      operation: operation,
      payloadJson: jsonEncode({
        'path': path,
        'httpMethod': method.toUpperCase(),
        if (body != null) 'body': body,
      }),
    );
  }
}
