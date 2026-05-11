import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:pranidoctor_mobile/src/features/session/application/session_notifier.dart';
import 'package:pranidoctor_mobile/src/features/workspace/domain/professional_role.dart';

final professionalRoleProvider = Provider<ProfessionalRole?>((ref) {
  final role = ref.watch(sessionNotifierProvider.select((s) => s.role));
  return ProfessionalRoleX.fromAppRole(role);
});

