import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:pranidoctor_mobile/src/app/routing/app_route_policy.dart';
import 'package:pranidoctor_mobile/src/features/profile/application/profile_dashboard_providers.dart';
import 'package:pranidoctor_mobile/src/features/profile/data/profile_api_exception.dart';
import 'package:pranidoctor_mobile/src/features/session/application/session_notifier.dart';
import 'package:pranidoctor_mobile/src/features/workspace/application/workspace_surface_provider.dart';
import 'package:pranidoctor_mobile/src/features/home/home_shell_screen.dart';

/// Resolves workspace role from `GET /api/mobile/profile/dashboard-context` after OTP/JWT sign-in.
class WorkspaceGateScreen extends ConsumerStatefulWidget {
  const WorkspaceGateScreen({super.key});

  static const routePath = '/session/workspace-gate';
  static const routeName = 'workspaceGate';

  @override
  ConsumerState<WorkspaceGateScreen> createState() =>
      _WorkspaceGateScreenState();
}

class _WorkspaceGateScreenState extends ConsumerState<WorkspaceGateScreen> {
  Object? _lastError;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _resolve());
  }

  Future<void> _resolve() async {
    final notifier = ref.read(sessionNotifierProvider.notifier);
    setState(() => _lastError = null);
    try {
      final repo = ref.read(profileDashboardRepositoryProvider);
      final ctx = await repo.fetchDashboardContext();
      if (!mounted) return;
      await notifier.applyResolvedWorkspace(ctx);
      ref.invalidate(profileDashboardContextProvider);
      if (!mounted) return;
      final session = ref.read(sessionNotifierProvider);
      final surfaceNotifier = ref.read(workspaceSurfaceProvider.notifier);
      await surfaceNotifier.setSurface(WorkspaceSurface.general);
      if (!mounted) return;
      context.go(defaultLocationForSession(session));
    } catch (e, _) {
      if (!mounted) return;
      setState(() => _lastError = e);
    }
  }

  Future<void> _giveUpAndUseCustomerHome() async {
    final notifier = ref.read(sessionNotifierProvider.notifier);
    await notifier.abortWorkspaceGateToCustomerFallback();
    ref.invalidate(profileDashboardContextProvider);
    if (!mounted) return;
    context.go(HomeShellScreen.routePath);
  }

  String _messageForError(Object e) {
    if (e is ProfileApiException && e.message.trim().isNotEmpty) {
      return e.message;
    }
    return 'ওয়ার্কস্পেস লোড করা যায়নি। গ্রাহক হোমে নিয়ে যাওয়া হচ্ছে।';
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Scaffold(
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (_lastError == null) ...[
                CircularProgressIndicator(color: scheme.primary),
                const SizedBox(height: 24),
                Text(
                  'আপনার অ্যাকাউন্ট সেট আপ করা হচ্ছে…',
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.titleMedium,
                ),
              ],
              if (_lastError != null) ...[
                const SizedBox(height: 16),
                Text(
                  _messageForError(_lastError!),
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: scheme.onSurfaceVariant,
                      ),
                ),
                const SizedBox(height: 16),
                FilledButton(
                  onPressed: _resolve,
                  child: const Text('আবার চেষ্টা করুন'),
                ),
                TextButton(
                  onPressed: _giveUpAndUseCustomerHome,
                  child: const Text('গ্রাহক হোমে যান'),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
