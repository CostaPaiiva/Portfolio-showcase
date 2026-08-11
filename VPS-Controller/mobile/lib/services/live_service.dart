import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import '../core/app_config.dart';

class LiveService extends ChangeNotifier with WidgetsBindingObserver {
  LiveService({required this.token}) {
    WidgetsBinding.instance.addObserver(this);
  }
  final String token;
  WebSocket? _socket;
  StreamSubscription<dynamic>? _subscription;
  Timer? _reconnectTimer;
  int _retry = 0;
  int _generation = 0;
  bool _disposed = false;
  bool _manualDisconnect = false;
  bool _connecting = false;
  bool _suspended = false;

  int get generation => _generation;

  void connect() {
    if (_disposed ||
        _manualDisconnect ||
        _suspended ||
        _connecting ||
        _socket != null) return;
    _reconnectTimer?.cancel();
    _reconnectTimer = null;
    _connecting = true;
    final uri = Uri.parse(
        '${AppConfig.wsUrl}?token=${Uri.encodeQueryComponent(token)}');
    unawaited(_open(uri));
  }

  Future<void> _open(Uri uri) async {
    try {
      final socket = await WebSocket.connect(uri.toString());
      if (_disposed || _manualDisconnect || _suspended) {
        _connecting = false;
        socket.close();
        return;
      }
      _connecting = false;
      _retry = 0;
      _socket = socket;
      _subscription = socket.listen(_onMessage,
          onDone: _connectionEnded, onError: (_) => _connectionEnded());
    } catch (_) {
      _connecting = false;
      _connectionEnded();
    }
  }

  void _onMessage(dynamic event) {
    try {
      final decoded = jsonDecode(event.toString());
      if (decoded is Map && decoded['event'] != 'connected') {
        _generation++;
        notifyListeners();
      }
    } catch (_) {}
  }

  void _connectionEnded() {
    _socket = null;
    _subscription?.cancel();
    _subscription = null;
    if (!_disposed && !_manualDisconnect && !_suspended) _scheduleReconnect();
  }

  void _scheduleReconnect() {
    if (_disposed ||
        _manualDisconnect ||
        _suspended ||
        _connecting ||
        _reconnectTimer != null) return;
    const delays = [2, 5, 10, 20, 30];
    final seconds = delays[_retry.clamp(0, delays.length - 1)];
    _retry = (_retry + 1).clamp(0, delays.length - 1);
    _reconnectTimer = Timer(Duration(seconds: seconds), () {
      _reconnectTimer = null;
      connect();
    });
  }

  void disconnect() {
    _manualDisconnect = true;
    _reconnectTimer?.cancel();
    _reconnectTimer = null;
    _subscription?.cancel();
    _subscription = null;
    _socket?.close();
    _socket = null;
    _connecting = false;
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.paused ||
        state == AppLifecycleState.inactive) {
      _suspended = true;
      _reconnectTimer?.cancel();
      _reconnectTimer = null;
      _subscription?.cancel();
      _subscription = null;
      _socket?.close();
      _socket = null;
    } else if (state == AppLifecycleState.resumed) {
      _suspended = false;
      if (!_manualDisconnect) connect();
    }
  }

  @override
  void dispose() {
    _disposed = true;
    WidgetsBinding.instance.removeObserver(this);
    disconnect();
    super.dispose();
  }
}
