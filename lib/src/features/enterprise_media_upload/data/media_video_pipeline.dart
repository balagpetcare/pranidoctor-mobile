import 'dart:io';

import 'package:video_player/video_player.dart';
import 'package:video_thumbnail/video_thumbnail.dart';

class MediaVideoPipeline {
  const MediaVideoPipeline();

  Future<Duration?> probeDuration(String path) async {
    VideoPlayerController? c;
    try {
      c = VideoPlayerController.file(File(path));
      await c.initialize();
      return c.value.duration;
    } catch (_) {
      return null;
    } finally {
      await c?.dispose();
    }
  }

  Future<String?> generateThumbnail({
    required String videoPath,
    required String tempDir,
  }) async {
    try {
      return await VideoThumbnail.thumbnailFile(
        video: videoPath,
        thumbnailPath: tempDir,
        imageFormat: ImageFormat.JPEG,
        maxHeight: 360,
        quality: 80,
      );
    } catch (_) {
      return null;
    }
  }
}
