import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:pranidoctor_mobile/src/design_system/prani_tokens.dart';
import 'package:pranidoctor_mobile/src/design_system/widgets/prani_premium_card.dart';
import 'package:pranidoctor_mobile/src/features/ai_technician_application/presentation/ai_technician_application_entry_screen.dart';
import 'package:pranidoctor_mobile/src/features/ai_technician_application/presentation/ai_technician_application_status_screen.dart';
import 'package:pranidoctor_mobile/src/features/profile/application/professional_profile_state.dart';
import 'package:pranidoctor_mobile/src/features/profile/application/profile_dashboard_providers.dart';
import 'package:pranidoctor_mobile/src/features/profile/presentation/widgets/professional_state_views/approved_professional_view.dart';
import 'package:pranidoctor_mobile/src/features/profile/presentation/widgets/professional_state_views/draft_application_view.dart';
import 'package:pranidoctor_mobile/src/features/profile/presentation/widgets/professional_state_views/no_application_view.dart';
import 'package:pranidoctor_mobile/src/features/profile/presentation/widgets/professional_state_views/pending_review_view.dart';
import 'package:pranidoctor_mobile/src/features/profile/presentation/widgets/professional_state_views/rejected_application_view.dart';
import 'package:pranidoctor_mobile/src/features/professional_profile/presentation/professional_profile_hub_screen.dart';
import 'package:pranidoctor_mobile/src/features/professional_verification/presentation/professional_verification_workflow_screen.dart';
import 'package:pranidoctor_mobile/src/features/workspace/application/current_workspace_provider.dart';
import 'package:pranidoctor_mobile/src/features/workspace/application/workspace_surface_provider.dart';
import 'package:pranidoctor_mobile/src/features/workspace/domain/professional_role.dart';

class ProfessionalDashboardCard extends ConsumerStatefulWidget {
  const ProfessionalDashboardCard({super.key});

  @override
  ConsumerState<ProfessionalDashboardCard> createState() =>
      _ProfessionalDashboardCardState();
}

class _ProfessionalDashboardCardState
    extends ConsumerState<ProfessionalDashboardCard> {
  bool _actionBusy = false;

  Future<void> _runAction(Future<void> Function() action) async {
    if (_actionBusy) return;
    setState(() => _actionBusy = true);
    try {
      await action();
    } finally {
      if (mounted) {
        setState(() => _actionBusy = false);
      }
    }
  }

  Future<void> _safePush(String location) async {
    try {
      await context.push(location);
    } catch (e, stack) {
      assert(() {
        debugPrint('ProfessionalDashboardCard: push failed: $e\n$stack');
        return true;
      }());
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          behavior: SnackBarBehavior.floating,
          content: Text('এই পাতাটি খুলতে পারিনি।'),
        ),
      );
    }
  }

  Future<void> _openWorkspace(ProfessionalProfileRole role) async {
    await ref
        .read(workspaceSurfaceProvider.notifier)
        .setSurface(WorkspaceSurface.professional);
    await ref
        .read(currentWorkspaceProvider.notifier)
        .setWorkspace(role.workspaceRole);
    if (!mounted) return;
    context.go(role.workspaceRole.routePath);
  }

  Future<void> _openDraftFlow(ProfessionalProfileRole role) async {
    if (role == ProfessionalProfileRole.aiTechnician) {
      await _safePush(AiTechnicianApplicationEntryScreen.routePath);
      return;
    }
    await _safePush(ProfessionalProfileHubScreen.routeLocation(role.persona));
  }

  Future<void> _openStatusFlow(ProfessionalProfileRole role) async {
    if (role == ProfessionalProfileRole.aiTechnician) {
      await _safePush(AiTechnicianApplicationStatusScreen.routePath);
      return;
    }
    await _safePush(ProfessionalVerificationWorkflowScreen.routeLocation(
      role.persona,
    ));
  }

  @override
  Widget build(BuildContext context) {
    final async = ref.watch(professionalProfileStateProvider);
    return async.when(
      loading: () => const _ProfessionalDashboardCardLoading(),
      error: (error, stack) => _ProfessionalDashboardCardError(
        onRetry: () => _runAction(() async {
          ref.invalidate(professionalProfileStateProvider);
          ref.invalidate(profileDashboardContextProvider);
        }),
        busy: _actionBusy,
      ),
      data: (state) => _buildStateView(state),
    );
  }

  Widget _buildStateView(ProfessionalProfileState state) {
    switch (state.status) {
      case ProfessionalProfileStatus.none:
        return NoApplicationView(
          actionsDisabled: _actionBusy,
          onApplyDoctor: () => _runAction(() async {
            await _openDraftFlow(ProfessionalProfileRole.doctor);
          }),
          onApplyAiTechnician: () => _runAction(() async {
            await _openDraftFlow(ProfessionalProfileRole.aiTechnician);
          }),
        );
      case ProfessionalProfileStatus.draft:
        return DraftApplicationView(
          actionsDisabled: _actionBusy,
          completionPercent: state.completionPercent,
          onContinue: () => _runAction(() async {
            final role = state.role ?? ProfessionalProfileRole.aiTechnician;
            await _openDraftFlow(role);
          }),
        );
      case ProfessionalProfileStatus.pending:
        return PendingReviewView(
          actionsDisabled: _actionBusy,
          onViewApplication: () => _runAction(() async {
            final role = state.role ?? ProfessionalProfileRole.aiTechnician;
            await _openStatusFlow(role);
          }),
        );
      case ProfessionalProfileStatus.rejected:
        return RejectedApplicationView(
          actionsDisabled: _actionBusy,
          onUpdateApplication: () => _runAction(() async {
            final role = state.role ?? ProfessionalProfileRole.aiTechnician;
            await _openDraftFlow(role);
          }),
          onViewFeedback: () => _runAction(() async {
            final role = state.role ?? ProfessionalProfileRole.aiTechnician;
            await _openStatusFlow(role);
          }),
        );
      case ProfessionalProfileStatus.approved:
        final role = state.role ?? ProfessionalProfileRole.aiTechnician;
        return ApprovedProfessionalView(
          actionsDisabled: _actionBusy,
          title: role.labelBn,
          subtitle: role.subtitleBn,
          icon: role.icon,
          onOpenDashboard: () => _runAction(() async {
            await _openWorkspace(role);
          }),
        );
    }
  }
}

