import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import '../../core/constants/app_colors.dart';
import '../auth/models/user_model.dart';
import 'profile_controller.dart';

class ProfileView extends GetView<ProfileController> {
  const ProfileView({super.key});

  void _showPrivacyPolicy(BuildContext context) {
    Get.dialog(
      AlertDialog(
        backgroundColor: AppColors.darkSurface,
        title: const Text('Privacy Policy', style: TextStyle(color: Colors.white)),
        content: const SingleChildScrollView(
          child: Text(
            'Privacy Policy\n\n'
            '1. Data Privacy: Conversation history and custom preferences are stored locally on your device.\n\n'
            '2. Firebase Authentication: User identification details (UID, email) are authenticated securely via Firebase Auth.\n\n'
            '3. Storage: You can delete your chat history or account anytime.',
            style: TextStyle(color: AppColors.darkTextSecondary),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text('Close', style: TextStyle(color: AppColors.primary)),
          ),
        ],
      ),
    );
  }

  void _showAbout(BuildContext context) {
    Get.dialog(
      AlertDialog(
        backgroundColor: AppColors.darkSurface,
        title: const Text('About AI Chat Assistant', style: TextStyle(color: Colors.white)),
        content: const Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'AI Chat Assistant v1.0.0',
              style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 8),
            Text(
              'A production-quality AI Chat application built with Flutter, GetX, Clean Architecture, and Google Gemini API.',
              style: TextStyle(color: AppColors.darkTextSecondary),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text('Close', style: TextStyle(color: AppColors.primary)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = context.isDarkMode;

    return Scaffold(
      backgroundColor: isDark ? AppColors.darkBackground : AppColors.lightBackground,
      appBar: AppBar(
        title: const Text('Profile'),
        centerTitle: true,
        elevation: 0,
        backgroundColor: isDark ? AppColors.darkBackground : AppColors.lightBackground,
      ),
      body: SafeArea(
        child: Obx(() {
          final user = controller.user;
          if (user == null) {
            return const Center(
              child: Text(
                'No user signed in',
                style: TextStyle(color: AppColors.darkTextSecondary),
              ),
            );
          }

          final memberSinceFormatted = DateFormat.yMMMd().format(user.createdAt);
          final providerLabel = user.provider == AuthProviderType.google
              ? 'Google'
              : (user.provider == AuthProviderType.anonymous ? 'Guest' : 'Email');

          return Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20.0),
              child: Container(
                constraints: const BoxConstraints(maxWidth: 500),
                child: Column(
                  children: [
                    // Profile Header Card
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(24),
                      decoration: BoxDecoration(
                        color: isDark ? AppColors.darkSurface : AppColors.lightSurface,
                        borderRadius: BorderRadius.circular(24),
                        border: Border.all(
                          color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
                          width: 0.5,
                        ),
                      ),
                      child: Column(
                        children: [
                          // Profile Photo Avatar
                          Container(
                            width: 90,
                            height: 90,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              gradient: const LinearGradient(
                                colors: [AppColors.primary, AppColors.primaryLight],
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: AppColors.primary.withValues(alpha: 0.3),
                                  blurRadius: 20,
                                  spreadRadius: 2,
                                ),
                              ],
                            ),
                            child: ClipOval(
                              child: user.photoUrl != null && user.photoUrl!.isNotEmpty
                                  ? Image.network(
                                      user.photoUrl!,
                                      fit: BoxFit.cover,
                                      errorBuilder: (context, error, stackTrace) => _buildAvatarInitials(user),
                                    )
                                  : _buildAvatarInitials(user),
                            ),
                          ),
                          const SizedBox(height: 16),

                          // Display Name
                          Text(
                            user.displayName ?? 'User',
                            style: context.textTheme.headlineSmall?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary,
                            ),
                          ),
                          const SizedBox(height: 4),

                          // Email
                          if (user.email != null && user.email!.isNotEmpty)
                            Text(
                              user.email!,
                              style: context.textTheme.bodyMedium?.copyWith(
                                color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
                              ),
                            ),
                          const SizedBox(height: 12),

                          // Provider Badge
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                            decoration: BoxDecoration(
                              color: AppColors.primary.withValues(alpha: 0.15),
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(
                                color: AppColors.primary.withValues(alpha: 0.4),
                                width: 1,
                              ),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  user.provider == AuthProviderType.google
                                      ? Icons.g_mobiledata_rounded
                                      : (user.provider == AuthProviderType.anonymous
                                          ? Icons.person_outline_rounded
                                          : Icons.email_rounded),
                                  size: 18,
                                  color: AppColors.primary,
                                ),
                                const SizedBox(width: 6),
                                Text(
                                  '$providerLabel Account',
                                  style: const TextStyle(
                                    color: AppColors.primary,
                                    fontSize: 13,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),

                    // User Info Card (UID & Member Since)
                    Container(
                      decoration: BoxDecoration(
                        color: isDark ? AppColors.darkSurface : AppColors.lightSurface,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
                          width: 0.5,
                        ),
                      ),
                      child: Column(
                        children: [
                          ListTile(
                            leading: const Icon(Icons.fingerprint_rounded, color: AppColors.primary),
                            title: const Text('User ID (UID)'),
                            subtitle: Text(
                              user.id,
                              style: const TextStyle(fontSize: 12),
                              overflow: TextOverflow.ellipsis,
                            ),
                            trailing: IconButton(
                              icon: const Icon(Icons.copy_rounded, size: 18),
                              onPressed: controller.copyUid,
                            ),
                          ),
                          const Divider(height: 1, indent: 16, endIndent: 16),
                          ListTile(
                            leading: const Icon(Icons.calendar_today_rounded, color: AppColors.primary),
                            title: const Text('Member Since'),
                            subtitle: Text(memberSinceFormatted),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),

                    // Options & Settings List Card
                    Container(
                      decoration: BoxDecoration(
                        color: isDark ? AppColors.darkSurface : AppColors.lightSurface,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
                          width: 0.5,
                        ),
                      ),
                      child: Column(
                        children: [
                          ListTile(
                            leading: const Icon(Icons.edit_rounded, color: AppColors.primary),
                            title: const Text('Edit Profile'),
                            trailing: const Icon(Icons.chevron_right_rounded),
                            onTap: controller.showEditProfileDialog,
                          ),
                          const Divider(height: 1, indent: 16, endIndent: 16),
                          GetBuilder<ProfileController>(
                            builder: (ctrl) => SwitchListTile(
                              secondary: const Icon(Icons.dark_mode_rounded, color: AppColors.primary),
                              title: const Text('Dark Mode'),
                              value: ctrl.isDarkMode,
                              onChanged: ctrl.toggleTheme,
                            ),
                          ),
                          const Divider(height: 1, indent: 16, endIndent: 16),
                          ListTile(
                            leading: const Icon(Icons.privacy_tip_rounded, color: AppColors.primary),
                            title: const Text('Privacy Policy'),
                            trailing: const Icon(Icons.chevron_right_rounded),
                            onTap: () => _showPrivacyPolicy(context),
                          ),
                          const Divider(height: 1, indent: 16, endIndent: 16),
                          ListTile(
                            leading: const Icon(Icons.info_rounded, color: AppColors.primary),
                            title: const Text('About App'),
                            trailing: const Icon(Icons.chevron_right_rounded),
                            onTap: () => _showAbout(context),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),

                    // Logout & Delete Buttons Card
                    Container(
                      decoration: BoxDecoration(
                        color: isDark ? AppColors.darkSurface : AppColors.lightSurface,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
                          width: 0.5,
                        ),
                      ),
                      child: Column(
                        children: [
                          ListTile(
                            leading: const Icon(Icons.logout_rounded, color: Colors.orangeAccent),
                            title: const Text('Logout', style: TextStyle(color: Colors.orangeAccent)),
                            onTap: () => controller.authController.signOut(),
                          ),
                          const Divider(height: 1, indent: 16, endIndent: 16),
                          ListTile(
                            leading: const Icon(Icons.delete_forever_rounded, color: AppColors.error),
                            title: const Text('Delete Account', style: TextStyle(color: AppColors.error)),
                            onTap: controller.confirmDeleteAccount,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),
                  ],
                ),
              ),
            ),
          );
        }),
      ),
    );
  }

  Widget _buildAvatarInitials(UserModel user) {
    final name = user.displayName ?? 'U';
    final initial = name.isNotEmpty ? name[0].toUpperCase() : 'U';
    return Center(
      child: Text(
        initial,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 36,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}
