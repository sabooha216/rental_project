import 'dart:math';
import 'package:drift/drift.dart';
import 'package:get/get.dart' hide Value;
import 'package:rental_project/core/database/app_database.dart';
import 'package:rental_project/features/contracts/domain/entities/contract.dart';
import 'package:rental_project/features/finance/domain/entities/due.dart';
import 'package:rental_project/features/finance/domain/entities/payment.dart';

class Balance {
  final double debt, credit;
  const Balance(this.debt, this.credit);
  double get net => debt - credit; // positive = tenant owes
}

class FinanceRepository {
  FinanceRepository(this._db);
  final AppDatabase _db;

  static const annualDiscount = 0.05;

  final dues = <Due>[].obs;
  final payments = <Payment>[].obs;
  final allocs = <Alloc>[].obs;

  /// Loads active dues, all payments (voided ones are marked), active allocations.
  Future<void> load() async {
    final dueRows =
        await (_db.select(_db.dues)..where((t) => t.status.equals('active'))).get();
    final payRows = await _db.select(_db.payments).get();
    final allocRows =
        await (_db.select(_db.allocations)..where((t) => t.reversedAt.isNull())).get();
    dues.assignAll(dueRows.map((r) => Due(
          id: r.id,
          contractId: r.contractId,
          date: r.date,
          amount: r.amount,
          labelKey: r.labelKey,
          seq: r.seq,
        )));
    payments.assignAll(payRows.map((r) => Payment(
          id: r.id,
          tenantId: r.tenantId,
          amount: r.amount,
          date: r.date,
          method: PayMethod.values.byName(r.method),
          voided: r.voidedAt != null,
          voidReason: r.voidReason,
          note: r.note,
        )));
    allocs.assignAll(allocRows.map((r) => Alloc(r.id, r.paymentId, r.dueId, r.amount)));
  }

  // ---- computed values (never stored) ----
  double paidOf(Due d) =>
      allocs.where((a) => a.dueId == d.id).fold(0.0, (s, a) => s + a.amount);

  double remainingOf(Due d) => d.amount - paidOf(d);

  /// Unallocated amount of a payment (voided payments have none).
  double creditOf(Payment p) {
    final used = allocs.where((a) => a.paymentId == p.id).fold(0.0, (s, a) => s + a.amount);
    if (p.voided) return 0;
    return p.amount - used;
  }

  DueStatus statusOf(Due d) {
    if (remainingOf(d) <= 0.005) return DueStatus.paid;
    final overdue = d.date.isBefore(DateTime.now());
    if (paidOf(d) > 0) return overdue ? DueStatus.partialOverdue : DueStatus.partial;
    return overdue ? DueStatus.overdue : DueStatus.unpaid;
  }

  Balance balanceOf(int tenantId, Set<int> contractIds) {
    final debt = dues
        .where((d) => contractIds.contains(d.contractId))
        .fold(0.0, (s, d) => s + remainingOf(d));
    final credit = payments
        .where((p) => p.tenantId == tenantId)
        .fold(0.0, (s, p) => s + creditOf(p));
    return Balance(debt, credit);
  }

  // ---- commands ----

  /// Inserts the contract's dues (no cache reload) so it can run inside the
  /// same transaction as the contract insert. Call load() after commit.
  Future<void> insertDues(Contract c) async {
    final rows = <DuesCompanion>[];
    if (c.plan == Plan.annual) {
      rows.add(DuesCompanion.insert(
        contractId: c.id,
        seq: 1,
        date: c.start,
        amount: _r(c.annualRent * (1 - annualDiscount)),
        labelKey: 'rent_annual',
      ));
    } else {
      final part = _r(c.annualRent / 12);
      double used = 0;
      for (int i = 0; i < 12; i++) {
        final last = DateTime(c.start.year, c.start.month + i + 1, 0).day;
        final date = DateTime(c.start.year, c.start.month + i, min(c.start.day, last));
        final amount = i == 11 ? _r(c.annualRent - used) : part;
        used += part;
        rows.add(DuesCompanion.insert(
          contractId: c.id,
          seq: i + 1,
          date: date,
          amount: amount,
          labelKey: 'rent_month',
        ));
      }
    }
    await _db.batch((b) => b.insertAll(_db.dues, rows));
  }

  /// Cancels upcoming dues of a contract that have no payments on them
  /// (no cache reload; call load() afterwards).
  Future<int> cancelFutureDues(int contractId, DateTime from) async {
    final ids = dues
        .where((d) => d.contractId == contractId && d.date.isAfter(from) && paidOf(d) <= 0.005)
        .map((d) => d.id)
        .toList();
    if (ids.isEmpty) return 0;
    await (_db.update(_db.dues)..where((t) => t.id.isIn(ids)))
        .write(DuesCompanion(status: Value('cancelled')));
    return ids.length;
  }

  Future<void> addPayment(int tenantId, double amount, PayMethod method) async {
    await _db.into(_db.payments).insert(PaymentsCompanion.insert(
          tenantId: tenantId,
          amount: amount,
          date: DateTime.now(),
          method: method.name,
        ));
    await load();
  }

  Future<void> allocate(Payment p, Due d, double amount) async {
    await _db.into(_db.allocations).insert(AllocationsCompanion.insert(
          paymentId: p.id,
          dueId: d.id,
          amount: amount,
        ));
    await load();
  }

  /// Voids a payment (kept for the record) and reverses all its allocations.
  Future<void> voidPayment(Payment p, String reason) async {
    final now = DateTime.now();
    await _db.transaction(() async {
      await (_db.update(_db.payments)..where((t) => t.id.equals(p.id))).write(
        PaymentsCompanion(voidedAt: Value(now), voidReason: Value(reason)),
      );
      await (_db.update(_db.allocations)
            ..where((t) => t.paymentId.equals(p.id) & t.reversedAt.isNull()))
          .write(AllocationsCompanion(reversedAt: Value(now)));
    });
    await load();
  }

  Future<void> reverseAllocation(int allocId) async {
    await (_db.update(_db.allocations)..where((t) => t.id.equals(allocId)))
        .write(AllocationsCompanion(reversedAt: Value(DateTime.now())));
    await load();
  }

  double _r(double v) => double.parse(v.toStringAsFixed(2));
}
