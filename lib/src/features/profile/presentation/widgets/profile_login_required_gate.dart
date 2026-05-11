import 'package:flutter/material.dart';

import 'package:pranidoctor_mobile/src/design_system/prani_page_insets.dart';
import 'package:pranidoctor_mobile/src/design_system/prani_tokens.dart';
import 'package:pranidoctor_mobile/src/design_system/widgets/prani_buttons.dart';
import 'package:pranidoctor_mobile/src/features/auth/application/customer_shell_login_navigation.dart';

/// Logged-out profile tab: primary path to OTP login.
class ProfileLoginRequiredGate extends StatelessWidget {
  const ProfileLoginRequiredGate({super.key});

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final hPad = PraniPageInsets.horizontalPadding(context);
    return Scaffold(
      backgroundColor: scheme.surfaceContainerLowest,
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: hPad),
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 400),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Icon(
                    Icons.lock_person_outlined,
                    size: 56,
                    color: scheme.primary,
                  ),
                  const SizedBox(height: PraniSpacing.xl),
                  Text(
                    'প্রোফাইল দেখতে লগইন করুন',
                    textAlign: TextAlign.center,
                    style: textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.w700,
                      height: 1.25,
                    ),
                  ),
                  const SizedBox(height: PraniSpacing.md),
                  Text(
                    'আপনার অ্যাকাউন্ট ও সেবার তথ্য দেখতে মোবাইল নম্বর দিয়ে নিরাপদ OTP লগইন করুন।',
                    textAlign: TextAlign.center,
                    style: textTheme.bodyMedium?.copyWith(
                      color: scheme.onSurfaceVariant,
                      height: 1.45,
                    ),
                  ),
                  const SizedBox(height: PraniSpacing.xxl),
                  PraniPrimaryButton(
                    label: 'লগইন করুন',
                    onPressed: () {
                      pdPushCustomerLoginIntent(context, shellTab: 'profile');
                    },
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
