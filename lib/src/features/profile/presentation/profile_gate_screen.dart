import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:pranidoctor_mobile/src/features/profile/presentation/profile_home_screen.dart';

/// Role-aware entry for the bottom-nav Profile tab.
class ProfileGateScreen extends ConsumerStatefulWidget {
  const ProfileGateScreen({super.key});

  @override
  ConsumerState<ProfileGateScreen> createState() => _ProfileGateScreenState();
}

class _ProfileGateScreenState extends ConsumerState<ProfileGateScreen> {
  @override
  Widget build(BuildContext context) {
    return const ProfileHomeScreen();
  }
}
