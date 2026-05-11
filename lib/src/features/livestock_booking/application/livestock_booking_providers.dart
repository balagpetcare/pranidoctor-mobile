import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:pranidoctor_mobile/src/features/livestock_booking/application/livestock_booking_realtime_port.dart';
import 'package:pranidoctor_mobile/src/features/livestock_booking/domain/livestock_booking_phase.dart';
import 'package:pranidoctor_mobile/src/features/livestock_booking/domain/service_request_booking_mapper.dart';
import 'package:pranidoctor_mobile/src/features/service_requests/application/service_requests_providers.dart';
import 'package:pranidoctor_mobile/src/features/service_requests/data/service_request_model.dart';

final livestockBookingRealtimePortProvider =
    Provider<LivestockBookingRealtimePort>(
  (_) => const SingleFetchLivestockBookingRealtime(),
);

/// Emits at least one [ServiceRequest]; replace [LivestockBookingRealtimePort]
/// with a socket-backed implementation for continuous updates.
final livestockServiceRequestLiveProvider = StreamProvider.autoDispose
    .family<ServiceRequest, String>((ref, id) {
  final repo = ref.watch(serviceRequestRepositoryProvider);
  final port = ref.watch(livestockBookingRealtimePortProvider);
  return port.watchRequest(id, repo);
});

final livestockBookingPhaseForRequestIdProvider = Provider.autoDispose
    .family<AsyncValue<LivestockBookingPhase>, String>((ref, id) {
  final live = ref.watch(livestockServiceRequestLiveProvider(id));
  return live.when(
    data: (r) => AsyncData(livestockBookingPhaseFor(r)),
    loading: () => const AsyncLoading(),
    error: (e, st) => AsyncValue.error(e, st),
  );
});

List<ServiceRequest> livestockBookingActiveRequests(List<ServiceRequest> all) {
  return all
      .where((r) => livestockBookingPhaseIsActive(livestockBookingPhaseFor(r)))
      .toList();
}

List<ServiceRequest> livestockBookingHistoryRequests(List<ServiceRequest> all) {
  return all
      .where((r) => !livestockBookingPhaseIsActive(livestockBookingPhaseFor(r)))
      .toList();
}
