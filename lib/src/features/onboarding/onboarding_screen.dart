import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../app/screen_padding.dart';
import '../../core/assets/prani_assets.dart';
import '../../design_system/prani_tokens.dart';
import '../../design_system/widgets/prani_buttons.dart';
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
    context.go(LoginEntryScreen.routePath);
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  Widget _heroImage(BuildContext context, _OnboardPage p, ColorScheme scheme) {
    return AspectRatio(
      aspectRatio: 4 / 3,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(PraniRadii.lg),
        child: LayoutBuilder(
          builder: (context, constraints) {
            final maxPx = PraniAssetDecode.onboardingBdHeroMaxPx;
            final decodeW = PraniAssetDecode.cacheExtentPx(
              context,
              constraints.maxWidth,
              maxPx,
            );
            final decodeH = PraniAssetDecode.cacheExtentPx(
              context,
              constraints.maxHeight,
              maxPx,
            );
            return ColoredBox(
              color: scheme.surfaceContainerHighest,
              child: Image.asset(
                p.imageAsset,
                fit: BoxFit.cover,
                alignment: Alignment.center,
                gaplessPlayback: true,
                semanticLabel: p.semanticLabel,
                cacheWidth: decodeW,
                cacheHeight: decodeH,
                errorBuilder: (context, error, stackTrace) {
                  return Center(
                    child: Icon(
                      Icons.pets,
                      size: 56,
                      color: scheme.primary,
                      semanticLabel: p.semanticLabel,
                    ),
                  );
                },
              ),
            );
          },
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
    final textScaler = mq.textScaler.clamp(
      minScaleFactor: 0.85,
      maxScaleFactor: 1.35,
    );

    return Scaffold(
      backgroundColor: scheme.surface,
      body: SafeArea(
        bottom: false,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Padding(
              padding: EdgeInsets.fromLTRB(
                pad.left,
                PraniSpacing.sm,
                pad.right,
                PraniSpacing.xs,
              ),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  'স্বাগতম',
                  style: textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: scheme.onSurfaceVariant,
                  ),
                ),
              ),
            ),
            Expanded(
              child: PageView.builder(
                controller: _pageController,
                itemCount: _pages.length,
                onPageChanged: (i) => setState(() => _page = i),
                itemBuilder: (context, index) {
                  final p = _pages[index];
                  final maxContent = (mq.size.width - pad.left - pad.right)
                      .clamp(0.0, 460.0);
                  return MediaQuery(
                    data: mq.copyWith(textScaler: textScaler),
                    child: SingleChildScrollView(
                      padding: EdgeInsets.fromLTRB(
                        pad.left,
                        PraniSpacing.xs,
                        pad.right,
                        PraniSpacing.lg,
                      ),
                      physics: const BouncingScrollPhysics(),
                      child: Align(
                        alignment: Alignment.topCenter,
                        child: ConstrainedBox(
                          constraints: BoxConstraints(maxWidth: maxContent),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              _heroImage(context, p, scheme),
                              SizedBox(height: PraniSpacing.xl),
                              Text(
                                p.title,
                                textAlign: TextAlign.center,
                                style: textTheme.headlineSmall?.copyWith(
                                  fontWeight: FontWeight.w800,
                                  letterSpacing: -0.35,
                                  height: 1.22,
                                  color: scheme.onSurface,
                                ),
                              ),
                              SizedBox(height: PraniSpacing.md),
                              Text(
                                p.body,
                                textAlign: TextAlign.center,
                                style: textTheme.bodyLarge?.copyWith(
                                  color: scheme.onSurfaceVariant,
                                  height: 1.5,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
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
                bottomSafe + PraniSpacing.lg,
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
                            child: PraniPrimaryButton(
                              fullWidth: false,
                              label: _page < _pages.length - 1
                                  ? 'পরের ধাপ'
                                  : 'শুরু করুন',
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
    required this.imageAsset,
    required this.semanticLabel,
  });

  final String title;
  final String body;
  final String imageAsset;
  final String semanticLabel;
}
