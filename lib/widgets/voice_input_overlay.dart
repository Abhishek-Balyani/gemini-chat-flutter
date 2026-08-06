import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:get/get.dart';
import '../core/constants/app_colors.dart';
import '../core/services/audio_service.dart';

class VoiceInputOverlay extends StatelessWidget {
  final ValueChanged<String> onSendVoiceText;

  const VoiceInputOverlay({
    super.key,
    required this.onSendVoiceText,
  });

  @override
  Widget build(BuildContext context) {
    final audioService = Get.find<AudioService>();
    final isDark = context.isDarkMode;

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkSurface : AppColors.lightSurface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.2),
            blurRadius: 20,
            spreadRadius: 5,
          ),
        ],
      ),
      child: SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Handle bar
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 24),

            // Pulsing Glowing Microphone Icon
            Stack(
              alignment: Alignment.center,
              children: [
                Container(
                  width: 100,
                  height: 100,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: AppColors.error.withValues(alpha: 0.15),
                  ),
                )
                    .animate(onPlay: (c) => c.repeat(reverse: true))
                    .scale(begin: const Offset(1, 1), end: const Offset(1.3, 1.3), duration: 1000.ms),
                Container(
                  width: 80,
                  height: 80,
                  decoration: const BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: LinearGradient(
                      colors: [AppColors.error, Color(0xFFFF6B6B)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                  ),
                  child: const Icon(
                    Icons.mic_rounded,
                    color: Colors.white,
                    size: 40,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 24),

            // Status Indicator & Live Recognized Words
            Obx(
              () => Text(
                audioService.isListening.value ? 'Listening...' : 'Tap microphone to speak',
                style: context.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: audioService.isListening.value ? AppColors.error : AppColors.darkTextSecondary,
                ),
              ),
            ),

            const SizedBox(height: 12),

            // Live recognized text snippet
            Container(
              constraints: const BoxConstraints(minHeight: 50, maxHeight: 120),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              decoration: BoxDecoration(
                color: isDark ? AppColors.darkInput : AppColors.lightInput,
                borderRadius: BorderRadius.circular(12),
              ),
              child: SingleChildScrollView(
                child: Obx(
                  () => Text(
                    audioService.recognizedText.value.isEmpty
                        ? 'Say something...'
                        : audioService.recognizedText.value,
                    textAlign: TextAlign.center,
                    style: context.textTheme.bodyMedium?.copyWith(
                      fontStyle: audioService.recognizedText.value.isEmpty ? FontStyle.italic : FontStyle.normal,
                    ),
                  ),
                ),
              ),
            ),

            const SizedBox(height: 24),

            // Controls (Cancel / Done & Send)
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                OutlinedButton.icon(
                  onPressed: () {
                    audioService.stopListening();
                    Get.back();
                  },
                  icon: const Icon(Icons.close_rounded),
                  label: const Text('Cancel'),
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
                  ),
                ),
                ElevatedButton.icon(
                  onPressed: () {
                    final text = audioService.recognizedText.value.trim();
                    audioService.stopListening();
                    Get.back();
                    if (text.isNotEmpty) {
                      onSendVoiceText(text);
                    }
                  },
                  icon: const Icon(Icons.send_rounded),
                  label: const Text('Send Prompt'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
