import 'dart:async';

import 'package:pranidoctor_mobile/src/features/service_requests/data/service_request_model.dart';
import 'package:pranidoctor_mobile/src/features/service_requests/data/service_request_repository.dart';

/// Abstraction for push / realtime updates (WebSocket, SSE, MQTT, etc.).
///
/// Default [SingleFetchLivestockBookingRealtime] emits one snapshot; swap the
/// binding in composition root when a socket client exists.
abstract class LivestockBookingRealtimePort {
  Stream<ServiceRequest> watchRequest(String id, ServiceRequestRepository repo);
}

/// One-shot fetch — safe default until realtime transport is available.
class SingleFetchLivestockBookingRealtime implements LivestockBookingRealtimePort {
  const SingleFetchLivestockBookingRealtime();

  @override
  Stream<ServiceRequest> watchRequest(String id, ServiceRequestRepository repo) {
    late final StreamController<ServiceRequest> c;
    c = StreamController(
      onListen: () async {
        try {
          c.add(await repo.getById(id));
        } catch (e, st) {
          c.addError(e, st);
        } finally {
          unawaited(c.close());
        }
      },
    );
    return c.stream;
  }
}
