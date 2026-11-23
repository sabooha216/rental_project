import 'package:get/get.dart';
import 'package:rental_project/core/database/app_database.dart';
import 'package:rental_project/features/contracts/data/repositories/contracts_repository.dart';
import 'package:rental_project/features/finance/data/repositories/finance_repository.dart';
import 'package:rental_project/features/tenants/data/repositories/tenants_repository.dart';
import 'package:rental_project/features/units/data/repositories/units_repository.dart';

/// Opens the database, registers repositories, and loads saved data.
/// Called once from main() before runApp().
Future<void> initServices() async {
  final db = Get.put(AppDatabase(), permanent: true);
  final units = Get.put(UnitsRepository(db), permanent: true);
  final tenants = Get.put(TenantsRepository(db), permanent: true);
  final contracts = Get.put(ContractsRepository(db), permanent: true);
  final finance = Get.put(FinanceRepository(db), permanent: true);
  await Future.wait([units.load(), tenants.load(), contracts.load(), finance.load()]);
}
