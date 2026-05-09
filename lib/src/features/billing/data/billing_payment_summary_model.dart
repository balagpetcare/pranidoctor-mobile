// Billing / payment summary — optional camelCase JSON from mobile APIs (forward-compatible).
// ignore_for_file: constant_identifier_names

/// Visible UI payment methods (API string normalized to uppercase).
enum BillingPaymentMethod {
  UNKNOWN,
  CASH,
  MOBILE_BANKING,
  CARD,
  BANK_TRANSFER,
  OTHER;

  static BillingPaymentMethod fromJson(String? raw) {
    if (raw == null || raw.trim().isEmpty) return BillingPaymentMethod.UNKNOWN;
    final k = raw.trim().toUpperCase().replaceAll('-', '_');
    for (final e in BillingPaymentMethod.values) {
      if (e.name == k) return e;
    }
    if (k.contains('CASH')) return BillingPaymentMethod.CASH;
    if (k.contains('MOBILE') || k.contains('BKASH') || k.contains('NAGAD')) {
      return BillingPaymentMethod.MOBILE_BANKING;
    }
    if (k.contains('CARD')) return BillingPaymentMethod.CARD;
    if (k.contains('BANK')) return BillingPaymentMethod.BANK_TRANSFER;
    return BillingPaymentMethod.OTHER;
  }

  String get labelBn {
    return switch (this) {
      BillingPaymentMethod.UNKNOWN => 'নির্ধারিত হয়নি',
      BillingPaymentMethod.CASH => 'নগদ',
      BillingPaymentMethod.MOBILE_BANKING => 'মোবাইল ব্যাংকিং',
      BillingPaymentMethod.CARD => 'কার্ড',
      BillingPaymentMethod.BANK_TRANSFER => 'ব্যাংক ট্রান্সফার',
      BillingPaymentMethod.OTHER => 'অন্যান্য',
    };
  }
}

enum BillingPaymentStatus {
  UNKNOWN,
  PENDING,
  PAID,
  PARTIAL,
  DUE,
  REFUNDED,
  WAIVED,
  CANCELLED;

  static BillingPaymentStatus fromJson(String? raw) {
    if (raw == null || raw.trim().isEmpty) return BillingPaymentStatus.UNKNOWN;
    final k = raw.trim().toUpperCase().replaceAll('-', '_');
    for (final e in BillingPaymentStatus.values) {
      if (e.name == k) return e;
    }
    return BillingPaymentStatus.UNKNOWN;
  }

  String get labelBn {
    return switch (this) {
      BillingPaymentStatus.UNKNOWN => 'অজানা',
      BillingPaymentStatus.PENDING => 'অপেক্ষমান',
      BillingPaymentStatus.PAID => 'পরিশোধিত',
      BillingPaymentStatus.PARTIAL => 'আংশিক পরিশোধ',
      BillingPaymentStatus.DUE => 'বাকি আছে',
      BillingPaymentStatus.REFUNDED => 'ফেরত দেওয়া হয়েছে',
      BillingPaymentStatus.WAIVED => 'মওকুফ',
      BillingPaymentStatus.CANCELLED => 'বাতিল',
    };
  }
}

/// Parsed billing snapshot (whole currency units, BDT unless API adds currency).
class BillingPaymentSummary {
  const BillingPaymentSummary({
    this.serviceFee,
    this.travelCost,
    this.medicineCost,
    this.discount,
    this.totalCollected,
    this.platformCommission,
    this.providerPayout,
    this.paymentMethod = BillingPaymentMethod.UNKNOWN,
    this.paymentStatus = BillingPaymentStatus.UNKNOWN,
    this.currency = 'BDT',
    this.notes,
  });

  final double? serviceFee;
  final double? travelCost;
  final double? medicineCost;

  /// Positive amount representing money taken off the bill.
  final double? discount;
  final double? totalCollected;
  final double? platformCommission;
  final double? providerPayout;
  final BillingPaymentMethod paymentMethod;
  final BillingPaymentStatus paymentStatus;
  final String currency;
  final String? notes;

  /// Non-null when any structured billing token exists (even “unknown” enums).
  bool get hasAnyStructuredField {
    return serviceFee != null ||
        travelCost != null ||
        medicineCost != null ||
        discount != null ||
        totalCollected != null ||
        platformCommission != null ||
        providerPayout != null ||
        paymentMethod != BillingPaymentMethod.UNKNOWN ||
        paymentStatus != BillingPaymentStatus.UNKNOWN ||
        (notes?.trim().isNotEmpty ?? false);
  }

