import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:pranidoctor_mobile/src/app/screen_padding.dart';
import 'package:pranidoctor_mobile/src/core/constants/pd_spacing.dart';
import 'package:pranidoctor_mobile/src/core/widgets/pd_async_states.dart';
import 'package:pranidoctor_mobile/src/features/providers/application/provider_finder_providers.dart';
import 'package:pranidoctor_mobile/src/features/providers/data/provider_finder_repository.dart';
import 'package:pranidoctor_mobile/src/features/providers/data/provider_kind.dart';
import 'package:pranidoctor_mobile/src/features/providers/data/provider_profile_model.dart';

/// Unified provider profile (doctor or AI technician).
class ProviderDetailScreen extends ConsumerWidget {
  const ProviderDetailScreen({
    super.key,
    required this.providerId,
    required this.kind,
  });

  final String providerId;
  final ProviderKind kind;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final async = ref.watch(providerProfileDetailProvider((providerId, kind)));
    final title = kind == ProviderKind.doctor
        ? 'ডাক্তারের বিবরণ'
        : 'টেকনিশিয়ানের বিবরণ';

    return Scaffold(
      appBar: AppBar(title: Text(title)),
      body: async.when(
        loading: () => const PdLoadingBody(message: 'লোড হচ্ছে…'),
        error: (e, _) => PdErrorBody(
          title: 'লোড করা যায়নি',
          message: e is ProviderApiException ? e.message : e.toString(),
          retryLabel: 'আবার চেষ্টা',
          onRetry: () =>
              ref.invalidate(providerProfileDetailProvider((providerId, kind))),
        ),
        data: (detail) => _ProviderDetailBody(detail: detail),
      ),
    );
  }
}

class _ProviderDetailBody extends StatelessWidget {
  const _ProviderDetailBody({required this.detail});

  final ProviderProfileDetail detail;

