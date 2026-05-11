import 'package:shared_preferences/shared_preferences.dart';

import 'package:pranidoctor_mobile/src/features/enterprise_insights/application/offline_sync_monitoring_ports.dart';

/// SharedPreferences-backed JSON cache (namespaced keys).
class SharedPreferencesOfflineJsonCache implements OfflineJsonCachePort {
  static String _k(String namespace, String key) =>
      'pd_offline_cache_v1_${namespace}_$key';

  @override
  Future<String?> get(String namespace, String key) async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_k(namespace, key));
  }

  @override
  Future<void> put(String namespace, String key, String json) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_k(namespace, key), json);
  }

  @override
  Future<void> remove(String namespace, String key) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_k(namespace, key));
  }
}
