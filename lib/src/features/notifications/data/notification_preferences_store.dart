import 'package:shared_preferences/shared_preferences.dart';

import 'package:pranidoctor_mobile/src/features/notifications/domain/notification_category.dart';

/// Per-category opt-in for foreground/local fan-out (push policy stays server-side).
class NotificationPreferencesState {
  const NotificationPreferencesState({
    required this.byCategory,
  });

  final Map<NotificationCategory, bool> byCategory;

  bool isEnabled(NotificationCategory c) => byCategory[c] ?? true;

  NotificationPreferencesState copyWithCategory(
    NotificationCategory c,
    bool enabled,
  ) {
    final next = Map<NotificationCategory, bool>.from(byCategory);
    next[c] = enabled;
    return NotificationPreferencesState(byCategory: next);
  }

  static NotificationPreferencesState allOn() {
    return NotificationPreferencesState(
      byCategory: {
        for (final e in NotificationCategory.values) e: true,
      },
    );
  }
}

class NotificationPreferencesStore {
  static const _prefix = 'pd_notif_cat_v1_';

  Future<NotificationPreferencesState> load() async {
    final prefs = await SharedPreferences.getInstance();
    final map = <NotificationCategory, bool>{};
    for (final c in NotificationCategory.values) {
      map[c] = prefs.getBool('$_prefix${c.name}') ?? true;
    }
    return NotificationPreferencesState(byCategory: map);
  }

  Future<void> setEnabled(NotificationCategory c, bool on) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('$_prefix${c.name}', on);
  }
}
