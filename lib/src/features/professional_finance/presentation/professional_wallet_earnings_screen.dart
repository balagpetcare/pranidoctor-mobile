import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:pranidoctor_mobile/src/app/screen_padding.dart';
import 'package:pranidoctor_mobile/src/app/user_visible_async_error.dart';
import 'package:pranidoctor_mobile/src/design_system/prani_tokens.dart';
import 'package:pranidoctor_mobile/src/design_system/widgets/prani_empty_state.dart';
import 'package:pranidoctor_mobile/src/design_system/widgets/prani_error_state.dart';
import 'package:pranidoctor_mobile/src/design_system/widgets/prani_loading_state.dart';
import 'package:pranidoctor_mobile/src/features/ai_technician_application/application/ai_technician_providers.dart';
import 'package:pranidoctor_mobile/src/features/profile/application/profile_dashboard_providers.dart';
import 'package:pranidoctor_mobile/src/features/professional_finance/application/professional_finance_mappers.dart';
import 'package:pranidoctor_mobile/src/features/professional_finance/application/professional_finance_providers.dart';
import 'package:pranidoctor_mobile/src/features/professional_finance/domain/professional_finance_types.dart';
import 'package:pranidoctor_mobile/src/features/professional_finance/presentation/professional_transaction_history_screen.dart';
import 'package:pranidoctor_mobile/src/features/professional_finance/presentation/widgets/commission_breakdown_card.dart';
import 'package:pranidoctor_mobile/src/features/professional_finance/presentation/widgets/earnings_trend_chart_placeholder.dart';
import 'package:pranidoctor_mobile/src/features/professional_finance/presentation/widgets/financial_balance_hero_card.dart';
import 'package:pranidoctor_mobile/src/features/professional_finance/presentation/widgets/financial_metric_card.dart';
import 'package:pranidoctor_mobile/src/features/professional_finance/presentation/widgets/invoice_readiness_card.dart';
import 'package:pranidoctor_mobile/src/features/professional_finance/presentation/widgets/wallet_transaction_tile.dart';
import 'package:pranidoctor_mobile/src/features/professional_finance/presentation/widgets/withdrawal_request_tile.dart';

/// Enterprise wallet + earnings hub (professional workspace tab + standalone route).
class ProfessionalWalletEarningsScreen extends ConsumerWidget {
  const ProfessionalWalletEarningsScreen({super.key, this.embedded = false});

  final bool embedded;

  static const routePath = '/workspace/finance/wallet';

  static Future<void> _refresh(WidgetRef ref) async {
    ref.invalidate(aiTechnicianDashboardProvider);
    ref.invalidate(profileDashboardContextProvider);
    ref.invalidate(professionalWalletTransactionsProvider);
    ref.invalidate(professionalWithdrawalRequestsProvider);
    await Future<void>.delayed(const Duration(milliseconds: 50));
  }

