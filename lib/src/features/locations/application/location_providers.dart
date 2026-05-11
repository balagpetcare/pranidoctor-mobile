import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:pranidoctor_mobile/src/core/network/api_client.dart';
import 'package:pranidoctor_mobile/src/features/locations/data/location_models.dart';
import 'package:pranidoctor_mobile/src/features/locations/data/location_repository.dart';

final locationRepositoryProvider = Provider<LocationRepository>((ref) {
  return LocationRepository(ref.watch(apiClientProvider));
});

/// Administrative divisions (বিভাগ).
final divisionsProvider = FutureProvider<List<MobileLocationDto>>((ref) {
  return ref.read(locationRepositoryProvider).fetchDivisions();
});

/// [divisionIdKey] empty → no fetch (profile cascade requires বিভাগ first).
/// Guest / other flows use [districtsProvider] for the full list.
final districtsForDivisionProvider = FutureProvider.autoDispose
    .family<List<MobileLocationDto>, String>((ref, divisionIdKey) {
      final id = divisionIdKey.trim();
      if (id.isEmpty) return Future.value(<MobileLocationDto>[]);
      return ref
          .read(locationRepositoryProvider)
          .fetchDistricts(divisionId: id);
    });

/// Cached (non–autoDispose) so reopening the guest sheet does not restart fetch.
final districtsProvider = FutureProvider<List<MobileLocationDto>>((ref) {
  return ref.read(locationRepositoryProvider).fetchDistricts();
});

final upazilasForDistrictProvider = FutureProvider.autoDispose
    .family<List<MobileLocationDto>, String>((ref, districtId) {
      return ref
          .read(locationRepositoryProvider)
          .fetchUpazilas(districtId: districtId);
    });

final unionsForDistrictUpazilaProvider = FutureProvider.autoDispose
    .family<List<MobileLocationDto>, ({String districtId, String upazilaId})>((
      ref,
      key,
    ) {
      return ref
          .read(locationRepositoryProvider)
          .fetchUnions(districtId: key.districtId, upazilaId: key.upazilaId);
    });

final villagesForUnionProvider = FutureProvider.autoDispose
    .family<List<MobileLocationDto>, String>((ref, unionId) {
      final id = unionId.trim();
      if (id.isEmpty) return Future.value(<MobileLocationDto>[]);
      return ref.read(locationRepositoryProvider).fetchVillages(unionId: id);
    });
