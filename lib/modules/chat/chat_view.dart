import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_strings.dart';
import '../../core/services/theme_service.dart';
import '../../widgets/chat_bubble.dart';
import '../../widgets/chat_input_box.dart';
import '../../widgets/typing_indicator.dart';
import '../home/home_controller.dart';
import 'chat_controller.dart';

class ChatView extends GetView<ChatController> {
  const ChatView({super.key});

  @override
  Widget build(BuildContext context) {
    final themeService = Get.find<ThemeService>();
    final homeController = Get.find<HomeController>();

    return Scaffold(
      appBar: AppBar(
        titleSpacing: 0,
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.15),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.auto_awesome, color: AppColors.primary, size: 20),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Obx(
                    () => Text(
                      homeController.activeConversation.value?.title ?? AppStrings.appName,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: context.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  Obx(
                    () => Text(
                      controller.selectedModel.value,
                      style: context.textTheme.bodySmall?.copyWith(
                        color: AppColors.primary,
                        fontSize: 11,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: Icon(
              themeService.isDarkMode ? Icons.light_mode_outlined : Icons.dark_mode_outlined,
            ),
            tooltip: 'Toggle Theme',
            onPressed: () => themeService.toggleTheme(),
          ),
          IconButton(
            icon: const Icon(Icons.settings_outlined),
            tooltip: 'Settings',
            onPressed: () => Get.toNamed('/settings'),
          ),
          IconButton(
            icon: const Icon(Icons.delete_sweep_outlined),
            tooltip: 'Clear Chat',
            onPressed: () => controller.clearChat(),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: Column(
        children: [
          // Scrollable Message List View
          Expanded(
            child: Align(
              alignment: Alignment.topCenter,
              child: Container(
                constraints: const BoxConstraints(maxWidth: 900),
                child: Obx(
                  () {
                    if (controller.messages.isEmpty && !controller.isTyping.value) {
                      return Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(
                              Icons.chat_bubble_outline_rounded,
                              size: 64,
                              color: AppColors.darkTextSecondary,
                            ),
                            const SizedBox(height: 16),
                            Text(
                              'How can I help you today?',
                              style: context.textTheme.headlineMedium?.copyWith(
                                color: AppColors.darkTextSecondary,
                              ),
                            ),
                          ],
                        ),
                      );
                    }

                    return ListView.builder(
                      controller: controller.scrollController,
                      padding: const EdgeInsets.only(top: 16, bottom: 16),
                      itemCount: controller.messages.length + (controller.isTyping.value ? 1 : 0),
                      itemBuilder: (context, index) {
                        if (index < controller.messages.length) {
                          final message = controller.messages[index];
                          return ChatBubble(
                            message: message,
                            onDelete: () => controller.deleteMessage(message.id),
                            onRegenerate: !message.isUser && index == controller.messages.length - 1
                                ? () => controller.regenerateLastResponse()
                                : null,
                            onRetry: message.isError
                                ? () => controller.retryLastMessage(message)
                                : null,
                          );
                        } else {
                          return const TypingIndicator();
                        }
                      },
                    );
                  },
                ),
              ),
            ),
          ),

          // Bottom Input Box
          Align(
            alignment: Alignment.bottomCenter,
            child: Container(
              constraints: const BoxConstraints(maxWidth: 900),
              child: Obx(
                () => ChatInputBox(
                  controller: controller.textEditingController,
                  focusNode: controller.focusNode,
                  isLoading: controller.isTyping.value,
                  onSend: (text) => controller.sendMessage(text),
                  onStop: () => controller.isTyping.value = false,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
