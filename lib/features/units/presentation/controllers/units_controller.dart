import 'package:get/get.dart';
import 'package:rental_project/core/utils/dialogs.dart';
import 'package:rental_project/features/contracts/data/repositories/contracts_repository.dart';
import 'package:rental_project/features/units/data/repositories/units_repository.dart';
import 'package:rental_project/features/units/domain/entities/rental_unit.dart';

class UnitsController extends GetxController {
  final repo = Get.find<UnitsRepository>();
  final contractsRepo = Get.find<ContractsRepository>();

  final query = ''.obs;
  final filter = 0.obs; // 0 all | 1 rented | 2 vacant

  bool isRented(RentalUnit u) => contractsRepo.ofUnit(u.id) != null;

  List<RentalUnit> get filtered {
    final q = query.value.trim().toLowerCase();
    return repo.units.where((u) {
      final rented = isRented(u);
      final okFilter =
          filter.value == 0 || (filter.value == 1 && rented) || (filter.value == 2 && !rented);
      return okFilter && (q.isEmpty || u.name.toLowerCase().contains(q));
    }).toList();
  }

  Future<void> addUnit() async {
    final r = await askText('new_unit', ['unit_name', 'annual_rent'], numeric: [false, true]);
    if (r == null || r[0].isEmpty) return;
    await repo.add(r[0], double.tryParse(r[1]) ?? 0);
  }

  Future<void> editUnit(RentalUnit u) async {
    final r = await askText('edit_unit', ['unit_name', 'annual_rent'],
        numeric: [false, true], initial: [u.name, u.rent.toString()]);
    if (r == null || r[0].isEmpty) return;
    await repo.update(u.id, r[0], double.tryParse(r[1]) ?? u.rent);
  }

  Future<void> deleteUnit(RentalUnit u) async {
    if (contractsRepo.contracts.any((c) => c.unitId == u.id)) {
      toast('unit_has_history'.tr);
      return;
    }
    if (!await confirm('delete_unit_confirm'.tr)) return;
    await repo.softDelete(u.id);
  }
}
