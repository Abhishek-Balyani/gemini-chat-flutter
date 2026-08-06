abstract class ApiConstants {
  static const String baseUrl = 'https://generativelanguage.googleapis.com';
  static const String apiVersion = 'v1beta';

  // Endpoint path generator
  static String generateContentUrl(String model) {
    return '/$apiVersion/models/$model:generateContent';
  }

  static const int connectTimeout = 30000; // 30s
  static const int receiveTimeout = 60000; // 60s

  // Default system instruction to guide Gemini API response formatting
  static const String defaultSystemInstruction =
      'You are a helpful, accurate, and concise AI Chat Assistant. Format your responses using clean Markdown. When writing code, provide explicit programming language code blocks with proper formatting.';
}
