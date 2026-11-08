import 'package:teleforge_fe/core/config/api_config.dart';
import 'package:teleforge_fe/core/network/api_client.dart';
import 'package:teleforge_fe/core/network/api_exceptions.dart';
import 'package:teleforge_fe/core/storage/token_storage.dart';

class AuthService {
  const AuthService({required this._apiClient, required this._tokenStorage});

  final ApiClient _apiClient;
  final TokenStorage _tokenStorage;

  Future<void> register({
    required String fullName,
    required String email,
    required String password,
  }) async {
    await _apiClient.post(
      ApiConfig.register,
      authenticated: false,
      body: {'full_name': fullName, 'email': email, 'password': password},
    );
  }

  Future<bool> login({required String email, required String password}) async {
    final response = await _apiClient.post(
      ApiConfig.login,
      authenticated: false,
      body: {'email': email, 'password': password},
    );
    if (await _storeSessionIfPresent(response)) return true;

    await _tokenStorage.clear();
    if (response['verification_required'] == true) return false;

    throw const ApiException(
      'The login response contained neither a session nor a verification requirement.',
    );
  }

  Future<void> verifyOtp({required String email, required String code}) async {
    final response = await _apiClient.post(
      ApiConfig.verifyOtp,
      authenticated: false,
      body: {'email': email, 'code': int.parse(code)},
    );
    if (!await _storeSessionIfPresent(response)) {
      throw const ApiException(
        'OTP verification did not return valid session tokens.',
      );
    }
  }

  Future<bool> hasSession() async {
    final refresh = await _tokenStorage.readRefreshToken();
    return refresh != null && refresh.isNotEmpty;
  }

  Future<void> logout() async {
    try {
      final refresh = await _tokenStorage.readRefreshToken();
      if (refresh != null) {
        await _apiClient.post(ApiConfig.logout, body: {'refresh': refresh});
      }
    } finally {
      await _tokenStorage.clear();
    }
  }

  Future<bool> _storeSessionIfPresent(Map<String, dynamic> response) async {
    final access = response['access'];
    final refresh = response['refresh'];
    if (access is! String ||
        access.isEmpty ||
        refresh is! String ||
        refresh.isEmpty) {
      return false;
    }
    await _tokenStorage.saveTokens(access: access, refresh: refresh);
    return true;
  }
}
