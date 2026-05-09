import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../app/screen_padding.dart';
import '../../core/assets/prani_assets.dart';
import '../auth/login_entry_screen.dart';
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
  /// Large PNG decodes on the first frame block the UI isolate and can trigger
  /// severe Choreographer frame skips + VM service disconnect during `flutter run`.
  bool _heavyBrandDecorReady = false;

  @override
  void initState() {
    super.initState();
    // Paint one cheap frame first, then decode splash / logo assets on the next.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;
        setState(() => _heavyBrandDecorReady = true);
      });
    });
    // Let the first frame paint before starting async navigation/storage work.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      _goNext();
    });
  }

  Future<void> _goNext() async {
    await Future<void>.delayed(const Duration(milliseconds: 1400));
    if (!mounted) return;
    try {
      await ref.read(sessionNotifierProvider.notifier).hydrateFromStorage();
    } catch (e, st) {
      debugPrint('hydrateFromStorage failed: $e');
      debugPrintStack(stackTrace: st);
    }
    if (!mounted) return;
    try {
      final prefs = await SharedPreferences.getInstance();
      final done = prefs.getBool(SplashScreen._onboardingDoneKey) ?? false;
      final auth = ref.read(sessionNotifierProvider).isAuthenticated;
      if (!mounted) return;
      if (!done) {
        context.go(OnboardingScreen.routePath);
      } else if (auth) {
        context.go(HomeShellScreen.routePath);
      } else {
        context.go(LoginEntryScreen.routePath);
      }
    } catch (e, st) {
      debugPrint('splash navigation failed: $e');
      debugPrintStack(stackTrace: st);
      if (!mounted) return;
      context.go(LoginEntryScreen.routePath);
    }
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final pad = pdScreenPadding(context);
    return Scaffold(
      body: Stack(
        fit: StackFit.expand,
        children: [
          if (_heavyBrandDecorReady)
            Builder(
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
                  gaplessPlayback: true,
                  excludeFromSemantics: true,
                  cacheWidth: cw,
                  cacheHeight: ch,
                );
              },
            )
          else
            ColoredBox(color: scheme.surfaceContainerHighest),
          if (_heavyBrandDecorReady)
            DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    scheme.surface.withValues(alpha: 0.55),
                    scheme.surface.withValues(alpha: 0.92),
                  ],
                ),
              ),
            ),
          SafeArea(
            child: Center(
              child: SingleChildScrollView(
                padding: pad,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    if (_heavyBrandDecorReady)
                      Image.asset(
                        PraniAssets.primaryLogo,
                        height: 112,
                        fit: BoxFit.contain,
                        gaplessPlayback: true,
                        semanticLabel: 'প্রাণী ডাক্তার লোগো',
                        cacheWidth: PraniAssetDecode.logoSquarePx,
                        cacheHeight: PraniAssetDecode.logoSquarePx,
                      )
                    else
                      SizedBox(
                        height: 112,
                        child: Icon(
                          Icons.pets,
                          size: 72,
                          color: scheme.primary,
                          semanticLabel: 'প্রাণী ডাক্তার',
                        ),
                      ),
                    const SizedBox(height: 20),
                    Text(
                      'প্রাণী ডাক্তার',
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.headlineMedium
                          ?.copyWith(color: scheme.onSurface),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'খামারের প্রাণীর স্বাস্থ্যসেবা এখন হাতের মুঠোয়',
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        color: scheme.onSurfaceVariant,
                        height: 1.35,
                      ),
                    ),
                    const SizedBox(height: 40),
                    SizedBox(
                      width: 32,
                      height: 32,
                      child: CircularProgressIndicator(
                        strokeWidth: 3,
                        color: scheme.primary,
                      ),
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
