import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:teleforge_fe/core/config/api_config.dart';
import 'package:teleforge_fe/core/network/api_client.dart';
import 'package:teleforge_fe/core/network/api_exceptions.dart';
import 'package:teleforge_fe/core/storage/token_storage.dart';
import 'package:teleforge_fe/features/auth/services/auth_service.dart';

void main() {
  test('uses the production API and dashboard endpoints by default', () {
    expect(ApiConfig.baseUrl, 'https://api.teleforge.ir/');
    expect(ApiConfig.dashboard, 'dashboard/');
  });

  test('keeps an unverified login out of an authenticated session', () async {
    final storage = _MemoryTokenStorage()
      ..access = 'stale-access'
      ..refresh = 'stale-refresh';
    final client = ApiClient(
      tokenStorage: storage,
      baseUrl: 'https://api.example.test',
      httpClient: MockClient((request) async {
        expect(request.url.path, '/login/');
        expect(jsonDecode(request.body), {
          'email': 'new@example.com',
          'password': 'password123',
        });
        return _json({'verification_required': true});
      }),
    );

    final authenticated = await AuthService(
      apiClient: client,
      tokenStorage: storage,
    ).login(email: 'new@example.com', password: 'password123');

    expect(authenticated, isFalse);
    expect(storage.access, isNull);
    expect(storage.refresh, isNull);
  });

  test('rejects a successful login response without a known session state', () {
    final storage = _MemoryTokenStorage();
    final client = ApiClient(
      tokenStorage: storage,
      baseUrl: 'https://api.example.test',
      httpClient: MockClient((_) async => _json({'message': 'Unexpected'})),
    );

    expect(
      AuthService(
        apiClient: client,
        tokenStorage: storage,
      ).login(email: 'user@example.com', password: 'password123'),
      throwsA(isA<ApiException>()),
    );
  });

  test('verifies a numeric code and stores the returned session', () async {
    final storage = _MemoryTokenStorage();
    final client = ApiClient(
      tokenStorage: storage,
      baseUrl: 'https://api.example.test',
      httpClient: MockClient((request) async {
        expect(request.url.path, '/register/otp/');
        expect(jsonDecode(request.body), {
          'email': 'user@example.com',
          'code': 123456,
        });
        return _json({'access': 'access-token', 'refresh': 'refresh-token'});
      }),
    );

    await AuthService(
      apiClient: client,
      tokenStorage: storage,
    ).verifyOtp(email: 'user@example.com', code: '123456');

    expect(storage.access, 'access-token');
    expect(storage.refresh, 'refresh-token');
  });
}

class _MemoryTokenStorage extends TokenStorage {
  String? access;
  String? refresh;

  @override
  Future<String?> readAccessToken() async => access;

  @override
  Future<String?> readRefreshToken() async => refresh;

  @override
  Future<void> saveTokens({
    required String access,
    required String refresh,
  }) async {
    this.access = access;
    this.refresh = refresh;
  }

  @override
  Future<void> clear() async {
    access = null;
    refresh = null;
  }
}

http.Response _json(Object body) => http.Response(
  jsonEncode(body),
  200,
  headers: {'content-type': 'application/json'},
);
