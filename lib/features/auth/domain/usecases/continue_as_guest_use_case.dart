import 'package:rental_project/features/auth/domain/repositories/auth_repository.dart';

class ContinueAsGuestUseCase {
  const ContinueAsGuestUseCase(this._repo);
  final AuthRepository _repo;

  Future<void> call() => _repo.enterGuest();
}
