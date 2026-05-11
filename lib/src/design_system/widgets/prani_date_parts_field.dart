import 'package:flutter/material.dart';

import 'package:pranidoctor_mobile/src/design_system/prani_tokens.dart';
import 'package:pranidoctor_mobile/src/design_system/widgets/prani_form_tokens.dart';

/// Optional or required birth date as **দিন / মাস / বছর** dropdowns — stores **`YYYY-MM-DD`** when complete.
///
/// Invalid calendar dates (e.g. ৩১ এপ্রিল) show a Bengali error; leap years handled.
class PraniDatePartsField extends StatefulWidget {
  const PraniDatePartsField({
    super.key,
    required this.onIsoChanged,
    this.initialIso,
    this.enabled = true,
    this.optional = true,
    this.label = 'জন্মতারিখ',
    this.helperText,
    this.onBlockingValidationChanged,
  });

  /// ISO `YYYY-MM-DD`, or `null` / empty = unset.
  final String? initialIso;

  /// Called when the logical date changes — empty components ⇒ `null` for API.
  final ValueChanged<String?> onIsoChanged;

  /// `true` when the user must fix day/month/year (partial selection or invalid date).
  final ValueChanged<bool>? onBlockingValidationChanged;

  final bool enabled;
  final bool optional;
  final String label;
  final String? helperText;

  @override
  State<PraniDatePartsField> createState() => _PraniDatePartsFieldState();
}

class _PraniDatePartsFieldState extends State<PraniDatePartsField> {
  int? _month;
  int? _day;
  int? _year;
  String? _fieldError;

  static const _monthBn = <String>[
    '',
    'জানুয়ারি',
    'ফেব্রুয়ারি',
    'মার্চ',
    'এপ্রিল',
    'মে',
    'জুন',
    'জুলাই',
    'আগস্ট',
    'সেপ্টেম্বর',
    'অক্টোবর',
    'নভেম্বর',
    'ডিসেম্বর',
  ];

  @override
  void initState() {
    super.initState();
    _parseIso(widget.initialIso);
    _fieldError = _evaluateDate().$2;
  }

