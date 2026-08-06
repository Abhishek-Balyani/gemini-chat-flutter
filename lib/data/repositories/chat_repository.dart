import '../datasources/chat_local_datasource.dart';
import '../models/conversation_model.dart';

class ChatRepository {
  final ChatLocalDataSource _localDataSource;

  ChatRepository(this._localDataSource);

  List<ConversationModel> getConversations() {
    return _localDataSource.getConversations();
  }

  Future<void> saveConversations(List<ConversationModel> conversations) async {
    await _localDataSource.saveConversations(conversations);
  }

  String? getActiveChatId() {
    return _localDataSource.getActiveChatId();
  }

  Future<void> setActiveChatId(String? id) async {
    await _localDataSource.setActiveChatId(id);
  }
}
