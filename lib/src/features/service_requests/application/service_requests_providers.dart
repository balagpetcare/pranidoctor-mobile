import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:pranidoctor_mobile/src/core/network/api_client.dart';
import 'package:pranidoctor_mobile/src/features/providers/data/provider_kind.dart';
import 'package:pranidoctor_mobile/src/features/service_requests/data/service_category_repository.dart';
import 'package:pranidoctor_mobile/src/features/service_requests/data/service_request_model.dart';
import 'package:pranidoctor_mobile/src/features/service_requests/data/service_request_repository.dart';
import 'package:pranidoctor_mobile/src/features/service_requests/domain/booking_urgency.dart';

final serviceRequestRepositoryProvider = Provider<ServiceRequestRepository>((
  ref,
) {
  return ServiceRequestRepository(ref.watch(apiClientProvider));
});

final serviceCategoryRepositoryProvider = Provider<ServiceCategoryRepository>((
  ref,
) {
  return ServiceCategoryRepository(ref.watch(apiClientProvider));
});

final serviceCategoriesProvider = FutureProvider<List<ServiceCategoryOption>>((
  ref,
) async {
  final repo = ref.watch(serviceCategoryRepositoryProvider);
  return repo.list();
});

final serviceRequestsListProvider =
    AsyncNotifierProvider<ServiceRequestsListNotifier, List<ServiceRequest>>(
      ServiceRequestsListNotifier.new,
    );

class ServiceRequestsListNotifier extends AsyncNotifier<List<ServiceRequest>> {
  Future<void> refresh() async {
    state = await AsyncValue.guard(_load);
  }

  @override
  Future<List<ServiceRequest>> build() async => _load();

  Future<List<ServiceRequest>> _load() async {
    final repo = ref.read(serviceRequestRepositoryProvider);
    final page = await repo.list(limit: 50);
    return page.requests;
  }
}

final serviceRequestDetailProvider = FutureProvider.autoDispose
    .family<ServiceRequest, String>((ref, id) async {
      final repo = ref.watch(serviceRequestRepositoryProvider);
      return repo.getById(id);
    });

@immutable
class BookingDraft {
  const BookingDraft({
    this.animalId,
    this.serviceType,
    this.selectedAreaSlug = '',
    this.locationDetail = '',
    this.problemOrSymptom = '',
    this.description = '',
    this.preferredTime = '',
    this.urgency,
    this.preferredProviderId,
    this.preferredProviderKind,
    this.preferredProviderDisplayName,
  });

  final String? animalId;
  final ServiceRequestType? serviceType;

  /// Area preset slug (e.g. ashulia) or empty string when user picks “custom”.
  final String selectedAreaSlug;

  /// Free-text location detail (village, landmark, road).
  final String locationDetail;
  final String problemOrSymptom;

  /// Optional extra notes (merged into API `description` with urgency).
  final String description;
  final String preferredTime;
  final BookingUrgency? urgency;

  final String? preferredProviderId;
  final ProviderKind? preferredProviderKind;
  final String? preferredProviderDisplayName;

  BookingDraft copyWith({
    String? animalId,
    ServiceRequestType? serviceType,
    String? selectedAreaSlug,
    String? locationDetail,
    String? problemOrSymptom,
    String? description,
    String? preferredTime,
    BookingUrgency? urgency,
    String? preferredProviderId,
    ProviderKind? preferredProviderKind,
    String? preferredProviderDisplayName,
    bool clearAnimalId = false,
    bool clearServiceType = false,
    bool clearUrgency = false,
    bool clearPreferredProvider = false,
  }) {
    return BookingDraft(
      animalId: clearAnimalId ? null : (animalId ?? this.animalId),
      serviceType: clearServiceType ? null : (serviceType ?? this.serviceType),
      selectedAreaSlug: selectedAreaSlug ?? this.selectedAreaSlug,
      locationDetail: locationDetail ?? this.locationDetail,
      problemOrSymptom: problemOrSymptom ?? this.problemOrSymptom,
      description: description ?? this.description,
      preferredTime: preferredTime ?? this.preferredTime,
      urgency: clearUrgency ? null : (urgency ?? this.urgency),
      preferredProviderId: clearPreferredProvider
          ? null
          : (preferredProviderId ?? this.preferredProviderId),
      preferredProviderKind: clearPreferredProvider
          ? null
          : (preferredProviderKind ?? this.preferredProviderKind),
      preferredProviderDisplayName: clearPreferredProvider
          ? null
          : (preferredProviderDisplayName ?? this.preferredProviderDisplayName),
    );
  }
}

final bookingDraftProvider =
    NotifierProvider<BookingDraftNotifier, BookingDraft>(
      BookingDraftNotifier.new,
    );

class BookingDraftNotifier extends Notifier<BookingDraft> {
  @override
  BookingDraft build() => const BookingDraft();

  void reset() => state = const BookingDraft();

  void applyPresetServiceType(ServiceRequestType type) {
    state = state.copyWith(serviceType: type, clearPreferredProvider: true);
  }

  void setAnimalId(String id) => state = state.copyWith(animalId: id);

  void setServiceType(ServiceRequestType type) {
    state = state.copyWith(serviceType: type, clearPreferredProvider: true);
  }

  void setSelectedAreaSlug(String slug) =>
      state = state.copyWith(selectedAreaSlug: slug);

  void setLocationDetail(String v) => state = state.copyWith(locationDetail: v);

  void setProblem(String v) => state = state.copyWith(problemOrSymptom: v);

  void setDescription(String v) => state = state.copyWith(description: v);

  void setPreferredTime(String v) => state = state.copyWith(preferredTime: v);

  void setUrgency(BookingUrgency u) => state = state.copyWith(urgency: u);

  void clearPreferredProvider() =>
      state = state.copyWith(clearPreferredProvider: true);

  void setPreferredProvider({
    required String id,
    required ProviderKind kind,
    required String displayName,
  }) {
    state = state.copyWith(
      preferredProviderId: id,
      preferredProviderKind: kind,
      preferredProviderDisplayName: displayName,
    );
  }
}
