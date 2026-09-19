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
  bool _loading = false;

  @override
  void initState() {
    super.initState();
    _loadTimes();
  }

  Future<void> _loadTimes({bool isRetry = false}) async {
    setState(() {
      _loading = true;
      _status = isRetry ? 'جاري إعادة تحديد الموقع...' : 'جاري تحديد الموقع...';
    });

    double lat = 21.3891, lon = 39.8579; // مكة كموقع افتراضي
    bool usedFallback = true;

    try {
      final serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (serviceEnabled) {
        final permission = await Geolocator.checkPermission();
        LocationPermission perm = permission;
        if (perm == LocationPermission.denied) {
          perm = await Geolocator.requestPermission();
        }
        if (perm == LocationPermission.always ||
            perm == LocationPermission.whileInUse) {
          try {
            final pos = await Geolocator.getCurrentPosition(
              desiredAccuracy: LocationAccuracy.medium,
              timeLimit: Duration(seconds: isRetry ? 15 : 8),
            );
            lat = pos.latitude;
            lon = pos.longitude;
            usedFallback = false;
          } catch (_) {
            final lastPos = await Geolocator.getLastKnownPosition();
            if (lastPos != null) {
              lat = lastPos.latitude;
              lon = lastPos.longitude;
              usedFallback = false;
            }
          }
        }
      }
    } catch (_) {
      // نستخدم القيمة الافتراضية عند فشل تحديد الموقع
    }

    if (!mounted) return;

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
      _loading = false;
      _status = usedFallback
          ? 'تعذّر الوصول للموقع — عرض توقيت مكة المكرمة (اضغط تحديث لإعادة المحاولة)'
          : 'تم تحديد الموقع (${lat.toStringAsFixed(2)}, ${lon.toStringAsFixed(2)})';
    });

    // لو فشلنا في أول محاولة، نجرب تلقائيًا مرة واحدة كمان بعد شوية
    // بدل ما نضطر المستخدم يقفل ويفتح التطبيق
    if (usedFallback && !isRetry) {
      await Future.delayed(const Duration(seconds: 3));
      if (mounted) _loadTimes(isRetry: true);
    }
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
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('مواقيت الصلاة اليوم', style: theme.textTheme.titleLarge),
                  IconButton(
                    icon: _loading
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Icon(Icons.refresh),
                    tooltip: 'تحديث الموقع',
                    onPressed: _loading ? null : () => _loadTimes(),
                  ),
                ],
              ),
              const SizedBox(height: 4),
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
