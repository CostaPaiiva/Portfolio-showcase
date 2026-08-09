import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import '../core/app_config.dart';

class AuthService extends ChangeNotifier {
  bool _firebaseReady = false;
  bool _loading = true;
  String? _error;
  bool _devSignedIn = false;

  bool get loading => _loading;
  String? get error => _error;
  bool get signedIn => _devSignedIn || (_firebaseReady && FirebaseAuth.instance.currentUser != null);

  Future<void> initialize() async {
    try {
      await Firebase.initializeApp();
      _firebaseReady = true;
    } catch (_) {
      _firebaseReady = false;
    }

    if (!_firebaseReady && AppConfig.devUserToken.isNotEmpty) {
      _devSignedIn = true;
    }

    _loading = false;
    notifyListeners();
  }

  Future<String> apiToken() async {
    if (_firebaseReady) {
      final token = await FirebaseAuth.instance.currentUser?.getIdToken();
      if (token != null && token.isNotEmpty) return token;
    }
    return AppConfig.devUserToken;
  }

  Future<void> signIn(String email, String password) async {
    _error = null;
    if (!_firebaseReady) {
      _devSignedIn = true;
      notifyListeners();
      return;
    }

    try {
      await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );
      notifyListeners();
    } on FirebaseAuthException catch (e) {
      _error = e.message ?? e.code;
      notifyListeners();
      rethrow;
    }
  }

  Future<void> signOut() async {
    if (_firebaseReady) {
      await FirebaseAuth.instance.signOut();
    }
    _devSignedIn = false;
    notifyListeners();
  }
}
