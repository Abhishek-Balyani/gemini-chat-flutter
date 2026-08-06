import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:get/get.dart';
import '../../data/models/attachment_model.dart';
import '../constants/api_constants.dart';
import '../network/api_exception.dart';
import '../network/dio_client.dart';
import 'storage_service.dart';

class GeminiService extends GetxService {
  final DioClient _dioClient;
  final StorageService _storageService;

  GeminiService(this._dioClient, this._storageService);

  String get activeApiKey {
    final customKey = _storageService.apiKey;
    if (customKey != null && customKey.trim().isNotEmpty) {
      return customKey.trim();
    }
    return dotenv.env['GEMINI_API_KEY'] ?? '';
  }

  Future<String> generateContent({
    required String prompt,
    String? model,
    List<Map<String, dynamic>>? history,
    List<AttachmentModel>? attachments,
  }) async {
    final selectedModel = model ?? _storageService.selectedModel;
    final path = ApiConstants.generateContentUrl(selectedModel);

    final List<Map<String, dynamic>> contents = [];

    // Add conversation history if provided
    if (history != null && history.isNotEmpty) {
      contents.addAll(history);
    }

    // Build current prompt parts (Text + Image Base64 / Document Context)
    final List<Map<String, dynamic>> parts = [];

    StringBuffer documentContext = StringBuffer();

    if (attachments != null && attachments.isNotEmpty) {
      for (final att in attachments) {
        if (att.isImage && att.base64String != null) {
          parts.add({
            'inlineData': {
              'mimeType': att.mimeType,
              'data': att.base64String,
            }
          });
        } else if (att.isDocument && att.extractedText != null && att.extractedText!.isNotEmpty) {
          documentContext.writeln('=== Document: ${att.name} ===');
          documentContext.writeln(att.extractedText);
          documentContext.writeln('===============================\n');
        }
      }
    }

    String finalPromptText = prompt;
    if (documentContext.isNotEmpty) {
      finalPromptText = 'Context from uploaded documents:\n${documentContext.toString()}\n\nUser Question: $prompt';
    }

    parts.add({'text': finalPromptText});

    contents.add({
      'role': 'user',
      'parts': parts,
    });

    final requestBody = {
      'contents': contents,
      'systemInstruction': {
        'parts': [
          {'text': ApiConstants.defaultSystemInstruction}
        ]
      },
      'generationConfig': {
        'temperature': 0.7,
        'maxOutputTokens': 2048,
      }
    };

    try {
      final response = await _dioClient.post(
        path,
        queryParameters: {'key': activeApiKey},
        data: requestBody,
      );

      if (response.statusCode == 200 && response.data != null) {
        final data = response.data as Map<String, dynamic>;

        if (data.containsKey('candidates')) {
          final candidates = data['candidates'] as List<dynamic>;
          if (candidates.isNotEmpty) {
            final firstCandidate = candidates.first as Map<String, dynamic>;
            final contentMap = firstCandidate['content'] as Map<String, dynamic>?;
            if (contentMap != null && contentMap.containsKey('parts')) {
              final partsList = contentMap['parts'] as List<dynamic>;
              if (partsList.isNotEmpty) {
                final firstPart = partsList.first as Map<String, dynamic>;
                final text = firstPart['text'] as String?;
                if (text != null && text.isNotEmpty) {
                  return text;
                }
              }
            }
          }
        }
      }

      throw ApiException(message: 'Received empty response from Gemini AI.');
    } on ApiException {
      rethrow;
    } catch (e) {
      throw ApiException(message: 'Failed to generate response: $e');
    }
  }
}
