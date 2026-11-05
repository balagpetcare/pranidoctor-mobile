import 'dart:collection';
import 'dart:typed_data';

/// Simple in-memory LRU for authenticated template upload bytes (images / small docs).
final class TemplateMediaCache {
  TemplateMediaCache._();
  static final TemplateMediaCache instance = TemplateMediaCache._();

  static const int _maxEntries = 28;
  final LinkedHashMap<String, Uint8List> _map = LinkedHashMap();

  Uint8List? get(String uploadId) {
    final id = uploadId.trim();
    if (id.isEmpty) return null;
    final v = _map.remove(id);
    if (v != null) {
      _map[id] = v;
    }
    return v;
  }

  void put(String uploadId, Uint8List bytes) {
    final id = uploadId.trim();
    if (id.isEmpty) return;
    _map.remove(id);
    _map[id] = bytes;
    while (_map.length > _maxEntries) {
      _map.remove(_map.keys.first);
    }
  }

  void clear() => _map.clear();
}
