import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:pranidoctor_mobile/src/core/network/network_messages.dart';
import 'package:pranidoctor_mobile/src/design_system/prani_tokens.dart';
import 'package:pranidoctor_mobile/src/design_system/widgets/prani_async_list_status.dart';
import 'package:pranidoctor_mobile/src/design_system/widgets/prani_section_header.dart';
import 'package:pranidoctor_mobile/src/features/home/presentation/widgets/doctor_preview_card.dart';
import 'package:pranidoctor_mobile/src/features/home/presentation/widgets/home_empty_doctors_state.dart';
import 'package:pranidoctor_mobile/src/features/providers/application/provider_finder_providers.dart';
import 'package:pranidoctor_mobile/src/features/providers/presentation/doctor_detail_screen.dart';
import 'package:pranidoctor_mobile/src/features/providers/presentation/doctor_list_screen.dart';

/// “আপনার কাছাকাছি ডাক্তার” — horizontal list from [doctorsListProvider].
class NearbyDoctorsSection extends ConsumerWidget {
  const NearbyDoctorsSection({super.key});

  static const double _cardWidth = 268;
  static const double _rowHeight = 168;

  static Future<void> _openDoctor(BuildContext context, String id) async {
    if (id.trim().isEmpty) return;
    try {
      await context.push(DoctorDetailScreen.pathFor(id));
    } catch (e, stack) {
      assert(() {
        debugPrint('NearbyDoctorsSection: push failed: $e\n$stack');
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
        debugPrint('NearbyDoctorsSection: list route failed: $e\n$stack');
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
    final async = ref.watch(doctorsListProvider);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        PraniSectionHeader(
          title: 'আপনার কাছাকাছি ডাক্তার',
          actionLabel: 'সব দেখুন',
          onAction: () => _openDoctorList(context),
        ),
        const SizedBox(height: PraniSpacing.sm),
        async.when(
          loading: () => const PraniAsyncLoadingCard(height: 156),
          error: (_, _) => PraniAsyncErrorCard(
            title: 'ডাক্তার তালিকা লোড করা যায়নি',
            subtitle: NetworkMessages.bnServerUnreachable,
            actionLabel: 'আবার চেষ্টা করুন',
            onAction: () => ref.read(doctorsListProvider.notifier).refresh(),
          ),
          data: (bundle) {
            final list = bundle.doctors;
            if (list.isEmpty) {
              return HomeEmptyDoctorsState(
                onRetry: () => ref.read(doctorsListProvider.notifier).refresh(),
              );
            }
            final show = list.length > 8 ? list.sublist(0, 8) : list;
            return SizedBox(
              height: _rowHeight,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                physics: const BouncingScrollPhysics(),
                itemCount: show.length,
                separatorBuilder: (_, _) =>
                    const SizedBox(width: PraniSpacing.md),
                itemBuilder: (context, i) {
                  final d = show[i];
                  return SizedBox(
                    width: _cardWidth,
                    child: DoctorPreviewCard(
                      doctor: d,
                      onTap: () => _openDoctor(context, d.id),
                    ),
                  );
                },
              ),
            );
          },
        ),
      ],
    );
  }
}
