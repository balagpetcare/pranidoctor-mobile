import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../core/assets/prani_assets.dart';
import '../../design_system/prani_tokens.dart';
import '../home/home_shell_screen.dart';
import '../onboarding/onboarding_screen.dart';
import '../session/application/session_notifier.dart';

class SplashScreen extends ConsumerStatefulWidget {
  const SplashScreen({super.key});

  static const routePath = '/splash';
  static const routeName = 'splash';

  static const _onboardingDoneKey = 'pd_onboarding_done';

  @override
  ConsumerState<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends ConsumerState<SplashScreen> {
  bool _imageReady = false;
  bool _imageFailed = false;
  bool _prefsFailed = false;

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      setState(() => _imageReady = true);
      _goNext();
    });
  }

  Future<void> _goNext() async {
    if (mounted) {
      setState(() => _prefsFailed = false);
    }

    const minBrandMs = 700;
    final minDelay = Future<void>.delayed(
      const Duration(milliseconds: minBrandMs),
    );

    try {
      await Future.wait<void>([
        minDelay,
        ref.read(sessionNotifierProvider.notifier).hydrateFromStorage(),
      ]);
    } catch (e, st) {
      debugPrint('hydrateFromStorage failed: $e');
      debugPrintStack(stackTrace: st);
    }

    if (!mounted) return;

    try {
      final prefs = await SharedPreferences.getInstance();
      final done = prefs.getBool(SplashScreen._onboardingDoneKey) ?? false;

      if (!mounted) return;

      if (!done) {
        context.go(OnboardingScreen.routePath);
      } else {
        context.go(HomeShellScreen.routePath);
      }
    } catch (e, st) {
      debugPrint('splash navigation failed: $e');
      debugPrintStack(stackTrace: st);

      if (!mounted) return;
      setState(() => _prefsFailed = true);
    }
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return Scaffold(
      backgroundColor: scheme.surface,
      body: Stack(
        fit: StackFit.expand,
        children: [
          Positioned.fill(
            child: _imageReady && !_imageFailed
                ? LayoutBuilder(
                    builder: (context, constraints) {
                      final mq = MediaQuery.of(context);
                      final dpr = mq.devicePixelRatio;

                      final cacheWidth = (constraints.maxWidth * dpr)
                          .round()
                          .clamp(
                            360,
                            PraniAssetDecode.splashBgMaxWidthPx,
                          );

                      final cacheHeight = (constraints.maxHeight * dpr)
                          .round()
                          .clamp(
                            640,
                            PraniAssetDecode.splashBgMaxHeightPx,
                          );

                      return Image.asset(
                        PraniAssets.splashFarm,
                        fit: BoxFit.cover,
                        width: double.infinity,
                        height: double.infinity,
                        alignment: Alignment.center,
                        gaplessPlayback: true,
                        excludeFromSemantics: true,
                        cacheWidth: cacheWidth,
                        cacheHeight: cacheHeight,
                        errorBuilder: (context, error, stackTrace) {
                          WidgetsBinding.instance.addPostFrameCallback((_) {
                            if (mounted) {
                              setState(() => _imageFailed = true);
                            }
                          });

                          return ColoredBox(
                            color: scheme.surfaceContainerHighest,
                          );
                        },
                      );
                    },
                  )
                : ColoredBox(
                    color: scheme.surfaceContainerHighest,
                  ),
          ),

          if (_prefsFailed)
            SafeArea(
              child: Center(
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      color: scheme.surface.withValues(alpha: 0.88),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            'চালু করতে সেটিংস পড়তে সমস্যা হয়েছে।',
                            textAlign: TextAlign.center,
                            style: Theme.of(context).textTheme.bodyMedium
                                ?.copyWith(
                                  color: scheme.onSurface,
                                  fontWeight: FontWeight.w600,
                                ),
                          ),
                          SizedBox(height: PraniSpacing.md),
                          FilledButton(
                            onPressed: () {
                              setState(() => _prefsFailed = false);
                              _goNext();
                            },
                            child: const Text('আবার চেষ্টা'),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}