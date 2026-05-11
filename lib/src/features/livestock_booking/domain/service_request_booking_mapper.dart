import 'package:pranidoctor_mobile/src/features/livestock_booking/domain/livestock_booking_phase.dart';
import 'package:pranidoctor_mobile/src/features/service_requests/data/service_request_model.dart';

/// Maps persisted API status (+ timestamps) to the canonical booking phase.
LivestockBookingPhase livestockBookingPhaseFor(ServiceRequest r) {
  switch (r.status) {
    case ServiceRequestStatus.CANCELLED:
    case ServiceRequestStatus.REJECTED:
      return LivestockBookingPhase.cancelled;
    case ServiceRequestStatus.COMPLETED:
      return LivestockBookingPhase.completed;
    case ServiceRequestStatus.IN_PROGRESS:
      if (r.startedAt != null) {
        return LivestockBookingPhase.inService;
      }
      return LivestockBookingPhase.onTheWay;
    case ServiceRequestStatus.ACCEPTED:
      return LivestockBookingPhase.accepted;
    case ServiceRequestStatus.ASSIGNED:
      return LivestockBookingPhase.assigned;
    case ServiceRequestStatus.PENDING:
      return LivestockBookingPhase.requestCreated;
  }
}

bool livestockBookingPhaseIsTerminal(LivestockBookingPhase p) =>
    p == LivestockBookingPhase.completed || p == LivestockBookingPhase.cancelled;

bool livestockBookingPhaseIsActive(LivestockBookingPhase p) =>
    !livestockBookingPhaseIsTerminal(p);

/// Vertical timeline rows derived from [ServiceRequest] fields.
List<LivestockBookingTimelineRow> buildLivestockBookingTimeline(
  ServiceRequest r,
) {
  final rows = <LivestockBookingTimelineRow>[
    LivestockBookingTimelineRow(
      phase: LivestockBookingPhase.requestCreated,
      titleBn: LivestockBookingPhase.requestCreated.labelBn,
      at: r.submittedAt,
      highlight: livestockBookingPhaseFor(r) == LivestockBookingPhase.requestCreated,
    ),
  ];

  if (r.assignedAt != null) {
    rows.add(
      LivestockBookingTimelineRow(
        phase: LivestockBookingPhase.assigned,
        titleBn: LivestockBookingPhase.assigned.labelBn,
        at: r.assignedAt,
        highlight: livestockBookingPhaseFor(r) == LivestockBookingPhase.assigned,
      ),
    );
  }

  if (r.status == ServiceRequestStatus.ACCEPTED ||
      r.status == ServiceRequestStatus.IN_PROGRESS ||
      r.status == ServiceRequestStatus.COMPLETED) {
    rows.add(
      LivestockBookingTimelineRow(
        phase: LivestockBookingPhase.accepted,
        titleBn: LivestockBookingPhase.accepted.labelBn,
        at: r.assignedAt ?? r.updatedAt,
        highlight: livestockBookingPhaseFor(r) == LivestockBookingPhase.accepted,
      ),
    );
  }

  if (r.status == ServiceRequestStatus.IN_PROGRESS && r.startedAt == null) {
    rows.add(
      LivestockBookingTimelineRow(
        phase: LivestockBookingPhase.onTheWay,
        titleBn: LivestockBookingPhase.onTheWay.labelBn,
        at: r.updatedAt,
        highlight: livestockBookingPhaseFor(r) == LivestockBookingPhase.onTheWay,
      ),
    );
  }

  if (r.startedAt != null) {
    rows.add(
      LivestockBookingTimelineRow(
        phase: LivestockBookingPhase.inService,
        titleBn: LivestockBookingPhase.inService.labelBn,
        at: r.startedAt,
        highlight: livestockBookingPhaseFor(r) == LivestockBookingPhase.inService,
      ),
    );
  }

  if (r.completedAt != null) {
    rows.add(
      LivestockBookingTimelineRow(
        phase: LivestockBookingPhase.completed,
        titleBn: LivestockBookingPhase.completed.labelBn,
        at: r.completedAt,
        highlight: livestockBookingPhaseFor(r) == LivestockBookingPhase.completed,
      ),
    );
  }

  if (r.cancelledAt != null ||
      r.status == ServiceRequestStatus.CANCELLED ||
      r.status == ServiceRequestStatus.REJECTED) {
    rows.add(
      LivestockBookingTimelineRow(
        phase: LivestockBookingPhase.cancelled,
        titleBn: r.status == ServiceRequestStatus.REJECTED
            ? 'প্রত্যাখ্যান / বাতিল'
            : LivestockBookingPhase.cancelled.labelBn,
        at: r.cancelledAt ?? r.updatedAt,
        highlight: livestockBookingPhaseFor(r) == LivestockBookingPhase.cancelled,
      ),
    );
  }

  return rows;
}

class LivestockBookingTimelineRow {
  const LivestockBookingTimelineRow({
    required this.phase,
    required this.titleBn,
    required this.at,
    this.highlight = false,
  });

  final LivestockBookingPhase phase;
  final String titleBn;
  final DateTime? at;
  final bool highlight;
}
