import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class DhikrItem {
  final String key;
  final String text;
  final int target;
  const DhikrItem(this.key, this.text, this.target);
}

class DhikrScreen extends StatefulWidget {
  const DhikrScreen({super.key});
  @override
  State<DhikrScreen> createState() => _DhikrScreenState();
}

class _DhikrScreenState extends State<DhikrScreen> {
  static const List<DhikrItem> _dhikrList = [
    DhikrItem('subhanallah', 'سبحان الله', 33),
    DhikrItem('alhamdulillah', 'الحمد لله', 33),
    DhikrItem('allahuakbar', 'الله أكبر', 34),
    DhikrItem('lailaha', 'لا إله إلا الله', 100),
    DhikrItem('astaghfirullah', 'أستغفر الله العظيم', 100),
  ];

  int _selected = 0;
  Map<String, int> _counts = {};

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final prefs = await SharedPreferences.getInstance();
    final loaded = <String, int>{};
    for (final d in _dhikrList) {
      loaded[d.key] = prefs.getInt('dhikr_${d.key}') ?? 0;
    }
    setState(() {
      _counts = loaded;
      _selected = prefs.getInt('dhikr_selected') ?? 0;
    });
  }

  Future<void> _save() async {
    final prefs = await SharedPreferences.getInstance();
    for (final d in _dhikrList) {
      await prefs.setInt('dhikr_${d.key}', _counts[d.key] ?? 0);
    }
    await prefs.setInt('dhikr_selected', _selected);
  }

  void _tap() {
    final key = _dhikrList[_selected].key;
    setState(() => _counts[key] = (_counts[key] ?? 0) + 1);
    _save();
  }

  void _reset() {
    final key = _dhikrList[_selected].key;
    setState(() => _counts[key] = 0);
    _save();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final current = _dhikrList[_selected];
    final count = _counts[current.key] ?? 0;
    return Column(
      children: [
        const SizedBox(height: 12),
        Text('عداد الأذكار', style: theme.textTheme.titleLarge),
        const SizedBox(height: 8),
        SizedBox(
          height: 48,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 12),
            itemCount: _dhikrList.length,
            separatorBuilder: (_, __) => const SizedBox(width: 8),
            itemBuilder: (context, i) {
              return ChoiceChip(
                label: Text(_dhikrList[i].text),
                selected: i == _selected,
                onSelected: (_) => setState(() => _selected = i),
              );
            },
          ),
        ),
        Expanded(
          child: Center(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    '$count',
                    style: theme.textTheme.displayLarge?.copyWith(
                      color: theme.colorScheme.primary,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(current.text, style: theme.textTheme.titleMedium, textAlign: TextAlign.center),
                  Padding(
                    padding: const EdgeInsets.only(top: 4),
                    child: Text('المستهدف: ${current.target} مرة',
                        style: theme.textTheme.bodySmall?.copyWith(color: Colors.grey)),
                  ),
                  const SizedBox(height: 32),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      ElevatedButton(
                        onPressed: _tap,
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                        ),
                        child: const Text('تسبيح +1'),
                      ),
                      const SizedBox(width: 12),
                      OutlinedButton(onPressed: _reset, child: const Icon(Icons.refresh)),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}
