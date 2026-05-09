import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:pranidoctor_mobile/src/design_system/prani_tokens.dart';
import 'package:pranidoctor_mobile/src/features/notifications/presentation/widgets/notification_bell_icon_button.dart';
import 'package:pranidoctor_mobile/src/features/profile/application/profile_providers.dart';
import 'package:pranidoctor_mobile/src/features/profile/presentation/area_setting_screen.dart';

/// Location row + notifications + optional quick booking entry.
class CustomerHomeTopBar extends ConsumerWidget {
  const CustomerHomeTopBar({
    super.key,
    required this.onOpenNotifications,
    required this.onQuickBooking,
  });

  final VoidCallback onOpenNotifications;
  final VoidCallback onQuickBooking;

  static const String _defaultLocation = 'ঢাকা, বাংলাদেশ';

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final scheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final userAsync = ref.watch(mobileUserProvider);

    final location = userAsync.maybeWhen(
      data: (u) {
        final a = u.area?.trim();
        if (a != null && a.isNotEmpty && a != 'এলাকা সেট করা হয়নি') {
          return a;
        }
        return _defaultLocation;
      },
      orElse: () => _defaultLocation,
    );

    return Padding(
      padding: const EdgeInsets.fromLTRB(
        PraniSpacing.xs,
        PraniSpacing.xxs,
        PraniSpacing.xs,
        PraniSpacing.sm,
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Expanded(
            child: InkWell(
              borderRadius: BorderRadius.circular(PraniRadii.md),
              onTap: () {
                try {
                  context.push(AreaSettingScreen.routePath);
                } catch (_) {
                  // Router not ready — ignore; area stays readable.
                }
              },
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  vertical: PraniSpacing.xxs,
                  horizontal: PraniSpacing.xs,
                ),
                child: Row(
                  children: [
                    Icon(Icons.place_outlined, color: scheme.primary, size: 22),
                    const SizedBox(width: PraniSpacing.xs),
                    Expanded(
                      child: Text(
                        location,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.w600,
                          color: scheme.onSurface,
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
          IconButton(
            tooltip: 'দ্রুত বুকিং',
            onPressed: onQuickBooking,
            icon: Icon(
              Icons.event_available_outlined,
              color: scheme.onSurfaceVariant,
            ),
          ),
          NotificationBellIconButton(onPressed: onOpenNotifications),
        ],
      ),
    );
  }
}
