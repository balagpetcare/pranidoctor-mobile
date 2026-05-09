import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:pranidoctor_mobile/src/app/screen_padding.dart';
import 'package:pranidoctor_mobile/src/features/providers/application/provider_finder_providers.dart';
import 'package:pranidoctor_mobile/src/features/providers/data/provider_finder_repository.dart';

class DoctorDetailScreen extends ConsumerWidget {
  const DoctorDetailScreen({super.key, required this.doctorId});

  final String doctorId;

  static const routeName = 'doctorDetail';

  static String pathFor(String id) => '/providers/doctors/$id';

  void _placeholderSnack(BuildContext context, String label) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text('$label — শীঘ্রই যুক্ত হবে')));
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final async = ref.watch(doctorDetailProvider(doctorId));
    final hPad = pdScreenPadding(context).horizontal;
    final maxW = pdReadableMaxWidth(context);

    return Scaffold(
      appBar: AppBar(title: const Text('ডাক্তারের বিবরণ')),
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
        data: (d) => SingleChildScrollView(
          padding: EdgeInsets.fromLTRB(hPad, 16, hPad, 32),
          child: Center(
            child: ConstrainedBox(
              constraints: BoxConstraints(maxWidth: maxW),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    d.name,
                    style: Theme.of(context).textTheme.headlineSmall,
                  ),
                  const SizedBox(height: 8),
                  if (d.degreeOrQualification != null &&
                      d.degreeOrQualification!.isNotEmpty)
                    Text(
                      d.degreeOrQualification!,
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                  if (d.serviceType != null && d.serviceType!.isNotEmpty) ...[
                    const SizedBox(height: 4),
                    Text(
                      d.serviceType!,
                      style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        color: Theme.of(context).colorScheme.primary,
                      ),
                    ),
                  ],
                  const SizedBox(height: 12),
                  _InfoRow(icon: Icons.place_outlined, text: d.areaText ?? '—'),
                  const SizedBox(height: 8),
                  _InfoRow(
                    icon: Icons.payments_outlined,
                    text: d.fee != null
                        ? 'ফি: ${d.fee} টাকা'
                        : 'ফি: নির্ধারিত নয়',
                  ),
                  const SizedBox(height: 8),
                  _InfoRow(icon: Icons.schedule, text: d.availability ?? '—'),
                  const SizedBox(height: 12),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      if (d.homeVisit)
                        Chip(
                          avatar: const Icon(Icons.home_outlined, size: 18),
                          label: const Text('হোম ভিজিট'),
                        ),
                      if (d.emergency)
                        Chip(
                          avatar: const Icon(
                            Icons.emergency_outlined,
                            size: 18,
                          ),
                          label: const Text('জরুরি'),
                        ),
                      if (d.onlineConsultation)
                        const Chip(
                          avatar: Icon(Icons.video_call_outlined, size: 18),
                          label: Text('অনলাইন'),
                        ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'রেটিং: ${d.rating == null ? 'শীঘ্রই' : d.rating.toString()}',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
                  ),
                  if (d.bio != null && d.bio!.trim().isNotEmpty) ...[
                    const SizedBox(height: 20),
                    Text(
                      'পরিচিতি',
                      style: Theme.of(context).textTheme.titleSmall,
                    ),
                    const SizedBox(height: 6),
                    Text(d.bio!, style: Theme.of(context).textTheme.bodyMedium),
                  ],
                  if (d.experienceYears != null) ...[
                    const SizedBox(height: 12),
                    Text(
                      'অভিজ্ঞতা: ${d.experienceYears} বছর',
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                  ],
                  if (d.serviceCategories.isNotEmpty) ...[
                    const SizedBox(height: 20),
                    Text(
                      'সেবার ধরন',
                      style: Theme.of(context).textTheme.titleSmall,
                    ),
                    const SizedBox(height: 6),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: d.serviceCategories
                          .map((c) => Chip(label: Text(c.name)))
                          .toList(),
                    ),
                  ],
                  if (d.areas.isNotEmpty) ...[
                    const SizedBox(height: 16),
                    Text(
                      'এলাকা (তালিকা)',
                      style: Theme.of(context).textTheme.titleSmall,
                    ),
                    const SizedBox(height: 6),
                    ...d.areas.map(
                      (a) => ListTile(
                        dense: true,
                        contentPadding: EdgeInsets.zero,
                        title: Text(a.nameBn ?? a.name),
                        subtitle: a.slug != null ? Text(a.slug!) : null,
                      ),
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
