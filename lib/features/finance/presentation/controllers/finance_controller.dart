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

  // dues list state
  final search = ''.obs;
  final statusFilter = 0.obs; // 0 all | 1 overdue | 2 open | 3 paid

  // payment form state
  final selTenant = Rxn<Tenant>();
  final method = PayMethod.cash.obs;
  final amountCtl = TextEditingController();

  // allocation form state
  final selPayment = Rxn<Payment>();
  final allocCtl = TextEditingController();

  String tenantNameOfDue(Due d) =>
      tenantsRepo.byId(contractsRepo.byId(d.contractId).tenantId).name;

  List<Due> get filteredDues {
    final q = search.value.trim().toLowerCase();
    return repo.dues.where((d) {
      final st = repo.statusOf(d);
      final ok = switch (statusFilter.value) {
        1 => st == DueStatus.overdue || st == DueStatus.partialOverdue,
        2 => st == DueStatus.unpaid || st == DueStatus.partial,
        3 => st == DueStatus.paid,
        _ => true,
      };
      if (!ok) return false;
      if (q.isEmpty) return true;
      return tenantNameOfDue(d).toLowerCase().contains(q) ||
          dueLabel(d).toLowerCase().contains(q);
    }).toList();
  }

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

  Future<void> _savePayment() async {
    final a = double.tryParse(amountCtl.text) ?? 0;
    final t = selTenant.value;
    if (a <= 0 || t == null) return;
    try {
      await repo.addPayment(t.id, a, method.value);
      Get.back();
    } catch (_) {
      toast('save_error'.tr);
    }
  }

  // ---------------- void payment ----------------
  Future<void> voidPayment(Payment p) async {
    final r = await askText('void_payment', ['void_reason']);
    if (r == null) return;
    if (r[0].isEmpty) {
      toast('reason_required'.tr);
      return;
    }
    try {
      await repo.voidPayment(p, r[0]);
    } catch (_) {
      toast('save_error'.tr);
    }
  }

  // ---------------- due details (allocations list + reverse) ----------------
  Future<void> openDueDetails(Due d) async {
    await Get.dialog(AlertDialog(
      title: Text(dueLabel(d)),
      content: SizedBox(
        width: double.maxFinite,
        child: SingleChildScrollView(
          child: Obx(() {
            final list = repo.allocs.where((a) => a.dueId == d.id).toList();
            final remaining = repo.remainingOf(d);
            return Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('${'due_date'.tr}: ${fmtDate(d.date)}'),
                Text('${'amount'.tr}: ${money(d.amount)}'),
                Text('${'remaining'.tr}: ${money(remaining)}'),
                const Divider(),
                Text('allocations'.tr, style: const TextStyle(fontWeight: FontWeight.bold)),
                if (list.isEmpty) Text('no_allocations'.tr),
                for (final a in list)
                  ListTile(
                    dense: true,
                    contentPadding: EdgeInsets.zero,
                    title: Text(money(a.amount)),
                    subtitle: Text(_receiptOf(a.paymentId)),
                    trailing: IconButton(
                      icon: const Icon(Icons.undo),
                      tooltip: 'reverse_confirm'.tr,
                      onPressed: () => reverseAllocation(a),
                    ),
                  ),
              ],
            );
          }),
        ),
      ),
      actions: [
        TextButton(onPressed: () => Get.back(), child: Text('close'.tr)),
        FilledButton(
          onPressed: () {
            Get.back();
            openAllocateForm(d);
          },
          child: Text('allocate'.tr),
        ),
      ],
    ));
  }

  String _receiptOf(int paymentId) {
    for (final p in repo.payments) {
      if (p.id == paymentId) return p.receiptNo;
    }
    return '';
  }

  Future<void> reverseAllocation(Alloc a) async {
    if (!await confirm('reverse_confirm'.tr)) return;
    try {
      await repo.reverseAllocation(a.id);
    } catch (_) {
      toast('save_error'.tr);
    }
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
                        child: Text(
                            '${p.receiptNo} - ${'available'.tr} ${money(repo.creditOf(p))}')))
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

  Future<void> _saveAllocation(Due d) async {
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
    try {
      await repo.allocate(p, d, a);
      Get.back();
    } catch (_) {
      toast('save_error'.tr);
    }
  }

  @override
  void onClose() {
    amountCtl.dispose();
    allocCtl.dispose();
    super.onClose();
  }
}
