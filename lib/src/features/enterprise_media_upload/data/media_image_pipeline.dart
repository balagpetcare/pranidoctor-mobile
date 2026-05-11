import 'dart:io';

import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:path/path.dart' as p;

class PreparedImagePaths {
  PreparedImagePaths({
    required this.mainPath,
    required this.thumbnailPath,
  });

  final String mainPath;
  final String thumbnailPath;
}

/// Resize + compress raster images; falls back to copy if compressor returns null.
class MediaImagePipeline {
  const MediaImagePipeline();

  Future<PreparedImagePaths> prepareRaster({
    required String sourcePath,
    required String tempDir,
    required String taskId,
  }) async {
    final mainOut = p.join(tempDir, '${taskId}_main.jpg');
    final thumbOut = p.join(tempDir, '${taskId}_thumb.jpg');

    final main = await FlutterImageCompress.compressAndGetFile(
      sourcePath,
      mainOut,
      quality: 82,
      minWidth: 1920,
      minHeight: 1080,
    );
    final mainPath = main?.path ?? mainOut;
    if (main == null) {
      await File(sourcePath).copy(mainOut);
    }

    try {
      await FlutterImageCompress.compressAndGetFile(
        mainPath,
        thumbOut,
        quality: 72,
        minWidth: 320,
        minHeight: 320,
      );
    } catch (_) {
      await File(mainPath).copy(thumbOut);
    }

    return PreparedImagePaths(mainPath: mainPath, thumbnailPath: thumbOut);
  }
}
