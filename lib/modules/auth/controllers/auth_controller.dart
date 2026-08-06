import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../core/constants/app_colors.dart';
import '../models/user_model.dart';
import '../repositories/auth_repository.dart';

class AuthController extends GetxController {
  final AuthRepository _authRepository = Get.find<AuthRepository>();

  final Rxn<UserModel> user = Rxn<UserModel>();
  final isLoading = false.obs;
  final errorMessage = ''.obs;

  bool get isLoggedIn => user.value != null;
  bool get isAnonymous => user.value?.isAnonymous ?? false;
  String get userName => user.value?.displayName ?? 'User';
  String get userEmail => user.value?.email ?? '';

  @override
  void onInit() {
    super.onInit();
    user.value = _authRepository.getCachedUser();
  }

  Future<void> signInAnonymously() async {
    await _executeAuthTask(() => _authRepository.signInAnonymously());
  }

  Future<void> signInWithEmailPassword(String email, String password) async {
    await _executeAuthTask(() => _authRepository.signInWithEmailPassword(email, password));
  }

  Future<void> signUpWithEmailPassword(String email, String password, String displayName) async {
    await _executeAuthTask(() => _authRepository.signUpWithEmailPassword(email, password, displayName));
  }

  Future<void> signInWithGoogle() async {
    isLoading.value = true;
    errorMessage.value = '';
    try {
      final loggedInUser = await _authRepository.signInWithGoogle();
      if (loggedInUser != null) {
        user.value = loggedInUser;
        Get.snackbar(
          'Welcome',
          'Signed in as ${loggedInUser.displayName ?? 'User'}',
          snackPosition: SnackPosition.TOP,
          backgroundColor: AppColors.primary,
          colorText: Colors.white,
        );
        Get.offAllNamed('/home');
      } else {
        // User cancelled Google Sign-In flow
        if (Get.isSnackbarOpen) Get.back();
      }
    } catch (e) {
      errorMessage.value = e.toString();
      Get.snackbar(
        'Google Sign-In Error',
        e.toString(),
        snackPosition: SnackPosition.TOP,
        backgroundColor: AppColors.error,
        colorText: Colors.white,
      );
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> signInWithApple() async {
    await _executeNullableAuthTask(() => _authRepository.signInWithApple());
  }

  Future<void> signInWithFacebook() async {
    await _executeNullableAuthTask(() => _authRepository.signInWithFacebook());
  }

  Future<void> signOut() async {
    isLoading.value = true;
    try {
      await _authRepository.signOut();
      user.value = null;
      Get.snackbar(
        'Signed Out',
        'You have successfully signed out.',
        snackPosition: SnackPosition.TOP,
      );
      Get.offAllNamed('/auth/login');
    } catch (e) {
      Get.snackbar(
        'Sign Out Error',
        e.toString(),
        snackPosition: SnackPosition.TOP,
        backgroundColor: AppColors.error,
        colorText: Colors.white,
      );
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> _executeAuthTask(Future<UserModel> Function() authFunction) async {
    isLoading.value = true;
    errorMessage.value = '';
    try {
      final loggedInUser = await authFunction();
      user.value = loggedInUser;
      Get.snackbar(
        'Welcome',
        'Signed in as ${loggedInUser.displayName ?? 'User'}',
        snackPosition: SnackPosition.TOP,
        backgroundColor: AppColors.primary,
        colorText: Colors.white,
      );
      Get.offAllNamed('/home');
    } catch (e) {
      errorMessage.value = e.toString();
      Get.snackbar(
        'Authentication Error',
        e.toString(),
        snackPosition: SnackPosition.TOP,
        backgroundColor: AppColors.error,
        colorText: Colors.white,
      );
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> _executeNullableAuthTask(Future<UserModel?> Function() authFunction) async {
    isLoading.value = true;
    errorMessage.value = '';
    try {
      final loggedInUser = await authFunction();
      if (loggedInUser != null) {
        user.value = loggedInUser;
        Get.snackbar(
          'Welcome',
          'Signed in as ${loggedInUser.displayName ?? 'User'}',
          snackPosition: SnackPosition.TOP,
          backgroundColor: AppColors.primary,
          colorText: Colors.white,
        );
        Get.offAllNamed('/home');
      }
    } catch (e) {
      errorMessage.value = e.toString();
      Get.snackbar(
        'Authentication Error',
        e.toString(),
        snackPosition: SnackPosition.TOP,
        backgroundColor: AppColors.error,
        colorText: Colors.white,
      );
    } finally {
      isLoading.value = false;
    }
  }
}
