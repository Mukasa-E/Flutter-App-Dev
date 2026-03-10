import '../models/app_user.dart';

class AuthService {
  AppUser? _currentUser;

  AppUser? get currentUser => _currentUser;

  Future<AppUser> signUp({
    required String email,
    required String password,
    required String name,
  }) async {
    await Future.delayed(const Duration(milliseconds: 800));

    _currentUser = AppUser(
      uid: 'demo_uid_001',
      email: email,
      name: name,
      createdAt: DateTime.now(),
    );

    return _currentUser!;
  }

  Future<AppUser> login({
    required String email,
    required String password,
  }) async {
    await Future.delayed(const Duration(milliseconds: 800));

    _currentUser = AppUser(
      uid: 'demo_uid_001',
      email: email,
      name: 'Demo User',
      createdAt: DateTime.now(),
    );

    return _currentUser!;
  }

  Future<void> logout() async {
    await Future.delayed(const Duration(milliseconds: 300));
    _currentUser = null;
  }

  Future<bool> isEmailVerified() async {
    await Future.delayed(const Duration(milliseconds: 300));
    return true;
  }
}