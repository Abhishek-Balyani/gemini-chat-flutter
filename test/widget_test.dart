import 'package:flutter_test/flutter_test.dart';
import 'package:ai_chatbot/data/models/chat_message_model.dart';

void main() {
  group('ChatMessageModel Unit Tests', () {
    test('ChatMessageModel serialization and deserialization works correctly', () {
      final now = DateTime.now();
      final message = ChatMessageModel(
        id: 'msg_1',
        conversationId: 'conv_1',
        content: 'Hello, AI!',
        isUser: true,
        timestamp: now,
      );

      final json = message.toJson();
      final fromJson = ChatMessageModel.fromJson(json);

      expect(fromJson.id, equals('msg_1'));
      expect(fromJson.conversationId, equals('conv_1'));
      expect(fromJson.content, equals('Hello, AI!'));
      expect(fromJson.isUser, isTrue);
      expect(fromJson.isError, isFalse);
    });

    test('ChatMessageModel copyWith creates modified instance', () {
      final now = DateTime.now();
      final original = ChatMessageModel(
        id: 'msg_1',
        conversationId: 'conv_1',
        content: 'Hello',
        isUser: true,
        timestamp: now,
      );

      final updated = original.copyWith(content: 'Hello World', isPending: true);

      expect(updated.id, equals(original.id));
      expect(updated.content, equals('Hello World'));
      expect(updated.isPending, isTrue);
    });
  });
}

