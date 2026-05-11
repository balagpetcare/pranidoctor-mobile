import 'package:pranidoctor_mobile/src/features/ai_technician_application/data/ai_technician_models.dart';
import 'package:pranidoctor_mobile/src/features/enterprise_insights/domain/professional_analytics_snapshot.dart';
import 'package:pranidoctor_mobile/src/features/profile/data/dashboard_context_models.dart';

ProfessionalAnalyticsSnapshot mapTechnicianAnalytics(
  AiTechnicianDashboardData d,
) {
  final monthlyDone = d.monthlyCompletedCount;
  final monthlyEarn = d.monthlyEarningsBdt;
  final monthlyReq = d.monthlyNewRequestsCount;
  final monthlyBn = <String>[
    if (monthlyDone != null) 'সম্পন্ন: $monthlyDone',
    if (monthlyReq != null) 'নতুন অনুরোধ: $monthlyReq',
    if (monthlyEarn != null && monthlyEarn.trim().isNotEmpty)
      'আয়: ৳$monthlyEarn',
  ].join(' · ');
  final monthlyPerformanceBn = monthlyBn.isEmpty
      ? 'মাসিক সারি এখনও সম্পূর্ণ নয়। মোট সম্পন্ন সেবা: ${d.completedServicesCount}।'
      : monthlyBn;

  final total = d.completedServicesCount + d.pendingRequestsCount;
  final successPct =
      total > 0 ? (100 * d.completedServicesCount / total).round() : null;
  final serviceSuccessRateBn = successPct != null
      ? '$successPct% (সম্পন্ন বনাম অপেক্ষমাণ অনুরোধ)'
      : 'হার গণনার জন্য যথেষ্ট ডেটা নেই।';

  final nearby = d.nearbyFarmersCount;
  final areaPerformanceBn = nearby != null
      ? 'কাছাকাছি কৃষক সংকেত: $nearby (এলাকা ভিত্তিক বিস্তারিত API-তে)'
      : 'এলাকা ভিত্তিক গভীর মেট্রিক্স সার্ভার আপডেটের সাথে যুক্ত হবে।';

  final revenueAnalyticsBn =
      'মোট আয় (৳): ${d.totalEarningsBdt} · সক্রিয় সেবা: ${d.activeServices.length}';

  final repeat = d.repeatClientsCount;
  final growthMetricsBn = repeat != null
      ? 'পুনরায় সেবা গ্রাহক: $repeat'
      : 'বৃদ্ধি / পুনরাবৃত্তি মেট্রিক্স শীঘ্রই।';

  return ProfessionalAnalyticsSnapshot(
    monthlyPerformanceBn: monthlyPerformanceBn,
    serviceSuccessRateBn: serviceSuccessRateBn,
    areaPerformanceBn: areaPerformanceBn,
    revenueAnalyticsBn: revenueAnalyticsBn,
    growthMetricsBn: growthMetricsBn,
    footnoteBn: 'উৎস: এআই টেকনিশিয়ান ড্যাশবোর্ড। অফলাইন ক্যাশে সজ্জিত।',
  );
}

ProfessionalAnalyticsSnapshot mapDoctorDashboardAnalytics(
  DashboardContext ctx,
) {
  final doctor = ctx.doctor;
  if (doctor == null) {
    return const ProfessionalAnalyticsSnapshot(
      monthlyPerformanceBn: '—',
      serviceSuccessRateBn: '—',
      areaPerformanceBn: '—',
      revenueAnalyticsBn: '—',
      growthMetricsBn: '—',
      footnoteBn: 'চিকিৎসক স্লাইস নেই। ড্যাশবোর্ড কনটেক্সট রিফ্রেশ করুন।',
    );
  }

  final monthlyPerformanceBn = <String>[
    if (doctor.prescriptionsIssuedThisMonth != null)
      'মাসিক প্রেসক্রিপশন: ${doctor.prescriptionsIssuedThisMonth}',
    if (doctor.earningsThisMonthBdt != null)
      'মাসিক আয় (৳): ${doctor.earningsThisMonthBdt!.toStringAsFixed(0)}',
    if (doctor.completedAppointmentsThisWeek != null)
      'সপ্তাহে সম্পন্ন অ্যাপয়েন্টমেন্ট: ${doctor.completedAppointmentsThisWeek}',
  ].join(' · ');
  final monthlyBn = monthlyPerformanceBn.isEmpty
      ? 'মাসিক সূচক এখনও সার্ভার থেকে সীমিত।'
      : monthlyPerformanceBn;

  final pending = doctor.pendingPrescriptionsCount;
  final issued = doctor.prescriptionsIssuedThisMonth;
  String successBn;
  if (pending != null && issued != null && (pending + issued) > 0) {
    final pct = (100 * issued / (pending + issued)).round();
    successBn =
        '$pct% (ইস্যুকৃত বনাম অপেক্ষমাণ প্রেসক্রিপশন — আনুমানিক সূচক)';
  } else if (doctor.rating.count > 0 && doctor.rating.average != null) {
    successBn =
        'রিভিউ গড় ${doctor.rating.average!.toStringAsFixed(1)} (${doctor.rating.count}টি)';
  } else {
    successBn = 'সেবা সাফল্যের হার সার্ভার মেট্রিক্সের সাথে আসবে।';
  }

  final spec = doctor.specialty?.trim();
  final areaPerformanceBn = spec != null && spec.isNotEmpty
      ? 'বিশেষতা: $spec · টেলিমেডিসিন: ${doctor.telemedicineCapable ? 'সক্রিয়' : 'নয়'}'
      : 'এলাকা / কভারেজ বিশ্লেষণ শীঘ্রই।';

  final rev = doctor.earningsThisMonthBdt;
  final revenueAnalyticsBn = rev != null
      ? 'মাসিক আয় (৳): ${rev.toStringAsFixed(0)}'
      : 'আয় ডেটা এখনও পাওয়া যায়নি।';

  final growth = doctor.followUpCasesCount;
  final completedWeek = doctor.completedAppointmentsThisWeek;
  final growthMetricsBn = [
    if (growth != null) 'ফলো-আপ কেস: $growth',
    if (completedWeek != null) 'সপ্তাহে সম্পন্ন: $completedWeek',
  ].join(' · ');
  final growthBn =
      growthMetricsBn.isEmpty ? 'বৃদ্ধি ট্রেন্ড শীঘ্রই।' : growthMetricsBn;

  return ProfessionalAnalyticsSnapshot(
    monthlyPerformanceBn: monthlyBn,
    serviceSuccessRateBn: successBn,
    areaPerformanceBn: areaPerformanceBn,
    revenueAnalyticsBn: revenueAnalyticsBn,
    growthMetricsBn: growthBn,
    footnoteBn: 'উৎস: প্রোফাইল ড্যাশবোর্ড কনটেক্সট (চিকিৎসক)।',
  );
}
