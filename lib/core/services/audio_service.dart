import 'package:flutter/foundation.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:get/get.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:speech_to_text/speech_to_text.dart';

class AudioService extends GetxService {
  final SpeechToText _speechToText = SpeechToText();
  final FlutterTts _flutterTts = FlutterTts();

  final isListening = false.obs;
  final isSttAvailable = false.obs;
  final recognizedText = ''.obs;

  final isPlayingTts = false.obs;
  final speakingMessageId = ''.obs;

  Future<AudioService> init() async {
    await _initTts();
    return this;
  }

  Future<void> _initTts() async {
    try {
      await _flutterTts.setLanguage('en-US');
      await _flutterTts.setSpeechRate(0.5);
      await _flutterTts.setVolume(1.0);
      await _flutterTts.setPitch(1.0);

      _flutterTts.setStartHandler(() {
        isPlayingTts.value = true;
      });

      _flutterTts.setCompletionHandler(() {
        isPlayingTts.value = false;
        speakingMessageId.value = '';
      });

      _flutterTts.setErrorHandler((msg) {
        isPlayingTts.value = false;
        speakingMessageId.value = '';
        if (kDebugMode) print('TTS error: $msg');
      });
    } catch (e) {
      if (kDebugMode) print('Error initializing TTS: $e');
    }
  }

  /// Request microphone permissions and start speech-to-text recording
  Future<bool> startListening({required ValueChanged<String> onResult}) async {
    final status = await Permission.microphone.request();
    if (!status.isGranted) {
      Get.snackbar(
        'Permission Denied',
        'Microphone permission is required for voice chat.',
        snackPosition: SnackPosition.TOP,
      );
      return false;
    }

    final available = await _speechToText.initialize(
      onError: (val) {
        isListening.value = false;
        if (kDebugMode) print('STT error: $val');
      },
      onStatus: (status) {
        if (status == 'done' || status == 'notListening') {
          isListening.value = false;
        }
      },
    );

    isSttAvailable.value = available;

    if (available) {
      isListening.value = true;
      recognizedText.value = '';

      await _speechToText.listen(
        onResult: (result) {
          recognizedText.value = result.recognizedWords;
          onResult(result.recognizedWords);
        },
        listenOptions: SpeechListenOptions(
          listenMode: ListenMode.dictation,
          partialResults: true,
          cancelOnError: true,
        ),
      );
      return true;
    } else {
      Get.snackbar(
        'Not Supported',
        'Speech recognition is not available on this device.',
        snackPosition: SnackPosition.TOP,
      );
      return false;
    }
  }

  /// Stop speech-to-text recording
  Future<void> stopListening() async {
    if (isListening.value) {
      await _speechToText.stop();
      isListening.value = false;
    }
  }

  /// Speak text out loud using Text-to-Speech
  Future<void> speak(String messageId, String text) async {
    if (isPlayingTts.value && speakingMessageId.value == messageId) {
      await stopTts();
      return;
    }

    await stopTts();
    if (text.trim().isNotEmpty) {
      speakingMessageId.value = messageId;
      await _flutterTts.speak(text);
    }
  }

  /// Stop Text-to-Speech playback
  Future<void> stopTts() async {
    await _flutterTts.stop();
    isPlayingTts.value = false;
    speakingMessageId.value = '';
  }

  @override
  void onClose() {
    _speechToText.cancel();
    _flutterTts.stop();
    super.onClose();
  }
}
