import 'package:flutter_secure_storage/flutter_secure_storage.dart';

const _keyToken = 'auth_token';
const _keyUserId = 'user_id';
const _keyUserEmail = 'user_email';
const _keyUserName = 'user_name';

class SecureStorageService {
  final FlutterSecureStorage _storage;
  SecureStorageService(this._storage);

  // ── Token ──────────────────────────────────────────────────────────────────
  Future<void> saveToken(String token) => _storage.write(key: _keyToken, value: token);
  Future<String?> getToken() => _storage.read(key: _keyToken);
  Future<void> clearToken() => _storage.delete(key: _keyToken);

  // ── User info ──────────────────────────────────────────────────────────────
  Future<void> saveUser({
    required String id,
    required String email,
    required String name,
  }) async {
    await _storage.write(key: _keyUserId, value: id);
    await _storage.write(key: _keyUserEmail, value: email);
    await _storage.write(key: _keyUserName, value: name);
  }

  Future<Map<String, String?>> getUser() async => {
        'id': await _storage.read(key: _keyUserId),
        'email': await _storage.read(key: _keyUserEmail),
        'name': await _storage.read(key: _keyUserName),
      };

  // ── Full logout ────────────────────────────────────────────────────────────
  Future<void> clearAll() => _storage.deleteAll();
}
