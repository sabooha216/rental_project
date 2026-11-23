import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:rental_project/core/utils/formatters.dart';
import 'package:rental_project/core/widgets/empty_state.dart';
import 'package:rental_project/core/widgets/search_field.dart';
import 'package:rental_project/features/tenants/presentation/controllers/tenants_controller.dart';

class TenantsScreen extends GetView<TenantsController> {
  const TenantsScreen({super.key});

  @override
  Widget build(BuildContext context) => Column(children: [
        SearchField(hintKey: 'search_tenants', onChanged: (v) => controller.query.value = v),
        FilterChips(labelKeys: const ['all', 'filter_has_debt'], selected: controller.filter),
        Expanded(
          child: Obx(() {
            final list = controller.filtered;
            if (list.isEmpty) return const EmptyState('no_tenants');
            return ListView(
              padding: const EdgeInsets.only(bottom: 88),
              children: list.map((t) {
                final b = controller.balanceOf(t);
                return Card(
                  margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  child: ListTile(
                    onTap: () => controller.openStatement(t),
                    leading: const Icon(Icons.person),
                    title: Text(t.name),
                    isThreeLine: true,
                    subtitle: Text(
                        '${t.phone}\n${'debt'.tr}: ${money(b.debt)}  |  ${'credit_balance'.tr}: ${money(b.credit)}'),
                    trailing: Row(mainAxisSize: MainAxisSize.min, children: [
                      Text(
                        b.net > 0
                            ? '${'owes'.tr} ${money(b.net)}'
                            : (b.net < 0 ? '${'credit_for'.tr} ${money(-b.net)}' : 'balanced'.tr),
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: b.net > 0 ? Colors.red : Colors.green.shade700,
                        ),
                      ),
                      PopupMenuButton<String>(
                        onSelected: (v) =>
                            v == 'edit' ? controller.editTenant(t) : controller.deleteTenant(t),
                        itemBuilder: (_) => [
                          PopupMenuItem(value: 'edit', child: Text('edit'.tr)),
                          PopupMenuItem(value: 'delete', child: Text('delete'.tr)),
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
