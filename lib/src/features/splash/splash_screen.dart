import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../app/screen_padding.dart';
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
  /// Defer heavy PNG decode to post-frame to reduce first-frame jank.
  bool _heavyBrandDecorReady = false;
  bool _heroImageFailed = false;
  bool _logoImageFailed = false;
  bool _prefsFailed = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      setState(() => _heavyBrandDecorReady = true);
      _goNext();
    });
  }

  Future<void> _goNext() async {
    if (mounted) {
      setState(() => _prefsFailed = false);
    }
    const minBrandMs = 480;
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
    final textTheme = Theme.of(context).textTheme;
    final pad = pdScreenPadding(context);

    return Scaffold(
      backgroundColor: scheme.surface,
      body: LayoutBuilder(
        builder: (context, constraints) {
          return Stack(
            fit: StackFit.expand,
            children: [
              if (_heavyBrandDecorReady && !_heroImageFailed)
                Positioned.fill(
                  child: ClipRect(
                    child: Builder(
                      builder: (context) {
                        final mq = MediaQuery.of(context);
                        final dpr = mq.devicePixelRatio;
                        final cw = (mq.size.width * dpr).round().clamp(
                          240,
                          PraniAssetDecode.splashBgMaxWidthPx,
                        );
                        final ch = (mq.size.height * dpr).round().clamp(
                          240,
                          PraniAssetDecode.splashBgMaxHeightPx,
                        );
                        return Image.asset(
                          PraniAssets.splashFarm,
                          fit: BoxFit.cover,
                          alignment: Alignment.center,
                          gaplessPlayback: true,
                          excludeFromSemantics: true,
                          cacheWidth: cw,
                          cacheHeight: ch,
                          errorBuilder: (context, error, stackTrace) {
                            WidgetsBinding.instance.addPostFrameCallback((_) {
                              if (mounted) {
                                setState(() => _heroImageFailed = true);
                              }
                            });
                            return ColoredBox(
                              color: scheme.surfaceContainerHighest,
                            );
                          },
                        );
                      },
                    ),
                  ),
                )
              else
                ColoredBox(color: scheme.surfaceContainerHighest),
              if (_heavyBrandDecorReady && !_heroImageFailed)
                DecoratedBox(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        scheme.surface.withValues(alpha: 0.5),
                        scheme.surface.withValues(alpha: 0.94),
                      ],
                    ),
                  ),
                ),
              SafeArea(
                child: Padding(
                  padding: pad,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      const Spacer(flex: 2),
                      Center(
                        child: ConstrainedBox(
                          constraints: const BoxConstraints(maxWidth: 420),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              if (_heavyBrandDecorReady && !_logoImageFailed)
                                Image.asset(
                                  PraniAssets.primaryLogo,
                                  height: 100,
                                  fit: BoxFit.contain,
                                  gaplessPlayback: true,
                                  semanticLabel: 'প্রাণী ডাক্তার লোগো',
                                  cacheWidth: PraniAssetDecode.logoSquarePx,
                                  cacheHeight: PraniAssetDecode.logoSquarePx,
                                  errorBuilder: (context, error, stackTrace) {
                                    WidgetsBinding.instance
                                        .addPostFrameCallback((_) {
                                          if (mounted) {
                                            setState(
                                              () => _logoImageFailed = true,
                                            );
                                          }
                                        });
                                    return Icon(
                                      Icons.pets,
                                      size: 72,
                                      color: scheme.primary,
                                      semanticLabel: 'প্রাণী ডাক্তার',
                                    );
                                  },
                                )
                              else
                                SizedBox(
                                  height: 100,
                                  child: Icon(
                                    Icons.pets,
                                    size: 72,
                                    color: scheme.primary,
                                    semanticLabel: 'প্রাণী ডাক্তার',
                                  ),
                                ),
                              SizedBox(height: PraniSpacing.lg),
                              Text(
                                'প্রাণী ডাক্তার',
                                textAlign: TextAlign.center,
                                style: textTheme.headlineMedium?.copyWith(
                                  color: scheme.onSurface,
                                  fontWeight: FontWeight.w700,
                                  letterSpacing: -0.25,
                                ),
                              ),
                              SizedBox(height: PraniSpacing.sm),
                              Text(
                                'খামারের প্রাণীর স্বাস্থ্যসেবা এখন হাতের মুঠোয়',
                                textAlign: TextAlign.center,
                                style: textTheme.bodyLarge?.copyWith(
                                  color: scheme.onSurfaceVariant,
                                  height: 1.38,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const Spacer(flex: 3),
                      Center(
                        child: _prefsFailed
                            ? Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text(
                                    'চালু করতে সেটিংস পড়তে সমস্যা হয়েছে।',
                                    textAlign: TextAlign.center,
                                    style: textTheme.bodyMedium?.copyWith(
                                      color: scheme.onSurfaceVariant,
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
                              )
                            : SizedBox(
                                width: 36,
                                height: 36,
                                child: CircularProgressIndicator(
                                  strokeWidth: 3,
                                  color: scheme.primary,
                                ),
                              ),
                      ),
                      SizedBox(height: PraniSpacing.xl),
                    ],
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
