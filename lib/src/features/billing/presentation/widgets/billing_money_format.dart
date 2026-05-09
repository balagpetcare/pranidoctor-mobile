import 'package:intl/intl.dart';

/// Whole-taka display with grouping (labels remain Bengali in widgets).
String formatTakaAmount(double? value, {bool showDashWhenNull = true}) {
  if (value == null) {
    return showDashWhenNull ? '—' : '';
  }
  final fmt = NumberFormat('#,##0', 'en_IN');
  return '${fmt.format(value.round())} টাকা';
}
