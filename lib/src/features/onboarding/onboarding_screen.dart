import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../app/screen_padding.dart';
import '../../core/assets/prani_assets.dart';
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
      title: 'খামার ও গবাদি প্রাণীর সেবা',
      body:
          'গরু, ছাগল, ভেড়া, হাঁস, মুরগি ও খামারের প্রাণীর জন্য ডাক্তার ও AI টেকনিশিয়ান সেবা — জেলা ও গ্রাম পর্যায়ের খামারিদের জন্য।',
      icon: Icons.health_and_safety_outlined,
      illustrationAsset: PraniAssets.onboardingFarmer,
    ),
    _OnboardPage(
      title: 'ডাক্তার ও কৃত্রিম প্রজনন',
      body:
          'জরুরি ডাক্তার, হোম ভিজিট ও কৃত্রিম প্রজনন (AI টেকনিশিয়ান) — খামারের গবাদি পশুর স্বাস্থ্য ঘিরে।',
      icon: Icons.groups_outlined,
    ),
    _OnboardPage(
      title: 'শুরু করুন',
      body:
          'পশুর প্রোফাইল ও সেবার অনুরোধ এক অ্যাপে রাখুন; লগইন করে ডাক্তার বা টেকনিশিয়ান খুঁজুন।',
      icon: Icons.agriculture_outlined,
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
                      if (p.illustrationAsset != null)
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 8),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(14),
                            child: SizedBox(
                              width: double.infinity,
                              height: 200,
                              child: Image.asset(
                                p.illustrationAsset!,
                                fit: BoxFit.contain,
                                gaplessPlayback: true,
                                semanticLabel:
                                    'খামার ও গবাদি প্রাণীর চিত্রায়ণ',
                              ),
                            ),
                          ),
                        )
                      else
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
    this.illustrationAsset,
  });

  final String title;
  final String body;
  final IconData icon;
  final String? illustrationAsset;
}
