import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:pranidoctor_mobile/src/design_system/prani_design_system.dart';
import 'package:pranidoctor_mobile/src/features/profile/application/profile_providers.dart';
import 'package:pranidoctor_mobile/src/features/profile/data/mobile_user_model.dart';
import 'package:pranidoctor_mobile/src/features/profile/presentation/edit_profile_account_screen.dart';
import 'package:pranidoctor_mobile/src/features/profile/presentation/edit_profile_basic_screen.dart';
import 'package:pranidoctor_mobile/src/features/profile/presentation/edit_profile_contact_screen.dart';
import 'package:pranidoctor_mobile/src/features/profile/presentation/edit_profile_documents_screen.dart';
import 'package:pranidoctor_mobile/src/features/profile/presentation/edit_profile_location_screen.dart';
import 'package:pranidoctor_mobile/src/features/profile/presentation/edit_profile_photos_screen.dart';
import 'package:pranidoctor_mobile/src/features/profile/presentation/widgets/profile_settings_list_tile.dart';

/// Section hub for profile edits — each row opens a dedicated route.
class EditProfileScreen extends ConsumerWidget {
  const EditProfileScreen({super.key});

  static const routePath = '/profile/edit';
  static const routeName = 'profileEdit';

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final scheme = Theme.of(context).colorScheme;
    final asyncUser = ref.watch(mobileUserProvider);

    return PraniScaffold(
      title: 'প্রোফাইল সম্পাদনা',
      subtitle: 'বিভাগ অনুযায়ী সম্পাদনা',
      body: asyncUser.when(
        loading: () => const Center(
          child: PraniLoadingState(
            message: 'প্রোফাইল লোড হচ্ছে…',
            compact: false,
          ),
        ),
        error: (error, stackTrace) => Center(
          child: Padding(
            padding: const EdgeInsets.all(PraniSpacing.xl),
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
          final namePreview = user.name.trim().isEmpty
              ? 'নাম সেট করুন'
              : user.name.trim();
          final phoneMissing =
              user.phone.trim().isEmpty ||
              user.phone.trim() == '—' ||
              user.phone == MobileUser.kPlaceholderPhoneBn;
          final phonePreview = phoneMissing
              ? 'মোবাইল যোগ বা যাচাই করুন'
              : user.phone.trim();
          final hasLoc = user.isLocationConfigured;
          final locPreview = !hasLoc
              ? 'লোকেশন সেটআপ করুন'
              : MobileUser.areaLooksLikeRealUserLocation(user.area)
              ? user.area!.trim()
              : (user.villageName?.trim().isNotEmpty == true
                    ? user.villageName!.trim()
                    : 'ঠিকানা সংরক্ষিত');

          return ListView(
            padding: const EdgeInsets.all(PraniSpacing.xl),
            children: [
              Card(
                color: scheme.surfaceContainerLow,
                child: Column(
                  children: [
                    ProfileSettingsListTile(
                      icon: Icons.photo_library_outlined,
                      title: 'ছবি ও কভার',
                      subtitle: 'প্রোফাইল ও ব্যাকগ্রাউন্ড ছবি',
                      onTap: () =>
                          context.push(EditProfilePhotosScreen.routePath),
                    ),
                    const Divider(height: 1),
                    ProfileSettingsListTile(
                      icon: Icons.badge_outlined,
                      title: 'মৌলিক তথ্য',
                      subtitle: namePreview,
                      onTap: () =>
                          context.push(EditProfileBasicScreen.routePath),
                    ),
                    const Divider(height: 1),
                    ProfileSettingsListTile(
                      icon: Icons.contact_phone_outlined,
                      title: 'যোগাযোগ',
                      subtitle: phonePreview,
                      onTap: () =>
                          context.push(EditProfileContactScreen.routePath),
                    ),
                    const Divider(height: 1),
                    ProfileSettingsListTile(
                      icon: Icons.map_outlined,
                      title: 'ঠিকানা / লোকেশন',
                      subtitle: locPreview,
                      onTap: () =>
                          context.push(EditProfileLocationScreen.routePath),
                    ),
                    const Divider(height: 1),
                    ProfileSettingsListTile(
                      icon: Icons.folder_special_outlined,
                      title: 'ডকুমেন্ট / যাচাই তথ্য',
                      subtitle: 'নথি ও পরিচয় (শীঘ্রই)',
                      onTap: () =>
                          context.push(EditProfileDocumentsScreen.routePath),
                    ),
                    const Divider(height: 1),
                    ProfileSettingsListTile(
                      icon: Icons.manage_accounts_outlined,
                      title: 'অ্যাকাউন্ট সেটিংস',
                      subtitle: 'লগআউট ও অ্যাপ পছন্দ',
                      onTap: () =>
                          context.push(EditProfileAccountScreen.routePath),
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
