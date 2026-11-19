import 'package:rental_project/core/utils/phone.dart';
import 'package:rental_project/features/auth/domain/entities/app_user.dart';
import 'package:rental_project/features/auth/domain/repositories/auth_repository.dart';

class LoginUseCase {
  const LoginUseCase(this._repo);
  final AuthRepository _repo;

  Future<AppUser> call({required String phone, required String password}) =>
      _repo.login(phone: normalizePhone(phone), password: password);
}
