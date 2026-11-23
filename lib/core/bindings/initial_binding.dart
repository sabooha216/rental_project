import 'package:get/get.dart';
import 'package:rental_project/core/services/storage_service.dart';
import 'package:rental_project/core/settings/settings_controller.dart';
import 'package:rental_project/features/auth/data/repositories/auth_repository_impl.dart';
import 'package:rental_project/features/auth/domain/repositories/auth_repository.dart';

/// Permanent services. Screen controllers are created by each screen's own
/// Binding. The database and the data repositories (units, tenants, contracts,
/// finance) are registered earlier, in initServices() (see app_services.dart).
class InitialBinding extends Bindings {
  @override
  void dependencies() {
    Get.put(StorageService(), permanent: true);
    Get.put(SettingsController(), permanent: true);
    Get.put<AuthRepository>(
      AuthRepositoryImpl(Get.find<StorageService>()),
      permanent: true,
    );
  }
}
