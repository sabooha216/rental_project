import 'package:get/get.dart';
import 'package:rental_project/features/auth/domain/entities/app_user.dart';
import 'package:rental_project/features/auth/domain/repositories/auth_repository.dart';

/// Demonstrates StateMixin: loading / success / empty (guest) / error.
class ProfileController extends GetxController with StateMixin<AppUser> {
  ProfileController(this._repo);
  final AuthRepository _repo;

  @override
  void onInit() {
    super.onInit();
    load();
  }

  Future<void> load() async {
    change(null, status: RxStatus.loading());
    try {
      await Future.delayed(const Duration(milliseconds: 300));
      final u = _repo.currentUser;
      if (u == null) {
        change(null, status: RxStatus.empty());
      } else {
        change(u, status: RxStatus.success());
      }
    } catch (e) {
      change(null, status: RxStatus.error(e.toString()));
    }
  }
}
