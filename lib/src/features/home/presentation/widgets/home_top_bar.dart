import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:pranidoctor_mobile/src/design_system/prani_tokens.dart';
import 'package:pranidoctor_mobile/src/features/locations/application/guest_location_preference.dart';
import 'package:pranidoctor_mobile/src/features/notifications/presentation/widgets/notification_bell_icon_button.dart';
import 'package:pranidoctor_mobile/src/features/profile/application/profile_providers.dart';
import 'package:pranidoctor_mobile/src/features/profile/data/mobile_user_model.dart';

/// Location row + notifications + optional quick booking entry.
class HomeTopBar extends ConsumerWidget {
  const HomeTopBar({
    super.key,
    required this.onOpenNotifications,
    required this.onQuickBooking,
    required this.onLocationTap,
  });

  final VoidCallback onOpenNotifications;
  final VoidCallback onQuickBooking;
  final VoidCallback onLocationTap;

  /// Shown when neither guest nor profile [area] is set — not a real address.
  static const String _neutralLocationHintBn = 'লোকেশন সেট করুন';

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final scheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final userAsync = ref.watch(mobileUserProvider);
    final guestAsync = ref.watch(guestLocationPreferenceProvider);

    final location = guestAsync.maybeWhen(
      data: (g) {
        if (g.hasSavedSelection) {
          final c = g.compactLocationLabelBn.trim();
          return c.isEmpty ? 'এলাকা নির্বাচিত' : c;
        }
        return null;
      },
      orElse: () => null,
    );

    final resolvedLocation =
        location ??
        userAsync.maybeWhen(
          data: (u) {
            final a = u.area?.trim();
            if (a != null &&
                a.isNotEmpty &&
                a != 'এলাকা সেট করা হয়নি' &&
                a != MobileUser.kPlaceholderAreaBn) {
              return a;
            }
            return null;
          },
          orElse: () => null,
        ) ??
        _neutralLocationHintBn;

    final hintGuest = guestAsync.maybeWhen(
      data: (g) => g.promptCompleted && !g.hasSavedSelection,
      orElse: () => false,
    );

    final chipTitle = hintGuest ? 'লোকেশন সেট করুন' : resolvedLocation;

    return Padding(
      padding: const EdgeInsets.fromLTRB(
        0,
        PraniSpacing.xxs,
        0,
        PraniSpacing.md,
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Expanded(
            child: Material(
              color: scheme.surfaceContainerLow,
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(PraniRadii.md),
                side: BorderSide(
                  color: scheme.outlineVariant.withValues(alpha: 0.55),
                ),
              ),
              clipBehavior: Clip.antiAlias,
              child: InkWell(
                borderRadius: BorderRadius.circular(PraniRadii.md),
                onTap: onLocationTap,
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    vertical: PraniSpacing.sm,
                    horizontal: PraniSpacing.sm,
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.place_rounded,
                        color: scheme.primary,
                        size: 22,
                      ),
                      const SizedBox(width: PraniSpacing.xs),
                      Expanded(
                        child: Text(
                          chipTitle,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: textTheme.titleSmall?.copyWith(
                            fontWeight: FontWeight.w600,
                            color: scheme.onSurface,
                            letterSpacing: -0.1,
                          ),
                        ),
                      ),
                      Icon(
                        Icons.keyboard_arrow_down_rounded,
                        color: scheme.onSurfaceVariant,
                        size: 22,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
          IconButton(
            tooltip: 'দ্রুত বুকিং',
            style: IconButton.styleFrom(
              foregroundColor: scheme.onSurfaceVariant,
              minimumSize: const Size(48, 48),
            ),
            onPressed: onQuickBooking,
            icon: const Icon(Icons.event_available_rounded, size: 24),
          ),
          NotificationBellIconButton(onPressed: onOpenNotifications),
        ],
      ),
    );
  }
}
