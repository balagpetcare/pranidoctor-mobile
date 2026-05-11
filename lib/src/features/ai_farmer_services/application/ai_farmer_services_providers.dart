import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:pranidoctor_mobile/src/core/network/api_client.dart';
import 'package:pranidoctor_mobile/src/features/ai_farmer_services/data/ai_digital_service_record_dto.dart';
import 'package:pranidoctor_mobile/src/features/ai_farmer_services/data/ai_farmer_services_models.dart';
import 'package:pranidoctor_mobile/src/features/ai_farmer_services/data/ai_farmer_services_repository.dart';
import 'package:pranidoctor_mobile/src/features/providers/data/provider_models.dart';

final aiFarmerServicesRepositoryProvider = Provider<AiFarmerServicesRepository>(
  (ref) {
    return AiFarmerServicesRepository(ref.watch(apiClientProvider));
  },
);

final aiTechnicianPublicProvider = FutureProvider.autoDispose
    .family<AiTechnicianPublicDetail, String>((ref, id) {
      return ref
          .read(aiFarmerServicesRepositoryProvider)
          .getTechnicianPublic(id);
    });

final aiMyServiceRequestsProvider =
    FutureProvider.autoDispose<
      ({List<AiFarmerServiceRequestRow> requests, PaginationInfo pagination})
    >((ref) async {
      final r = await ref
          .read(aiFarmerServicesRepositoryProvider)
          .listMyRequests();
      return (requests: r.requests, pagination: r.pagination);
    });

final aiFarmerMyRequestDetailProvider = FutureProvider.autoDispose
    .family<AiFarmerServiceRequestRow, String>((ref, id) {
      return ref.read(aiFarmerServicesRepositoryProvider).getMyRequest(id);
    });

final aiDigitalServiceRecordProvider = FutureProvider.autoDispose
    .family<AiDigitalServiceRecord, String>((ref, id) {
      return ref
          .read(aiFarmerServicesRepositoryProvider)
          .fetchServiceRecord(id);
    });
