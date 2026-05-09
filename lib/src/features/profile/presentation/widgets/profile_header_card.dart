import 'package:flutter/material.dart';

import 'package:pranidoctor_mobile/src/app/screen_padding.dart';
import 'package:pranidoctor_mobile/src/core/assets/prani_assets.dart';
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

/// Hero card: brand row, avatar, name, role chip, contact rows, completion hint, primary CTA.
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

    final areaMissing =
        user.area == null ||
        user.area!.trim().isEmpty ||
        user.area == MobileUser.kPlaceholderAreaBn ||
        user.area == 'এলাকা সেট করা হয়নি';
    final displayArea = areaMissing
        ? MobileUser.kPlaceholderAreaBn
        : user.area!.trim();

    final ctaLabel = _wantsSetup ? 'প্রোফাইল সেটআপ করুন' : 'প্রোফাইল এডিট করুন';

    return Card(
      elevation: 2,
      shadowColor: const Color(0x141F2937),
      child: Padding(
        padding: const EdgeInsets.all(PraniSpacing.xl),
        child: Center(
          child: ConstrainedBox(
            constraints: BoxConstraints(maxWidth: maxW),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Row(
                  children: [
                    Image.asset(
                      PraniAssets.primaryLogo,
                      height: 28,
                      fit: BoxFit.contain,
                      semanticLabel: 'প্রাণী ডাক্তার লোগো',
                      cacheWidth: PraniAssetDecode.logoHeaderPx,
                      cacheHeight: PraniAssetDecode.logoHeaderPx,
                    ),
                    const SizedBox(width: PraniSpacing.sm),
                    Text(
                      'প্রাণী ডাক্তার',
                      style: textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w600,
                        color: scheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: PraniSpacing.xl),
                Align(
                  alignment: Alignment.center,
                  child: CircleAvatar(
                    radius: 44,
                    backgroundColor: scheme.primaryContainer,
                    foregroundColor: scheme.onPrimaryContainer,
                    child: user.profilePhotoUrl != null
                        ? ClipOval(
                            child: SizedBox(
                              width: 88,
                              height: 88,
                              child: Image.network(
                                user.profilePhotoUrl!,
                                fit: BoxFit.cover,
                                errorBuilder: (context, error, stackTrace) =>
                                    Text(
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
                ),
                const SizedBox(height: PraniSpacing.lg),
                Text(
                  user.name,
                  textAlign: TextAlign.center,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: PraniSpacing.sm),
                Align(
                  alignment: Alignment.center,
                  child: Chip(
                    label: Text(profileRoleLabelBn(user.role)),
                    visualDensity: VisualDensity.compact,
                    padding: const EdgeInsets.symmetric(horizontal: 10),
                    backgroundColor: scheme.secondaryContainer,
                    side: BorderSide.none,
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
                _contactRow(
                  context,
                  Icons.place_outlined,
                  displayArea,
                  muted: areaMissing,
                ),
                if (missing > 0) ...[
                  const SizedBox(height: PraniSpacing.lg),
                  Container(
                    padding: const EdgeInsets.all(PraniSpacing.md),
                    decoration: BoxDecoration(
                      color: scheme.primaryContainer.withValues(alpha: 0.35),
                      borderRadius: BorderRadius.circular(PraniRadii.md),
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
                            crossAxisAlignment: CrossAxisAlignment.start,
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
                FilledButton(onPressed: onPrimaryAction, child: Text(ctaLabel)),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _contactRow(
    BuildContext context,
    IconData icon,
    String text, {
    required bool muted,
  }) {
    final scheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
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
              color: muted ? scheme.onSurfaceVariant : scheme.onSurface,
              fontStyle: muted ? FontStyle.italic : FontStyle.normal,
            ),
          ),
        ),
      ],
    );
  }
}
