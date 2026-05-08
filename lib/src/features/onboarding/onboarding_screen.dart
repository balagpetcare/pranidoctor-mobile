import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../app/screen_padding.dart';
import '../auth/login_entry_screen.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  static const routePath = '/onboarding';
  static const routeName = 'onboarding';

  static const _onboardingDoneKey = 'pd_onboarding_done';

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _pageController = PageController();
  int _page = 0;

  static const _pages = <_OnboardPage>[
    _OnboardPage(
      title: 'আপনার প্রাণির জন্য দ্রুত সাহায্য',
      body:
          'জরুরি অবস্থায় ডাক্তার ডাকুন, নিকটস্থ চিকিৎসক খুঁজুন — সবকিছু গ্রাহকের ভাষায় ও সহজ ধাপে।',
      icon: Icons.health_and_safety_outlined,
    ),
    _OnboardPage(
      title: 'ডাক্তার ও টেকনিশিয়ান',
      body:
          'পরামর্শ, চিকিৎসার ইতিহাস ও টিউটোরিয়াল — এক জায়গায়। পরের আপডেটে আসল সেবা যুক্ত হবে।',
      icon: Icons.groups_outlined,
    ),
    _OnboardPage(
      title: 'শুরু করুন',
      body:
          'এখন অ্যাপটি চালু করুন; পরবর্তী কাজে লগইন ও সার্ভার সংযোগ যুক্ত হবে।',
      icon: Icons.pets,
    ),
  ];

  Future<void> _finish() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(OnboardingScreen._onboardingDoneKey, true);
    if (!mounted) return;
    context.go(LoginEntryScreen.routePath);
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final pad = pdScreenPadding(context);
    return Scaffold(
      appBar: AppBar(title: const Text('স্বাগতম')),
      body: Column(
        children: [
          Expanded(
            child: PageView.builder(
              controller: _pageController,
              itemCount: _pages.length,
              onPageChanged: (i) => setState(() => _page = i),
              itemBuilder: (context, index) {
                final p = _pages[index];
                return Padding(
                  padding: pad.copyWith(top: 8, bottom: 16),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(p.icon, size: 76, color: scheme.primary),
                      const SizedBox(height: 24),
                      Text(
                        p.title,
                        textAlign: TextAlign.center,
                        style: Theme.of(context).textTheme.headlineSmall,
                      ),
                      const SizedBox(height: 14),
                      Text(
                        p.body,
                        textAlign: TextAlign.center,
                        style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                          color: scheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(
              _pages.length,
              (i) => Padding(
                padding: const EdgeInsets.symmetric(horizontal: 4),
                child: CircleAvatar(
                  radius: 5,
                  backgroundColor: i == _page
                      ? scheme.primary
                      : scheme.outlineVariant,
                ),
              ),
            ),
          ),
          const SizedBox(height: 16),
          Padding(
            padding: pad.copyWith(bottom: 24),
            child: Row(
              children: [
                if (_page > 0)
                  TextButton(
                    onPressed: () {
                      _pageController.previousPage(
                        duration: const Duration(milliseconds: 280),
                        curve: Curves.easeOut,
                      );
                    },
                    child: const Text('পিছনে'),
                  ),
                const Spacer(),
                if (_page < _pages.length - 1)
                  FilledButton(
                    onPressed: () {
                      _pageController.nextPage(
                        duration: const Duration(milliseconds: 280),
                        curve: Curves.easeOut,
                      );
                    },
                    child: const Text('পরের ধাপ'),
                  )
                else
                  FilledButton(
                    onPressed: _finish,
                    child: const Text('শুরু করুন'),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _OnboardPage {
  const _OnboardPage({
    required this.title,
    required this.body,
    required this.icon,
  });

  final String title;
  final String body;
  final IconData icon;
}
