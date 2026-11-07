import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:teleforge_fe/core/network/api_client.dart';
import 'package:teleforge_fe/core/network/api_exceptions.dart';
import 'package:teleforge_fe/core/storage/token_storage.dart';

void main() {
  test('refreshes and retries a request with rotated JWTs', () async {
    final storage = _MemoryTokenStorage()
      ..access = 'expired-access'
      ..refresh = 'old-refresh';
    final seenRequests = <http.Request>[];
    final client = ApiClient(
      tokenStorage: storage,
      baseUrl: 'https://api.example.test',
      httpClient: MockClient((request) async {
        seenRequests.add(request);
        if (request.url.path == '/private/') {
          if (request.headers['Authorization'] == 'Bearer expired-access') {
            return _json({'detail': 'Token is invalid.'}, 401);
          }
          return _json({'ok': true});
        }
        if (request.url.path == '/token/refresh/') {
          expect(jsonDecode(request.body), {'refresh': 'old-refresh'});
          return _json({'access': 'new-access', 'refresh': 'new-refresh'});
        }
        return _json({'detail': 'Unexpected request.'}, 404);
      }),
    );

    expect(await client.get('private/'), {'ok': true});
    expect(seenRequests.map((request) => request.url.path), [
      '/private/',
      '/token/refresh/',
      '/private/',
    ]);
    expect(seenRequests.last.headers['Authorization'], 'Bearer new-access');
    expect(storage.access, 'new-access');
    expect(storage.refresh, 'new-refresh');
  });

  test('converts DRF validation errors to visible API exceptions', () async {
    final client = ApiClient(
      tokenStorage: _MemoryTokenStorage(),
      baseUrl: 'https://api.example.test',
      httpClient: MockClient(
        (_) async => _json({
          'email': ['Enter a valid email address.'],
        }, 400),
      ),
    );

    await expectLater(
      client.post('login/', authenticated: false),
      throwsA(
        isA<ApiException>().having(
          (error) => error.message,
          'message',
          'Enter a valid email address.',
        ),
      ),
    );
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

http.Response _json(Object body, [int statusCode = 200]) => http.Response(
  jsonEncode(body),
  statusCode,
  headers: {'content-type': 'application/json'},
);
