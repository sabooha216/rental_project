import 'package:rental_project/core/utils/phone.dart';
import 'package:rental_project/features/auth/domain/entities/app_user.dart';
import 'package:rental_project/features/auth/domain/repositories/auth_repository.dart';

class RegisterUseCase {
  const RegisterUseCase(this._repo);
  final AuthRepository _repo;

  Future<AppUser> call({
    required String name,
    required String phone,
    required String password,
    required UserRole role,
  }) =>
      _repo.register(
        name: name.trim(),
        phone: normalizePhone(phone),
        password: password,
        role: role,
      );
}
