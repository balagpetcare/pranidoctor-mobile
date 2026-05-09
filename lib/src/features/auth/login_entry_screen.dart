import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../app/screen_padding.dart';
import '../../design_system/prani_tokens.dart';
import '../../core/assets/prani_assets.dart';
import '../../core/config/app_config.dart';
import '../session/application/session_notifier.dart';
import '../home/home_shell_screen.dart';
import 'data/mobile_otp_auth_repository.dart';
import 'doctor/presentation/doctor_login_screen.dart';
import 'technician/presentation/technician_login_screen.dart';

enum _LoginBusy { none, send, verify }

/// Customer login via SMS OTP (`/api/mobile/auth/otp/*`).
class LoginEntryScreen extends ConsumerStatefulWidget {
  const LoginEntryScreen({super.key});

  static const routePath = '/login';
  static const routeName = 'loginEntry';

  @override
  ConsumerState<LoginEntryScreen> createState() => _LoginEntryScreenState();
}

class _LoginEntryScreenState extends ConsumerState<LoginEntryScreen> {
  final _phoneController = TextEditingController();
  final _otpController = TextEditingController();
  bool _otpSent = false;
  _LoginBusy _loginBusy = _LoginBusy.none;

  bool get _busy => _loginBusy != _LoginBusy.none;

  /// Normalized `01XXXXXXXXX` last successfully targeted for OTP (for UI reset on edit).
  String? _otpTargetPhone;

  static final _bdMobile = RegExp(r'^01\d{9}$');

  @override
  void initState() {
    super.initState();
    _phoneController.addListener(_onPhoneEdited);
    _otpController.addListener(() => setState(() {}));
  }

  void _onPhoneEdited() {
    final normalized = _normalizedBdMobile(_phoneController.text);
    if (_otpSent &&
        _otpTargetPhone != null &&
        normalized.isNotEmpty &&
        normalized != _otpTargetPhone) {
      _otpController.clear();
      _otpSent = false;
      _otpTargetPhone = null;
    }
    setState(() {});
  }

  /// Digits-only Bangladesh mobile as `01XXXXXXXXX` when valid input is present.
  String _normalizedBdMobile(String raw) {
    var d = raw.replaceAll(RegExp(r'\D'), '');
    if (d.startsWith('880') && d.length > 3) {
      d = d.substring(3);
    }
    if (d.length == 10 && d.startsWith('1')) {
      d = '0$d';
    }
    return d;
  }

  bool get _phoneValid =>
      _bdMobile.hasMatch(_normalizedBdMobile(_phoneController.text));

  bool get _otpComplete => _otpController.text.length == 6;

  @override
  void dispose() {
    _phoneController.removeListener(_onPhoneEdited);
    _phoneController.dispose();
    _otpController.dispose();
    super.dispose();
  }

  Future<void> _sendOtp() async {
    if (_loginBusy != _LoginBusy.none) return;
    final phone = _normalizedBdMobile(_phoneController.text);
    if (!_bdMobile.hasMatch(phone)) {
      _snack(
        'মোবাইল নম্বরটি দেখুন: ০১ দিয়ে শুরু হওয়া ১১ সংখ্যা (যেমন ০১৭xxxxxxxx)।',
      );
      return;
    }
    setState(() => _loginBusy = _LoginBusy.send);
    try {
      final channel = await ref
          .read(mobileOtpAuthRepositoryProvider)
          .requestOtp(phone);
      if (!mounted) return;
      setState(() {
        _otpSent = true;
        _otpTargetPhone = phone;
      });
      if (channel == OtpSendChannel.devTerminalFallback) {
        _snack(
          'ডেভেলপমেন্ট মোডে টেস্ট OTP তৈরি করা হয়েছে। টার্মিনাল/ডিবাগ কনসোল দেখুন।',
        );
      } else {
        _snack('যাচাইকরণ কোড SMS এ পাঠানো হয়েছে।');
      }
    } on OtpAuthException catch (e) {
      if (mounted) _snack(e.message);
    } catch (_) {
      if (mounted) {
        _snack('কিছু একটা সমস্যা হয়েছে। আবার চেষ্টা করুন।');
      }
    } finally {
      if (mounted) setState(() => _loginBusy = _LoginBusy.none);
    }
  }

