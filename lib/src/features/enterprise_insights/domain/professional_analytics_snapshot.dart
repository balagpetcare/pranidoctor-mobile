/// Aggregated professional analytics headline (server + derived preview fields).
class ProfessionalAnalyticsSnapshot {
  const ProfessionalAnalyticsSnapshot({
    required this.monthlyPerformanceBn,
    required this.serviceSuccessRateBn,
    required this.areaPerformanceBn,
    required this.revenueAnalyticsBn,
    required this.growthMetricsBn,
    this.footnoteBn,
  });

  final String monthlyPerformanceBn;
  final String serviceSuccessRateBn;
  final String areaPerformanceBn;
  final String revenueAnalyticsBn;
  final String growthMetricsBn;
  final String? footnoteBn;

  static const ProfessionalAnalyticsSnapshot empty = ProfessionalAnalyticsSnapshot(
    monthlyPerformanceBn: '—',
    serviceSuccessRateBn: '—',
    areaPerformanceBn: '—',
    revenueAnalyticsBn: '—',
    growthMetricsBn: '—',
    footnoteBn: 'এই রোলে বিশ্লেষণ উপলব্ধ নয়।',
  );
}
