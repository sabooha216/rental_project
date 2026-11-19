import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:rental_project/core/services/storage_service.dart';

/// App-wide settings (theme + language), persisted with GetStorage.
class SettingsController extends GetxController {
  static const _ar = Locale('ar', 'SA');
  static const _en = Locale('en', 'US');
  static const _themeKey = 'theme_mode';
  static const _langKey = 'language';

  /// Values saved from the previous run (used by main.dart at startup).
  static ThemeMode initialTheme() {
    final saved = StorageService.peek<String>(_themeKey);
    return ThemeMode.values.firstWhere(
      (m) => m.name == saved,
      orElse: () => ThemeMode.light,
    );
  }

  static Locale initialLocale() =>
      StorageService.peek<String>(_langKey) == 'en' ? _en : _ar;

  final _storage = Get.find<StorageService>();

  final themeMode = initialTheme().obs;
  final locale = initialLocale().obs;

  bool get isDark => themeMode.value == ThemeMode.dark;
  bool get isArabic => locale.value.languageCode == 'ar';

  void setTheme(ThemeMode mode) {
    themeMode.value = mode;
    Get.changeThemeMode(mode);
    _storage.write(_themeKey, mode.name);
    update(); // refresh GetBuilder listeners
  }

  void setLanguage(String code) {
    locale.value = code == 'en' ? _en : _ar;
    Get.updateLocale(locale.value);
    _storage.write(_langKey, code);
    update();
  }

  void toggleTheme() => setTheme(isDark ? ThemeMode.light : ThemeMode.dark);
  void toggleLanguage() => setLanguage(isArabic ? 'en' : 'ar');
}
