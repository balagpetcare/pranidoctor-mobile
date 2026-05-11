import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:pranidoctor_mobile/src/app/screen_padding.dart';
import 'package:pranidoctor_mobile/src/app/user_visible_async_error.dart';
import 'package:pranidoctor_mobile/src/design_system/prani_tokens.dart';
import 'package:pranidoctor_mobile/src/design_system/widgets/prani_empty_state.dart';
import 'package:pranidoctor_mobile/src/design_system/widgets/prani_error_state.dart';
import 'package:pranidoctor_mobile/src/design_system/widgets/prani_loading_state.dart';
import 'package:pranidoctor_mobile/src/features/professional_finance/application/professional_finance_providers.dart';
import 'package:pranidoctor_mobile/src/features/professional_finance/domain/professional_finance_types.dart';
import 'package:pranidoctor_mobile/src/features/professional_finance/presentation/widgets/wallet_transaction_tile.dart';

enum _TxnFilter { all, credit, debit }

/// Full transaction history (stub repository until wallet API ships).
class ProfessionalTransactionHistoryScreen extends ConsumerStatefulWidget {
  const ProfessionalTransactionHistoryScreen({super.key});

  static const routePath = '/workspace/finance/transactions';

  @override
  ConsumerState<ProfessionalTransactionHistoryScreen> createState() =>
      _ProfessionalTransactionHistoryScreenState();
}

class _ProfessionalTransactionHistoryScreenState
    extends ConsumerState<ProfessionalTransactionHistoryScreen> {
  _TxnFilter _filter = _TxnFilter.all;

  List<WalletTransactionRecord> _apply(
    List<WalletTransactionRecord> all,
  ) {
    return switch (_filter) {
      _TxnFilter.all => all,
      _TxnFilter.credit =>
        all.where((e) => e.direction == WalletLedgerDirection.credit).toList(),
      _TxnFilter.debit =>
        all.where((e) => e.direction == WalletLedgerDirection.debit).toList(),
    };
  }

  @override
  Widget build(BuildContext context) {
    final async = ref.watch(professionalWalletTransactionsProvider);
    final hPad = pdScreenPadding(context).horizontal;

    return Scaffold(
      appBar: AppBar(title: const Text('লেনদেনের ইতিহাস')),
      body: Column(
        children: [
          Padding(
            padding: EdgeInsets.fromLTRB(hPad, 12, hPad, 0),
            child: Align(
              alignment: Alignment.centerLeft,
              child: Wrap(
                spacing: PraniSpacing.sm,
                children: [
                  ChoiceChip(
                    label: const Text('সব'),
                    selected: _filter == _TxnFilter.all,
                    onSelected: (_) => setState(() => _filter = _TxnFilter.all),
                  ),
                  ChoiceChip(
                    label: const Text('জমা'),
                    selected: _filter == _TxnFilter.credit,
                    onSelected: (_) =>
                        setState(() => _filter = _TxnFilter.credit),
                  ),
                  ChoiceChip(
                    label: const Text('খরচ'),
                    selected: _filter == _TxnFilter.debit,
                    onSelected: (_) =>
                        setState(() => _filter = _TxnFilter.debit),
                  ),
                ],
              ),
            ),
          ),
          Expanded(
            child: async.when(
              loading: () => const Center(
                child: PraniLoadingState(message: 'লোড হচ্ছে…'),
              ),
              error: (e, _) => Center(
                child: Padding(
                  padding: EdgeInsets.all(hPad),
                  child: PraniErrorState(
                    title: 'লোড করা যায়নি',
                    message: userVisibleAsyncErrorBn(e),
                    retryLabel: 'আবার চেষ্টা',
                    onRetry: () => ref.invalidate(
                      professionalWalletTransactionsProvider,
                    ),
                    detail: '$e',
                  ),
                ),
              ),
              data: (rows) {
                final filtered = _apply(rows);
                if (filtered.isEmpty) {
                  return ListView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    padding: EdgeInsets.all(hPad),
                    children: const [
                      PraniEmptyState(
                        title: 'কোনো লেনদেন নেই',
                        message: 'ফিল্টার পরিবর্তন করুন বা পরে আবার দেখুন।',
                        boxed: true,
                      ),
                    ],
                  );
                }
                return RefreshIndicator(
                  onRefresh: () async {
                    ref.invalidate(professionalWalletTransactionsProvider);
                    await ref.read(
                      professionalWalletTransactionsProvider.future,
                    );
                  },
                  child: ListView.separated(
                    physics: const AlwaysScrollableScrollPhysics(),
                    padding: EdgeInsets.fromLTRB(hPad, 16, hPad, 32),
                    itemCount: filtered.length,
                    separatorBuilder: (_, _) =>
                        const SizedBox(height: PraniSpacing.sm),
                    itemBuilder: (context, i) {
                      return WalletTransactionTile(row: filtered[i]);
                    },
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
