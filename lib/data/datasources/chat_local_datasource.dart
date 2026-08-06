import '../../core/services/storage_service.dart';
import '../models/conversation_model.dart';

class ChatLocalDataSource {
  final StorageService _storageService;

  ChatLocalDataSource(this._storageService);

  /// Fetch all saved conversations from GetStorage
  List<ConversationModel> getConversations() {
    final rawList = _storageService.getRawConversations();
    return rawList
        .map((item) => ConversationModel.fromJson(Map<String, dynamic>.from(item as Map)))
        .toList();
  }

  /// Save or update a list of conversations in GetStorage
  Future<void> saveConversations(List<ConversationModel> conversations) async {
    final jsonList = conversations.map((c) => c.toJson()).toList();
    await _storageService.saveRawConversations(jsonList);
  }

  /// Get active conversation ID
  String? getActiveChatId() {
    return _storageService.activeChatId;
  }

  /// Save active conversation ID
  Future<void> setActiveChatId(String? id) async {
    await _storageService.saveActiveChatId(id);
  }
}
