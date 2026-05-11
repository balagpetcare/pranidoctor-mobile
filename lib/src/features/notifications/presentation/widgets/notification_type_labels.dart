import 'package:flutter/material.dart';

/// Normalizes API `type` strings for lookup (case-insensitive, `-` → `_`).
String notificationTypeKey(String type) {
  return type.trim().toLowerCase().replaceAll('-', '_');
}

/// Bengali short label for notification [type]; safe fallback for unknown values.
String notificationTypeLabelBn(String type) {
  switch (notificationTypeKey(type)) {
    case 'otp_login':
      return 'লগইন / OTP';
    case 'request_submitted':
      return 'অনুরোধ জমা';
    case 'doctor_accepted':
      return 'ডাক্তার গ্রহণ';
    case 'technician_accepted':
      return 'টেকনিশিয়ান গ্রহণ';
    case 'request_completed':
      return 'অনুরোধ সম্পন্ন';
    case 'payment_billing_update':
      return 'পেমেন্ট / বিলিং';
    case 'follow_up_reminder':
      return 'ফলো-আপ মনে করিয়ে';
    case 'admin_system_notice':
      return 'সিস্টেম বিজ্ঞপ্তি';
    case 'booking_update':
    case 'service_booking_update':
      return 'বুকিং আপডেট';
    case 'verification_update':
    case 'profile_verification_update':
      return 'যাচাইকরণ আপডেট';
    case 'earnings_alert':
    case 'wallet_credit':
      return 'আয় সতর্কতা';
    case 'appointment_reminder':
    case 'appointment_upcoming':
      return 'অ্যাপয়েন্ট মনে করিয়ে';
    case 'emergency_request':
    case 'emergency_dispatch':
      return 'জরুরি অনুরোধ';
    default:
      final t = type.trim();
      if (t.isEmpty) return 'বিজ্ঞপ্তি';
      return t.replaceAll('_', ' ');
  }
}

/// Icon per known [type]; generic bell for unknown.
IconData notificationTypeIcon(String type) {
  switch (notificationTypeKey(type)) {
    case 'otp_login':
      return Icons.sms_outlined;
    case 'request_submitted':
      return Icons.send_outlined;
    case 'doctor_accepted':
      return Icons.medical_services_outlined;
    case 'technician_accepted':
      return Icons.build_outlined;
    case 'request_completed':
      return Icons.task_alt_outlined;
    case 'payment_billing_update':
      return Icons.payments_outlined;
    case 'follow_up_reminder':
      return Icons.alarm_outlined;
    case 'admin_system_notice':
      return Icons.info_outline_rounded;
    case 'booking_update':
    case 'service_booking_update':
      return Icons.event_note_outlined;
    case 'verification_update':
    case 'profile_verification_update':
      return Icons.verified_user_outlined;
    case 'earnings_alert':
    case 'wallet_credit':
      return Icons.account_balance_wallet_outlined;
    case 'appointment_reminder':
    case 'appointment_upcoming':
      return Icons.event_available_outlined;
    case 'emergency_request':
    case 'emergency_dispatch':
      return Icons.emergency_outlined;
    default:
      return Icons.notifications_outlined;
  }
}
