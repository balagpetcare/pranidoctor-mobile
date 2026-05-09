import 'package:flutter/material.dart';

import 'package:pranidoctor_mobile/src/features/providers/presentation/doctor_list_screen.dart';

/// Bottom-nav tab body: nested stack so [DoctorListScreen] pushes stay under the tab.
class DoctorTabScreen extends StatelessWidget {
  const DoctorTabScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Navigator(
      onGenerateRoute: (RouteSettings settings) {
        return MaterialPageRoute<void>(
          builder: (_) => const DoctorListScreen(),
          settings: settings,
        );
      },
    );
  }
}
