import 'package:meta/meta.dart';

import 'package:pranidoctor_mobile/src/features/enterprise_insights/domain/sync_outbox_action.dart';

/// Executes one durable outbox action (HTTP dispatch, local bridge, etc.).
abstract class SyncActionExecutorPort {
  Future<SyncExecutionResult> execute(SyncOutboxAction action);
}

@immutable
class SyncExecutionResult {
  const SyncExecutionResult({
    required this.success,
    required this.retryable,
    this.message,
  });

  final bool success;
  final bool retryable;
  final String? message;

  const SyncExecutionResult.ok()
      : success = true,
        retryable = false,
        message = null;

  const SyncExecutionResult.retryLater(String message)
      : success = false,
        retryable = true,
        message = message;

  const SyncExecutionResult.giveUp(String message)
      : success = false,
        retryable = false,
        message = message;
}
