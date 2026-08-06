abstract class AppStrings {
  static const String appName = 'AI Chat Assistant';
  static const String splashSubtitle = 'Powered by Google Gemini AI';
  static const String newChat = 'New chat';
  static const String askAnything = 'Ask anything...';
  static const String conversations = 'Conversations';
  static const String today = 'Today';
  static const String yesterday = 'Yesterday';
  static const String previous7Days = 'Previous 7 Days';
  static const String older = 'Older';

  // Actions
  static const String rename = 'Rename';
  static const String delete = 'Delete';
  static const String cancel = 'Cancel';
  static const String save = 'Save';
  static const String copy = 'Copy';
  static const String retry = 'Retry';
  static const String clearAll = 'Clear All Chats';

  // Dialog Titles
  static const String renameChatTitle = 'Rename Conversation';
  static const String deleteChatTitle = 'Delete Conversation';
  static const String deleteChatPrompt = 'Are you sure you want to delete this chat? This action cannot be undone.';
  static const String apiKeyTitle = 'Gemini API Key';
  static const String apiKeyHint = 'Enter your Gemini API key';

  // Errors & Status
  static const String noApiKeyError = 'Gemini API Key is missing. Please set your API key in Settings.';
  static const String genericError = 'Something went wrong. Please try again.';
  static const String networkError = 'Network error. Please check your internet connection.';
  static const String messageCopied = 'Message copied to clipboard';

  // Default models
  static const String defaultModel = 'gemini-2.5-flash';
  static const List<String> availableModels = [
    'gemini-2.5-flash',
    'gemini-2.5-pro',
    'gemini-flash-latest',
  ];
}
