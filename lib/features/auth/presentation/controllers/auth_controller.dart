import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:rental_project/core/routes/app_routes.dart';
import 'package:rental_project/features/auth/auth_routes.dart';
import 'package:rental_project/features/auth/domain/entities/app_user.dart';
import 'package:rental_project/features/auth/domain/failures/auth_exception.dart';
import 'package:rental_project/features/auth/domain/repositories/auth_repository.dart';
import 'package:rental_project/features/auth/domain/usecases/continue_as_guest_use_case.dart';
import 'package:rental_project/features/auth/domain/usecases/login_use_case.dart';
import 'package:rental_project/features/auth/domain/usecases/logout_use_case.dart';
import 'package:rental_project/features/auth/domain/usecases/register_use_case.dart';

class AuthController extends GetxController {
  AuthController({
    required AuthRepository repo,
    required LoginUseCase login,
    required RegisterUseCase register,
    required LogoutUseCase logout,
    required ContinueAsGuestUseCase guest,
  })  : _repo = repo,
        _login = login,
        _register = register,
        _logout = logout,
        _guest = guest;

  final AuthRepository _repo;
  final LoginUseCase _login;
  final RegisterUseCase _register;
  final LogoutUseCase _logout;
  final ContinueAsGuestUseCase _guest;

  final user = Rxn<AppUser>();
  final loading = false.obs;

  @override
  void onInit() {
    super.onInit();
    user.value = _repo.currentUser;
  }

  String get displayName => user.value?.name ?? 'guest'.tr;

  Future<void> register({
    required String name,
    required String phone,
    required String password,
    required UserRole role,
  }) =>
      _run(() async {
        user.value = await _register(
            name: name, phone: phone, password: password, role: role);
        loading.value = false;
        Get.offAllNamed(Routes.home);
        _toast('account_created'.tr);
      });

  Future<void> login({required String phone, required String password}) =>
      _run(() async {
        final u = await _login(phone: phone, password: password);
        user.value = u;
        loading.value = false;
        Get.offAllNamed(Routes.home);
        _toast('welcome_user'.trParams({'name': u.name}));
      });

  Future<void> continueAsGuest() async {
    await _guest();
    user.value = null;
    Get.offAllNamed(Routes.home);
  }

  Future<void> logout() async {
    await _logout();
    user.value = null;
    Get.offAllNamed(AuthRoutes.login);
  }

  Future<void> _run(Future<void> Function() action) async {
    loading.value = true;
    try {
      await Future.delayed(const Duration(milliseconds: 500));
      await action();
    } on AuthException catch (e) {
      _toast(
        e.type == AuthFailure.phoneExists
            ? 'phone_exists'.tr
            : 'wrong_credentials'.tr,
        error: true,
      );
    } finally {
      if (!isClosed) loading.value = false;
    }
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
