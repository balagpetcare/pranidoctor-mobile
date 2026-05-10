import 'package:flutter/material.dart';

import 'prani_empty_state.dart';
import 'prani_error_state.dart';
import 'prani_loading_state.dart';

/// Routes async list phases to shared loading / empty / error / ready widgets.
enum PraniAsyncListPhase { loading, empty, error, ready }

class PraniAsyncListStatus extends StatelessWidget {
  const PraniAsyncListStatus({
    super.key,
    required this.phase,
    required this.ready,
    this.loading,
    this.empty,
    this.error,
  });

  final PraniAsyncListPhase phase;
  final Widget ready;
  final Widget? loading;
  final Widget? empty;
  final Widget? error;

  @override
  Widget build(BuildContext context) {
    switch (phase) {
      case PraniAsyncListPhase.loading:
        return loading ??
            const PraniLoadingState(message: 'লোড হচ্ছে…', compact: false);
      case PraniAsyncListPhase.empty:
        return empty ??
            PraniEmptyState(
              title: 'কিছুই নেই',
              message: 'এখনও কোনো ফল নেই। পরে আবার চেষ্টা করুন।',
              boxed: false,
            );
      case PraniAsyncListPhase.error:
        return error ??
            PraniErrorState(
              title: 'লোড করা যায়নি',
              message: 'একটি সমস্যা হয়েছে। পরে আবার চেষ্টা করুন।',
              compact: true,
            );
      case PraniAsyncListPhase.ready:
        return ready;
    }
  }
}

/// Premium empty state for provider lists / home strips — boxed [PraniEmptyState].
class PraniAsyncEmptyCard extends StatelessWidget {
  const PraniAsyncEmptyCard({
    super.key,
    required this.title,
    required this.subtitle,
    required this.actionLabel,
    required this.onAction,
    this.icon = Icons.search_off_rounded,
    this.iconColor,
  });

  final String title;
  final String subtitle;
  final String actionLabel;
  final VoidCallback onAction;
  final IconData icon;
  final Color? iconColor;

  @override
  Widget build(BuildContext context) {
    return PraniEmptyState(
      title: title,
      message: subtitle,
      icon: icon,
      iconColor: iconColor,
      actionLabel: actionLabel,
      onAction: onAction,
      boxed: true,
    );
  }
}

/// Premium error state — boxed [PraniErrorState] with retry.
class PraniAsyncErrorCard extends StatelessWidget {
  const PraniAsyncErrorCard({
    super.key,
    required this.title,
    required this.subtitle,
    required this.actionLabel,
    required this.onAction,
    this.detail,
  });

  final String title;
  final String subtitle;
  final String actionLabel;
  final VoidCallback onAction;
  final String? detail;

  @override
  Widget build(BuildContext context) {
    return PraniErrorState(
      title: title,
      message: subtitle,
      retryLabel: actionLabel,
      onRetry: onAction,
      detail: detail,
      boxed: true,
      compact: false,
    );
  }
}

/// Compact loading block for horizontal strips / lists.
class PraniAsyncLoadingCard extends StatelessWidget {
  const PraniAsyncLoadingCard({super.key, this.height = 148});

  final double height;

  @override
  Widget build(BuildContext context) {
    return PraniLoadingState(height: height);
  }
}
