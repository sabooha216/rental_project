import 'package:get/get.dart';
import 'package:rental_project/core/utils/formatters.dart';
import 'package:rental_project/features/tenants/domain/entities/tenant.dart';

class TenantsRepository {
  final tenants = <Tenant>[].obs;

  Tenant add(String name, String phone) {
    final t = Tenant(id: IdGen.next(), name: name, phone: phone);
    tenants.add(t);
    return t;
  }

  Tenant byId(int id) => tenants.firstWhere((t) => t.id == id);
}