/// Compact loading state for professional dashboard.
class _ProfessionalDashboardCardLoading extends StatelessWidget {
  const _ProfessionalDashboardCardLoading();

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return PraniPremiumCard(
      padding: const EdgeInsets.symmetric(
        horizontal: PraniSpacing.md,
        vertical: PraniSpacing.sm,
      ),
      child: Row(
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: scheme.primaryContainer.withValues(alpha: 0.5),
            ),
            child: Padding(
              padding: const EdgeInsets.all(8),
              child: CircularProgressIndicator(
                strokeWidth: 2,
                color: scheme.primary,
              ),
            ),
          ),
          const SizedBox(width: PraniSpacing.sm),
          Expanded(
            child: Text(
              'Loading…',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: scheme.onSurfaceVariant,
                    fontSize: 12,
                  ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Compact error state for professional dashboard.
class _ProfessionalDashboardCardError extends StatelessWidget {
  const _ProfessionalDashboardCardError({
    required this.onRetry,
    required this.busy,
  });

  final VoidCallback onRetry;
  final bool busy;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return PraniPremiumCard(
      padding: const EdgeInsets.symmetric(
        horizontal: PraniSpacing.md,
        vertical: PraniSpacing.sm,
      ),
      child: Row(
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: scheme.errorContainer.withValues(alpha: 0.5),
            ),
            child: Icon(
              Icons.error_outline_rounded,
              color: scheme.error,
              size: 20,
            ),
          ),
          const SizedBox(width: PraniSpacing.sm),
          Expanded(
            child: Text(
              'লোড হয়নি',
              style: textTheme.bodySmall?.copyWith(
                color: scheme.onSurfaceVariant,
                fontSize: 12,
              ),
            ),
          ),
          Material(
            color: Colors.transparent,
            borderRadius: BorderRadius.circular(8),
            child: InkWell(
              onTap: busy ? null : onRetry,
              borderRadius: BorderRadius.circular(8),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(
                  border: Border.all(color: scheme.outline),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: busy
                    ? SizedBox(
                        width: 14,
                        height: 14,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: scheme.primary,
                        ),
                      )
                    : Text(
                        'Retry',
                        style: textTheme.labelSmall?.copyWith(
                          color: scheme.primary,
                          fontWeight: FontWeight.w600,
                          fontSize: 12,
                        ),
                      ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
