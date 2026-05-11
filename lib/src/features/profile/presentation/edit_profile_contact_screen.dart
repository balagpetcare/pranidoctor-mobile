import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:pranidoctor_mobile/src/app/screen_padding.dart';
import 'package:pranidoctor_mobile/src/design_system/prani_design_system.dart';
import 'package:pranidoctor_mobile/src/features/profile/application/profile_providers.dart';
import 'package:pranidoctor_mobile/src/features/profile/data/mobile_user_model.dart';

/// Phone read-only — number change requires OTP flow (not implemented here).
class EditProfileContactScreen extends ConsumerWidget {
  const EditProfileContactScreen({super.key});

  static const routePath = '/profile/edit/contact';
  static const routeName = 'profileEditContact';

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final scheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final pad = pdScreenPadding(context);
    final asyncUser = ref.watch(mobileUserProvider);

    return PraniScaffold(
      title: 'যোগাযোগ',
      subtitle: 'মোবাইল নম্বর',
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
          final phoneMissing =
              user.phone.trim().isEmpty ||
              user.phone.trim() == '—' ||
              user.phone == MobileUser.kPlaceholderPhoneBn;
          final displayPhone = phoneMissing
              ? MobileUser.kPlaceholderPhoneBn
              : user.phone;

          return ListView(
            padding: pad.copyWith(top: PraniSpacing.md, bottom: 32),
            children: [
              PraniPremiumCard(
                padding: const EdgeInsets.all(PraniSpacing.xl),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text(
                      'মোবাইল নম্বর',
                      style: textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: PraniSpacing.md),
                    InputDecorator(
                      decoration: InputDecoration(
                        border: const OutlineInputBorder(),
                        fillColor: scheme.surfaceContainerHighest.withValues(
                          alpha: 0.5,
                        ),
                        filled: true,
                      ),
                      child: Row(
                        children: [
                          Icon(Icons.phone_outlined, color: scheme.primary),
                          const SizedBox(width: PraniSpacing.md),
                          Expanded(
                            child: Text(
                              displayPhone,
                              style: textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.w600,
                                color: phoneMissing
                                    ? scheme.onSurfaceVariant
                                    : scheme.onSurface,
                                fontStyle: phoneMissing
                                    ? FontStyle.italic
                                    : FontStyle.normal,
                              ),
                            ),
                          ),
                          Icon(Icons.lock_outline, color: scheme.outline),
                        ],
                      ),
                    ),
                    const SizedBox(height: PraniSpacing.lg),
                    DecoratedBox(
                      decoration: BoxDecoration(
                        color: scheme.primaryContainer.withValues(alpha: 0.35),
                        borderRadius: BorderRadius.circular(PraniRadii.md),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(PraniSpacing.md),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Icon(
                              Icons.info_outline_rounded,
                              size: 22,
                              color: scheme.onPrimaryContainer,
                            ),
                            const SizedBox(width: PraniSpacing.sm),
                            Expanded(
                              child: Text(
                                'মোবাইল নম্বর পরিবর্তন করতে OTP যাচাই প্রয়োজন। '
                                'এই পাতা থেকে নম্বর বদলানো বা সম্পাদনা করা যাবে না।',
                                style: textTheme.bodyMedium?.copyWith(
                                  color: scheme.onSurface,
                                  height: 1.45,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
