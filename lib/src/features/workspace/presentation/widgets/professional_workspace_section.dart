import 'package:flutter/material.dart';

import 'package:pranidoctor_mobile/src/design_system/prani_tokens.dart';
import 'package:pranidoctor_mobile/src/design_system/widgets/prani_premium_card.dart';
import 'package:pranidoctor_mobile/src/design_system/widgets/prani_profile_section_header.dart';
import 'package:pranidoctor_mobile/src/features/workspace/domain/workspace_entry.dart';
import 'package:pranidoctor_mobile/src/features/workspace/presentation/widgets/workspace_card.dart';

class ProfessionalWorkspaceSection extends StatelessWidget {
  const ProfessionalWorkspaceSection({
    super.key,
    required this.entries,
    required this.onOpenWorkspace,
  });

  final List<WorkspaceEntry> entries;
  final ValueChanged<WorkspaceEntry> onOpenWorkspace;

  @override
  Widget build(BuildContext context) {
    if (entries.isEmpty) return const SizedBox.shrink();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const PraniProfileSectionHeader(title: 'পেশাদার ওয়ার্কস্পেস'),
        const SizedBox(height: PraniSpacing.md),
        ...entries.map((entry) {
          return Padding(
            padding: const EdgeInsets.only(bottom: PraniSpacing.md),
            child: WorkspaceCard(
              entry: entry,
              onTap: () => onOpenWorkspace(entry),
            ),
          );
        }),
      ],
    );
  }
}

class ProfessionalWorkspaceSectionLoading extends StatelessWidget {
  const ProfessionalWorkspaceSectionLoading({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const PraniProfileSectionHeader(title: 'পেশাদার ওয়ার্কস্পেস'),
        const SizedBox(height: PraniSpacing.md),
        PraniPremiumCard(
          padding: const EdgeInsets.all(PraniSpacing.md),
          child: Row(
            children: [
              SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: Theme.of(context).colorScheme.primary,
                ),
              ),
              const SizedBox(width: PraniSpacing.sm),
              Expanded(
                child: Text(
                  'ওয়ার্কস্পেস লোড হচ্ছে…',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

