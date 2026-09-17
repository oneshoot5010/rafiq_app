import 'dart:math';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import '../services/prayer_times_service.dart';

class QiblaScreen extends StatefulWidget {
  const QiblaScreen({super.key});

  @override
  State<QiblaScreen> createState() => _QiblaScreenState();
}

class _QiblaScreenState extends State<QiblaScreen> {
  double? _bearing;
  String _status = 'جاري تحديد الموقع...';

  @override
  void initState() {
    super.initState();
    _loadBearing();
  }

  Future<void> _loadBearing() async {
    double lat = 21.3891, lon = 39.8579;
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
    } catch (_) {}

    final bearing = PrayerTimesService.qiblaBearing(lat: lat, lon: lon);
    setState(() {
      _bearing = bearing;
      _status = usedFallback
          ? 'تعذّر تحديد الموقع — القيمة تقريبية'
          : 'الاتجاه محسوب من موقعك الحالي';
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('اتجاه القبلة', style: theme.textTheme.titleLarge),
            const SizedBox(height: 8),
            Text(_status,
                style: theme.textTheme.bodySmall, textAlign: TextAlign.center),
            const SizedBox(height: 32),
            if (_bearing == null)
              const CircularProgressIndicator()
            else
              Column(
                children: [
                  SizedBox(
                    width: 180,
                    height: 180,
                    child: Transform.rotate(
                      angle: _bearing! * pi / 180,
                      child: Icon(
                        Icons.navigation,
                        size: 140,
                        color: theme.colorScheme.primary,
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  Text(
                    '${_bearing!.round()}°',
                    style: theme.textTheme.headlineMedium
                        ?.copyWith(color: theme.colorScheme.primary),
                  ),
                  const SizedBox(height: 4),
                  Text('الزاوية من الشمال نحو الكعبة',
                      style: theme.textTheme.bodySmall),
                ],
              ),
            const SizedBox(height: 24),
            const Text(
              'ملحوظة: للحصول على بوصلة حية تتحرك مع الجهاز، أضف حزمة\n'
              'flutter_compass وادمج قراءتها مع هذه الزاوية.',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 12, color: Colors.grey),
            ),
          ],
        ),
      ),
    );
  }
}
