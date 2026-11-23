enum PayMethod { cash, wallet, transfer, cheque }

class Payment {
  final int id, tenantId;
  final double amount;
  final DateTime date;
  final PayMethod method;
  final bool voided;
  final String? voidReason;
  final String? note;

  Payment({
    required this.id,
    required this.tenantId,
    required this.amount,
    required this.date,
    required this.method,
    this.voided = false,
    this.voidReason,
    this.note,
  });

  /// Receipt number derived from the id, e.g. RC-000012
  String get receiptNo => 'RC-${id.toString().padLeft(6, '0')}';
}

/// Manual link between a payment and a due (reversed, never deleted).
class Alloc {
  final int id, paymentId, dueId;
  final double amount;
  Alloc(this.id, this.paymentId, this.dueId, this.amount);
}
