import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../app/screen_padding.dart';
import '../../core/constants/pd_radii.dart';
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
          'জরুরি অবস্থায় ডাক্তার খুঁজুন, সেবা অনুরোধ করুন — সবকিছু বাংলায় ও সহজ ধাপে।',
      icon: Icons.health_and_safety_outlined,
    ),
    _OnboardPage(
      title: 'ডাক্তার ও টেকনিশিয়ান',
      body:
          'পরামর্শ, ইতিহাস ও শেখার উপকরণ এক জায়গায়। সেবার বিস্তারিত ধাপে ধাপে যুক্ত হবে।',
      icon: Icons.groups_outlined,
    ),
    _OnboardPage(
      title: 'শুরু করুন',
      body:
          'পরবর্তীতে লগইন দিয়ে আপনার তথ্য সংরক্ষিত থাকবে। এখন প্রবেশ স্ক্রিনে যান।',
      icon: Icons.pets,
    ),
  ];

  Future<void> _markDoneAndGoLogin() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(OnboardingScreen._onboardingDoneKey, true);
    if (!mounted) return;
    context.go(LoginEntryScreen.routePath);
  }

  void _skip() => _markDoneAndGoLogin();

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
      backgroundColor: scheme.surface,
      appBar: AppBar(
        title: const Text('স্বাগতম'),
        actions: [TextButton(onPressed: _skip, child: const Text('এড়িয়ে যান'))],
      ),
      body: Column(
        children: [
          Expanded(
            child: LayoutBuilder(
              builder: (context, constraints) {
                final w = constraints.maxWidth - pad.horizontal;
                final cardH = (w * 16 / 9).clamp(
                  280.0,
                  constraints.maxHeight * 0.72,
                );

                return PageView.builder(
                  controller: _pageController,
                  itemCount: _pages.length,
                  onPageChanged: (i) => setState(() => _page = i),
                  itemBuilder: (context, index) {
                    final p = _pages[index];
                    return Padding(
                      padding: pad.copyWith(top: 12, bottom: 8),
                      child: Center(
                        child: SizedBox(
                          width: w.clamp(0.0, 400),
                          height: cardH,
                          child: Card(
                            elevation: 0,
                            color: scheme.surfaceContainerLowest,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(PdRadii.lg),
                              side: BorderSide(color: scheme.outlineVariant),
                            ),
                            child: Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: PdRadii.lg,
                                vertical: PdRadii.lg,
                              ),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(p.icon, size: 64, color: scheme.primary),
                                  const SizedBox(height: 20),
                                  Text(
                                    p.title,
                                    textAlign: TextAlign.center,
                                    style: Theme.of(context)
                                        .textTheme
                                        .titleLarge
                                        ?.copyWith(fontWeight: FontWeight.w600),
                                  ),
                                  const SizedBox(height: 14),
                                  Text(
                                    p.body,
                                    textAlign: TextAlign.center,
                                    style: Theme.of(context).textTheme.bodyLarge
                                        ?.copyWith(
                                          color: scheme.onSurfaceVariant,
                                        ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                    );
                  },
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
          const SizedBox(height: 12),
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
                    child: const Text('চালিয়ে যান'),
                  )
                else
                  FilledButton(
                    onPressed: _markDoneAndGoLogin,
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
