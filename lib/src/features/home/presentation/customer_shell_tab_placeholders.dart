import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/screen_padding.dart';
import '../../../core/widgets/shell_tab_placeholder.dart';
import '../../auth/login_entry_screen.dart';
import '../../session/application/session_notifier.dart';

/// M02 placeholder — হোম ট্যাব।
class HomeTabPlaceholderScreen extends StatelessWidget {
  const HomeTabPlaceholderScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const ShellTabPlaceholder(
      icon: Icons.home_outlined,
      title: 'হোম',
      message:
          'এখানে হোম ড্যাশবোর্ড, দ্রুত কাজ ও সূচনা থাকবে। বর্তমানে MVP প্লেসহোল্ডার।',
    );
  }
}

/// M02 placeholder — আমার পশু।
class AnimalsTabPlaceholderScreen extends StatelessWidget {
  const AnimalsTabPlaceholderScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const ShellTabPlaceholder(
      icon: Icons.pets_outlined,
      title: 'আমার পশু',
      message:
          'পোষা ও খামার প্রাণির প্রোফাইল ও তালিকা এখানে যুক্ত হবে। এখন শুধু প্লেসহোল্ডার।',
    );
  }
}

/// M02 placeholder — সেবা অনুরোধ।
class RequestsTabPlaceholderScreen extends StatelessWidget {
  const RequestsTabPlaceholderScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const ShellTabPlaceholder(
      icon: Icons.assignment_outlined,
      title: 'অনুরোধ',
      message: 'চিকিৎসা ও সেবার অনুরোধ তৈরি ও ট্র্যাক করার UI পরে যুক্ত হবে।',
    );
  }
}

/// M02 placeholder — সহায়তা / নলেজ।
class KnowledgeTabPlaceholderScreen extends StatelessWidget {
  const KnowledgeTabPlaceholderScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const ShellTabPlaceholder(
      icon: Icons.menu_book_outlined,
      title: 'সহায়তা ও নলেজ',
      message:
          'টিউটোরিয়াল, গাইড ও প্রাণস্বাস্থ্য টিপস এখানে থাকবে। বর্তমানে প্লেসহোল্ডার।',
    );
  }
}

/// M02 placeholder — প্রোফাইল + প্রস্থান।
class ProfileTabPlaceholderScreen extends ConsumerWidget {
  const ProfileTabPlaceholderScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final scheme = Theme.of(context).colorScheme;
    final pad = pdScreenPadding(context);

    return CustomScrollView(
      slivers: [
        const SliverAppBar.large(title: Text('প্রোফাইল')),
        SliverPadding(
          padding: pad.copyWith(bottom: 28),
          sliver: SliverToBoxAdapter(
            child: ShellTabPlaceholderBody(
              icon: Icons.person_outline,
              cardHeading: 'আপনার প্রোফাইল',
              message:
                  'অ্যাকাউন্ট, সেটিংস ও নোটিফিকেশন এখানে থাকবে। এখন MVP প্লেসহোল্ডার।',
              actions: [
                FilledButton.tonal(
                  onPressed: () async {
                    await ref.read(sessionNotifierProvider.notifier).signOut();
                    if (context.mounted) {
                      context.go(LoginEntryScreen.routePath);
                    }
                  },
                  child: const Text('প্রস্থান'),
                ),
                const SizedBox(height: 12),
                Text(
                  'প্রস্থান করলে আবার প্রবেশ স্ক্রিনে যাবেন।',
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: scheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
