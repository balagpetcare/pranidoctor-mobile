import 'package:pranidoctor_mobile/src/features/animals/data/animal_profile_model.dart';

/// Short Bengali labels for enums (UI only).
String animalTypeLabelBn(AnimalType type) {
  return switch (type) {
    AnimalType.CATTLE => 'গরু',
    AnimalType.GOAT => 'ছাগল',
    AnimalType.POULTRY => 'হাঁস–মুরগি',
    AnimalType.DOG => 'কুকুর',
    AnimalType.CAT => 'বিড়াল',
    AnimalType.OTHER => 'অন্যান্য',
  };
}

String animalCategoryLabelBn(AnimalCategory c) {
  return switch (c) {
    AnimalCategory.PET => 'পোষা',
    AnimalCategory.LIVESTOCK => 'খামার',
    AnimalCategory.OTHER => 'অন্যান্য',
  };
}

String genderLabelBn(Gender g) {
  return switch (g) {
    Gender.MALE => 'পুরুষ',
    Gender.FEMALE => 'মহিলা',
    Gender.UNKNOWN => 'অজানা',
    Gender.OTHER => 'অন্যান্য',
  };
}

String pregnancyLabelBn(PregnancyStatus p) {
  return switch (p) {
    PregnancyStatus.UNKNOWN => 'অজানা',
    PregnancyStatus.NOT_APPLICABLE => 'প্রযোজ্য নয়',
    PregnancyStatus.NOT_PREGNANT => 'গর্ভবতী নয়',
    PregnancyStatus.PREGNANT => 'গর্ভবতী',
  };
}
