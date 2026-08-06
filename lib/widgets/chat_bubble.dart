import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:get/get.dart';
import '../core/constants/app_colors.dart';
import '../core/constants/app_strings.dart';
import '../core/services/audio_service.dart';
import '../core/utils/date_formatter.dart';
import '../data/models/chat_message_model.dart';
import 'custom_avatar.dart';
import 'markdown_widget.dart';

class ChatBubble extends StatelessWidget {
  final ChatMessageModel message;
  final VoidCallback? onRetry;
  final VoidCallback? onRegenerate;
  final VoidCallback? onDelete;

  const ChatBubble({
    super.key,
    required this.message,
    this.onRetry,
    this.onRegenerate,
    this.onDelete,
  });

  void _copyToClipboard(BuildContext context) {
    Clipboard.setData(ClipboardData(text: message.content));
    Get.snackbar(
      'Copied',
      AppStrings.messageCopied,
      snackPosition: SnackPosition.TOP,
      duration: const Duration(seconds: 2),
      backgroundColor: context.isDarkMode ? AppColors.darkSurface : AppColors.lightSurface,
      colorText: context.isDarkMode ? AppColors.darkTextPrimary : AppColors.lightTextPrimary,
      margin: const EdgeInsets.all(16),
      borderRadius: 12,
    );
  }

