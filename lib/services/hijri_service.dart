/// تحويل تقريبي من التاريخ الميلادي إلى الهجري (خوارزمية حسابية شائعة).
/// لأغراض دقيقة جدًا (مواعيد الأعياد الرسمية) يُفضّل لاحقًا ربطها بجدول
/// رسمي من دار الإفتاء، لكنها كافية للاستخدام اليومي العام.
class HijriDate {
  final int year;
  final int month; // 1-12
  final int day;
  HijriDate(this.year, this.month, this.day);
}

class HijriService {
  static const List<String> monthNames = [
    'محرم',
    'صفر',
    'ربيع الأول',
    'ربيع الآخر',
    'جمادى الأولى',
    'جمادى الآخرة',
    'رجب',
    'شعبان',
    'رمضان',
    'شوال',
    'ذو القعدة',
    'ذو الحجة',
  ];

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

  static HijriDate fromGregorian(DateTime date) {
    final jd = _julianDate(date).floor() + 0.5;
    final l0 = jd - 1948440 + 10632;
    final n = ((l0 - 1) / 10631).floor();
    final l1 = l0 - 10631 * n + 354;
    final j = ((10985 - l1) / 5316).floor() * ((50 * l1) / 17719).floor() +
        (l1 / 5670).floor() * ((43 * l1) / 15238).floor();
    final l2 = l1 -
        ((30 - j) / 15).floor() * ((17719 * j) / 50).floor() -
        (j / 16).floor() * ((15238 * j) / 43).floor() +
        29;
    final month = ((24 * l2) / 709).floor();
    final day = (l2 - ((709 * month) / 24).floor()).toInt();
    final year = 30 * n + j - 30;
    return HijriDate(year.toInt(), month, day);
  }

  static String formatToday(DateTime date) {
    final h = fromGregorian(date);
    final name = (h.month >= 1 && h.month <= 12) ? monthNames[h.month - 1] : '';
    return '${h.day} $name ${h.year} هـ';
  }
}
