import 'package:get/get.dart';
import 'package:rental_project/core/services/storage_service.dart';
import 'package:rental_project/features/auth/data/models/user_model.dart';
import 'package:rental_project/features/auth/domain/entities/app_user.dart';
import 'package:rental_project/features/auth/domain/failures/auth_exception.dart';
import 'package:rental_project/features/auth/domain/repositories/auth_repository.dart';

/// Accounts + session persisted locally with GetStorage.
class AuthRepositoryImpl extends GetxService implements AuthRepository {
  AuthRepositoryImpl(this._storage) {
    _restore();
  }

  final StorageService _storage;

  static const _usersKey = 'auth_users';
  static const _sessionKey = 'auth_session'; // 'guest' | 'user:<id>'

  final List<UserModel> _users = [];
  AppUser? _current;
  bool _guest = false;

  @override
  AppUser? get currentUser => _current;
  @override
  bool get isGuest => _guest;
  @override
  bool get hasSession => _current != null || _guest;

  void _restore() {
    final raw = _storage.read<List>(_usersKey) ?? const [];
    for (final e in raw) {
      _users.add(UserModel.fromJson(Map<String, dynamic>.from(e as Map)));
    }
    final session = _storage.read<String>(_sessionKey);
    if (session == 'guest') {
      _guest = true;
    } else if (session != null && session.startsWith('user:')) {
      _current = _byId(session.substring(5));
    }
  }

  UserModel? _byId(String id) {
    for (final u in _users) {
      if (u.id == id) return u;
    }
    return null;
  }

  UserModel? _byPhone(String phone) {
    for (final u in _users) {
      if (u.phone == phone) return u;
    }
    return null;
  }

  @override
  Future<AppUser> register({
    required String name,
    required String phone,
    required String password,
    required UserRole role,
  }) async {
    if (_byPhone(phone) != null) {
      throw const AuthException(AuthFailure.phoneExists);
    }
    final user = UserModel(
      id: DateTime.now().microsecondsSinceEpoch.toString(),
      name: name,
      phone: phone,
      password: password,
      role: role,
    );
    _users.add(user);
    await _storage.write(_usersKey, _users.map((u) => u.toJson()).toList());
    await _startSession(user);
    return user;
  }

  @override
  Future<AppUser> login({required String phone, required String password}) async {
    final user = _byPhone(phone);
    if (user == null || user.password != password) {
      throw const AuthException(AuthFailure.wrongCredentials);
    }
    await _startSession(user);
    return user;
  }

  Future<void> _startSession(UserModel user) async {
    _current = user;
    _guest = false;
    await _storage.write(_sessionKey, 'user:${user.id}');
  }

  @override
  Future<void> enterGuest() async {
    _current = null;
    _guest = true;
    await _storage.write(_sessionKey, 'guest');
  }

  @override
  Future<void> logout() async {
    _current = null;
    _guest = false;
    await _storage.remove(_sessionKey);
  }
}
