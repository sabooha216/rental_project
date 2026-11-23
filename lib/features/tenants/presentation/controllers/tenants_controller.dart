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

  final query = ''.obs;
  final filter = 0.obs; // 0 all | 1 has debt

  Balance balanceOf(Tenant t) =>
      financeRepo.balanceOf(t.id, contractsRepo.contractIds(t.id));

  List<Tenant> get filtered {
    final q = query.value.trim().toLowerCase();
    return repo.tenants.where((t) {
      if (filter.value == 1 && balanceOf(t).debt <= 0.005) return false;
      return q.isEmpty || t.name.toLowerCase().contains(q) || t.phone.contains(q);
    }).toList();
  }

  Future<void> addTenant() async {
    final r = await askText('new_tenant', ['name', 'phone', 'national_id']);
    if (r == null || r[0].isEmpty) return;
    await repo.add(r[0], r[1], nationalId: r[2]);
  }

  Future<void> editTenant(Tenant t) async {
    final r = await askText('edit_tenant', ['name', 'phone', 'national_id'],
        initial: [t.name, t.phone, t.nationalId ?? '']);
    if (r == null || r[0].isEmpty) return;
    await repo.update(t.id, r[0], r[1], nationalId: r[2]);
  }

  Future<void> deleteTenant(Tenant t) async {
    final hasContracts = contractsRepo.contracts.any((c) => c.tenantId == t.id);
    final hasPayments = financeRepo.payments.any((p) => p.tenantId == t.id);
    if (hasContracts || hasPayments) {
      toast('tenant_has_history'.tr);
      return;
    }
    if (!await confirm('delete_tenant_confirm'.tr)) return;
    await repo.softDelete(t.id);
  }

  void openStatement(Tenant t) => Get.toNamed(Routes.tenantStatement, arguments: t.id);
}
