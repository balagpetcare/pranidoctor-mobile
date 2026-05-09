import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:pranidoctor_mobile/src/core/network/api_client.dart';
import 'package:pranidoctor_mobile/src/features/animals/data/animal_profile_model.dart';
import 'package:pranidoctor_mobile/src/features/animals/data/animal_profile_repository.dart';

final animalRepositoryProvider = Provider<AnimalProfileRepository>((ref) {
  return AnimalProfileRepository(ref.watch(apiClientProvider));
});

final animalsListProvider =
    AsyncNotifierProvider<AnimalsListNotifier, List<AnimalProfile>>(
      AnimalsListNotifier.new,
    );

class AnimalsListNotifier extends AsyncNotifier<List<AnimalProfile>> {
  bool _includeInactive = false;

  bool get includeInactive => _includeInactive;

  void setIncludeInactive(bool value) {
    if (_includeInactive == value) return;
    _includeInactive = value;
    refresh();
  }

  Future<void> refresh() async {
    state = await AsyncValue.guard(() => _load());
  }

  @override
  Future<List<AnimalProfile>> build() async {
    return _load();
  }

  Future<List<AnimalProfile>> _load() async {
    final repo = ref.read(animalRepositoryProvider);
    return repo.list(includeInactive: _includeInactive);
  }
}

final animalDetailProvider = FutureProvider.family<AnimalProfile, String>((
  ref,
  id,
) async {
  final repo = ref.watch(animalRepositoryProvider);
  return repo.getById(id);
});
