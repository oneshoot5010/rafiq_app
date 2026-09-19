import 'package:flutter/material.dart';
import 'quran_screen.dart';
import 'hijri_screen.dart';
import 'zakat_screen.dart';
import 'fasting_screen.dart';
import 'jamaah_screen.dart';
import 'khushoo_screen.dart';
import 'stories_screen.dart';
import 'memorization_screen.dart';
import 'about_developer_screen.dart';
import 'tafsir_screen.dart';
import 'settings_screen.dart';

class MoreItem {
  final String title;
  final IconData icon;
  final Widget screen;
  const MoreItem(this.title, this.icon, this.screen);
}

class MoreScreen extends StatelessWidget {
  const MoreScreen({super.key});

  static const List<MoreItem> _items = [
    MoreItem('القرآن الكريم', Icons.menu_book_outlined, QuranScreen()),
    MoreItem('التقويم الهجري', Icons.calendar_month, HijriScreen()),
    MoreItem('حاسبة الزكاة', Icons.calculate, ZakatScreen()),
    MoreItem('تتبع الصيام', Icons.nights_stay, FastingScreen()),
    MoreItem('صلاة الجماعة', Icons.groups, JamaahScreen()),
    MoreItem('وضع الخشوع', Icons.self_improvement, KhushooScreen()),
    MoreItem('قصص الأنبياء', Icons.auto_stories, StoriesScreen()),
    MoreItem('تتبع الحفظ', Icons.menu_book, MemorizationScreen()),
    MoreItem('عن المطوّر', Icons.info_outline, AboutDeveloperScreen()),
    MoreItem('التفسير', Icons.book_outlined, TafsirScreen()),
    MoreItem('الإعدادات', Icons.settings_outlined, SettingsScreen()),
  ];

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return GridView.builder(
      padding: const EdgeInsets.all(16),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        mainAxisSpacing: 12,
        crossAxisSpacing: 12,
        childAspectRatio: 1.1,
      ),
      itemCount: _items.length,
      itemBuilder: (context, i) {
        final item = _items[i];
        return Card(
          child: InkWell(
            borderRadius: BorderRadius.circular(14),
            onTap: () {
              Navigator.push(context, MaterialPageRoute(
                builder: (_) => Scaffold(
                  appBar: AppBar(title: Text(item.title)),
                  body: item.screen,
                ),
              ));
            },
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(item.icon, size: 40, color: theme.colorScheme.primary),
                const SizedBox(height: 10),
                Text(item.title, textAlign: TextAlign.center, style: theme.textTheme.titleSmall),
              ],
            ),
          ),
        );
      },
    );
  }
}
