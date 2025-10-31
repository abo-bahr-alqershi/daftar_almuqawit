// ignore_for_file: public_member_api_docs

import 'package:flutter_local_notifications/flutter_local_notifications.dart';

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
}
