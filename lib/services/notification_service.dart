import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest_all.dart' as tzdata;
import 'prayer_times_service.dart';

class NotificationService {
  static final FlutterLocalNotificationsPlugin _plugin =
      FlutterLocalNotificationsPlugin();
  static bool _initialized = false;
  static const String _channelId = 'prayer_athan_channel_v2';

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

  /// يطلب من المستخدم استثناء التطبيق من توفير الطاقة عبر نافذة النظام
  /// الرسمية (مش إعدادات مخصصة لكل شركة، ده إذن أندرويد قياسي).
  /// يرجّع true لو الإذن اتاح بالفعل أو اتوافق عليه، و false لو اترفض.
  static Future<bool> requestIgnoreBatteryOptimizations() async {
    final status = await Permission.ignoreBatteryOptimizations.status;
    if (status.isGranted) return true;
    final result = await Permission.ignoreBatteryOptimizations.request();
    return result.isGranted;
  }

  static Future<bool> hasBatteryOptimizationExemption() async {
    return (await Permission.ignoreBatteryOptimizations.status).isGranted;
  }

  static AndroidNotificationDetails _athanDetails({bool withStopAction = true}) {
    return AndroidNotificationDetails(
      _channelId,
      'أذان الصلاة',
      channelDescription: 'تنبيه صوتي بموعد كل صلاة',
      importance: Importance.max,
      priority: Priority.high,
      sound: const RawResourceAndroidNotificationSound('athan'),
      playSound: true,
      audioAttributesUsage: AudioAttributesUsage.alarm,
      fullScreenIntent: true,
      category: AndroidNotificationCategory.alarm,
      actions: withStopAction
          ? const [
              AndroidNotificationAction(
                'stop_athan',
                'إيقاف الأذان',
                cancelNotification: true,
              ),
            ]
          : null,
    );
  }

  /// يجدول أذان اليوم (المتبقي فقط) وأذان الغد بالكامل، بأعلى وضع أولوية
  /// متاح في أندرويد (منبه الساعة)، عشان يفضل فيه رصيد أمان يوم كامل حتى
  /// لو المستخدم نسي يفتح التطبيق. يرجّع أسماء الصلوات المجدولة (للتشخيص).
  static Future<List<String>> scheduleUpcoming({
    required DailyPrayerTimes today,
    required DailyPrayerTimes tomorrow,
  }) async {
    if (!_initialized) await init();
    await _plugin.cancelAll();
    final scheduledNames = <String>[];
    final prefs = await SharedPreferences.getInstance();
    final details = NotificationDetails(android: _athanDetails());
    final now = DateTime.now();
    final tomorrowDate = now.add(const Duration(days: 1));
    int id = 0;

    Future<void> scheduleDay(
        DailyPrayerTimes dt, DateTime baseDate, String dayLabel) async {
      final entries = <String, PrayerTime?>{
        'الفجر': dt.fajr,
        'الظهر': dt.dhuhr,
        'العصر': dt.asr,
        'المغرب': dt.maghrib,
        'العشاء': dt.isha,
      };
      for (final entry in entries.entries) {
        final name = entry.key;
        final enabled = prefs.getBool(prefKeys[name]!) ?? true;
        if (!enabled) continue;
        final t = entry.value;
        if (t == null) continue;
        final localTarget = DateTime(
            baseDate.year, baseDate.month, baseDate.day, t.hour, t.minute);
        if (localTarget.isBefore(now)) continue;
        final scheduled = tz.TZDateTime.from(localTarget, tz.UTC);
        await _plugin.zonedSchedule(
          id++,
          'حان الآن موعد صلاة $name',
          'حي على الصلاة، حي على الفلاح',
          scheduled,
          details,
          androidScheduleMode: AndroidScheduleMode.alarmClock,
          uiLocalNotificationDateInterpretation:
              UILocalNotificationDateInterpretation.absoluteTime,
        );
        scheduledNames.add('$name $dayLabel');
      }
    }

    await scheduleDay(today, now, '(اليوم)');
    await scheduleDay(tomorrow, tomorrowDate, '(غدًا)');

    return scheduledNames;
  }

  static Future<void> scheduleTest() async {
    if (!_initialized) await init();
    final details = NotificationDetails(android: _athanDetails());
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
      androidScheduleMode: AndroidScheduleMode.alarmClock,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
    );
  }

  static Future<void> showInstant() async {
    if (!_initialized) await init();
    final details =
        NotificationDetails(android: _athanDetails(withStopAction: false));
    await _plugin.show(
      998,
      'اختبار فوري',
      'إشعار فوري من غير جدولة',
      details,
    );
  }

  static Future<bool?> canScheduleExact() async {
    if (!_initialized) await init();
    final androidImpl = _plugin.resolvePlatformSpecificImplementation<
        AndroidFlutterLocalNotificationsPlugin>();
    return androidImpl?.canScheduleExactNotifications();
  }

  static Future<void> cancelAll() => _plugin.cancelAll();
}
