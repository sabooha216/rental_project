String money(double v) => v.toStringAsFixed(2);

String fmtDate(DateTime t) =>
    '${t.year}-${t.month.toString().padLeft(2, '0')}-${t.day.toString().padLeft(2, '0')}';

/// Simple in-memory id generator (replaced by DB ids later).
class IdGen {
  static int _i = 0;
  static int next() => ++_i;
}
