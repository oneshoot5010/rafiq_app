import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class DhikrScreen extends StatefulWidget {
  const DhikrScreen({super.key});

  @override
  State<DhikrScreen> createState() => _DhikrScreenState();
}

class _DhikrScreenState extends State<DhikrScreen> {
  static const List<String> _dhikrList = [
    'سبحان الله',
    'الحمد لله',
    'الله أكبر',
    'لا إله إلا الله',
    'أستغفر الله',
  ];

  int _count = 0;
  int _index = 0;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _count = prefs.getInt('dhikr_count') ?? 0;
      _index = prefs.getInt('dhikr_index') ?? 0;
    });
  }

  Future<void> _save() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('dhikr_count', _count);
    await prefs.setInt('dhikr_index', _index);
  }

  void _tap() {
    setState(() {
      _count++;
      if (_count % 33 == 0) {
        _index = (_index + 1) % _dhikrList.length;
      }
    });
    _save();
  }

  void _reset() {
    setState(() {
      _count = 0;
      _index = 0;
    });
    _save();
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
            Text('عداد التسبيح', style: theme.textTheme.titleLarge),
            const SizedBox(height: 24),
            Text(
              '$_count',
              style: theme.textTheme.displayLarge
                  ?.copyWith(color: theme.colorScheme.primary, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(_dhikrList[_index], style: theme.textTheme.titleMedium),
            const SizedBox(height: 32),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ElevatedButton(
                  onPressed: _tap,
                  style: ElevatedButton.styleFrom(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                  ),
                  child: const Text('تسبيح +1'),
                ),
                const SizedBox(width: 12),
                OutlinedButton(
                  onPressed: _reset,
                  child: const Icon(Icons.refresh),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
