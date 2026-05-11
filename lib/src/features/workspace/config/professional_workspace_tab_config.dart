import 'package:flutter/material.dart';

import 'package:pranidoctor_mobile/src/features/session/application/session_notifier.dart';

/// One bottom-navigation destination in a professional workspace.
class ProfessionalNavTabDefinition {
  const ProfessionalNavTabDefinition({
    required this.id,
    required this.bottomLabel,
    required this.appBarTitle,
    required this.icon,
    required this.selectedIcon,
  });

  /// Stable key for analytics / future deep links.
  final String id;

  /// [NavigationDestination.label] (short).
  final String bottomLabel;

  /// [AppBar] title while this tab is active.
  final String appBarTitle;
  final IconData icon;
  final IconData selectedIcon;
}

/// Central navigation configuration per professional role (extend for new roles).
List<ProfessionalNavTabDefinition> professionalNavTabsForRole(AppRole role) {
  switch (role) {
    case AppRole.aiTechnician:
      return const [
        ProfessionalNavTabDefinition(
          id: 'dashboard',
          bottomLabel: 'ড্যাশবোর্ড',
          appBarTitle: 'এআই টেকনিশিয়ান',
          icon: Icons.dashboard_outlined,
          selectedIcon: Icons.dashboard_rounded,
        ),
        ProfessionalNavTabDefinition(
          id: 'requests',
          bottomLabel: 'অনুরোধ',
          icon: Icons.assignment_outlined,
          selectedIcon: Icons.assignment_rounded,
          appBarTitle: 'কাজের অনুরোধ',
        ),
        ProfessionalNavTabDefinition(
          id: 'services',
          bottomLabel: 'সেবা',
          icon: Icons.medical_services_outlined,
          selectedIcon: Icons.medical_services_rounded,
          appBarTitle: 'কৃত্রিম প্রজনন সেবা',
        ),
        ProfessionalNavTabDefinition(
          id: 'earnings',
          bottomLabel: 'আয়',
          icon: Icons.payments_outlined,
          selectedIcon: Icons.payments_rounded,
          appBarTitle: 'আয় ও লেনদেন',
        ),
        ProfessionalNavTabDefinition(
          id: 'profile',
          bottomLabel: 'প্রোফাইল',
          icon: Icons.person_outline_rounded,
          selectedIcon: Icons.person_rounded,
          appBarTitle: 'পেশাদার প্রোফাইল',
        ),
      ];
    case AppRole.doctor:
      return const [
        ProfessionalNavTabDefinition(
          id: 'dashboard',
          bottomLabel: 'ড্যাশবোর্ড',
          appBarTitle: 'চিকিৎসক ওয়ার্কস্পেস',
          icon: Icons.dashboard_outlined,
          selectedIcon: Icons.dashboard_rounded,
        ),
        ProfessionalNavTabDefinition(
          id: 'appointments',
          bottomLabel: 'অ্যাপয়েন্ট',
          icon: Icons.event_available_outlined,
          selectedIcon: Icons.event_available_rounded,
          appBarTitle: 'অ্যাপয়েন্টমেন্ট',
        ),
        ProfessionalNavTabDefinition(
          id: 'patients',
          bottomLabel: 'রোগী',
          icon: Icons.groups_outlined,
          selectedIcon: Icons.groups_rounded,
          appBarTitle: 'রোগী',
        ),
        ProfessionalNavTabDefinition(
          id: 'earnings',
          bottomLabel: 'আয়',
          icon: Icons.account_balance_wallet_outlined,
          selectedIcon: Icons.account_balance_wallet_rounded,
          appBarTitle: 'আয় ও বিলিং',
        ),
        ProfessionalNavTabDefinition(
          id: 'profile',
          bottomLabel: 'প্রোফাইল',
          icon: Icons.person_outline_rounded,
          selectedIcon: Icons.person_rounded,
          appBarTitle: 'চিকিৎসক প্রোফাইল',
        ),
      ];
    case AppRole.customer:
    case AppRole.technician:
    case AppRole.admin:
      return const [];
  }
}
