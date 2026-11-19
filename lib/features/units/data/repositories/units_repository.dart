import 'package:get/get.dart';
import 'package:rental_project/core/utils/formatters.dart';
import 'package:rental_project/features/units/domain/entities/rental_unit.dart';

class UnitsRepository {
  final units = <RentalUnit>[].obs;

  RentalUnit add(String name, double rent) {
    final u = RentalUnit(id: IdGen.next(), name: name, rent: rent);
    units.add(u);
    return u;
  }

  RentalUnit byId(int id) => units.firstWhere((u) => u.id == id);
}