  void _showContextMenu(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: context.isDarkMode ? AppColors.darkSurface : AppColors.lightSurface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: const Icon(Icons.copy_rounded),
                title: const Text(AppStrings.copy),
                onTap: () {
                  Navigator.pop(context);
                  _copyToClipboard(context);
                },
              ),
              if (!message.isUser && onRegenerate != null)
                ListTile(
                  leading: const Icon(Icons.refresh_rounded),
                  title: const Text('Regenerate Response'),
                  onTap: () {
                    Navigator.pop(context);
                    onRegenerate!();
                  },
                ),
              if (onDelete != null)
                ListTile(
                  leading: const Icon(Icons.delete_outline, color: AppColors.error),
                  title: const Text(AppStrings.delete, style: TextStyle(color: AppColors.error)),
                  onTap: () {
                    Navigator.pop(context);
                    onDelete!();
                  },
                ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = context.isDarkMode;
    final isUser = message.isUser;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      child: Row(
        mainAxisAlignment: isUser ? MainAxisAlignment.end : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (!isUser) ...[
            const CustomAvatar(isUser: false, size: 30),
            const SizedBox(width: 10),
          ],
          Flexible(
            child: Column(
              crossAxisAlignment: isUser ? CrossAxisAlignment.end : CrossAxisAlignment.start,
              children: [
                GestureDetector(
                  onLongPress: () => _showContextMenu(context),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    decoration: BoxDecoration(
                      color: message.isError
                          ? AppColors.error.withValues(alpha: 0.1)
                          : isUser
                              ? (isDark ? AppColors.darkUserBubble : AppColors.lightUserBubble)
                              : (isDark ? AppColors.darkAiBubble : AppColors.lightAiBubble),
                      borderRadius: BorderRadius.only(
                        topLeft: const Radius.circular(18),
                        topRight: const Radius.circular(18),
                        bottomLeft: isUser ? const Radius.circular(18) : const Radius.circular(4),
                        bottomRight: isUser ? const Radius.circular(4) : const Radius.circular(18),
                      ),
                      border: Border.all(
                        color: message.isError
                            ? AppColors.error.withValues(alpha: 0.4)
                            : isDark
                                ? AppColors.darkBorder
                                : AppColors.lightBorder,
                        width: 0.5,
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (message.attachments != null && message.attachments!.isNotEmpty) ...[
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: message.attachments!.map((att) {
                              if (att.isImage && att.bytes != null) {
                                return Container(
                                  margin: const EdgeInsets.only(bottom: 8),
                                  clipBehavior: Clip.antiAlias,
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  constraints: const BoxConstraints(maxHeight: 220, maxWidth: 300),
                                  child: Image.memory(
                                    att.bytes!,
                                    fit: BoxFit.cover,
                                  ),
                                );
                              }
                              return Container(
                                margin: const EdgeInsets.only(bottom: 8),
                                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                                decoration: BoxDecoration(
                                  color: isDark ? AppColors.darkSurface : AppColors.lightSurface,
                                  borderRadius: BorderRadius.circular(10),
                                  border: Border.all(
                                    color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
                                    width: 0.5,
                                  ),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    const Icon(Icons.insert_drive_file_rounded, size: 20, color: AppColors.primary),
                                    const SizedBox(width: 8),
                                    Flexible(
                                      child: Text(
                                        att.name,
                                        style: context.textTheme.bodyMedium?.copyWith(
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              );
                            }).toList(),
                          ),
                        ],
                        CustomMarkdownWidget(
                          content: message.content,
                          isUser: isUser,
                        ),
                        if (message.isError && onRetry != null) ...[
                          const SizedBox(height: 8),
                          GestureDetector(
                            onTap: onRetry,
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Icon(Icons.refresh, size: 14, color: AppColors.error),
                                const SizedBox(width: 4),
                                Text(
                                  AppStrings.retry,
                                  style: context.textTheme.bodySmall?.copyWith(
                                    color: AppColors.error,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 4),

                // Action Bar (Timestamp, Copy Button, Regenerate, Delete Button)
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      DateFormatter.formatTime(message.timestamp),
                      style: context.textTheme.bodySmall?.copyWith(fontSize: 10),
                    ),
                    const SizedBox(width: 8),
                    // TTS Read Aloud Button
                    GetBuilder<GetMaterialController>(
                      builder: (_) {
                        final audioService = Get.find<AudioService>();
                        return Obx(() {
                          final isSpeakingThis = audioService.speakingMessageId.value == message.id &&
                              audioService.isPlayingTts.value;
                          return InkWell(
                            onTap: () => audioService.speak(message.id, message.content),
                            borderRadius: BorderRadius.circular(4),
                            child: Padding(
                              padding: const EdgeInsets.all(2.0),
                              child: Icon(
                                isSpeakingThis ? Icons.volume_up_rounded : Icons.volume_mute_rounded,
                                size: 14,
                                color: isSpeakingThis ? AppColors.primary : AppColors.darkTextSecondary,
                              ),
                            ),
                          );
                        });
                      },
                    ),
                    const SizedBox(width: 4),
                    InkWell(
                      onTap: () => _copyToClipboard(context),
                      borderRadius: BorderRadius.circular(4),
                      child: const Padding(
                        padding: EdgeInsets.all(2.0),
                        child: Icon(Icons.copy_rounded, size: 13, color: AppColors.darkTextSecondary),
                      ),
                    ),
                    if (!isUser && onRegenerate != null) ...[
                      const SizedBox(width: 4),
                      InkWell(
                        onTap: onRegenerate,
                        borderRadius: BorderRadius.circular(4),
                        child: const Padding(
                          padding: EdgeInsets.all(2.0),
                          child: Icon(Icons.refresh_rounded, size: 14, color: AppColors.darkTextSecondary),
                        ),
                      ),
                    ],
                    if (onDelete != null) ...[
                      const SizedBox(width: 4),
                      InkWell(
                        onTap: onDelete,
                        borderRadius: BorderRadius.circular(4),
                        child: const Padding(
                          padding: EdgeInsets.all(2.0),
                          child: Icon(Icons.delete_outline, size: 14, color: AppColors.darkTextSecondary),
                        ),
                      ),
                    ],
                  ],
                ),
              ],
            ),
          ),
          if (isUser) ...[
            const SizedBox(width: 10),
            const CustomAvatar(isUser: true, size: 30),
          ],
        ],
      ),
    ).animate().fadeIn(duration: 250.ms).slideY(begin: 0.1, end: 0);
  }
}
