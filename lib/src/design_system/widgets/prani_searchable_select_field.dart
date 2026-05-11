import 'package:dio/dio.dart';
import 'package:flutter/material.dart';

import '../../core/network/dio_user_message.dart';
import '../../core/network/mobile_api_envelope.dart';
import '../../core/network/network_messages.dart';
import '../prani_tokens.dart';
import 'prani_error_state.dart';
import 'prani_loading_state.dart';
import 'prani_search_field.dart';

/// Tappable field that opens a searchable bottom sheet list (Bengali-first).
///
/// Uses [PraniSpacing], [PraniRadius], and theme colors only.
class PraniSearchableSelectField<T> extends StatelessWidget {
  const PraniSearchableSelectField({
    super.key,
    required this.label,
    required this.hintEmpty,
    required this.enabled,
    required this.selectedItem,
    required this.displayBuilder,
    required this.loadItems,
    this.filter,
    this.onChanged,
    this.sheetTitle,
    this.emptyListMessage,
  });

  final String label;
  final String hintEmpty;
  final bool enabled;
  final T? selectedItem;
  final String Function(T item) displayBuilder;
  final Future<List<T>> Function() loadItems;
  final bool Function(T item, String query)? filter;
  final ValueChanged<T?>? onChanged;
  final String? sheetTitle;

  /// When the loaded list is empty (no search query). Defaults to a generic line.
  final String? emptyListMessage;

  bool _defaultFilter(T item, String q) {
    if (q.isEmpty) return true;
    return displayBuilder(item).toLowerCase().contains(q.trim().toLowerCase());
  }

