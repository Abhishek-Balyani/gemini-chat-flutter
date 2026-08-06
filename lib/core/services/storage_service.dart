import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import '../constants/app_strings.dart';

class StorageService extends GetxService {
  late final GetStorage _box;

  static const String _keyApiKey = 'gemini_api_key';
  static const String _keyThemeModeStr = 'theme_mode_str';
  static const String _keyFontSizeScale = 'font_size_scale';
  static const String _keySelectedModel = 'selected_model';
  static const String _keyConversations = 'conversations_v1';
  static const String _keyActiveChatId = 'active_chat_id';

  Future<StorageService> init() async {
    await GetStorage.init();
    _box = GetStorage();
    return this;
  }

  // Gemini API Key
  String? get apiKey => _box.read<String>(_keyApiKey);
  Future<void> saveApiKey(String key) async => await _box.write(_keyApiKey, key.trim());
  Future<void> removeApiKey() async => await _box.remove(_keyApiKey);

  // Theme Mode String ('dark', 'light', 'system')
  String get themeModeStr => _box.read<String>(_keyThemeModeStr) ?? 'dark';
  Future<void> saveThemeModeStr(String mode) async => await _box.write(_keyThemeModeStr, mode);

  // Font Size Scale (0.85, 1.0, 1.15)
  double get fontSizeScale => _box.read<double>(_keyFontSizeScale) ?? 1.0;
  Future<void> saveFontSizeScale(double scale) async => await _box.write(_keyFontSizeScale, scale);

  // Selected AI Model
  String get selectedModel => _box.read<String>(_keySelectedModel) ?? AppStrings.defaultModel;
  Future<void> saveSelectedModel(String model) async => await _box.write(_keySelectedModel, model);

  // Active Conversation ID
  String? get activeChatId => _box.read<String>(_keyActiveChatId);
  Future<void> saveActiveChatId(String? id) async {
    if (id == null) {
      await _box.remove(_keyActiveChatId);
    } else {
      await _box.write(_keyActiveChatId, id);
    }
  }

  // Conversations Data Persistence
  List<dynamic> getRawConversations() {
    final data = _box.read<List<dynamic>>(_keyConversations);
    return data ?? [];
  }

  Future<void> saveRawConversations(List<dynamic> conversationsJson) async {
    await _box.write(_keyConversations, conversationsJson);
  }

  // Clear All Storage Data
  Future<void> clearAll() async {
    await _box.erase();
  }
}
