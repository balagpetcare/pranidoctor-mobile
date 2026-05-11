import 'package:pranidoctor_mobile/src/features/ai_technician_application/data/ai_technician_models.dart';
import 'package:pranidoctor_mobile/src/features/profile/data/dashboard_context_models.dart';
import 'package:pranidoctor_mobile/src/features/professional_finance/domain/professional_finance_types.dart';

double? _parseMoney(String? raw) {
  if (raw == null) return null;
  final t = raw.trim();
  if (t.isEmpty) return null;
  return double.tryParse(t.replaceAll(',', ''));
}

String _fmtInt(double v) {
  if (v.isNaN || v.isInfinite) return '—';
  return v.round().toString();
}

/// Uses real dashboard fields where present; derives day/week from monthly when needed.
ProfessionalEarningsSnapshot mapTechnicianDashboardToSnapshot(
  AiTechnicianDashboardData d,
) {
  final total = d.totalEarningsBdt.trim();
  final monthlyStr = d.monthlyEarningsBdt?.trim();
  final monthly = _parseMoney(monthlyStr);
  String daily;
  String weekly;
  if (monthly != null && monthly > 0) {
    daily = _fmtInt(monthly / 30);
    weekly = _fmtInt(monthly * 7 / 30);
  } else {
    daily = '—';
    weekly = '—';
  }
  final monthlyOut =
      (monthlyStr != null && monthlyStr.isNotEmpty) ? monthlyStr : '—';

  final pendingApprox = d.pendingRequestsCount > 0
      ? '${d.pendingRequestsCount} টি কাজ অপেক্ষমাণ'
      : '৳০';

  final totalNum = _parseMoney(total) ?? 0;
  final withdrawable = totalNum > 0 ? _fmtInt(totalNum * 0.85) : '—';

  return ProfessionalEarningsSnapshot(
    dailyEarningsBdt: daily,
    weeklyEarningsBdt: weekly,
    monthlyEarningsBdt: monthlyOut,
    pendingPaymentsBdt: pendingApprox,
    withdrawableBalanceBdt: withdrawable,
    confirmedLifetimeBdt: total.isNotEmpty ? total : null,
    dataQualityNoteBn: monthly == null || monthly <= 0
        ? 'দৈনিক/সাপ্তাহিক ভাগ সার্ভারে `monthlyEarningsBdt` এলে স্বয়ংক্রিয় হবে। '
            'এখন মাসিক ও মোট আয় ড্যাশবোর্ড থেকে দেখানো হয়েছে।'
        : 'দৈনিক ও সাপ্তাহিক মান মাসিক থেকে আনুমানিক (প্রিভিউ)।',
  );
}

ProfessionalEarningsSnapshot mapDoctorContextToSnapshot(DashboardContext ctx) {
  final m = ctx.doctor?.earningsThisMonthBdt;
  final monthly = m != null ? m.round().toString() : '—';
  return ProfessionalEarningsSnapshot(
    dailyEarningsBdt: '—',
    weeklyEarningsBdt: '—',
    monthlyEarningsBdt: monthly,
    pendingPaymentsBdt: '—',
    withdrawableBalanceBdt: '—',
    confirmedLifetimeBdt: null,
    dataQualityNoteBn:
        'চিকিৎসক বুকিং ওয়ালেট API আসলে দৈনিক/সাপ্তাহিক ও নিষ্কাশনযোগ্য ব্যালেন্স এখানে যুক্ত হবে।',
  );
}

CommissionBreakdown demoCommissionFromGross(String grossBdtRaw) {
  final g = _parseMoney(grossBdtRaw) ?? 0;
  const pct = 12.0;
  final fee = g * (pct / 100);
  final net = g - fee;
  return CommissionBreakdown(
    grossBdtRaw: grossBdtRaw,
    platformFeePercent: pct,
    platformFeeBdtRaw: _fmtInt(fee),
    providerNetBdtRaw: _fmtInt(net),
  );
}
