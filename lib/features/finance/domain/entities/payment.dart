enum PayMethod { cash, wallet, transfer, cheque }

class Payment {
  final int id, tenantId;
  final double amount;
  final DateTime date;
  final PayMethod method;
  Payment({
    required this.id,
    required this.tenantId,
    required this.amount,
    required this.date,
    required this.method,
  });
}

/// Manual link between a payment and a due.
class Alloc {
  final int paymentId, dueId;
  final double amount;
  Alloc(this.paymentId, this.dueId, this.amount);
}
