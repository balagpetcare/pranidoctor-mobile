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
  bool _busy = false;

  @override
  void dispose() {
    _phoneController.dispose();
    _otpController.dispose();
    super.dispose();
  }

  Future<void> _sendOtp() async {
    final phone = _phoneController.text.trim();
    if (phone.length < 10) {
      _snack('সঠিক মোবাইল নম্বর দিন।');
      return;
    }
    setState(() => _busy = true);
    try {
      await ref.read(mobileOtpAuthRepositoryProvider).requestOtp(phone);
      if (!mounted) return;
      setState(() {
        _otpSent = true;
      });
      _snack('যাচাইকরণ কোড SMS এ পাঠানো হয়েছে।');
    } on OtpAuthException catch (e) {
      _snack(e.message);
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _verify() async {
    final phone = _phoneController.text.trim();
    final code = _otpController.text.trim();
    if (code.length != 6) {
      _snack('৬ সংখ্যার কোড দিন।');
      return;
    }
    setState(() => _busy = true);
    try {
      final token = await ref
          .read(mobileOtpAuthRepositoryProvider)
          .verifyOtp(phone, code);
      await ref.read(sessionNotifierProvider.notifier).signInCustomer(token);
      if (!mounted) return;
      context.go(HomeShellScreen.routePath);
    } on OtpAuthException catch (e) {
      _snack(e.message);
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  void _snack(String message) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final pad = pdScreenPadding(context);
    return Scaffold(
      appBar: AppBar(title: const Text('প্রবেশ')),
      body: ListView(
        padding: pad.copyWith(
          top: 12,
          bottom: 28 + MediaQuery.viewInsetsOf(context).bottom,
        ),
        children: [
          Center(
            child: Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Image.asset(
                PraniAssets.horizontalLogo,
                height: 52,
                fit: BoxFit.contain,
                gaplessPlayback: true,
                semanticLabel: 'প্রাণী ডাক্তার ওয়ার্ডমার্ক',
              ),
            ),
          ),
          Text(
            'গ্রাহক হিসেবে লগইন',
            style: Theme.of(context).textTheme.headlineSmall,
          ),
          const SizedBox(height: 8),
          Text(
            'মোবাইল নম্বর দিন। একটি যাচাইকরণ কোড SMS এ পাঠানো হবে।',
            style: Theme.of(
              context,
            ).textTheme.bodyLarge?.copyWith(color: scheme.onSurfaceVariant),
          ),
          const SizedBox(height: 28),
          Text('মোবাইল নম্বর', style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 12),
          TextField(
            controller: _phoneController,
            keyboardType: TextInputType.phone,
            inputFormatters: [
              FilteringTextInputFormatter.allow(RegExp(r'[\d+\s-]')),
            ],
            decoration: const InputDecoration(
              labelText: 'মোবাইল নম্বর',
              hintText: '01XXXXXXXXX',
            ),
            enabled: !_busy,
            textInputAction: TextInputAction.next,
          ),
          const SizedBox(height: 16),
          FilledButton(
            onPressed: _busy ? null : _sendOtp,
            child: Text(_otpSent ? 'কোড আবার পাঠান' : 'যাচাইকরণ কোড পাঠান'),
          ),
          const SizedBox(height: 28),
          Text('যাচাইকরণ কোড', style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 12),
          TextField(
            controller: _otpController,
            keyboardType: TextInputType.number,
            obscureText: false,
            inputFormatters: [
              FilteringTextInputFormatter.digitsOnly,
              LengthLimitingTextInputFormatter(6),
            ],
            decoration: const InputDecoration(
              labelText: '৬ সংখ্যার কোড',
              hintText: '———',
            ),
            enabled: !_busy,
            onSubmitted: (_) => _verify(),
          ),
          const SizedBox(height: 20),
          FilledButton(
            onPressed: _busy ? null : _verify,
            child: const Text('নিশ্চিত করে প্রবেশ করুন'),
          ),
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
            'সোশ্যাল (শীঘ্রই)',
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 12),
          OutlinedButton.icon(
            onPressed: null,
            icon: const Icon(Icons.g_translate, size: 22),
            label: const Text('Google দিয়ে লগইন (শীঘ্রই)'),
          ),
          const SizedBox(height: 10),
          OutlinedButton.icon(
            onPressed: null,
            icon: const Icon(Icons.facebook, size: 22),
            label: const Text('Facebook দিয়ে লগইন (শীঘ্রই)'),
          ),
          const SizedBox(height: 24),
          Text(
            'পেশাদার প্রবেশ',
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              TextButton(
                onPressed: () => context.push(DoctorLoginScreen.routePath),
                child: const Text('চিকিৎসক'),
              ),
              TextButton(
                onPressed: () => context.push(TechnicianLoginScreen.routePath),
                child: const Text('AI টেকনিশিয়ান'),
              ),
            ],
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
    );
  }
}
