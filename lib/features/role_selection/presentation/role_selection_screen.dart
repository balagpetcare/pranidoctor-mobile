import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../auth/customer/presentation/customer_login_screen.dart';
import '../../auth/doctor/presentation/doctor_login_screen.dart';
import '../../session/application/session_notifier.dart';

class RoleSelectionScreen extends ConsumerWidget {
  const RoleSelectionScreen({super.key});

  static const routePath = '/role';
  static const routeName = 'role';

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final scheme = Theme.of(context).colorScheme;
    return Scaffold(
      appBar: AppBar(
        title: const Text('Prani Doctor'),
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
        children: [
          Text(
            'আপনি কীভাবে চালিয়ে যেতে চান?',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 6),
          Text(
            'Choose how you want to continue',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: scheme.onSurfaceVariant,
                ),
          ),
          const SizedBox(height: 24),
          _RoleCard(
            icon: Icons.pets_outlined,
            titleBn: 'গ্রাহক',
            titleEn: 'Customer',
            subtitle: 'পোষা প্রাণি বা পশুপালন — চিকিৎসা অনুরোধ',
            onTap: () async {
              await ref.read(sessionNotifierProvider.notifier).setRole(AppRole.customer);
              if (context.mounted) {
                context.push(CustomerLoginScreen.routePath);
              }
            },
          ),
          const SizedBox(height: 14),
          _RoleCard(
            icon: Icons.medical_services_outlined,
            titleBn: 'চিকিৎসক',
            titleEn: 'Doctor',
            subtitle: 'নির্ধারিত কাজ ও রোগীর তথ্য',
            onTap: () async {
              await ref.read(sessionNotifierProvider.notifier).setRole(AppRole.doctor);
              if (context.mounted) {
                context.push(DoctorLoginScreen.routePath);
              }
            },
          ),
        ],
      ),
    );
  }
}

class _RoleCard extends StatelessWidget {
  const _RoleCard({
    required this.icon,
    required this.titleBn,
    required this.titleEn,
    required this.subtitle,
    required this.onTap,
  });

  final IconData icon;
  final String titleBn;
  final String titleEn;
  final String subtitle;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Material(
      color: scheme.surfaceContainerLowest,
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(18),
          child: Row(
            children: [
              CircleAvatar(
                radius: 26,
                backgroundColor: scheme.primaryContainer,
                child: Icon(icon, color: scheme.onPrimaryContainer, size: 28),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      titleBn,
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    Text(
                      titleEn,
                      style: Theme.of(context).textTheme.labelLarge?.copyWith(
                            color: scheme.primary,
                          ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      subtitle,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: scheme.onSurfaceVariant,
                          ),
                    ),
                  ],
                ),
              ),
              Icon(Icons.chevron_right, color: scheme.onSurfaceVariant),
            ],
          ),
        ),
      ),
    );
  }
}
