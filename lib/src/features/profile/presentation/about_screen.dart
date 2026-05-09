import 'package:flutter/material.dart';

import 'package:pranidoctor_mobile/src/app/screen_padding.dart';

/// Matches `pubspec.yaml` version until `package_info_plus` is added.
const String kPraniDoctorAppVersionLabel = '১.০.০ (১)';

class AboutScreen extends StatelessWidget {
  const AboutScreen({super.key});

  static const routePath = '/profile/about';
  static const routeName = 'profileAbout';

  static const String _domain = 'https://pranidoctor.com/';

  @override
  Widget build(BuildContext context) {
    final pad = pdScreenPadding(context);
    final scheme = Theme.of(context).colorScheme;
    return Scaffold(
      appBar: AppBar(title: const Text('আমাদের সম্পর্কে')),
      body: ListView(
        padding: pad.copyWith(top: 24, bottom: 32),
        children: [
          Icon(Icons.pets, size: 64, color: scheme.primary),
          const SizedBox(height: 16),
          Text(
            'প্রাণি ডাক্তার',
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.headlineSmall,
          ),
          const SizedBox(height: 4),
          Text(
            'Prani Doctor',
            textAlign: TextAlign.center,
            style: Theme.of(
              context,
            ).textTheme.titleMedium?.copyWith(color: scheme.onSurfaceVariant),
          ),
          const SizedBox(height: 16),
          Text(
            'পোষা ও খামার প্রাণির যত্ন, চিকিৎসক ও টেকনিশিয়ানের সেবা — এক অ্যাপে। '
            'বাংলাদেশের প্রাণিসম্পদ মালিকদের জন্য তৈরি।',
            textAlign: TextAlign.center,
            style: Theme.of(
              context,
            ).textTheme.bodyLarge?.copyWith(height: 1.45),
          ),
          const SizedBox(height: 28),
          Text('ওয়েবসাইট', style: Theme.of(context).textTheme.titleSmall),
          const SizedBox(height: 8),
          SelectableText(
            _domain,
            style: Theme.of(
              context,
            ).textTheme.bodyLarge?.copyWith(color: scheme.primary),
          ),
          const SizedBox(height: 24),
          Text('ভার্সন', style: Theme.of(context).textTheme.titleSmall),
          const SizedBox(height: 8),
          Text(
            kPraniDoctorAppVersionLabel,
            style: Theme.of(context).textTheme.bodyLarge,
          ),
          const SizedBox(height: 8),
          Text(
            'স্টোর বিল্ডের জন্য পরে অটো ভার্সন দেখানো হতে পারে।',
            style: Theme.of(
              context,
            ).textTheme.bodySmall?.copyWith(color: scheme.onSurfaceVariant),
          ),
        ],
      ),
    );
  }
}
