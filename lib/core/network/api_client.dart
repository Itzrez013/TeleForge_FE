import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;
import 'package:teleforge_fe/core/config/api_config.dart';
import 'package:teleforge_fe/core/network/api_exceptions.dart';
import 'package:teleforge_fe/core/storage/token_storage.dart';

class ApiClient {
  ApiClient({
    required this._tokenStorage,
    http.Client? httpClient,
    String baseUrl = ApiConfig.baseUrl,
  }) : _httpClient = httpClient ?? http.Client(),
       _baseUri = Uri.parse(baseUrl.endsWith('/') ? baseUrl : '$baseUrl/');

  final TokenStorage _tokenStorage;
  final http.Client _httpClient;
  final Uri _baseUri;
  Future<bool>? _refreshInProgress;

  Future<Map<String, dynamic>> get(
    String path, {
    bool authenticated = true,
  }) => _request('GET', path, authenticated: authenticated);

  Future<Map<String, dynamic>> post(
    String path, {
    Map<String, Object?> body = const {},
    bool authenticated = true,
  }) => _request('POST', path, body: body, authenticated: authenticated);

  Future<Map<String, dynamic>> patch(
    String path, {
    required Map<String, Object?> body,
  }) => _request('PATCH', path, body: body);

  Future<void> delete(String path) async {
    await _request('DELETE', path);
  }

  Future<Map<String, dynamic>> _request(
    String method,
    String path, {
    Map<String, Object?>? body,
    bool authenticated = true,
    bool retryAfterRefresh = true,
  }) async {
    var response = await _send(
      method,
      path,
      body: body,
      authenticated: authenticated,
    );

    if (response.statusCode == 401 &&
        authenticated &&
        retryAfterRefresh &&
        await _refreshTokens()) {
      response = await _send(
        method,
        path,
        body: body,
        authenticated: true,
      );
    }

    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw _exceptionFor(response);
    }

    if (response.bodyBytes.isEmpty) return {};
    final decoded = _decode(response);
    if (decoded is Map<String, dynamic>) return decoded;
    throw ApiException(
      'The server returned an unexpected response.',
      statusCode: response.statusCode,
      payload: decoded,
    );
  }

  Future<http.Response> _send(
    String method,
    String path, {
    Map<String, Object?>? body,
    required bool authenticated,
  }) async {
    final headers = <String, String>{
      'Accept': 'application/json',
      'Content-Type': 'application/json',
    };
    if (authenticated) {
      final accessToken = await _tokenStorage.readAccessToken();
      if (accessToken != null && accessToken.isNotEmpty) {
        headers['Authorization'] = 'Bearer $accessToken';
      }
    }

    final request = http.Request(method, _baseUri.resolve(path))
      ..headers.addAll(headers);
    if (body != null) request.body = jsonEncode(body);

    try {
      final streamed = await _httpClient.send(request).timeout(
        const Duration(seconds: 25),
      );
      return await http.Response.fromStream(streamed);
    } on TimeoutException {
      throw const ApiException('The server request timed out.');
    } on SocketException {
      throw const ApiException(
        'Could not reach the server. Check the API base URL and network.',
      );
    } on http.ClientException catch (error) {
      throw ApiException('Network request failed: ${error.message}');
    }
  }

  Future<bool> _refreshTokens() {
    final pending = _refreshInProgress;
    if (pending != null) return pending;
    final refresh = _performRefresh();
    _refreshInProgress = refresh;
    return refresh.whenComplete(() => _refreshInProgress = null);
  }

  Future<bool> _performRefresh() async {
    final refreshToken = await _tokenStorage.readRefreshToken();
    if (refreshToken == null || refreshToken.isEmpty) {
      await _tokenStorage.clear();
      return false;
    }

    final response = await _send(
      'POST',
      ApiConfig.refresh,
      body: {'refresh': refreshToken},
      authenticated: false,
    );
    if (response.statusCode < 200 || response.statusCode >= 300) {
      await _tokenStorage.clear();
      return false;
    }

    final decoded = _decode(response);
    if (decoded is! Map<String, dynamic> ||
        decoded['access'] is! String ||
        decoded['refresh'] is! String) {
      await _tokenStorage.clear();
      throw const ApiException('The token refresh response was invalid.');
    }

    await _tokenStorage.saveTokens(
      access: decoded['access'] as String,
      refresh: decoded['refresh'] as String,
    );
    return true;
  }

  Object? _decode(http.Response response) {
    try {
      return jsonDecode(utf8.decode(response.bodyBytes));
    } on FormatException {
      throw ApiException(
        'The server returned invalid JSON (HTTP ${response.statusCode}).',
        statusCode: response.statusCode,
        payload: response.body,
      );
    }
  }

  ApiException _exceptionFor(http.Response response) {
    final payload = response.bodyBytes.isEmpty ? null : _decode(response);
    return ApiException(
      _errorMessage(payload) ?? 'Server request failed (HTTP ${response.statusCode}).',
      statusCode: response.statusCode,
      payload: payload,
    );
  }

  String? _errorMessage(Object? value) {
    if (value is String && value.trim().isNotEmpty) return value;
    if (value is List) {
      final messages = value.map(_errorMessage).whereType<String>().toList();
      return messages.isEmpty ? null : messages.join(' ');
    }
    if (value is Map) {
      final preferred = value['error'] ?? value['detail'] ?? value['message'];
      final preferredMessage = _errorMessage(preferred);
      if (preferredMessage != null) return preferredMessage;
      final messages = value.values
          .map(_errorMessage)
          .whereType<String>()
          .toList();
      return messages.isEmpty ? null : messages.join(' ');
    }
    return null;
  }
}