  Future<void> _openSheet(BuildContext context) async {
    if (!enabled) return;
    final scheme = Theme.of(context).colorScheme;
    final picked = await showModalBottomSheet<T>(
      context: context,
      isScrollControlled: true,
      backgroundColor: scheme.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(PraniRadius.lg),
        ),
      ),
      builder: (ctx) {
        return _PraniSearchableSelectSheetBody<T>(
          title: sheetTitle ?? label,
          loadItems: loadItems,
          displayBuilder: displayBuilder,
          filter: filter ?? _defaultFilter,
          emptyListMessage: emptyListMessage,
        );
      },
    );
    if (picked != null && context.mounted) {
      onChanged?.call(picked);
    }
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final sel = selectedItem;
    final has = sel != null;
    final displayText = has ? displayBuilder(sel) : hintEmpty;
    final labelStyle = textTheme.bodySmall?.copyWith(
      color: scheme.onSurfaceVariant,
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(label, style: labelStyle),
        const SizedBox(height: PraniSpacing.xs),
        Material(
          color: scheme.surfaceContainerHighest.withValues(alpha: 0.35),
          borderRadius: BorderRadius.circular(PraniRadius.md),
          child: InkWell(
            onTap: enabled ? () => _openSheet(context) : null,
            borderRadius: BorderRadius.circular(PraniRadius.md),
            child: Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: PraniSpacing.md,
                vertical: PraniSpacing.md,
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      displayText,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: textTheme.bodyLarge?.copyWith(
                        color: has ? scheme.onSurface : scheme.onSurfaceVariant,
                      ),
                    ),
                  ),
                  Icon(
                    Icons.keyboard_arrow_down_rounded,
                    color: enabled
                        ? scheme.onSurfaceVariant
                        : scheme.onSurface.withValues(alpha: 0.38),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _PraniSearchableSelectSheetBody<T> extends StatefulWidget {
  const _PraniSearchableSelectSheetBody({
    required this.title,
    required this.loadItems,
    required this.displayBuilder,
    required this.filter,
    this.emptyListMessage,
  });

  final String title;
  final Future<List<T>> Function() loadItems;
  final String Function(T item) displayBuilder;
  final bool Function(T item, String query) filter;
  final String? emptyListMessage;

  @override
  State<_PraniSearchableSelectSheetBody<T>> createState() =>
      _PraniSearchableSelectSheetBodyState<T>();
}

class _PraniSearchableSelectSheetBodyState<T>
    extends State<_PraniSearchableSelectSheetBody<T>> {
  final _search = TextEditingController();
  List<T>? _items;
  Object? _error;
  String _query = '';

  @override
  void initState() {
    super.initState();
    _load();
  }

  @override
  void dispose() {
    _search.dispose();
    super.dispose();
  }

  static String _messageForError(Object e) {
    if (e is MobileApiEnvelopeException) return e.message;
    if (e is DioException) {
      return userFacingDioMessageBn(e, debugLabel: 'select-sheet');
    }
    return NetworkMessages.bnGenericRequestFailed;
  }

  Future<void> _load() async {
    setState(() {
      _error = null;
      _items = null;
    });
    try {
      final list = await widget.loadItems();
      if (mounted) setState(() => _items = list);
    } catch (e, st) {
      assert(() {
        debugPrint('PraniSearchableSelectField load failed: $e\n$st');
        return true;
      }());
      if (mounted) setState(() => _error = e);
    }
  }

  void _retry() => _load();

  List<T> _filtered() {
    final all = _items ?? const [];
    return all.where((e) => widget.filter(e, _query)).toList();
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final mq = MediaQuery.of(context);
    final maxH = (mq.size.height * 0.85 - mq.viewInsets.bottom).clamp(
      220.0,
      mq.size.height,
    );

    return SafeArea(
      child: Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.viewInsetsOf(context).bottom,
        ),
        child: SizedBox(
          height: maxH,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(
                  PraniSpacing.xl,
                  PraniSpacing.md,
                  PraniSpacing.xl,
                  PraniSpacing.sm,
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        widget.title,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: Theme.of(context).textTheme.titleMedium
                            ?.copyWith(fontWeight: FontWeight.w600),
                      ),
                    ),
                    IconButton(
                      tooltip: 'বন্ধ',
                      onPressed: () => Navigator.of(context).pop(),
                      icon: const Icon(Icons.close_rounded),
                    ),
                  ],
                ),
              ),
              const Divider(height: 1),
              Padding(
                padding: const EdgeInsets.fromLTRB(
                  PraniSpacing.xl,
                  PraniSpacing.sm,
                  PraniSpacing.xl,
                  PraniSpacing.md,
                ),
                child: PraniSearchField(
                  controller: _search,
                  hintText: 'খুঁজুন…',
                  onChanged: (v) => setState(() => _query = v),
                ),
              ),
              Expanded(
                child: Builder(
                  builder: (context) {
                    if (_error != null) {
                      return Center(
                        child: SingleChildScrollView(
                          padding: const EdgeInsets.all(PraniSpacing.xl),
                          child: PraniErrorState(
                            title: 'লোড ব্যর্থ',
                            message: _messageForError(_error!),
                            retryLabel: 'আবার চেষ্টা',
                            onRetry: _retry,
                            detail: null,
                            compact: false,
                            boxed: true,
                          ),
                        ),
                      );
                    }
                    if (_items == null) {
                      return const Center(
                        child: PraniLoadingState(
                          message: 'লোড হচ্ছে…',
                          compact: false,
                        ),
                      );
                    }
                    final rows = _filtered();
                    if (rows.isEmpty) {
                      return Center(
                        child: Text(
                          _query.isEmpty
                              ? (widget.emptyListMessage ?? 'কোনো ফল নেই')
                              : 'আপনার অনুসন্ধানে কিছু মেলেনি',
                          textAlign: TextAlign.center,
                          style: Theme.of(context).textTheme.bodyMedium
                              ?.copyWith(color: scheme.onSurfaceVariant),
                        ),
                      );
                    }
                    return ListView.separated(
                      padding: const EdgeInsets.fromLTRB(
                        PraniSpacing.xl,
                        0,
                        PraniSpacing.xl,
                        PraniSpacing.xl,
                      ),
                      itemCount: rows.length,
                      separatorBuilder: (context, index) =>
                          const Divider(height: 1),
                      itemBuilder: (context, i) {
                        final item = rows[i];
                        return ListTile(
                          contentPadding: EdgeInsets.zero,
                          title: Text(
                            widget.displayBuilder(item),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                          onTap: () => Navigator.of(context).pop(item),
                        );
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
