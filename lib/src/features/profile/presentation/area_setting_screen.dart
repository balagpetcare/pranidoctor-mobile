import 'package:flutter/material.dart';

import 'package:pranidoctor_mobile/src/features/profile/presentation/edit_profile_location_screen.dart';

/// Back-compat route: same UI as [EditProfileLocationScreen].
class AreaSettingScreen extends StatelessWidget {
  const AreaSettingScreen({super.key});

  static const routePath = '/profile/area';
  static const routeName = 'profileArea';

  @override
  Widget build(BuildContext context) => const EditProfileLocationScreen();
}
