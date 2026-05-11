import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../app/screen_padding.dart';
import '../../core/assets/prani_assets.dart';
import '../../design_system/prani_tokens.dart';
import '../../design_system/widgets/prani_buttons.dart';
import '../home/home_shell_screen.dart';

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
      title: 'প্রাণী ডাক্তার',
      body:
          'খামারের প্রাণীর স্বাস্থ্যসেবা এখন হাতের মুঠোয়। ডাক্তার পরামর্শ, ওষুধ ও পণ্য, টিকাদান স্মরণী, স্বাস্থ্য রেকর্ড ও জরুরি সহায়তা—সব একসাথে।',
      imageAsset: PraniAssets.onboarding01ServiceOverviewBd,
      semanticLabel: 'প্রাণী ডাক্তার সেবার পরিচিতি',
    ),
    _OnboardPage(
      title: 'খামারভিত্তিক সেবা',
      body:
          'কৃষক, ডাক্তার ও মাঠপর্যায়ের সেবাকে এক জায়গায় যুক্ত করা হয়েছে, যাতে গরু, ছাগল, ভেড়া, হাঁস-মুরগি ও অন্যান্য খামারের প্রাণীর জন্য দ্রুত সহায়তা পাওয়া যায়।',
      imageAsset: PraniAssets.onboarding02FarmerVetConsultationBd,
      semanticLabel: 'খামারে ডাক্তার পরামর্শ',
    ),
    _OnboardPage(
      title: 'AI টেকনিশিয়ান ও ভেট সাপোর্ট',
      body:
          'কৃত্রিম প্রজনন, মাঠপর্যায়ের সেবা, স্বাস্থ্য পর্যবেক্ষণ ও প্রযুক্তিনির্ভর সহায়তার মাধ্যমে খামারের প্রাণীর যত্ন হবে আরও সহজ ও কার্যকর।',
      imageAsset: PraniAssets.onboarding03AiFieldSupportBd,
      semanticLabel: 'AI টেকনিশিয়ান ও মাঠপর্যায়ের সহায়তা',
    ),
    _OnboardPage(
      title: 'শুরু করুন',
      body:
          'আপনার লোকেশন দিন, প্রয়োজনীয় সেবা নির্বাচন করুন এবং নিরাপদ OTP লগইনের মাধ্যমে সহজেই সেবা গ্রহণ শুরু করুন।',
      imageAsset: PraniAssets.onboarding04GetStartedBd,
      semanticLabel: 'শুরু করার ধাপ',
    ),
  ];

  Future<void> _finish() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(OnboardingScreen._onboardingDoneKey, true);

    if (!mounted) return;
    context.go(HomeShellScreen.routePath);
  }

  void _goPrevious() {
    if (_page <= 0) return;

    _pageController.previousPage(
      duration: const Duration(milliseconds: 280),
      curve: Curves.easeOutCubic,
    );
  }

  void _goNext() {
    if (_page < _pages.length - 1) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 280),
        curve: Curves.easeOutCubic,
      );
      return;
    }

    _finish();
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final pad = pdScreenPadding(context);

    return Scaffold(
      backgroundColor: const Color(0xFF020D0B),
      body: Stack(
        fit: StackFit.expand,
        children: [
          PageView.builder(
            controller: _pageController,
            itemCount: _pages.length,
            onPageChanged: (i) {
              if (!mounted) return;
              setState(() => _page = i);
            },
            itemBuilder: (context, index) {
              final page = _pages[index];

              return _OnboardingImagePage(
                imageAsset: page.imageAsset,
                semanticLabel: page.semanticLabel,
              );
            },
          ),

          // Image readability overlay.
          Positioned.fill(
            child: IgnorePointer(
              child: DecoratedBox(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.black.withValues(alpha: 0.05),
                      Colors.transparent,
                      Colors.black.withValues(alpha: 0.22),
                      const Color(0xFF020D0B).withValues(alpha: 0.88),
                      const Color(0xFF020D0B).withValues(alpha: 0.98),
                    ],
                    stops: const [0.0, 0.35, 0.58, 0.78, 1.0],
                  ),
                ),
              ),
            ),
          ),

          Positioned(
            left: pad.left,
            right: pad.right,
            bottom: 0,
            child: SafeArea(
              top: false,
              child: Padding(
                padding: const EdgeInsets.only(
                  top: PraniSpacing.md,
                  bottom: PraniSpacing.lg,
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    AnimatedSwitcher(
                      duration: const Duration(milliseconds: 220),
                      switchInCurve: Curves.easeOut,
                      switchOutCurve: Curves.easeIn,
                      child: _OnboardingTextContent(
                        key: ValueKey<int>(_page),
                        title: _pages[_page].title,
                        body: _pages[_page].body,
                        textTheme: textTheme,
                      ),
                    ),

                    SizedBox(height: PraniSpacing.xl),

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
                                : PraniColors.white.withValues(alpha: 0.45),
                          ),
                        ),
                      ),
                    ),

                    SizedBox(height: PraniSpacing.xl),

                    Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        SizedBox(
                          width: 100,
                          child: Align(
                            alignment: Alignment.centerLeft,
                            child: _page > 0
                                ? TextButton(
                                    onPressed: _goPrevious,
                                    style: TextButton.styleFrom(
                                      foregroundColor: PraniColors.white
                                          .withValues(alpha: 0.92),
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
                              child: PraniPrimaryButton(
                                fullWidth: false,
                                label: _page < _pages.length - 1
                                    ? 'পরের ধাপ'
                                    : 'শুরু করুন',
                                onPressed: _goNext,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _OnboardingImagePage extends StatelessWidget {
  const _OnboardingImagePage({
    required this.imageAsset,
    required this.semanticLabel,
  });

  final String imageAsset;
  final String semanticLabel;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: semanticLabel,
      image: true,
      child: SizedBox.expand(
        child: FittedBox(
          fit: BoxFit.cover,
          alignment: Alignment.center,
          child: SizedBox(
            width: 9,
            height: 16,
            child: Image.asset(
              imageAsset,
              fit: BoxFit.cover,
              filterQuality: FilterQuality.high,
            ),
          ),
        ),
      ),
    );
  }
}

class _OnboardingTextContent extends StatelessWidget {
  const _OnboardingTextContent({
    super.key,
    required this.title,
    required this.body,
    required this.textTheme,
  });

  final String title;
  final String body;
  final TextTheme textTheme;

  @override
  Widget build(BuildContext context) {
    return ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: 520),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            title,
            textAlign: TextAlign.center,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: textTheme.headlineSmall?.copyWith(
              color: PraniColors.white,
              fontWeight: FontWeight.w800,
              height: 1.18,
              shadows: [
                Shadow(
                  color: Colors.black.withValues(alpha: 0.45),
                  blurRadius: 14,
                  offset: const Offset(0, 3),
                ),
              ],
            ),
          ),
          SizedBox(height: PraniSpacing.sm),
          Text(
            body,
            textAlign: TextAlign.center,
            maxLines: 4,
            overflow: TextOverflow.ellipsis,
            style: textTheme.bodyMedium?.copyWith(
              color: PraniColors.white.withValues(alpha: 0.92),
              height: 1.45,
              fontWeight: FontWeight.w500,
              shadows: [
                Shadow(
                  color: Colors.black.withValues(alpha: 0.55),
                  blurRadius: 12,
                  offset: const Offset(0, 2),
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
    required this.imageAsset,
    required this.semanticLabel,
  });

  final String title;
  final String body;
  final String imageAsset;
  final String semanticLabel;
}