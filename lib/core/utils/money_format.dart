import 'package:intl/intl.dart';

class MoneyFormat {
  MoneyFormat._();

  static final _fmt = NumberFormat.decimalPattern('uz');

  /// 1234567 -> "1 234 567"
  static String amount(num value) => _fmt.format(value);

  /// 1234567 -> "1 234 567 so'm"
  static String sum(num value) => "${_fmt.format(value)} so'm";

  /// Compact "1.2M so'm" for small spaces.
  static String compactSum(num value) {
    if (value >= 1_000_000) {
      final v = value / 1_000_000;
      return "${v.toStringAsFixed(v >= 10 ? 0 : 1)}M so'm";
    }
    if (value >= 1000) {
      final v = value / 1000;
      return "${v.toStringAsFixed(v >= 10 ? 0 : 1)}K so'm";
    }
    return "${value.toInt()} so'm";
  }
}
