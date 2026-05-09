import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:pranidoctor_mobile/src/core/network/api_client.dart';
import 'package:pranidoctor_mobile/src/features/service_requests/data/service_category_repository.dart';
import 'package:pranidoctor_mobile/src/features/service_requests/data/service_request_model.dart';
import 'package:pranidoctor_mobile/src/features/service_requests/data/service_request_repository.dart';

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
    this.problemOrSymptom = '',
    this.description = '',
    this.locationText = '',
    this.preferredTime = '',
  });

  final String? animalId;
  final ServiceRequestType? serviceType;
  final String problemOrSymptom;
  final String description;
  final String locationText;
  final String preferredTime;
}

final bookingDraftProvider =
    NotifierProvider<BookingDraftNotifier, BookingDraft>(
      BookingDraftNotifier.new,
    );

class BookingDraftNotifier extends Notifier<BookingDraft> {
  @override
  BookingDraft build() => const BookingDraft();

  void reset() => state = const BookingDraft();

  void setAnimalId(String id) {
    state = BookingDraft(
      animalId: id,
      serviceType: state.serviceType,
      problemOrSymptom: state.problemOrSymptom,
      description: state.description,
      locationText: state.locationText,
      preferredTime: state.preferredTime,
    );
  }

  void setServiceType(ServiceRequestType type) {
    state = BookingDraft(
      animalId: state.animalId,
      serviceType: type,
      problemOrSymptom: state.problemOrSymptom,
      description: state.description,
      locationText: state.locationText,
      preferredTime: state.preferredTime,
    );
  }

  void setProblem(String v) {
    state = BookingDraft(
      animalId: state.animalId,
      serviceType: state.serviceType,
      problemOrSymptom: v,
      description: state.description,
      locationText: state.locationText,
      preferredTime: state.preferredTime,
    );
  }

  void setDescription(String v) {
    state = BookingDraft(
      animalId: state.animalId,
      serviceType: state.serviceType,
      problemOrSymptom: state.problemOrSymptom,
      description: v,
      locationText: state.locationText,
      preferredTime: state.preferredTime,
    );
  }

  void setLocationText(String v) {
    state = BookingDraft(
      animalId: state.animalId,
      serviceType: state.serviceType,
      problemOrSymptom: state.problemOrSymptom,
      description: state.description,
      locationText: v,
      preferredTime: state.preferredTime,
    );
  }

  void setPreferredTime(String v) {
    state = BookingDraft(
      animalId: state.animalId,
      serviceType: state.serviceType,
      problemOrSymptom: state.problemOrSymptom,
      description: state.description,
      locationText: state.locationText,
      preferredTime: v,
    );
  }
}
