import 'package:flutter_test/flutter_test.dart';
import 'package:pranidoctor_mobile/src/features/animals/data/animal_profile_model.dart';
import 'package:pranidoctor_mobile/src/features/providers/data/provider_list_query.dart';

void main() {
  test(
    'ProviderListQuery includes search and aiTechnicianService in params',
    () {
      const q = ProviderListQuery(
        nameSearch: 'রহমান',
        aiTechnicianService: true,
        animalType: AnimalType.CATTLE,
      );
      final m = q.toQueryParameters();
      expect(m['search'], 'রহমান');
      expect(m['aiTechnicianService'], 'true');
      expect(m['animalType'], 'CATTLE');
    },
  );

  test('withFilters clears nameSearch', () {
    const q = ProviderListQuery(nameSearch: 'x');
    final cleared = q.withFilters(clearNameSearch: true);
    expect(cleared.nameSearch, isNull);
  });
}
