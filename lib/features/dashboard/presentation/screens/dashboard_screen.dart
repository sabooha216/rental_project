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
        final recent = c.recentPayments;
        return Align(
          alignment: Alignment.topCenter,
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 900),
            child: LayoutBuilder(builder: (context, box) {
              final cols = box.maxWidth >= 760 ? 4 : 2;
              return ListView(
                padding: const EdgeInsets.fromLTRB(12, 12, 12, 88),
                children: [
                  // ---- quick actions ----
                  _title('quick_actions'.tr),
                  Wrap(spacing: 8, runSpacing: 8, children: [
                    FilledButton.tonalIcon(
                        onPressed: c.addPayment,
                        icon: const Icon(Icons.payments),
                        label: Text('qa_payment'.tr)),
                    FilledButton.tonalIcon(
                        onPressed: c.addContract,
                        icon: const Icon(Icons.description),
                        label: Text('qa_contract'.tr)),
                    FilledButton.tonalIcon(
                        onPressed: c.addTenant,
                        icon: const Icon(Icons.person_add),
                        label: Text('qa_tenant'.tr)),
                    FilledButton.tonalIcon(
                        onPressed: c.addUnit,
                        icon: const Icon(Icons.add_home_work),
                        label: Text('qa_unit'.tr)),
                  ]),
                  const SizedBox(height: 16),
                  // ---- numbers ----
                  GridView(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: cols,
                      mainAxisSpacing: 10,
                      crossAxisSpacing: 10,
                      mainAxisExtent: 104,
                    ),
                    children: [
                      _StatCard(Icons.warning_amber, 'overdue_total'.tr, money(c.overdueTotal),
                          Colors.red, '${c.overdueCount} ${'overdue_count'.tr}'),
                      _StatCard(Icons.payments, 'collected_month'.tr,
                          money(c.collectedThisMonth), Colors.green),
                      _StatCard(Icons.event, 'due_next_7'.tr, money(c.dueNext7Days),
                          Colors.orange),
                      _StatCard(Icons.apartment, 'occupancy'.tr,
                          '${c.occupancy.toStringAsFixed(0)}%', Colors.blue,
                          '${c.rentedUnits} / ${c.totalUnits}'),
                    ],
                  ),
                  // ---- lists ----
                  _Section('expiring_contracts'.tr, [
                    if (expiring.isEmpty) _empty(),
                    for (final k in expiring)
                      ListTile(
                        dense: true,
                        leading: const Icon(Icons.description),
                        title: Text(
                            '${c.unitsRepo.byId(k.unitId).name}  ←  ${c.tenantsRepo.byId(k.tenantId).name}'),
                        subtitle: Text(fmtDate(k.endDate)),
                        trailing: Text('days_left'.trParams({'n': '${k.daysLeft}'})),
                      ),
                  ]),
                  _Section('top_debtors'.tr, [
                    if (debtors.isEmpty) _empty(),
                    for (final d in debtors)
                      ListTile(
                        dense: true,
                        leading: const Icon(Icons.person),
                        title: Text(d.tenant.name),
                        subtitle: Text(d.tenant.phone),
                        trailing: Text(money(d.amount),
                            style: const TextStyle(
                                color: Colors.red, fontWeight: FontWeight.bold)),
                      ),
                  ]),
                  _Section('recent_payments'.tr, [
                    if (recent.isEmpty) _empty(),
                    for (final p in recent)
                      ListTile(
                        dense: true,
                        leading: const Icon(Icons.receipt_long),
                        title: Text('${p.receiptNo}  ${c.tenantsRepo.byId(p.tenantId).name}'),
                        subtitle: Text('${fmtDate(p.date)} • ${'m_${p.method.name}'.tr}'),
                        trailing: Text(money(p.amount),
                            style: const TextStyle(fontWeight: FontWeight.bold)),
                      ),
                  ]),
                ],
              );
            }),
          ),
        );
      });

  Widget _title(String t) => Padding(
        padding: const EdgeInsets.only(bottom: 8),
        child: Text(t, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
      );

  Widget _empty() => Padding(
        padding: const EdgeInsets.all(8),
        child: Text('nothing_here'.tr, style: const TextStyle(color: Colors.grey)),
      );
}

class _Section extends StatelessWidget {
  final String title;
  final List<Widget> children;
  const _Section(this.title, this.children);

  @override
  Widget build(BuildContext context) => Card(
        margin: const EdgeInsets.only(top: 16),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(12, 8, 12, 4),
              child: Text(title,
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
            ),
            ...children,
          ]),
        ),
      );
}

class _StatCard extends StatelessWidget {
  final IconData icon;
  final String label, value;
  final MaterialColor color;
  final String? footer;
  const _StatCard(this.icon, this.label, this.value, this.color, [this.footer]);

  @override
  Widget build(BuildContext context) {
    final dark = Theme.of(context).brightness == Brightness.dark;
    final bg = dark ? color.shade900.withValues(alpha: 0.35) : color.shade50;
    final fg = dark ? color.shade100 : color.shade900;
    return Card(
      margin: EdgeInsets.zero,
      color: bg,
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(children: [
            Icon(icon, color: fg, size: 18),
            const SizedBox(width: 6),
            Expanded(
              child: Text(label,
                  style: TextStyle(color: fg, fontSize: 12), overflow: TextOverflow.ellipsis),
            ),
          ]),
          const Spacer(),
          Text(value, style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: fg)),
          if (footer != null) Text(footer!, style: TextStyle(fontSize: 11, color: fg)),
        ]),
      ),
    );
  }
}
