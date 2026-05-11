import 'package:flutter/material.dart';

import 'package:pranidoctor_mobile/src/app/screen_padding.dart';
import 'package:pranidoctor_mobile/src/design_system/widgets/prani_premium_card.dart';
import 'package:pranidoctor_mobile/src/design_system/widgets/prani_primary_cta_button.dart';
import 'package:pranidoctor_mobile/src/design_system/prani_tokens.dart';
import 'package:pranidoctor_mobile/src/features/profile/data/mobile_user_model.dart';

String profileRoleLabelBn(String? role) {
  final r = (role ?? 'guest').toLowerCase();
  switch (r) {
    case 'doctor':
      return 'ডাক্তার';
    case 'technician':
      return 'এআই টেকনিশিয়ান';
    case 'guest':
      return 'অতিথি';
    case 'customer':
    default:
      return 'গ্রাহক';
  }
}

String _avatarBadgeText(String name) {
  final t = name.trim();
  if (t.isEmpty) return '?';
  final runes = t.runes.toList();
  if (runes.length <= 2) return t;
  return String.fromCharCode(runes.first) + String.fromCharCode(runes.last);
}

bool _isNetworkPhotoUrl(String? u) {
  final t = u?.trim() ?? '';
  return t.startsWith('http://') || t.startsWith('https://');
}

/// Line shown when [user.isLocationConfigured] — never injects demo/fake area text.
String _profileLocationDisplayLine(MobileUser user) {
  if (MobileUser.areaLooksLikeRealUserLocation(user.area)) {
    return user.area!.trim();
  }
  final vn = user.villageName?.trim() ?? '';
  if (vn.isNotEmpty) return vn;
  return 'ঠিকানা সংরক্ষিত';
}

/// Profile hub header: cover band, overlapping avatar, name, role, phone, location CTA.
class ProfileHeaderCard extends StatelessWidget {
  const ProfileHeaderCard({
    super.key,
    required this.user,
    required this.onPrimaryAction,
  });

  final MobileUser user;
  final VoidCallback onPrimaryAction;

  bool get _wantsSetup =>
      !user.isRemoteProfile || user.missingProfileFieldsCount > 0;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final maxW = pdReadableMaxWidth(context);
    final missing = user.missingProfileFieldsCount;

    final phoneMissing =
        user.phone.trim().isEmpty ||
        user.phone.trim() == '—' ||
        user.phone == MobileUser.kPlaceholderPhoneBn;
    final displayPhone = phoneMissing
        ? MobileUser.kPlaceholderPhoneBn
        : user.phone;

    final hasRealLocation = user.isLocationConfigured;
    const locationSetupBn = 'লোকেশন সেটআপ করুন';

    final ctaLabel = _wantsSetup ? 'প্রোফাইল সেটআপ করুন' : 'প্রোফাইল এডিট করুন';

