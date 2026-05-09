import 'package:pranidoctor_mobile/src/features/animals/data/animal_profile_model.dart';

/// Query params for provider list APIs (omit nulls when building request).
class ProviderListQuery {
  const ProviderListQuery({
    this.areaSlug,
    this.areaId,
    this.animalType,
    this.homeVisit,
    this.emergency,
    this.onlineConsultation,
    this.serviceCategoryId,
    this.limit = 20,
    this.offset = 0,
  });

  final String? areaSlug;
  final String? areaId;
  final AnimalType? animalType;
  final bool? homeVisit;
  final bool? emergency;
  final bool? onlineConsultation;
  final String? serviceCategoryId;
  final int limit;
  final int offset;

  static const ProviderListQuery initial = ProviderListQuery();

  /// Whether any list filter differs from “all” (area/type/service toggles).
  bool get hasNonDefaultDoctorFilters {
    if (areaSlug != null && areaSlug!.trim().isNotEmpty) return true;
    if (areaId != null && areaId!.trim().isNotEmpty) return true;
    if (animalType != null) return true;
    if (homeVisit != null) return true;
    if (emergency != null) return true;
    if (onlineConsultation != null) return true;
    if (serviceCategoryId != null && serviceCategoryId!.trim().isNotEmpty) {
      return true;
    }
    return false;
  }

  Map<String, String> toQueryParameters() {
    final m = <String, String>{};
    if (areaSlug != null && areaSlug!.isNotEmpty) {
      m['areaSlug'] = areaSlug!;
    }
    if (areaId != null && areaId!.isNotEmpty) {
      m['areaId'] = areaId!;
    }
    if (animalType != null) {
      m['animalType'] = animalType!.name;
    }
    if (homeVisit != null) {
      m['homeVisit'] = homeVisit! ? 'true' : 'false';
    }
    if (emergency != null) {
      m['emergency'] = emergency! ? 'true' : 'false';
    }
    if (onlineConsultation != null) {
      m['onlineConsultation'] = onlineConsultation! ? 'true' : 'false';
    }
    if (serviceCategoryId != null && serviceCategoryId!.isNotEmpty) {
      m['serviceCategoryId'] = serviceCategoryId!;
    }
    m['limit'] = limit.clamp(1, 50).toString();
    m['offset'] = offset.toString();
    return m;
  }

  /// New query with filters changed; resets [offset] to 0 unless [keepOffset].
  ProviderListQuery withFilters({
    String? areaSlug,
    String? areaId,
    AnimalType? animalType,
    bool? homeVisit,
    bool? emergency,
    bool? onlineConsultation,
    String? serviceCategoryId,
    bool clearAreaSlug = false,
    bool clearAreaId = false,
    bool clearAnimalType = false,
    bool clearHomeVisit = false,
    bool clearEmergency = false,
    bool clearOnlineConsultation = false,
    bool clearServiceCategoryId = false,
    bool keepOffset = false,
  }) {
    var ns = clearAreaSlug ? null : (areaSlug ?? this.areaSlug);
    var ni = clearAreaId ? null : (areaId ?? this.areaId);
    if (ns != null && ns.isNotEmpty) {
      ni = null;
    } else if (ni != null && ni.isNotEmpty) {
      ns = null;
    }
    return ProviderListQuery(
      areaSlug: ns,
      areaId: ni,
      animalType: clearAnimalType ? null : (animalType ?? this.animalType),
      homeVisit: clearHomeVisit ? null : (homeVisit ?? this.homeVisit),
      emergency: clearEmergency ? null : (emergency ?? this.emergency),
      onlineConsultation: clearOnlineConsultation
          ? null
          : (onlineConsultation ?? this.onlineConsultation),
      serviceCategoryId: clearServiceCategoryId
          ? null
          : (serviceCategoryId ?? this.serviceCategoryId),
      limit: limit,
      offset: keepOffset ? offset : 0,
    );
  }
}
