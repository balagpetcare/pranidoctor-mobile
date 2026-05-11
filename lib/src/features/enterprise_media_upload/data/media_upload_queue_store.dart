import 'dart:convert';
import 'dart:io';

import 'package:shared_preferences/shared_preferences.dart';

import 'package:pranidoctor_mobile/src/features/enterprise_media_upload/domain/media_upload_task.dart';

const _kQueue = 'pd_enterprise_media_upload_queue_v1';
const int _maxTasks = 80;

class MediaUploadQueueStore {
  Future<List<MediaUploadTask>> loadAll() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_kQueue);
    if (raw == null || raw.trim().isEmpty) return const [];
    try {
      final list = jsonDecode(raw);
      if (list is! List) return const [];
      return list
          .map(
            (e) => MediaUploadTask.fromJson(
              Map<String, Object?>.from(e as Map),
            ),
          )
          .toList();
    } catch (_) {
      return const [];
    }
  }

  Future<void> saveAll(List<MediaUploadTask> tasks) async {
    final prefs = await SharedPreferences.getInstance();
    var next = tasks;
    if (next.length > _maxTasks) {
      next = next.sublist(next.length - _maxTasks);
    }
    await prefs.setString(
      _kQueue,
      jsonEncode(next.map((e) => e.toJson()).toList()),
    );
  }

  Future<void> deleteTempArtifacts(MediaUploadTask t) async {
    for (final p in [t.workingPath, t.thumbnailPath]) {
      if (p == null || p.isEmpty) continue;
      try {
        final f = File(p);
        if (f.existsSync()) await f.delete();
      } catch (_) {}
    }
  }
}