    return Center(
      child: ConstrainedBox(
        constraints: BoxConstraints(maxWidth: maxW),
        child: LayoutBuilder(
          builder: (context, constraints) {
            final w = constraints.maxWidth;
            final coverHeight = (w * 0.28).clamp(96.0, 136.0);
            const avatarR = 40.0;

            return PraniPremiumCard(
              radius: PraniRadii.xl,
              padding: EdgeInsets.zero,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(PraniRadii.xl),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    SizedBox(
                      height: coverHeight + avatarR,
                      child: Stack(
                        clipBehavior: Clip.none,
                        alignment: Alignment.topCenter,
                        children: [
                          Positioned(
                            top: 0,
                            left: 0,
                            right: 0,
                            height: coverHeight,
                            child: Stack(
                              fit: StackFit.expand,
                              children: [
                                DecoratedBox(
                                  decoration: BoxDecoration(
                                    gradient: LinearGradient(
                                      begin: Alignment.topLeft,
                                      end: Alignment.bottomRight,
                                      colors: [
                                        Color.lerp(
                                              scheme.primary,
                                              scheme.surface,
                                              0.12,
                                            ) ??
                                            scheme.primary,
                                        scheme.primary.withValues(alpha: 0.82),
                                        Color.lerp(
                                              scheme.tertiary,
                                              scheme.primary,
                                              0.35,
                                            ) ??
                                            scheme.tertiary,
                                      ],
                                    ),
                                  ),
                                ),
                                if (_isNetworkPhotoUrl(user.coverPhotoUrl))
                                  Image.network(
                                    user.coverPhotoUrl!.trim(),
                                    fit: BoxFit.cover,
                                    errorBuilder:
                                        (context, error, stackTrace) => Center(
                                          child: Icon(
                                            Icons.broken_image_outlined,
                                            size: (coverHeight * 0.35).clamp(
                                              28.0,
                                              48.0,
                                            ),
                                            color: scheme.surface.withValues(
                                              alpha: 0.65,
                                            ),
                                          ),
                                        ),
                                  )
                                else
                                  Center(
                                    child: Icon(
                                      Icons.landscape_outlined,
                                      size: (coverHeight * 0.42).clamp(
                                        32.0,
                                        56.0,
                                      ),
                                      color: scheme.surface.withValues(
                                        alpha: 0.55,
                                      ),
                                    ),
                                  ),
                              ],
                            ),
                          ),
                          Positioned(
                            top: coverHeight - avatarR,
                            child: _AvatarRing(
                              radius: avatarR,
                              scheme: scheme,
                              textTheme: textTheme,
                              user: user,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.fromLTRB(
                        PraniSpacing.xl,
                        PraniSpacing.sm,
                        PraniSpacing.xl,
                        PraniSpacing.xl,
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Text(
                            user.name,
                            textAlign: TextAlign.center,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: textTheme.titleLarge?.copyWith(
                              fontWeight: FontWeight.w700,
                              height: 1.25,
                            ),
                          ),
                          const SizedBox(height: PraniSpacing.sm),
                          Align(
                            alignment: Alignment.center,
                            child: FittedBox(
                              fit: BoxFit.scaleDown,
                              child: Chip(
                                label: Text(profileRoleLabelBn(user.role)),
                                visualDensity: VisualDensity.compact,
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 10,
                                ),
                                backgroundColor: scheme.secondaryContainer,
                                side: BorderSide.none,
                              ),
                            ),
                          ),
                          const SizedBox(height: PraniSpacing.md),
                          _contactRow(
                            context,
                            Icons.phone_outlined,
                            displayPhone,
                            muted: phoneMissing,
                          ),
                          const SizedBox(height: PraniSpacing.sm),
                          if (hasRealLocation)
                            _contactRow(
                              context,
                              Icons.place_outlined,
                              _profileLocationDisplayLine(user),
                              muted: false,
                            )
                          else
                            Material(
                              color: Colors.transparent,
                              child: InkWell(
                                onTap: onPrimaryAction,
                                borderRadius: BorderRadius.circular(
                                  PraniRadii.md,
                                ),
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(
                                    vertical: PraniSpacing.xs,
                                  ),
                                  child: _contactRow(
                                    context,
                                    Icons.add_location_alt_outlined,
                                    locationSetupBn,
                                    muted: false,
                                    emphasis: true,
                                  ),
                                ),
                              ),
                            ),
                          if (missing > 0) ...[
                            const SizedBox(height: PraniSpacing.lg),
                            Container(
                              padding: const EdgeInsets.all(PraniSpacing.md),
                              decoration: BoxDecoration(
                                color: scheme.primaryContainer.withValues(
                                  alpha: 0.35,
                                ),
                                borderRadius: BorderRadius.circular(
                                  PraniRadii.md,
                                ),
                              ),
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Icon(
                                    Icons.flag_outlined,
                                    size: 22,
                                    color: scheme.primary,
                                  ),
                                  const SizedBox(width: PraniSpacing.sm),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          'প্রোফাইল সম্পূর্ণ করুন',
                                          style: textTheme.titleSmall?.copyWith(
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                        const SizedBox(height: 4),
                                        Text(
                                          '${bnDigit0to9(missing)}টি তথ্য বাকি',
                                          style: textTheme.bodySmall?.copyWith(
                                            color: scheme.onSurfaceVariant,
                                            height: 1.35,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                          const SizedBox(height: PraniSpacing.xl),
                          PraniPrimaryCtaButton(
                            label: ctaLabel,
                            onPressed: onPrimaryAction,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _contactRow(
    BuildContext context,
    IconData icon,
    String text, {
    required bool muted,
    bool emphasis = false,
  }) {
    final scheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    Color textColor;
    FontStyle fontStyle = FontStyle.normal;
    FontWeight? weight;
    if (emphasis) {
      textColor = scheme.primary;
      weight = FontWeight.w600;
    } else if (muted) {
      textColor = scheme.onSurfaceVariant;
      fontStyle = FontStyle.italic;
    } else {
      textColor = scheme.onSurface;
    }
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(top: 2),
          child: Icon(icon, size: 22, color: scheme.primary),
        ),
        const SizedBox(width: PraniSpacing.sm),
        Expanded(
          child: Text(
            text,
            style: textTheme.bodyLarge?.copyWith(
              height: 1.35,
              color: textColor,
              fontStyle: fontStyle,
              fontWeight: weight,
            ),
          ),
        ),
      ],
    );
  }
}

class _AvatarRing extends StatelessWidget {
  const _AvatarRing({
    required this.radius,
    required this.scheme,
    required this.textTheme,
    required this.user,
  });

  final double radius;
  final ColorScheme scheme;
  final TextTheme textTheme;
  final MobileUser user;

  @override
  Widget build(BuildContext context) {
    final d = radius * 2;
    final netUrl = user.profilePhotoUrl?.trim();
    final useNetwork =
        netUrl != null && netUrl.isNotEmpty && _isNetworkPhotoUrl(netUrl);

    return DecoratedBox(
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(color: scheme.surface, width: 3),
        boxShadow: [
          BoxShadow(
            color: scheme.shadow.withValues(alpha: 0.12),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: CircleAvatar(
        radius: radius,
        backgroundColor: scheme.primaryContainer,
        foregroundColor: scheme.onPrimaryContainer,
        child: useNetwork
            ? ClipOval(
                child: SizedBox(
                  width: d,
                  height: d,
                  child: Image.network(
                    netUrl,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) => Text(
                      _avatarBadgeText(user.name),
                      style: textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ),
              )
            : Text(
                _avatarBadgeText(user.name),
                style: textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
              ),
      ),
    );
  }
}
