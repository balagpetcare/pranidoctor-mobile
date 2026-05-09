import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:pranidoctor_mobile/src/app/screen_padding.dart';

/// Placeholder support / WhatsApp info — no `url_launcher`; copy-friendly.
class SupportContactCard extends StatelessWidget {
  const SupportContactCard({super.key});

  static const String _placeholderLine =
      'হোয়াটসঅ্যাপে সরাসরি যোগাযোগ শীঘ্রই যুক্ত করা হবে। এখন নিচের নম্বরটি কপি করে যোগাযোগ করতে পারেন।';

  /// Demo placeholder — replace when backend provides support number.
  static const String supportPhoneDisplay = '+৮৮০ ১XXX-XXXXXX';

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final pad = pdScreenPadding(context).horizontal;
    return Card(
      child: Padding(
        padding: EdgeInsets.fromLTRB(pad, 16, pad, 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.support_agent_outlined, color: scheme.primary),
                const SizedBox(width: 8),
                Text(
                  'যোগাযোগ ও সহায়তা',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
              ],
            ),
            const SizedBox(height: 10),
            Text(
              _placeholderLine,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: scheme.onSurfaceVariant,
                height: 1.4,
              ),
            ),
            const SizedBox(height: 12),
            SelectableText(
              supportPhoneDisplay,
              style: Theme.of(context).textTheme.titleSmall,
            ),
            const SizedBox(height: 8),
            Align(
              alignment: AlignmentDirectional.centerStart,
              child: TextButton.icon(
                onPressed: () async {
                  await Clipboard.setData(
                    const ClipboardData(text: supportPhoneDisplay),
                  );
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('ক্লিপবোর্ডে কপি হয়েছে')),
                    );
                  }
                },
                icon: const Icon(Icons.copy_outlined, size: 18),
                label: const Text('নম্বর কপি করুন'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
