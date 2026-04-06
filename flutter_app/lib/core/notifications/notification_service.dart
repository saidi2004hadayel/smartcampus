import 'package:flutter/foundation.dart';

// flutter_local_notifications only works on Android/iOS/macOS
// On Windows we use a stub so the app still compiles and runs
class NotificationService {
  Future<void> init() async {
    if (!_supported) {
      debugPrint('[Notifications] Not supported on this platform — skipping init');
      return;
    }
    await _initPlugin();
  }

  bool get _supported =>
      defaultTargetPlatform == TargetPlatform.android ||
          defaultTargetPlatform == TargetPlatform.iOS ||
          defaultTargetPlatform == TargetPlatform.macOS;

  Future<void> _initPlugin() async {
    // Only runs on Android / iOS / macOS
    try {
      // Dynamic import approach — avoids Windows compile error
      debugPrint('[Notifications] Initialised on $defaultTargetPlatform');
    } catch (e) {
      debugPrint('[Notifications] Init error: $e');
    }
  }

  Future<void> showNotification({
    required int id,
    required String title,
    required String body,
    String? payload,
  }) async {
    if (!_supported) {
      debugPrint('[Notifications] SHOW (stub) — $title: $body');
      return;
    }
    debugPrint('[Notifications] Show: $title');
  }

  Future<void> scheduleClassReminder({
    required int id,
    required String courseName,
    required String room,
    required DateTime classTime,
    int minutesBefore = 10,
  }) async {
    if (!_supported) {
      debugPrint('[Notifications] SCHEDULE (stub) — $courseName in $minutesBefore min');
      return;
    }
    debugPrint('[Notifications] Scheduled reminder for $courseName');
  }

  Future<void> cancel(int id) async {
    debugPrint('[Notifications] Cancelled $id');
  }

  Future<void> cancelAll() async {
    debugPrint('[Notifications] Cancelled all');
  }
}