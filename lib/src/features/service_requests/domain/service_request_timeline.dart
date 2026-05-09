import 'package:pranidoctor_mobile/src/features/service_requests/data/service_request_model.dart';

/// Visual state for one row in the customer-facing status timeline (M08).
enum RequestTimelineRowKind { completed, current, pending, cancelledTerminal }

class RequestTimelineStep {
  const RequestTimelineStep({required this.labelBn, required this.kind});

  final String labelBn;
  final RequestTimelineRowKind kind;
}

/// Ordered Bangla labels for the standard happy path (before completion).
const List<String> kServiceRequestTimelineLabelsBn = [
  'জমা হয়েছে',
  'নিয়োগের অপেক্ষায়',
  'গ্রহণ হয়েছে',
  'পথে',
  'চিকিৎসা চলছে',
  'সম্পন্ন',
];

/// Builds timeline rows from API status + timestamps (no backend changes).
List<RequestTimelineStep> buildServiceRequestTimeline(ServiceRequest r) {
  final terminalCancelled =
      r.status == ServiceRequestStatus.CANCELLED ||
      r.status == ServiceRequestStatus.REJECTED;

  if (terminalCancelled) {
    return _timelineCancelled(r);
  }

  if (r.status == ServiceRequestStatus.COMPLETED) {
    return List<RequestTimelineStep>.generate(
      kServiceRequestTimelineLabelsBn.length,
      (i) => RequestTimelineStep(
        labelBn: kServiceRequestTimelineLabelsBn[i],
        kind: RequestTimelineRowKind.completed,
      ),
    );
  }

  final active = _activeStepIndex(r.status);
  return List<RequestTimelineStep>.generate(
    kServiceRequestTimelineLabelsBn.length,
    (i) {
      RequestTimelineRowKind kind;
      if (i < active) {
        kind = RequestTimelineRowKind.completed;
      } else if (i == active) {
        kind = RequestTimelineRowKind.current;
      } else {
        kind = RequestTimelineRowKind.pending;
      }
      return RequestTimelineStep(
        labelBn: kServiceRequestTimelineLabelsBn[i],
        kind: kind,
      );
    },
  );
}

/// Active step index aligned with [kServiceRequestTimelineLabelsBn].
int _activeStepIndex(ServiceRequestStatus s) {
  return switch (s) {
    ServiceRequestStatus.PENDING => 1,
    ServiceRequestStatus.ACCEPTED => 2,
    ServiceRequestStatus.ASSIGNED => 3,
    ServiceRequestStatus.IN_PROGRESS => 4,
    ServiceRequestStatus.COMPLETED => kServiceRequestTimelineLabelsBn.length,
    ServiceRequestStatus.CANCELLED || ServiceRequestStatus.REJECTED => 0,
  };
}

List<RequestTimelineStep> _timelineCancelled(ServiceRequest r) {
  final cancelAt = _cancelAtStepIndex(r);
  final out = <RequestTimelineStep>[];

  for (var i = 0; i < kServiceRequestTimelineLabelsBn.length; i++) {
    RequestTimelineRowKind kind;
    if (i < cancelAt) {
      kind = RequestTimelineRowKind.completed;
    } else if (i == cancelAt) {
      kind = RequestTimelineRowKind.cancelledTerminal;
    } else {
      kind = RequestTimelineRowKind.pending;
    }

    final defaultLabel = kServiceRequestTimelineLabelsBn[i];
    final labelBn =
        kind == RequestTimelineRowKind.cancelledTerminal &&
            r.status == ServiceRequestStatus.REJECTED
        ? 'প্রত্যাখ্যান হয়েছে'
        : kind == RequestTimelineRowKind.cancelledTerminal &&
              r.status == ServiceRequestStatus.CANCELLED
        ? 'বাতিল হয়েছে'
        : defaultLabel;

    out.add(RequestTimelineStep(labelBn: labelBn, kind: kind));
  }
  return out;
}

int _cancelAtStepIndex(ServiceRequest r) {
  if (r.startedAt != null) return 4;
  if (r.assignedAt != null ||
      (r.assignedDoctorId?.trim().isNotEmpty ?? false) ||
      (r.assignedTechnicianId?.trim().isNotEmpty ?? false)) {
    return 3;
  }
  return 1;
}
