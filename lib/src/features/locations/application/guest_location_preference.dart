import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:pranidoctor_mobile/src/features/providers/application/provider_finder_providers.dart';

/// Persisted guest browsing location (upazila + union IDs from mobile locations API).
class GuestLocationState {
  const GuestLocationState({
    this.districtId,
    this.upazilaId,
    this.unionId,
    this.districtLabelBn = '',
    this.upazilaLabelBn = '',
    this.unionLabelBn = '',
    this.promptCompleted = false,
  });

  final String? districtId;
  final String? upazilaId;
  final String? unionId;
  final String districtLabelBn;
  final String upazilaLabelBn;
  final String unionLabelBn;

  /// After save or "এখন নয়" — do not auto-show the first-run sheet again.
  final bool promptCompleted;

  bool get hasSavedSelection =>
      unionId != null &&
      unionId!.trim().isNotEmpty &&
      upazilaId != null &&
      upazilaId!.trim().isNotEmpty;

  String get compactLocationLabelBn {
    if (!hasSavedSelection) return '';
    final u = unionLabelBn.trim();
    final z = upazilaLabelBn.trim();
    if (u.isEmpty && z.isEmpty) return 'এলাকা নির্বাচিত';
    if (z.isEmpty) return u;
    if (u.isEmpty) return z;
    return '$z · $u';
  }

  static GuestLocationState fromPrefs(SharedPreferences prefs) {
    return GuestLocationState(
      districtId: _nonEmpty(prefs.getString(_kDistrictId)),
      upazilaId: _nonEmpty(prefs.getString(_kUpazilaId)),
      unionId: _nonEmpty(prefs.getString(_kUnionId)),
      districtLabelBn: prefs.getString(_kDistrictLabel) ?? '',
      upazilaLabelBn: prefs.getString(_kUpazilaLabel) ?? '',
      unionLabelBn: prefs.getString(_kUnionLabel) ?? '',
      promptCompleted: prefs.getBool(_kPromptCompleted) ?? false,
    );
  }

  static String? _nonEmpty(String? s) {
    final t = s?.trim() ?? '';
    return t.isEmpty ? null : t;
  }

  static const _kDistrictId = 'pd_guest_district_id';
  static const _kUpazilaId = 'pd_guest_upazila_id';
  static const _kUnionId = 'pd_guest_union_id';
  static const _kDistrictLabel = 'pd_guest_district_label_bn';
  static const _kUpazilaLabel = 'pd_guest_upazila_label_bn';
  static const _kUnionLabel = 'pd_guest_union_label_bn';
  static const _kPromptCompleted = 'pd_guest_location_prompt_completed';
}

class GuestLocationNotifier extends AsyncNotifier<GuestLocationState> {
  @override
  Future<GuestLocationState> build() async {
    final prefs = await SharedPreferences.getInstance();
    return GuestLocationState.fromPrefs(prefs);
  }

  Future<void> saveSelection({
    required String districtId,
    required String upazilaId,
    required String unionId,
    required String districtLabelBn,
    required String upazilaLabelBn,
    required String unionLabelBn,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(GuestLocationState._kDistrictId, districtId.trim());
    await prefs.setString(GuestLocationState._kUpazilaId, upazilaId.trim());
    await prefs.setString(GuestLocationState._kUnionId, unionId.trim());
    await prefs.setString(
      GuestLocationState._kDistrictLabel,
      districtLabelBn.trim(),
    );
    await prefs.setString(
      GuestLocationState._kUpazilaLabel,
      upazilaLabelBn.trim(),
    );
    await prefs.setString(GuestLocationState._kUnionLabel, unionLabelBn.trim());
    await prefs.setBool(GuestLocationState._kPromptCompleted, true);
    final next = GuestLocationState(
      districtId: districtId.trim(),
      upazilaId: upazilaId.trim(),
      unionId: unionId.trim(),
      districtLabelBn: districtLabelBn.trim(),
      upazilaLabelBn: upazilaLabelBn.trim(),
      unionLabelBn: unionLabelBn.trim(),
      promptCompleted: true,
    );
    state = AsyncData(next);
    _applyAreaFilter(next);
  }

  Future<void> dismissPromptWithoutSaving() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(GuestLocationState._kPromptCompleted, true);
    final prev = state.maybeWhen(data: (v) => v, orElse: () => null);
    final base = prev ?? await future;
    final next = GuestLocationState(
      districtId: base.districtId,
      upazilaId: base.upazilaId,
      unionId: base.unionId,
      districtLabelBn: base.districtLabelBn,
      upazilaLabelBn: base.upazilaLabelBn,
      unionLabelBn: base.unionLabelBn,
      promptCompleted: true,
    );
    state = AsyncData(next);
  }

  /// Apply saved union as provider list `areaId` (backend union/area cuid).
  void applySavedLocationToProviderQueries() {
    final v = state.maybeWhen(data: (x) => x, orElse: () => null);
    if (v == null || !v.hasSavedSelection) return;
    _applyAreaFilter(v);
  }

  void _applyAreaFilter(GuestLocationState v) {
    if (!v.hasSavedSelection) return;
    final union = v.unionId!.trim();
    ref
        .read(doctorListQueryProvider.notifier)
        .apply(
          ref
              .read(doctorListQueryProvider)
              .withFilters(areaId: union, clearAreaSlug: true),
        );
    ref
        .read(technicianListQueryProvider.notifier)
        .apply(
          ref
              .read(technicianListQueryProvider)
              .withFilters(areaId: union, clearAreaSlug: true),
        );
  }
}

final guestLocationPreferenceProvider =
    AsyncNotifierProvider<GuestLocationNotifier, GuestLocationState>(
      GuestLocationNotifier.new,
    );
