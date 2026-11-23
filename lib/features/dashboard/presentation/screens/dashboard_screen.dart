import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:rental_project/core/utils/formatters.dart';
import 'package:rental_project/features/dashboard/presentation/controllers/dashboard_controller.dart';

class DashboardScreen extends GetView<DashboardController> {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) => Obx(() {
        final c = controller;
        final expiring = c.expiringSoon;
        final debtors = c.topDebtors;
        return ListView(
          padding: const EdgeInsets.fromLTRB(12, 12, 12, 88),
          children: [
            GridView.count(
              crossAxisCount: 2,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              mainAxisSpacing: 10,
              crossAxisSpacing: 10,
              childAspectRatio: 1.45,
              children: [
                _StatCard(Icons.warning_amber, 'overdue_total'.tr, money(c.overdueTotal),
                    Colors.red, '${c.overdueCount} ${'overdue_count'.tr}'),
                _StatCard(Icons.payments, 'collected_month'.tr, money(c.collectedThisMonth),
                    Colors.green),
                _StatCard(Icons.event, 'due_next_7'.tr, money(c.dueNext7Days), Colors.orange),
                _StatCard(Icons.apartment, 'occupancy'.tr,
                    '${c.occupancy.toStringAsFixed(0)}%', Colors.blue,
                    '${c.rentedUnits} / ${c.totalUnits}'),
              ],
            ),
            _header('expiring_contracts'.tr),
            if (expiring.isEmpty) _empty(),
            for (final k in expiring)
              ListTile(
                leading: const Icon(Icons.description),
                title: Text(
                    '${c.unitsRepo.byId(k.unitId).name}  ←  ${c.tenantsRepo.byId(k.tenantId).name}'),
                subtitle: Text(fmtDate(k.endDate)),
                trailing: Text('days_left'.trParams({'n': '${k.daysLeft}'})),
              ),
            _header('top_debtors'.tr),
            if (debtors.isEmpty) _empty(),
            for (final d in debtors)
              ListTile(
                leading: const Icon(Icons.person),
                title: Text(d.tenant.name),
                subtitle: Text(d.tenant.phone),
                trailing: Text(money(d.amount),
                    style: const TextStyle(color: Colors.red, fontWeight: FontWeight.bold)),
              ),
          ],
        );
      });

  Widget _header(String t) => Padding(
        padding: const EdgeInsets.fromLTRB(4, 20, 4, 4),
        child: Text(t, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
      );

  Widget _empty() => Padding(
        padding: const EdgeInsets.all(12),
        child: Text('nothing_here'.tr, style: const TextStyle(color: Colors.grey)),
      );
}

class _StatCard extends StatelessWidget {
  final IconData icon;
  final String label, value;
  final MaterialColor color;
  final String? footer;
  const _StatCard(this.icon, this.label, this.value, this.color, [this.footer]);

  @override
  Widget build(BuildContext context) => Card(
        color: color.shade50.withValues(alpha: 0.6),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Row(children: [
              Icon(icon, color: color.shade700, size: 20),
              const SizedBox(width: 6),
              Expanded(
                child: Text(label,
                    style: TextStyle(color: color.shade900, fontSize: 12),
                    overflow: TextOverflow.ellipsis),
              ),
            ]),
            const Spacer(),
            Text(value,
                style: TextStyle(
                    fontSize: 22, fontWeight: FontWeight.bold, color: color.shade900)),
            if (footer != null)
              Text(footer!, style: TextStyle(fontSize: 11, color: color.shade800)),
          ]),
        ),
      );
}
