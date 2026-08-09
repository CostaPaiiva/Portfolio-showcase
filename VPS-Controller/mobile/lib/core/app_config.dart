class AppConfig {
  static const apiBaseUrl = String.fromEnvironment('API_BASE_URL', defaultValue: 'http://10.0.2.2:3000');
  static const userToken = String.fromEnvironment('USER_TOKEN', defaultValue: 'change-me-user');
  static const devUserToken = userToken;
  static const wsUrl = String.fromEnvironment('WS_URL', defaultValue: 'ws://10.0.2.2:3000/ws');
  static const wsToken = String.fromEnvironment('WS_TOKEN', defaultValue: 'change-me-ws');
}
