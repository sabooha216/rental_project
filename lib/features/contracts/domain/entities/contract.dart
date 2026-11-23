enum Plan { monthly, annual }

enum ContractStatus { active, terminated, expired }

class Contract {
  final int id, unitId, tenantId;
  final DateTime start, endDate;
  final double annualRent;
  final Plan plan;
  final ContractStatus status;
  final DateTime? terminatedAt;
  final String? terminationReason;
  final int? renewedFromId;

  Contract({
    required this.id,
    required this.unitId,
    required this.tenantId,
    required this.start,
    required this.endDate,
    required this.annualRent,
    required this.plan,
    this.status = ContractStatus.active,
    this.terminatedAt,
    this.terminationReason,
    this.renewedFromId,
  });

  bool get isActive => status == ContractStatus.active;
  int get daysLeft => endDate.difference(DateTime.now()).inDays;
}
