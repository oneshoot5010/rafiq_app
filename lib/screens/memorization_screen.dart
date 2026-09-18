import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class MemorizationScreen extends StatefulWidget {
  const MemorizationScreen({super.key});
  @override
  State<MemorizationScreen> createState() => _MemorizationScreenState();
}

class _MemorizationScreenState extends State<MemorizationScreen> {
  static const List<String> _juzList = [
    'الجزء الأول', 'الجزء الثاني', 'الجزء الثالث', 'الجزء الرابع', 'الجزء الخامس',
    'الجزء السادس', 'الجزء السابع', 'الجزء الثامن', 'الجزء التاسع', 'الجزء العاشر',
    'الجزء الحادي عشر', 'الجزء الثاني عشر', 'الجزء الثالث عشر', 'الجزء الرابع عشر',
    'الجزء الخامس عشر', 'الجزء السادس عشر', 'الجزء السابع عشر', 'الجزء الثامن عشر',
    'الجزء التاسع عشر', 'الجزء العشرون', 'الجزء الحادي والعشرون', 'الجزء الثاني والعشرون',
    'الجزء الثالث والعشرون', 'الجزء الرابع والعشرون', 'الجزء الخامس والعشرون',
    'الجزء السادس والعشرون', 'الجزء السابع والعشرون', 'الجزء الثامن والعشرون',
    'الجزء التاسع والعشرون', 'الجزء الثلاثون',
  ];

  Set<int> _memorized = {};

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _memorized = (prefs.getStringList('memorized_juz') ?? []).map(int.parse).toSet();
    });
  }

  Future<void> _toggle(int index) async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      if (_memorized.contains(index)) {
        _memorized.remove(index);
      } else {
        _memorized.add(index);
      }
    });
    await prefs.setStringList('memorized_juz', _memorized.map((e) => e.toString()).toList());
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final progress = _memorized.length / _juzList.length;
    return Column(
      children: [
        const SizedBox(height: 16),
        Text('تتبع حفظ القرآن', style: theme.textTheme.titleLarge),
        const SizedBox(height: 12),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: LinearProgressIndicator(value: progress, minHeight: 10, borderRadius: BorderRadius.circular(6)),
        ),
        const SizedBox(height: 8),
        Text('${_memorized.length} من ${_juzList.length} جزء (${(progress * 100).toStringAsFixed(0)}%)',
            style: theme.textTheme.bodyMedium),
        const SizedBox(height: 12),
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            itemCount: _juzList.length,
            itemBuilder: (context, i) {
              final done = _memorized.contains(i);
              return Card(
                margin: const EdgeInsets.symmetric(vertical: 3),
                child: CheckboxListTile(
                  title: Text(_juzList[i]),
                  value: done,
                  onChanged: (_) => _toggle(i),
                  controlAffinity: ListTileControlAffinity.leading,
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}
