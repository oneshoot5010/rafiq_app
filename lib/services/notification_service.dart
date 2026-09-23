import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest_all.dart' as tzdata;
import 'prayer_times_service.dart';

class NotificationService {
  static final FlutterLocalNotificationsPlugin _plugin =
      FlutterLocalNotificationsPlugin();
  static bool _initialized = false;
  static const String _channelId = 'prayer_athan_channel';

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

    final now = DateTime.now();
    int id = 0;
    for (final entry in entries.entries) {
      final t = entry.value;
      if (t == null) continue;
      final localTarget =
          DateTime(now.year, now.month, now.day, t.hour, t.minute);
      if (localTarget.isBefore(now)) continue;
      // نحول الوقت المحلي (المحسوب أصلاً بإزاحة الجهاز) إلى TZDateTime
      // بنفس اللحظة الزمنية الفعلية، من غير الحاجة لمعرفة اسم المنطقة الزمنية
      final scheduled = tz.TZDateTime.from(localTarget, tz.UTC);
      await _plugin.zonedSchedule(
        id++,
        'حان الآن موعد صلاة ${entry.key}',
        'حي على الصلاة، حي على الفلاح',
        scheduled,
        details,
        androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
        uiLocalNotificationDateInterpretation:
            UILocalNotificationDateInterpretation.absoluteTime,
      );
    }
  }

  static Future<void> cancelAll() => _plugin.cancelAll();
}
