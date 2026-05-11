import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'package:pranidoctor_mobile/src/design_system/prani_tokens.dart';
import 'package:pranidoctor_mobile/src/features/ai_technician_application/presentation/ai_technician_application_entry_screen.dart';
import 'package:pranidoctor_mobile/src/features/ai_technician_application/presentation/ai_technician_application_status_screen.dart';

Future<void> _safePushProfileRoute(BuildContext context, String location) async {
  try {
    await context.push(location);
  } catch (_) {
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          behavior: SnackBarBehavior.floating,
          content: Text('এই পাতাটি খুলতে পারিনি।'),
        ),
      );
    }
  }
}

typedef _BannerCopy = ({IconData icon, String title, String body});

_BannerCopy _bannerCopyForStatus(String raw) {
  final st = raw.trim().toUpperCase();
  switch (st) {
    case 'DRAFT':
      return (
        icon: Icons.edit_note_outlined,
        title: 'খসড়া আবেদন',
        body:
            'আপনার এআই টেকনিশিয়ান আবেদন এখনো সম্পূর্ণ হয়নি। চালিয়ে যেতে ট্যাপ করুন।',
      );
    case 'NEEDS_CORRECTION':
      return (
        icon: Icons.feedback_outlined,
        title: 'সংশোধন প্রয়োজন',
        body:
            'আপনার আবেদনটি সংশোধনের জন্য ফেরত পাঠানো হয়েছে। বিস্তারিত দেখে আপডেট করুন।',
      );
    case 'REJECTED':
      return (
        icon: Icons.cancel_outlined,
        title: 'আবেদন গ্রহণ হয়নি',
        body: 'আপনার আবেদনে গ্রহণ করা হয়নি। প্রয়োজনে আবার আবেদন করতে পারেন।',
      );
    case 'SUSPENDED':
      return (
        icon: Icons.pause_circle_outline,
        title: 'সেবা স্থগিত',
        body:
            'আপনার এআই টেকনিশিয়ান সেবা সাময়িকভাবে বন্ধ আছে। সাধারণ প্রোফাইল ব্যবহার চালিয়ে যেতে পারবেন।',
      );
    case 'SUBMITTED':
    case 'UNDER_REVIEW':
    case 'PENDING':
    case 'PENDING_VERIFICATION':
      return (
        icon: Icons.hourglass_top_outlined,
        title: 'পর্যালোচনাধীন',
        body:
            'আপনার এআই টেকনিশিয়ান আবেদন পর্যালোচনাধীন। ফলাফল জানতে বিস্তারিত দেখুন।',
      );
    default:
      return (
        icon: Icons.info_outline_rounded,
        title: 'এআই টেকনিশিয়ান আবেদন',
        body: 'আপনার আবেদনের অবস্থা দেখতে বিস্তারিতে যান।',
      );
  }
}

/// In-profile notice for AI technician application lifecycle (non-approved).
class ProfileAiTechnicianApplicationStatusBanner extends StatelessWidget {
  const ProfileAiTechnicianApplicationStatusBanner({
    super.key,
    required this.applicationStatus,
  });

  final String applicationStatus;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final st = applicationStatus.trim().toUpperCase();
    final copy = _bannerCopyForStatus(st);

    return DecoratedBox(
      decoration: BoxDecoration(
        color: scheme.primaryContainer.withValues(alpha: 0.35),
        borderRadius: BorderRadius.circular(PraniRadii.lg),
        border: Border.all(
          color: scheme.outlineVariant.withValues(alpha: 0.65),
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(PraniSpacing.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(copy.icon, color: scheme.primary, size: 24),
                const SizedBox(width: PraniSpacing.sm),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        copy.title,
                        style: textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.w700,
                          color: scheme.onSurface,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        copy.body,
                        style: textTheme.bodySmall?.copyWith(
                          color: scheme.onSurfaceVariant,
                          height: 1.4,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: PraniSpacing.md),
            Wrap(
              alignment: WrapAlignment.end,
              spacing: 8,
              runSpacing: 8,
              children: [
                TextButton(
                  onPressed: () => _safePushProfileRoute(
                    context,
                    AiTechnicianApplicationStatusScreen.routePath,
                  ),
                  child: const Text('বিস্তারিত দেখুন'),
                ),
                if (st == 'REJECTED' || st == 'NEEDS_CORRECTION' || st == 'DRAFT')
                  FilledButton.tonal(
                    onPressed: () => _safePushProfileRoute(
                      context,
                      AiTechnicianApplicationEntryScreen.routePath,
                    ),
                    child: Text(st == 'REJECTED' ? 'পুনরায় আবেদন' : 'আবেদন চালিয়ে যান'),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
