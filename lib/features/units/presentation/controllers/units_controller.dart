import 'package:get/get.dart';
import 'package:rental_project/core/utils/dialogs.dart';
import 'package:rental_project/features/contracts/data/repositories/contracts_repository.dart';
import 'package:rental_project/features/units/data/repositories/units_repository.dart';
import 'package:rental_project/features/units/domain/entities/rental_unit.dart';

class UnitsController extends GetxController {
  final repo = Get.find<UnitsRepository>();
  final contractsRepo = Get.find<ContractsRepository>();

  bool isRented(RentalUnit u) => contractsRepo.ofUnit(u.id) != null;

  Future<void> addUnit() async {
    final r = await askText('new_unit', ['unit_name', 'annual_rent'], numeric: [false, true]);
    if (r == null || r[0].isEmpty) return;
    repo.add(r[0], double.tryParse(r[1]) ?? 0);
  }
}