  /// True when the customer card should only show the empty state (no meaningful row).
  bool get isEmptyForCustomerView {
    if (notes?.trim().isNotEmpty == true) return false;
    if (paymentStatus != BillingPaymentStatus.UNKNOWN) return false;
    if (paymentMethod != BillingPaymentMethod.UNKNOWN) return false;
    return !hasCustomerAmountLines;
  }

  bool get hasProviderNumericInsight {
    return totalCollected != null ||
        platformCommission != null ||
        providerPayout != null;
  }

  /// True when provider card has nothing to show except maybe free-text [notes].
  bool get isEmptyForProviderView {
    if (notes?.trim().isNotEmpty == true) return false;
    if (paymentStatus != BillingPaymentStatus.UNKNOWN) return false;
    if (paymentMethod != BillingPaymentMethod.UNKNOWN) return false;
    if (hasProviderNumericInsight) return false;
    if (hasCustomerAmountLines) return false;
    return true;
  }

  /// Rows meaningful for customer receipt (amount lines).
  bool get hasCustomerAmountLines {
    return serviceFee != null ||
        travelCost != null ||
        medicineCost != null ||
        discount != null ||
        totalCollected != null;
  }

  factory BillingPaymentSummary.fromJson(Map<String, dynamic> json) {
    return BillingPaymentSummary(
      serviceFee: _parseMoney(json['serviceFee'] ?? json['service_fee']),
      travelCost: _parseMoney(json['travelCost'] ?? json['travel_cost']),
      medicineCost: _parseMoney(json['medicineCost'] ?? json['medicine_cost']),
      discount: _parseMoney(json['discount']),
      totalCollected: _parseMoney(
        json['totalCollected'] ??
            json['total_collected'] ??
            json['totalPayable'] ??
            json['total_payable'],
      ),
      platformCommission: _parseMoney(
        json['platformCommission'] ?? json['platform_commission'],
      ),
      providerPayout: _parseMoney(
        json['providerPayout'] ?? json['provider_payout'],
      ),
      paymentMethod: BillingPaymentMethod.fromJson(
        json['paymentMethod']?.toString() ?? json['payment_method']?.toString(),
      ),
      paymentStatus: BillingPaymentStatus.fromJson(
        json['paymentStatus']?.toString() ?? json['payment_status']?.toString(),
      ),
      currency: json['currency']?.toString().trim().isNotEmpty == true
          ? json['currency']!.toString().trim()
          : 'BDT',
      notes: json['notes']?.toString() ?? json['note']?.toString(),
    );
  }

  /// Reads nested `billing` / `payment` / `paymentSummary` objects from a root JSON map.
  static BillingPaymentSummary? fromRootJson(Map<String, dynamic> json) {
    final nested = _pickMap(json, ['billing', 'payment', 'paymentSummary']);
    if (nested != null) {
      final parsed = BillingPaymentSummary.fromJson(nested);
      if (parsed.hasAnyStructuredField) return parsed;
    }
    final loose = BillingPaymentSummary.fromJson(json);
    return loose.hasAnyStructuredField ? loose : null;
  }

  static Map<String, dynamic>? _pickMap(
    Map<String, dynamic> json,
    List<String> keys,
  ) {
    for (final k in keys) {
      final v = json[k];
      if (v is Map<String, dynamic>) return v;
    }
    return null;
  }

  static double? _parseMoney(dynamic v) {
    if (v == null) return null;
    if (v is num) return v.toDouble();
    if (v is String) return double.tryParse(v.trim());
    return null;
  }

  /// QA/demo only — `USE_MOCK_BILLING_UI` must gate usage at call site.
  static BillingPaymentSummary demoForCustomerPreview() {
    return const BillingPaymentSummary(
      serviceFee: 1200,
      travelCost: 350,
      medicineCost: 200,
      discount: 100,
      totalCollected: 1650,
      platformCommission: 165,
      providerPayout: 1485,
      paymentMethod: BillingPaymentMethod.MOBILE_BANKING,
      paymentStatus: BillingPaymentStatus.PAID,
      notes: '(ডেমো ডেটা)',
    );
  }

  /// Technician mock — sample settled job (same shape as future API).
  static BillingPaymentSummary demoForTechnicianJob() {
    return const BillingPaymentSummary(
      serviceFee: 2500,
      travelCost: 400,
      medicineCost: 0,
      discount: 0,
      totalCollected: 2900,
      platformCommission: 290,
      providerPayout: 2610,
      paymentMethod: BillingPaymentMethod.CASH,
      paymentStatus: BillingPaymentStatus.PAID,
    );
  }
}
