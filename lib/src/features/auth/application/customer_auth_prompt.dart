import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:pranidoctor_mobile/src/design_system/prani_tokens.dart';
import 'package:pranidoctor_mobile/src/design_system/widgets/prani_bottom_sheet.dart';
import 'package:pranidoctor_mobile/src/design_system/widgets/prani_buttons.dart';
import 'package:pranidoctor_mobile/src/features/auth/login_entry_screen.dart';
import 'package:pranidoctor_mobile/src/features/session/application/session_notifier.dart';

/// Shows a Bengali prompt and navigates to the existing customer OTP screen.
///
/// [loginTab]: after successful login, selects home shell tab — `profile`,
/// `notifications`, or `services`.
Future<void> showCustomerAuthRequiredSheet(
  BuildContext context, {
  String? loginTab,
}) async {
  await showPraniBottomSheet<void>(
    context: context,
    title: 'সেবা নিতে মোবাইল নম্বর ভেরিফাই করুন',
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          'ডাক্তার বুকিং, আপনার অ্যাকাউন্ট এবং ব্যক্তিগত সেবার জন্য নম্বর যাচাই করা প্রয়োজন।',
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
            height: 1.4,
            color: Theme.of(context).colorScheme.onSurfaceVariant,
          ),
        ),
        const SizedBox(height: PraniSpacing.xl),
        PraniPrimaryButton(
          label: 'লগইন / OTP ভেরিফাই করুন',
          onPressed: () {
            Navigator.of(context).pop();
            final tab = loginTab?.trim();
            final q = tab != null && tab.isNotEmpty
                ? '?tab=${Uri.encodeComponent(tab)}'
                : '';
            context.push('${LoginEntryScreen.routePath}$q');
          },
        ),
      ],
    ),
  );
}

bool isCustomerAuthenticated(WidgetRef ref) {
  final s = ref.read(sessionNotifierProvider);
  return s.isAuthenticated && s.role == AppRole.customer;
}
