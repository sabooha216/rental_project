import 'package:flutter/material.dart';
import 'package:get/get.dart';

void toast(String message) =>
    Get.snackbar('app_title'.tr, message, snackPosition: SnackPosition.BOTTOM);

/// Generic text form dialog. Returns the entered values, or null if cancelled.
/// [initial] pre-fills the fields (used for editing).
Future<List<String>?> askText(String titleKey, List<String> labelKeys,
    {List<bool>? numeric, List<String>? initial}) {
  final ctls = [
    for (int i = 0; i < labelKeys.length; i++)
      TextEditingController(text: (initial != null && i < initial.length) ? initial[i] : ''),
  ];
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

/// Yes/no confirmation dialog.
Future<bool> confirm(String message) async {
  final r = await Get.dialog<bool>(AlertDialog(
    content: Text(message),
    actions: [
      TextButton(onPressed: () => Get.back(result: false), child: Text('cancel'.tr)),
      FilledButton(onPressed: () => Get.back(result: true), child: Text('confirm'.tr)),
    ],
  ));
  return r ?? false;
}
