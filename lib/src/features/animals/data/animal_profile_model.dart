// ignore_for_file: constant_identifier_names

library;

/// Maps Prani Doctor mobile API `animal` JSON (camelCase).
///
/// Enum names mirror backend strings (`CATTLE`, …).

class AnimalProfile {
  const AnimalProfile({
    required this.id,
    required this.customerId,
    required this.name,
    required this.species,
    required this.category,
    required this.animalType,
    required this.active,
    required this.createdAt,
    required this.updatedAt,
    this.breed,
    this.weightKg,
    this.dateOfBirth,
    this.ageYears,
    this.ageMonths,
    this.sex,
    this.gender,
    this.microchipOrTag,
    this.notes,
    this.photoUrl,
    this.pregnancyStatus,
  });

  final String id;
  final String customerId;
  final String name;
  final String species;
  final AnimalCategory category;
  final AnimalType? animalType;
  final bool active;
  final DateTime createdAt;
  final DateTime updatedAt;

  final String? breed;
  final String? weightKg;
  final DateTime? dateOfBirth;
  final int? ageYears;
  final int? ageMonths;
  final String? sex;
  final Gender? gender;
  final String? microchipOrTag;
  final String? notes;
  final String? photoUrl;
  final PregnancyStatus? pregnancyStatus;

  factory AnimalProfile.fromJson(Map<String, dynamic> json) {
    return AnimalProfile(
      id: json['id'] as String,
      customerId: json['customerId'] as String,
      name: json['name'] as String,
      species: json['species'] as String,
      category: AnimalCategory.fromJson(json['category'] as String),
      animalType: AnimalType.fromJson(json['animalType'] as String?),
      active: json['active'] as bool,
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
      breed: json['breed'] as String?,
      weightKg: json['weightKg']?.toString(),
      dateOfBirth: json['dateOfBirth'] == null
          ? null
          : DateTime.tryParse(json['dateOfBirth'] as String),
      ageYears: (json['ageYears'] as num?)?.toInt(),
      ageMonths: (json['ageMonths'] as num?)?.toInt(),
      sex: json['sex'] as String?,
      gender: Gender.fromJson(json['gender'] as String?),
      microchipOrTag: json['microchipOrTag'] as String?,
      notes: json['notes'] as String?,
      photoUrl: json['photoUrl'] as String?,
      pregnancyStatus: PregnancyStatus.fromJson(
        json['pregnancyStatus'] as String?,
      ),
    );
  }
}

enum AnimalCategory {
  PET,
  LIVESTOCK,
  OTHER;

  static AnimalCategory fromJson(String v) => AnimalCategory.values.byName(v);
}

enum AnimalType {
  CATTLE,
  GOAT,
  POULTRY,
  DOG,
  CAT,
  OTHER;

  static AnimalType? fromJson(String? v) {
    if (v == null) return null;
    try {
      return AnimalType.values.byName(v);
    } catch (_) {
      return null;
    }
  }
}

enum Gender {
  MALE,
  FEMALE,
  UNKNOWN,
  OTHER;

  static Gender? fromJson(String? v) {
    if (v == null) return null;
    try {
      return Gender.values.byName(v);
    } catch (_) {
      return null;
    }
  }
}

enum PregnancyStatus {
  UNKNOWN,
  NOT_APPLICABLE,
  NOT_PREGNANT,
  PREGNANT;

  static PregnancyStatus? fromJson(String? v) {
    if (v == null) return null;
    try {
      return PregnancyStatus.values.byName(v);
    } catch (_) {
      return null;
    }
  }
}