  void _requestPlaceholder(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        behavior: SnackBarBehavior.floating,
        content: Text('সেবা অনুরোধ করুন — পরবর্তী ধাপে যুক্ত হবে।'),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final s = detail.summary;
    final scheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final hPad = pdScreenPadding(context).horizontal;
    final maxW = pdReadableMaxWidth(context);

    return SingleChildScrollView(
      padding: EdgeInsets.fromLTRB(hPad, PdSpacing.md, hPad, PdSpacing.xl),
      child: Center(
        child: ConstrainedBox(
          constraints: BoxConstraints(maxWidth: maxW),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  CircleAvatar(
                    radius: 36,
                    backgroundColor: scheme.primaryContainer,
                    backgroundImage:
                        s.profilePhotoUrl != null &&
                            (s.profilePhotoUrl!.startsWith('http://') ||
                                s.profilePhotoUrl!.startsWith('https://'))
                        ? NetworkImage(s.profilePhotoUrl!)
                        : null,
                    child:
                        s.profilePhotoUrl != null &&
                            (s.profilePhotoUrl!.startsWith('http://') ||
                                s.profilePhotoUrl!.startsWith('https://'))
                        ? null
                        : Icon(
                            s.kind == ProviderKind.doctor
                                ? Icons.medical_services_outlined
                                : Icons.smart_toy_outlined,
                            size: 36,
                            color: scheme.onPrimaryContainer,
                          ),
                  ),
                  const SizedBox(width: PdSpacing.md),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(s.name, style: textTheme.headlineSmall),
                        const SizedBox(height: 4),
                        Text(
                          s.kind.labelBn,
                          style: textTheme.labelLarge?.copyWith(
                            color: scheme.primary,
                          ),
                        ),
                        if (s.titleOrQualification != null &&
                            s.titleOrQualification!.trim().isNotEmpty) ...[
                          const SizedBox(height: 6),
                          Text(
                            s.titleOrQualification!,
                            style: textTheme.titleMedium,
                          ),
                        ],
                        if (detail.certification != null &&
                            detail.certification!.trim().isNotEmpty) ...[
                          const SizedBox(height: 6),
                          Text(
                            detail.certification!,
                            style: textTheme.bodyLarge,
                          ),
                        ],
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: PdSpacing.md),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  Chip(
                    avatar: Icon(
                      Icons.payments_outlined,
                      size: 18,
                      color: scheme.primary,
                    ),
                    label: Text(
                      s.feeText != null && s.feeText!.trim().isNotEmpty
                          ? 'ফি ${s.feeText} টাকা'
                          : 'ফি — শীঘ্রই',
                    ),
                  ),
                  Chip(
                    avatar: Icon(
                      Icons.schedule,
                      size: 18,
                      color: scheme.secondary,
                    ),
                    label: Text(
                      s.availabilityText != null &&
                              s.availabilityText!.trim().isNotEmpty
                          ? s.availabilityText!
                          : 'উপলব্ধতা — শীঘ্রই',
                    ),
                  ),
                  if (s.homeVisit)
                    Chip(
                      avatar: Icon(
                        s.kind == ProviderKind.doctor
                            ? Icons.home_outlined
                            : Icons.agriculture_outlined,
                        size: 18,
                      ),
                      label: Text(
                        s.kind == ProviderKind.doctor
                            ? 'হোম ভিজিট'
                            : 'মাঠ সেবা',
                      ),
                    ),
                  if (s.emergency)
                    Chip(
                      avatar: const Icon(Icons.emergency_outlined, size: 18),
                      label: const Text('জরুরি সেবা'),
                    ),
                  Chip(
                    avatar: const Icon(Icons.video_call_outlined, size: 18),
                    label: Text(
                      s.onlineConsultation
                          ? 'অনলাইন পরামর্শ'
                          : 'অনলাইন — শীঘ্রই',
                    ),
                  ),
                  Chip(
                    label: Text(
                      s.rating != null ? 'রেটিং ${s.rating}' : 'রেটিং — শীঘ্রই',
                    ),
                  ),
                ],
              ),
              const SizedBox(height: PdSpacing.md),
              _InfoRow(
                icon: Icons.place_outlined,
                text: s.areaCoverageSummary?.trim().isNotEmpty == true
                    ? s.areaCoverageSummary!
                    : 'এলাকা — তথ্য শীঘ্রই',
              ),
              if (detail.areaRows.isNotEmpty) ...[
                const SizedBox(height: PdSpacing.sm),
                Text('এলাকা তালিকা', style: textTheme.titleSmall),
                const SizedBox(height: 4),
                ...detail.areaRows.map(
                  (line) => ListTile(
                    dense: true,
                    contentPadding: EdgeInsets.zero,
                    leading: Icon(
                      Icons.map_outlined,
                      size: 20,
                      color: scheme.primary,
                    ),
                    title: Text(line),
                  ),
                ),
              ],
              if (detail.villageRows.isNotEmpty) ...[
                const SizedBox(height: PdSpacing.sm),
                Text('গ্রাম / ওয়ার্ড', style: textTheme.titleSmall),
                ...detail.villageRows.map(
                  (line) => ListTile(
                    dense: true,
                    contentPadding: EdgeInsets.zero,
                    title: Text(line),
                  ),
                ),
              ],
              if (s.animalTypesSummary.isNotEmpty) ...[
                const SizedBox(height: PdSpacing.sm),
                Text('পশুর ধরন', style: textTheme.titleSmall),
                const SizedBox(height: 4),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: s.animalTypesSummary
                      .map((t) => Chip(label: Text(t)))
                      .toList(),
                ),
              ],
              if (detail.serviceCategoryLabels.isNotEmpty) ...[
                const SizedBox(height: PdSpacing.sm),
                Text('সেবার ধরন', style: textTheme.titleSmall),
                const SizedBox(height: 4),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: detail.serviceCategoryLabels
                      .map((c) => Chip(label: Text(c)))
                      .toList(),
                ),
              ],
              if (detail.experienceYears != null) ...[
                const SizedBox(height: PdSpacing.sm),
                Text(
                  'অভিজ্ঞতা: ${detail.experienceYears} বছর',
                  style: textTheme.bodyMedium,
                ),
              ],
              if (detail.bioFull != null &&
                  detail.bioFull!.trim().isNotEmpty) ...[
                const SizedBox(height: PdSpacing.md),
                Text('পরিচিতি', style: textTheme.titleSmall),
                const SizedBox(height: 4),
                Text(detail.bioFull!, style: textTheme.bodyMedium),
              ],
              const SizedBox(height: PdSpacing.xl),
              OutlinedButton.icon(
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      behavior: SnackBarBehavior.floating,
                      content: Text(
                        'জরুরি সহায়তা — পরবর্তী আপডেটে সরাসরি যোগাযোগ যুক্ত হবে।',
                      ),
                    ),
                  );
                },
                icon: const Icon(Icons.emergency_outlined),
                label: const Text('জরুরি সহায়তা'),
              ),
              const SizedBox(height: PdSpacing.sm),
              FilledButton(
                onPressed: () => _requestPlaceholder(context),
                child: const Text('সেবা অনুরোধ করুন — পরবর্তী ধাপে যুক্ত হবে'),
              ),
            ],
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
