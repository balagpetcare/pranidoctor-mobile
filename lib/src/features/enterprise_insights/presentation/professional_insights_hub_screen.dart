import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:pranidoctor_mobile/src/design_system/prani_tokens.dart';
import 'package:pranidoctor_mobile/src/design_system/widgets/prani_error_state.dart';
import 'package:pranidoctor_mobile/src/design_system/widgets/prani_loading_state.dart';
import 'package:pranidoctor_mobile/src/design_system/widgets/prani_scaffold.dart';
import 'package:pranidoctor_mobile/src/features/ai_technician_application/application/ai_technician_providers.dart';
import 'package:pranidoctor_mobile/src/features/enterprise_insights/application/enterprise_insights_providers.dart';
import 'package:pranidoctor_mobile/src/features/enterprise_insights/data/enterprise_audit_activity_store.dart';
import 'package:pranidoctor_mobile/src/features/enterprise_insights/domain/professional_analytics_snapshot.dart';
import 'package:pranidoctor_mobile/src/features/enterprise_insights/presentation/widgets/enterprise_insights_sections.dart';
import 'package:pranidoctor_mobile/src/features/enterprise_media_upload/application/enterprise_media_upload_providers.dart';
import 'package:pranidoctor_mobile/src/features/enterprise_media_upload/domain/media_upload_lifecycle.dart';
import 'package:pranidoctor_mobile/src/features/enterprise_media_upload/domain/media_upload_task.dart';
import 'package:pranidoctor_mobile/src/features/enterprise_media_upload/presentation/widgets/enterprise_media_upload_widgets.dart';
import 'package:pranidoctor_mobile/src/features/profile/application/profile_dashboard_providers.dart';
import 'package:pranidoctor_mobile/src/features/session/application/session_notifier.dart';

/// Enterprise analytics + offline/sync audit hub (doctor / AI technician).
class ProfessionalInsightsHubScreen extends ConsumerStatefulWidget {
  const ProfessionalInsightsHubScreen({super.key});

  static const routePath = '/workspace/enterprise-insights';
  static const routeName = 'professionalEnterpriseInsights';

  @override
  ConsumerState<ProfessionalInsightsHubScreen> createState() =>
      _ProfessionalInsightsHubScreenState();
}

