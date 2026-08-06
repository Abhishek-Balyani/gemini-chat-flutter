import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../core/constants/app_colors.dart';
import '../core/constants/app_strings.dart';
import '../core/services/audio_service.dart';
import '../modules/chat/chat_controller.dart';
import 'voice_input_overlay.dart';

class ChatInputBox extends StatefulWidget {
  final TextEditingController controller;
  final FocusNode focusNode;
  final ValueChanged<String> onSend;
  final bool isLoading;
  final VoidCallback? onStop;

  const ChatInputBox({
    super.key,
    required this.controller,
    required this.focusNode,
    required this.onSend,
    this.isLoading = false,
    this.onStop,
  });

  @override
  State<ChatInputBox> createState() => _ChatInputBoxState();
}

class _ChatInputBoxState extends State<ChatInputBox> {
  bool _canSend = false;

  @override
  void initState() {
    super.initState();
    widget.controller.addListener(_handleTextChange);
  }

  void _handleTextChange() {
    final chatController = Get.find<ChatController>();
    final hasText = widget.controller.text.trim().isNotEmpty || chatController.pendingAttachments.isNotEmpty;
    if (hasText != _canSend) {
      setState(() {
        _canSend = hasText;
      });
    }
  }

  @override
  void dispose() {
    widget.controller.removeListener(_handleTextChange);
    super.dispose();
  }

  void _submit() {
    final chatController = Get.find<ChatController>();
    final hasContent = widget.controller.text.trim().isNotEmpty || chatController.pendingAttachments.isNotEmpty;
    if (hasContent && !widget.isLoading) {
      final text = widget.controller.text.trim();
      widget.controller.clear();
      widget.onSend(text);
      setState(() {
        _canSend = false;
      });
    }
  }

  void _openVoiceOverlay() async {
    final audioService = Get.find<AudioService>();
    final started = await audioService.startListening(
      onResult: (words) {
        widget.controller.text = words;
      },
    );

    if (started && mounted) {
      Get.bottomSheet(
        VoiceInputOverlay(
          onSendVoiceText: (voiceText) {
            widget.controller.text = voiceText;
            _submit();
          },
        ),
        isScrollControlled: true,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = context.isDarkMode;
    final chatController = Get.find<ChatController>();

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkBackground : AppColors.lightBackground,
        border: Border(
          top: BorderSide(
            color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
            width: 0.5,
          ),
        ),
      ),
      child: SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Pending Attachments Preview Chips
            Obx(() {
              if (chatController.pendingAttachments.isEmpty) return const SizedBox.shrink();
              return Container(
                margin: const EdgeInsets.only(bottom: 8),
                height: 48,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: chatController.pendingAttachments.length,
                  itemBuilder: (context, index) {
                    final att = chatController.pendingAttachments[index];
                    return Container(
                      margin: const EdgeInsets.only(right: 8),
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                      decoration: BoxDecoration(
                        color: isDark ? AppColors.darkSurface : AppColors.lightSurface,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: AppColors.primary.withValues(alpha: 0.5),
                          width: 1,
                        ),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            att.isImage ? Icons.image_rounded : Icons.description_rounded,
                            size: 16,
                            color: AppColors.primary,
                          ),
                          const SizedBox(width: 6),
                          Text(
                            att.name.length > 15 ? '${att.name.substring(0, 15)}...' : att.name,
                            style: context.textTheme.bodySmall?.copyWith(fontWeight: FontWeight.w600),
                          ),
                          const SizedBox(width: 4),
                          InkWell(
                            onTap: () {
                              chatController.removePendingAttachment(att);
                              _handleTextChange();
                            },
                            child: const Icon(Icons.close_rounded, size: 14, color: AppColors.darkTextSecondary),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              );
            }),

            Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                // File Attachment Paperclip Button
                GestureDetector(
                  onTap: () async {
                    await chatController.pickAttachment();
                    _handleTextChange();
                  },
                  child: Container(
                    width: 44,
                    height: 44,
                    margin: const EdgeInsets.only(right: 6),
                    decoration: BoxDecoration(
                      color: isDark ? AppColors.darkInput : AppColors.lightInput,
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
                        width: 0.5,
                      ),
                    ),
                    child: const Icon(
                      Icons.attach_file_rounded,
                      color: AppColors.primary,
                      size: 20,
                    ),
                  ),
                ),

                // Voice Microphone Button
                GestureDetector(
                  onTap: _openVoiceOverlay,
                  child: Container(
                    width: 44,
                    height: 44,
                    margin: const EdgeInsets.only(right: 8),
                    decoration: BoxDecoration(
                      color: isDark ? AppColors.darkInput : AppColors.lightInput,
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
                        width: 0.5,
                      ),
                    ),
                    child: const Icon(
                      Icons.mic_none_rounded,
                      color: AppColors.primary,
                      size: 20,
                    ),
                  ),
                ),

                // Text Input Box
                Expanded(
                  child: Container(
                    decoration: BoxDecoration(
                      color: isDark ? AppColors.darkInput : AppColors.lightInput,
                      borderRadius: BorderRadius.circular(24),
                      border: Border.all(
                        color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
                        width: 0.5,
                      ),
                    ),
                    child: TextField(
                      controller: widget.controller,
                      focusNode: widget.focusNode,
                      minLines: 1,
                      maxLines: 5,
                      keyboardType: TextInputType.multiline,
                      style: context.textTheme.bodyMedium?.copyWith(
                        color: isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary,
                      ),
                      decoration: InputDecoration(
                        hintText: AppStrings.askAnything,
                        hintStyle: TextStyle(
                          color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
                        ),
                        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                        border: InputBorder.none,
                        enabledBorder: InputBorder.none,
                        focusedBorder: InputBorder.none,
                      ),
                      onSubmitted: (_) => _submit(),
                    ),
                  ),
                ),
                const SizedBox(width: 8),

                // Send / Stop Button
                Obx(() {
                  final hasPending = chatController.pendingAttachments.isNotEmpty;
                  final canSubmit = _canSend || hasPending;

                  return GestureDetector(
                    onTap: widget.isLoading ? widget.onStop : _submit,
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      width: 44,
                      height: 44,
                      decoration: BoxDecoration(
                        color: widget.isLoading
                            ? AppColors.error
                            : canSubmit
                                ? AppColors.primary
                                : (isDark ? AppColors.darkInput : AppColors.lightInput),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        widget.isLoading
                            ? Icons.stop_rounded
                            : Icons.arrow_upward_rounded,
                        color: (widget.isLoading || canSubmit)
                            ? Colors.white
                            : (isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary),
                        size: 22,
                      ),
                    ),
                  );
                }),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
