abstract final class ApiConfig {
  static const baseUrl = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: 'http://127.0.0.1:8000',
  );

  static const register = 'register/';
  static const verifyOtp = 'register/otp/';
  static const login = 'login/';
  static const logout = 'logout/';
  static const refresh = 'token/refresh/';
  static const dashboard = 'Dashboaed/';
  static const addBot = 'get-token/';

  static String bot(int botId) => 'bots/$botId/';
  static String deactivateBot(int botId) => 'bots/$botId/deactivate/';
  static String syncBot(int botId) => 'bots/$botId/sync/';
  static String command(int botId, int commandId) =>
      'bots/$botId/commands/$commandId/';
  static String response(int botId, int commandId, int responseId) =>
      '${command(botId, commandId)}responses/$responseId/';
}