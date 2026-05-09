import 'package:flutter_test/flutter_test.dart';

import 'package:pranidoctor_mobile/src/features/doctor_workflow/data/doctor_case_models.dart';

void main() {
  group('DoctorIncomingRequest.fromJson', () {
    test('parses requestId and nested customer/animal', () {
      final r = DoctorIncomingRequest.fromJson({
        'requestId': 'req-1',
        'status': 'PENDING',
        'serviceTypeLabel': 'ডাক্তার — বাড়িতে পরিদর্শন',
        'isEmergency': true,
        'priority': 'urgent',
        'customer': {'displayName': 'রহিম', 'phone': '01711'},
        'animal': {'name': 'কালু', 'species': 'গরু'},
      });
      expect(r.requestId, 'req-1');
      expect(r.isEmergency, true);
      expect(r.customer.displayLineBn, contains('রহিম'));
      expect(r.animal.name, 'কালু');
    });
  });

  group('DoctorCaseDetail.fromJson', () {
    test('parses nested case and request id for actions', () {
      final d = DoctorCaseDetail.fromJson({
        'case': {
          'id': 'case-9',
          'status': 'PENDING',
          'serviceRequestId': 'sr-2',
          'animal': {'name': 'মিলি', 'species': 'ছাগল'},
        },
      });
      expect(d.caseId, 'case-9');
      expect(d.effectiveRequestIdForAcceptReject, 'sr-2');
      expect(d.canAcceptOrReject, true);
    });
  });
}
