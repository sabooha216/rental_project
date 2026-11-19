import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:rental_project/core/utils/formatters.dart';
import 'package:rental_project/features/finance/presentation/widgets/due_tile.dart';
import 'package:rental_project/features/tenants/presentation/controllers/tenant_statement_controller.dart';

class TenantStatementScreen extends GetView<TenantStatementController> {
  const TenantStatementScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final name = controller.tenant.name;
    return Scaffold(
      appBar: AppBar(title: Text('${'statement'.tr} - $name')),
      body: Obx(() {
        final b = controller.balance;
        final dues = controller.dues;
        final pays = controller.payments;
        return ListView(children: [
          Card(
            margin: const EdgeInsets.all(12),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text('${'debt'.tr}: ${money(b.debt)}'),
                Text('${'credit_balance'.tr}: ${money(b.credit)}'),
                const Divider(),
                Text(
                  '${'net'.tr}: ${money(b.net)}',
                  style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: b.net > 0 ? Colors.red : Colors.green.shade700),
                ),
              ]),
            ),
          ),
          _header('dues'.tr),
          ...dues.map((d) => DueTile(due: d)),
          _header('payments'.tr),
          ...pays.map((p) => PaymentTile(payment: p, tenantName: name)),
        ]);
      }),
    );
  }

  Widget _header(String t) => Padding(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 4),
        child: Text(t, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
      );
}
