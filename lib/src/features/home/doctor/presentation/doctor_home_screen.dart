import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:pranidoctor_mobile/src/features/home/doctor/presentation/veterinary_doctor_dashboard_screen.dart';

/// Doctor home / dashboard entry (workspace tab or standalone route).
///
/// See [VeterinaryDoctorDashboardScreen] for the full UI.
class DoctorHomeScreen extends ConsumerWidget {
  const DoctorHomeScreen({super.key, this.embedded = false});

  /// Inside [ProfessionalWorkspaceShellScreen] — shell owns the app bar.
  final bool embedded;

  static const routePath = '/doctor/home';
  static const routeName = 'doctorHome';

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return VeterinaryDoctorDashboardScreen(
      embedded: embedded,
      useShellTabBinder: embedded,
    );
  }
}
