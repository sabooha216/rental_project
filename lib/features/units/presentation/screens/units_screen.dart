import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:rental_project/core/utils/formatters.dart';
import 'package:rental_project/core/widgets/empty_state.dart';
import 'package:rental_project/core/widgets/search_field.dart';
import 'package:rental_project/features/units/presentation/controllers/units_controller.dart';

class UnitsScreen extends GetView<UnitsController> {
  const UnitsScreen({super.key});

  @override
  Widget build(BuildContext context) => Column(children: [
        SearchField(hintKey: 'search_units', onChanged: (v) => controller.query.value = v),
        FilterChips(labelKeys: const ['all', 'rented', 'vacant'], selected: controller.filter),
        Expanded(
          child: Obx(() {
            final list = controller.filtered;
            if (list.isEmpty) return const EmptyState('no_units');
            return ListView(
              padding: const EdgeInsets.only(bottom: 88),
              children: list.map((u) {
                final rented = controller.isRented(u);
                final MaterialColor color = rented ? Colors.green : Colors.orange;
                return ListTile(
                  leading: const Icon(Icons.home_work),
                  title: Text(u.name),
                  subtitle: Text('${'annual_rent'.tr}: ${money(u.rent)}'),
                  trailing: Row(mainAxisSize: MainAxisSize.min, children: [
                    Chip(
                      label: Text(rented ? 'rented'.tr : 'vacant'.tr,
                          style: TextStyle(color: color.shade900)),
                      backgroundColor: color.shade100,
                    ),
                    PopupMenuButton<String>(
                      onSelected: (v) =>
                          v == 'edit' ? controller.editUnit(u) : controller.deleteUnit(u),
                      itemBuilder: (_) => [
                        PopupMenuItem(value: 'edit', child: Text('edit'.tr)),
                        PopupMenuItem(value: 'delete', child: Text('delete'.tr)),
                      ],
                    ),
                  ]),
                );
              }).toList(),
            );
          }),
        ),
      ]);
}
