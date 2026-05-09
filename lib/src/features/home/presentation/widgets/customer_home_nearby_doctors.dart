import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:pranidoctor_mobile/src/design_system/prani_tokens.dart';
import 'package:pranidoctor_mobile/src/features/providers/application/provider_finder_providers.dart';
import 'package:pranidoctor_mobile/src/features/providers/data/provider_models.dart';
import 'package:pranidoctor_mobile/src/features/providers/presentation/doctor_detail_screen.dart';
import 'package:pranidoctor_mobile/src/features/providers/presentation/doctor_list_screen.dart';

/// “আপনার কাছাকাছি ডাক্তার” — horizontal list from [doctorsListProvider].
class CustomerHomeNearbyDoctors extends ConsumerWidget {
  const CustomerHomeNearbyDoctors({super.key});

  static const double _cardWidth = 268;
  static const double _rowHeight = 168;

  static Future<void> _openDoctor(BuildContext context, String id) async {
    if (id.trim().isEmpty) return;
    try {
      await context.push(DoctorDetailScreen.pathFor(id));
    } catch (e, stack) {
      assert(() {
        debugPrint('CustomerHomeNearbyDoctors: push failed: $e\n$stack');
        return true;
      }());
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            behavior: SnackBarBehavior.floating,
            content: Text('বিবরণ খুলতে সমস্যা হয়েছে।'),
          ),
        );
      }
    }
  }

  static void _openDoctorList(BuildContext context) {
    try {
      context.pushNamed(DoctorListScreen.routeName);
    } catch (e, stack) {
      assert(() {
        debugPrint('CustomerHomeNearbyDoctors: list route failed: $e\n$stack');
        return true;
      }());
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            behavior: SnackBarBehavior.floating,
            content: Text('তালিকা খুলতে সমস্যা হয়েছে।'),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final scheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final async = ref.watch(doctorsListProvider);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                'আপনার কাছাকাছি ডাক্তার',
                style: textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
            TextButton(
              onPressed: () => _openDoctorList(context),
              child: const Text('সব দেখুন'),
            ),
          ],
        ),
        const SizedBox(height: PraniSpacing.xs),
        SizedBox(
          height: _rowHeight,
          child: async.when(
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (e, _) => _ErrorRow(
              message: 'ডাক্তারের তালিকা লোড করা যায়নি।',
              onRetry: () => ref.read(doctorsListProvider.notifier).refresh(),
            ),
            data: (bundle) {
              final list = bundle.doctors;
              if (list.isEmpty) {
                return Center(
                  child: Text(
                    'কাছাকাছি কোনো ডাক্তার পাওয়া যায়নি।',
                    textAlign: TextAlign.center,
                    style: textTheme.bodyMedium?.copyWith(
                      color: scheme.onSurfaceVariant,
                    ),
                  ),
                );
              }
              final show = list.length > 8 ? list.sublist(0, 8) : list;
              return ListView.separated(
                scrollDirection: Axis.horizontal,
                physics: const BouncingScrollPhysics(),
                itemCount: show.length,
                separatorBuilder: (_, _) =>
                    const SizedBox(width: PraniSpacing.md),
                itemBuilder: (context, i) {
                  final d = show[i];
                  return SizedBox(
                    width: _cardWidth,
                    child: _HomeDoctorMiniCard(
                      doctor: d,
                      onTap: () => _openDoctor(context, d.id),
                    ),
                  );
                },
              );
            },
          ),
        ),
      ],
    );
  }
}

class _ErrorRow extends StatelessWidget {
  const _ErrorRow({required this.message, required this.onRetry});

  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: PraniSpacing.xl),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              message,
              textAlign: TextAlign.center,
              style: textTheme.bodyMedium?.copyWith(
                color: scheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: PraniSpacing.sm),
            FilledButton.tonal(
              onPressed: onRetry,
              child: const Text('আবার চেষ্টা করুন'),
            ),
          ],
        ),
      ),
    );
  }
}

class _HomeDoctorMiniCard extends StatelessWidget {
  const _HomeDoctorMiniCard({required this.doctor, required this.onTap});

  final DoctorSummary doctor;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final name = doctor.name.trim().isEmpty ? 'নাম পাওয়া যায়নি' : doctor.name;
    final qual = doctor.degreeOrQualification?.trim();
    final ratingText = doctor.rating != null ? '★ ${doctor.rating}' : '★ —';
    const distancePlaceholder = 'দূরত্ব: শীঘ্রই';

    return Material(
      color: scheme.surface,
      elevation: 2,
      shadowColor: const Color(0x121F2937),
      surfaceTintColor: Colors.transparent,
      borderRadius: BorderRadius.circular(PraniRadii.lg),
      child: InkWell(
        borderRadius: BorderRadius.circular(PraniRadii.lg),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(PraniSpacing.md),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              CircleAvatar(
                radius: 28,
                backgroundColor: scheme.primaryContainer,
                child: Icon(Icons.person_rounded, color: scheme.primary),
              ),
              const SizedBox(width: PraniSpacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      name,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    if (qual != null && qual.isNotEmpty) ...[
                      const SizedBox(height: PraniSpacing.xxs),
                      Text(
                        qual,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: textTheme.bodySmall?.copyWith(
                          color: scheme.onSurfaceVariant,
                          height: 1.3,
                        ),
                      ),
                    ],
                    const Spacer(),
                    Text(
                      ratingText,
                      style: textTheme.labelLarge?.copyWith(
                        color: scheme.onSurfaceVariant,
                      ),
                    ),
                    Text(
                      distancePlaceholder,
                      style: textTheme.labelSmall?.copyWith(
                        color: scheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
