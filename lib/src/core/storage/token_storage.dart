import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'secure_storage_service.dart';

final tokenStorageProvider = Provider<TokenStorage>((ref) {
  return TokenStorage(ref.watch(secureStorageServiceProvider));
});

/// Keys for auth tokens (real auth flows will use these later).
class TokenStorage {
  TokenStorage(this._secure);

  static const _accessKey = 'pd_access_token';
  static const _refreshKey = 'pd_refresh_token';

  final SecureStorageService _secure;

  Future<void> writeAccessToken(String value) =>
      _secure.write(_accessKey, value);

  Future<String?> readAccessToken() => _secure.read(_accessKey);

  Future<void> writeRefreshToken(String value) =>
      _secure.write(_refreshKey, value);

  Future<String?> readRefreshToken() => _secure.read(_refreshKey);

  Future<void> clear() async {
    await _secure.delete(_accessKey);
    await _secure.delete(_refreshKey);
  }
}
