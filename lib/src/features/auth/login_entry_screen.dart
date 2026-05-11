import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../app/screen_padding.dart';
import '../../core/assets/prani_assets.dart';
import '../../core/config/app_config.dart';
import '../../design_system/prani_tokens.dart';
import '../../design_system/widgets/prani_buttons.dart';
import '../../design_system/widgets/prani_form_fields.dart';
import '../../design_system/widgets/prani_info_card.dart';
import '../../design_system/widgets/prani_section_header.dart';
import 'application/customer_auth_success.dart';
import 'data/mobile_credential_auth_repository.dart';
import 'data/mobile_otp_auth_repository.dart';

enum _LoginBusy { none, send, verify }

enum _CredentialSubmit { none, register, password }

enum _LoginMode { otp, password }

enum _AuthPageTab { login, register }

/// Customer auth: SMS OTP, password login, registration, social stubs.
/// Login vs register is toggled only from footer links (no top segmented tabs).
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
  final _identifierController = TextEditingController();
  final _passwordController = TextEditingController();

  final _regNameController = TextEditingController();
  final _regPhoneController = TextEditingController();
  final _regEmailController = TextEditingController();
  final _regPasswordController = TextEditingController();
  final _regConfirmPasswordController = TextEditingController();

  _AuthPageTab _authPageTab = _AuthPageTab.login;
  _LoginMode _loginMode = _LoginMode.otp;
  bool _otpSent = false;
  _LoginBusy _loginBusy = _LoginBusy.none;
  _CredentialSubmit _credentialSubmit = _CredentialSubmit.none;
  bool _obscurePassword = true;
  bool _obscureRegPassword = true;
  bool _obscureRegConfirmPassword = true;

  /// Last successful send channel (inline helper, not a scary SnackBar).
  OtpSendChannel? _otpSendHint;

  bool get _busy =>
      _loginBusy != _LoginBusy.none ||
      _credentialSubmit != _CredentialSubmit.none;

  /// Normalized `01XXXXXXXXX` last successfully targeted for OTP (for UI reset on edit).
  String? _otpTargetPhone;

  static final _bdMobile = RegExp(r'^01\d{9}$');
  static final _emailLoose = RegExp(
    r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$',
  );

  @override
  void initState() {
    super.initState();
    _phoneController.addListener(_onPhoneEdited);
    _otpController.addListener(() => setState(() {}));
    _identifierController.addListener(() => setState(() {}));
    _passwordController.addListener(() => setState(() {}));
    _regNameController.addListener(() => setState(() {}));
    _regPhoneController.addListener(() => setState(() {}));
    _regEmailController.addListener(() => setState(() {}));
    _regPasswordController.addListener(() => setState(() {}));
    _regConfirmPasswordController.addListener(() => setState(() {}));
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
      _otpSendHint = null;
    }
    setState(() {});
  }

  void _onLoginModeChanged(_LoginMode mode) {
    if (mode == _loginMode || _busy) return;
    setState(() => _loginMode = mode);
  }

  void _onAuthPageTabChanged(_AuthPageTab tab) {
    if (tab == _authPageTab || _busy) return;
    setState(() => _authPageTab = tab);
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

  bool get _passwordFormReady {
    final id = _identifierController.text.trim();
    final pw = _passwordController.text;
    return id.isNotEmpty && pw.isNotEmpty;
  }

  bool get _regNameValid => _regNameController.text.trim().isNotEmpty;

  bool get _regPhoneValid =>
      _bdMobile.hasMatch(_normalizedBdMobile(_regPhoneController.text));

  bool get _regEmailValid {
    final e = _regEmailController.text.trim();
    if (e.isEmpty) return true;
    return _emailLoose.hasMatch(e);
  }

  bool get _regPasswordValid => _regPasswordController.text.length >= 6;

  bool get _regConfirmValid =>
      _regConfirmPasswordController.text == _regPasswordController.text &&
      _regPasswordController.text.isNotEmpty;

  bool get _registerFormValid =>
      _regNameValid &&
      _regPhoneValid &&
      _regEmailValid &&
      _regPasswordValid &&
      _regConfirmValid;

  @override
  void dispose() {
    _phoneController.removeListener(_onPhoneEdited);
    _phoneController.dispose();
    _otpController.dispose();
    _identifierController.dispose();
    _passwordController.dispose();
    _regNameController.dispose();
    _regPhoneController.dispose();
    _regEmailController.dispose();
    _regPasswordController.dispose();
    _regConfirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _sendOtp() async {
    if (_loginBusy != _LoginBusy.none ||
        _credentialSubmit != _CredentialSubmit.none) {
      return;
    }
    final phone = _normalizedBdMobile(_phoneController.text);
    if (!_bdMobile.hasMatch(phone)) {
      _snack(
        'মোবাইল নম্বরটি দেখুন: ০১ দিয়ে শুরু হওয়া ১১ সংখ্যা (যেমন ০১৭xxxxxxxx)।',
      );
      return;
    }
    setState(() {
      _loginBusy = _LoginBusy.send;
      _otpSendHint = null;
    });
    try {
      final channel = await ref
          .read(mobileOtpAuthRepositoryProvider)
          .requestOtp(phone);
      if (!mounted) return;
      setState(() {
        _otpSent = true;
        _otpTargetPhone = phone;
        _otpSendHint = channel;
      });
    } on OtpAuthException catch (e) {
      if (mounted) _snack(e.message);
    } catch (_) {
      if (mounted) {
        _snack('আবার চেষ্টা করুন');
      }
    } finally {
      if (mounted) setState(() => _loginBusy = _LoginBusy.none);
    }
  }

  Future<void> _verify() async {
    if (_loginBusy != _LoginBusy.none ||
        _credentialSubmit != _CredentialSubmit.none) {
      return;
    }
    final phone = _normalizedBdMobile(_phoneController.text);
    final code = _otpController.text.trim();
    if (!_bdMobile.hasMatch(phone) || code.length != 6) {
      _snack(
        'সঠিক মোবাইল এবং SMS এ আসা ৬ সংখ্যার কোড লিখুন। কোড সম্পূর্ণ না হলে প্রবেশ সম্ভব নয়।',
      );
      return;
    }
    setState(() => _loginBusy = _LoginBusy.verify);
    final tab = GoRouterState.of(context).uri.queryParameters['tab'];
    final nextPath = GoRouterState.of(context).uri.queryParameters['next'];
    try {
      final token = await ref
          .read(mobileOtpAuthRepositoryProvider)
          .verifyOtp(phone, code);
      await completeCustomerSessionAfterSignIn(
        ref: ref,
        accessToken: token,
        postLoginTab: tab,
        postLoginNextPath: nextPath,
      );
    } on OtpAuthException catch (e) {
      if (mounted) _snack(e.message);
    } catch (_) {
      if (mounted) {
        _snack('আবার চেষ্টা করুন');
      }
    } finally {
      if (mounted) setState(() => _loginBusy = _LoginBusy.none);
    }
  }

  Future<void> _submitPasswordLogin() async {
    if (!_passwordFormReady || _busy) return;
    setState(() => _credentialSubmit = _CredentialSubmit.password);
    final tab = GoRouterState.of(context).uri.queryParameters['tab'];
    final nextPath = GoRouterState.of(context).uri.queryParameters['next'];
    try {
      final token = await ref
          .read(mobileCredentialAuthRepositoryProvider)
          .loginWithPassword(
            identifier: _identifierController.text.trim(),
            password: _passwordController.text,
          );
      await completeCustomerSessionAfterSignIn(
        ref: ref,
        accessToken: token,
        postLoginTab: tab,
        postLoginNextPath: nextPath,
      );
    } on CredentialAuthException catch (e) {
      if (mounted) _snack(e.message);
    } catch (_) {
      if (mounted) {
        _snack('মোবাইল/ইমেইল অথবা পাসওয়ার্ড সঠিক নয়');
      }
    } finally {
      if (mounted) {
        setState(() => _credentialSubmit = _CredentialSubmit.none);
      }
    }
  }

  Future<void> _submitRegister() async {
    if (!_registerFormValid || _busy) return;
    if (!_regEmailValid) {
      _snack('ইমেইল ঠিকানাটি সঠিক ফরম্যাটে লিখুন।');
      return;
    }
    setState(() => _credentialSubmit = _CredentialSubmit.register);
    final tab = GoRouterState.of(context).uri.queryParameters['tab'];
    final nextPath = GoRouterState.of(context).uri.queryParameters['next'];
    try {
      final phone = _normalizedBdMobile(_regPhoneController.text);
      final emailTrim = _regEmailController.text.trim();
      final token = await ref
          .read(mobileCredentialAuthRepositoryProvider)
          .register(
            name: _regNameController.text.trim(),
            mobile: phone,
            email: emailTrim.isEmpty ? null : emailTrim,
            password: _regPasswordController.text,
          );
      await completeCustomerSessionAfterSignIn(
        ref: ref,
        accessToken: token,
        postLoginTab: tab,
        postLoginNextPath: nextPath,
      );
      if (mounted) _snack('অ্যাকাউন্ট তৈরি হয়েছে');
    } on CredentialAuthException catch (e) {
      if (mounted) _snack(e.message);
    } catch (_) {
      if (mounted) _snack('অ্যাকাউন্ট তৈরি করা যায়নি');
    } finally {
      if (mounted) {
        setState(() => _credentialSubmit = _CredentialSubmit.none);
      }
    }
  }

  void _onSocialSoonTap() {
    _snack('এই ফিচারটি শীঘ্রই আসছে');
  }

  void _snack(String message) {
    final bottomInset = MediaQuery.viewInsetsOf(context).bottom;
    final padBottom = MediaQuery.paddingOf(context).bottom;
    ScaffoldMessenger.of(context).hideCurrentSnackBar();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        behavior: SnackBarBehavior.floating,
        margin: EdgeInsets.fromLTRB(
          16,
          16,
          16,
          12 + padBottom + (bottomInset * 0.35).clamp(0.0, 120.0),
        ),
        content: Text(message),
      ),
    );
  }

  InputDecoration _fieldDecoration(
    BuildContext context, {
    required String label,
    required String hint,
    Widget? suffixIcon,
  }) {
    final scheme = Theme.of(context).colorScheme;
    return InputDecoration(
      labelText: label,
      hintText: hint,
      suffixIcon: suffixIcon,
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

  Widget _loginHero(BuildContext context, double keyboardInset) {
    final mq = MediaQuery.of(context);
    final dpr = mq.devicePixelRatio;
    final w = mq.size.width;
    final heroH = keyboardInset > 8
        ? (mq.size.height * 0.09).clamp(64.0, 88.0)
        : (w / 2.85).clamp(96.0, 140.0);
    final decodeW = (w * dpr).round().clamp(120, PraniAssetDecode.heroMaxPx);
    final decodeH = (heroH * dpr).round().clamp(72, PraniAssetDecode.heroMaxPx);

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

  Widget _loginModeSwitch(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    Widget chip(_LoginMode mode, String label) {
      final selected = _loginMode == mode;
      return Expanded(
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: _busy ? null : () => _onLoginModeChanged(mode),
            borderRadius: BorderRadius.circular(PraniRadii.md - 2),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 180),
              curve: Curves.easeOutCubic,
              padding: const EdgeInsets.symmetric(vertical: PraniSpacing.sm),
              decoration: BoxDecoration(
                color: selected ? scheme.primaryContainer : Colors.transparent,
                borderRadius: BorderRadius.circular(PraniRadii.md - 2),
              ),
              alignment: Alignment.center,
              child: Text(
                label,
                style: textTheme.labelLarge?.copyWith(
                  fontWeight: FontWeight.w700,
                  color: selected
                      ? scheme.onPrimaryContainer
                      : scheme.onSurfaceVariant,
                ),
              ),
            ),
          ),
        ),
      );
    }

    return DecoratedBox(
      decoration: BoxDecoration(
        color: scheme.surfaceContainerHighest.withValues(alpha: 0.45),
        borderRadius: BorderRadius.circular(PraniRadii.md),
        border: Border.all(
          color: scheme.outlineVariant.withValues(alpha: 0.85),
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(4),
        child: Row(
          children: [
            chip(_LoginMode.otp, 'OTP'),
            chip(_LoginMode.password, 'পাসওয়ার্ড'),
          ],
        ),
      ),
    );
  }

  Widget _socialLoginButton({
    required BuildContext context,
    required IconData icon,
    required String label,
  }) {
    final scheme = Theme.of(context).colorScheme;
    return SizedBox(
      width: double.infinity,
      child: OutlinedButton.icon(
        onPressed: _busy ? null : _onSocialSoonTap,
        icon: Icon(icon, size: 22, color: scheme.primary),
        label: Text(
          label,
          style: Theme.of(
            context,
          ).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w600),
        ),
        style: OutlinedButton.styleFrom(
          minimumSize: const Size.fromHeight(48),
          padding: const EdgeInsets.symmetric(
            horizontal: PraniSpacing.md,
            vertical: PraniSpacing.sm,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(PraniRadius.md),
          ),
          side: BorderSide(color: scheme.outline.withValues(alpha: 0.75)),
        ),
      ),
    );
  }

  Widget _socialBlock(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const SizedBox(height: PraniSpacing.lg),
        Row(
          children: [
            Expanded(child: Divider(color: scheme.outlineVariant)),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: PraniSpacing.md),
              child: Text(
                'অথবা',
                style: Theme.of(context).textTheme.labelLarge?.copyWith(
                  color: scheme.onSurfaceVariant,
                ),
              ),
            ),
            Expanded(child: Divider(color: scheme.outlineVariant)),
          ],
        ),
        const SizedBox(height: PraniSpacing.md),
        const PraniSectionHeader(title: 'সোশ্যাল লগইন', compact: true),
        const SizedBox(height: PraniSpacing.sm),
        _socialLoginButton(
          context: context,
          icon: Icons.g_mobiledata_rounded,
          label: 'Google দিয়ে চালিয়ে যান',
        ),
        const SizedBox(height: PraniSpacing.sm),
        _socialLoginButton(
          context: context,
          icon: Icons.facebook_rounded,
          label: 'Facebook দিয়ে চালিয়ে যান',
        ),
      ],
    );
  }

  Widget _authFooter(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    if (_authPageTab == _AuthPageTab.login) {
      return Padding(
        padding: const EdgeInsets.only(top: PraniSpacing.lg),
        child: Wrap(
          alignment: WrapAlignment.center,
          crossAxisAlignment: WrapCrossAlignment.center,
          spacing: PraniSpacing.xs,
          runSpacing: PraniSpacing.xs,
          children: [
            Text(
              'নতুন ব্যবহারকারী?',
              style: Theme.of(
                context,
              ).textTheme.bodyMedium?.copyWith(color: scheme.onSurfaceVariant),
            ),
            TextButton(
              onPressed: _busy
                  ? null
                  : () => _onAuthPageTabChanged(_AuthPageTab.register),
              child: const Text('অ্যাকাউন্ট তৈরি করুন'),
            ),
          ],
        ),
      );
    }
    return Padding(
      padding: const EdgeInsets.only(top: PraniSpacing.lg),
      child: Wrap(
        alignment: WrapAlignment.center,
        crossAxisAlignment: WrapCrossAlignment.center,
        spacing: PraniSpacing.xs,
        runSpacing: PraniSpacing.xs,
        children: [
          Text(
            'ইতিমধ্যে অ্যাকাউন্ট আছে?',
            style: Theme.of(
              context,
            ).textTheme.bodyMedium?.copyWith(color: scheme.onSurfaceVariant),
          ),
          TextButton(
            onPressed: _busy
                ? null
                : () => _onAuthPageTabChanged(_AuthPageTab.login),
            child: const Text('লগইন করুন'),
          ),
        ],
      ),
    );
  }

  Widget _loginTabBody(BuildContext context, ColorScheme scheme) {
    final sendInitialInteractive =
        _loginMode == _LoginMode.otp &&
        _phoneValid &&
        !_otpSent &&
        _loginBusy != _LoginBusy.verify;
    final resendInteractive =
        _loginMode == _LoginMode.otp && _otpSent && _phoneValid && !_busy;
    final verifyInteractive =
        _loginMode == _LoginMode.otp &&
        _otpSent &&
        _otpComplete &&
        _loginBusy != _LoginBusy.send;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _loginModeSwitch(context),
        const SizedBox(height: PraniSpacing.md),
        if (_loginMode == _LoginMode.otp) ...[
          PraniTextField(
            controller: _phoneController,
            keyboardType: TextInputType.phone,
            inputFormatters: [
              FilteringTextInputFormatter.allow(RegExp(r'[\d+\s-]')),
            ],
            decoration: _fieldDecoration(
              context,
              label: 'মোবাইল নম্বর',
              hint: 'মোবাইল নম্বর লিখুন',
            ),
            enabled: !_busy,
            textInputAction: TextInputAction.done,
          ),
          if (!_otpSent) ...[
            const SizedBox(height: PraniSpacing.md),
            PraniPrimaryButton(
              label: 'যাচাইকরণ কোড পাঠান',
              onPressed: sendInitialInteractive ? _sendOtp : null,
              isLoading: _loginBusy == _LoginBusy.send,
            ),
          ],
          if (_otpSent) ...[
            const SizedBox(height: PraniSpacing.lg),
            if (_otpSendHint == OtpSendChannel.smsApi) ...[
              PraniInfoCard(
                title: 'কোড পাঠানো হয়েছে',
                subtitle:
                    'কিছুক্ষণের মধ্যে SMS এ ৬ সংখ্যার কোড আসবে। ইনবক্স না দেখলে স্প্যাম ফোল্ডার দেখুন।',
                leadingIcon: const Icon(Icons.sms_outlined),
                padding: const EdgeInsets.all(PraniSpacing.md),
              ),
              const SizedBox(height: PraniSpacing.md),
            ],
            if (AppConfig.useDevOtpFallback &&
                _otpSendHint == OtpSendChannel.devTerminalFallback) ...[
              PraniInfoCard(
                title: 'ডেভেলপমেন্ট মোড',
                subtitle:
                    'সার্ভার না পেলে টেস্ট প্রবেশ চালু থাকতে পারে। প্রোডাকশন বিল্ডে এটি দেখা যাবে না।',
                leadingIcon: const Icon(Icons.science_outlined),
                padding: const EdgeInsets.all(PraniSpacing.md),
              ),
              const SizedBox(height: PraniSpacing.md),
            ],
            PraniTextField(
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
              textInputAction: TextInputAction.done,
            ),
            const SizedBox(height: PraniSpacing.md),
            PraniPrimaryButton(
              label: 'নিশ্চিত করে প্রবেশ করুন',
              onPressed: verifyInteractive ? _verify : null,
              isLoading: _loginBusy == _LoginBusy.verify,
            ),
            const SizedBox(height: PraniSpacing.sm),
            Center(
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
                          style: Theme.of(context).textTheme.bodySmall
                              ?.copyWith(
                                color: scheme.primary,
                                fontWeight: FontWeight.w600,
                              ),
                        ),
                      ],
                    )
                  : TextButton.icon(
                      onPressed: resendInteractive ? _sendOtp : null,
                      icon: Icon(
                        Icons.sms_outlined,
                        size: 18,
                        color: resendInteractive
                            ? scheme.primary
                            : scheme.onSurfaceVariant.withValues(alpha: 0.45),
                      ),
                      label: Text(
                        'কোড আবার পাঠান (SMS)',
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          color: resendInteractive
                              ? scheme.primary
                              : scheme.onSurfaceVariant.withValues(alpha: 0.45),
                        ),
                      ),
                    ),
            ),
          ],
        ] else ...[
          PraniTextField(
            controller: _identifierController,
            keyboardType: TextInputType.text,
            decoration: _fieldDecoration(
              context,
              label: 'মোবাইল / ইমেইল',
              hint: 'মোবাইল নম্বর অথবা ইমেইল লিখুন',
            ),
            enabled: !_busy,
            textInputAction: TextInputAction.next,
          ),
          const SizedBox(height: PraniSpacing.md),
          PraniTextField(
            controller: _passwordController,
            obscureText: _obscurePassword,
            decoration: _fieldDecoration(
              context,
              label: 'পাসওয়ার্ড',
              hint: 'পাসওয়ার্ড লিখুন',
              suffixIcon: IconButton(
                tooltip: _obscurePassword ? 'দেখান' : 'লুকান',
                onPressed: () {
                  setState(() => _obscurePassword = !_obscurePassword);
                },
                icon: Icon(
                  _obscurePassword
                      ? Icons.visibility_outlined
                      : Icons.visibility_off_outlined,
                ),
              ),
            ),
            enabled: !_busy,
            textInputAction: TextInputAction.done,
          ),
          const SizedBox(height: PraniSpacing.md),
          PraniPrimaryButton(
            label: 'লগইন',
            onPressed: _passwordFormReady && !_busy
                ? () => unawaited(_submitPasswordLogin())
                : null,
            isLoading: _credentialSubmit == _CredentialSubmit.password,
          ),
        ],
        _socialBlock(context),
        _authFooter(context),
      ],
    );
  }

  Widget _registerTabBody(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        PraniTextField(
          controller: _regNameController,
          keyboardType: TextInputType.name,
          decoration: _fieldDecoration(
            context,
            label: 'পূর্ণ নাম',
            hint: 'আপনার নাম লিখুন',
          ),
          enabled: !_busy,
          textInputAction: TextInputAction.next,
        ),
        const SizedBox(height: PraniSpacing.md),
        PraniTextField(
          controller: _regPhoneController,
          keyboardType: TextInputType.phone,
          inputFormatters: [
            FilteringTextInputFormatter.allow(RegExp(r'[\d+\s-]')),
          ],
          decoration: _fieldDecoration(
            context,
            label: 'মোবাইল নম্বর',
            hint: 'মোবাইল নম্বর লিখুন',
          ),
          enabled: !_busy,
          textInputAction: TextInputAction.next,
        ),
        const SizedBox(height: PraniSpacing.md),
        PraniTextField(
          controller: _regEmailController,
          keyboardType: TextInputType.emailAddress,
          decoration: _fieldDecoration(
            context,
            label: 'ইমেইল',
            hint: 'ইমেইল লিখুন',
          ),
          enabled: !_busy,
          textInputAction: TextInputAction.next,
        ),
        if (_regEmailController.text.trim().isNotEmpty && !_regEmailValid)
          Padding(
            padding: const EdgeInsets.only(top: PraniSpacing.xs),
            child: Text(
              'সঠিক ইমেইল ফরম্যাট লিখুন',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Theme.of(context).colorScheme.error,
              ),
            ),
          ),
        const SizedBox(height: PraniSpacing.md),
        PraniTextField(
          controller: _regPasswordController,
          obscureText: _obscureRegPassword,
          decoration: _fieldDecoration(
            context,
            label: 'পাসওয়ার্ড',
            hint: 'পাসওয়ার্ড দিন',
            suffixIcon: IconButton(
              tooltip: _obscureRegPassword ? 'দেখান' : 'লুকান',
              onPressed: () {
                setState(() => _obscureRegPassword = !_obscureRegPassword);
              },
              icon: Icon(
                _obscureRegPassword
                    ? Icons.visibility_outlined
                    : Icons.visibility_off_outlined,
              ),
            ),
          ),
          enabled: !_busy,
          textInputAction: TextInputAction.next,
        ),
        if (_regPasswordController.text.isNotEmpty && !_regPasswordValid)
          Padding(
            padding: const EdgeInsets.only(top: PraniSpacing.xs),
            child: Text(
              'কমপক্ষে ৬ অক্ষরের পাসওয়ার্ড দিন',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Theme.of(context).colorScheme.error,
              ),
            ),
          ),
        const SizedBox(height: PraniSpacing.md),
        PraniTextField(
          controller: _regConfirmPasswordController,
          obscureText: _obscureRegConfirmPassword,
          decoration: _fieldDecoration(
            context,
            label: 'পাসওয়ার্ড নিশ্চিত করুন',
            hint: 'আবার পাসওয়ার্ড দিন',
            suffixIcon: IconButton(
              tooltip: _obscureRegConfirmPassword ? 'দেখান' : 'লুকান',
              onPressed: () {
                setState(
                  () =>
                      _obscureRegConfirmPassword = !_obscureRegConfirmPassword,
                );
              },
              icon: Icon(
                _obscureRegConfirmPassword
                    ? Icons.visibility_outlined
                    : Icons.visibility_off_outlined,
              ),
            ),
          ),
          enabled: !_busy,
          textInputAction: TextInputAction.done,
        ),
        if (_regConfirmPasswordController.text.isNotEmpty && !_regConfirmValid)
          Padding(
            padding: const EdgeInsets.only(top: PraniSpacing.xs),
            child: Text(
              'পাসওয়ার্ড মিলছে না',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Theme.of(context).colorScheme.error,
              ),
            ),
          ),
        const SizedBox(height: PraniSpacing.lg),
        PraniPrimaryButton(
          label: 'অ্যাকাউন্ট তৈরি করুন',
          onPressed: _registerFormValid && !_busy
              ? () => unawaited(_submitRegister())
              : null,
          isLoading: _credentialSubmit == _CredentialSubmit.register,
        ),
        _socialBlock(context),
        _authFooter(context),
      ],
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
        PraniSpacing.lg;

    return Scaffold(
      resizeToAvoidBottomInset: true,
      body: SafeArea(
        child: SingleChildScrollView(
          keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
          padding: EdgeInsets.fromLTRB(
            pad.left,
            PraniSpacing.sm,
            pad.right,
            scrollBottomPad,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              if (Navigator.of(context).canPop())
                Align(
                  alignment: Alignment.centerLeft,
                  child: IconButton(
                    tooltip: MaterialLocalizations.of(
                      context,
                    ).backButtonTooltip,
                    onPressed: _busy
                        ? null
                        : () => Navigator.of(context).maybePop(),
                    icon: const Icon(Icons.arrow_back_rounded),
                  ),
                ),
              _loginHero(context, viewInsets),
              SizedBox(
                height: viewInsets > 0 ? PraniSpacing.md : PraniSpacing.lg,
              ),
              Text(
                _authPageTab == _AuthPageTab.login
                    ? 'প্রবেশ'
                    : 'অ্যাকাউন্ট তৈরি',
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.w800,
                  letterSpacing: -0.4,
                  height: 1.15,
                ),
              ),
              const SizedBox(height: PraniSpacing.sm),
              Text(
                _authPageTab == _AuthPageTab.login
                    ? 'আপনার অ্যাকাউন্টে নিরাপদে প্রবেশ করুন'
                    : 'নতুন অ্যাকাউন্ট তৈরি করে সেবা ব্যবহার করুন',
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: scheme.onSurfaceVariant,
                  height: 1.45,
                ),
              ),
              const SizedBox(height: PraniSpacing.md),
              if (_authPageTab == _AuthPageTab.login)
                _loginTabBody(context, scheme)
              else
                _registerTabBody(context),
              if (kDebugMode) ...[
                const SizedBox(height: PraniSpacing.xxl),
                Text(
                  'API (ডিবাগ): ${AppConfig.resolvedApiBaseUrl}',
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.labelSmall?.copyWith(
                    color: scheme.outline.withValues(alpha: 0.75),
                    fontSize: 10,
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
