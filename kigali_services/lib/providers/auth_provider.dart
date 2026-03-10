import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../services/auth_service.dart';

class AuthProvider extends ChangeNotifier {
  final AuthService _authService = AuthService();

  User? _user = FirebaseAuth.instance.currentUser;
  bool _isLoading = false;
  String? _error;

  User? get user => _user;
  bool get isLoading => _isLoading;
  String? get error => _error;

  bool get isLoggedIn => _user != null;
  bool get isVerified => _user?.emailVerified ?? false;

  Future<bool> signUp({
    required String email,
    required String password,
    required String name,
  }) async {
    _setLoading(true);
    _error = null;

    try {
      final credential = await _authService.signUp(
        email: email,
        password: password,
        name: name,
      );

      _user = credential.user;
      notifyListeners();
      return true;
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return false;
    } finally {
      _setLoading(false);
    }
  }

  Future<bool> login({
    required String email,
    required String password,
  }) async {
    _setLoading(true);
    _error = null;

    try {
      final credential = await _authService.login(
        email: email,
        password: password,
      );

      _user = credential.user;
      notifyListeners();
      return true;
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return false;
    } finally {
      _setLoading(false);
    }
  }

  Future<bool> checkEmailVerified() async {
    _setLoading(true);

    try {
      final verified = await _authService.checkEmailVerified();
      _user = FirebaseAuth.instance.currentUser;
      notifyListeners();
      return verified;
    } finally {
      _setLoading(false);
    }
  }

  Future<void> resendVerificationEmail() async {
    await _authService.resendVerificationEmail();
  }

  Future<void> logout() async {
    _setLoading(true);

    await _authService.logout();
    _user = null;
    _error = null;

    _setLoading(false);
    notifyListeners();
  }

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }
}