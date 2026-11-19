import 'package:get/get.dart';
import 'package:rental_project/features/auth/domain/repositories/auth_repository.dart';
import 'package:rental_project/features/auth/presentation/controllers/profile_controller.dart';

class ProfileBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<ProfileController>(
      () => ProfileController(Get.find<AuthRepository>()),
    );
  }
}
