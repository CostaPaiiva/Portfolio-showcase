import 'package:flutter/material.dart';
import 'core/app_theme.dart';
import 'screens/home_shell.dart';
import 'screens/login_screen.dart';
import 'services/api_service.dart';
import 'services/auth_storage.dart';
import 'services/live_service.dart';

void main() => runApp(const VpsControllerApp());

enum _SessionState { loading, signedOut, signedIn }

class VpsControllerApp extends StatefulWidget {
  const VpsControllerApp({super.key});
  @override
  State<VpsControllerApp> createState() => _VpsControllerAppState();
}

class _VpsControllerAppState extends State<VpsControllerApp> {
  final AuthStorage _storage = AuthStorage();
  _SessionState _state = _SessionState.loading;
  ApiService? _api;
  LiveService? _live;
  String? _message;

  @override
  void initState() {
    super.initState();
    _restoreSession();
  }

  Future<void> _restoreSession() async {
    final token = await _storage.readToken();
    if (token == null || token.isEmpty) {
      if (mounted) setState(() => _state = _SessionState.signedOut);
      return;
    }
    await _authenticate(token, persist: false);
  }

  Future<void> _authenticate(String token, {required bool persist}) async {
    final api = ApiService(token: token);
    try {
      await api.listServers();
      if (persist) await _storage.writeToken(token);
      _api?.dispose();
      _live?.dispose();
      final live = LiveService(token: token)..connect();
      if (!mounted) {
        api.dispose();
        live.dispose();
        return;
      }
      setState(() {
        _api = api;
        _live = live;
        _message = null;
        _state = _SessionState.signedIn;
      });
    } on ApiException catch (error) {
      api.dispose();
      await _storage.deleteToken();
      if (mounted)
        setState(() {
          _message = error.message;
          _state = _SessionState.signedOut;
        });
    }
  }

  Future<void> _login(String token) async {
    if (token.trim().isEmpty) {
      setState(() => _message = 'Informe o token de acesso.');
      return;
    }
    setState(() {
      _state = _SessionState.loading;
      _message = null;
    });
    await _authenticate(token.trim(), persist: true);
  }

  Future<void> _logout() async {
    _live?.disconnect();
    _live?.dispose();
    _api?.dispose();
    _live = null;
    _api = null;
    await _storage.deleteToken();
    if (mounted)
      setState(() {
        _message = null;
        _state = _SessionState.signedOut;
      });
  }

  @override
  void dispose() {
    _live?.dispose();
    _api?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => MaterialApp(
        title: 'VPS Controller',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.dark(),
        home: switch (_state) {
          _SessionState.loading =>
            const Scaffold(body: Center(child: CircularProgressIndicator())),
          _SessionState.signedOut =>
            LoginScreen(onLogin: _login, message: _message),
          _SessionState.signedIn =>
            HomeShell(api: _api!, live: _live!, onLogout: _logout),
        },
      );
}
