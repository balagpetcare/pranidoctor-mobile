import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:pranidoctor_mobile/src/app/screen_padding.dart';
import 'package:pranidoctor_mobile/src/core/assets/prani_assets.dart';
import 'package:pranidoctor_mobile/src/features/providers/application/provider_finder_providers.dart';
import 'package:pranidoctor_mobile/src/features/providers/data/provider_finder_repository.dart';

class TechnicianDetailScreen extends ConsumerWidget {
  const TechnicianDetailScreen({super.key, required this.technicianId});

  final String technicianId;

  static const routeName = 'technicianDetail';

  static String pathFor(String id) => '/providers/technicians/$id';

  void _placeholderSnack(BuildContext context, String label) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text('$label — শীঘ্রই যুক্ত হবে')));
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final async = ref.watch(technicianDetailProvider(technicianId));
    final hPad = pdScreenPadding(context).horizontal;
    final maxW = pdReadableMaxWidth(context);

    return Scaffold(
      appBar: AppBar(title: const Text('টেকনিশিয়ানের বিবরণ')),
      body: async.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Text(
              e is ProviderApiException ? e.message : 'লোড করা যায়নি',
              textAlign: TextAlign.center,
            ),
          ),
        ),
        data: (t) => SingleChildScrollView(
          padding: EdgeInsets.fromLTRB(hPad, 16, hPad, 32),
          child: Center(
            child: ConstrainedBox(
              constraints: BoxConstraints(maxWidth: maxW),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  PraniBrandHero(
                    assetPath: PraniAssets.aiTechnicianCattle,
                    height: 152,
                    fit: BoxFit.cover,
                    semanticLabel: 'গবাদি পশুর কৃত্রিম প্রজনন টেকনিশিয়ান সেবা',
                  ),
                  const SizedBox(height: 10),
                  Text(
                    'কৃত্রিম প্রজনন ও গবাদি পরিচর্যায় প্রশিক্ষিত টেকনিশিয়ান',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                      height: 1.35,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    t.name,
                    style: Theme.of(context).textTheme.headlineSmall,
                  ),
                  const SizedBox(height: 8),
                  if (t.serviceType != null && t.serviceType!.isNotEmpty)
                    Text(
                      t.serviceType!,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        color: Theme.of(context).colorScheme.primary,
                      ),
                    ),
                  if (t.certification != null &&
                      t.certification!.trim().isNotEmpty) ...[
                    const SizedBox(height: 6),
                    Text(
                      t.certification!,
                      style: Theme.of(context).textTheme.bodyLarge,
                    ),
                  ],
                  const SizedBox(height: 12),
                  _InfoRow(icon: Icons.place_outlined, text: t.areaText ?? '—'),
                  const SizedBox(height: 8),
                  _InfoRow(
                    icon: Icons.payments_outlined,
                    text: t.fee != null
                        ? 'ফি: ${t.fee} টাকা'
                        : 'ফি: নির্ধারিত নয়',
                  ),
                  const SizedBox(height: 8),
                  _InfoRow(icon: Icons.schedule, text: t.availability ?? '—'),
                  if (t.supportedAnimalTypes.isNotEmpty) ...[
                    const SizedBox(height: 12),
                    Text(
                      'পশুর ধরন',
                      style: Theme.of(context).textTheme.titleSmall,
                    ),
                    const SizedBox(height: 6),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: t.supportedAnimalTypes
                          .map((s) => Chip(label: Text(s)))
                          .toList(),
                    ),
                  ],
                  const SizedBox(height: 12),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      if (t.homeVisit)
                        const Chip(
                          avatar: Icon(Icons.agriculture_outlined, size: 18),
                          label: Text('মাঠ সেবা'),
                        ),
                      if (t.emergency)
                        Chip(
                          avatar: const Icon(
                            Icons.emergency_outlined,
                            size: 18,
                          ),
                          label: const Text('জরুরি'),
                        ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'রেটিং: ${t.rating == null ? 'শীঘ্রই' : t.rating.toString()}',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
                  ),
                  if (t.bio != null && t.bio!.trim().isNotEmpty) ...[
                    const SizedBox(height: 20),
                    Text(
                      'পরিচিতি',
                      style: Theme.of(context).textTheme.titleSmall,
                    ),
                    const SizedBox(height: 6),
                    Text(t.bio!, style: Theme.of(context).textTheme.bodyMedium),
                  ],
                  if (t.serviceCategories.isNotEmpty) ...[
                    const SizedBox(height: 20),
                    Text(
                      'সেবার ধরন',
                      style: Theme.of(context).textTheme.titleSmall,
                    ),
                    const SizedBox(height: 6),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: t.serviceCategories
                          .map((c) => Chip(label: Text(c.name)))
                          .toList(),
                    ),
                  ],
                  const SizedBox(height: 24),
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: () => _placeholderSnack(context, 'কল'),
                          icon: const Icon(Icons.call_outlined),
                          label: const Text('কল'),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: FilledButton.tonalIcon(
                          onPressed: () => _placeholderSnack(context, 'বুকিং'),
                          icon: const Icon(Icons.event_note_outlined),
                          label: const Text('বুক'),
                        ),
                      ),
                    ],
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

class _InfoRow extends StatelessWidget {
  const _InfoRow({required this.icon, required this.text});

  final IconData icon;
  final String text;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 22, color: Theme.of(context).colorScheme.primary),
        const SizedBox(width: 10),
        Expanded(
          child: Text(text, style: Theme.of(context).textTheme.bodyLarge),
        ),
      ],
    );
  }
}
