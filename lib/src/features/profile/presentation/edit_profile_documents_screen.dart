import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:go_router/go_router.dart';

import 'package:pranidoctor_mobile/src/app/screen_padding.dart';
import 'package:pranidoctor_mobile/src/design_system/prani_design_system.dart';
import 'package:pranidoctor_mobile/src/features/ai_technician_application/presentation/ai_technician_application_entry_screen.dart';
import 'package:pranidoctor_mobile/src/features/profile/application/profile_providers.dart';

/// Customer profile has no document list on `GET /api/mobile/me` yet — coming-soon UX.
/// AI technician documents live under the separate technician module (real navigation only).
class EditProfileDocumentsScreen extends ConsumerWidget {
  const EditProfileDocumentsScreen({super.key});

  static const routePath = '/profile/edit/documents';
  static const routeName = 'profileEditDocuments';

  static const _kComingSoonTitle = 'ডকুমেন্ট আপলোড শীঘ্রই আসছে';

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final scheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final pad = pdScreenPadding(context);
    final asyncUser = ref.watch(mobileUserProvider);

    return PraniScaffold(
      title: 'ডকুমেন্ট / যাচাই তথ্য',
      subtitle: 'নথি ও পরিচয়',
      body: asyncUser.when(
        loading: () => const Center(
          child: PraniLoadingState(
            message: 'প্রোফাইল লোড হচ্ছে…',
            compact: false,
          ),
        ),
        error: (error, stackTrace) => Center(
          child: Padding(
            padding: pad,
            child: PraniErrorState(
              title: 'লোড ব্যর্থ',
              message: 'প্রোফাইল লোড করা যায়নি।',
              retryLabel: 'আবার চেষ্টা',
              onRetry: () => ref.invalidate(mobileUserProvider),
              detail: null,
              compact: false,
              boxed: true,
            ),
          ),
        ),
        data: (user) {
          final role = (user.role ?? 'customer').toLowerCase();
          final isTechnicianRole = role == 'technician';

          return ListView(
            padding: pad.copyWith(top: PraniSpacing.md, bottom: 32),
            children: [
              PraniPremiumCard(
                padding: const EdgeInsets.all(PraniSpacing.xl),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Icon(
                      Icons.folder_outlined,
                      size: 48,
                      color: scheme.primary.withValues(alpha: 0.85),
                    ),
                    const SizedBox(height: PraniSpacing.md),
                    Text(
                      _kComingSoonTitle,
                      textAlign: TextAlign.center,
                      style: textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: PraniSpacing.sm),
                    Text(
                      'গ্রাহক প্রোফাইলে নথি আপলোড এখনো চালু নয়। '
                      'ব্যাকএন্ডে API যুক্ত হলে এখানে তালিকা ও আপলোড দেখানো হবে।',
                      textAlign: TextAlign.center,
                      style: textTheme.bodyMedium?.copyWith(
                        color: scheme.onSurfaceVariant,
                        height: 1.45,
                      ),
                    ),
                  ],
                ),
              ),
              if (isTechnicianRole) ...[
                const SizedBox(height: PraniSpacing.md),
                PraniPremiumCard(
                  padding: const EdgeInsets.all(PraniSpacing.xl),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Text(
                        'এআই টেকনিশিয়ান নথি',
                        style: textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: PraniSpacing.sm),
                      Text(
                        'টেকনিশিয়ান আবেদন ও নথি আলাদা মডিউলে সংরক্ষিত। '
                        'সেখানে আপলোড ও যাচাইয়ের বাস্তব অবস্থা দেখুন।',
                        style: textTheme.bodySmall?.copyWith(
                          color: scheme.onSurfaceVariant,
                          height: 1.4,
                        ),
                      ),
                      const SizedBox(height: PraniSpacing.md),
                      FilledButton.tonalIcon(
                        onPressed: () async {
                          try {
                            await context.push(
                              AiTechnicianApplicationEntryScreen.routePath,
                            );
                          } catch (e, stack) {
                            assert(() {
                              debugPrint(
                                'EditProfileDocuments: AI entry push failed: '
                                '$e\n$stack',
                              );
                              return true;
                            }());
                            if (context.mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  behavior: SnackBarBehavior.fixed,
                                  content: Text(
                                    'এআই টেকনিশিয়ান আবেদন খুলতে পারিনি।',
                                  ),
                                ),
                              );
                            }
                          }
                        },
                        icon: const Icon(Icons.engineering_outlined),
                        label: const Text('টেকনিশিয়ান নথি খুলুন'),
                      ),
                    ],
                  ),
                ),
              ],
            ],
          );
        },
      ),
    );
  }
}
