import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_strings.dart';
import '../../../core/services/theme_service.dart';
import '../../../core/utils/date_formatter.dart';
import '../../../data/models/conversation_model.dart';
import '../home_controller.dart';

class SidebarDrawer extends StatelessWidget {
  const SidebarDrawer({super.key});

  void _showRenameDialog(BuildContext context, HomeController controller, ConversationModel chat) {
    final textController = TextEditingController(text: chat.title);

    Get.dialog(
      AlertDialog(
        title: const Text(AppStrings.renameChatTitle),
        content: TextField(
          controller: textController,
          autofocus: true,
          decoration: const InputDecoration(
            hintText: 'Enter conversation title',
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text(AppStrings.cancel),
          ),
          ElevatedButton(
            onPressed: () {
              final newTitle = textController.text.trim();
              if (newTitle.isNotEmpty) {
                controller.renameConversation(chat.id, newTitle);
              }
              Get.back();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
            ),
            child: const Text(AppStrings.save),
          ),
        ],
      ),
    );
  }

  void _showDeleteDialog(BuildContext context, HomeController controller, ConversationModel chat) {
    Get.dialog(
      AlertDialog(
        title: const Text(AppStrings.deleteChatTitle),
        content: const Text(AppStrings.deleteChatPrompt),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text(AppStrings.cancel),
          ),
          ElevatedButton(
            onPressed: () {
              controller.deleteConversation(chat.id);
              Get.back();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.error,
              foregroundColor: Colors.white,
            ),
            child: const Text(AppStrings.delete),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<HomeController>();
    final themeService = Get.find<ThemeService>();
    final isDark = context.isDarkMode;

    return Drawer(
      backgroundColor: isDark ? AppColors.darkSidebar : AppColors.lightSidebar,
      child: SafeArea(
        child: Column(
          children: [
            // New Chat Button
            Padding(
              padding: const EdgeInsets.all(12.0),
              child: InkWell(
                onTap: () {
                  controller.createNewConversation();
                  if (Scaffold.of(context).isDrawerOpen) {
                    Navigator.pop(context);
                  }
                },
                borderRadius: BorderRadius.circular(12),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  decoration: BoxDecoration(
                    border: Border.all(
                      color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
                      width: 1,
                    ),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.add, size: 20, color: AppColors.primary),
                      const SizedBox(width: 12),
                      Text(
                        AppStrings.newChat,
                        style: context.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),

            const Divider(height: 1),

            // Conversation List Grouped by Header
            Expanded(
              child: Obx(() {
                if (controller.conversations.isEmpty) {
                  return Center(
                    child: Text(
                      'No conversations yet',
                      style: context.textTheme.bodyMedium?.copyWith(
                        color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
                      ),
                    ),
                  );
                }

                return ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                  itemCount: controller.conversations.length,
                  itemBuilder: (context, index) {
                    final chat = controller.conversations[index];
                    return Obx(() {
                      final isActive = controller.activeConversation.value?.id == chat.id;

                      return Container(
                        margin: const EdgeInsets.symmetric(vertical: 2),
                        decoration: BoxDecoration(
                          color: isActive
                              ? (isDark ? AppColors.darkSurface : AppColors.lightCard)
                              : Colors.transparent,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: ListTile(
                          dense: true,
                          contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 0),
                          leading: Icon(
                            Icons.chat_bubble_outline_rounded,
                            size: 18,
                            color: isActive
                                ? AppColors.primary
                                : (isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary),
                          ),
                          title: Text(
                            chat.title,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: context.textTheme.bodyMedium?.copyWith(
                              fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
                              color: isActive
                                  ? (isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary)
                                  : (isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary),
                            ),
                          ),
                          subtitle: Text(
                            DateFormatter.formatDate(chat.updatedAt),
                            style: context.textTheme.bodySmall?.copyWith(fontSize: 10),
                          ),
                          trailing: isActive
                              ? Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    InkWell(
                                      onTap: () => _showRenameDialog(context, controller, chat),
                                      child: const Padding(
                                        padding: EdgeInsets.all(4.0),
                                        child: Icon(Icons.edit_outlined, size: 16),
                                      ),
                                    ),
                                    const SizedBox(width: 4),
                                    InkWell(
                                      onTap: () => _showDeleteDialog(context, controller, chat),
                                      child: const Padding(
                                        padding: EdgeInsets.all(4.0),
                                        child: Icon(Icons.delete_outline, size: 16, color: AppColors.error),
                                      ),
                                    ),
                                  ],
                                )
                              : null,
                          onTap: () {
                            controller.selectConversation(chat);
                            if (Scaffold.of(context).isDrawerOpen) {
                              Navigator.pop(context);
                            }
                          },
                        ),
                      );
                    });
                  },
                );
              }),
            ),

            const Divider(height: 1),

            // Footer (Profile, Settings & Theme Switcher)
            ListTile(
              leading: const Icon(Icons.person_outline_rounded, size: 20),
              title: Text('Profile', style: context.textTheme.bodyMedium),
              onTap: () {
                if (Scaffold.of(context).isDrawerOpen) {
                  Navigator.pop(context);
                }
                Get.toNamed('/profile');
              },
            ),
            ListTile(
              leading: const Icon(Icons.settings_outlined, size: 20),
              title: Text('Settings', style: context.textTheme.bodyMedium),
              onTap: () {
                if (Scaffold.of(context).isDrawerOpen) {
                  Navigator.pop(context);
                }
                Get.toNamed('/settings');
              },
            ),
            ListTile(
              leading: Icon(
                isDark ? Icons.light_mode_outlined : Icons.dark_mode_outlined,
                size: 20,
              ),
              title: Text(
                isDark ? 'Light Mode' : 'Dark Mode',
                style: context.textTheme.bodyMedium,
              ),
              onTap: () => themeService.toggleTheme(),
            ),
          ],
        ),
      ),
    );
  }
}
