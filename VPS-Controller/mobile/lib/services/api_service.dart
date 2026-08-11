import 'dart:async';
import 'dart:convert';
import 'dart:io';
import '../core/app_config.dart';
import '../models/alert.dart';
import '../models/server.dart';

class ApiException implements Exception {
  const ApiException(this.message, {this.statusCode});
  final String message;
  final int? statusCode;
  @override
  String toString() => message;
}

class ApiService {
  ApiService({required this.token}) {
    _client.connectionTimeout = const Duration(seconds: 8);
    _client.idleTimeout = const Duration(seconds: 15);
  }

  final String token;
  final HttpClient _client = HttpClient();
  bool _closed = false;

  Uri _url(String path) => Uri.parse('${AppConfig.apiBaseUrl}$path');

  Future<dynamic> _request(String method, String path, {Object? data}) async {
    if (_closed) throw const ApiException('Sessão encerrada.');
    try {
      final request = await _client.openUrl(method, _url(path));
      request.headers.set(HttpHeaders.authorizationHeader, 'Bearer $token');
      request.headers.contentType = ContentType.json;
      if (data != null) request.write(jsonEncode(data));
      final response =
          await request.close().timeout(const Duration(seconds: 15));
      final text = await utf8.decoder
          .bind(response)
          .join()
          .timeout(const Duration(seconds: 15));
      if (response.statusCode == 401)
        throw const ApiException('Sessão inválida.', statusCode: 401);
      if (response.statusCode == 403)
        throw const ApiException('Acesso negado.', statusCode: 403);
      if (response.statusCode < 200 || response.statusCode >= 300) {
        throw ApiException('Servidor indisponível.',
            statusCode: response.statusCode);
      }
      if (text.isEmpty) return <String, dynamic>{};
      try {
        return jsonDecode(text);
      } on FormatException {
        throw const ApiException('Resposta inválida do servidor.');
      }
    } on ApiException {
      rethrow;
    } on SocketException {
      throw const ApiException(
          'Não foi possível conectar à VPS. Verifique o Tailscale.');
    } on TimeoutException {
      throw const ApiException('A VPS demorou demais para responder.');
    } on HttpException {
      throw const ApiException('Erro de comunicação com a VPS.');
    }
  }

  Future<List<ServerInfo>> listServers() async {
    final data = await _request('GET', '/api/servers') as Map<String, dynamic>;
    return ((data['servers'] as List?) ?? const [])
        .map((item) =>
            ServerInfo.fromJson(Map<String, dynamic>.from(item as Map)))
        .toList();
  }

  Future<ServerInfo> getServer(String id) async {
    final data =
        await _request('GET', '/api/servers/${Uri.encodeComponent(id)}')
            as Map<String, dynamic>;
    return ServerInfo.fromJson(
        Map<String, dynamic>.from(data['server'] as Map));
  }

  Future<List<AlertInfo>> alerts() async {
    final data = await _request('GET', '/api/alerts') as Map<String, dynamic>;
    return ((data['alerts'] as List?) ?? const [])
        .map((item) =>
            AlertInfo.fromJson(Map<String, dynamic>.from(item as Map)))
        .toList();
  }

  Future<void> action(String serverId, String type, String target) async {
    await _request(
        'POST', '/api/servers/${Uri.encodeComponent(serverId)}/actions',
        data: {'type': type, 'target': target});
  }

  void dispose() {
    if (!_closed) {
      _closed = true;
      _client.close(force: true);
    }
  }
}
