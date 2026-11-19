import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';

/// Permanent service wrapping GetStorage (local key-value persistence).
class StorageService extends GetxService {
  /// Call once in main() before runApp.
  static Future<void> init() => GetStorage.init();

  /// Synchronous read usable before dependencies are registered (e.g. in main).
  static T? peek<T>(String key) => GetStorage().read<T>(key);

  final _box = GetStorage();

  T? read<T>(String key) => _box.read<T>(key);
  Future<void> write(String key, dynamic value) => _box.write(key, value);
  Future<void> remove(String key) => _box.remove(key);
}
