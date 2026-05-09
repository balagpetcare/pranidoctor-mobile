import 'package:flutter/material.dart';

import 'package:pranidoctor_mobile/src/features/animals/presentation/animal_list_screen.dart';

/// Nested [Navigator] so list/detail/forms stack inside the bottom-nav tab.
class AnimalsTabScreen extends StatelessWidget {
  const AnimalsTabScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Navigator(
      initialRoute: '/',
      onGenerateRoute: (RouteSettings settings) {
        return MaterialPageRoute<void>(
          builder: (_) => const AnimalListScreen(),
          settings: settings,
        );
      },
    );
  }
}
