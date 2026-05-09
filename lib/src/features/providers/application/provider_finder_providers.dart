import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:pranidoctor_mobile/src/core/network/api_client.dart';
import 'package:pranidoctor_mobile/src/features/providers/data/provider_finder_repository.dart';
import 'package:pranidoctor_mobile/src/features/providers/data/provider_kind.dart';
import 'package:pranidoctor_mobile/src/features/providers/data/provider_list_query.dart';
import 'package:pranidoctor_mobile/src/features/providers/data/provider_models.dart';
import 'package:pranidoctor_mobile/src/features/providers/data/provider_profile_model.dart';

final providerFinderRepositoryProvider = Provider<ProviderFinderRepository>((
  ref,
) {
  return ProviderFinderRepository(ref.watch(apiClientProvider));
});

class DoctorListQueryNotifier extends Notifier<ProviderListQuery> {
  @override
  ProviderListQuery build() => ProviderListQuery.initial;

  void apply(ProviderListQuery q) {
    state = q;
  }

  void reset() {
    state = ProviderListQuery.initial;
  }
}

final doctorListQueryProvider =
    NotifierProvider<DoctorListQueryNotifier, ProviderListQuery>(
      DoctorListQueryNotifier.new,
    );

class TechnicianListQueryNotifier extends Notifier<ProviderListQuery> {
  @override
  ProviderListQuery build() => ProviderListQuery.initial;

  void apply(ProviderListQuery q) {
    state = q;
  }

  void reset() {
    state = ProviderListQuery.initial;
  }
}

final technicianListQueryProvider =
    NotifierProvider<TechnicianListQueryNotifier, ProviderListQuery>(
      TechnicianListQueryNotifier.new,
    );

final doctorsListProvider =
    AsyncNotifierProvider<
      DoctorsListNotifier,
      ({List<DoctorSummary> doctors, PaginationInfo pagination})
    >(DoctorsListNotifier.new);

class DoctorsListNotifier
    extends
        AsyncNotifier<
          ({List<DoctorSummary> doctors, PaginationInfo pagination})
        > {
  @override
  Future<({List<DoctorSummary> doctors, PaginationInfo pagination})>
  build() async {
    final q = ref.watch(doctorListQueryProvider);
    final repo = ref.watch(providerFinderRepositoryProvider);
    return repo.listDoctors(q);
  }

  Future<void> refresh() async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      final q = ref.read(doctorListQueryProvider);
      return ref.read(providerFinderRepositoryProvider).listDoctors(q);
    });
  }
}

final techniciansListProvider =
    AsyncNotifierProvider<
      TechniciansListNotifier,
      ({List<TechnicianSummary> technicians, PaginationInfo pagination})
    >(TechniciansListNotifier.new);

class TechniciansListNotifier
    extends
        AsyncNotifier<
          ({List<TechnicianSummary> technicians, PaginationInfo pagination})
        > {
  @override
  Future<({List<TechnicianSummary> technicians, PaginationInfo pagination})>
  build() async {
    final q = ref.watch(technicianListQueryProvider);
    final repo = ref.watch(providerFinderRepositoryProvider);
    return repo.listTechnicians(q);
  }

  Future<void> refresh() async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      final q = ref.read(technicianListQueryProvider);
      return ref.read(providerFinderRepositoryProvider).listTechnicians(q);
    });
  }
}

/// Unified detail: tries `GET /api/mobile/providers/:id`, then role-specific APIs.
final providerProfileDetailProvider = FutureProvider.autoDispose
    .family<ProviderProfileDetail, (String, ProviderKind)>((ref, arg) async {
      final repo = ref.watch(providerFinderRepositoryProvider);
      return repo.getProviderProfileDetail(arg.$1, arg.$2);
    });
