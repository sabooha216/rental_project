import 'package:drift/drift.dart';
import 'package:get/get.dart' hide Value;
import 'package:rental_project/core/database/app_database.dart';
import 'package:rental_project/features/tenants/domain/entities/tenant.dart';

class TenantsRepository {
  TenantsRepository(this._db);
  final AppDatabase _db;

  final tenants = <Tenant>[].obs;

  Future<void> load() async {
    final rows = await (_db.select(_db.tenants)..where((t) => t.deletedAt.isNull())).get();
    tenants.assignAll(rows.map((r) =>
        Tenant(id: r.id, name: r.name, phone: r.phone, nationalId: r.nationalId)));
  }

  Future<void> add(String name, String phone, {String? nationalId}) async {
    await _db.into(_db.tenants).insert(TenantsCompanion.insert(
          name: name,
          phone: phone,
          nationalId: Value(_nullIfEmpty(nationalId)),
        ));
    await load();
  }

  Future<void> update(int id, String name, String phone, {String? nationalId}) async {
    await (_db.update(_db.tenants)..where((t) => t.id.equals(id))).write(TenantsCompanion(
      name: Value(name),
      phone: Value(phone),
      nationalId: Value(_nullIfEmpty(nationalId)),
    ));
    await load();
  }

  Future<void> softDelete(int id) async {
    await (_db.update(_db.tenants)..where((t) => t.id.equals(id)))
        .write(TenantsCompanion(deletedAt: Value(DateTime.now())));
    await load();
  }

  Tenant byId(int id) => tenants.firstWhere((t) => t.id == id);

  String? _nullIfEmpty(String? s) => (s == null || s.trim().isEmpty) ? null : s.trim();
}
