import 'package:get/get.dart';
import 'package:rental_project/core/utils/formatters.dart';
import 'package:rental_project/features/contracts/domain/entities/contract.dart';

class ContractsRepository {
  final contracts = <Contract>[].obs;

  Contract? ofUnit(int unitId) {
    for (final c in contracts) {
      if (c.unitId == unitId) return c;
    }
    return null;
  }

  Contract byId(int id) => contracts.firstWhere((c) => c.id == id);

  Set<int> contractIds(int tenantId) =>
      contracts.where((c) => c.tenantId == tenantId).map((c) => c.id).toSet();

  Contract add(int unitId, int tenantId, Plan plan, double rent, DateTime start) {
    final c = Contract(
      id: IdGen.next(),
      unitId: unitId,
      tenantId: tenantId,
      start: start,
      annualRent: rent,
      plan: plan,
    );
    contracts.add(c);
    return c;
  }
}
