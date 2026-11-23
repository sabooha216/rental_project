import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:rental_project/core/utils/formatters.dart';
import 'package:rental_project/features/finance/data/repositories/finance_repository.dart';
import 'package:rental_project/features/finance/domain/entities/due.dart';
import 'package:rental_project/features/finance/domain/entities/payment.dart';

String dueLabel(Due d) => d.labelKey.trParams({'n': '${d.seq}'});

class DueTile extends StatelessWidget {
  final Due due;
  final String? tenantName;
  final VoidCallback? onTap;
  const DueTile({super.key, required this.due, this.tenantName, this.onTap});

  @override
  Widget build(BuildContext context) {
    final repo = Get.find<FinanceRepository>();
    return Obx(() {
      final st = repo.statusOf(due);
      final MaterialColor color = switch (st) {
        DueStatus.paid => Colors.green,
        DueStatus.overdue || DueStatus.partialOverdue => Colors.red,
        _ => Colors.orange,
      };
      return ListTile(
        onTap: onTap,
        title: Text(tenantName == null ? dueLabel(due) : '${dueLabel(due)} - $tenantName'),
        subtitle: Text('${'due_date'.tr}: ${fmtDate(due.date)} | ${money(due.amount)} | '
            '${'remaining'.tr}: ${money(repo.remainingOf(due))}'),
        trailing: Chip(
          label: Text('st_${st.name}'.tr, style: TextStyle(color: color.shade900)),
          backgroundColor: color.shade100,
        ),
      );
    });
  }
}

class PaymentTile extends StatelessWidget {
  final Payment payment;
  final String tenantName;
  final Widget? trailing;
  const PaymentTile({super.key, required this.payment, required this.tenantName, this.trailing});

  @override
  Widget build(BuildContext context) {
    final repo = Get.find<FinanceRepository>();
    return Obx(() {
      final credit = repo.creditOf(payment);
      final voided = payment.voided;
      return ListTile(
        leading: Icon(voided ? Icons.block : Icons.receipt_long,
            color: voided ? Colors.grey : null),
        title: Text(
          '${payment.receiptNo}  $tenantName - ${money(payment.amount)} (${'m_${payment.method.name}'.tr})',
          style: voided
              ? const TextStyle(decoration: TextDecoration.lineThrough, color: Colors.grey)
              : null,
        ),
        subtitle: Text(voided
            ? '${'voided'.tr}: ${payment.voidReason ?? ''}'
            : '${fmtDate(payment.date)} | ${'unallocated'.tr}: ${money(credit)}'),
        trailing: trailing,
      );
    });
  }
}
