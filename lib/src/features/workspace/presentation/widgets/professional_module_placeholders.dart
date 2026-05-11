import 'package:flutter/material.dart';

import 'package:pranidoctor_mobile/src/design_system/prani_tokens.dart';

/// Shared placeholder for modules not yet shipped (earnings, wallet, etc.).
class ProfessionalModulePlaceholder extends StatelessWidget {
  const ProfessionalModulePlaceholder({
    super.key,
    required this.title,
    required this.message,
    this.icon = Icons.construction_outlined,
  });

  final String title;
  final String message;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return ListView(
      padding: const EdgeInsets.all(PraniSpacing.xl),
      children: [
        const SizedBox(height: PraniSpacing.section),
        Icon(icon, size: 48, color: scheme.primary),
        const SizedBox(height: PraniSpacing.xl),
        Text(
          title,
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w700,
              ),
        ),
        const SizedBox(height: PraniSpacing.md),
        Text(
          message,
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: scheme.onSurfaceVariant,
                height: 1.45,
              ),
        ),
      ],
    );
  }
}

class ProfessionalEarningsPlaceholder extends StatelessWidget {
  const ProfessionalEarningsPlaceholder({
    super.key,
    required this.isDoctor,
  });

  final bool isDoctor;

  @override
  Widget build(BuildContext context) {
    return ProfessionalModulePlaceholder(
      title: isDoctor ? 'আয় ও বিলিং' : 'আয় ও লেনদেন',
      message: isDoctor
          ? 'চিকিৎসক আয়, ইনভয়েস ও পেমেন্ট ট্র্যাকিং শীঘ্রই যুক্ত করা হবে।'
          : 'এআই টেকনিশিয়ান আয়, উইথহোল্ডিং ও পেআউট ড্যাশবোর্ড শীঘ্রই যুক্ত করা হবে।',
      icon: Icons.payments_outlined,
    );
  }
}

class DoctorAppointmentsPlaceholder extends StatelessWidget {
  const DoctorAppointmentsPlaceholder({super.key});

  @override
  Widget build(BuildContext context) {
    return const ProfessionalModulePlaceholder(
      title: 'অ্যাপয়েন্টমেন্ট',
      message:
          'ক্যালেন্ডার, স্লট বুকিং ও রিমাইন্ডার — পরবর্তী রিলিজে সংযুক্ত হবে।',
      icon: Icons.event_available_outlined,
    );
  }
}

class DoctorPatientsPlaceholder extends StatelessWidget {
  const DoctorPatientsPlaceholder({super.key});

  @override
  Widget build(BuildContext context) {
    return const ProfessionalModulePlaceholder(
      title: 'রোগী',
      message: 'রোগী তালিকা, কেস নোট ও ফলো-আপ শীঘ্রই এখানে থাকবে।',
      icon: Icons.groups_outlined,
    );
  }
}

class DoctorPrescriptionComposerPlaceholder extends StatelessWidget {
  const DoctorPrescriptionComposerPlaceholder({super.key});

  @override
  Widget build(BuildContext context) {
    return const ProfessionalModulePlaceholder(
      title: 'প্রেসক্রিপশন কম্পোজার',
      message:
          'ড্রাগ ডাটাবেস, ডোজ ক্যালকুলেটর ও ই-প্রেসক্রিপশন এক্সপোর্ট শীঘ্রই যুক্ত হবে। '
          'API সংযুক্ত হলে এই পর্দা সরাসরি কম্পোজারে রূপ নেবে।',
      icon: Icons.medication_outlined,
    );
  }
}

class ProfessionalWalletPlaceholder extends StatelessWidget {
  const ProfessionalWalletPlaceholder({super.key});

  @override
  Widget build(BuildContext context) {
    return const ProfessionalModulePlaceholder(
      title: 'ওয়ালেট',
      message: 'ব্যালেন্স, উইথড্রয়াল ও লেনদেনের ইতিহাস শীঘ্রই যুক্ত করা হবে।',
      icon: Icons.account_balance_wallet_outlined,
    );
  }
}

class ProfessionalVerificationPlaceholder extends StatelessWidget {
  const ProfessionalVerificationPlaceholder({super.key});

  @override
  Widget build(BuildContext context) {
    return const ProfessionalModulePlaceholder(
      title: 'যাচাইকরণের অবস্থা',
      message: 'নথি যাচাই ও অনুমোদনের ধাপ এখানে দেখানো হবে।',
      icon: Icons.verified_user_outlined,
    );
  }
}

class ProfessionalDocumentsPlaceholder extends StatelessWidget {
  const ProfessionalDocumentsPlaceholder({super.key});

  @override
  Widget build(BuildContext context) {
    return const ProfessionalModulePlaceholder(
      title: 'নথি',
      message: 'লাইসেন্স, পরিচয় ও চুক্তি সংরক্ষণ শীঘ্রই।',
      icon: Icons.folder_open_outlined,
    );
  }
}
