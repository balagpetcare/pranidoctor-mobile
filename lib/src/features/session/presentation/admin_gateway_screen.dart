import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'package:pranidoctor_mobile/src/core/config/app_config.dart';
import 'package:url_launcher/url_launcher.dart';

/// Opens the web admin panel — mobile JWT does not carry panel sessions today.
class AdminGatewayScreen extends StatelessWidget {
  const AdminGatewayScreen({super.key});

  static const routePath = '/admin/gateway';
  static const routeName = 'adminGateway';

  Future<void> _openAdmin(BuildContext context) async {
    final base = AppConfig.resolvedApiBaseUrl;
    final uri = Uri.parse('$base/admin/login');
    final ok =
        await launchUrl(uri, mode: LaunchMode.externalApplication);
    if (!context.mounted) return;
    if (!ok) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          behavior: SnackBarBehavior.floating,
          content: Text('অ্যাডমিন প্যানেল খুলতে পারিনি।'),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Scaffold(
      appBar: AppBar(
        leading: BackButton(onPressed: () => context.pop()),
        title: const Text('অ্যাডমিন প্যানেল'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          Text(
            'ওয়েব অ্যাডমিন প্যানেল ব্রাউজারে খুলবে। মোবাইল অ্যাপ থেকে প্যানেল অ্যাক্সেস আলাদা লগইন প্রয়োজন হতে পারে।',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: scheme.onSurfaceVariant,
                  height: 1.45,
                ),
          ),
          const SizedBox(height: 24),
          FilledButton.icon(
            onPressed: () => _openAdmin(context),
            icon: const Icon(Icons.open_in_browser),
            label: const Text('প্যানেল খুলুন'),
          ),
        ],
      ),
    );
  }
}
