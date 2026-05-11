import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'package:pranidoctor_mobile/src/app/screen_padding.dart';
import 'package:pranidoctor_mobile/src/design_system/prani_page_insets.dart';
import 'package:pranidoctor_mobile/src/design_system/prani_tokens.dart';
import 'package:pranidoctor_mobile/src/design_system/widgets/prani_buttons.dart';
import 'package:pranidoctor_mobile/src/design_system/widgets/prani_info_card.dart';
import 'package:pranidoctor_mobile/src/design_system/widgets/prani_premium_card.dart';
import 'package:pranidoctor_mobile/src/design_system/widgets/prani_scaffold.dart';
import 'package:pranidoctor_mobile/src/design_system/widgets/prani_section_header.dart';
import 'package:pranidoctor_mobile/src/features/ai_technician_application/presentation/ai_technician_application_form_screen.dart';

/// Landing copy for customers who may apply as AI (insemination) technicians.
class AiTechnicianIntroScreen extends StatelessWidget {
  const AiTechnicianIntroScreen({super.key});

  static const routePath = '/profile/ai-technician/intro';
  static const routeName = 'aiTechnicianIntro';

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final hPad = PraniPageInsets.horizontalPadding(context);
    final maxW = pdReadableMaxWidth(context);

    final bullets = <_Bullet>[
      const _Bullet(
        Icons.favorite_outline_rounded,
        'কৃত্রিম প্রজনন সেবা',
        'গবাদি ও প্রজনন সহায়তায় পেশাদার এআই টেকনিশিয়ান হিসেবে কাজ করুন।',
      ),
      const _Bullet(
        Icons.home_work_outlined,
        'খামারিদের বাড়িতে সেবা',
        'ক্ষেত্রে গিয়ে সেবা দিন — খামারির সময় ও স্থান অনুযায়ী।',
      ),
      const _Bullet(
        Icons.verified_outlined,
        'যাচাইকৃত প্রোফাইল',
        'নথি ও তথ্য যাচাইয়ের পর প্রোফাইল প্রকাশিত হয়।',
      ),
      const _Bullet(
        Icons.map_outlined,
        'সার্ভিস এলাকা',
        'জেলা ও উপজেলা ভিত্তিকে কাজের এলাকা নির্ধারণ করুন।',
      ),
      const _Bullet(
        Icons.payments_outlined,
        'আয়ের সুযোগ',
        'সেবামূল্য ও ডিমান্ডের ভিত্তিতে আয় — অ্যাপের মাধ্যমে অনুরোধ পেতে পারেন।',
      ),
    ];

    return PraniScaffold(
      title: 'এআই টেকনিশিয়ান',
      subtitle: 'কৃত্রিম প্রজনন সেবা',
      resizeToAvoidBottomInset: false,
      padding: EdgeInsets.fromLTRB(
        hPad,
        PraniSpacing.md,
        hPad,
        PraniSpacing.lg,
      ),
      body: SingleChildScrollView(
        child: Align(
          alignment: Alignment.topCenter,
          child: ConstrainedBox(
            constraints: BoxConstraints(maxWidth: maxW),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  'প্রাণী ডাক্তার প্ল্যাটফর্মে যাচাইকৃত এআই টেকনিশিয়ান হিসেবে যুক্ত হন।',
                  style: PraniTextStyles.sectionTitleProminent(
                    scheme,
                    textTheme,
                  ).copyWith(fontWeight: FontWeight.w600, height: 1.45),
                ),
                const SizedBox(height: PraniSpacing.lg),
                const PraniSectionHeader(
                  title: 'কী কী সুবিধা',
                  subtitle: 'সংক্ষেপে জেনে নিন',
                ),
                const SizedBox(height: PraniSpacing.sm),
                PraniPremiumCard(
                  child: Column(
                    children: [
                      for (var i = 0; i < bullets.length; i++) ...[
                        if (i > 0)
                          Divider(
                            height: 1,
                            color: scheme.outlineVariant.withValues(alpha: 0.4),
                          ),
                        _BulletTile(b: bullets[i]),
                      ],
                    ],
                  ),
                ),
                const SizedBox(height: PraniSpacing.lg),
                PraniInfoCard(
                  title: 'পরবর্তী ধাপ',
                  subtitle:
                      'আবেদন ফর্মে নাম, ঠিকানা, নথি ও সেবা এলাকা দিন। জমা দিলে অ্যাডমিন পর্যালোচনা করবেন।',
                  leadingIcon: const Icon(Icons.edit_note_outlined),
                ),
                const SizedBox(height: PraniSpacing.xl),
                PraniPrimaryButton(
                  label: 'আবেদন শুরু করুন',
                  onPressed: () => context.push(
                    AiTechnicianApplicationFormScreen.routePath,
                    extra: 0,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _Bullet {
  const _Bullet(this.icon, this.title, this.body);

  final IconData icon;
  final String title;
  final String body;
}

class _BulletTile extends StatelessWidget {
  const _BulletTile({required this.b});

  final _Bullet b;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: PraniSpacing.md),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(b.icon, color: scheme.primary, size: 26),
          const SizedBox(width: PraniSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  b.title,
                  style: textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w700,
                    color: scheme.onSurface,
                  ),
                ),
                const SizedBox(height: PraniSpacing.xxs),
                Text(
                  b.body,
                  style: PraniTextStyles.bodyMuted(
                    scheme,
                    textTheme,
                  ).copyWith(height: 1.42),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
