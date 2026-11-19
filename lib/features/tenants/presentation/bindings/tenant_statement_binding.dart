import 'package:get/get.dart';
import 'package:rental_project/features/tenants/presentation/controllers/tenant_statement_controller.dart';

class TenantStatementBinding extends Bindings {
  @override
  void dependencies() => Get.lazyPut(() => TenantStatementController());
}
