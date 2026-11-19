import 'package:get/get.dart';
import 'package:rental_project/features/tenants/presentation/controllers/tenants_controller.dart';

class TenantsBinding extends Bindings {
  @override
  void dependencies() => Get.lazyPut(() => TenantsController());
}
