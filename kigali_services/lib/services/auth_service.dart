import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  User? get currentUser => _auth.currentUser;

  Future<UserCredential> signUp({
    required String email,
    required String password,
    required String name,
  }) async {
    final credential = await _auth.createUserWithEmailAndPassword(
      email: email,
      password: password,
    );

    final user = credential.user;
    if (user == null) {
      throw Exception('User account was not created.');
    }

    await user.updateDisplayName(name);
    await user.sendEmailVerification();

    await _firestore.collection('users').doc(user.uid).set({
      'uid': user.uid,
      'email': email,
      'name': name,
      'createdAt': Timestamp.now(),
    });

    return credential;
  }

  Future<UserCredential> login({
    required String email,
    required String password,
  }) async {
    final credential = await _auth.signInWithEmailAndPassword(
      email: email,
      password: password,
    );

    await credential.user?.reload();
    final refreshedUser = FirebaseAuth.instance.currentUser;

    if (refreshedUser == null) {
      throw Exception('Unable to load user.');
    }

    if (!refreshedUser.emailVerified) {
      await _auth.signOut();
      throw Exception('Please verify your email before logging in.');
    }

    return credential;
  }

  Future<void> resendVerificationEmail() async {
    final user = _auth.currentUser;
    if (user == null) {
      throw Exception('No signed-in user found.');
    }
    await user.sendEmailVerification();
  }

  Future<bool> checkEmailVerified() async {
    final user = _auth.currentUser;
    if (user == null) return false;

    await user.reload();
    return FirebaseAuth.instance.currentUser?.emailVerified ?? false;
  }

  Future<void> logout() async {
    await _auth.signOut();
  }
}