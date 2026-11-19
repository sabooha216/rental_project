import 'package:get/get.dart';
import 'package:rental_project/features/contracts/data/repositories/contracts_repository.dart';
import 'package:rental_project/features/finance/data/repositories/finance_repository.dart';
import 'package:rental_project/features/finance/domain/entities/due.dart';
import 'package:rental_project/features/finance/domain/entities/payment.dart';
import 'package:rental_project/features/tenants/data/repositories/tenants_repository.dart';
import 'package:rental_project/features/tenants/domain/entities/tenant.dart';

class TenantStatementController extends GetxController {
  final int tenantId = Get.arguments as int;
  final tenantsRepo = Get.find<TenantsRepository>();
  final contractsRepo = Get.find<ContractsRepository>();
  final financeRepo = Get.find<FinanceRepository>();

  Tenant get tenant => tenantsRepo.byId(tenantId);
  Set<int> get _contractIds => contractsRepo.contractIds(tenantId);

  List<Due> get dues =>
      financeRepo.dues.where((d) => _contractIds.contains(d.contractId)).toList();
  List<Payment> get payments =>
      financeRepo.payments.where((p) => p.tenantId == tenantId).toList();
  Balance get balance => financeRepo.balanceOf(tenantId, _contractIds);
}
