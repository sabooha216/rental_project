import 'package:rental_project/features/auth/domain/entities/app_user.dart';

/// JSON mapping of [AppUser] for local storage.
class UserModel extends AppUser {
  const UserModel({
    required super.id,
    required super.name,
    required super.phone,
    required super.password,
    required super.role,
  });

  factory UserModel.fromEntity(AppUser u) => UserModel(
        id: u.id,
        name: u.name,
        phone: u.phone,
        password: u.password,
        role: u.role,
      );

  factory UserModel.fromJson(Map<String, dynamic> j) => UserModel(
        id: j['id'] as String,
        name: j['name'] as String,
        phone: j['phone'] as String,
        password: j['password'] as String,
        role: UserRole.values.firstWhere(
          (r) => r.name == j['role'],
          orElse: () => UserRole.owner,
        ),
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'phone': phone,
        'password': password,
        'role': role.name,
      };
}
