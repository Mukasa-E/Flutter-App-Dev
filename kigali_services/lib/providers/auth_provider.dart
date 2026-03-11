import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../services/auth_service.dart';

/// AuthProvider manages Firebase Authentication state across the application.
///
/// This provider uses the Provider pattern to expose authentication state and
/// operations to the UI without direct Firebase dependencies. It handles:
/// - User sign up with email/password
/// - User login/logout
/// - Email verification enforcement
/// - Loading and error states
///
/// Architecture Flow:
/// UI (LoginScreen) → AuthProvider (state management) → AuthService (Firestore)
class AuthProvider extends ChangeNotifier {
  final AuthService _authService = AuthService();

  /// The currently authenticated Firebase user, or null if not logged in
  User? _user = FirebaseAuth.instance.currentUser;

  /// Whether an auth operation is in progress (for showing loaders)
  bool _isLoading = false;

  /// Error message from the most recent auth operation
  String? _error;

  // Getters for UI consumption
  User? get user => _user;
  bool get isLoading => _isLoading;
  String? get error => _error;

  /// True if a user is logged in (user != null)
  bool get isLoggedIn => _user != null;

  /// True if the logged-in user has verified their email address
  bool get isVerified => _user?.emailVerified ?? false;

  /// Creates a new user account with Firebase Authentication.
  ///
  /// After successful signup:
  /// 1. User document is created in Firestore with their UID
  /// 2. Verification email is sent
  /// 3. User remains logged in (but unverified until email confirmation)
  ///
  /// Parameters:
  ///   email: User's email address
  ///   password: User's password (min 6 characters)
  ///   name: User's display name
  ///
  /// Returns: true if signup successful, false otherwise
  /// Error message is stored in _error
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

  /// Authenticates an existing user with email/password.
  ///
  /// The app requires email verification, so users must verify before
  /// accessing the full app functionality. See checkEmailVerified().
  ///
  /// Parameters:
  ///   email: User's registered email
  ///   password: User's password
  ///
  /// Returns: true if login successful, false otherwise
  /// Error message is stored in _error
  Future<bool> login({required String email, required String password}) async {
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

  /// Checks if the current user has verified their email address.
  ///
  /// This should be called periodically while user is on verification screen.
  /// Firebase auth state is refreshed to get latest verification status.
  ///
  /// Returns: true if email is verified, false otherwise
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

  /// Sends a new verification email to the user.
  ///
  /// Called when user didn't receive initial verification email
  /// or link expired.
  Future<void> resendVerificationEmail() async {
    await _authService.resendVerificationEmail();
  }

  /// Logs out the current user from Firebase and clears auth state.
  ///
  /// After logout:
  /// - _user is set to null
  /// - _error is cleared
  /// - All listeners are notified (UI rebuilds)
  /// - App navigates back to login screen
  Future<void> logout() async {
    _setLoading(true);

    await _authService.logout();
    _user = null;
    _error = null;

    _setLoading(false);
    notifyListeners();
  }

  /// Private helper to set loading state and notify listeners.
  /// Used internally to show/hide loading indicators in UI.
  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }
}
