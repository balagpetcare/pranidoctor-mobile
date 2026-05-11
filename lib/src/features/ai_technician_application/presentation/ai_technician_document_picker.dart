import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';

import 'package:pranidoctor_mobile/src/features/ai_technician_application/data/ai_technician_models.dart';
import 'package:pranidoctor_mobile/src/features/profile/presentation/profile_photo_crop_flow.dart';

/// Picks a local file path (+ display name) for AI technician document slots.
///
/// Image slots use gallery/camera + [image_cropper]; mixed slots use file picker
/// then optional free crop for raster files. PDFs are returned as-is.
abstract final class AiTechnicianDocumentPicker {
  static bool _looksPdf(String name) {
    return name.toLowerCase().endsWith('.pdf');
  }

  static bool _looksRaster(String name) {
    final l = name.toLowerCase();
    return l.endsWith('.jpg') ||
        l.endsWith('.jpeg') ||
        l.endsWith('.png') ||
        l.endsWith('.webp') ||
        l.endsWith('.heic');
  }

  static Future<({String path, String name})?> pickForSlot(
    BuildContext context, {
    required String type,
  }) async {
    final strictImage =
        type == 'PROFILE_PHOTO' ||
        type == 'COVER_IMAGE' ||
        type == 'NID_FRONT' ||
        type == 'NID_BACK';

    if (strictImage) {
      String? path;
      if (type == 'PROFILE_PHOTO') {
        path = await ProfilePhotoCropFlow.pickCropProfilePhotoWithSheet(
          context,
        );
      } else if (type == 'COVER_IMAGE') {
        path = await ProfilePhotoCropFlow.pickCropCoverPhotoWithSheet(context);
      } else {
        path = await ProfilePhotoCropFlow.pickCropFreeWithSheet(
          context,
          toolbarTitle: 'এনআইডি ছবি ক্রপ করুন',
        );
      }
      if (path == null || !context.mounted) return null;
      final uriName = Uri.file(path).pathSegments.last;
      return (path: path, name: uriName);
    }

    final res = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: const ['jpg', 'jpeg', 'png', 'webp', 'pdf'],
      withData: false,
    );
    if (res == null || res.files.isEmpty) return null;
    final f = res.files.first;
    final path = f.path;
    if (path == null || path.isEmpty || !context.mounted) return null;
    final name = f.name;
    if (_looksPdf(name)) {
      return (path: path, name: name);
    }
    if (_looksRaster(name)) {
      final cropped = await ProfilePhotoCropFlow.cropRasterImageFree(
        context,
        sourcePath: path,
        toolbarTitle: '${AiTechnicianDocumentTypes.labelBn(type)} ক্রপ করুন',
      );
      if (cropped == null || !context.mounted) return null;
      return (path: cropped, name: name);
    }
    if (context.mounted) {
      final messenger = ScaffoldMessenger.of(context);
      messenger.hideCurrentSnackBar();
      messenger.showSnackBar(
        const SnackBar(
          behavior: SnackBarBehavior.fixed,
          content: Text('শুধু JPG, PNG, WEBP বা PDF ফাইল বেছে নিন।'),
        ),
      );
    }
    return null;
  }
}
