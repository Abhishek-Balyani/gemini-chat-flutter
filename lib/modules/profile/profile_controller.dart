import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import '../../core/constants/app_colors.dart';
import '../../core/services/theme_service.dart';
import '../auth/controllers/auth_controller.dart';
import '../auth/models/user_model.dart';

class ProfileController extends GetxController {
  final AuthController authController = Get.find<AuthController>();
  final ThemeService themeService = Get.find<ThemeService>();

  final displayNameController = TextEditingController();

  UserModel? get user => authController.user.value;
  bool get isDarkMode => themeService.isDarkMode;

  @override
  void onInit() {
    super.onInit();
    if (user != null) {
      displayNameController.text = user!.displayName ?? '';
    }
  }

  void toggleTheme(bool value) {
    themeService.toggleTheme();
    update();
  }

  void copyUid() {
    if (user?.id != null) {
      Clipboard.setData(ClipboardData(text: user!.id));
      Get.snackbar(
        'Copied',
        'User ID copied to clipboard',
        snackPosition: SnackPosition.TOP,
        duration: const Duration(seconds: 2),
      );
    }
  }

  void showEditProfileDialog() {
    displayNameController.text = user?.displayName ?? '';
    Get.dialog(
      AlertDialog(
        backgroundColor: AppColors.darkSurface,
        title: const Text('Edit Profile', style: TextStyle(color: Colors.white)),
        content: TextField(
          controller: displayNameController,
          style: const TextStyle(color: Colors.white),
          decoration: const InputDecoration(
            labelText: 'Display Name',
            labelStyle: TextStyle(color: AppColors.darkTextSecondary),
            enabledBorder: UnderlineInputBorder(
              borderSide: BorderSide(color: AppColors.darkBorder),
            ),
            focusedBorder: UnderlineInputBorder(
              borderSide: BorderSide(color: AppColors.primary),
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text('Cancel', style: TextStyle(color: AppColors.darkTextSecondary)),
          ),
          ElevatedButton(
            onPressed: () {
              final newName = displayNameController.text.trim();
              if (newName.isNotEmpty && user != null) {
                authController.user.value = user!.copyWith(displayName: newName);
                Get.back();
                Get.snackbar(
                  'Success',
                  'Profile updated',
                  snackPosition: SnackPosition.TOP,
                  backgroundColor: AppColors.primary,
                  colorText: Colors.white,
                );
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
            ),
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  void confirmDeleteAccount() {
    Get.dialog(
      AlertDialog(
        backgroundColor: AppColors.darkSurface,
        title: const Text('Delete Account', style: TextStyle(color: AppColors.error)),
        content: const Text(
          'Are you sure you want to delete your account? All data associated with your user ID will be permanently removed.',
          style: TextStyle(color: AppColors.darkTextSecondary),
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text('Cancel', style: TextStyle(color: Colors.white)),
          ),
          ElevatedButton(
            onPressed: () async {
              Get.back();
              await authController.signOut();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.error,
              foregroundColor: Colors.white,
            ),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  @override
  void onClose() {
    displayNameController.dispose();
    super.onClose();
  }
}