  static Future<void> _openWithdrawalSheet(
    BuildContext context,
    WidgetRef ref,
  ) async {
    final amount = TextEditingController();
    final note = TextEditingController();
    try {
      final go = await showModalBottomSheet<bool>(
        context: context,
        showDragHandle: true,
        isScrollControlled: true,
        builder: (ctx) {
          return Padding(
            padding: EdgeInsets.only(
              left: 20,
              right: 20,
              top: 12,
              bottom: MediaQuery.viewInsetsOf(ctx).bottom + 20,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  'নিষ্কাশন অনুরোধ',
                  style: Theme.of(ctx).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w800,
                      ),
                ),
                const SizedBox(height: PraniSpacing.md),
                TextField(
                  controller: amount,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                    labelText: 'পরিমাণ (৳)',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: PraniSpacing.sm),
                TextField(
                  controller: note,
                  decoration: const InputDecoration(
                    labelText: 'নোট (ঐচ্ছিক)',
                    border: OutlineInputBorder(),
                  ),
                  maxLines: 2,
                ),
                const SizedBox(height: PraniSpacing.lg),
                FilledButton(
                  onPressed: () => Navigator.pop(ctx, true),
                  child: const Text('জমা দিন'),
                ),
              ],
            ),
          );
        },
      );
      if (go != true || !context.mounted) return;
      try {
        await ref.read(withdrawalRequestPortProvider).submitWithdrawal(
              amountBdtRaw: amount.text.trim(),
              noteBn: note.text.trim().isEmpty ? null : note.text.trim(),
            );
        if (!context.mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'অনুরোধ গ্রহণ করা হয়েছে (স্টাব) — পেমেন্ট গেটওয়ে সংযুক্ত হলে প্রক্রিয়া হবে।',
            ),
          ),
        );
      } on ArgumentError {
        if (!context.mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('সঠিক পরিমাণ লিখুন।')),
        );
      }
    } finally {
      amount.dispose();
      note.dispose();
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final snapAsync = ref.watch(professionalEarningsSnapshotProvider);
    final hPad = pdScreenPadding(context).horizontal;

    final body = snapAsync.when(
      loading: () => const Center(
        child: PraniLoadingState(message: 'আর্থিক সারাংশ লোড হচ্ছে…'),
      ),
      error: (e, _) => Center(
        child: Padding(
          padding: EdgeInsets.all(hPad),
          child: PraniErrorState(
            title: 'লোড করা যায়নি',
            message: userVisibleAsyncErrorBn(e),
            retryLabel: 'আবার চেষ্টা',
            onRetry: () => _refresh(ref),
            detail: '$e',
          ),
        ),
      ),
      data: (snap) => RefreshIndicator(
        onRefresh: () => _refresh(ref),
        child: CustomScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          slivers: [
            SliverPadding(
              padding: EdgeInsets.fromLTRB(hPad, 12, hPad, 24),
              sliver: SliverList(
                delegate: SliverChildListDelegate([
                  FinancialBalanceHeroCard(
                    withdrawableBdt: snap.withdrawableBalanceBdt,
                    pendingLabelBn: snap.pendingPaymentsBdt,
                    lifetimeBdt: snap.confirmedLifetimeBdt,
                  ),
                  if (snap.dataQualityNoteBn != null) ...[
                    const SizedBox(height: PraniSpacing.md),
                    Text(
                      snap.dataQualityNoteBn!,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: Theme.of(context).colorScheme.onSurfaceVariant,
                            height: 1.45,
                          ),
                    ),
                  ],
                  const SizedBox(height: PraniSpacing.lg),
                  LayoutBuilder(
                    builder: (context, c) {
                      final gap = PraniSpacing.md;
                      final w = (c.maxWidth - gap) / 2;
                      Widget cell(Widget child) =>
                          SizedBox(width: w, child: child);
                      return Wrap(
                        spacing: gap,
                        runSpacing: gap,
                        children: [
                          cell(
                            FinancialMetricCard(
                              labelBn: 'দৈনিক আয়',
                              valueBn: snap.dailyEarningsBdt,
                              icon: Icons.today_outlined,
                            ),
                          ),
                          cell(
                            FinancialMetricCard(
                              labelBn: 'সাপ্তাহিক আয়',
                              valueBn: snap.weeklyEarningsBdt,
                              icon: Icons.date_range_outlined,
                            ),
                          ),
                          cell(
                            FinancialMetricCard(
                              labelBn: 'মাসিক আয়',
                              valueBn: snap.monthlyEarningsBdt,
                              icon: Icons.calendar_month_outlined,
                            ),
                          ),
                          cell(
                            FinancialMetricCard(
                              labelBn: 'অপেক্ষমাণ পেমেন্ট',
                              valueBn: snap.pendingPaymentsBdt,
                              icon: Icons.hourglass_top_outlined,
                            ),
                          ),
                        ],
                      );
                    },
                  ),
                  const SizedBox(height: PraniSpacing.lg),
                  _commissionAndInvoice(context, snap),
                  const SizedBox(height: PraniSpacing.lg),
                  EarningsTrendChartPlaceholder(
                    seed: snap.confirmedLifetimeBdt ?? snap.monthlyEarningsBdt,
                  ),
                  const SizedBox(height: PraniSpacing.lg),
                  Row(
                    children: [
                      Text(
                        'নিষ্কাশন ইতিহাস',
                        style: Theme.of(context).textTheme.titleSmall?.copyWith(
                              fontWeight: FontWeight.w800,
                            ),
                      ),
                      const Spacer(),
                      TextButton(
                        onPressed: () => _openWithdrawalSheet(context, ref),
                        child: const Text('নতুন অনুরোধ'),
                      ),
                    ],
                  ),
                  const SizedBox(height: PraniSpacing.sm),
                  _WithdrawalPreviewSliver(),
                  const SizedBox(height: PraniSpacing.xl),
                  Row(
                    children: [
                      Text(
                        'সাম্প্রতিক লেনদেন',
                        style: Theme.of(context).textTheme.titleSmall?.copyWith(
                              fontWeight: FontWeight.w800,
                            ),
                      ),
                      const Spacer(),
                      TextButton(
                        onPressed: () => context.push(
                          ProfessionalTransactionHistoryScreen.routePath,
                        ),
                        child: const Text('সব দেখুন'),
                      ),
                    ],
                  ),
                  const SizedBox(height: PraniSpacing.sm),
                  _TransactionPreviewList(),
                  const SizedBox(height: PraniSpacing.lg),
                  if (!embedded)
                    FilledButton.icon(
                      onPressed: () => _openWithdrawalSheet(context, ref),
                      icon: const Icon(Icons.outbound_outlined),
                      label: const Text('টাকা তুলুন (স্টাব)'),
                    ),
                ]),
              ),
            ),
          ],
        ),
      ),
    );

    if (embedded) return body;
    return Scaffold(
      appBar: AppBar(title: const Text('ওয়ালেট ও আয়')),
      body: body,
    );
  }
}

