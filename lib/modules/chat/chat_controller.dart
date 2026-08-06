import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:uuid/uuid.dart';
import '../../core/constants/app_strings.dart';
import '../../core/network/api_exception.dart';
import '../../core/services/document_parser_service.dart';
import '../../core/services/gemini_service.dart';
import '../../data/models/attachment_model.dart';
import '../../data/models/chat_message_model.dart';
import '../home/home_controller.dart';

class ChatController extends GetxController {
  final GeminiService _geminiService = Get.find<GeminiService>();
  final HomeController _homeController = Get.find<HomeController>();
  final DocumentParserService _parserService = Get.find<DocumentParserService>();

  final messages = <ChatMessageModel>[].obs;
  final pendingAttachments = <AttachmentModel>[].obs;
  final isTyping = false.obs;
  final selectedModel = AppStrings.defaultModel.obs;

  late final TextEditingController textEditingController;
  late final ScrollController scrollController;
  late final FocusNode focusNode;

  final _uuid = const Uuid();

  @override
  void onInit() {
    super.onInit();
    textEditingController = TextEditingController();
    scrollController = ScrollController();
    focusNode = FocusNode();

    ever(_homeController.activeConversation, (activeChat) {
      if (activeChat != null) {
        messages.assignAll(activeChat.messages);
        _scrollToBottom();
      } else {
        messages.clear();
      }
    });

    if (_homeController.activeConversation.value != null) {
      messages.assignAll(_homeController.activeConversation.value!.messages);
    }
  }

  /// Pick File (Image, PDF, DOCX, TXT) using FilePicker
  Future<void> pickAttachment() async {
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['pdf', 'doc', 'docx', 'txt', 'png', 'jpg', 'jpeg', 'webp'],
        withData: true,
      );

      if (result != null && result.files.isNotEmpty) {
        for (final file in result.files) {
          final ext = file.extension?.toLowerCase() ?? '';
          AttachmentType type;
          String mimeType;

          if (['png', 'jpg', 'jpeg', 'webp'].contains(ext)) {
            type = AttachmentType.image;
            mimeType = 'image/${ext == 'jpg' ? 'jpeg' : ext}';
          } else if (ext == 'pdf') {
            type = AttachmentType.pdf;
            mimeType = 'application/pdf';
          } else if (['doc', 'docx'].contains(ext)) {
            type = AttachmentType.doc;
            mimeType = 'application/msword';
          } else {
            type = AttachmentType.text;
            mimeType = 'text/plain';
          }

          var att = AttachmentModel(
            id: _uuid.v4(),
            name: file.name,
            path: file.path,
            bytes: file.bytes,
            mimeType: mimeType,
            fileType: type,
            size: file.size,
          );

          if (att.isDocument) {
            final text = await _parserService.extractText(att);
            att = AttachmentModel(
              id: att.id,
              name: att.name,
              path: att.path,
              bytes: att.bytes,
              mimeType: att.mimeType,
              fileType: att.fileType,
              size: att.size,
              extractedText: text,
            );
          }

          pendingAttachments.add(att);
        }
      }
    } catch (e) {
      Get.snackbar(
        'File Selection Error',
        'Unable to select file: $e',
        snackPosition: SnackPosition.TOP,
      );
    }
  }

  void removePendingAttachment(AttachmentModel att) {
    pendingAttachments.removeWhere((item) => item.id == att.id);
  }

  /// Send user message with attachments to Gemini API
  Future<void> sendMessage(String text) async {
    final prompt = text.trim();
    if (prompt.isEmpty && pendingAttachments.isEmpty) return;
    if (isTyping.value) return;

    final activeChat = _homeController.activeConversation.value;
    final conversationId = activeChat?.id ?? 'default';

    final attachedList = List<AttachmentModel>.from(pendingAttachments);
    pendingAttachments.clear();

    final userMsg = ChatMessageModel(
      id: _uuid.v4(),
      conversationId: conversationId,
      content: prompt.isEmpty ? (attachedList.first.isImage ? 'Analyze this image' : 'Summarize this document') : prompt,
      isUser: true,
      timestamp: DateTime.now(),
      attachments: attachedList.isEmpty ? null : attachedList,
    );

    messages.add(userMsg);
    _syncWithHome();
    _scrollToBottom();

    isTyping.value = true;
    _scrollToBottom();

    try {
      final List<Map<String, dynamic>> history = [];
      for (final msg in messages) {
        if (msg.id == userMsg.id) break;
        if (!msg.isError && msg.content.isNotEmpty) {
          history.add({
            'role': msg.isUser ? 'user' : 'model',
            'parts': [
              {'text': msg.content}
            ]
          });
        }
      }

      final aiTextResponse = await _geminiService.generateContent(
        prompt: userMsg.content,
        model: selectedModel.value,
        history: history.isEmpty ? null : history,
        attachments: attachedList,
      );

      final aiMsg = ChatMessageModel(
        id: _uuid.v4(),
        conversationId: conversationId,
        content: aiTextResponse,
        isUser: false,
        timestamp: DateTime.now(),
      );

      messages.add(aiMsg);
      _syncWithHome();
    } on ApiException catch (e) {
      _addErrorBubble(e.message, conversationId);
    } catch (e) {
      _addErrorBubble('An unexpected error occurred: $e', conversationId);
    } finally {
      isTyping.value = false;
      _scrollToBottom();
    }
  }

  void _addErrorBubble(String errorText, String conversationId) {
    final errorMsg = ChatMessageModel(
      id: _uuid.v4(),
      conversationId: conversationId,
      content: errorText,
      isUser: false,
      timestamp: DateTime.now(),
      isError: true,
    );
    messages.add(errorMsg);
    _syncWithHome();
  }

  void regenerateLastResponse() {
    if (messages.isEmpty || isTyping.value) return;

    final lastUserMsgIndex = messages.lastIndexWhere((m) => m.isUser);
    if (lastUserMsgIndex != -1) {
      final lastUserMsg = messages[lastUserMsgIndex];
      while (messages.length > lastUserMsgIndex + 1) {
        messages.removeLast();
      }
      messages.removeAt(lastUserMsgIndex);
      _syncWithHome();
      pendingAttachments.assignAll(lastUserMsg.attachments ?? []);
      sendMessage(lastUserMsg.content);
    }
  }

  void retryLastMessage(ChatMessageModel errorMessage) {
    final errorIndex = messages.indexOf(errorMessage);
    if (errorIndex > 0) {
      final lastUserMsg = messages[errorIndex - 1];
      if (lastUserMsg.isUser) {
        messages.removeAt(errorIndex);
        _syncWithHome();
        pendingAttachments.assignAll(lastUserMsg.attachments ?? []);
        sendMessage(lastUserMsg.content);
      }
    }
  }

  void deleteMessage(String id) {
    messages.removeWhere((msg) => msg.id == id);
    _syncWithHome();
  }

  void clearChat() {
    messages.clear();
    pendingAttachments.clear();
    _syncWithHome();
  }

  void _syncWithHome() {
    _homeController.updateActiveMessages(List.from(messages));
  }

  void _scrollToBottom() {
    Future.delayed(const Duration(milliseconds: 100), () {
      if (scrollController.hasClients) {
        scrollController.animateTo(
          scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  @override
  void onClose() {
    textEditingController.dispose();
    scrollController.dispose();
    focusNode.dispose();
    super.onClose();
  }
}
