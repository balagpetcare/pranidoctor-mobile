import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'package:pranidoctor_mobile/src/app/screen_padding.dart';
import 'package:pranidoctor_mobile/src/features/knowledge_hub/presentation/knowledge_hub_home_screen.dart';
import 'package:pranidoctor_mobile/src/features/profile/presentation/widgets/support_contact_card.dart';

class HelpSupportScreen extends StatelessWidget {
  const HelpSupportScreen({super.key});

  static const routePath = '/profile/help';
  static const routeName = 'profileHelp';

  @override
  Widget build(BuildContext context) {
    final pad = pdScreenPadding(context);
    final scheme = Theme.of(context).colorScheme;
    return Scaffold(
      appBar: AppBar(title: const Text('সাহায্য ও সহায়তা')),
      body: ListView(
        padding: pad.copyWith(top: 16, bottom: 32),
        children: [
          Text(
            'দ্রুত নির্দেশনা',
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 12),
          _tip(
            context,
            '১',
            'হোম থেকে সেবা বুকিং, প্রোভাইডার খোঁজা ও জ্ঞানকেন্দ্রে যান।',
          ),
          _tip(
            context,
            '২',
            '“আমার পশু” ট্যাবে আপনার পশুর প্রোফাইল যোগ ও সম্পাদনা করুন।',
          ),
          _tip(context, '৩', '“অনুরোধ” ট্যাবে সেবার অবস্থা দেখুন।'),
          const SizedBox(height: 20),
          Card(
            child: ListTile(
              leading: Icon(Icons.menu_book_outlined, color: scheme.primary),
              title: const Text('জ্ঞানকেন্দ্র'),
              subtitle: const Text('টিউটোরিয়াল ও শিক্ষামূলক লেখা'),
              trailing: const Icon(Icons.chevron_right),
              onTap: () => context.push(KnowledgeHubHomeScreen.routePath),
            ),
          ),
          const SizedBox(height: 20),
          Text('যোগাযোগ', style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 8),
          const SupportContactCard(),
          const SizedBox(height: 16),
          Text(
            'হোয়াটসঅ্যাপ বা অন্য অ্যাপ থেকে সরাসরি চ্যাট খোলার লিংক পরে সংযুক্ত করা যাবে। এখন উপরের নির্দেশ অনুযায়ী যোগাযোগ করুন।',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: scheme.onSurfaceVariant,
              height: 1.45,
            ),
          ),
        ],
      ),
    );
  }

  Widget _tip(BuildContext context, String n, String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CircleAvatar(
            radius: 14,
            child: Text(n, style: const TextStyle(fontSize: 12)),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              text,
              style: Theme.of(
                context,
              ).textTheme.bodyLarge?.copyWith(height: 1.4),
            ),
          ),
        ],
      ),
    );
  }
}
