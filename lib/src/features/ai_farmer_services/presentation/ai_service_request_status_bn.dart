/// Bengali labels for native `AiServiceRequest` status strings.
abstract final class AiServiceRequestStatusBn {
  static String title(String status) {
    switch (status) {
      case 'PENDING':
        return 'অপেক্ষমাণ';
      case 'ACCEPTED':
        return 'গ্রহণ করা';
      case 'ON_THE_WAY':
        return 'রওনা হয়েছে';
      case 'ARRIVED':
        return 'পৌঁছেছে';
      case 'IN_PROGRESS':
        return 'কাজ চলছে';
      case 'COMPLETED':
        return 'সম্পন্ন';
      case 'DECLINED':
        return 'প্রত্যাখ্যাত';
      case 'CANCELLED':
        return 'বাতিল';
      default:
        return status;
    }
  }
}
