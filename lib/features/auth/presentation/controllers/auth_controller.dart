import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:rental_project/core/routes/app_routes.dart';
import 'package:rental_project/features/auth/auth_routes.dart';
import 'package:rental_project/features/auth/data/models/app_user.dart';
import 'package:rental_project/features/auth/data/repositories/auth_repository.dart';

class AuthController extends GetxController {
  final repo = Get.find<AuthRepository>();
  final loading = false.obs;

  bool get isGuest => repo.current.value == null;
  String get displayName => repo.current.value?.name ?? 'guest'.tr;

  /// Converts Arabic-Indic digits to latin and strips spaces, dashes and '+'.
  static String normalizePhone(String raw) {
    const arabic = '٠١٢٣٤٥٦٧٨٩';
    final b = StringBuffer();
    for (final c in raw.split('')) {
      final i = arabic.indexOf(c);
      b.write(i >= 0 ? '$i' : c);
    }
    return b.toString().replaceAll(RegExp(r'[\s\-+]'), '');
  }

  Future<void> register({
    required String name,
    required String phone,
    required String password,
    required UserRole role,
  }) async {
    loading.value = true;
    await Future.delayed(const Duration(milliseconds: 500));
    loading.value = false;

    final p = normalizePhone(phone);
    if (repo.findByPhone(p) != null) {
      _toast('phone_exists'.tr, error: true);
      return;
    }
    repo.current.value =
        repo.add(name: name.trim(), phone: p, password: password, role: role);
    Get.offAllNamed(Routes.home);
    _toast('account_created'.tr);
  }

  Future<void> login({required String phone, required String password}) async {
    loading.value = true;
    await Future.delayed(const Duration(milliseconds: 500));
    loading.value = false;

    final user = repo.findByPhone(normalizePhone(phone));
    if (user == null || user.password != password) {
      _toast('wrong_credentials'.tr, error: true);
      return;
    }
    repo.current.value = user;
    Get.offAllNamed(Routes.home);
    _toast('welcome_user'.trParams({'name': user.name}));
  }

  void continueAsGuest() {
    repo.current.value = null;
    Get.offAllNamed(Routes.home);
  }

  void logout() {
    repo.current.value = null;
    Get.offAllNamed(AuthRoutes.login);
  }

  void _toast(String msg, {bool error = false}) {
    final cs = Get.theme.colorScheme;
    Get.snackbar(
      '',
      msg,
      titleText: const SizedBox.shrink(),
      snackPosition: SnackPosition.BOTTOM,
      margin: const EdgeInsets.all(16),
      borderRadius: 14,
      backgroundColor: error ? cs.errorContainer : cs.primaryContainer,
      colorText: error ? cs.onErrorContainer : cs.onPrimaryContainer,
      duration: const Duration(seconds: 3),
    );
  }
}
