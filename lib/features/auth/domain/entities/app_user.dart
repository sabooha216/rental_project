enum UserRole {
  owner,
  manager;

  /// translation key, e.g. role_owner
  String get labelKey => 'role_$name';
}

class AppUser {
  const AppUser({
    required this.id,
    required this.name,
    required this.phone,
    required this.password,
    required this.role,
  });

  final String id;
  final String name;
  final String phone;
  final String password; // TODO: hash / move to server side auth
  final UserRole role;
}
