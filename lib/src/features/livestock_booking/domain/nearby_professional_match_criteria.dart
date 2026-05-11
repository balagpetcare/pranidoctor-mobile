import 'package:pranidoctor_mobile/src/features/service_requests/data/service_request_model.dart';

/// Inputs for ranking nearby doctors / technicians (server-ready shape).
///
/// Wire coordinates when location services expose them; until then use labels.
class NearbyProfessionalMatchCriteria {
  const NearbyProfessionalMatchCriteria({
    this.latitude,
    this.longitude,
    this.districtLabel,
    this.upazilaLabel,
    this.unionOrAreaLabel,
    this.serviceRequestType,
    this.radiusKm = 25,
    this.includeEmergencyCapable = false,
  });

  final double? latitude;
  final double? longitude;
  final String? districtLabel;
  final String? upazilaLabel;
  final String? unionOrAreaLabel;
  final ServiceRequestType? serviceRequestType;
  final double radiusKm;
  final bool includeEmergencyCapable;

  bool get hasGeoPoint => latitude != null && longitude != null;
}
