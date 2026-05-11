// DTOs for mobile semen template catalog (`/api/mobile/ai-technician/semen-templates`).

class SemenCatalogProviderSummary {
  const SemenCatalogProviderSummary({
    required this.id,
    required this.slug,
    required this.name,
    this.nameBn,
  });

  final String id;
  final String slug;
  final String name;
  final String? nameBn;

  factory SemenCatalogProviderSummary.fromJson(Map<String, dynamic> j) {
    return SemenCatalogProviderSummary(
      id: j['id'] as String,
      slug: j['slug'] as String? ?? '',
      name: j['name'] as String? ?? '',
      nameBn: j['nameBn'] as String?,
    );
  }
}

class SemenCatalogBreedRef {
  const SemenCatalogBreedRef({
    required this.id,
    required this.slug,
    required this.nameEn,
    required this.nameBn,
    required this.animalType,
  });

  final String id;
  final String slug;
  final String nameEn;
  final String nameBn;
  final String animalType;

  factory SemenCatalogBreedRef.fromJson(Map<String, dynamic> j) {
    return SemenCatalogBreedRef(
      id: j['id'] as String,
      slug: j['slug'] as String? ?? '',
      nameEn: j['nameEn'] as String? ?? '',
      nameBn: j['nameBn'] as String? ?? '',
      animalType: j['animalType'] as String? ?? 'OTHER',
    );
  }
}

class SemenCatalogBreedMixLine {
  const SemenCatalogBreedMixLine({
    required this.breedId,
    required this.percentage,
    required this.breed,
  });

  final String breedId;
  final String percentage;
  final SemenCatalogBreedRef breed;

  factory SemenCatalogBreedMixLine.fromJson(Map<String, dynamic> j) {
    final b = j['breed'];
    return SemenCatalogBreedMixLine(
      breedId: j['breedId'] as String? ?? '',
      percentage: j['percentage']?.toString() ?? '0',
      breed: b is Map<String, dynamic>
          ? SemenCatalogBreedRef.fromJson(b)
          : SemenCatalogBreedRef(
              id: '',
              slug: '',
              nameEn: '',
              nameBn: '',
              animalType: 'OTHER',
            ),
    );
  }
}

class SemenCatalogMediaLine {
  const SemenCatalogMediaLine({
    required this.id,
    required this.kind,
    this.uploadedFileId,
    this.externalUrl,
    required this.sortOrder,
  });

  final String id;
  final String kind;
  final String? uploadedFileId;
  final String? externalUrl;
  final int sortOrder;

  factory SemenCatalogMediaLine.fromJson(Map<String, dynamic> j) {
    return SemenCatalogMediaLine(
      id: j['id'] as String? ?? '',
      kind: j['kind'] as String? ?? '',
      uploadedFileId: j['uploadedFileId'] as String?,
      externalUrl: j['externalUrl'] as String?,
      sortOrder: (j['sortOrder'] as num?)?.toInt() ?? 0,
    );
  }
}

/// Row returned by catalog list and template detail APIs.
class SemenTemplateCatalogRow {
  const SemenTemplateCatalogRow({
    required this.id,
    required this.internalName,
    required this.animalType,
    required this.semenProductKind,
    this.otherSemenLabel,
    this.shortDescription,
    required this.semenProvider,
    required this.breedMix,
    required this.media,
    required this.defaultBasePrice,
    this.defaultOfferPrice,
    this.defaultDiscountPercent,
    this.warningsContraindications,
    this.expectedBenefits,
    this.recommendedAnimalCondition,
    this.detailedDescription,
  });

  final String id;
  final String internalName;
  final String animalType;
  final String semenProductKind;
  final String? otherSemenLabel;
  final String? shortDescription;
  final SemenCatalogProviderSummary semenProvider;
  final List<SemenCatalogBreedMixLine> breedMix;
  final List<SemenCatalogMediaLine> media;
  final String defaultBasePrice;
  final String? defaultOfferPrice;
  final String? defaultDiscountPercent;
  final String? warningsContraindications;
  final String? expectedBenefits;
  final String? recommendedAnimalCondition;
  final String? detailedDescription;

