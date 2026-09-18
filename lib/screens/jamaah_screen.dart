import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class JamaahScreen extends StatefulWidget {
  const JamaahScreen({super.key});
  @override
  State<JamaahScreen> createState() => _JamaahScreenState();
}

class _JamaahScreenState extends State<JamaahScreen> {
  static const _prayers = ['الفجر', 'الظهر', 'العصر', 'المغرب', 'العشاء'];
  Map<String, bool> _today = {};

  @override
  void initState() {
    super.initState();
    _load();
  }

  String get _dateKey {
    final n = DateTime.now();
    return '${n.year}-${n.month}-${n.day}';
  }

  Future<void> _load() async {
    final prefs = await SharedPreferences.getInstance();
    final map = <String, bool>{};
    for (final p in _prayers) {
      map[p] = prefs.getBool('jamaah_${_dateKey}_$p') ?? false;
    }
    setState(() => _today = map);
  }

  Future<void> _toggle(String prayer) async {
    final prefs = await SharedPreferences.getInstance();
    final newVal = !(_today[prayer] ?? false);
    setState(() => _today[prayer] = newVal);
    await prefs.setBool('jamaah_${_dateKey}_$prayer', newVal);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final count = _today.values.where((v) => v).length;
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Text('تتبع صلاة الجماعة اليوم', style: theme.textTheme.titleLarge, textAlign: TextAlign.center),
        const SizedBox(height: 8),
        Text('$count من ${_prayers.length} صلوات في جماعة', style: theme.textTheme.bodyMedium, textAlign: TextAlign.center),
        const SizedBox(height: 20),
        for (final prayer in _prayers)
          Card(
            margin: const EdgeInsets.symmetric(vertical: 4),
            child: CheckboxListTile(
              title: Text(prayer, style: theme.textTheme.titleMedium),
              value: _today[prayer] ?? false,
              onChanged: (_) => _toggle(prayer),
              controlAffinity: ListTileControlAffinity.leading,
            ),
          ),
      ],
    );
  }
}
