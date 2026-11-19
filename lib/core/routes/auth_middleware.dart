import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:rental_project/features/auth/auth_routes.dart';
import 'package:rental_project/features/auth/domain/repositories/auth_repository.dart';

/// Sends the user to the login screen when there is no session
/// (neither a signed-in account nor guest mode).
class AuthMiddleware extends GetMiddleware {
  @override
  RouteSettings? redirect(String? route) {
    final ok = Get.isRegistered<AuthRepository>() &&
        Get.find<AuthRepository>().hasSession;
    return ok ? null : const RouteSettings(name: AuthRoutes.login);
  }
}