class _ProfessionalInsightsHubScreenState
    extends ConsumerState<ProfessionalInsightsHubScreen> {
  var _loggedOpen = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      unawaited(_logOpenOnce());
    });
  }

  Future<void> _logOpenOnce() async {
    if (_loggedOpen) return;
    _loggedOpen = true;
    final role = ref.read(sessionNotifierProvider).role;
    if (role == null) return;
    await recordEnterpriseAuditPreview(
      role: role,
      actionKey: 'enterprise_insights.open',
      summaryBn: 'এন্টারপ্রাইজ বিশ্লেষণ হাব খোলা হয়েছে',
    );
    await recordEnterpriseActivityPreview(
      role: role,
      titleBn: 'বিশ্লেষণ হাব',
      detailBn: 'স্ক্রিন ওভারভিউ',
    );
    if (!mounted) return;
    ref.invalidate(enterpriseAuditListProvider);
    ref.invalidate(enterpriseActivityListProvider);
  }

  Future<void> _persistSnapshot(ProfessionalAnalyticsSnapshot s) async {
    final cache = ref.read(offlineJsonCachePortProvider);
    final payload = jsonEncode({
      'monthlyPerformanceBn': s.monthlyPerformanceBn,
      'serviceSuccessRateBn': s.serviceSuccessRateBn,
      'areaPerformanceBn': s.areaPerformanceBn,
      'revenueAnalyticsBn': s.revenueAnalyticsBn,
      'growthMetricsBn': s.growthMetricsBn,
      'footnoteBn': s.footnoteBn,
      'cachedAtUtc': DateTime.now().toUtc().toIso8601String(),
    });
    await cache.put('enterprise_analytics', 'snapshot_v1', payload);
  }

  Future<void> _onRefresh() async {
    final role = ref.read(sessionNotifierProvider).role;
    final sync = ref.read(syncCoordinatorPortProvider);
    final mon = ref.read(monitoringPortProvider);
    mon.breadcrumb('enterprise_insights.refresh', data: {'role': '${role?.name}'});
    await sync.requestFlush();
    try {
      if (role == AppRole.aiTechnician) {
        ref.invalidate(aiTechnicianDashboardProvider);
        await ref.read(aiTechnicianDashboardProvider.future);
      } else if (role == AppRole.doctor) {
        ref.invalidate(profileDashboardContextProvider);
        await ref.read(profileDashboardContextProvider.future);
      }
    } catch (e, st) {
      mon.captureException(e, st);
    }
    if (role != null && mounted) {
      await recordEnterpriseActivityPreview(
        role: role,
        titleBn: 'রিফ্রেশ',
        detailBn: 'ড্যাশবোর্ড ডেটা পুনরায় লোড',
      );
      ref.invalidate(enterpriseActivityListProvider);
    }
    ref.read(enterpriseSyncTickProvider.notifier).bump();
    unawaited(ref.read(enterpriseMediaUploadManagerProvider).processQueue());
  }

  @override
  Widget build(BuildContext context) {
    ref.listen<AsyncValue<ProfessionalAnalyticsSnapshot>>(
      professionalAnalyticsSnapshotProvider,
      (prev, next) {
        next.whenData((snap) {
          unawaited(_persistSnapshot(snap));
        });
      },
    );

    final asyncSnap = ref.watch(professionalAnalyticsSnapshotProvider);
    final asyncAudit = ref.watch(enterpriseAuditListProvider);
    final asyncActivity = ref.watch(enterpriseActivityListProvider);
    final asyncSync = ref.watch(enterpriseSyncSnapshotProvider);
    final asyncMediaTasks = ref.watch(enterpriseMediaUploadTasksProvider);
    final asyncMediaActivity = ref.watch(enterpriseMediaUploadActivityProvider);

    return PraniScaffold(
      title: 'এন্টারপ্রাইজ বিশ্লেষণ',
      showBackButton: true,
      body: RefreshIndicator(
        onRefresh: _onRefresh,
        child: ListView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.fromLTRB(
            PraniSpacing.lg,
            PraniSpacing.md,
            PraniSpacing.lg,
            PraniSpacing.xxl,
          ),
          children: [
            EnterpriseOfflineSyncBanner(asyncSnapshot: asyncSync),
            const SizedBox(height: PraniSpacing.lg),
            asyncSnap.when(
              loading: () => const PraniLoadingState(
                message: 'মেট্রিক্স লোড হচ্ছে…',
                compact: false,
              ),
              error: (e, _) => PraniErrorState(
                title: 'লোড করা যায়নি',
                message: 'নেটওয়ার্ক বা সেশন যাচাই করে আবার চেষ্টা করুন।',
                retryLabel: 'আবার চেষ্টা',
                onRetry: _onRefresh,
                boxed: true,
              ),
              data: (snap) => Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  EnterpriseAnalyticsMetricDeck(snapshot: snap),
                  const SizedBox(height: PraniSpacing.xl),
                  const EnterpriseMultiChartPlaceholder(),
                  if (snap.footnoteBn != null) ...[
                    const SizedBox(height: PraniSpacing.md),
                    Text(
                      snap.footnoteBn!,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: Theme.of(context).colorScheme.onSurfaceVariant,
                            height: 1.45,
                          ),
                    ),
                  ],
                ],
              ),
            ),
            const SizedBox(height: PraniSpacing.xxl),
            Text(
              'মিডিয়া আপলোড কিউ',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w800,
                  ),
            ),
            const SizedBox(height: PraniSpacing.sm),
            asyncMediaTasks.when(
              loading: () => const PraniLoadingState(compact: true),
              error: (e, _) => Text('মিডিয়া কিউ লোড ব্যর্থ: $e'),
              data: (tasks) {
                if (tasks.isEmpty) {
                  return Text(
                    'কিউ খালি। প্রোফাইল বা সেবা স্ক্রিন থেকে আপলোড এনকিউ করা হবে।',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                        ),
                  );
                }
                final mgr = ref.read(enterpriseMediaUploadManagerProvider);
                return Column(
                  children: [
                    for (final t in tasks.take(8))
                      Padding(
                        padding: const EdgeInsets.only(bottom: PraniSpacing.sm),
                        child: _MediaHubRow(
                          task: t,
                          onCancel: () => unawaited(mgr.cancel(t.id)),
                          onPause: () => unawaited(mgr.pause(t.id)),
                          onResume: () => unawaited(mgr.resume(t.id)),
                          onRetry: () => unawaited(mgr.retry(t.id)),
                        ),
                      ),
                  ],
                );
              },
            ),
            const SizedBox(height: PraniSpacing.lg),
            Text(
              'মিডিয়া আপলোড কার্যকলাপ',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w800,
                  ),
            ),
            const SizedBox(height: PraniSpacing.sm),
            asyncMediaActivity.when(
              loading: () => const SizedBox.shrink(),
              error: (_, _) => const SizedBox.shrink(),
              data: (rows) {
                if (rows.isEmpty) {
                  return Text(
                    'কার্যকলম নেই।',
                    style: Theme.of(context).textTheme.bodySmall,
                  );
                }
                final rev = rows.reversed.take(10).toList();
                return Column(
                  children: rev
                      .map(
                        (r) => ListTile(
                          dense: true,
                          contentPadding: EdgeInsets.zero,
                          leading: const Icon(Icons.history_rounded, size: 20),
                          title: Text('${r['titleBn'] ?? ''}'),
                          subtitle: Text('${r['detailBn'] ?? ''}'),
                        ),
                      )
                      .toList(),
                );
              },
            ),
            const SizedBox(height: PraniSpacing.xxl),
            Text(
              'অডিট লগ (লোকাল)',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w800,
                  ),
            ),
            const SizedBox(height: PraniSpacing.sm),
            asyncAudit.when(
              loading: () => const PraniLoadingState(compact: true),
              error: (e, _) => Text('অডিট লোড ব্যর্থ: $e'),
              data: (list) => EnterpriseAuditTimeline(entries: list),
            ),
            const SizedBox(height: PraniSpacing.xl),
            Text(
              'কার্যকলাপের ইতিহাস',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w800,
                  ),
            ),
            const SizedBox(height: PraniSpacing.sm),
            asyncActivity.when(
              loading: () => const PraniLoadingState(compact: true),
              error: (e, _) => Text('ইতিহাস লোড ব্যর্থ: $e'),
              data: (list) => EnterpriseActivityList(entries: list),
            ),
          ],
        ),
      ),
    );
  }
}

class _MediaHubRow extends StatelessWidget {
  const _MediaHubRow({
    required this.task,
    required this.onCancel,
    required this.onPause,
    required this.onResume,
    required this.onRetry,
  });

  final MediaUploadTask task;
  final VoidCallback onCancel;
  final VoidCallback onPause;
  final VoidCallback onResume;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    if (task.lifecycle == MediaUploadLifecycle.failed) {
      return EnterpriseMediaUploadFailedCard(
        task: task,
        onRetry: onRetry,
      );
    }
    if (task.lifecycle == MediaUploadLifecycle.retryScheduled) {
      return EnterpriseMediaUploadRetryTile(task: task);
    }
    return EnterpriseMediaUploadCard(
      task: task,
      onCancel: onCancel,
      onPause: onPause,
      onResume: onResume,
    );
  }
}
