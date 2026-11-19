import 'package:get/get.dart';
import 'package:rental_project/core/services/storage_service.dart';
import 'package:rental_project/core/settings/settings_controller.dart';
import 'package:rental_project/features/auth/data/repositories/auth_repository_impl.dart';
import 'package:rental_project/features/auth/domain/repositories/auth_repository.dart';
import 'package:rental_project/features/contracts/data/repositories/contracts_repository.dart';
import 'package:rental_project/features/finance/data/repositories/finance_repository.dart';
import 'package:rental_project/features/tenants/data/repositories/tenants_repository.dart';
import 'package:rental_project/features/units/data/repositories/units_repository.dart';

/// Permanent services + repositories. Screen controllers are created by
/// each screen's own Binding.
class InitialBinding extends Bindings {
  @override
  void dependencies() {
    Get.put(StorageService(), permanent: true);
    Get.put(SettingsController(), permanent: true);
    Get.put<AuthRepository>(
      AuthRepositoryImpl(Get.find<StorageService>()),
      permanent: true,
    );
    Get.put(UnitsRepository(), permanent: true);
    Get.put(TenantsRepository(), permanent: true);
    Get.put(ContractsRepository(), permanent: true);
    Get.put(FinanceRepository(), permanent: true);
  }
}
