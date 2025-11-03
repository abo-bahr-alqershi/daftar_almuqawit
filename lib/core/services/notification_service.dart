/// خدمة الإشعارات المحلية والبعيدة
/// تدير الإشعارات المحلية والمجدولة واستقبال إشعارات FCM

import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;

/// خدمة الإشعارات
class NotificationService {
  final FlutterLocalNotificationsPlugin _plugin = FlutterLocalNotificationsPlugin();
  bool _initialized = false;

  Future<void> _ensureInitialized() async {
    if (_initialized) return;
    const androidInit = AndroidInitializationSettings('@mipmap/ic_launcher');
    const iosInit = DarwinInitializationSettings();
    const initSettings = InitializationSettings(android: androidInit, iOS: iosInit);
    await _plugin.initialize(initSettings);

    const androidChannel = AndroidNotificationChannel(
      'debts',
      'تذكيرات الديون',
      description: 'قناة لإشعارات تذكير الديون',
      importance: Importance.defaultImportance,
    );
    await _plugin.resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(androidChannel);
    _initialized = true;
  }

  /// إرسال تذكير بالدين
  Future<void> sendDebtReminder(int debtId) async {
    await _ensureInitialized();
    const android = AndroidNotificationDetails(
      'debts',
      'تذكيرات الديون',
      channelDescription: 'قناة لإشعارات تذكير الديون',
      importance: Importance.defaultImportance,
      priority: Priority.defaultPriority,
    );
    const ios = DarwinNotificationDetails();
    await _plugin.show(
      debtId,
      'تذكير بالدين',
      'لديك دين رقم $debtId بحاجة للمراجعة',
      const NotificationDetails(android: android, iOS: ios),
      payload: 'debt:$debtId',
    );
  }

  /// جدولة إشعار
  Future<void> scheduleNotification({
    required int id,
    required String title,
    required String body,
    required DateTime scheduledDate,
    String? payload,
  }) async {
    await _ensureInitialized();
    
    const android = AndroidNotificationDetails(
      'scheduled',
      'إشعارات مجدولة',
      channelDescription: 'قناة للإشعارات المجدولة',
      importance: Importance.high,
      priority: Priority.high,
    );
    const ios = DarwinNotificationDetails();
    
    await _plugin.zonedSchedule(
      id,
      title,
      body,
      tz.TZDateTime.from(scheduledDate, tz.local),
      const NotificationDetails(android: android, iOS: ios),
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
      payload: payload,
    );
  }

  /// إلغاء إشعار مجدول
  Future<void> cancelNotification(int id) async {
    await _plugin.cancel(id);
  }

  /// إلغاء جميع الإشعارات
  Future<void> cancelAllNotifications() async {
    await _plugin.cancelAll();
  }

  /// معالجة النقر على الإشعار
  void onNotificationClick(Function(String?) callback) {
    _plugin.initialize(
      const InitializationSettings(
        android: AndroidInitializationSettings('@mipmap/ic_launcher'),
        iOS: DarwinInitializationSettings(),
      ),
      onDidReceiveNotificationResponse: (details) {
        callback(details.payload);
      },
    );
  }
}
