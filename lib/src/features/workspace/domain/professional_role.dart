import 'package:flutter/material.dart';

import 'package:pranidoctor_mobile/src/features/session/application/session_notifier.dart';

enum ProfessionalRole {
  aiTechnician,
  doctor,
  seller,
  pharmacy,
  ambulance,
  breeder,
  ngoWorker,
}

extension ProfessionalRoleX on ProfessionalRole {
  String get labelBn {
    switch (this) {
      case ProfessionalRole.aiTechnician:
        return 'এআই টেকনিশিয়ান';
      case ProfessionalRole.doctor:
        return 'ভেটেরিনারি ডাক্তার';
      case ProfessionalRole.seller:
        return 'বিক্রেতা';
      case ProfessionalRole.pharmacy:
        return 'ফার্মেসি';
      case ProfessionalRole.ambulance:
        return 'অ্যাম্বুলেন্স';
      case ProfessionalRole.breeder:
        return 'ব্রিডার';
      case ProfessionalRole.ngoWorker:
        return 'এনজিও ওয়ার্কার';
    }
  }

  String get subtitleBn {
    switch (this) {
      case ProfessionalRole.aiTechnician:
        return 'কৃত্রিম প্রজনন ও সেবা ড্যাশবোর্ড';
      case ProfessionalRole.doctor:
        return 'চিকিৎসা, রোগী ও আয়ের হাব';
      case ProfessionalRole.seller:
        return 'পণ্য ও অর্ডার ম্যানেজমেন্ট';
      case ProfessionalRole.pharmacy:
        return 'ঔষধ ও প্রেসক্রিপশন ম্যানেজমেন্ট';
      case ProfessionalRole.ambulance:
        return 'জরুরি সেবা পরিচালনা';
      case ProfessionalRole.breeder:
        return 'প্রজনন ও খামার পরিচালনা';
      case ProfessionalRole.ngoWorker:
        return 'সামাজিক সহায়তা মডিউল';
    }
  }

  String get routePath {
    switch (this) {
      case ProfessionalRole.aiTechnician:
        return '/workspace/technician';
      case ProfessionalRole.doctor:
        return '/workspace/doctor';
      case ProfessionalRole.seller:
        return '/workspace/seller';
      case ProfessionalRole.pharmacy:
        return '/workspace/pharmacy';
      case ProfessionalRole.ambulance:
        return '/workspace/ambulance';
      case ProfessionalRole.breeder:
        return '/workspace/breeder';
      case ProfessionalRole.ngoWorker:
        return '/workspace/ngo';
    }
  }

  IconData get icon {
    switch (this) {
      case ProfessionalRole.aiTechnician:
        return Icons.engineering_rounded;
      case ProfessionalRole.doctor:
        return Icons.medical_services_rounded;
      case ProfessionalRole.seller:
        return Icons.storefront_rounded;
      case ProfessionalRole.pharmacy:
        return Icons.local_pharmacy_rounded;
      case ProfessionalRole.ambulance:
        return Icons.emergency_rounded;
      case ProfessionalRole.breeder:
        return Icons.agriculture_rounded;
      case ProfessionalRole.ngoWorker:
        return Icons.volunteer_activism_rounded;
    }
  }

  Color accentColor(ColorScheme scheme) {
    switch (this) {
      case ProfessionalRole.aiTechnician:
        return scheme.primary;
      case ProfessionalRole.doctor:
        return scheme.tertiary;
      default:
        return scheme.secondary;
    }
  }

  List<Color> gradientColors(ColorScheme scheme) {
    switch (this) {
      case ProfessionalRole.aiTechnician:
        return [
          scheme.primaryContainer,
          scheme.primaryContainer.withValues(alpha: 0.55),
          scheme.surfaceContainerLowest.withValues(alpha: 0.25),
        ];
      case ProfessionalRole.doctor:
        return [
          scheme.tertiaryContainer,
          scheme.tertiaryContainer.withValues(alpha: 0.55),
          scheme.surfaceContainerLowest.withValues(alpha: 0.25),
        ];
      default:
        return [
          scheme.secondaryContainer,
          scheme.secondaryContainer.withValues(alpha: 0.55),
          scheme.surfaceContainerLowest.withValues(alpha: 0.25),
        ];
    }
  }

  static ProfessionalRole? fromAppRole(AppRole? role) {
    switch (role) {
      case AppRole.aiTechnician:
        return ProfessionalRole.aiTechnician;
      case AppRole.doctor:
        return ProfessionalRole.doctor;
      default:
        return null;
    }
  }
}

