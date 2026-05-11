import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';

import 'package:pranidoctor_mobile/src/design_system/prani_page_insets.dart';
import 'package:pranidoctor_mobile/src/design_system/prani_tokens.dart';
import 'package:pranidoctor_mobile/src/design_system/widgets/prani_error_state.dart';
import 'package:pranidoctor_mobile/src/design_system/widgets/prani_form_card.dart';
import 'package:pranidoctor_mobile/src/design_system/widgets/prani_form_tokens.dart';
import 'package:pranidoctor_mobile/src/design_system/widgets/prani_buttons.dart';
import 'package:pranidoctor_mobile/src/design_system/widgets/prani_loading_state.dart';
import 'package:pranidoctor_mobile/src/design_system/widgets/prani_scaffold.dart';
import 'package:pranidoctor_mobile/src/features/profile/application/profile_providers.dart';
import 'package:pranidoctor_mobile/src/features/profile/data/mobile_profile_api_contract.dart';
import 'package:pranidoctor_mobile/src/features/profile/presentation/local_profile_image_file.dart';
import 'package:pranidoctor_mobile/src/features/profile/presentation/profile_photo_crop_flow.dart';

/// Profile + cover: pick, crop, compress, local preview; upload stub until API ready.
class EditProfilePhotosScreen extends ConsumerStatefulWidget {
  const EditProfilePhotosScreen({super.key});

  static const routePath = '/profile/edit/photos';
  static const routeName = 'profileEditPhotos';

  @override
  ConsumerState<EditProfilePhotosScreen> createState() =>
      _EditProfilePhotosScreenState();
}

