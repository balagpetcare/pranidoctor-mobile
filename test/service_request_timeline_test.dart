import 'package:flutter_test/flutter_test.dart';

import 'package:pranidoctor_mobile/src/features/service_requests/data/service_request_model.dart';
import 'package:pranidoctor_mobile/src/features/service_requests/domain/service_request_timeline.dart';

ServiceRequest _req({
  required ServiceRequestStatus status,
  DateTime? startedAt,
  DateTime? assignedAt,
  String? assignedDoctorId,
  String? assignedTechnicianId,
}) {
  final now = DateTime.utc(2026, 5, 9, 12);
  return ServiceRequest(
    id: 'r1',
    customerId: 'c1',
    animalId: 'a1',
    serviceCategoryId: 'sc1',
    serviceType: ServiceRequestType.DOCTOR_HOME_VISIT,
    status: status,
    submittedAt: now,
    createdAt: now,
    updatedAt: now,
    startedAt: startedAt,
    assignedAt: assignedAt,
    assignedDoctorId: assignedDoctorId,
    assignedTechnicianId: assignedTechnicianId,
  );
}

void main() {
  test('COMPLETED marks every timeline step completed', () {
    final steps = buildServiceRequestTimeline(
      _req(status: ServiceRequestStatus.COMPLETED),
    );
    expect(steps.length, kServiceRequestTimelineLabelsBn.length);
    expect(
      steps.every((s) => s.kind == RequestTimelineRowKind.completed),
      true,
    );
  });

  test('PENDING marks pending-assignment as current', () {
    final steps = buildServiceRequestTimeline(
      _req(status: ServiceRequestStatus.PENDING),
    );
    expect(steps[0].kind, RequestTimelineRowKind.completed);
    expect(steps[1].kind, RequestTimelineRowKind.current);
    expect(steps[2].kind, RequestTimelineRowKind.pending);
  });

  test('IN_PROGRESS marks treatment step current', () {
    final steps = buildServiceRequestTimeline(
      _req(status: ServiceRequestStatus.IN_PROGRESS),
    );
    expect(steps[4].kind, RequestTimelineRowKind.current);
  });

  test('CANCELLED early shows cancel marker at inferred step', () {
    final steps = buildServiceRequestTimeline(
      _req(status: ServiceRequestStatus.CANCELLED),
    );
    expect(steps[1].kind, RequestTimelineRowKind.cancelledTerminal);
    expect(steps[1].labelBn, 'বাতিল হয়েছে');
  });

  test('CANCELLED after assignment uses deeper cancel step', () {
    final steps = buildServiceRequestTimeline(
      _req(
        status: ServiceRequestStatus.CANCELLED,
        assignedAt: DateTime.utc(2026, 5, 9, 13),
        assignedDoctorId: 'd1',
      ),
    );
    expect(steps[3].kind, RequestTimelineRowKind.cancelledTerminal);
  });
}
