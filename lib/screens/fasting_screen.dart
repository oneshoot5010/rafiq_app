import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class FastingScreen extends StatefulWidget {
  const FastingScreen({super.key});
  @override
  State<FastingScreen> createState() => _FastingScreenState();
}

class _FastingScreenState extends State<FastingScreen> {
  Set<String> _fastedDates = {};

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _fastedDates = (prefs.getStringList('fasted_dates') ?? []).toSet();
    });
  }

  Future<void> _save() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList('fasted_dates', _fastedDates.toList());
  }

  String _key(DateTime d) => '${d.year}-${d.month}-${d.day}';

  void _toggleToday() {
    final key = _key(DateTime.now());
    setState(() {
      if (_fastedDates.contains(key)) {
        _fastedDates.remove(key);
      } else {
        _fastedDates.add(key);
      }
    });
    _save();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final today = DateTime.now();
    final isFastedToday = _fastedDates.contains(_key(today));
    final weekday = today.weekday;
    final isSunnahDay = weekday == 1 || weekday == 4;
    final isWhiteDay = today.day == 13 || today.day == 14 || today.day == 15;

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Text('تتبع صيام النوافل', style: theme.textTheme.titleLarge, textAlign: TextAlign.center),
        const SizedBox(height: 24),
        Card(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
                Icon(
                  isFastedToday ? Icons.check_circle : Icons.circle_outlined,
                  size: 48,
                  color: isFastedToday ? theme.colorScheme.primary : Colors.grey,
                ),
                const SizedBox(height: 12),
                Text(isFastedToday ? 'صائم اليوم' : 'لم تسجل صيام اليوم', style: theme.textTheme.titleMedium),
                if (isSunnahDay)
                  Padding(
                    padding: const EdgeInsets.only(top: 8),
                    child: Text('اليوم من أيام السنة (الإثنين/الخميس)',
                        style: theme.textTheme.bodySmall?.copyWith(color: theme.colorScheme.secondary)),
                  ),
                if (isWhiteDay)
                  Padding(
                    padding: const EdgeInsets.only(top: 4),
                    child: Text('اليوم من الأيام البيض',
                        style: theme.textTheme.bodySmall?.copyWith(color: theme.colorScheme.secondary)),
                  ),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: _toggleToday,
                  child: Text(isFastedToday ? 'إلغاء تسجيل اليوم' : 'سجّل صيام اليوم'),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 20),
        Text('إجمالي أيام الصيام المسجلة: ${_fastedDates.length}', style: theme.textTheme.bodyMedium, textAlign: TextAlign.center),
      ],
    );
  }
}
