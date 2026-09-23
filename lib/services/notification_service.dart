import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest_all.dart' as tzdata;
import 'package:flutter_timezone/flutter_timezone.dart';
import 'prayer_times_service.dart';

class NotificationService {
  static final FlutterLocalNotificationsPlugin _plugin =
      FlutterLocalNotificationsPlugin();
  static bool _initialized = false;
  static const String _channelId = 'prayer_athan_channel';

  static Future<void> init() async {
    if (_initialized) return;

    tzdata.initializeTimeZones();
    try {
      final String localTz = await FlutterTimezone.getLocalTimezone();
      tz.setLocalLocation(tz.getLocation(localTz));
    } catch (_) {
      tz.setLocalLocation(tz.getLocation('UTC'));
    }

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
    );
    const details = NotificationDetails(android: androidDetails);

    final now = tz.TZDateTime.now(tz.local);
    int id = 0;
    for (final entry in entries.entries) {
      final t = entry.value;
      if (t == null) continue;
      final scheduled = tz.TZDateTime(
          tz.local, now.year, now.month, now.day, t.hour, t.minute);
      if (scheduled.isBefore(now)) continue;
      await _plugin.zonedSchedule(
        id++,
        'حان الآن موعد صلاة ${entry.key}',
        'حي على الصلاة، حي على الفلاح',
        scheduled,
        details,
        androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
        uiLocalNotificationDateInterpretation:
            UiLocalNotificationDateInterpretation.absoluteTime,
      );
    }
  }

  static Future<void> cancelAll() => _plugin.cancelAll();
}
