import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:pranidoctor_mobile/src/app/screen_padding.dart';
import 'package:pranidoctor_mobile/src/app/user_visible_async_error.dart';
import 'package:pranidoctor_mobile/src/design_system/widgets/prani_error_state.dart';
import 'package:pranidoctor_mobile/src/design_system/widgets/prani_loading_state.dart';
import 'package:pranidoctor_mobile/src/features/livestock_booking/application/livestock_booking_providers.dart';
import 'package:pranidoctor_mobile/src/features/livestock_booking/domain/service_request_booking_mapper.dart';
import 'package:pranidoctor_mobile/src/features/livestock_booking/presentation/widgets/livestock_service_request_card.dart';
import 'package:pranidoctor_mobile/src/features/service_requests/application/service_requests_providers.dart';
import 'package:pranidoctor_mobile/src/features/service_requests/data/service_request_model.dart';
import 'package:pranidoctor_mobile/src/features/service_requests/presentation/service_requests_tab_screen.dart'
    show ServiceRequestDetailScreen;

String _formatSubmittedDate(DateTime t) {
  final d = t.toLocal();
  return '${d.day}/${d.month}/${d.year}';
}

/// Active vs completed/cancelled booking history (same API list, client-side filter).
class BookingHistoryScreen extends ConsumerStatefulWidget {
  const BookingHistoryScreen({super.key});

  static const routePath = '/booking/history';
  static const routeName = 'bookingHistory';

  @override
  ConsumerState<BookingHistoryScreen> createState() =>
      _BookingHistoryScreenState();
}

class _BookingHistoryScreenState extends ConsumerState<BookingHistoryScreen>
    with SingleTickerProviderStateMixin {
  late final TabController _tabs =
      TabController(length: 2, vsync: this, initialIndex: 0);

  @override
  void dispose() {
    _tabs.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final async = ref.watch(serviceRequestsListProvider);
    final hPad = pdScreenPadding(context).horizontal;

    return Scaffold(
      appBar: AppBar(
        title: const Text('বুকিং ইতিহাস'),
        bottom: TabBar(
          controller: _tabs,
          tabs: const [
            Tab(text: 'চলমান'),
            Tab(text: 'সমাপ্ত / বাতিল'),
          ],
        ),
      ),
      body: async.when(
        loading: () => const Center(
          child: PraniLoadingState(message: 'লোড হচ্ছে…'),
        ),
        error: (e, _) => Center(
          child: Padding(
            padding: EdgeInsets.all(hPad),
            child: PraniErrorState(
              title: 'লোড করা যায়নি',
              message: userVisibleAsyncErrorBn(e),
              retryLabel: 'আবার চেষ্টা করুন',
              onRetry: () =>
                  ref.read(serviceRequestsListProvider.notifier).refresh(),
              detail: '$e',
            ),
          ),
        ),
        data: (items) {
          if (items.isEmpty) {
            return TabBarView(
              controller: _tabs,
              children: const [
                _EmptyHistory(
                  message: 'কোনো চলমান বুকিং নেই।',
                ),
                _EmptyHistory(
                  message: 'এখনো কোনো সমাপ্ত বুকিং নেই।',
                ),
              ],
            );
          }
          final active = livestockBookingActiveRequests(items);
          final past = livestockBookingHistoryRequests(items);

          return TabBarView(
            controller: _tabs,
            children: [
              _RequestList(
                items: active,
                emptyMessage: 'কোনো চলমান বুকিং নেই।',
                onRefresh: () =>
                    ref.read(serviceRequestsListProvider.notifier).refresh(),
              ),
              _RequestList(
                items: past,
                emptyMessage: 'কোনো সমাপ্ত বা বাতিল বুকিং নেই।',
                onRefresh: () =>
                    ref.read(serviceRequestsListProvider.notifier).refresh(),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _EmptyHistory extends StatelessWidget {
  const _EmptyHistory({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Text(
          message,
          textAlign: TextAlign.center,
          style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
        ),
      ),
    );
  }
}

class _RequestList extends StatelessWidget {
  const _RequestList({
    required this.items,
    required this.emptyMessage,
    required this.onRefresh,
  });

  final List<ServiceRequest> items;
  final String emptyMessage;
  final Future<void> Function() onRefresh;

  @override
  Widget build(BuildContext context) {
    if (items.isEmpty) {
      return RefreshIndicator(
        onRefresh: onRefresh,
        child: ListView(
          physics: const AlwaysScrollableScrollPhysics(),
          children: [
            SizedBox(
              height: MediaQuery.sizeOf(context).height * 0.35,
              child: Center(child: Text(emptyMessage)),
            ),
          ],
        ),
      );
    }
    final hPad = pdScreenPadding(context).horizontal;
    return RefreshIndicator(
      onRefresh: onRefresh,
      child: ListView.separated(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: EdgeInsets.fromLTRB(hPad, 12, hPad, 24),
        itemCount: items.length,
        separatorBuilder: (_, _) => const SizedBox(height: 10),
        itemBuilder: (context, i) {
          final r = items[i];
          return LivestockServiceRequestCard(
            title: r.serviceType.labelBn,
            phaseLabelBn: livestockBookingPhaseFor(r).labelBn,
            submittedLine: 'জমা · ${_formatSubmittedDate(r.submittedAt)}',
            onTap: () => context.push(
              ServiceRequestDetailScreen.routePathFor(r.id),
            ),
          );
        },
      ),
    );
  }
}
