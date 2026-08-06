import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'storage_service.dart';

class ThemeService extends GetxService {
  final StorageService _storageService;

  ThemeService(this._storageService);

  final Rx<ThemeMode> _themeMode = ThemeMode.dark.obs;
  final RxString themeModeString = 'dark'.obs;
  final RxDouble fontSizeScale = 1.0.obs;

  ThemeMode get themeMode => _themeMode.value;
  bool get isDarkMode {
    if (_themeMode.value == ThemeMode.system) {
      return Get.isPlatformDarkMode;
    }
    return _themeMode.value == ThemeMode.dark;
  }

  @override
  void onInit() {
    super.onInit();
    final savedMode = _storageService.themeModeStr;
    themeModeString.value = savedMode;
    _themeMode.value = _parseThemeMode(savedMode);
    fontSizeScale.value = _storageService.fontSizeScale;
  }

  ThemeMode _parseThemeMode(String mode) {
    switch (mode) {
      case 'light':
        return ThemeMode.light;
      case 'system':
        return ThemeMode.system;
      case 'dark':
      default:
        return ThemeMode.dark;
    }
  }

  void setThemeModeString(String mode) {
    themeModeString.value = mode;
    final tm = _parseThemeMode(mode);
    _themeMode.value = tm;
    _storageService.saveThemeModeStr(mode);
    Get.changeThemeMode(tm);
  }

  void toggleTheme() {
    if (isDarkMode) {
      setThemeModeString('light');
    } else {
      setThemeModeString('dark');
    }
  }

  void setFontSizeScale(double scale) {
    fontSizeScale.value = scale;
    _storageService.saveFontSizeScale(scale);
  }
}
