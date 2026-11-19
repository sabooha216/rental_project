/// Converts Arabic-Indic digits to latin and strips spaces, dashes and '+'.
String normalizePhone(String raw) {
  const arabic = '٠١٢٣٤٥٦٧٨٩';
  final b = StringBuffer();
  for (final c in raw.split('')) {
    final i = arabic.indexOf(c);
    b.write(i >= 0 ? '$i' : c);
  }
  return b.toString().replaceAll(RegExp(r'[\s\-+]'), '');
}
