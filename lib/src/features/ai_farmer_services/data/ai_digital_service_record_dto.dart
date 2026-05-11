/// `GET /api/mobile/ai-services/requests/[id]/record` → `data.record`.
class AiDigitalServiceRecord {
  AiDigitalServiceRecord({
    required this.id,
    required this.aiServiceRequestId,
    required this.technicianProfileId,
    required this.customerUserId,
    required this.serviceDate,
    required this.animalType,
    this.breedOrSemenType,
    this.semenBatch,
    this.heatObservation,
    this.inseminationTime,
    this.serviceNote,
    this.nextFollowUpDate,
    this.pregnancyCheckDate,
    this.totalFee,
    required this.paymentStatus,
    required this.createdAt,
    required this.updatedAt,
  });

  final String id;
  final String aiServiceRequestId;
  final String technicianProfileId;
  final String customerUserId;
  final String serviceDate;
  final String animalType;
  final String? breedOrSemenType;
  final String? semenBatch;
  final String? heatObservation;
  final String? inseminationTime;
  final String? serviceNote;
  final String? nextFollowUpDate;
  final String? pregnancyCheckDate;
  final String? totalFee;
  final String paymentStatus;
  final String createdAt;
  final String updatedAt;

  factory AiDigitalServiceRecord.fromJson(Map<String, dynamic> j) {
    return AiDigitalServiceRecord(
      id: j['id'] as String,
      aiServiceRequestId: j['aiServiceRequestId'] as String,
      technicianProfileId: j['technicianProfileId'] as String,
      customerUserId: j['customerUserId'] as String,
      serviceDate: j['serviceDate'] as String? ?? '',
      animalType: j['animalType'] as String? ?? 'OTHER',
      breedOrSemenType: j['breedOrSemenType'] as String?,
      semenBatch: j['semenBatch'] as String?,
      heatObservation: j['heatObservation'] as String?,
      inseminationTime: j['inseminationTime'] as String?,
      serviceNote: j['serviceNote'] as String?,
      nextFollowUpDate: j['nextFollowUpDate'] as String?,
      pregnancyCheckDate: j['pregnancyCheckDate'] as String?,
      totalFee: j['totalFee']?.toString(),
      paymentStatus: j['paymentStatus'] as String? ?? 'UNPAID',
      createdAt: j['createdAt'] as String? ?? '',
      updatedAt: j['updatedAt'] as String? ?? '',
    );
  }
}

abstract final class AiPaymentStatusBn {
  static String label(String code) {
    switch (code) {
      case 'UNPAID':
        return 'অপরিশোধিত';
      case 'DUE':
        return 'বাকি';
      case 'CASH_PAID':
        return 'নগদে পরিশোধিত';
      case 'MANUAL_PAID':
        return 'ম্যানুয়ালি পরিশোধিত';
      case 'REFUNDED':
        return 'ফেরত';
      default:
        return code;
    }
  }
}
