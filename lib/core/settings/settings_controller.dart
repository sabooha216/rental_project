import 'package:flutter/material.dart';
import 'package:get/get.dart';

/// App-wide settings: theme mode and language. Lives for the whole app.
class SettingsController extends GetxController {
  static const _ar = Locale('ar', 'SA');
  static const _en = Locale('en', 'US');

  final themeMode = ThemeMode.light.obs;
  final locale = _ar.obs;

  bool get isDark => themeMode.value == ThemeMode.dark;
  bool get isArabic => locale.value.languageCode == 'ar';

  void toggleTheme() {
    themeMode.value = isDark ? ThemeMode.light : ThemeMode.dark;
    Get.changeThemeMode(themeMode.value);
  }

  void toggleLanguage() {
    locale.value = isArabic ? _en : _ar;
    Get.updateLocale(locale.value);
  }
}
