import 'package:flutter/foundation.dart';
import '../core/app_config.dart';

/// Development-compatible auth facade. Firebase can be added without changing
/// screens or API contracts once platform configuration is available.
class AuthService extends ChangeNotifier {
  bool _signedIn = false;
  bool _loading = false;

  bool get loading => _loading;
  bool get signedIn => _signedIn;
  String? get error => null;

  Future<void> initialize() async {
    _signedIn = false;
    _loading = false;
    notifyListeners();
  }

  Future<String> apiToken() async => AppConfig.devUserToken;

  Future<void> signIn(String email, String password) async {
    if (email.trim().isEmpty || password.isEmpty) throw StateError('Credenciais inválidas');
    _signedIn = true;
    notifyListeners();
  }

  Future<void> createAccount(String email, String password) => signIn(email, password);
  Future<void> resetPassword(String email) async {}
  Future<String?> fcmToken() async => null;

  Future<void> signOut() async {
    _signedIn = false;
    notifyListeners();
  }
}
