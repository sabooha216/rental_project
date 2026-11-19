import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:rental_project/core/utils/formatters.dart';
import 'package:rental_project/core/widgets/empty_state.dart';
import 'package:rental_project/features/units/presentation/controllers/units_controller.dart';

class UnitsScreen extends GetView<UnitsController> {
  const UnitsScreen({super.key});

  @override
  Widget build(BuildContext context) => Obx(() {
        final list = controller.repo.units;
        if (list.isEmpty) return const EmptyState('no_units');
        return ListView(
          children: list.map((u) {
            final rented = controller.isRented(u);
            final MaterialColor color = rented ? Colors.green : Colors.orange;
            return ListTile(
              leading: const Icon(Icons.home_work),
              title: Text(u.name),
              subtitle: Text('${'annual_rent'.tr}: ${money(u.rent)}'),
              trailing: Chip(
                label: Text(
                  rented ? 'rented'.tr : 'vacant'.tr,
                  style: TextStyle(color: color.shade900),
                ),
                backgroundColor: color.shade100,
              ),
            );
          }).toList(),
        );
      });
}
