import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:pranidoctor_mobile/src/app/screen_padding.dart';
import 'package:pranidoctor_mobile/src/core/constants/pd_spacing.dart';
import 'package:pranidoctor_mobile/src/features/providers/application/provider_finder_providers.dart';
import 'package:pranidoctor_mobile/src/features/providers/presentation/doctor_list_screen.dart';
import 'package:pranidoctor_mobile/src/features/providers/presentation/technician_list_screen.dart';

/// Hub: choose doctor vs AI technician finder flows.
class ProviderFinderLandingScreen extends ConsumerStatefulWidget {
  const ProviderFinderLandingScreen({super.key});

  static const routePath = '/providers';
  static const routeName = 'providerFinderLanding';

  @override
  ConsumerState<ProviderFinderLandingScreen> createState() =>
      _ProviderFinderLandingScreenState();
}

class _ProviderFinderLandingScreenState
    extends ConsumerState<ProviderFinderLandingScreen> {
  final _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _emergencyPlaceholder(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        behavior: SnackBarBehavior.floating,
        content: Text('জরুরি সেবা অনুরোধ — পরবর্তী আপডেটে যুক্ত হবে।'),
      ),
    );
  }

  void _applyNameToDoctorQuery() {
    final t = _searchController.text.trim();
    final q = ref.read(doctorListQueryProvider);
    ref
        .read(doctorListQueryProvider.notifier)
        .apply(
          q.withFilters(
            nameSearch: t.isEmpty ? null : t,
            clearNameSearch: t.isEmpty,
          ),
        );
  }

  void _applyNameToTechnicianQuery() {
    final t = _searchController.text.trim();
    final q = ref.read(technicianListQueryProvider);
    ref
        .read(technicianListQueryProvider.notifier)
        .apply(
          q.withFilters(
            nameSearch: t.isEmpty ? null : t,
            clearNameSearch: t.isEmpty,
          ),
        );
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final pad = pdScreenPadding(context);
    final maxW = pdReadableMaxWidth(context);

    return Scaffold(
      appBar: AppBar(title: const Text('ডাক্তার ও টেকনিশিয়ান')),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: pad.copyWith(top: PdSpacing.md, bottom: PdSpacing.xl),
          child: Center(
            child: ConstrainedBox(
              constraints: BoxConstraints(maxWidth: maxW),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    'আপনার এলাকা ও পশুর প্রয়োজন অনুযায় ডাক্তার বা এআই টেকনিশিয়ান খুঁজুন।',
                    style: textTheme.bodyLarge?.copyWith(
                      color: scheme.onSurfaceVariant,
                    ),
                  ),
                  const SizedBox(height: PdSpacing.lg),
                  Text('খুঁজুন ও ফিল্টার', style: textTheme.titleSmall),
                  const SizedBox(height: PdSpacing.xs),
                  TextField(
                    controller: _searchController,
                    textInputAction: TextInputAction.search,
                    decoration: const InputDecoration(
                      border: OutlineInputBorder(),
                      hintText: 'নাম দিয়ে খুঁজুন (সার্ভার ও তালিকায় প্রয়োগ)',
                      prefixIcon: Icon(Icons.search),
                    ),
                    onSubmitted: (_) => _applyNameToDoctorQuery(),
                  ),
                  const SizedBox(height: PdSpacing.sm),
                  Text(
                    'এলাকা ও সেবার ধরন নির্বাচন করতে তালিকা খুলুন; সেখানে বিস্তারিত ফিল্টার পাবেন।',
                    style: textTheme.bodySmall?.copyWith(
                      color: scheme.onSurfaceVariant,
                    ),
                  ),
                  const SizedBox(height: PdSpacing.xl),
                  FilledButton.icon(
                    onPressed: () {
                      _applyNameToDoctorQuery();
                      context.push(DoctorListScreen.routePath);
                    },
                    icon: const Icon(Icons.medical_services_outlined),
                    label: const Text('ডাক্তার খুঁজুন'),
                  ),
                  const SizedBox(height: PdSpacing.sm),
                  FilledButton.tonalIcon(
                    onPressed: () {
                      _applyNameToTechnicianQuery();
                      context.push(TechnicianListScreen.routePath);
                    },
                    icon: const Icon(Icons.smart_toy_outlined),
                    label: const Text('এআই টেকনিশিয়ান খুঁজুন'),
                  ),
                  const SizedBox(height: PdSpacing.xl),
                  OutlinedButton.icon(
                    onPressed: () => _emergencyPlaceholder(context),
                    icon: const Icon(Icons.emergency_outlined),
                    label: const Text('জরুরি সেবা (শীঘ্রই)'),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
