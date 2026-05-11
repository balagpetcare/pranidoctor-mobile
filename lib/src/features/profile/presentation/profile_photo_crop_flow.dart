import 'package:flutter/material.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';

import 'package:pranidoctor_mobile/src/design_system/prani_tokens.dart';
import 'package:pranidoctor_mobile/src/features/profile/presentation/profile_image_file_utils.dart';

/// Gallery/camera pick + crop + optional JPEG compress for profile photos.
abstract final class ProfilePhotoCropFlow {
  /// Before decode/crop — reject very large originals (bytes).
  static const int maxOriginalBytes = 25 * 1024 * 1024;

  static void _snack(BuildContext context, String message) {
    if (!context.mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(behavior: SnackBarBehavior.floating, content: Text(message)),
    );
  }

  /// Square profile image (~512×512 output target).
  static Future<String?> pickCropProfilePhoto(
    BuildContext context,
    ImageSource source,
  ) {
    return _pickCrop(
      context,
      source,
      aspectRatio: const CropAspectRatio(ratioX: 1, ratioY: 1),
      maxWidth: 512,
      maxHeight: 512,
      toolbarTitle: 'প্রোফাইল ছবি ক্রপ করুন',
      compressMinW: 512,
      compressMinH: 512,
    );
  }

  /// Wide cover (~1200×450 target).
  static Future<String?> pickCropCoverPhoto(
    BuildContext context,
    ImageSource source,
  ) {
    return _pickCrop(
      context,
      source,
      aspectRatio: const CropAspectRatio(ratioX: 8, ratioY: 3),
      maxWidth: 1200,
      maxHeight: 450,
      toolbarTitle: 'কভার ছবি ক্রপ করুন',
      compressMinW: 1200,
      compressMinH: 450,
    );
  }

