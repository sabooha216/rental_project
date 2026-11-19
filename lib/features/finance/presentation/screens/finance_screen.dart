import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:rental_project/core/widgets/empty_state.dart';
import 'package:rental_project/features/finance/presentation/controllers/finance_controller.dart';
import 'package:rental_project/features/finance/presentation/widgets/due_tile.dart';

class FinanceScreen extends GetView<FinanceController> {
  const FinanceScreen({super.key});

  @override
  Widget build(BuildContext context) => DefaultTabController(
        length: 2,
        child: Column(children: [
          TabBar(tabs: [Tab(text: 'dues'.tr), Tab(text: 'payments'.tr)]),
          Expanded(child: TabBarView(children: [_dues(), _payments()])),
        ]),
      );

  Widget _dues() => Obx(() {
        final list = controller.repo.dues;
        if (list.isEmpty) return const EmptyState('no_dues');
        return ListView(
          children: list
              .map((d) => DueTile(
                    due: d,
                    tenantName: controller.tenantNameOfDue(d),
                    onTap: () => controller.openAllocateForm(d),
                  ))
              .toList(),
        );
      });

  Widget _payments() => Obx(() {
        final list = controller.repo.payments;
        if (list.isEmpty) return const EmptyState('no_payments');
        return ListView(
          children: list.reversed
              .map((p) => PaymentTile(
                    payment: p,
                    tenantName: controller.tenantsRepo.byId(p.tenantId).name,
                  ))
              .toList(),
        );
      });
}
