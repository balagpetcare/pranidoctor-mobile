import 'dart:convert';
import 'dart:math';

import 'package:shared_preferences/shared_preferences.dart';

const _kActivity = 'pd_enterprise_media_upload_activity_v1';
const int _max = 100;

Future<void> appendMediaUploadActivity({
  required String titleBn,
  String? detailBn,
}) async {
  final prefs = await SharedPreferences.getInstance();
  final raw = prefs.getString(_kActivity);
  final list = <Map<String, Object?>>[];
  if (raw != null && raw.trim().isNotEmpty) {
    try {
      final decoded = jsonDecode(raw);
      if (decoded is List) {
        for (final e in decoded) {
          if (e is Map) list.add(Map<String, Object?>.from(e));
        }
      }
    } catch (_) {}
  }
  final id =
      '${DateTime.now().millisecondsSinceEpoch}_${Random().nextInt(1 << 30)}';
  list.add({
    'id': id,
    'atUtc': DateTime.now().toUtc().toIso8601String(),
    'titleBn': titleBn,
    if (detailBn != null) 'detailBn': detailBn,
  });
  final capped = list.length > _max ? list.sublist(list.length - _max) : list;
  await prefs.setString(_kActivity, jsonEncode(capped));
}

Future<List<Map<String, Object?>>> loadMediaUploadActivity() async {
  final prefs = await SharedPreferences.getInstance();
  final raw = prefs.getString(_kActivity);
  if (raw == null || raw.trim().isEmpty) return const [];
  try {
    final decoded = jsonDecode(raw);
    if (decoded is! List) return const [];
    return decoded
        .map((e) => Map<String, Object?>.from(e as Map))
        .toList();
  } catch (_) {
    return const [];
  }
}
