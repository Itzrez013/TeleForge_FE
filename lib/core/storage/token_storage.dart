import 'package:flutter/services.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:teleforge_fe/core/network/api_exceptions.dart';

class TokenStorage {
  const TokenStorage();

  static const _storage = FlutterSecureStorage();
  static const _accessKey = 'teleforge_access_token';
  static const _refreshKey = 'teleforge_refresh_token';

  Future<String?> readAccessToken() => _read(_accessKey);

  Future<String?> readRefreshToken() => _read(_refreshKey);

  Future<void> saveTokens({
    required String access,
    required String refresh,
  }) async {
    await _write(_accessKey, access);
    await _write(_refreshKey, refresh);
  }

  Future<void> clear() async {
    await _delete(_accessKey);
    await _delete(_refreshKey);
  }

  Future<String?> _read(String key) async {
    try {
      return await _storage.read(key: key);
    } on PlatformException catch (error) {
      throw ApiException(
        'Secure token storage failed: ${error.message ?? error.code}',
      );
    }
  }

  Future<void> _write(String key, String value) async {
    try {
      await _storage.write(key: key, value: value);
    } on PlatformException catch (error) {
      throw ApiException(
        'Secure token storage failed: ${error.message ?? error.code}',
      );
    }
  }

  Future<void> _delete(String key) async {
    try {
      await _storage.delete(key: key);
    } on PlatformException catch (error) {
      throw ApiException(
        'Secure token storage failed: ${error.message ?? error.code}',
      );
    }
  }
}