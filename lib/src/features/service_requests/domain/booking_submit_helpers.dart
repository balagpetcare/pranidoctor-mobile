import 'package:pranidoctor_mobile/src/features/providers/data/provider_kind.dart';
import 'package:pranidoctor_mobile/src/features/service_requests/data/service_request_model.dart';
import 'package:pranidoctor_mobile/src/features/service_requests/domain/booking_urgency.dart';

/// Known area presets for UX (slug aligns with provider finder filter).
abstract final class BookingAreaPresets {
  static const String ashuliaSlug = 'ashulia-union-area';

  static const List<({String slug, String labelBn})> choices = [
    (slug: ashuliaSlug, labelBn: 'আশুলিয়া ইউনিয়ন'),
    (slug: '', labelBn: 'অন্যান্য / নিজে লিখুন'),
  ];
}

/// Builds [locationText] for POST — avoids fake [areaId]s (backend validates IDs).
String bookingLocationTextForSubmit({
  required ServiceRequestType serviceType,
  required String selectedAreaSlug,
  required String locationDetailTrimmed,
}) {
  final needsGeo = _needsGeo(serviceType);
  if (!needsGeo) {
    return locationDetailTrimmed.isEmpty ? '' : locationDetailTrimmed;
  }

  final presetBn =
      selectedAreaSlug.isNotEmpty &&
          selectedAreaSlug == BookingAreaPresets.ashuliaSlug
      ? 'আশুলিয়া ইউনিয়ন'
      : null;

  if (presetBn != null && locationDetailTrimmed.isNotEmpty) {
    return 'এলাকা: $presetBn — $locationDetailTrimmed';
  }
  if (presetBn != null && locationDetailTrimmed.isEmpty) {
    return 'এলাকা: $presetBn';
  }
  return locationDetailTrimmed;
}

/// True when composed location or detail satisfies “area/location” step for geo types.
bool bookingHasValidLocation({
  required ServiceRequestType serviceType,
  required String selectedAreaSlug,
  required String locationDetail,
}) {
  if (!_needsGeo(serviceType)) return true;
  final composed = bookingLocationTextForSubmit(
    serviceType: serviceType,
    selectedAreaSlug: selectedAreaSlug,
    locationDetailTrimmed: locationDetail.trim(),
  );
  return composed.trim().isNotEmpty;
}

/// Field-visit / on-site types require at least one location signal (API rule).
bool bookingNeedsGeo(ServiceRequestType t) {
  return t == ServiceRequestType.DOCTOR_HOME_VISIT ||
      t == ServiceRequestType.EMERGENCY_DOCTOR ||
      t == ServiceRequestType.AI_SERVICE;
}

bool _needsGeo(ServiceRequestType t) => bookingNeedsGeo(t);

/// Strict-schema workaround: urgency & optional provider preference go here.
String? bookingMergedDescription({
  required BookingUrgency urgency,
  String? userExtraDescription,
  String? preferredProviderName,
  ProviderKind? preferredProviderKind,
}) {
  final parts = <String>[];

  final extra = userExtraDescription?.trim();
  if (extra != null && extra.isNotEmpty) {
    parts.add(extra);
  }

  parts.add('জরুরিতা: ${urgency.labelBn}');

  if (preferredProviderName != null &&
      preferredProviderName.trim().isNotEmpty &&
      preferredProviderKind != null) {
    parts.add(
      'পছন্দের ${preferredProviderKind.labelBn}: ${preferredProviderName.trim()}',
    );
  }

  if (parts.isEmpty) return null;
  return parts.join('\n\n');
}

bool bookingShowsProviderStep(ServiceRequestType type) {
  return type == ServiceRequestType.DOCTOR_HOME_VISIT ||
      type == ServiceRequestType.EMERGENCY_DOCTOR ||
      type == ServiceRequestType.AI_SERVICE ||
      type == ServiceRequestType.ONLINE_CONSULTATION_LATER;
}
