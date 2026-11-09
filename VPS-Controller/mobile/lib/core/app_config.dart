class AppConfig {
  static const primaryServerId = 'vps-producao-01';
  static const apiBaseUrl = String.fromEnvironment('API_BASE_URL',
      defaultValue: 'http://100.105.65.75:3100');
  static const wsUrl =
      String.fromEnvironment('WS_URL', defaultValue: 'ws://100.105.65.75:3100/ws');
}
