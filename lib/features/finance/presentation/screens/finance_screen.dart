import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:rental_project/core/widgets/empty_state.dart';
import 'package:rental_project/core/widgets/search_field.dart';
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

  Widget _dues() => Column(children: [
        SearchField(hintKey: 'search_dues', onChanged: (v) => controller.search.value = v),
        FilterChips(
          labelKeys: const ['all', 'filter_overdue', 'filter_open', 'filter_paid'],
          selected: controller.statusFilter,
        ),
        Expanded(
          child: Obx(() {
            final list = controller.filteredDues;
            if (list.isEmpty) return const EmptyState('no_dues');
            return ListView(
              padding: const EdgeInsets.only(bottom: 88),
              children: list
                  .map((d) => DueTile(
                        due: d,
                        tenantName: controller.tenantNameOfDue(d),
                        onTap: () => controller.openDueDetails(d),
                      ))
                  .toList(),
            );
          }),
        ),
      ]);

  Widget _payments() => Obx(() {
        final list = controller.repo.payments;
        if (list.isEmpty) return const EmptyState('no_payments');
        return ListView(
          padding: const EdgeInsets.only(bottom: 88),
          children: list.reversed
              .map((p) => PaymentTile(
                    payment: p,
                    tenantName: controller.tenantsRepo.byId(p.tenantId).name,
                    trailing: p.voided
                        ? null
                        : PopupMenuButton<String>(
                            onSelected: (_) => controller.voidPayment(p),
                            itemBuilder: (_) => [
                              PopupMenuItem(value: 'void', child: Text('void_payment'.tr)),
                            ],
                          ),
                  ))
              .toList(),
        );
      });
}
