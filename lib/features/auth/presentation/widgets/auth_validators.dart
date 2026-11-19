import 'package:get/get.dart';
import 'package:rental_project/core/utils/phone.dart';

abstract class AuthValidators {
  static String? required(String? v) =>
      (v == null || v.trim().isEmpty) ? 'required'.tr : null;

  static String? name(String? v) {
    if (v == null || v.trim().isEmpty) return 'required'.tr;
    return v.trim().length < 2 ? 'invalid_name'.tr : null;
  }

  static String? phone(String? v) {
    if (v == null || v.trim().isEmpty) return 'required'.tr;
    final p = normalizePhone(v);
    return RegExp(r'^\d{9,15}$').hasMatch(p) ? null : 'invalid_phone'.tr;
  }

  static String? password(String? v) {
    if (v == null || v.isEmpty) return 'required'.tr;
    return v.length < 6 ? 'short_password'.tr : null;
  }

  static String? Function(String?) confirm(String Function() original) =>
      (v) {
        if (v == null || v.isEmpty) return 'required'.tr;
        return v == original() ? null : 'password_mismatch'.tr;
      };
}
