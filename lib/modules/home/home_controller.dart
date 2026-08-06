import 'package:get/get.dart';
import 'package:uuid/uuid.dart';
import '../../core/services/storage_service.dart';
import '../../data/datasources/chat_local_datasource.dart';
import '../../data/models/chat_message_model.dart';
import '../../data/models/conversation_model.dart';
import '../../data/repositories/chat_repository.dart';

class HomeController extends GetxController {
  late final ChatRepository _repository;
  final _uuid = const Uuid();

  final conversations = <ConversationModel>[].obs;
  final Rx<ConversationModel?> activeConversation = Rx<ConversationModel?>(null);

  @override
  void onInit() {
    super.onInit();
    final storageService = Get.find<StorageService>();
    final localDataSource = ChatLocalDataSource(storageService);
    _repository = ChatRepository(localDataSource);

    _loadConversations();
  }

  void _loadConversations() {
    final loaded = _repository.getConversations();
    conversations.assignAll(loaded);

    final savedActiveId = _repository.getActiveChatId();
    if (savedActiveId != null && conversations.any((c) => c.id == savedActiveId)) {
      activeConversation.value = conversations.firstWhere((c) => c.id == savedActiveId);
    } else if (conversations.isNotEmpty) {
      activeConversation.value = conversations.first;
    } else {
      createNewConversation();
    }
  }

  ConversationModel createNewConversation() {
    final now = DateTime.now();
    final newChat = ConversationModel(
      id: _uuid.v4(),
      title: 'New Chat',
      createdAt: now,
      updatedAt: now,
      messages: [],
    );

    conversations.insert(0, newChat);
    activeConversation.value = newChat;
    _save();
    return newChat;
  }

  void selectConversation(ConversationModel conversation) {
    activeConversation.value = conversation;
    _repository.setActiveChatId(conversation.id);
  }

  void renameConversation(String id, String newTitle) {
    final index = conversations.indexWhere((c) => c.id == id);
    if (index != -1 && newTitle.trim().isNotEmpty) {
      final updated = conversations[index].copyWith(
        title: newTitle.trim(),
        updatedAt: DateTime.now(),
      );
      conversations[index] = updated;
      if (activeConversation.value?.id == id) {
        activeConversation.value = updated;
      }
      _save();
    }
  }

  void deleteConversation(String id) {
    conversations.removeWhere((c) => c.id == id);
    if (activeConversation.value?.id == id) {
      if (conversations.isNotEmpty) {
        activeConversation.value = conversations.first;
      } else {
        createNewConversation();
      }
    }
    _save();
  }

  void updateActiveMessages(List<ChatMessageModel> messages) {
    final active = activeConversation.value;
    if (active == null) return;

    String updatedTitle = active.title;
    // Auto-generate chat title from first user message if default
    if (active.title == 'New Chat' && messages.isNotEmpty) {
      final firstUserMessage = messages.firstWhereOrNull((m) => m.isUser);
      if (firstUserMessage != null) {
        final content = firstUserMessage.content.trim();
        updatedTitle = content.length > 25 ? '${content.substring(0, 25)}...' : content;
      }
    }

    final updated = active.copyWith(
      title: updatedTitle,
      updatedAt: DateTime.now(),
      messages: messages,
    );

    final index = conversations.indexWhere((c) => c.id == active.id);
    if (index != -1) {
      conversations[index] = updated;
    }
    activeConversation.value = updated;
    _save();
  }

  void _save() {
    _repository.saveConversations(conversations);
    if (activeConversation.value != null) {
      _repository.setActiveChatId(activeConversation.value!.id);
    }
  }
}
