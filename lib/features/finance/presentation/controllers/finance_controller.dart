import 'dart:math';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:rental_project/core/utils/dialogs.dart';
import 'package:rental_project/core/utils/formatters.dart';
import 'package:rental_project/features/contracts/data/repositories/contracts_repository.dart';
import 'package:rental_project/features/finance/data/repositories/finance_repository.dart';
import 'package:rental_project/features/finance/domain/entities/due.dart';
import 'package:rental_project/features/finance/domain/entities/payment.dart';
import 'package:rental_project/features/finance/presentation/widgets/due_tile.dart';
import 'package:rental_project/features/tenants/data/repositories/tenants_repository.dart';
import 'package:rental_project/features/tenants/domain/entities/tenant.dart';

class FinanceController extends GetxController {
  final repo = Get.find<FinanceRepository>();
  final contractsRepo = Get.find<ContractsRepository>();
  final tenantsRepo = Get.find<TenantsRepository>();

  // payment form state
  final selTenant = Rxn<Tenant>();
  final method = PayMethod.cash.obs;
  final amountCtl = TextEditingController();

  // allocation form state
  final selPayment = Rxn<Payment>();
  final allocCtl = TextEditingController();

  String tenantNameOfDue(Due d) =>
      tenantsRepo.byId(contractsRepo.byId(d.contractId).tenantId).name;

  // ---------------- payment form ----------------
  Future<void> openPaymentForm() async {
    if (tenantsRepo.tenants.isEmpty) {
      toast('need_tenant'.tr);
      return;
    }
    selTenant.value = tenantsRepo.tenants.first;
    method.value = PayMethod.cash;
    amountCtl.clear();

    await Get.dialog(AlertDialog(
      title: Text('new_payment'.tr),
      content: SingleChildScrollView(
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          Obx(() => DropdownButtonFormField<Tenant>(
                value: selTenant.value,
                decoration: InputDecoration(labelText: 'tenant'.tr),
                items: tenantsRepo.tenants
                    .map((t) => DropdownMenuItem(value: t, child: Text(t.name)))
                    .toList(),
                onChanged: (v) => selTenant.value = v,
              )),
          Obx(() => DropdownButtonFormField<PayMethod>(
                value: method.value,
                decoration: InputDecoration(labelText: 'method'.tr),
                items: PayMethod.values
                    .map((m) => DropdownMenuItem(value: m, child: Text('m_${m.name}'.tr)))
                    .toList(),
                onChanged: (v) => method.value = v ?? PayMethod.cash,
              )),
          TextField(
            controller: amountCtl,
            decoration: InputDecoration(labelText: 'amount'.tr),
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
          ),
        ]),
      ),
      actions: [
        TextButton(onPressed: () => Get.back(), child: Text('cancel'.tr)),
        FilledButton(onPressed: _savePayment, child: Text('save'.tr)),
      ],
    ));
  }

  void _savePayment() {
    final a = double.tryParse(amountCtl.text) ?? 0;
    final t = selTenant.value;
    if (a <= 0 || t == null) return;
    repo.addPayment(t.id, a, method.value);
    Get.back();
  }

  // ---------------- allocation form ----------------
  Future<void> openAllocateForm(Due d) async {
    final remaining = repo.remainingOf(d);
    if (remaining <= 0.005) {
      toast('fully_paid'.tr);
      return;
    }
    final tenantId = contractsRepo.byId(d.contractId).tenantId;
    final usable = repo.payments
        .where((p) => p.tenantId == tenantId && repo.creditOf(p) > 0.005)
        .toList();
    if (usable.isEmpty) {
      toast('no_credit_payment'.tr);
      return;
    }
    selPayment.value = usable.first;
    allocCtl.text = money(min(repo.creditOf(usable.first), remaining));

    await Get.dialog(AlertDialog(
      title: Text('${'allocate_title'.tr} - ${dueLabel(d)}'),
      content: SingleChildScrollView(
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          Text('${'remaining'.tr}: ${money(remaining)}'),
          Obx(() => DropdownButtonFormField<Payment>(
                value: selPayment.value,
                decoration: InputDecoration(labelText: 'payment'.tr),
                items: usable
                    .map((p) => DropdownMenuItem(
                        value: p,
                        child: Text('${fmtDate(p.date)} - ${'available'.tr} ${money(repo.creditOf(p))}')))
                    .toList(),
                onChanged: (v) {
                  selPayment.value = v;
                  if (v != null) allocCtl.text = money(min(repo.creditOf(v), remaining));
                },
              )),
          TextField(
            controller: allocCtl,
            decoration: InputDecoration(labelText: 'allocated_amount'.tr),
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
          ),
        ]),
      ),
      actions: [
        TextButton(onPressed: () => Get.back(), child: Text('cancel'.tr)),
        FilledButton(onPressed: () => _saveAllocation(d), child: Text('allocate'.tr)),
      ],
    ));
  }

  void _saveAllocation(Due d) {
    final p = selPayment.value;
    final a = double.tryParse(allocCtl.text) ?? 0;
    if (p == null || a <= 0) return;
    if (a > repo.creditOf(p) + 0.001) {
      toast('over_payment'.tr);
      return;
    }
    if (a > repo.remainingOf(d) + 0.001) {
      toast('over_due'.tr);
      return;
    }
    repo.allocate(p, d, a);
    Get.back();
  }

  @override
  void onClose() {
    amountCtl.dispose();
    allocCtl.dispose();
    super.onClose();
  }
}
