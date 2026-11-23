import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:rental_project/core/utils/formatters.dart';
import 'package:rental_project/core/widgets/empty_state.dart';
import 'package:rental_project/core/widgets/search_field.dart';
import 'package:rental_project/features/contracts/presentation/controllers/contracts_controller.dart';

class ContractsScreen extends GetView<ContractsController> {
  const ContractsScreen({super.key});

  @override
  Widget build(BuildContext context) => Column(children: [
        SearchField(hintKey: 'search_contracts', onChanged: (v) => controller.query.value = v),
        FilterChips(
            labelKeys: const ['all', 'filter_active', 'filter_ended'], selected: controller.filter),
        Expanded(
          child: Obx(() {
            final list = controller.filtered;
            if (list.isEmpty) return const EmptyState('no_contracts');
            return ListView(
              padding: const EdgeInsets.only(bottom: 88),
              children: list.map((c) {
                final unit = controller.unitsRepo.byId(c.unitId).name;
                final tenant = controller.tenantsRepo.byId(c.tenantId).name;
                final ended = !c.isActive || c.endDate.isBefore(DateTime.now());
                final MaterialColor color = ended ? Colors.grey : Colors.green;
                return Card(
                  margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  child: ListTile(
                    leading: const Icon(Icons.description),
                    title: Text('$unit  ←  $tenant'),
                    isThreeLine: true,
                    subtitle: Text(
                      '${'plan_${c.plan.name}'.tr} | ${money(c.annualRent)}\n'
                      '${fmtDate(c.start)}  →  ${fmtDate(c.endDate)}'
                      '${c.isActive && c.daysLeft >= 0 ? '  (${'days_left'.trParams({'n': '${c.daysLeft}'})})' : ''}'
                      '${c.terminationReason != null ? '\n${c.terminationReason}' : ''}',
                    ),
                    trailing: Row(mainAxisSize: MainAxisSize.min, children: [
                      Chip(
                        label: Text(controller.statusLabel(c),
                            style: TextStyle(color: color.shade900)),
                        backgroundColor: color.shade100,
                      ),
                      if (c.isActive)
                        PopupMenuButton<String>(
                          onSelected: (v) =>
                              v == 'renew' ? controller.renew(c) : controller.terminate(c),
                          itemBuilder: (_) => [
                            PopupMenuItem(value: 'renew', child: Text('renew_contract'.tr)),
                            PopupMenuItem(value: 'terminate', child: Text('terminate_contract'.tr)),
                          ],
                        ),
                    ]),
                  ),
                );
              }).toList(),
            );
          }),
        ),
      ]);
}