  Future<void> _verify() async {
    if (_loginBusy != _LoginBusy.none) return;
    final phone = _normalizedBdMobile(_phoneController.text);
    final code = _otpController.text.trim();
    if (!_bdMobile.hasMatch(phone) || code.length != 6) {
      _snack(
        'সঠিক মোবাইল এবং SMS এ আসা ৬ সংখ্যার কোড লিখুন। কোড সম্পূর্ণ না হলে প্রবেশ সম্ভব নয়।',
      );
      return;
    }
    setState(() => _loginBusy = _LoginBusy.verify);
    try {
      final token = await ref
          .read(mobileOtpAuthRepositoryProvider)
          .verifyOtp(phone, code);
      await ref.read(sessionNotifierProvider.notifier).signInCustomer(token);
      if (!mounted) return;
      context.go(HomeShellScreen.routePath);
    } on OtpAuthException catch (e) {
      if (mounted) _snack(e.message);
    } catch (_) {
      if (mounted) {
        _snack('প্রবেশ সম্ভব হয়নি। আবার চেষ্টা করুন।');
      }
    } finally {
      if (mounted) setState(() => _loginBusy = _LoginBusy.none);
    }
  }

  void _snack(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        behavior: SnackBarBehavior.floating,
        margin: const EdgeInsets.fromLTRB(16, 0, 16, 16),
        content: Text(message),
      ),
    );
  }

  InputDecoration _fieldDecoration(
    BuildContext context, {
    required String label,
    required String hint,
  }) {
    final scheme = Theme.of(context).colorScheme;
    return InputDecoration(
      labelText: label,
      hintText: hint,
      filled: true,
      fillColor: scheme.surface,
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(PraniRadii.md),
        borderSide: BorderSide(color: scheme.outline, width: 1),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(PraniRadii.md),
        borderSide: BorderSide(color: scheme.primary, width: 2),
      ),
      disabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(PraniRadii.md),
        borderSide: BorderSide(color: scheme.outlineVariant),
      ),
    );
  }

  Widget _primaryButtonChild({
    required String label,
    required bool showLoading,
  }) {
    if (!showLoading) return Text(label);
    final scheme = Theme.of(context).colorScheme;
    return SizedBox(
      height: 22,
      width: 22,
      child: CircularProgressIndicator(strokeWidth: 2, color: scheme.onPrimary),
    );
  }

  Widget _loginHero(BuildContext context, double keyboardInset) {
    final mq = MediaQuery.of(context);
    final dpr = mq.devicePixelRatio;
    final w = mq.size.width;
    final heroH = keyboardInset > 8
        ? (mq.size.height * 0.13).clamp(96.0, 124.0)
        : (w / 2.08).clamp(172.0, 232.0);
    final decodeW = (w * dpr).round().clamp(120, PraniAssetDecode.heroMaxPx);
    final decodeH = (heroH * dpr).round().clamp(80, PraniAssetDecode.heroMaxPx);

    return AnimatedContainer(
      duration: const Duration(milliseconds: 220),
      curve: Curves.easeOutCubic,
      child: ClipRRect(
        borderRadius: const BorderRadius.vertical(
          bottom: Radius.circular(PraniRadii.xl),
        ),
        child: SizedBox(
          height: heroH,
          width: double.infinity,
          child: Stack(
            fit: StackFit.expand,
            children: [
              Image.asset(
                PraniAssets.homeFarmBanner,
                fit: BoxFit.cover,
                alignment: Alignment.center,
                gaplessPlayback: true,
                semanticLabel: 'ফার্ম ও প্রাণিসম্পদ সেবার ছবি',
                cacheWidth: decodeW,
                cacheHeight: decodeH,
              ),
              DecoratedBox(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.black.withValues(alpha: 0.06),
                      Colors.black.withValues(alpha: 0.42),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _providerEntryCard({
    required BuildContext context,
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    final scheme = Theme.of(context).colorScheme;
    return Material(
      color: scheme.surface,
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: scheme.outlineVariant.withValues(alpha: 0.9)),
      ),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              DecoratedBox(
                decoration: BoxDecoration(
                  color: scheme.primaryContainer.withValues(alpha: 0.65),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Icon(icon, size: 26, color: scheme.primary),
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      subtitle,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: scheme.onSurfaceVariant,
                        height: 1.35,
                      ),
                    ),
                  ],
                ),
              ),
              Icon(Icons.chevron_right_rounded, color: scheme.outline),
            ],
          ),
        ),
      ),
    );
  }

  Widget _socialSoonRow({
    required BuildContext context,
    required IconData icon,
    required String label,
  }) {
    final scheme = Theme.of(context).colorScheme;
    return Semantics(
      label: '$label — শীঘ্রই আসছে',
      enabled: false,
      button: true,
      child: ExcludeSemantics(
        child: Material(
          color: scheme.surfaceContainerHighest.withValues(alpha: 0.72),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(PraniRadii.md),
            side: BorderSide(color: scheme.outline.withValues(alpha: 0.55)),
          ),
          child: InkWell(
            onTap: () {},
            splashColor: Colors.transparent,
            highlightColor: Colors.transparent,
            child: Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: PraniSpacing.md,
                vertical: PraniSpacing.md,
              ),
              child: Row(
                children: [
                  Icon(icon, size: 22, color: scheme.onSurfaceVariant),
                  const SizedBox(width: PraniSpacing.sm),
                  Expanded(
                    child: Text(
                      label,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: scheme.onSurfaceVariant.withValues(alpha: 0.92),
                      ),
                    ),
                  ),
                  DecoratedBox(
                    decoration: BoxDecoration(
                      color: scheme.primaryContainer.withValues(alpha: 0.45),
                      borderRadius: BorderRadius.circular(PraniRadii.sm),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: PraniSpacing.sm,
                        vertical: PraniSpacing.xxs,
                      ),
                      child: Text(
                        'শীঘ্রই',
                        style: Theme.of(context).textTheme.labelSmall?.copyWith(
                          color: scheme.onPrimaryContainer,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final pad = pdScreenPadding(context);
    final viewInsets = MediaQuery.viewInsetsOf(context).bottom;
    final bottomPad = MediaQuery.paddingOf(context).bottom;
    final scrollBottomPad =
        (viewInsets > bottomPad ? viewInsets : bottomPad) +
        PraniSpacing.xl +
        PraniSpacing.sm;

    final sendInitialInteractive =
        _phoneValid && !_otpSent && _loginBusy != _LoginBusy.verify;
    final resendInteractive = _otpSent && _phoneValid && !_busy;
    final verifyInteractive =
        _otpSent && _otpComplete && _loginBusy != _LoginBusy.send;

    return Scaffold(
      appBar: AppBar(title: const Text('প্রবেশ')),
      resizeToAvoidBottomInset: true,
      body: SafeArea(
        bottom: false,
        child: SingleChildScrollView(
          keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _loginHero(context, viewInsets),
              Padding(
                padding: EdgeInsets.fromLTRB(
                  pad.left,
                  PraniSpacing.section,
                  pad.right,
                  scrollBottomPad,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text(
                      'গ্রাহক হিসেবে লগইন',
                      style: Theme.of(context).textTheme.headlineSmall
                          ?.copyWith(
                            fontWeight: FontWeight.w700,
                            letterSpacing: -0.35,
                          ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: PraniSpacing.sm),
                    Text(
                      'মোবাইল নম্বর যাচাই করে SMS OTP দিয়ে নিরাপদ প্রবেশ।',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: scheme.onSurfaceVariant,
                        height: 1.45,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: PraniSpacing.xxl),
                    Text(
                      'মোবাইল নম্বর',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: PraniSpacing.sm),
                    TextField(
                      controller: _phoneController,
                      keyboardType: TextInputType.phone,
                      inputFormatters: [
                        FilteringTextInputFormatter.allow(RegExp(r'[\d+\s-]')),
                      ],
                      decoration: _fieldDecoration(
                        context,
                        label: 'মোবাইল নম্বর',
                        hint: '০১XXXXXXXXX',
                      ),
                      enabled: !_busy,
                      textInputAction: TextInputAction.done,
                    ),
                    if (!_otpSent) ...[
                      const SizedBox(height: PraniSpacing.md),
                      SizedBox(
                        width: double.infinity,
                        child: FilledButton(
                          onPressed: sendInitialInteractive ? _sendOtp : null,
                          child: _primaryButtonChild(
                            label: 'যাচাইকরণ কোড পাঠান',
                            showLoading: _loginBusy == _LoginBusy.send,
                          ),
                        ),
                      ),
                    ],
                    if (_otpSent) ...[
                      const SizedBox(height: PraniSpacing.section),
                      Text(
                        'যাচাইকরণ কোড',
                        style: Theme.of(context).textTheme.titleMedium
                            ?.copyWith(fontWeight: FontWeight.w600),
                      ),
                      const SizedBox(height: PraniSpacing.sm),
                      TextField(
                        controller: _otpController,
                        keyboardType: TextInputType.number,
                        inputFormatters: [
                          FilteringTextInputFormatter.digitsOnly,
                          LengthLimitingTextInputFormatter(6),
                        ],
                        decoration: _fieldDecoration(
                          context,
                          label: '৬ সংখ্যার কোড',
                          hint: '৬ সংখ্যা লিখুন',
                        ),
                        enabled: !_busy,
                        onSubmitted: (_) {
                          if (verifyInteractive) _verify();
                        },
                      ),
                      const SizedBox(height: PraniSpacing.md),
                      SizedBox(
                        width: double.infinity,
                        child: FilledButton(
                          onPressed: verifyInteractive ? _verify : null,
                          child: _primaryButtonChild(
                            label: 'নিশ্চিত করে প্রবেশ করুন',
                            showLoading: _loginBusy == _LoginBusy.verify,
                          ),
                        ),
                      ),
                      const SizedBox(height: PraniSpacing.sm),
                      Padding(
                        padding: const EdgeInsets.only(top: PraniSpacing.xs),
                        child: Center(
                          child: _loginBusy == _LoginBusy.send && _otpSent
                              ? Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    SizedBox(
                                      width: 18,
                                      height: 18,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2,
                                        color: scheme.primary,
                                      ),
                                    ),
                                    const SizedBox(width: PraniSpacing.sm),
                                    Text(
                                      'SMS পাঠানো হচ্ছে…',
                                      style: Theme.of(context)
                                          .textTheme
                                          .bodySmall
                                          ?.copyWith(
                                            color: scheme.primary,
                                            fontWeight: FontWeight.w600,
                                          ),
                                    ),
                                  ],
                                )
                              : TextButton.icon(
                                  onPressed: resendInteractive
                                      ? _sendOtp
                                      : null,
                                  icon: Icon(
                                    Icons.sms_outlined,
                                    size: 18,
                                    color: resendInteractive
                                        ? scheme.primary
                                        : scheme.onSurfaceVariant.withValues(
                                            alpha: 0.45,
                                          ),
                                  ),
                                  label: Text(
                                    'কোড আবার পাঠান (SMS)',
                                    style: TextStyle(
                                      fontWeight: FontWeight.w600,
                                      color: resendInteractive
                                          ? scheme.primary
                                          : scheme.onSurfaceVariant.withValues(
                                              alpha: 0.45,
                                            ),
                                    ),
                                  ),
                                ),
                        ),
                      ),
                    ],
                    const SizedBox(height: PraniSpacing.section),
                    Row(
                      children: [
                        Expanded(child: Divider(color: scheme.outlineVariant)),
                        Padding(
                          padding: const EdgeInsets.symmetric(
                            horizontal: PraniSpacing.md,
                          ),
                          child: Text(
                            'অথবা',
                            style: Theme.of(context).textTheme.labelLarge
                                ?.copyWith(color: scheme.onSurfaceVariant),
                          ),
                        ),
                        Expanded(child: Divider(color: scheme.outlineVariant)),
                      ],
                    ),
                    const SizedBox(height: PraniSpacing.md),
                    Text(
                      'সোশ্যাল লগইন',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: PraniSpacing.sm),
                    _socialSoonRow(
                      context: context,
                      icon: Icons.g_mobiledata_rounded,
                      label: 'Google দিয়ে লগইন',
                    ),
                    const SizedBox(height: PraniSpacing.sm),
                    _socialSoonRow(
                      context: context,
                      icon: Icons.facebook_rounded,
                      label: 'Facebook দিয়ে লগইন',
                    ),
                    const SizedBox(height: PraniSpacing.section),
                    Text(
                      'পেশাদার প্রবেশ',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: PraniSpacing.xxs),
                    Text(
                      'নিবন্ধিত সেবাদাতা হিসেবে আলাদা প্রবেশ',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: scheme.onSurfaceVariant,
                      ),
                    ),
                    const SizedBox(height: PraniSpacing.md),
                    _providerEntryCard(
                      context: context,
                      icon: Icons.medical_services_rounded,
                      title: 'ডাক্তার',
                      subtitle:
                          'রেজিস্টার্ড প্রাণিসম্পদ চিকিৎসক হিসেবে প্রবেশ করুন',
                      onTap: () => context.push(DoctorLoginScreen.routePath),
                    ),
                    const SizedBox(height: PraniSpacing.sm),
                    _providerEntryCard(
                      context: context,
                      icon: Icons.precision_manufacturing_rounded,
                      title: 'AI টেকনিশিয়ান',
                      subtitle:
                          'এআই সহায়তায় ফার্মে সেবা ও কাজের তালিকা পরিচালনা',
                      onTap: () =>
                          context.push(TechnicianLoginScreen.routePath),
                    ),
                    if (kDebugMode) ...[
                      const SizedBox(height: PraniSpacing.xxl),
                      Text(
                        'API ভিত্তি (ডিবাগ): ${AppConfig.apiBaseUrl}',
                        textAlign: TextAlign.center,
                        style: Theme.of(
                          context,
                        ).textTheme.labelSmall?.copyWith(color: scheme.outline),
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