  /// গ্যালারি বা ক্যামেরা — বাতিল হলে `null`।
  static Future<ImageSource?> showPickImageSourceSheet(
    BuildContext context,
  ) async {
    if (kIsWeb) {
      _snack(
        context,
        'এই ফিচার মোবাইল অ্যাপ (অ্যান্ড্রয়েড/আইওএস) এ ব্যবহার করুন।',
      );
      return null;
    }
    final choice = await showModalBottomSheet<ImageSource>(
      context: context,
      showDragHandle: true,
      builder: (ctx) {
        final scheme = Theme.of(ctx).colorScheme;
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.only(bottom: PraniSpacing.sm),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                ListTile(
                  leading: Icon(
                    Icons.photo_library_outlined,
                    color: scheme.primary,
                  ),
                  title: const Text('গ্যালারি'),
                  onTap: () => Navigator.pop(ctx, ImageSource.gallery),
                ),
                ListTile(
                  leading: Icon(
                    Icons.photo_camera_outlined,
                    color: scheme.primary,
                  ),
                  title: const Text('ক্যামেরা'),
                  onTap: () => Navigator.pop(ctx, ImageSource.camera),
                ),
                ListTile(
                  leading: const Icon(Icons.close),
                  title: const Text('বাতিল'),
                  onTap: () => Navigator.pop(ctx),
                ),
              ],
            ),
          ),
        );
      },
    );
    return choice;
  }

  static Future<String?> pickCropProfilePhotoWithSheet(
    BuildContext context,
  ) async {
    final src = await showPickImageSourceSheet(context);
    if (src == null || !context.mounted) return null;
    return pickCropProfilePhoto(context, src);
  }

  static Future<String?> pickCropCoverPhotoWithSheet(
    BuildContext context,
  ) async {
    final src = await showPickImageSourceSheet(context);
    if (src == null || !context.mounted) return null;
    return pickCropCoverPhoto(context, src);
  }

  /// এনআইডি/সনদ ইত্যাদির জন্য স্বাধীন অনুপাতে ক্রপ।
  static Future<String?> pickCropFreeWithSheet(
    BuildContext context, {
    required String toolbarTitle,
  }) async {
    final src = await showPickImageSourceSheet(context);
    if (src == null || !context.mounted) return null;
    return pickCropFreeFromSource(context, src, toolbarTitle: toolbarTitle);
  }

  static Future<String?> pickCropFreeFromSource(
    BuildContext context,
    ImageSource source, {
    required String toolbarTitle,
  }) {
    return _pickCrop(
      context,
      source,
      aspectRatio: null,
      maxWidth: 2400,
      maxHeight: 2400,
      toolbarTitle: toolbarTitle,
      compressMinW: 640,
      compressMinH: 640,
      lockAspectRatio: false,
    );
  }

  /// ফাইল পিকার থেকে আসা ছবির পথ — শুধু ক্রপ ধাপ (আবার ক্রপ বাতিল = `null`)।
  static Future<String?> cropRasterImageFree(
    BuildContext context, {
    required String sourcePath,
    required String toolbarTitle,
  }) async {
    if (kIsWeb) return null;
    try {
      if (!profileImagePathLooksSupported(sourcePath)) {
        _snack(context, 'শুধু JPEG, PNG, WebP বা HEIC গ্রহণযোগ্য।');
        return null;
      }
      final len = profileImageFileLengthBytes(sourcePath);
      if (len < 0) {
        _snack(context, 'ফাইলের আকার যাচাই করা যায়নি।');
        return null;
      }
      if (len > maxOriginalBytes) {
        _snack(
          context,
          'ফাইলের আকার অনেক বড় (${(len / (1024 * 1024)).toStringAsFixed(1)} MB)। '
          'সর্বোচ্চ ২৫ MB এর ছোট ছবি বেছে নিন।',
        );
        return null;
      }
      final cropped = await ImageCropper().cropImage(
        sourcePath: sourcePath,
        maxWidth: 2400,
        maxHeight: 2400,
        compressFormat: ImageCompressFormat.jpg,
        compressQuality: 90,
        uiSettings: [
          AndroidUiSettings(
            toolbarTitle: toolbarTitle,
            lockAspectRatio: false,
            cropStyle: CropStyle.rectangle,
          ),
          IOSUiSettings(title: toolbarTitle, aspectRatioLockEnabled: false),
        ],
      );
      if (cropped == null) return null;
      if (!context.mounted) return null;
      final out = await _compressToJpeg(
        sourcePath: cropped.path,
        minWidth: 640,
        minHeight: 640,
      );
      return out ?? cropped.path;
    } catch (e, st) {
      assert(() {
        debugPrint('ProfilePhotoCropFlow.cropRasterImageFree: $e\n$st');
        return true;
      }());
      if (context.mounted) {
        _snack(context, 'ক্রপ করা যায়নি। আবার চেষ্টা করুন।');
      }
      return null;
    }
  }

  static Future<String?> _pickCrop(
    BuildContext context,
    ImageSource source, {
    CropAspectRatio? aspectRatio,
    required int maxWidth,
    required int maxHeight,
    required String toolbarTitle,
    required int compressMinW,
    required int compressMinH,
    bool lockAspectRatio = true,
  }) async {
    if (kIsWeb) {
      _snack(
        context,
        'এই ফিচার মোবাইল অ্যাপ (অ্যান্ড্রয়েড/আইওএস) এ ব্যবহার করুন।',
      );
      return null;
    }

    try {
      final picked = await ImagePicker().pickImage(
        source: source,
        imageQuality: 92,
      );
      if (picked == null) return null;
      if (!context.mounted) return null;

      final path = picked.path;
      if (!profileImagePathLooksSupported(path)) {
        _snack(context, 'শুধু JPEG, PNG, WebP বা HEIC গ্রহণযোগ্য।');
        return null;
      }

      final len = profileImageFileLengthBytes(path);
      if (len < 0) {
        _snack(context, 'ফাইলের আকার যাচাই করা যায়নি।');
        return null;
      }
      if (len > maxOriginalBytes) {
        _snack(
          context,
          'ফাইলের আকার অনেক বড় (${(len / (1024 * 1024)).toStringAsFixed(1)} MB)। '
          'সর্বোচ্চ ২৫ MB এর ছোট ছবি বেছে নিন।',
        );
        return null;
      }

      final cropped = await ImageCropper().cropImage(
        sourcePath: path,
        maxWidth: maxWidth,
        maxHeight: maxHeight,
        aspectRatio: aspectRatio,
        compressFormat: ImageCompressFormat.jpg,
        compressQuality: 92,
        uiSettings: [
          AndroidUiSettings(
            toolbarTitle: toolbarTitle,
            lockAspectRatio: lockAspectRatio,
            cropStyle: CropStyle.rectangle,
          ),
          IOSUiSettings(
            title: toolbarTitle,
            aspectRatioLockEnabled: lockAspectRatio,
          ),
        ],
      );

      if (cropped == null) return null;
      if (!context.mounted) return null;

      final croppedPath = cropped.path;
      final compressed = await _compressToJpeg(
        sourcePath: croppedPath,
        minWidth: compressMinW,
        minHeight: compressMinH,
      );
      if (!context.mounted) return null;
      return compressed ?? croppedPath;
    } catch (e, st) {
      assert(() {
        debugPrint('ProfilePhotoCropFlow: $e\n$st');
        return true;
      }());
      if (context.mounted) {
        _snack(
          context,
          'ছবি বেছে নেওয়া বা ক্রপ করা যায়নি। আবার চেষ্টা করুন।',
        );
      }
      return null;
    }
  }

  static Future<String?> _compressToJpeg({
    required String sourcePath,
    required int minWidth,
    required int minHeight,
  }) async {
    try {
      final dir = await getTemporaryDirectory();
      final target =
          '${dir.path}/pd_img_${DateTime.now().millisecondsSinceEpoch}.jpg';
      final out = await FlutterImageCompress.compressAndGetFile(
        sourcePath,
        target,
        quality: 85,
        minWidth: minWidth,
        minHeight: minHeight,
        format: CompressFormat.jpeg,
      );
      return out?.path;
    } catch (e, st) {
      assert(() {
        debugPrint('ProfilePhotoCropFlow compress: $e\n$st');
        return true;
      }());
      return null;
    }
  }
}
