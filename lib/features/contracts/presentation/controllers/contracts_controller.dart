import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:rental_project/core/database/app_database.dart';
import 'package:rental_project/core/utils/dialogs.dart';
import 'package:rental_project/core/utils/formatters.dart';
import 'package:rental_project/features/contracts/data/repositories/contracts_repository.dart';
import 'package:rental_project/features/contracts/domain/entities/contract.dart';
import 'package:rental_project/features/finance/data/repositories/finance_repository.dart';
import 'package:rental_project/features/tenants/data/repositories/tenants_repository.dart';
import 'package:rental_project/features/tenants/domain/entities/tenant.dart';
import 'package:rental_project/features/units/data/repositories/units_repository.dart';
import 'package:rental_project/features/units/domain/entities/rental_unit.dart';

class ContractsController extends GetxController {
  final db = Get.find<AppDatabase>();
  final repo = Get.find<ContractsRepository>();
  final unitsRepo = Get.find<UnitsRepository>();
  final tenantsRepo = Get.find<TenantsRepository>();
  final financeRepo = Get.find<FinanceRepository>();

  // list state
  final query = ''.obs;
  final filter = 0.obs; // 0 all | 1 active | 2 ended

  // new-contract form state
  final selUnit = Rxn<RentalUnit>();
  final selTenant = Rxn<Tenant>();
  final plan = Plan.monthly.obs;
  final selStart = DateTime.now().obs;
  final rentCtl = TextEditingController();

  List<Contract> get filtered {
    final q = query.value.trim().toLowerCase();
    return repo.contracts
        .where((c) {
          final okFilter = filter.value == 0 ||
              (filter.value == 1 && c.isActive) ||
              (filter.value == 2 && !c.isActive);
          if (!okFilter) return false;
          if (q.isEmpty) return true;
          return unitsRepo.byId(c.unitId).name.toLowerCase().contains(q) ||
              tenantsRepo.byId(c.tenantId).name.toLowerCase().contains(q);
        })
        .toList()
        .reversed
        .toList();
  }

  String statusLabel(Contract c) {
    if (c.isActive && c.endDate.isBefore(DateTime.now())) return 'cs_ended'.tr;
    return 'cs_${c.status.name}'.tr;
  }

  // ---------------- new contract ----------------
  Future<void> openForm() async {
    final vacant = unitsRepo.units.where((u) => repo.ofUnit(u.id) == null).toList();
    if (vacant.isEmpty || tenantsRepo.tenants.isEmpty) {
      toast('need_unit_tenant'.tr);
      return;
    }
    selUnit.value = vacant.first;
    selTenant.value = tenantsRepo.tenants.first;
    plan.value = Plan.monthly;
    selStart.value = DateTime.now();
    rentCtl.text = vacant.first.rent.toString();

    await Get.dialog(AlertDialog(
      title: Text('new_contract'.tr),
      content: SingleChildScrollView(
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          Obx(() => DropdownButtonFormField<RentalUnit>(
                value: selUnit.value,
                decoration: InputDecoration(labelText: 'unit'.tr),
                items: vacant.map((u) => DropdownMenuItem(value: u, child: Text(u.name))).toList(),
                onChanged: (v) {
                  selUnit.value = v;
                  if (v != null) rentCtl.text = v.rent.toString();
                },
              )),
          Obx(() => DropdownButtonFormField<Tenant>(
                value: selTenant.value,
                decoration: InputDecoration(labelText: 'tenant'.tr),
                items: tenantsRepo.tenants
                    .map((t) => DropdownMenuItem(value: t, child: Text(t.name)))
                    .toList(),
                onChanged: (v) => selTenant.value = v,
              )),
          Obx(() => DropdownButtonFormField<Plan>(
                value: plan.value,
                decoration: InputDecoration(labelText: 'plan'.tr),
                items: Plan.values
                    .map((p) => DropdownMenuItem(value: p, child: Text('plan_${p.name}'.tr)))
                    .toList(),
                onChanged: (v) => plan.value = v ?? Plan.monthly,
              )),
          Obx(() => ListTile(
                contentPadding: EdgeInsets.zero,
                title: Text('start_date'.tr),
                subtitle: Text(fmtDate(selStart.value)),
                trailing: const Icon(Icons.calendar_today),
                onTap: () async {
                  final d = await showDatePicker(
                    context: Get.context!,
                    initialDate: selStart.value,
                    firstDate: DateTime(2000),
                    lastDate: DateTime(2100),
                  );
                  if (d != null) selStart.value = d;
                },
              )),
          TextField(
            controller: rentCtl,
            decoration: InputDecoration(labelText: 'annual_rent'.tr),
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
          ),
        ]),
      ),
      actions: [
        TextButton(onPressed: () => Get.back(), child: Text('cancel'.tr)),
        FilledButton(onPressed: _save, child: Text('create_contract'.tr)),
      ],
    ));
  }

  Future<void> _save() async {
    final rent = double.tryParse(rentCtl.text) ?? 0;
    final u = selUnit.value, t = selTenant.value;
    if (rent <= 0 || u == null || t == null) return;
    try {
      // contract + its dues are saved together, or not at all
      await db.transaction(() async {
        final c = await repo.insert(u.id, t.id, plan.value, rent, selStart.value);
        await financeRepo.insertDues(c);
      });
      await repo.load();
      await financeRepo.load();
      Get.back();
    } catch (_) {
      toast('save_error'.tr);
    }
  }

  // ---------------- terminate ----------------
  Future<void> terminate(Contract c) async {
    final r = await askText('terminate_contract', ['termination_reason']);
    if (r == null) return;
    if (r[0].isEmpty) {
      toast('reason_required'.tr);
      return;
    }
    if (!await confirm('terminate_confirm'.tr)) return;
    try {
      await db.transaction(() async {
        await repo.setStatus(c.id, ContractStatus.terminated, reason: r[0]);
        await financeRepo.cancelFutureDues(c.id, DateTime.now());
      });
      await repo.load();
      await financeRepo.load();
    } catch (_) {
      toast('save_error'.tr);
    }
  }

  // ---------------- renew ----------------
  Future<void> renew(Contract c) async {
    final r = await askText('renew_contract', ['annual_rent'],
        numeric: [true], initial: [c.annualRent.toString()]);
    if (r == null) return;
    final rent = double.tryParse(r[0]) ?? 0;
    if (rent <= 0) return;
    final newStart = DateTime(c.endDate.year, c.endDate.month, c.endDate.day + 1);
    try {
      await db.transaction(() async {
        await repo.setStatus(c.id, ContractStatus.expired);
        final n =
            await repo.insert(c.unitId, c.tenantId, c.plan, rent, newStart, renewedFromId: c.id);
        await financeRepo.insertDues(n);
      });
      await repo.load();
      await financeRepo.load();
    } catch (_) {
      toast('save_error'.tr);
    }
  }

  @override
  void onClose() {
    rentCtl.dispose();
    super.onClose();
  }
}
