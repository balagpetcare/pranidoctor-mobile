/// Bangladesh mobile helpers for Prani Doctor API.
///
/// API body uses digits-only `8801XXXXXXXXX` (13 digits), no `+` prefix.
abstract final class BdPhone {
  /// Operator range after national trunk `01`: typically `01[3-9]`.
  static final RegExp _apiFormat = RegExp(r'^8801[3-9]\d{8}$');

  static String _digitsOnly(String input) =>
      input.replaceAll(RegExp(r'\D'), '');

  /// Returns `null` if the input cannot be normalized to a valid API phone.
  static String? normalizeToApiDigits(String input) {
    final d = _digitsOnly(input);
    if (d.isEmpty) return null;

    String candidate;
    if (d.startsWith('880') && d.length == 13) {
      candidate = d;
    } else if (d.startsWith('01') && d.length == 11) {
      candidate = '880${d.substring(1)}';
    } else if (d.startsWith('1') && d.length == 10) {
      candidate = '880$d';
    } else if (d.length == 11 && d.startsWith('0')) {
      candidate = '880${d.substring(1)}';
    } else {
      return null;
    }

    return _apiFormat.hasMatch(candidate) ? candidate : null;
  }

  static bool isValidApiDigits(String digits13) =>
      _apiFormat.hasMatch(digits13);

  /// Display mask: `01712 ••• •••` style (hides middle digits).
  static String maskForDisplay(String apiDigits13) {
    if (apiDigits13.length != 13 || !apiDigits13.startsWith('880')) {
      return apiDigits13;
    }
    final local = '0${apiDigits13.substring(3)}';
    if (local.length != 11) return apiDigits13;
    return '${local.substring(0, 5)} ••• •••';
  }
}
