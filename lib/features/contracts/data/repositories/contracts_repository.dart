import 'package:drift/drift.dart';
import 'package:get/get.dart' hide Value;
import 'package:rental_project/core/database/app_database.dart';
import 'package:rental_project/features/contracts/domain/entities/contract.dart';

class ContractsRepository {
  ContractsRepository(this._db);
  final AppDatabase _db;

  final contracts = <Contract>[].obs;

  /// Contract term = one year: ends the day before the anniversary.
  static DateTime endOf(DateTime start) => DateTime(start.year + 1, start.month, start.day - 1);

  Future<void> load() async {
    final rows = await _db.select(_db.contracts).get();
    contracts.assignAll(rows.map((r) => Contract(
          id: r.id,
          unitId: r.unitId,
          tenantId: r.tenantId,
          start: r.start,
          endDate: r.endDate ?? endOf(r.start),
          annualRent: r.annualRent,
          plan: Plan.values.byName(r.plan),
          status: ContractStatus.values.byName(r.status),
          terminatedAt: r.terminatedAt,
          terminationReason: r.terminationReason,
          renewedFromId: r.renewedFromId,
        )));
  }

  /// The ACTIVE contract of a unit (terminated/expired ones are history).
  Contract? ofUnit(int unitId) {
    for (final c in contracts) {
      if (c.unitId == unitId && c.isActive) return c;
    }
    return null;
  }

  Contract byId(int id) => contracts.firstWhere((c) => c.id == id);

  Set<int> contractIds(int tenantId) =>
      contracts.where((c) => c.tenantId == tenantId).map((c) => c.id).toSet();

  /// Inserts only (no cache reload) so it can run inside a transaction.
  /// Call load() after the transaction commits.
  Future<Contract> insert(int unitId, int tenantId, Plan plan, double rent, DateTime start,
      {int? renewedFromId}) async {
    final end = endOf(start);
    final id = await _db.into(_db.contracts).insert(ContractsCompanion.insert(
          unitId: unitId,
          tenantId: tenantId,
          start: start,
          annualRent: rent,
          plan: plan.name,
          endDate: Value(end),
          renewedFromId: Value(renewedFromId),
        ));
    return Contract(
      id: id,
      unitId: unitId,
      tenantId: tenantId,
      start: start,
      endDate: end,
      annualRent: rent,
      plan: plan,
      renewedFromId: renewedFromId,
    );
  }

  /// Changes a contract's status (no cache reload; call load() afterwards).
  Future<void> setStatus(int id, ContractStatus status, {String? reason}) async {
    await (_db.update(_db.contracts)..where((t) => t.id.equals(id))).write(ContractsCompanion(
      status: Value(status.name),
      terminatedAt: status == ContractStatus.terminated
          ? Value(DateTime.now())
          : const Value.absent(),
      terminationReason: reason != null ? Value(reason) : const Value.absent(),
    ));
  }
}
