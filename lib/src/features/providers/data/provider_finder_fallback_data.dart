import 'package:pranidoctor_mobile/src/features/providers/data/provider_models.dart';
import 'package:pranidoctor_mobile/src/features/providers/data/provider_profile_model.dart';

/// Offline / CI demo data for provider finder. Not used in release unless
/// [AppConfig.useProviderFinderFixtures] is true (`USE_PROVIDER_FIXTURES`).
///
/// Replace with real API responses by disabling the dart-define flag.
abstract final class ProviderFinderFallbackData {
  static const String demoDoctorId = 'fixture-doctor-ashulia';
  static const String demoTechnicianId = 'fixture-tech-ashulia';

  static DoctorSummary get demoDoctorSummary => DoctorSummary(
    id: demoDoctorId,
    name: 'ডা. ফিক্সচার রহমান',
    homeVisit: true,
    emergency: true,
    onlineConsultation: false,
    degreeOrQualification: 'ডিভিএম (পশুচিকিৎসা)',
    serviceType: 'গবাদি ও ছাগল',
    areaText: 'আশুলিয়া ইউনিয়ন ও পার্শ্ববর্তী এলাকা',
    fee: '৫০০',
    availability: 'সপ্তাহে ৬ দিন — সকাল ৯টা–বিকাল ৫টা',
    phone: null,
    rating: null,
    callAction: const ProviderCallAction(enabled: false, reason: 'ডেমো'),
    bookAction: const ProviderBookAction(enabled: false, reason: 'ডেমো'),
  );

  static TechnicianSummary get demoTechnicianSummary => TechnicianSummary(
    id: demoTechnicianId,
    name: 'এআই টেকনিশিয়ান ফিক্সচার',
    homeVisit: true,
    emergency: false,
    onlineConsultation: false,
    serviceType: 'খামার ডিজিটাল নিরীক্ষা',
    areaText: 'ঢাকা জেলার নির্বাচিত ইউনিয়ন',
    fee: '৩০০',
    availability: 'অগ্রিম যোগাযোগ',
    supportedAnimalTypes: const ['গরু', 'ছাগল'],
    phone: null,
    rating: null,
    callAction: const ProviderCallAction(enabled: false, reason: 'ডেমো'),
    bookAction: const ProviderBookAction(enabled: false, reason: 'ডেমো'),
  );

  static DoctorDetail get demoDoctorDetail => DoctorDetail(
    id: demoDoctorSummary.id,
    name: demoDoctorSummary.name,
    homeVisit: demoDoctorSummary.homeVisit,
    emergency: demoDoctorSummary.emergency,
    onlineConsultation: demoDoctorSummary.onlineConsultation,
    degreeOrQualification: demoDoctorSummary.degreeOrQualification,
    serviceType: demoDoctorSummary.serviceType,
    areaText: demoDoctorSummary.areaText,
    fee: demoDoctorSummary.fee,
    availability: demoDoctorSummary.availability,
    phone: demoDoctorSummary.phone,
    rating: demoDoctorSummary.rating,
    callAction: demoDoctorSummary.callAction,
    bookAction: demoDoctorSummary.bookAction,
    bio: 'এটি ডেমো ডাটা। সার্ভার চালু হলে আসল প্রোফাইল দেখাবে।',
    profilePhotoUrl: null,
    experienceYears: 8,
    areas: const [
      DoctorArea(
        id: 'a1',
        name: 'Ashulia Union',
        nameBn: 'আশুলিয়া ইউনিয়ন',
        slug: 'ashulia-union-area',
      ),
    ],
    villages: const [DoctorVillage(id: 'v1', name: 'যাত্রাবাড়ী')],
    serviceCategories: const [
      DoctorServiceCategory(id: 'c1', name: 'গবাদি', slug: 'cattle'),
    ],
  );

  static TechnicianDetail get demoTechnicianDetail => TechnicianDetail(
    id: demoTechnicianSummary.id,
    name: demoTechnicianSummary.name,
    homeVisit: demoTechnicianSummary.homeVisit,
    emergency: demoTechnicianSummary.emergency,
    onlineConsultation: demoTechnicianSummary.onlineConsultation,
    serviceType: demoTechnicianSummary.serviceType,
    areaText: demoTechnicianSummary.areaText,
    fee: demoTechnicianSummary.fee,
    availability: demoTechnicianSummary.availability,
    supportedAnimalTypes: demoTechnicianSummary.supportedAnimalTypes,
    phone: demoTechnicianSummary.phone,
    rating: demoTechnicianSummary.rating,
    callAction: demoTechnicianSummary.callAction,
    bookAction: demoTechnicianSummary.bookAction,
    bio: 'ডেমো টেকনিশিয়ান বিবরণ।',
    certification: 'লাইভস্টক এক্সটেনশন সার্টিফিকেট (ডেমো)',
    metadataJson: null,
    areas: const [
      DoctorArea(
        id: 'a2',
        name: 'Demo area',
        nameBn: 'ডেমো এলাকা',
        slug: 'demo-area',
      ),
    ],
    villages: const [],
    serviceCategories: const [
      DoctorServiceCategory(id: 'c2', name: 'AI সেবা', slug: 'ai'),
    ],
  );

  static ProviderProfileDetail profileDetailFor(String id) {
    if (id == demoTechnicianId) {
      return ProviderProfileDetail.fromTechnicianDetail(demoTechnicianDetail);
    }
    return ProviderProfileDetail.fromDoctorDetail(demoDoctorDetail);
  }
}
