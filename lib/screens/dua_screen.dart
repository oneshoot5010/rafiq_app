import 'package:flutter/material.dart';

class DuaCategory {
  final String title;
  final List<String> duas;
  const DuaCategory(this.title, this.duas);
}

class DuaScreen extends StatelessWidget {
  const DuaScreen({super.key});

  static const List<DuaCategory> _categories = [
    DuaCategory('أذكار الصباح', [
      'أَصْبَحْنَا وَأَصْبَحَ الْمُلْكُ لِلَّهِ، وَالْحَمْدُ لِلَّهِ، لَا إِلَهَ إِلَّا اللَّهُ وَحْدَهُ لَا شَرِيكَ لَهُ',
      'اللَّهُمَّ بِكَ أَصْبَحْنَا، وَبِكَ أَمْسَيْنَا، وَبِكَ نَحْيَا، وَبِكَ نَمُوتُ وَإِلَيْكَ النُّشُورُ',
    ]),
    DuaCategory('أذكار المساء', [
      'أَمْسَيْنَا وَأَمْسَى الْمُلْكُ لِلَّهِ، وَالْحَمْدُ لِلَّهِ، لَا إِلَهَ إِلَّا اللَّهُ وَحْدَهُ لَا شَرِيكَ لَهُ',
    ]),
    DuaCategory('أدعية بعد الصلاة', [
      'أَسْتَغْفِرُ اللَّهَ (ثلاثًا)، اللَّهُمَّ أَنْتَ السَّلَامُ وَمِنْكَ السَّلَامُ، تَبَارَكْتَ يَا ذَا الْجَلَالِ وَالْإِكْرَامِ',
    ]),
    DuaCategory('أدعية الطعام', [
      'بِسْمِ اللَّهِ (عند البدء)',
      'الْحَمْدُ لِلَّهِ الَّذِي أَطْعَمَنِي هَذَا، وَرَزَقَنِيهِ مِنْ غَيْرِ حَوْلٍ مِنِّي وَلَا قُوَّةٍ (بعد الانتهاء)',
    ]),
    DuaCategory('أدعية السفر', [
      'اللَّهُ أَكْبَرُ، سُبْحَانَ الَّذِي سَخَّرَ لَنَا هَذَا وَمَا كُنَّا لَهُ مُقْرِنِينَ وَإِنَّا إِلَى رَبِّنَا لَمُنْقَلِبُونَ',
    ]),
    DuaCategory('أدعية النوم', [
      'بِاسْمِكَ اللَّهُمَّ أَمُوتُ وَأَحْيَا',
      'اللَّهُمَّ قِنِي عَذَابَكَ يَوْمَ تَبْعَثُ عِبَادَكَ',
    ]),
  ];

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return ListView(
      padding: const EdgeInsets.all(12),
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: Text('مكتبة الأدعية', style: theme.textTheme.titleLarge, textAlign: TextAlign.center),
        ),
        for (final category in _categories)
          Card(
            margin: const EdgeInsets.symmetric(vertical: 6),
            child: ExpansionTile(
              title: Text(category.title, style: theme.textTheme.titleMedium),
              children: [
                for (final dua in category.duas)
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                    child: Text(
                      dua,
                      textAlign: TextAlign.right,
                      style: theme.textTheme.bodyLarge?.copyWith(height: 1.6),
                    ),
                  ),
              ],
            ),
          ),
      ],
    );
  }
}
