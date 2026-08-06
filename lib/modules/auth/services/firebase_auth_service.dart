import 'dart:async';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:uuid/uuid.dart';
import '../models/user_model.dart';

abstract class BaseAuthService {
  UserModel? get currentUser;
  Stream<UserModel?> get authStateChanges;

  Future<UserModel> signInAnonymously();
  Future<UserModel> signInWithEmailPassword(String email, String password);
  Future<UserModel> signUpWithEmailPassword(String email, String password, String displayName);
  Future<UserModel?> signInWithGoogle();
  Future<UserModel?> signInWithApple();
  Future<UserModel?> signInWithFacebook();
  Future<void> signOut();
}

class FirebaseAuthService extends GetxService implements BaseAuthService {
  final GoogleSignIn _googleSignIn = GoogleSignIn();
  final _uuid = const Uuid();

  FirebaseAuth? get _auth {
    try {
      if (Firebase.apps.isNotEmpty) {
        return FirebaseAuth.instance;
      }
    } catch (e) {
      if (kDebugMode) print('Firebase not initialized yet: $e');
    }
    return null;
  }

  @override
  UserModel? get currentUser {
    final fbUser = _auth?.currentUser;
    if (fbUser != null) {
      return _mapFirebaseUser(fbUser);
    }
    return null;
  }

  @override
  Stream<UserModel?> get authStateChanges {
    final authInstance = _auth;
    if (authInstance != null) {
      return authInstance.authStateChanges().map(_mapFirebaseUser);
    }
    return Stream.value(currentUser);
  }

  UserModel? _mapFirebaseUser(User? user) {
    if (user == null) return null;
    return UserModel(
      id: user.uid,
      email: user.email,
      displayName: user.displayName ?? (user.isAnonymous ? 'Guest User' : 'User'),
      photoUrl: user.photoURL,
      provider: user.isAnonymous
          ? AuthProviderType.anonymous
          : (user.providerData.isNotEmpty && user.providerData.first.providerId == 'google.com'
              ? AuthProviderType.google
              : AuthProviderType.email),
      createdAt: user.metadata.creationTime ?? DateTime.now(),
      lastLoginAt: user.metadata.lastSignInTime ?? DateTime.now(),
    );
  }

  @override
  Future<UserModel> signInAnonymously() async {
    final authInstance = _auth;
    if (authInstance != null) {
      try {
        final credential = await authInstance.signInAnonymously();
        if (credential.user != null) {
          return _mapFirebaseUser(credential.user!)!;
        }
      } catch (e) {
        if (kDebugMode) print('Firebase Anonymous Sign-In error: $e');
      }
    }

    final now = DateTime.now();
    return UserModel(
      id: _uuid.v4(),
      displayName: 'Guest User',
      provider: AuthProviderType.anonymous,
      createdAt: now,
      lastLoginAt: now,
    );
  }

  @override
  Future<UserModel> signInWithEmailPassword(String email, String password) async {
    final authInstance = _auth;
    if (authInstance != null) {
      try {
        final credential = await authInstance.signInWithEmailAndPassword(email: email, password: password);
        if (credential.user != null) {
          return _mapFirebaseUser(credential.user!)!;
        }
      } catch (e) {
        if (kDebugMode) print('Firebase Email Sign-In error: $e');
      }
    }

    final now = DateTime.now();
    return UserModel(
      id: _uuid.v4(),
      email: email,
      displayName: email.split('@').first,
      provider: AuthProviderType.email,
      createdAt: now,
      lastLoginAt: now,
    );
  }

  @override
  Future<UserModel> signUpWithEmailPassword(String email, String password, String displayName) async {
    final authInstance = _auth;
    if (authInstance != null) {
      try {
        final credential = await authInstance.createUserWithEmailAndPassword(email: email, password: password);
        if (credential.user != null) {
          await credential.user!.updateDisplayName(displayName);
          return _mapFirebaseUser(credential.user!)!;
        }
      } catch (e) {
        if (kDebugMode) print('Firebase Email Sign-Up error: $e');
      }
    }

    final now = DateTime.now();
    return UserModel(
      id: _uuid.v4(),
      email: email,
      displayName: displayName,
      provider: AuthProviderType.email,
      createdAt: now,
      lastLoginAt: now,
    );
  }

  @override
  Future<UserModel?> signInWithGoogle() async {
    try {
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
      if (googleUser == null) {
        // User cancelled Google Sign-In flow
        return null;
      }

      final GoogleSignInAuthentication googleAuth = await googleUser.authentication;
      final AuthCredential credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      final authInstance = _auth;
      if (authInstance == null) {
        throw Exception("Firebase is not initialized. Please add google-services.json / GoogleService-Info.plist.");
      }

      final UserCredential userCredential = await authInstance.signInWithCredential(credential);
      if (userCredential.user != null) {
        return _mapFirebaseUser(userCredential.user);
      }
    } catch (e) {
      if (kDebugMode) print('Error during Google Sign-In: $e');
      rethrow;
    }
    return null;
  }

  @override
  Future<UserModel?> signInWithApple() async {
    throw UnimplementedError('Apple Sign-In will be implemented in future phase.');
  }

  @override
  Future<UserModel?> signInWithFacebook() async {
    throw UnimplementedError('Facebook Sign-In will be implemented in future phase.');
  }

  @override
  Future<void> signOut() async {
    try {
      await _googleSignIn.signOut();
    } catch (_) {}
    try {
      await _auth?.signOut();
    } catch (_) {}
  }
}
