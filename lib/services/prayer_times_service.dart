import 'dart:math';

/// نتيجة حساب المواقيت لكل صلاة، كساعة ودقيقة محلية
class PrayerTime {
  final int hour;
  final int minute;
  PrayerTime(this.hour, this.minute);

  String format() {
    final period = hour >= 12 ? 'م' : 'ص';
    int h = hour % 12;
    if (h == 0) h = 12;
    final mm = minute.toString().padLeft(2, '0');
    return '$h:$mm $period';
  }
}

class DailyPrayerTimes {
  final PrayerTime? fajr;
  final PrayerTime? sunrise;
  final PrayerTime? dhuhr;
  final PrayerTime? asr;
  final PrayerTime? maghrib;
  final PrayerTime? isha;

  DailyPrayerTimes({
    required this.fajr,
    required this.sunrise,
    required this.dhuhr,
    required this.asr,
    required this.maghrib,
    required this.isha,
  });

  Map<String, PrayerTime?> asMap() => {
        'الفجر': fajr,
        'الشروق': sunrise,
        'الظهر': dhuhr,
        'العصر': asr,
        'المغرب': maghrib,
        'العشاء': isha,
      };
}

/// حساب مواقيت الصلاة فلكيًا بدون أي اتصال بالإنترنت.
/// يعتمد على معادلات موضع الشمس (مشابه لطريقة رابطة العالم الإسلامي - MWL).
class PrayerTimesService {
  static const double fajrAngle = 18.0;
  static const double ishaAngle = 17.0;

  static double _julianDate(DateTime date) {
    final utc = date.toUtc();
    int y = utc.year, m = utc.month;
    final d = utc.day;
    if (m <= 2) {
      y -= 1;
      m += 12;
    }
    final a = (y / 100).floor();
    final b = 2 - a + (a / 4).floor();
    return (365.25 * (y + 4716)).floorToDouble() +
        (30.6001 * (m + 1)).floorToDouble() +
        d +
        b -
        1524.5;
  }

  static ({double decl, double eqt}) _sunPosition(double jd) {
    final d = jd - 2451545.0;
    final g = (357.529 + 0.98560028 * d) % 360;
    final q = (280.459 + 0.98564736 * d) % 360;
    final gRad = g * pi / 180;
    final l = (q + 1.915 * sin(gRad) + 0.020 * sin(2 * gRad)) % 360;
    final e = 23.439 - 0.00000036 * d;
    final eRad = e * pi / 180, lRad = l * pi / 180;
    double ra = atan2(cos(eRad) * sin(lRad), cos(lRad)) * 180 / pi / 15;
    final decl = asin(sin(eRad) * sin(lRad)) * 180 / pi;
    final eqt = q / 15 - (ra < 0 ? ra + 24 : ra);
    return (decl: decl, eqt: eqt);
  }

  static double? _timeForAngle(
      double angle, double lat, double decl, bool isAfterNoon) {
    final latR = lat * pi / 180, declR = decl * pi / 180, angR = angle * pi / 180;
    final cosH = (-sin(angR) - sin(latR) * sin(declR)) / (cos(latR) * cos(declR));
    if (cosH > 1 || cosH < -1) return null;
    final h = acos(cosH) * 180 / pi / 15;
    return isAfterNoon ? 12 + h : 12 - h;
  }

  /// يحسب مواقيت الصلاة الست ليوم معين عند إحداثيات معينة.
  static DailyPrayerTimes compute({
    required double lat,
    required double lon,
    required DateTime date,
    required double timezoneOffsetHours,
  }) {
    final jd = _julianDate(date);
    final sun = _sunPosition(jd);
    final decl = sun.decl;
    final eqt = sun.eqt;
    final tz = timezoneOffsetHours;

    PrayerTime? toLocal(double? hoursFromSolarNoon) {
      if (hoursFromSolarNoon == null) return null;
      double t = hoursFromSolarNoon + tz - lon / 15 + eqt / 60;
      t = ((t % 24) + 24) % 24;
      int hh = t.floor();
      int mm = ((t - hh) * 60).round();
      if (mm == 60) {
        mm = 0;
        hh = (hh + 1) % 24;
      }
      return PrayerTime(hh, mm);
    }

    final fajrH = _timeForAngle(fajrAngle, lat, decl, false);
    final sunriseH = _timeForAngle(0.833, lat, decl, false);
    final sunsetH = _timeForAngle(0.833, lat, decl, true);
    final ishaH = _timeForAngle(ishaAngle, lat, decl, true);
    final asrAngleDeg =
        -atan(1 / (1 + tan((lat - decl).abs() * pi / 180))) * 180 / pi;
    final asrH = _timeForAngle(asrAngleDeg, lat, decl, true);

    return DailyPrayerTimes(
      fajr: toLocal(fajrH),
      sunrise: toLocal(sunriseH),
      dhuhr: toLocal(12),
      asr: toLocal(asrH),
      maghrib: toLocal(sunsetH),
      isha: toLocal(ishaH),
    );
  }

  /// يحسب اتجاه القبلة (بالدرجات من الشمال) من أي إحداثيات على الأرض.
  static double qiblaBearing({required double lat, required double lon}) {
    const kaabaLat = 21.4225 * pi / 180;
    const kaabaLon = 39.8262 * pi / 180;
    final latR = lat * pi / 180, lonR = lon * pi / 180;
    final dLon = kaabaLon - lonR;
    final y = sin(dLon) * cos(kaabaLat);
    final x = cos(latR) * sin(kaabaLat) - sin(latR) * cos(kaabaLat) * cos(dLon);
    double bearing = atan2(y, x) * 180 / pi;
    return (bearing + 360) % 360;
  }
}