  factory SemenTemplateCatalogRow.fromJson(Map<String, dynamic> j) {
    final p = j['semenProvider'];
    final mix = j['breedMix'];
    final media = j['media'];
    return SemenTemplateCatalogRow(
      id: j['id'] as String,
      internalName: j['internalName'] as String? ?? '',
      animalType: j['animalType'] as String? ?? 'OTHER',
      semenProductKind: j['semenProductKind'] as String? ?? 'NORMAL',
      otherSemenLabel: j['otherSemenLabel'] as String?,
      shortDescription: j['shortDescription'] as String?,
      semenProvider: p is Map<String, dynamic>
          ? SemenCatalogProviderSummary.fromJson(p)
          : const SemenCatalogProviderSummary(id: '', slug: '', name: ''),
      breedMix: mix is List<dynamic>
          ? mix
              .map(
                (e) => SemenCatalogBreedMixLine.fromJson(e as Map<String, dynamic>),
              )
              .toList()
          : const [],
      media: media is List<dynamic>
          ? media
              .map(
                (e) => SemenCatalogMediaLine.fromJson(e as Map<String, dynamic>),
              )
              .toList()
          : const [],
      defaultBasePrice: j['defaultBasePrice']?.toString() ?? '0',
      defaultOfferPrice: j['defaultOfferPrice']?.toString(),
      defaultDiscountPercent: j['defaultDiscountPercent']?.toString(),
      warningsContraindications: j['warningsContraindications'] as String?,
      expectedBenefits: j['expectedBenefits'] as String?,
      recommendedAnimalCondition: j['recommendedAnimalCondition'] as String?,
      detailedDescription: j['detailedDescription'] as String?,
    );
  }

  String get breedSummaryBn {
    if (breedMix.isEmpty) return '';
    return breedMix
        .map((m) => '${m.percentage}% ${m.breed.nameBn}')
        .join(' · ');
  }
}

class AiTechnicianStockSummary {
  const AiTechnicianStockSummary({
    required this.totalAvailable,
    required this.lotsCount,
    required this.lowStock,
  });

  final int totalAvailable;
  final int lotsCount;
  final bool lowStock;

  factory AiTechnicianStockSummary.fromJson(Map<String, dynamic> j) {
    return AiTechnicianStockSummary(
      totalAvailable: (j['totalAvailable'] as num?)?.toInt() ?? 0,
      lotsCount: (j['lotsCount'] as num?)?.toInt() ?? 0,
      lowStock: j['lowStock'] as bool? ?? false,
    );
  }
}

class SemenInventoryLotRow {
  const SemenInventoryLotRow({
    required this.id,
    required this.aiTechnicianServiceId,
    required this.currentQuantity,
    required this.reservedQuantity,
    required this.usedQuantity,
    this.minStockAlert,
    this.batchNumber,
    this.expiryDate,
    this.sourceNote,
    this.storageNote,
    required this.isActive,
    required this.createdAt,
    required this.updatedAt,
  });

  final String id;
  final String aiTechnicianServiceId;
  final int currentQuantity;
  final int reservedQuantity;
  final int usedQuantity;
  final int? minStockAlert;
  final String? batchNumber;
  final String? expiryDate;
  final String? sourceNote;
  final String? storageNote;
  final bool isActive;
  final String createdAt;
  final String updatedAt;

  factory SemenInventoryLotRow.fromJson(Map<String, dynamic> j) {
    return SemenInventoryLotRow(
      id: j['id'] as String,
      aiTechnicianServiceId: j['aiTechnicianServiceId'] as String? ?? '',
      currentQuantity: (j['currentQuantity'] as num?)?.toInt() ?? 0,
      reservedQuantity: (j['reservedQuantity'] as num?)?.toInt() ?? 0,
      usedQuantity: (j['usedQuantity'] as num?)?.toInt() ?? 0,
      minStockAlert: (j['minStockAlert'] as num?)?.toInt(),
      batchNumber: j['batchNumber'] as String?,
      expiryDate: j['expiryDate'] as String?,
      sourceNote: j['sourceNote'] as String?,
      storageNote: j['storageNote'] as String?,
      isActive: j['isActive'] as bool? ?? true,
      createdAt: j['createdAt'] as String? ?? '',
      updatedAt: j['updatedAt'] as String? ?? '',
    );
  }
}
