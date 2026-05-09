import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:pranidoctor_mobile/src/features/billing/data/billing_payment_summary_model.dart';
import 'package:pranidoctor_mobile/src/features/billing/presentation/widgets/customer_billing_summary_card.dart';
import 'package:pranidoctor_mobile/src/features/billing/presentation/widgets/payment_status_badge.dart';
import 'package:pranidoctor_mobile/src/features/billing/presentation/widgets/provider_earning_summary_card.dart';

void main() {
  testWidgets('PaymentStatusBadge shows Bengali paid label', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: PaymentStatusBadge(status: BillingPaymentStatus.PAID),
        ),
      ),
    );
    expect(find.text('পরিশোধিত'), findsOneWidget);
  });

  testWidgets('CustomerBillingSummaryCard hides commission labels', (
    tester,
  ) async {
    final demo = BillingPaymentSummary.demoForCustomerPreview();
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: CustomerBillingSummaryCard(summary: demo, isEmpty: false),
        ),
      ),
    );
    expect(find.textContaining('প্ল্যাটফর্ম কমিশন'), findsNothing);
    expect(find.textContaining('পেআউট'), findsNothing);
    expect(find.text('মোট পরিশোধ'), findsOneWidget);
  });

  testWidgets('ProviderEarningSummaryCard shows payout row', (tester) async {
    final demo = BillingPaymentSummary.demoForTechnicianJob();
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: ProviderEarningSummaryCard(summary: demo, isEmpty: false),
        ),
      ),
    );
    expect(find.textContaining('প্ল্যাটফর্ম কমিশন'), findsOneWidget);
    expect(find.textContaining('প্রদানকারী পেআউট'), findsOneWidget);
  });
}
