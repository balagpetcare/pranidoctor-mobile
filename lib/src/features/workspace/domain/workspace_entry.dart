import 'professional_role.dart';
import 'workspace_status.dart';

enum WorkspaceBadgeTone { success, warning, danger, neutral }

class WorkspaceBadgeInfo {
  const WorkspaceBadgeInfo({
    required this.label,
    this.tone = WorkspaceBadgeTone.neutral,
  });

  final String label;
  final WorkspaceBadgeTone tone;
}

class WorkspaceEntry {
  const WorkspaceEntry({
    required this.role,
    required this.title,
    required this.subtitle,
    required this.status,
    required this.routePath,
    required this.ctaLabel,
    this.badge,
    this.isVerified = false,
    this.metadata = const {},
  });

  final ProfessionalRole role;
  final String title;
  final String subtitle;
  final WorkspaceStatus status;
  final String routePath;
  final String ctaLabel;
  final WorkspaceBadgeInfo? badge;
  final bool isVerified;
  final Map<String, Object?> metadata;
}

