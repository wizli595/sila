import 'dart:ui';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Overridden in main() with the instance loaded during bootstrap.
final prefsProvider = Provider<SharedPreferences>(
  (_) => throw UnimplementedError('prefsProvider must be overridden'),
);

/// null = first launch, language not chosen yet → language screen.
final localeProvider = StateNotifierProvider<LocaleNotifier, Locale?>((ref) {
  return LocaleNotifier(ref.read(prefsProvider));
});

class LocaleNotifier extends StateNotifier<Locale?> {
  static const _key = 'locale';
  final SharedPreferences _prefs;

  LocaleNotifier(this._prefs)
    : super(
        _prefs.getString(_key) != null ? Locale(_prefs.getString(_key)!) : null,
      );

  Future<void> set(String code) async {
    await _prefs.setString(_key, code);
    state = Locale(code);
  }
}

/// First-run intro (Give. Wait. Connect.) — shown once.
final introSeenProvider = StateNotifierProvider<IntroSeenNotifier, bool>((ref) {
  return IntroSeenNotifier(ref.read(prefsProvider));
});

class IntroSeenNotifier extends StateNotifier<bool> {
  static const _key = 'intro_seen';
  final SharedPreferences _prefs;

  IntroSeenNotifier(this._prefs) : super(_prefs.getBool(_key) ?? false);

  Future<void> markSeen() async {
    await _prefs.setBool(_key, true);
    state = true;
  }
}

/// One-time flags (coach-mark tours, etc.), keyed by pref name.
final seenFlagProvider =
    StateNotifierProvider.family<SeenFlagNotifier, bool, String>((ref, key) {
      return SeenFlagNotifier(ref.read(prefsProvider), key);
    });

class SeenFlagNotifier extends StateNotifier<bool> {
  final SharedPreferences _prefs;
  final String _key;

  SeenFlagNotifier(this._prefs, this._key)
    : super(_prefs.getBool(_key) ?? false);

  Future<void> markSeen() async {
    await _prefs.setBool(_key, true);
    state = true;
  }
}

/// Coach-mark tour keys
abstract final class CoachKeys {
  static const home = 'coach_marks_seen';
  static const confirm = 'coach_confirm_seen';
  static const waiting = 'coach_waiting_seen';
  static const inbox = 'coach_inbox_seen';
}

/// Whether the notification-permission explainer was shown (once, after
/// the first gift).
final notificationPrimedProvider =
    StateNotifierProvider<NotificationPrimedNotifier, bool>((ref) {
      return NotificationPrimedNotifier(ref.read(prefsProvider));
    });

class NotificationPrimedNotifier extends StateNotifier<bool> {
  static const _key = 'notification_primed';
  final SharedPreferences _prefs;

  NotificationPrimedNotifier(this._prefs)
    : super(_prefs.getBool(_key) ?? false);

  Future<void> markPrimed() async {
    await _prefs.setBool(_key, true);
    state = true;
  }
}

/// Local preference only — FCM wiring comes later.
final notificationsEnabledProvider =
    StateNotifierProvider<NotificationsNotifier, bool>((ref) {
      return NotificationsNotifier(ref.read(prefsProvider));
    });

class NotificationsNotifier extends StateNotifier<bool> {
  static const _key = 'notifications_enabled';
  final SharedPreferences _prefs;

  NotificationsNotifier(this._prefs) : super(_prefs.getBool(_key) ?? true);

  Future<void> set(bool enabled) async {
    await _prefs.setBool(_key, enabled);
    state = enabled;
  }
}
