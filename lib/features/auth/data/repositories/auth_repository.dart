import 'package:get/get.dart';
import 'package:rental_project/features/auth/data/models/app_user.dart';

/// In-memory accounts store (same approach as the other repositories).
class AuthRepository extends GetxService {
  final users = <AppUser>[].obs;

  /// Signed-in user. `null` means guest / signed out.
  final current = Rxn<AppUser>();

  AppUser? findByPhone(String phone) =>
      users.firstWhereOrNull((u) => u.phone == phone);

  AppUser add({
    required String name,
    required String phone,
    required String password,
    required UserRole role,
  }) {
    final user = AppUser(
      id: DateTime.now().microsecondsSinceEpoch.toString(),
      name: name,
      phone: phone,
      password: password,
      role: role,
    );
    users.add(user);
    return user;
  }
}