Widget _commissionAndInvoice(
  BuildContext context,
  ProfessionalEarningsSnapshot snap,
) {
  final lifetime = snap.confirmedLifetimeBdt?.trim();
  final monthly = snap.monthlyEarningsBdt.trim();
  final raw = (lifetime != null && lifetime.isNotEmpty) ? lifetime : monthly;
  final digits = raw.replaceAll(RegExp(r'[^\d.]'), '');
  final g = double.tryParse(digits);
  final grossForDemo =
      (g != null && g > 0) ? g.round().toString() : '3200';
  final commission = demoCommissionFromGross(grossForDemo);
  final invoice = InvoiceReadinessOutline(
    invoiceNumber: 'PD-INV-2026-0142',
    periodLabelBn: 'মে ২০২৬',
    totalBdtRaw: grossForDemo,
    taxReady: false,
    linesBn: const [
      'সেবা শ্রেণি ও হার সার্ভার থেকে লোড হবে',
      'ভ্যাট/আয়কর ক্ষেত্রে বিন/ব্রেকআপ টেবিল',
      'পিডিএফ ইনভয়েস জেনারেশন — সার্ভার জব',
    ],
  );
  return Column(
    children: [
      CommissionBreakdownCard(data: commission),
      const SizedBox(height: PraniSpacing.md),
      InvoiceReadinessCard(outline: invoice),
    ],
  );
}

class _WithdrawalPreviewSliver extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final async = ref.watch(professionalWithdrawalRequestsProvider);
    return async.when(
      loading: () => const Center(
        child: Padding(
          padding: EdgeInsets.all(24),
          child: CircularProgressIndicator(),
        ),
      ),
      error: (e, _) => Text(
        userVisibleAsyncErrorBn(e),
        style: Theme.of(context).textTheme.bodySmall,
      ),
      data: (rows) {
        if (rows.isEmpty) {
          return const PraniEmptyState(
            title: 'কোনো নিষ্কাশন নেই',
            message: 'নিষ্কাশন অনুরোধ জমা দিলে এখানে দেখা যাবে।',
            boxed: true,
          );
        }
        return Column(
          children: [
            for (final r in rows.take(3)) ...[
              WithdrawalRequestTile(row: r),
              const SizedBox(height: PraniSpacing.sm),
            ],
          ],
        );
      },
    );
  }
}

class _TransactionPreviewList extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final async = ref.watch(professionalWalletTransactionsProvider);
    return async.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, _) => Text(userVisibleAsyncErrorBn(e)),
      data: (rows) {
        if (rows.isEmpty) {
          return const PraniEmptyState(
            title: 'লেনদেন নেই',
            message: 'সেবা সম্পন্ন ও পেমেন্ট নিশ্চিত হলে লেনদেন এখানে জমা হবে।',
            boxed: true,
          );
        }
        return Column(
          children: [
            for (final r in rows.take(4)) ...[
              WalletTransactionTile(row: r),
              const SizedBox(height: PraniSpacing.sm),
            ],
          ],
        );
      },
    );
  }
}
