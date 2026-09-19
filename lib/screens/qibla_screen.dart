import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_compass/flutter_compass.dart';
import 'package:geolocator/geolocator.dart';
import '../services/prayer_times_service.dart';

class QiblaScreen extends StatefulWidget {
  const QiblaScreen({super.key});

  @override
  State<QiblaScreen> createState() => _QiblaScreenState();
}

class _QiblaScreenState extends State<QiblaScreen> {
  double? _qiblaBearing; // زاوية القبلة من الشمال الجغرافي (ثابتة بناء على الموقع)
  double? _heading; // اتجاه الموبايل الحالي من البوصلة (بيتحدث لحظيًا)
  String _status = 'جاري تحديد الموقع...';
  bool _hasCompass = true;
  StreamSubscription<CompassEvent>? _compassSub;

  @override
  void initState() {
    super.initState();
    _loadQiblaBearing();
    _listenToCompass();
  }

  @override
  void dispose() {
    _compassSub?.cancel();
    super.dispose();
  }

  void _listenToCompass() {
    if (FlutterCompass.events == null) {
      setState(() => _hasCompass = false);
      return;
    }
    _compassSub = FlutterCompass.events!.listen((event) {
      if (event.heading == null) {
        setState(() => _hasCompass = false);
        return;
      }
      setState(() {
        _heading = event.heading;
      });
    });
  }

  Future<void> _loadQiblaBearing() async {
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
      _qiblaBearing = bearing;
      _status = usedFallback
          ? 'تعذّر تحديد الموقع – القيمة تقريبية'
          : 'الاتجاه محسوب من موقعك الحالي';
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    // زاوية دوران السهم = زاوية القبلة - اتجاه الموبايل الحالي
    // لو مفيش بوصلة أو لسه بتقرأ، بنستخدم زاوية القبلة الثابتة بس
    double? rotationAngle;
    if (_qiblaBearing != null) {
      if (_hasCompass && _heading != null) {
        rotationAngle = _qiblaBearing! - _heading!;
      } else {
        rotationAngle = _qiblaBearing;
      }
    }

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
            if (rotationAngle == null)
              const CircularProgressIndicator()
            else
              Column(
                children: [
                  SizedBox(
                    width: 180,
                    height: 180,
                    child: TweenAnimationBuilder<double>(
                      tween: Tween<double>(
                        begin: rotationAngle,
                        end: rotationAngle,
                      ),
                      duration: const Duration(milliseconds: 200),
                      builder: (context, angle, child) => Transform.rotate(
                        angle: angle * pi / 180,
                        child: child,
                      ),
                      child: Icon(
                        Icons.navigation,
                        size: 140,
                        color: theme.colorScheme.primary,
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  Text(
                    '${_qiblaBearing!.round()}°',
                    style: theme.textTheme.headlineMedium
                        ?.copyWith(color: theme.colorScheme.primary),
                  ),
                  const SizedBox(height: 4),
                  Text('زاوية القبلة من الشمال الجغرافي',
                      style: theme.textTheme.bodySmall),
                ],
              ),
            const SizedBox(height: 24),
            if (!_hasCompass)
              const Text(
                'ملحوظة: جهازك مفيهوش حساس بوصلة (مغناطيسي)، فالسهم هيوريك زاوية القبلة الثابتة بس من غير حركة لحظية.',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 12, color: Colors.grey),
              )
            else
              const Text(
                'حرّك موبايلك بشكل ثمانية أفقيًا لمعايرة البوصلة لو السهم مش دقيق',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 12, color: Colors.grey),
              ),
          ],
        ),
      ),
    );
  }
}
