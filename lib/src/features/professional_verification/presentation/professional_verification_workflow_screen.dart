import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:pranidoctor_mobile/src/design_system/prani_tokens.dart';
import 'package:pranidoctor_mobile/src/design_system/widgets/prani_scaffold.dart';
import 'package:pranidoctor_mobile/src/features/professional_profile/domain/professional_persona.dart';
import 'package:pranidoctor_mobile/src/features/professional_verification/presentation/professional_verification_workflow_panel.dart';

/// Full-screen verification hub (drawer / deep link).
class ProfessionalVerificationWorkflowScreen extends ConsumerWidget {
  const ProfessionalVerificationWorkflowScreen({super.key, required this.persona});

  final ProfessionalPersona persona;

  static const routePath = '/professional/verification/:persona';

  static String routeLocation(ProfessionalPersona p) =>
      '/professional/verification/${p.routeSegment}';

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return PraniScaffold(
      title: 'যাচাইকরণ ওয়ার্কফ্লো',
      subtitle: persona.labelBn,
      body: ListView(
        padding: const EdgeInsets.all(PraniSpacing.lg),
        children: [
          ProfessionalVerificationWorkflowPanel(persona: persona),
        ],
      ),
    );
  }
}
