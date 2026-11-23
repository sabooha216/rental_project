import 'package:drift/drift.dart';
import 'package:get/get.dart' hide Value;
import 'package:rental_project/core/database/app_database.dart';
import 'package:rental_project/features/units/domain/entities/rental_unit.dart';

class UnitsRepository {
  UnitsRepository(this._db);
  final AppDatabase _db;

  final units = <RentalUnit>[].obs;

  Future<void> load() async {
    final rows = await (_db.select(_db.units)..where((t) => t.deletedAt.isNull())).get();
    units.assignAll(rows.map((r) => RentalUnit(id: r.id, name: r.name, rent: r.rent)));
  }

  Future<void> add(String name, double rent) async {
    await _db.into(_db.units).insert(UnitsCompanion.insert(name: name, rent: rent));
    await load();
  }

  Future<void> update(int id, String name, double rent) async {
    await (_db.update(_db.units)..where((t) => t.id.equals(id)))
        .write(UnitsCompanion(name: Value(name), rent: Value(rent)));
    await load();
  }

  /// Soft delete: the row stays in the database.
  Future<void> softDelete(int id) async {
    await (_db.update(_db.units)..where((t) => t.id.equals(id)))
        .write(UnitsCompanion(deletedAt: Value(DateTime.now())));
    await load();
  }

  RentalUnit byId(int id) => units.firstWhere((u) => u.id == id);
}
