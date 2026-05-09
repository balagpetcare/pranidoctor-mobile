import 'package:flutter_test/flutter_test.dart';
import 'package:pranidoctor_mobile/src/features/service_requests/data/service_request_model.dart';
import 'package:pranidoctor_mobile/src/features/service_requests/domain/booking_submit_helpers.dart';

void main() {
  group('bookingLocationTextForSubmit', () {
    test('ashulia preset without detail still yields location text', () {
      expect(
        bookingLocationTextForSubmit(
          serviceType: ServiceRequestType.DOCTOR_HOME_VISIT,
          selectedAreaSlug: BookingAreaPresets.ashuliaSlug,
          locationDetailTrimmed: '',
        ),
        'এলাকা: আশুলিয়া ইউনিয়ন',
      );
    });

    test('custom area uses detail only', () {
      expect(
        bookingLocationTextForSubmit(
          serviceType: ServiceRequestType.AI_SERVICE,
          selectedAreaSlug: '',
          locationDetailTrimmed: 'গ্রাম খাজাবাগ',
        ),
        'গ্রাম খাজাবাগ',
      );
    });
  });

  group('bookingNeedsGeo', () {
    test('online consultation does not require geo', () {
      expect(
        bookingNeedsGeo(ServiceRequestType.ONLINE_CONSULTATION_LATER),
        false,
      );
    });

    test('home visit requires geo flag', () {
      expect(bookingNeedsGeo(ServiceRequestType.DOCTOR_HOME_VISIT), true);
    });
  });
}
