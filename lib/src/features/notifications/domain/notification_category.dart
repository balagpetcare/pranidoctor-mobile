/// Enterprise notification categories (maps from API `type` + optional metadata).
enum NotificationCategory {
  booking,
  verification,
  earnings,
  appointment,
  emergency,
  general;

  String get labelBn => switch (this) {
        NotificationCategory.booking => 'বুকিং ও সেবা',
        NotificationCategory.verification => 'যাচাইকরণ',
        NotificationCategory.earnings => 'আয় ও পেমেন্ট',
        NotificationCategory.appointment => 'অ্যাপয়েন্টমেন্ট',
        NotificationCategory.emergency => 'জরুরি',
        NotificationCategory.general => 'সাধারণ',
      };

  /// FCM / WebSocket topic suffix (`prani.<category>` on server).
  String get topicSuffix => name;
}
