import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'package:pranidoctor_mobile/src/design_system/prani_tokens.dart';
import 'package:pranidoctor_mobile/src/features/knowledge_hub/presentation/knowledge_hub_home_screen.dart';
import 'package:pranidoctor_mobile/src/features/professional_profile/domain/professional_persona.dart';
import 'package:pranidoctor_mobile/src/features/professional_profile/presentation/professional_profile_hub_screen.dart';

/// Doctor workspace "Profile" tab — enterprise profile hub + knowledge hub.
class DoctorProfileTabScreen extends StatelessWidget {
  const DoctorProfileTabScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return ListView(
      padding: const EdgeInsets.symmetric(
        horizontal: PraniSpacing.pageHorizontal,
        vertical: PraniSpacing.xl,
      ),
      children: [
        Text(
          'চিকিৎসক প্রোফাইল',
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w700,
              ),
        ),
        const SizedBox(height: PraniSpacing.sm),
        Text(
          'পেশাদার বিবরণ, নথি, মিডিয়া ও যাচাইকরণ — এক হাব থেকে।',
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: scheme.onSurfaceVariant,
                height: 1.4,
              ),
        ),
        const SizedBox(height: PraniSpacing.xl),
        Card(
          child: Column(
            children: [
              ListTile(
                leading: Icon(Icons.hub_outlined, color: scheme.primary),
                title: const Text('এন্টারপ্রাইজ প্রোফাইল হাব'),
                subtitle: const Text(
                  'বিভাগ, সম্পূর্ণতা %, মিডিয়া ও স্বয়ংক্রিয় সংরক্ষণ',
                ),
                trailing: const Icon(Icons.chevron_right),
                onTap: () => context.push(
                  ProfessionalProfileHubScreen.routeLocation(
                    ProfessionalPersona.veterinaryDoctor,
                  ),
                ),
              ),
              const Divider(height: 1),
              ListTile(
                leading: Icon(Icons.menu_book_outlined, color: scheme.primary),
                title: const Text('জ্ঞানকেন্দ্র'),
                subtitle: const Text('নির্দেশনা ও নিবন্ধ'),
                trailing: const Icon(Icons.chevron_right),
                onTap: () => context.push(KnowledgeHubHomeScreen.routePath),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
