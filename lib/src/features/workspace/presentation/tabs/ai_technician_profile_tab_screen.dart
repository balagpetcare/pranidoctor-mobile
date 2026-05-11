import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'package:pranidoctor_mobile/src/design_system/prani_tokens.dart';
import 'package:pranidoctor_mobile/src/features/ai_technician_application/presentation/ai_technician_application_form_screen.dart';
import 'package:pranidoctor_mobile/src/features/ai_technician_application/presentation/ai_technician_application_status_screen.dart';
import 'package:pranidoctor_mobile/src/features/professional_profile/domain/professional_persona.dart';
import 'package:pranidoctor_mobile/src/features/professional_profile/presentation/professional_profile_hub_screen.dart';

/// AI technician "Profile" tab — enterprise profile hub + legacy shortcuts.
class AiTechnicianProfileTabScreen extends StatelessWidget {
  const AiTechnicianProfileTabScreen({super.key});

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
          'পেশাদার প্রোফাইল',
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w700,
              ),
        ),
        const SizedBox(height: PraniSpacing.sm),
        Text(
          'সম্পূর্ণ প্রোফাইল ম্যানেজমেন্ট, মিডিয়া আপলোড ও যাচাইকরণ।',
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
                  'বিভাগ, সম্পূর্ণতা %, নথি ও মিডিয়া — স্বয়ংক্রিয় সংরক্ষণ',
                ),
                trailing: const Icon(Icons.chevron_right),
                onTap: () => context.push(
                  ProfessionalProfileHubScreen.routeLocation(
                    ProfessionalPersona.aiTechnician,
                  ),
                ),
              ),
              const Divider(height: 1),
              ListTile(
                leading: Icon(Icons.edit_outlined, color: scheme.primary),
                title: const Text('সম্পূর্ণ আবেদন ফরম'),
                trailing: const Icon(Icons.chevron_right),
                onTap: () => context.push(
                  AiTechnicianApplicationFormScreen.routePath,
                ),
              ),
              const Divider(height: 1),
              ListTile(
                leading: Icon(Icons.verified_outlined, color: scheme.primary),
                title: const Text('যাচাইকরণ ও আবেদন'),
                trailing: const Icon(Icons.chevron_right),
                onTap: () => context.push(
                  AiTechnicianApplicationStatusScreen.routePath,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
