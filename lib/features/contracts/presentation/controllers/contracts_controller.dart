import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:rental_project/core/utils/dialogs.dart';
import 'package:rental_project/features/contracts/data/repositories/contracts_repository.dart';
import 'package:rental_project/features/contracts/domain/entities/contract.dart';
import 'package:rental_project/features/finance/data/repositories/finance_repository.dart';
import 'package:rental_project/features/tenants/data/repositories/tenants_repository.dart';
import 'package:rental_project/features/tenants/domain/entities/tenant.dart';
import 'package:rental_project/features/units/data/repositories/units_repository.dart';
import 'package:rental_project/features/units/domain/entities/rental_unit.dart';

class ContractsController extends GetxController {
  final repo = Get.find<ContractsRepository>();
  final unitsRepo = Get.find<UnitsRepository>();
  final tenantsRepo = Get.find<TenantsRepository>();
  final financeRepo = Get.find<FinanceRepository>();

  // form state
  final selUnit = Rxn<RentalUnit>();
  final selTenant = Rxn<Tenant>();
  final plan = Plan.monthly.obs;
  final rentCtl = TextEditingController();

  Future<void> openForm() async {
    final vacant = unitsRepo.units.where((u) => repo.ofUnit(u.id) == null).toList();
    if (vacant.isEmpty || tenantsRepo.tenants.isEmpty) {
      toast('need_unit_tenant'.tr);
      return;
    }
    selUnit.value = vacant.first;
    selTenant.value = tenantsRepo.tenants.first;
    plan.value = Plan.monthly;
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

  void _save() {
    final rent = double.tryParse(rentCtl.text) ?? 0;
    final u = selUnit.value, t = selTenant.value;
    if (rent <= 0 || u == null || t == null) return;
    final c = repo.add(u.id, t.id, plan.value, rent, DateTime.now());
    financeRepo.generateDues(c);
    Get.back();
  }

  @override
  void onClose() {
    rentCtl.dispose();
    super.onClose();
  }
}
