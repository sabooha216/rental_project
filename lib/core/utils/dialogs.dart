import 'package:flutter/material.dart';
import 'package:get/get.dart';

void toast(String message) =>
    Get.snackbar('app_title'.tr, message, snackPosition: SnackPosition.BOTTOM);

/// Generic text form dialog. Returns the entered values, or null if cancelled.
Future<List<String>?> askText(String titleKey, List<String> labelKeys,
    {List<bool>? numeric}) {
  final ctls = labelKeys.map((_) => TextEditingController()).toList();
  return Get.dialog<List<String>>(
    AlertDialog(
      title: Text(titleKey.tr),
      content: SingleChildScrollView(
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          for (int i = 0; i < labelKeys.length; i++)
            TextField(
              controller: ctls[i],
              decoration: InputDecoration(labelText: labelKeys[i].tr),
              keyboardType: (numeric != null && numeric[i])
                  ? const TextInputType.numberWithOptions(decimal: true)
                  : TextInputType.text,
            ),
        ]),
      ),
      actions: [
        TextButton(onPressed: () => Get.back(), child: Text('cancel'.tr)),
        FilledButton(
          onPressed: () => Get.back(result: ctls.map((e) => e.text.trim()).toList()),
          child: Text('save'.tr),
        ),
      ],
    ),
  );
}
