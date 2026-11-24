import 'package:get/get.dart';
import 'package:rental_project/features/contracts/data/repositories/contracts_repository.dart';
import 'package:rental_project/features/contracts/domain/entities/contract.dart';
import 'package:rental_project/features/contracts/presentation/controllers/contracts_controller.dart';
import 'package:rental_project/features/finance/data/repositories/finance_repository.dart';
import 'package:rental_project/features/finance/domain/entities/due.dart';
import 'package:rental_project/features/finance/domain/entities/payment.dart';
import 'package:rental_project/features/finance/presentation/controllers/finance_controller.dart';
import 'package:rental_project/features/tenants/data/repositories/tenants_repository.dart';
import 'package:rental_project/features/tenants/domain/entities/tenant.dart';
import 'package:rental_project/features/tenants/presentation/controllers/tenants_controller.dart';
import 'package:rental_project/features/units/data/repositories/units_repository.dart';
import 'package:rental_project/features/units/presentation/controllers/units_controller.dart';

/// All numbers are computed from the repositories (nothing stored).
class DashboardController extends GetxController {
  final unitsRepo = Get.find<UnitsRepository>();
  final tenantsRepo = Get.find<TenantsRepository>();
  final contractsRepo = Get.find<ContractsRepository>();
  final finance = Get.find<FinanceRepository>();

  // ---- quick actions (reuse the forms of each feature) ----
  void addPayment() => Get.find<FinanceController>().openPaymentForm();
  void addContract() => Get.find<ContractsController>().openForm();
  void addTenant() => Get.find<TenantsController>().addTenant();
  void addUnit() => Get.find<UnitsController>().addUnit();

  // ---- numbers ----
  List<Due> get _overdue => finance.dues.where((d) {
        final s = finance.statusOf(d);
        return s == DueStatus.overdue || s == DueStatus.partialOverdue;
      }).toList();

  double get overdueTotal => _overdue.fold(0.0, (s, d) => s + finance.remainingOf(d));
  int get overdueCount => _overdue.length;

  double get collectedThisMonth {
    final n = DateTime.now();
    return finance.payments
        .where((p) => !p.voided && p.date.year == n.year && p.date.month == n.month)
        .fold(0.0, (s, p) => s + p.amount);
  }

  double get dueNext7Days {
    final now = DateTime.now();
    final limit = now.add(const Duration(days: 7));
    return finance.dues
        .where((d) => d.date.isAfter(now) && d.date.isBefore(limit))
        .fold(0.0, (s, d) => s + finance.remainingOf(d));
  }

  int get totalUnits => unitsRepo.units.length;
  int get rentedUnits =>
      unitsRepo.units.where((u) => contractsRepo.ofUnit(u.id) != null).length;
  double get occupancy => totalUnits == 0 ? 0 : rentedUnits / totalUnits * 100;

  List<Contract> get expiringSoon {
    final list = contractsRepo.contracts
        .where((c) => c.isActive && c.daysLeft >= 0 && c.daysLeft <= 90)
        .toList()
      ..sort((a, b) => a.endDate.compareTo(b.endDate));
    return list.take(5).toList();
  }

  List<({Tenant tenant, double amount})> get topDebtors {
    final byTenant = <int, double>{};
    for (final d in _overdue) {
      final tid = contractsRepo.byId(d.contractId).tenantId;
      byTenant[tid] = (byTenant[tid] ?? 0) + finance.remainingOf(d);
    }
    final list = byTenant.entries
        .map((e) => (tenant: tenantsRepo.byId(e.key), amount: e.value))
        .toList()
      ..sort((a, b) => b.amount.compareTo(a.amount));
    return list.take(5).toList();
  }

  List<Payment> get recentPayments {
    final list = finance.payments.where((p) => !p.voided).toList()
      ..sort((a, b) => b.date.compareTo(a.date));
    return list.take(5).toList();
  }
}
