import 'package:flutter_test/flutter_test.dart';
import 'package:pranidoctor_mobile/src/features/animals/presentation/animal_form_validators.dart';

void main() {
  group('AnimalFormValidators', () {
    test('nameOrTagRequired rejects both empty', () {
      expect(AnimalFormValidators.nameOrTagRequired('', ''), isNotNull);
      expect(AnimalFormValidators.nameOrTagRequired('  ', '  '), isNotNull);
    });

    test('nameOrTagRequired accepts name only', () {
      expect(AnimalFormValidators.nameOrTagRequired('মিলন', ''), isNull);
    });

    test('nameOrTagRequired accepts tag only', () {
      expect(AnimalFormValidators.nameOrTagRequired('', 'T-12'), isNull);
    });

    test('weightKgOptional rejects invalid', () {
      expect(AnimalFormValidators.weightKgOptional('0'), isNotNull);
      expect(AnimalFormValidators.weightKgOptional('-1'), isNotNull);
      expect(AnimalFormValidators.weightKgOptional('abc'), isNotNull);
    });

    test('weightKgOptional accepts empty and valid decimals', () {
      expect(AnimalFormValidators.weightKgOptional(''), isNull);
      expect(AnimalFormValidators.weightKgOptional('  '), isNull);
      expect(AnimalFormValidators.weightKgOptional('45.5'), isNull);
      expect(AnimalFormValidators.weightKgOptional('45,5'), isNull);
    });

    test('notesLength enforces max', () {
      expect(AnimalFormValidators.notesLength('a' * 8000), isNull);
      expect(AnimalFormValidators.notesLength('a' * 8001), isNotNull);
    });

    test('photoUrlOptional', () {
      expect(AnimalFormValidators.photoUrlOptional(''), isNull);
      expect(AnimalFormValidators.photoUrlOptional('ftp://x'), isNotNull);
      expect(
        AnimalFormValidators.photoUrlOptional('https://a.com/x.png'),
        isNull,
      );
    });
  });
}
