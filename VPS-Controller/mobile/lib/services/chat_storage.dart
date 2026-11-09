import 'dart:convert';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../screens/chat_screen.dart';

class ChatStorage {
  ChatStorage({FlutterSecureStorage? storage})
      : _storage = storage ?? const FlutterSecureStorage();

  static const _chatHistoryKey = 'vps_controller.chat_history';
  final FlutterSecureStorage _storage;

  Future<List<ChatMessageItem>?> loadMessages() async {
    try {
      final jsonStr = await _storage.read(key: _chatHistoryKey);
      if (jsonStr == null || jsonStr.isEmpty) return null;
      final decoded = jsonDecode(jsonStr);
      if (decoded is List) {
        return decoded
            .map((item) =>
                ChatMessageItem.fromMap(Map<String, dynamic>.from(item as Map)))
            .toList();
      }
    } catch (_) {
      // Ignora erro de parsing e retorna nulo para usar a mensagem inicial padrão
    }
    return null;
  }

  Future<void> saveMessages(List<ChatMessageItem> messages) async {
    try {
      final listMap = messages.map((m) => m.toMap()).toList();
      await _storage.write(key: _chatHistoryKey, value: jsonEncode(listMap));
    } catch (_) {}
  }

  Future<void> clearMessages() async {
    try {
      await _storage.delete(key: _chatHistoryKey);
    } catch (_) {}
  }
}
