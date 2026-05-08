import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final tokenStorageProvider = Provider<TokenStorage>((ref) {
  const storage = FlutterSecureStorage();
  return TokenStorage(storage);
});

/// Keys for auth tokens (customer / doctor flows will use these later).
class TokenStorage {
  TokenStorage(this._secure);

  static const _accessKey = 'pd_access_token';
  static const _refreshKey = 'pd_refresh_token';

  final FlutterSecureStorage _secure;

  Future<void> writeAccessToken(String value) =>
      _secure.write(key: _accessKey, value: value);

  Future<String?> readAccessToken() => _secure.read(key: _accessKey);

  Future<void> writeRefreshToken(String value) =>
      _secure.write(key: _refreshKey, value: value);

  Future<String?> readRefreshToken() => _secure.read(key: _refreshKey);

  Future<void> clear() async {
    await _secure.delete(key: _accessKey);
    await _secure.delete(key: _refreshKey);
  }
}
