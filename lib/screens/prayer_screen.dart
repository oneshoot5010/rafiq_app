import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import '../services/prayer_times_service.dart';

class PrayerScreen extends StatefulWidget {
  const PrayerScreen({super.key});

  @override
  State<PrayerScreen> createState() => _PrayerScreenState();
}

class _PrayerScreenState extends State<PrayerScreen> {
  DailyPrayerTimes? _times;
  String _status = 'جاري تحديد الموقع...';

  @override
  void initState() {
    super.initState();
    _loadTimes();
  }

  Future<void> _loadTimes() async {
    double lat = 21.3891, lon = 39.8579; // مكة كموقع افتراضي
    bool usedFallback = true;

    try {
      final permission = await Geolocator.checkPermission();
      LocationPermission perm = permission;
      if (perm == LocationPermission.denied) {
        perm = await Geolocator.requestPermission();
      }
      if (perm == LocationPermission.always ||
          perm == LocationPermission.whileInUse) {
        final pos = await Geolocator.getCurrentPosition(
          desiredAccuracy: LocationAccuracy.medium,
        );
        lat = pos.latitude;
        lon = pos.longitude;
        usedFallback = false;
      }
    } catch (_) {
      // نستخدم القيمة الافتراضية عند فشل تحديد الموقع
    }

    final now = DateTime.now();
    final tzOffsetHours = now.timeZoneOffset.inMinutes / 60.0;
    final times = PrayerTimesService.compute(
      lat: lat,
      lon: lon,
      date: now,
      timezoneOffsetHours: tzOffsetHours,
    );

    setState(() {
      _times = times;
      _status = usedFallback
          ? 'تعذّر الوصول للموقع — عرض توقيت مكة المكرمة (فعّل صلاحية الموقع لدقة أكبر)'
          : 'تم تحديد الموقع (${lat.toStringAsFixed(2)}, ${lon.toStringAsFixed(2)})';
    });
  }

  String? _nextPrayerName() {
    if (_times == null) return null;
    final now = DateTime.now();
    final nowMinutes = now.hour * 60 + now.minute;
    String? next;
    int minDiff = 1 << 30;
    _times!.asMap().forEach((name, t) {
      if (t == null) return;
      final mins = t.hour * 60 + t.minute;
      final diff = mins - nowMinutes;
      if (diff > 0 && diff < minDiff) {
        minDiff = diff;
        next = name;
      }
    });
    return next;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final next = _nextPrayerName();

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('مواقيت الصلاة اليوم', style: theme.textTheme.titleLarge),
              const SizedBox(height: 8),
              Text(_status, style: theme.textTheme.bodySmall),
              const SizedBox(height: 16),
              if (_times == null)
                const Center(child: CircularProgressIndicator())
              else
                ..._times!.asMap().entries.map((entry) {
                  final isNext = entry.key == next;
                  return Container(
                    margin: const EdgeInsets.symmetric(vertical: 4),
                    padding: const EdgeInsets.symmetric(
                        horizontal: 12, vertical: 10),
                    decoration: BoxDecoration(
                      color: isNext
                          ? theme.colorScheme.primaryContainer
                          : null,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          entry.key + (isNext ? ' (القادمة)' : ''),
                          style: TextStyle(
                            fontWeight:
                                isNext ? FontWeight.bold : FontWeight.normal,
                          ),
                        ),
                        Text(entry.value?.format() ?? '--:--'),
                      ],
                    ),
                  );
                }),
            ],
          ),
        ),
      ),
    );
  }
}
