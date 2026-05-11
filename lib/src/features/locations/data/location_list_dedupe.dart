import 'package:pranidoctor_mobile/src/features/locations/data/location_models.dart';

/// Collapses API rows that repeat the same [MobileLocationDto.displayLabelBn]
/// under the same logical parent scope (e.g. same district when listing upazilas).
///
/// Does **not** merge areas that share a name under different parents — use a
/// distinct [parentScopeKey] per parent (district id, district+upazila, etc.).
///
/// When duplicates disagree on [MobileLocationDto.id], keeps the lexicographically
/// smallest id for stability.
List<MobileLocationDto> dedupeMobileLocationsForParentScope(
  List<MobileLocationDto> raw,
  String parentScopeKey,
) {
  final byKey = <String, MobileLocationDto>{};
  for (final item in raw) {
    final label = item.displayLabelBn.trim().toLowerCase();
    if (label.isEmpty) continue;
    final composite = '$parentScopeKey|§|$label';
    final existing = byKey[composite];
    if (existing == null) {
      byKey[composite] = item;
    } else if (item.id.compareTo(existing.id) < 0) {
      byKey[composite] = item;
    }
  }
  final out = byKey.values.toList()
    ..sort((a, b) => a.displayLabelBn.compareTo(b.displayLabelBn));
  return out;
}
