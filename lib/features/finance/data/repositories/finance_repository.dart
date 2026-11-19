import 'dart:math';
import 'package:get/get.dart';
import 'package:rental_project/core/utils/formatters.dart';
import 'package:rental_project/features/contracts/domain/entities/contract.dart';
import 'package:rental_project/features/finance/domain/entities/due.dart';
import 'package:rental_project/features/finance/domain/entities/payment.dart';

class Balance {
  final double debt, credit;
  const Balance(this.debt, this.credit);
  double get net => debt - credit; // positive = tenant owes
}

class FinanceRepository {
  static const annualDiscount = 0.05;

  final dues = <Due>[].obs;
  final payments = <Payment>[].obs;
  final allocs = <Alloc>[].obs;

  // ---- computed values (never stored) ----
  double paidOf(Due d) =>
      allocs.where((a) => a.dueId == d.id).fold(0.0, (s, a) => s + a.amount);

  double remainingOf(Due d) => d.amount - paidOf(d);

  double creditOf(Payment p) =>
      p.amount - allocs.where((a) => a.paymentId == p.id).fold(0.0, (s, a) => s + a.amount);

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
  void generateDues(Contract c) {
    final list = <Due>[];
    if (c.plan == Plan.annual) {
      list.add(Due(
        id: IdGen.next(),
        contractId: c.id,
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
        list.add(Due(
          id: IdGen.next(),
          contractId: c.id,
          date: date,
          amount: amount,
          labelKey: 'rent_month',
          seq: i + 1,
        ));
      }
    }
    dues.addAll(list);
  }

  void addPayment(int tenantId, double amount, PayMethod method) {
    payments.add(Payment(
      id: IdGen.next(),
      tenantId: tenantId,
      amount: amount,
      date: DateTime.now(),
      method: method,
    ));
  }

  void allocate(Payment p, Due d, double amount) => allocs.add(Alloc(p.id, d.id, amount));

  double _r(double v) => double.parse(v.toStringAsFixed(2));
}
