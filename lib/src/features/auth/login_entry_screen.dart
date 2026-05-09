import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../app/screen_padding.dart';
import '../../core/assets/prani_assets.dart';
import '../../core/config/app_config.dart';
import '../session/application/session_notifier.dart';
import '../home/home_shell_screen.dart';
import '../auth/doctor/presentation/doctor_login_screen.dart';
import '../auth/technician/presentation/technician_login_screen.dart';
import 'data/mobile_otp_auth_repository.dart';

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
      _snack('সঠিক মোবাইল নম্বর দিন (০১ দিয়ে শুরু, ১১ সংখ্যা)।');
      return;
    }
    setState(() => _loginBusy = _LoginBusy.send);
    try {
      await ref.read(mobileOtpAuthRepositoryProvider).requestOtp(phone);
      if (!mounted) return;
      setState(() {
        _otpSent = true;
        _otpTargetPhone = phone;
      });
      _snack('যাচাইকরণ কোড SMS এ পাঠানো হয়েছে।');
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
      _snack('মোবাইল ও ৬ সংখ্যার কোড যাচাই করুন।');
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
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
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
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: scheme.outline, width: 1),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: scheme.primary, width: 2),
      ),
      disabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
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

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final pad = pdScreenPadding(context);
    final bottomInset =
        MediaQuery.viewInsetsOf(context).bottom +
        MediaQuery.paddingOf(context).bottom;
    final sendInteractive = _phoneValid && _loginBusy != _LoginBusy.verify;
    final verifyInteractive =
        _otpSent && _otpComplete && _loginBusy != _LoginBusy.send;

    return Scaffold(
      appBar: AppBar(title: const Text('প্রবেশ')),
      resizeToAvoidBottomInset: true,
      body: SafeArea(
        child: SingleChildScrollView(
          keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
          padding: EdgeInsets.fromLTRB(
            pad.left,
            12,
            pad.right,
            36 + bottomInset,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Center(
                child: Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      color: scheme.surface,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: scheme.outlineVariant.withValues(alpha: 0.65),
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: scheme.shadow.withValues(alpha: 0.06),
                          blurRadius: 12,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 12,
                      ),
                      child: Image.asset(
                        PraniAssets.horizontalLogo,
                        height: 64,
                        fit: BoxFit.contain,
                        gaplessPlayback: true,
                        semanticLabel: 'প্রাণী ডাক্তার ওয়ার্ডমার্ক',
                        cacheWidth: PraniAssetDecode.cacheExtentPx(
                          context,
                          MediaQuery.sizeOf(context).width -
                              pad.horizontal -
                              64,
                          PraniAssetDecode.wordmarkMaxWidthPx,
                        ),
                        cacheHeight: PraniAssetDecode.cacheExtentPx(
                          context,
                          64,
                          220,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              Text(
                'গ্রাহক হিসেবে লগইন',
                style: Theme.of(context).textTheme.headlineSmall,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Text(
                'আপনার মোবাইল নম্বরে SMS এর মাধ্যমে যাচাইকরণ কোড পাঠানো হবে।',
                style: Theme.of(
                  context,
                ).textTheme.bodyLarge?.copyWith(color: scheme.onSurfaceVariant),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 28),
              Text(
                'মোবাইল নম্বর',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: 12),
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
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                child: FilledButton(
                  onPressed: sendInteractive ? _sendOtp : null,
                  child: _primaryButtonChild(
                    label: _otpSent ? 'কোড আবার পাঠান' : 'যাচাইকরণ কোড পাঠান',
                    showLoading: _loginBusy == _LoginBusy.send,
                  ),
                ),
              ),
              if (_otpSent) ...[
                const SizedBox(height: 28),
                Text(
                  'যাচাইকরণ কোড',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const SizedBox(height: 12),
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
                const SizedBox(height: 20),
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
              ],
              const SizedBox(height: 28),
              Row(
                children: [
                  Expanded(child: Divider(color: scheme.outlineVariant)),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 12),
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
              const SizedBox(height: 20),
              Text(
                'সোশ্যাল লগইন',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: 12),
              OutlinedButton.icon(
                onPressed: null,
                icon: Icon(
                  Icons.g_translate,
                  size: 22,
                  color: scheme.onSurfaceVariant.withValues(alpha: 0.45),
                ),
                label: Text(
                  'Google দিয়ে লগইন (শীঘ্রই)',
                  style: TextStyle(
                    color: scheme.onSurfaceVariant.withValues(alpha: 0.55),
                  ),
                ),
                style: OutlinedButton.styleFrom(
                  side: BorderSide(color: scheme.outlineVariant),
                  backgroundColor: scheme.surface.withValues(alpha: 0.5),
                ),
              ),
              const SizedBox(height: 10),
              OutlinedButton.icon(
                onPressed: null,
                icon: Icon(
                  Icons.facebook,
                  size: 22,
                  color: scheme.onSurfaceVariant.withValues(alpha: 0.45),
                ),
                label: Text(
                  'Facebook দিয়ে লগইন (শীঘ্রই)',
                  style: TextStyle(
                    color: scheme.onSurfaceVariant.withValues(alpha: 0.55),
                  ),
                ),
                style: OutlinedButton.styleFrom(
                  side: BorderSide(color: scheme.outlineVariant),
                  backgroundColor: scheme.surface.withValues(alpha: 0.5),
                ),
              ),
              const SizedBox(height: 24),
              Text(
                'পেশাদার প্রবেশ',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: 12),
              OutlinedButton(
                onPressed: () => context.push(DoctorLoginScreen.routePath),
                child: const Text('ডাক্তার'),
              ),
              const SizedBox(height: 8),
              OutlinedButton(
                onPressed: () => context.push(TechnicianLoginScreen.routePath),
                child: const Text('AI টেকনিশিয়ান'),
              ),
              if (kDebugMode) ...[
                const SizedBox(height: 24),
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
      ),
    );
  }
}
