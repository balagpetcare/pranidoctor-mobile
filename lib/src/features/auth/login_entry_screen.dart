import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../app/screen_padding.dart';
import '../../core/constants/pd_radii.dart';
import '../../core/validation/bd_phone.dart';
import '../../core/widgets/pd_text_field.dart';
import '../home/home_shell_screen.dart';
import '../session/application/session_notifier.dart';
import 'data/mobile_otp_auth_repository.dart';
import 'otp_verify_screen.dart';

/// Customer phone login → OTP ([OtpVerifyScreen]).
class LoginEntryScreen extends ConsumerStatefulWidget {
  const LoginEntryScreen({super.key});

  static const routePath = '/login';
  static const routeName = 'loginEntry';

  @override
  ConsumerState<LoginEntryScreen> createState() => _LoginEntryScreenState();
}

class _LoginEntryScreenState extends ConsumerState<LoginEntryScreen> {
  final _phoneController = TextEditingController();
  bool _loading = false;
  String? _fieldError;
  String? _apiError;

  @override
  void dispose() {
    _phoneController.dispose();
    super.dispose();
  }

  Future<void> _sendOtp() async {
    final normalized = BdPhone.normalizeToApiDigits(_phoneController.text);
    if (normalized == null) {
      setState(() {
        _fieldError = 'সঠিক বাংলাদেশি মোবাইল নম্বর দিন (০১১ সংখ্যার বা ৮৮০১…)।';
        _apiError = null;
      });
      return;
    }

    setState(() {
      _loading = true;
      _fieldError = null;
      _apiError = null;
    });

    try {
      final repo = ref.read(mobileOtpAuthRepositoryProvider);
      final result = await repo.startOtp(normalized);
      if (!mounted) return;
      await context.pushNamed(
        OtpVerifyScreen.routeName,
        extra: <String, dynamic>{
          'phone': normalized,
          'ttl': result.otpTtlSeconds,
        },
      );
    } on OtpAuthException catch (e) {
      if (mounted) setState(() => _apiError = e.message);
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  void _debugGuest() {
    ref.read(sessionNotifierProvider.notifier).signInGuest();
    context.go(HomeShellScreen.routePath);
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final pad = pdScreenPadding(context);

    return Scaffold(
      appBar: AppBar(title: const Text('লগইন')),
      body: ListView(
        padding: pad.copyWith(top: 16, bottom: 32),
        children: [
          Icon(Icons.pets, size: 72, color: scheme.primary),
          const SizedBox(height: 20),
          Text(
            'প্রাণী ডাক্তার',
            textAlign: TextAlign.center,
            style: Theme.of(
              context,
            ).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 8),
          Text(
            'মোবাইল নম্বর দিয়ে লগইন করুন',
            textAlign: TextAlign.center,
            style: Theme.of(
              context,
            ).textTheme.bodyLarge?.copyWith(color: scheme.onSurfaceVariant),
          ),
          const SizedBox(height: 28),
          PdTextField(
            controller: _phoneController,
            keyboardType: TextInputType.phone,
            textInputAction: TextInputAction.done,
            labelText: 'মোবাইল নম্বর',
            hintText: '০১৭১২৩৪৫৬৭৮ অথবা ৮৮০১…',
            prefixIcon: Icon(Icons.phone_outlined, color: scheme.primary),
            enabled: !_loading,
            inputFormatters: [
              FilteringTextInputFormatter.allow(RegExp(r'[\d+\s-]')),
            ],
            onSubmitted: (_) => _sendOtp(),
            onChanged: (_) {
              if (_fieldError != null || _apiError != null) {
                setState(() {
                  _fieldError = null;
                  _apiError = null;
                });
              }
            },
          ),
          if (_fieldError != null) ...[
            const SizedBox(height: 8),
            Text(
              _fieldError!,
              style: Theme.of(
                context,
              ).textTheme.bodySmall?.copyWith(color: scheme.error),
            ),
          ],
          if (_apiError != null) ...[
            const SizedBox(height: 8),
            Text(
              _apiError!,
              style: Theme.of(
                context,
              ).textTheme.bodySmall?.copyWith(color: scheme.error),
            ),
          ],
          const SizedBox(height: 24),
          FilledButton(
            onPressed: _loading ? null : _sendOtp,
            child: _loading
                ? SizedBox(
                    height: 24,
                    width: 24,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: scheme.onPrimary,
                    ),
                  )
                : const Text('কোড পাঠান'),
          ),
          const SizedBox(height: 16),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(PdRadii.md),
              child: Text(
                'নম্বরটি যাচাই করে আমরা এসএমএসে একটি কোড পাঠাব। কোডটি এককালীন এবং গোপন রাখুন।',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: scheme.onSurfaceVariant,
                ),
              ),
            ),
          ),
          if (kDebugMode) ...[
            const SizedBox(height: 24),
            TextButton(
              onPressed: _loading ? null : _debugGuest,
              child: const Text('ডেমো প্রবেশ (শুধু ডিবাগ)'),
            ),
          ],
        ],
      ),
    );
  }
}