class _EditProfilePhotosScreenState
    extends ConsumerState<EditProfilePhotosScreen> {
  String? _draftProfilePath;
  String? _draftCoverPath;
  bool _saving = false;

  ImageProvider<Object>? _networkImg(String? u) {
    final t = u?.trim() ?? '';
    if (t.isEmpty) return null;
    if (t.startsWith('http://') || t.startsWith('https://')) {
      return NetworkImage(t);
    }
    return null;
  }

  Future<ImageSource?> _askImageSource() {
    final scheme = Theme.of(context).colorScheme;
    return showModalBottomSheet<ImageSource>(
      context: context,
      showDragHandle: true,
      backgroundColor: scheme.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(PraniRadius.lg),
        ),
      ),
      builder: (ctx) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(
              PraniSpacing.xl,
              PraniSpacing.sm,
              PraniSpacing.xl,
              PraniSpacing.xl,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  'ছবির উৎস',
                  style: Theme.of(ctx).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: PraniSpacing.md),
                ListTile(
                  leading: const Icon(Icons.photo_library_outlined),
                  title: const Text('গ্যালারি'),
                  onTap: () => Navigator.pop(ctx, ImageSource.gallery),
                ),
                ListTile(
                  leading: const Icon(Icons.photo_camera_outlined),
                  title: const Text('ক্যামেরা'),
                  onTap: () => Navigator.pop(ctx, ImageSource.camera),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Future<void> _changeProfilePhoto() async {
    final src = await _askImageSource();
    if (src == null || !mounted) return;
    final path = await ProfilePhotoCropFlow.pickCropProfilePhoto(context, src);
    if (path != null && mounted) {
      setState(() => _draftProfilePath = path);
    }
  }

  Future<void> _changeCoverPhoto() async {
    final src = await _askImageSource();
    if (src == null || !mounted) return;
    final path = await ProfilePhotoCropFlow.pickCropCoverPhoto(context, src);
    if (path != null && mounted) {
      setState(() => _draftCoverPath = path);
    }
  }

  Future<void> _save() async {
    if (_draftProfilePath == null && _draftCoverPath == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('কোনো নতুন ছবি নেই। আগে ছবি বেছে নিন।')),
      );
      return;
    }
    setState(() => _saving = true);
    try {
      final repo = ref.read(profileRepositoryProvider);
      MobileProfilePhotoUploadResult? pr;
      MobileProfilePhotoUploadResult? cr;
      if (_draftProfilePath != null) {
        pr = await repo.uploadProfilePhoto(_draftProfilePath!);
      }
      if (_draftCoverPath != null) {
        cr = await repo.uploadCoverPhoto(_draftCoverPath!);
      }
      if (!mounted) return;

      if (pr?.status == MobileProfilePhotoUploadStatus.success) {
        setState(() => _draftProfilePath = null);
        ref.invalidate(mobileUserProvider);
      }
      if (cr?.status == MobileProfilePhotoUploadStatus.success) {
        setState(() => _draftCoverPath = null);
        ref.invalidate(mobileUserProvider);
      }

      final outs = <MobileProfilePhotoUploadResult>[?pr, ?cr];
      final failed = outs
          .where((r) => r.status == MobileProfilePhotoUploadStatus.failure)
          .toList();
      final notReady = outs
          .where(
            (r) => r.status == MobileProfilePhotoUploadStatus.endpointNotReady,
          )
          .toList();
      final ok = outs
          .where((r) => r.status == MobileProfilePhotoUploadStatus.success)
          .toList();

      String snackText;
      if (failed.isNotEmpty) {
        snackText = failed.first.messageBn ?? 'আপলোড ব্যর্থ।';
      } else if (ok.isNotEmpty) {
        snackText = notReady.isNotEmpty
            ? 'একটি ছবি সার্ভারে আপডেট হয়েছে; বাকিটি এখনো পাঠানো যায়নি।'
            : 'ছবি সার্ভারে আপডেট হয়েছে।';
      } else if (notReady.isNotEmpty) {
        snackText =
            notReady.first.messageBn ?? 'সার্ভারে আপলোড এখনো সক্রিয় নয়।';
      } else {
        snackText = 'সম্পন্ন।';
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          behavior: SnackBarBehavior.floating,
          content: Text(snackText),
          action: failed.isNotEmpty || notReady.isNotEmpty
              ? SnackBarAction(label: 'আবার চেষ্টা', onPressed: () => _save())
              : null,
        ),
      );
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  bool get _hasDraft => _draftProfilePath != null || _draftCoverPath != null;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final asyncUser = ref.watch(mobileUserProvider);

    if (kIsWeb) {
      return PraniScaffold(
        title: 'ছবি ও কভার',
        subtitle: 'প্রোফাইল ও ব্যাকগ্রাউন্ড',
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(PraniSpacing.xl),
            child: Text(
              'ছবি বাছাই ও ক্রপ মোবাইল অ্যাপে উপলব্ধ। ওয়েব ব্রাউজারে এই ধাপ খোলা হয়নি।',
              textAlign: TextAlign.center,
              style: textTheme.bodyLarge?.copyWith(height: 1.45),
            ),
          ),
        ),
      );
    }

    return PraniScaffold(
      title: 'ছবি ও কভার',
      subtitle: 'প্রোফাইল ও ব্যাকগ্রাউন্ড',
      resizeToAvoidBottomInset: true,
      body: asyncUser.when(
        loading: () => const Center(
          child: PraniLoadingState(
            message: 'প্রোফাইল লোড হচ্ছে…',
            compact: false,
          ),
        ),
        error: (error, stackTrace) => Center(
          child: Padding(
            padding: EdgeInsets.symmetric(
              horizontal: PraniPageInsets.horizontalPadding(context),
            ),
            child: PraniErrorState(
              title: 'প্রোফাইল লোড করা যায়নি',
              message: 'অনুগ্রহ করে নেটওয়ার্ক যাচাই করে আবার চেষ্টা করুন।',
              retryLabel: 'আবার চেষ্টা',
              onRetry: () => ref.invalidate(mobileUserProvider),
              boxed: true,
            ),
          ),
        ),
        data: (user) {
          final profileNet = _networkImg(user.profilePhotoUrl);
          final coverNet = _networkImg(user.coverPhotoUrl);
          final kb = MediaQuery.viewInsetsOf(context).bottom;
          final pad = MediaQuery.paddingOf(context).bottom;

          return ListView(
            keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
            padding: EdgeInsets.fromLTRB(
              PraniPageInsets.horizontalPadding(context),
              PraniSpacing.md,
              PraniPageInsets.horizontalPadding(context),
              PraniSpacing.xl + kb + pad + 8,
            ),
            children: [
              DecoratedBox(
                decoration: BoxDecoration(
                  color: scheme.secondaryContainer.withValues(alpha: 0.55),
                  borderRadius: BorderRadius.circular(PraniRadii.md),
                  border: Border.all(
                    color: scheme.outlineVariant.withValues(alpha: 0.5),
                  ),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(PraniSpacing.md),
                  child: Text(
                    'নতুন ছবি বেছে নিলে প্রথমে এই ডিভাইসে প্রিভিউ দেখা যাবে। '
                    '«সংরক্ষণ করুন» চাপলে সার্ভারে আপলোড হয় এবং পরের লগইনেও দেখা যাবে '
                    '(স্টোরেজ S3/MinIO চালু থাকতে হবে)।',
                    style: textTheme.bodySmall?.copyWith(height: 1.4),
                  ),
                ),
              ),
              const SizedBox(height: PraniFormTokens.fieldGap),
              PraniFormCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text(
                      'কভার / ব্যাকগ্রাউন্ড',
                      style: PraniTextStyles.cardTitleProminent(
                        scheme,
                        textTheme,
                      ),
                    ),
                    const SizedBox(height: PraniSpacing.sm),
                    Text(
                      'প্রস্তাবিত অনুপাত ১২০০×৪৫০ (৮:৩)।',
                      style: textTheme.bodySmall?.copyWith(
                        color: scheme.onSurfaceVariant,
                        height: 1.35,
                      ),
                    ),
                    const SizedBox(height: PraniSpacing.md),
                    AspectRatio(
                      aspectRatio: 8 / 3,
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(PraniRadii.md),
                        child: _draftCoverPath != null
                            ? pdLocalImageFile(
                                _draftCoverPath!,
                                fit: BoxFit.cover,
                              )
                            : coverNet != null
                            ? Image(
                                image: coverNet,
                                fit: BoxFit.cover,
                                errorBuilder: (context, error, stackTrace) =>
                                    _coverPlaceholder(scheme),
                              )
                            : _coverPlaceholder(scheme),
                      ),
                    ),
                    const SizedBox(height: PraniSpacing.md),
                    PraniSecondaryButton(
                      label: 'কভার ছবি পরিবর্তন',
                      icon: Icons.add_photo_alternate_outlined,
                      fullWidth: true,
                      onPressed: _changeCoverPhoto,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: PraniFormTokens.fieldGap),
              PraniFormCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text(
                      'প্রোফাইল ছবি',
                      style: PraniTextStyles.cardTitleProminent(
                        scheme,
                        textTheme,
                      ),
                    ),
                    const SizedBox(height: PraniSpacing.sm),
                    Text(
                      'বর্গাকার ক্রপ, প্রস্তাবিত ৫১২×৫১২।',
                      style: textTheme.bodySmall?.copyWith(
                        color: scheme.onSurfaceVariant,
                        height: 1.35,
                      ),
                    ),
                    const SizedBox(height: PraniSpacing.md),
                    Center(
                      child: SizedBox(
                        width: 120,
                        height: 120,
                        child: _draftProfilePath != null
                            ? ClipOval(
                                child: pdLocalImageFile(
                                  _draftProfilePath!,
                                  fit: BoxFit.cover,
                                ),
                              )
                            : CircleAvatar(
                                radius: 60,
                                backgroundColor: scheme.primaryContainer
                                    .withValues(alpha: 0.65),
                                foregroundImage: profileNet,
                                child: profileNet == null
                                    ? Icon(
                                        Icons.person_rounded,
                                        size: 56,
                                        color: scheme.primary,
                                      )
                                    : null,
                              ),
                      ),
                    ),
                    const SizedBox(height: PraniSpacing.md),
                    PraniSecondaryButton(
                      label: 'প্রোফাইল ছবি পরিবর্তন',
                      icon: Icons.photo_camera_outlined,
                      fullWidth: true,
                      onPressed: _changeProfilePhoto,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: PraniSpacing.lg),
              PraniPrimaryButton(
                label: 'সংরক্ষণ করুন',
                isLoading: _saving,
                onPressed: !_hasDraft || _saving ? null : _save,
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _coverPlaceholder(ColorScheme scheme) {
    return ColoredBox(
      color: scheme.surfaceContainerHighest,
      child: Center(
        child: Icon(Icons.landscape_outlined, size: 40, color: scheme.outline),
      ),
    );
  }
}
