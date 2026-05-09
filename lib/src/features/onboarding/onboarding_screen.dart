import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../app/screen_padding.dart';
import '../../core/assets/prani_assets.dart';
import '../../design_system/prani_tokens.dart';
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

  double _illustrationHeight(double screenH, double screenW) {
    final h = screenH * 0.22;
    return h.clamp(132.0, (screenW * 0.52).clamp(156.0, 214.0));
  }

  Widget _illustrationSlot(
    BuildContext context,
    _OnboardPage p,
    double slotHeight,
    ColorScheme scheme,
  ) {
    final maxDecode = PraniAssetDecode.onboardingIllustrationMaxPx;

    if (p.illustrationAsset != null) {
      final cacheW = PraniAssetDecode.cacheExtentPx(
        context,
        MediaQuery.sizeOf(context).width - 32,
        maxDecode,
      );
      final cacheH = PraniAssetDecode.cacheExtentPx(
        context,
        slotHeight,
        maxDecode,
      );

      return ClipRRect(
        borderRadius: BorderRadius.circular(PraniRadii.lg),
        child: SizedBox(
          width: double.infinity,
          height: slotHeight,
          child: Image.asset(
            p.illustrationAsset!,
            fit: BoxFit.contain,
            gaplessPlayback: true,
            semanticLabel: 'খামার ও গবাদি প্রাণীর চিত্রায়ণ',
            cacheWidth: cacheW,
            cacheHeight: cacheH,
          ),
        ),
      );
    }

    final iconBox = (slotHeight * 0.72).clamp(112.0, 168.0);
    return DecoratedBox(
      decoration: BoxDecoration(
        color: scheme.primaryContainer.withValues(alpha: 0.55),
        borderRadius: BorderRadius.circular(PraniRadii.lg),
        border: Border.all(
          color: scheme.outlineVariant.withValues(alpha: 0.35),
        ),
      ),
      child: SizedBox(
        width: double.infinity,
        height: slotHeight,
        child: Center(
          child: Icon(
            p.icon,
            size: (iconBox * 0.36).clamp(56.0, 78.0),
            color: scheme.primary,
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final pad = pdScreenPadding(context);
    final mq = MediaQuery.of(context);
    final bottomSafe = mq.padding.bottom;
    final illH = _illustrationHeight(mq.size.height, mq.size.width);

    return Scaffold(
      appBar: AppBar(title: const Text('স্বাগতম')),
      body: SafeArea(
        bottom: false,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Expanded(
              child: PageView.builder(
                controller: _pageController,
                itemCount: _pages.length,
                onPageChanged: (i) => setState(() => _page = i),
                itemBuilder: (context, index) {
                  final p = _pages[index];
                  return SingleChildScrollView(
                    padding: EdgeInsets.fromLTRB(
                      pad.left,
                      PraniSpacing.sm,
                      pad.right,
                      PraniSpacing.md,
                    ),
                    physics: const BouncingScrollPhysics(),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        _illustrationSlot(context, p, illH, scheme),
                        SizedBox(height: PraniSpacing.section),
                        Text(
                          p.title,
                          textAlign: TextAlign.center,
                          style: textTheme.headlineSmall?.copyWith(
                            fontWeight: FontWeight.w700,
                            letterSpacing: -0.35,
                            height: 1.25,
                            color: scheme.onSurface,
                          ),
                        ),
                        const SizedBox(height: PraniSpacing.md),
                        Text(
                          p.body,
                          textAlign: TextAlign.center,
                          style: textTheme.bodyLarge?.copyWith(
                            color: scheme.onSurfaceVariant,
                            height: 1.48,
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
            Padding(
              padding: EdgeInsets.fromLTRB(
                pad.left,
                PraniSpacing.sm,
                pad.right,
                bottomSafe + PraniSpacing.md,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(
                      _pages.length,
                      (i) => AnimatedContainer(
                        duration: const Duration(milliseconds: 220),
                        curve: Curves.easeOut,
                        margin: const EdgeInsets.symmetric(horizontal: 5),
                        height: 8,
                        width: i == _page ? 22 : 8,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(999),
                          color: i == _page
                              ? scheme.primary
                              : scheme.outlineVariant.withValues(alpha: 0.85),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: PraniSpacing.lg),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      SizedBox(
                        width: 100,
                        child: Align(
                          alignment: Alignment.centerLeft,
                          child: _page > 0
                              ? TextButton(
                                  onPressed: () {
                                    _pageController.previousPage(
                                      duration: const Duration(
                                        milliseconds: 280,
                                      ),
                                      curve: Curves.easeOutCubic,
                                    );
                                  },
                                  style: TextButton.styleFrom(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: PraniSpacing.sm,
                                      vertical: PraniSpacing.sm,
                                    ),
                                  ),
                                  child: const Text('পিছনে'),
                                )
                              : const SizedBox(height: 48),
                        ),
                      ),
                      Expanded(
                        child: Align(
                          alignment: Alignment.centerRight,
                          child: ConstrainedBox(
                            constraints: const BoxConstraints(minWidth: 148),
                            child: FilledButton(
                              onPressed: _page < _pages.length - 1
                                  ? () {
                                      _pageController.nextPage(
                                        duration: const Duration(
                                          milliseconds: 280,
                                        ),
                                        curve: Curves.easeOutCubic,
                                      );
                                    }
                                  : _finish,
                              child: Text(
                                _page < _pages.length - 1
                                    ? 'পরের ধাপ'
                                    : 'শুরু করুন',
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
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
