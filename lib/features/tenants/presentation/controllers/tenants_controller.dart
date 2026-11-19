import 'package:get/get.dart';
import 'package:rental_project/core/routes/app_routes.dart';
import 'package:rental_project/core/utils/dialogs.dart';
import 'package:rental_project/features/contracts/data/repositories/contracts_repository.dart';
import 'package:rental_project/features/finance/data/repositories/finance_repository.dart';
import 'package:rental_project/features/tenants/data/repositories/tenants_repository.dart';
import 'package:rental_project/features/tenants/domain/entities/tenant.dart';

class TenantsController extends GetxController {
  final repo = Get.find<TenantsRepository>();
  final contractsRepo = Get.find<ContractsRepository>();
  final financeRepo = Get.find<FinanceRepository>();

  Balance balanceOf(Tenant t) =>
      financeRepo.balanceOf(t.id, contractsRepo.contractIds(t.id));

  Future<void> addTenant() async {
    final r = await askText('new_tenant', ['name', 'phone']);
    if (r == null || r[0].isEmpty) return;
    repo.add(r[0], r[1]);
  }

  void openStatement(Tenant t) => Get.toNamed(Routes.tenantStatement, arguments: t.id);
}
