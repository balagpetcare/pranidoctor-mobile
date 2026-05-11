import 'package:pranidoctor_mobile/src/features/ai_technician_application/data/ai_technician_models.dart';

/// Placeholder when per-stage request counts are not on the dashboard payload.
const String kAiTechnicianDashboardUnavailableMark = '—';

/// Client-side profile completeness (0–100). Does not change API contract.
int aiTechnicianProfileCompletionPercent(AiTechnicianProfile profile) {
  var score = 0;
  const total = 6;
  if (profile.displayName?.trim().isNotEmpty ?? false) score++;
  if (profile.phone?.trim().isNotEmpty ?? false) score++;
  if ((profile.district?.trim().isNotEmpty ?? false) &&
      (profile.upazila?.trim().isNotEmpty ?? false)) {
    score++;
  }
  if (profile.divisionCoverageAreas.isNotEmpty) score++;
  final types = profile.documents.map((d) => d.type).toSet();
  if (types.contains('NID_FRONT') && types.contains('NID_BACK')) score++;
  if (types.contains('TRAINING_CERTIFICATE') ||
      types.contains('AI_CERTIFICATE')) {
    score++;
  }
  return ((score / total) * 100).round().clamp(0, 100);
}

String aiTechnicianProviderStatusLabelBn(String code) {
  return AiTechnicianStatusCopy.providerStatusBn(code);
}

String aiTechnicianServiceAreaLine(AiTechnicianProfile profile) {
  if (profile.divisionCoverageAreas.isNotEmpty) {
    final a = profile.divisionCoverageAreas.first;
    final u = a.unionOrArea?.trim();
    if (u != null && u.isNotEmpty) {
      return '${a.district}, ${a.upazila} · $u';
    }
    return '${a.district}, ${a.upazila}';
  }
  final d = profile.district?.trim();
  final up = profile.upazila?.trim();
  if (d != null && d.isNotEmpty && up != null && up.isNotEmpty) {
    final u = profile.unionOrArea?.trim();
    if (u != null && u.isNotEmpty) return '$d, $up · $u';
    return '$d, $up';
  }
  return 'সেবা এলাকা এখনও পূর্ণ হয়নি';
}

String aiTechnicianShortUpdatedLabel(String iso) {
  if (iso.length >= 10) return iso.substring(0, 10);
  if (iso.isEmpty) return 'তথ্য নেই';
  return iso;
}

/// Prefer server aggregate when present; else derive mean from recent snippets only.
double? aiTechnicianEffectiveRatingAverage({
  required double? dashboardRatingAverage,
  required List<AiTechnicianReviewSnippet> recentReviews,
}) {
  if (dashboardRatingAverage != null) return dashboardRatingAverage;
  if (recentReviews.isEmpty) return null;
  final sum = recentReviews.fold<int>(0, (a, r) => a + r.rating);
  return sum / recentReviews.length;
}

/// Heuristic using dashboard totals only (no extra API).
/// TODO(backend): Dedicated completion / SLA metrics when product defines them.
String? aiTechnicianCompletionRatePercentLabel({
  required int completedServicesCount,
  required int pendingRequestsCount,
}) {
  final den = completedServicesCount + pendingRequestsCount;
  if (den <= 0) return null;
  final pct = ((completedServicesCount / den) * 100).round().clamp(0, 100);
  return '$pct%';
}
