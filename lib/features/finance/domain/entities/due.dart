enum DueStatus { paid, partial, partialOverdue, unpaid, overdue }

class Due {
  final int id, contractId, seq;
  final DateTime date;
  final double amount;
  final String labelKey; // translation key, e.g. rent_month
  Due({
    required this.id,
    required this.contractId,
    required this.date,
    required this.amount,
    required this.labelKey,
    this.seq = 1,
  });
}
