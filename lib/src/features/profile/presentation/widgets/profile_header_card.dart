import 'package:flutter/material.dart';

import 'package:pranidoctor_mobile/src/app/screen_padding.dart';
import 'package:pranidoctor_mobile/src/features/profile/data/mobile_user_model.dart';

String profileRoleLabelBn(String? role) {
  final r = (role ?? 'customer').toLowerCase();
  switch (r) {
    case 'doctor':
      return 'চিকিৎসক';
    case 'technician':
      return 'টেকনিশিয়ান';
    case 'customer':
    default:
      return 'গ্রাহক';
  }
}

/// Header: avatar placeholder, name, role chip, phone, optional email/area rows.
class ProfileHeaderCard extends StatelessWidget {
  const ProfileHeaderCard({super.key, required this.user});

  final MobileUser user;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final maxW = pdReadableMaxWidth(context);
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Center(
          child: ConstrainedBox(
            constraints: BoxConstraints(maxWidth: maxW),
            child: Column(
              children: [
                CircleAvatar(
                  radius: 44,
                  backgroundColor: scheme.primaryContainer,
                  child: user.profilePhotoUrl != null
                      ? ClipOval(
                          child: Image.network(
                            user.profilePhotoUrl!,
                            width: 88,
                            height: 88,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) => Icon(
                              Icons.person,
                              size: 48,
                              color: scheme.onPrimaryContainer,
                            ),
                          ),
                        )
                      : Icon(
                          Icons.person,
                          size: 48,
                          color: scheme.onPrimaryContainer,
                        ),
                ),
                const SizedBox(height: 16),
                Text(
                  user.name,
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                const SizedBox(height: 8),
                Chip(
                  label: Text(profileRoleLabelBn(user.role)),
                  visualDensity: VisualDensity.compact,
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                ),
                const SizedBox(height: 12),
                _row(context, Icons.phone_outlined, user.phone),
                if (user.email != null && user.email!.isNotEmpty) ...[
                  const SizedBox(height: 6),
                  _row(context, Icons.email_outlined, user.email!),
                ],
                if (user.area != null && user.area!.isNotEmpty) ...[
                  const SizedBox(height: 6),
                  _row(context, Icons.place_outlined, user.area!),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _row(BuildContext context, IconData icon, String text) {
    final scheme = Theme.of(context).colorScheme;
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(icon, size: 20, color: scheme.primary),
        const SizedBox(width: 8),
        Flexible(
          child: Text(
            text,
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodyLarge,
          ),
        ),
      ],
    );
  }
}
