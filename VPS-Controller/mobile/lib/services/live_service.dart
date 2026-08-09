import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import '../core/app_config.dart';

class LiveService extends ChangeNotifier {
  WebSocket? _socket;
  Timer? _reconnectTimer;
  int _generation = 0;
  int get generation => _generation;

  void connect() {
    disconnect();
    WebSocket.connect(AppConfig.wsUrl).then((socket) {
      _socket = socket;
      socket.listen((event) {
        try {
          final decoded = jsonDecode(event.toString());
          if (decoded is Map && decoded['event'] != 'connected') {
            _generation++;
            notifyListeners();
          }
        } catch (_) {}
      }, onDone: _scheduleReconnect, onError: (_) => _scheduleReconnect());
    }).catchError((Object _) { _scheduleReconnect(); });
  }

  void _scheduleReconnect() {
    _reconnectTimer?.cancel();
    _reconnectTimer = Timer(const Duration(seconds: 5), connect);
  }

  void disconnect() {
    _reconnectTimer?.cancel();
    _socket?.close();
    _socket = null;
  }

  @override
  void dispose() {
    disconnect();
    super.dispose();
  }
}
