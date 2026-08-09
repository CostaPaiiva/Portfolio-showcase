import 'package:dio/dio.dart';
import '../core/app_config.dart';
import '../models/alert.dart';
import '../models/server.dart';
import 'auth_service.dart';

class ApiService {
  ApiService(this.auth) : _dio = Dio(BaseOptions(baseUrl: AppConfig.apiBaseUrl));

  final AuthService auth;
  final Dio _dio;

  Future<Options> _options() async => Options(
        headers: {'Authorization': 'Bearer ${await auth.apiToken()}'},
      );

  Future<List<ServerInfo>> listServers() async {
    final response = await _dio.get('/api/servers', options: await _options());
    return ((response.data['servers'] as List?) ?? const [])
        .map((e) => ServerInfo.fromJson((e as Map).cast<String, dynamic>()))
        .toList();
  }

  Future<ServerInfo> getServer(String id) async {
    final response = await _dio.get('/api/servers/$id', options: await _options());
    return ServerInfo.fromJson((response.data['server'] as Map).cast<String, dynamic>());
  }

  Future<List<AlertInfo>> listAlerts() async {
    final response = await _dio.get('/api/alerts', options: await _options());
    return ((response.data['alerts'] as List?) ?? const [])
        .map((e) => AlertInfo.fromJson((e as Map).cast<String, dynamic>()))
        .toList();
  }

  Future<void> sendAction({
    required String serverId,
    required String type,
    required String target,
  }) async {
    await _dio.post(
      '/api/servers/$serverId/actions',
      data: {'type': type, 'target': target},
      options: await _options(),
    );
  }
}
