import 'package:flutter/material.dart';

/// Editable professional profile areas (COMMAND 5).
enum ProfessionalProfileSection {
  basic,
  professional,
  serviceAreas,
  availability,
  experience,
  education,
  pricing,
  documents,
  mediaGallery,
  verification,
}

extension ProfessionalProfileSectionUi on ProfessionalProfileSection {
  String get titleBn => switch (this) {
        ProfessionalProfileSection.basic => 'মৌলিক তথ্য',
        ProfessionalProfileSection.professional => 'পেশাদার তথ্য',
        ProfessionalProfileSection.serviceAreas => 'সেবা এলাকা',
        ProfessionalProfileSection.availability => 'উপলব্ধতা',
        ProfessionalProfileSection.experience => 'অভিজ্ঞতা',
        ProfessionalProfileSection.education => 'শিক্ষা / প্রশিক্ষণ',
        ProfessionalProfileSection.pricing => 'মূল্য তালিকা',
        ProfessionalProfileSection.documents => 'নথি',
        ProfessionalProfileSection.mediaGallery => 'মিডিয়া গ্যালারি',
        ProfessionalProfileSection.verification => 'যাচাইকরণ তথ্য',
      };

  String get subtitleBn => switch (this) {
        ProfessionalProfileSection.basic => 'নাম, যোগাযোগ ও পরিচিতি',
        ProfessionalProfileSection.professional =>
          'লাইসেন্স, বিশেষতা ও পেশাগত বিবরণ',
        ProfessionalProfileSection.serviceAreas => 'যে অঞ্চলে সেবা দেন',
        ProfessionalProfileSection.availability => 'সময় ও মোড',
        ProfessionalProfileSection.experience => 'কাজের ইতিহাস সংক্ষেপে',
        ProfessionalProfileSection.education => 'ডিগ্রি ও সার্টিফিকেট ট্রেনিং',
        ProfessionalProfileSection.pricing => 'ভিজিট / সেবার মূল্য নোট',
        ProfessionalProfileSection.documents => 'সনদ, পরিচয়পত্র, আপলোড',
        ProfessionalProfileSection.mediaGallery => 'প্রোফাইল, কাজের ছবি ও ভিডিও',
        ProfessionalProfileSection.verification =>
          'প্ল্যাটফর্ম যাচাই অবস্থা (পঠনযোগ্য)',
      };

  IconData get icon => switch (this) {
        ProfessionalProfileSection.basic => Icons.person_outline_rounded,
        ProfessionalProfileSection.professional => Icons.badge_outlined,
        ProfessionalProfileSection.serviceAreas => Icons.map_outlined,
        ProfessionalProfileSection.availability => Icons.event_available_outlined,
        ProfessionalProfileSection.experience => Icons.work_history_outlined,
        ProfessionalProfileSection.education => Icons.school_outlined,
        ProfessionalProfileSection.pricing => Icons.payments_outlined,
        ProfessionalProfileSection.documents => Icons.folder_special_outlined,
        ProfessionalProfileSection.mediaGallery => Icons.collections_outlined,
        ProfessionalProfileSection.verification => Icons.verified_user_outlined,
      };

  String get routeKey => name;
}

ProfessionalProfileSection? parseProfessionalProfileSection(String? raw) {
  if (raw == null || raw.trim().isEmpty) return null;
  for (final v in ProfessionalProfileSection.values) {
    if (v.name == raw.trim()) return v;
  }
  return null;
}
