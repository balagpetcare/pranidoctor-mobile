import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Bottom tab index inside [ProfessionalWorkspaceShellScreen].
class ProfessionalWorkspaceTabNotifier extends Notifier<int> {
  @override
  int build() => 0;

  void select(int index) {
    if (index < 0) return;
    state = index;
  }
}

final professionalWorkspaceTabIndexProvider =
    NotifierProvider<ProfessionalWorkspaceTabNotifier, int>(
  ProfessionalWorkspaceTabNotifier.new,
);
