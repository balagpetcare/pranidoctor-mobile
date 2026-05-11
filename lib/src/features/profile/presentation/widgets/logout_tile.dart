import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:pranidoctor_mobile/src/features/profile/presentation/widgets/account_menu_tile.dart';
import 'package:pranidoctor_mobile/src/features/profile/presentation/widgets/logout_confirm_dialog.dart';

class LogoutTile extends ConsumerWidget {
  const LogoutTile({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final scheme = Theme.of(context).colorScheme;
    return AccountMenuTile(
      icon: Icons.logout_rounded,
      title: 'লগআউট',
      subtitle: 'নিরাপদে সেশন শেষ করুন',
      iconColor: scheme.error,
      titleColor: scheme.error,
      trailing: Icon(Icons.chevron_right, color: scheme.error),
      onTap: () => showPdLogoutConfirmAndExecute(context, ref),
      semanticLabel: 'লগআউট',
    );
  }
}
