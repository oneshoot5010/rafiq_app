import 'package:flutter/material.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'screens/prayer_screen.dart';
import 'screens/qibla_screen.dart';
import 'screens/dhikr_screen.dart';
import 'screens/hijri_screen.dart';
import 'screens/dua_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initializeDateFormatting('ar');
  runApp(const RafiqApp());
}

class RafiqApp extends StatelessWidget {
  const RafiqApp({super.key});

  @override
  Widget build(BuildContext context) {
    const seed = Color(0xFF0B5D45);
    const gold = Color(0xFFC9A24B);
    return MaterialApp(
      title: 'رفيق',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: seed).copyWith(secondary: gold),
        useMaterial3: true,
        fontFamily: 'Tahoma',
        appBarTheme: const AppBarTheme(centerTitle: true, elevation: 0),
        cardTheme: CardThemeData(
          elevation: 0,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        ),
      ),
      builder: (context, child) {
        return Directionality(
          textDirection: TextDirection.rtl,
          child: child!,
        );
      },
      home: const HomeShell(),
    );
  }
}

class HomeShell extends StatefulWidget {
  const HomeShell({super.key});

  @override
  State<HomeShell> createState() => _HomeShellState();
}

class _HomeShellState extends State<HomeShell> {
  int _tabIndex = 0;

  static const _screens = [
    PrayerScreen(),
    QiblaScreen(),
    DhikrScreen(),
    DuaScreen(),
    HijriScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('🕌 '),
            Text('رفيق'),
          ],
        ),
        centerTitle: true,
      ),
      body: IndexedStack(
        index: _tabIndex,
        children: _screens,
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _tabIndex,
        onDestinationSelected: (i) => setState(() => _tabIndex = i),
        destinations: const [
          NavigationDestination(icon: Icon(Icons.access_time), label: 'الصلاة'),
          NavigationDestination(icon: Icon(Icons.explore), label: 'القبلة'),
          NavigationDestination(icon: Icon(Icons.fingerprint), label: 'الأذكار'),
          NavigationDestination(icon: Icon(Icons.menu_book), label: 'الأدعية'),
          NavigationDestination(icon: Icon(Icons.calendar_month), label: 'التقويم'),
        ],
      ),
    );
  }
}
