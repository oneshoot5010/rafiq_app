import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest_all.dart' as tzdata;
import 'prayer_times_service.dart';

class NotificationService {
  static final FlutterLocalNotificationsPlugin _plugin =
      FlutterLocalNotificationsPlugin();
  static bool _initialized = false;
  static const String _channelId = 'prayer_athan_channel';

  static const Map<String, String> prefKeys = {
    'الفجر': 'athan_fajr',
    'الظهر': 'athan_dhuhr',
    'العصر': 'athan_asr',
    'المغرب': 'athan_maghrib',
    'العشاء': 'athan_isha',
  };

  static Future<void> init() async {
    if (_initialized) return;

    tzdata.initializeTimeZones();

    const androidSettings =
        AndroidInitializationSettings('@mipmap/ic_launcher');
    const initSettings = InitializationSettings(android: androidSettings);
    await _plugin.initialize(initSettings);

    final androidImpl = _plugin.resolvePlatformSpecificImplementation<
        AndroidFlutterLocalNotificationsPlugin>();
    await androidImpl?.requestNotificationsPermission();
    await androidImpl?.requestExactAlarmsPermission();

    const channel = AndroidNotificationChannel(
      _channelId,
      'أذان الصلاة',
      description: 'تنبيه صوتي بموعد كل صلاة',
      importance: Importance.max,
      sound: RawResourceAndroidNotificationSound('athan'),
      playSound: true,
      audioAttributesUsage: AudioAttributesUsage.alarm,
    );
    await androidImpl?.createNotificationChannel(channel);

    _initialized = true;
  }

  /// يجدول تنبيهات الأذان للصلوات المتبقية اليوم فقط (الفجر، الظهر، العصر،
  /// المغرب، العشاء). يُستحسن مناداتها كل ما فُتحت شاشة الصلاة أو التطبيق،
  /// حتى تتجدد المواعيد يوميًا لأن مواقيت الصلاة بتتغير كل يوم شوية.
  static Future<void> scheduleForToday(DailyPrayerTimes times) async {
    if (!_initialized) await init();
    await _plugin.cancelAll();

    final prefs = await SharedPreferences.getInstance();

    final entries = <String, PrayerTime?>{
      'الفجر': times.fajr,
      'الظهر': times.dhuhr,
      'العصر': times.asr,
      'المغرب': times.maghrib,
      'العشاء': times.isha,
    };

    const androidDetails = AndroidNotificationDetails(
      _channelId,
      'أذان الصلاة',
      channelDescription: 'تنبيه صوتي بموعد كل صلاة',
      importance: Importance.max,
      priority: Priority.high,
      sound: RawResourceAndroidNotificationSound('athan'),
      playSound: true,
      audioAttributesUsage: AudioAttributesUsage.alarm,
      fullScreenIntent: true,
      actions: [
        AndroidNotificationAction(
          'stop_athan',
          'إيقاف الأذان',
          cancelNotification: true,
        ),
      ],
    );
    const details = NotificationDetails(android: androidDetails);

    final now = DateTime.now();
    int id = 0;
    for (final entry in entries.entries) {
      final name = entry.key;
      final enabled = prefs.getBool(prefKeys[name]!) ?? true;
      if (!enabled) continue;
      final t = entry.value;
      if (t == null) continue;
      final localTarget =
          DateTime(now.year, now.month, now.day, t.hour, t.minute);
      if (localTarget.isBefore(now)) continue;
      final scheduled = tz.TZDateTime.from(localTarget, tz.UTC);
      await _plugin.zonedSchedule(
        id++,
        'حان الآن موعد صلاة $name',
        'حي على الصلاة، حي على الفلاح',
        scheduled,
        details,
        androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
        uiLocalNotificationDateInterpretation:
            UILocalNotificationDateInterpretation.absoluteTime,
      );
    }
  }

  static Future<void> scheduleTest() async {
    if (!_initialized) await init();

    const androidDetails = AndroidNotificationDetails(
      _channelId,
      'أذان الصلاة',
      channelDescription: 'تنبيه صوتي بموعد كل صلاة',
      importance: Importance.max,
      priority: Priority.high,
      sound: RawResourceAndroidNotificationSound('athan'),
      playSound: true,
      audioAttributesUsage: AudioAttributesUsage.alarm,
      fullScreenIntent: true,
    );
    const details = NotificationDetails(android: androidDetails);

    final scheduled = tz.TZDateTime.from(
      DateTime.now().add(const Duration(seconds: 10)),
      tz.UTC,
    );

    await _plugin.zonedSchedule(
      999,
      'اختبار الأذان',
      'هذا إشعار تجريبي للتأكد من عمل الصوت',
      scheduled,
      details,
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
    );
  }

  static Future<void> cancelAll() => _plugin.cancelAll();
}
