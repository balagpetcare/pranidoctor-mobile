import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../app/screen_padding.dart';
import '../../core/constants/pd_spacing.dart';
import '../../core/constants/pd_radii.dart';
import '../../core/validation/bd_phone.dart';
import '../home/home_shell_screen.dart';
import '../session/application/session_notifier.dart';
import 'data/mobile_otp_auth_repository.dart';
import 'login_entry_screen.dart';

/// SMS OTP entry after phone submission on [LoginEntryScreen].
class OtpVerifyScreen extends ConsumerStatefulWidget {
  const OtpVerifyScreen({
    super.key,
    required this.apiPhone,
    this.resendCooldownSeconds,
  });

  /// Digits-only `8801XXXXXXXXX`.
  final String apiPhone;

  /// Optional TTL from server on last start; defaults to [defaultResendCooldown].
  final int? resendCooldownSeconds;

  static const routePathSegment = 'otp';
  static const routeName = 'otpVerify';

  /// Full path when nested under [LoginEntryScreen.routePath].
  static String get routePath =>
      '${LoginEntryScreen.routePath}/$routePathSegment';

  static const defaultResendCooldown = 60;

  @override
  ConsumerState<OtpVerifyScreen> createState() => _OtpVerifyScreenState();
}

class _OtpVerifyScreenState extends ConsumerState<OtpVerifyScreen> {
  final _otpController = TextEditingController();
  bool _submitting = false;
  String? _errorMessage;
  Timer? _cooldownTimer;
  int _secondsLeft = 0;
  bool _canResend = false;

  @override
  void initState() {
    super.initState();
    _startCooldown(
      widget.resendCooldownSeconds ?? OtpVerifyScreen.defaultResendCooldown,
    );
  }

  @override
  void dispose() {
    _cooldownTimer?.cancel();
    _otpController.dispose();
    super.dispose();
  }

  void _startCooldown(int seconds) {
    _cooldownTimer?.cancel();
    setState(() {
      _secondsLeft = seconds;
      _canResend = false;
    });
    _cooldownTimer = Timer.periodic(const Duration(seconds: 1), (t) {
      if (!mounted) return;
      setState(() {
        _secondsLeft -= 1;
        if (_secondsLeft <= 0) {
          _canResend = true;
          t.cancel();
        }
      });
    });
  }

  Future<void> _onResend() async {
    if (!_canResend || _submitting) return;
    setState(() {
      _errorMessage = null;
      _submitting = true;
    });
    try {
      final repo = ref.read(mobileOtpAuthRepositoryProvider);
      final result = await repo.startOtp(widget.apiPhone);
      if (!mounted) return;
      _startCooldown(
        result.otpTtlSeconds ?? OtpVerifyScreen.defaultResendCooldown,
      );
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('কোড আবার পাঠানো হয়েছে।')));
    } on OtpAuthException catch (e) {
      if (mounted) setState(() => _errorMessage = e.message);
    } finally {
      if (mounted) setState(() => _submitting = false);
    }
  }

  Future<void> _onVerify() async {
    final code = _otpController.text.trim();
    if (code.length < 6) {
      setState(() => _errorMessage = '৬ সংখ্যার কোড দিন।');
      return;
    }
    setState(() {
      _errorMessage = null;
      _submitting = true;
    });
    try {
      final repo = ref.read(mobileOtpAuthRepositoryProvider);
      final token = await repo.verifyOtp(widget.apiPhone, code);
      await ref.read(sessionNotifierProvider.notifier).signInCustomer(token);
      if (!mounted) return;
      context.go(HomeShellScreen.routePath);
    } on OtpAuthException catch (e) {
      if (mounted) setState(() => _errorMessage = e.message);
    } finally {
      if (mounted) setState(() => _submitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final pad = pdScreenPadding(context);
    final masked = BdPhone.maskForDisplay(widget.apiPhone);

    return Scaffold(
      appBar: AppBar(
        leading: BackButton(
          onPressed: () => context.go(LoginEntryScreen.routePath),
        ),
        title: const Text('কোড নিশ্চিত করুন'),
      ),
      body: ListView(
        padding: pad.copyWith(top: 16, bottom: 32),
        children: [
          Text(
            'আমরা এই নম্বরে একটি কোড পাঠিয়েছি',
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 8),
          Text(
            masked,
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
              fontWeight: FontWeight.w600,
              color: scheme.primary,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            '৬ সংখ্যার কোডটি লিখে নিশ্চিত করুন।',
            textAlign: TextAlign.center,
            style: Theme.of(
              context,
            ).textTheme.bodyMedium?.copyWith(color: scheme.onSurfaceVariant),
          ),
          const SizedBox(height: 28),
          Semantics(
            label: 'এসএমএস কোড',
            child: TextField(
              controller: _otpController,
              keyboardType: TextInputType.number,
              maxLength: 6,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                letterSpacing: 10,
                fontWeight: FontWeight.w600,
              ),
              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              decoration: InputDecoration(
                labelText: 'কোড',
                hintText: '• • • • • •',
                counterText: '',
                filled: true,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(PdRadii.input),
                ),
              ),
              autofillHints: const [AutofillHints.oneTimeCode],
              onChanged: (v) {
                if (_errorMessage != null) setState(() => _errorMessage = null);
                if (v.length == 6) {
                  FocusScope.of(context).unfocus();
                }
              },
              onSubmitted: (_) => _onVerify(),
            ),
          ),
          if (_errorMessage != null) ...[
            const SizedBox(height: 12),
            Text(
              _errorMessage!,
              style: Theme.of(
                context,
              ).textTheme.bodyMedium?.copyWith(color: scheme.error),
            ),
          ],
          const SizedBox(height: 24),
          FilledButton(
            onPressed: _submitting ? null : _onVerify,
            child: _submitting
                ? SizedBox(
                    height: PdSpacing.minTapHeight - 16,
                    child: Center(
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: scheme.onPrimary,
                      ),
                    ),
                  )
                : const Text('নিশ্চিত করুন'),
          ),
          const SizedBox(height: 20),
          TextButton(
            onPressed: _submitting
                ? null
                : () => context.go(LoginEntryScreen.routePath),
            child: const Text('নম্বর পরিবর্তন'),
          ),
          const SizedBox(height: 8),
          Center(
            child: _canResend
                ? TextButton(
                    onPressed: _submitting ? null : _onResend,
                    child: const Text('কোড আবার পাঠান'),
                  )
                : Text(
                    'আবার পাঠাতে অপেক্ষা করুন ($_secondsLeft সেকেন্ড)',
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: scheme.onSurfaceVariant,
                    ),
                  ),
          ),
        ],
      ),
    );
  }
}
