class AppConfig {
  static const primaryServerId = 'vps-producao-01';
  static const apiBaseUrl = String.fromEnvironment('API_BASE_URL',
      defaultValue: 'http://10.0.2.2:3000');
  static const wsUrl =
      String.fromEnvironment('WS_URL', defaultValue: 'ws://10.0.2.2:3000/ws');
}