  @override
  void didUpdateWidget(PraniDatePartsField oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.initialIso != widget.initialIso) {
      String? err;
      setState(() {
        _parseIso(widget.initialIso);
        final r = _evaluateDate();
        err = r.$2;
        _fieldError = err;
      });
      widget.onBlockingValidationChanged?.call(err != null);
    }
  }

  void _parseIso(String? iso) {
    final t = iso?.trim() ?? '';
    if (t.length >= 10) {
      final y = int.tryParse(t.substring(0, 4));
      final mo = int.tryParse(t.substring(5, 7));
      final d = int.tryParse(t.substring(8, 10));
      if (y != null && mo != null && d != null && _isValidDate(y, mo, d)) {
        _year = y;
        _month = mo;
        _day = d;
        return;
      }
    }
    _month = null;
    _day = null;
    _year = null;
  }

  static bool _isValidDate(int y, int m, int d) {
    if (m < 1 || m > 12) return false;
    if (d < 1 || d > 31) return false;
    try {
      final dt = DateTime(y, m, d);
      return dt.year == y && dt.month == m && dt.day == d;
    } catch (_) {
      return false;
    }
  }

  static int _daysInMonth(int y, int m) {
    if (m == 2) {
      final leap = (y % 4 == 0 && y % 100 != 0) || (y % 400 == 0);
      return leap ? 29 : 28;
    }
    const m30 = <int>{4, 6, 9, 11};
    if (m30.contains(m)) return 30;
    return 31;
  }

  int _filledCount() {
    var n = 0;
    if (_day != null) n++;
    if (_month != null) n++;
    if (_year != null) n++;
    return n;
  }

  /// ISO string (or `null`) and Bengali [error] message (or `null` if OK).
  (String?, String?) _evaluateDate() {
    final n = _filledCount();
    if (n == 0) {
      if (widget.optional) return (null, null);
      return (null, 'জন্মতারিখের দিন, মাস ও বছর তিনটিই নির্বাচন করুন।');
    }
    if (n < 3) {
      return (null, 'দিন, মাস ও বছর তিনটিই নির্বাচন করুন অথবা সব খালি রাখুন।');
    }
    if (!_isValidDate(_year!, _month!, _day!)) {
      return (
        null,
        'এই তারিখটি বৈধ নয় (মাস অনুযায়ী দিন ও অধিবর্ষ মিলিয়ে নিন)।',
      );
    }
    final iso =
        '${_year.toString().padLeft(4, '0')}-'
        '${_month.toString().padLeft(2, '0')}-'
        '${_day.toString().padLeft(2, '0')}';
    return (iso, null);
  }

  void _setMonth(int? v) {
    String? iso;
    String? err;
    setState(() {
      _month = v;
      if (_year != null && _month != null && _day != null) {
        final cap = _daysInMonth(_year!, _month!);
        if (_day! > cap) _day = cap;
      }
      final r = _evaluateDate();
      iso = r.$1;
      err = r.$2;
      _fieldError = err;
    });
    widget.onIsoChanged(iso);
    widget.onBlockingValidationChanged?.call(err != null);
  }

  void _setDay(int? v) {
    String? iso;
    String? err;
    setState(() {
      _day = v;
      final r = _evaluateDate();
      iso = r.$1;
      err = r.$2;
      _fieldError = err;
    });
    widget.onIsoChanged(iso);
    widget.onBlockingValidationChanged?.call(err != null);
  }

  void _setYear(int? v) {
    String? iso;
    String? err;
    setState(() {
      _year = v;
      if (_year != null && _month != null && _day != null) {
        final cap = _daysInMonth(_year!, _month!);
        if (_day! > cap) _day = cap;
      }
      final r = _evaluateDate();
      iso = r.$1;
      err = r.$2;
      _fieldError = err;
    });
    widget.onIsoChanged(iso);
    widget.onBlockingValidationChanged?.call(err != null);
  }

  List<int> _dayChoices() {
    if (_year != null && _month != null) {
      final n = _daysInMonth(_year!, _month!);
      return List<int>.generate(n, (i) => i + 1);
    }
    return List<int>.generate(31, (i) => i + 1);
  }

  InputDecoration _dropdownDecoration(
    BuildContext context, {
    required String labelText,
  }) {
    final scheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    return InputDecoration(
      labelText: labelText,
      isDense: false,
      filled: true,
      fillColor: scheme.surfaceContainerLow,
      floatingLabelBehavior: FloatingLabelBehavior.auto,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
      constraints: const BoxConstraints(
        minHeight: PraniFormTokens.inputMinTouchHeight,
      ),
      labelStyle: PraniTextStyles.formLabel(
        scheme,
        textTheme,
      ).copyWith(fontSize: 14.5, height: 1.42),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(PraniRadius.md),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(PraniRadius.md),
        borderSide: BorderSide(color: scheme.outline.withValues(alpha: 0.65)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(PraniRadius.md),
        borderSide: BorderSide(color: scheme.primary, width: 2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final itemsYear = List<int>.generate(
      2015 - 1965 + 1,
      (i) => 1965 + i,
    ).reversed.toList();

    final dayField = DropdownButtonFormField<int>(
      isExpanded: true,
      // ignore: deprecated_member_use
      value: _day,
      style: PraniTextStyles.input(scheme, textTheme),
      decoration: _dropdownDecoration(context, labelText: 'দিন'),
      items: [
        const DropdownMenuItem<int>(value: null, child: Text('—')),
        for (final d in _dayChoices())
          DropdownMenuItem<int>(value: d, child: Text('$d')),
      ],
      onChanged: widget.enabled ? _setDay : null,
    );

    final monthField = DropdownButtonFormField<int>(
      isExpanded: true,
      // ignore: deprecated_member_use
      value: _month,
      style: PraniTextStyles.input(scheme, textTheme),
      decoration: _dropdownDecoration(context, labelText: 'মাস'),
      items: [
        const DropdownMenuItem<int>(value: null, child: Text('—')),
        for (var m = 1; m <= 12; m++)
          DropdownMenuItem<int>(
            value: m,
            child: Text(
              '${m.toString().padLeft(2, '0')} · ${_monthBn[m]}',
              overflow: TextOverflow.ellipsis,
            ),
          ),
      ],
      onChanged: widget.enabled ? _setMonth : null,
    );

    final yearField = DropdownButtonFormField<int>(
      isExpanded: true,
      // ignore: deprecated_member_use
      value: _year,
      style: PraniTextStyles.input(scheme, textTheme),
      decoration: _dropdownDecoration(context, labelText: 'বছর'),
      items: [
        const DropdownMenuItem<int>(value: null, child: Text('—')),
        for (final y in itemsYear)
          DropdownMenuItem<int>(value: y, child: Text('$y')),
      ],
      onChanged: widget.enabled ? _setYear : null,
    );

    return LayoutBuilder(
      builder: (context, constraints) {
        final narrow = constraints.maxWidth < 360;
        final pickers = narrow
            ? Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  dayField,
                  SizedBox(height: PraniFormTokens.fieldGap),
                  monthField,
                  SizedBox(height: PraniFormTokens.fieldGap),
                  yearField,
                ],
              )
            : Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(flex: 4, child: dayField),
                  SizedBox(width: PraniSpacing.sm),
                  Expanded(flex: 6, child: monthField),
                  SizedBox(width: PraniSpacing.sm),
                  Expanded(flex: 5, child: yearField),
                ],
              );

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              widget.optional
                  ? '${widget.label} (ঐচ্ছিক)'
                  : '${widget.label} *',
              style: PraniTextStyles.formLabel(
                scheme,
                textTheme,
              ).copyWith(fontWeight: FontWeight.w600),
            ),
            if (widget.helperText != null &&
                widget.helperText!.trim().isNotEmpty) ...[
              const SizedBox(height: PraniSpacing.xs),
              Text(
                widget.helperText!,
                style: PraniTextStyles.formHelper(scheme, textTheme),
              ),
            ],
            const SizedBox(height: PraniSpacing.sm),
            pickers,
            if (_fieldError != null) ...[
              const SizedBox(height: PraniSpacing.xs),
              Text(
                _fieldError!,
                style: PraniTextStyles.caption(
                  scheme,
                  textTheme,
                ).copyWith(color: scheme.error, height: 1.35),
              ),
            ],
          ],
        );
      },
    );
  }
}
