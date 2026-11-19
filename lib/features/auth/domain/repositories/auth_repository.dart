import 'package:rental_project/features/auth/domain/entities/app_user.dart';

/// Contract implemented by the data layer.
abstract class AuthRepository {
  AppUser? get currentUser;
  bool get isGuest;

  /// A signed-in account or guest mode.
  bool get hasSession;

  /// Throws [AuthException] when the phone is already registered.
  Future<AppUser> register({
    required String name,
    required String phone,
    required String password,
    required UserRole role,
  });

  /// Throws [AuthException] on wrong phone / password.
  Future<AppUser> login({required String phone, required String password});

  Future<void> enterGuest();
  Future<void> logout();
}
