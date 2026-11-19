import 'package:get/get.dart';
import 'package:rental_project/features/auth/domain/repositories/auth_repository.dart';
import 'package:rental_project/features/auth/domain/usecases/continue_as_guest_use_case.dart';
import 'package:rental_project/features/auth/domain/usecases/login_use_case.dart';
import 'package:rental_project/features/auth/domain/usecases/logout_use_case.dart';
import 'package:rental_project/features/auth/domain/usecases/register_use_case.dart';
import 'package:rental_project/features/auth/presentation/controllers/auth_controller.dart';

/// Used by splash / login / register. `fenix` lets the home screen
/// (logout menu) get the controller again after these routes are gone.
class AuthBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<AuthController>(
      () {
        final repo = Get.find<AuthRepository>();
        return AuthController(
          repo: repo,
          login: LoginUseCase(repo),
          register: RegisterUseCase(repo),
          logout: LogoutUseCase(repo),
          guest: ContinueAsGuestUseCase(repo),
        );
      },
      fenix: true,
    );
  }
}
