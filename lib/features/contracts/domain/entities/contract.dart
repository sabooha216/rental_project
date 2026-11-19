enum Plan { monthly, annual }

class Contract {
  final int id, unitId, tenantId;
  final DateTime start;
  final double annualRent;
  final Plan plan;
  Contract({
    required this.id,
    required this.unitId,
    required this.tenantId,
    required this.start,
    required this.annualRent,
    required this.plan,
  });
}
