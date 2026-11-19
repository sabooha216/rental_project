import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:rental_project/core/utils/formatters.dart';
import 'package:rental_project/core/widgets/empty_state.dart';
import 'package:rental_project/features/contracts/presentation/controllers/contracts_controller.dart';

class ContractsScreen extends GetView<ContractsController> {
  const ContractsScreen({super.key});

  @override
  Widget build(BuildContext context) => Obx(() {
        final list = controller.repo.contracts;
        if (list.isEmpty) return const EmptyState('no_contracts');
        return ListView(
          children: list.map((c) {
            final unit = controller.unitsRepo.byId(c.unitId).name;
            final tenant = controller.tenantsRepo.byId(c.tenantId).name;
            return ListTile(
              leading: const Icon(Icons.description),
              title: Text('$unit  ←  $tenant'),
              subtitle: Text(
                  '${'plan_${c.plan.name}'.tr} | ${'starts'.tr} ${fmtDate(c.start)} | ${money(c.annualRent)}'),
            );
          }).toList(),
        );
      });
}
