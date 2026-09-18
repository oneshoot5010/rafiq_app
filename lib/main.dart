import 'package:flutter/material.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'screens/prayer_screen.dart';
import 'screens/qibla_screen.dart';
import 'screens/dhikr_screen.dart';
import 'screens/dua_screen.dart';
import 'screens/more_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initializeDateFormatting('ar');
  runApp(const RafiqApp());
}

class RafiqApp extends StatelessWidget {
  const RafiqApp({super.key});

  @override
  Widget build(BuildContext context) {
    const gold = Color(0xFFC9A24B);
    const bg = Color(0xFF121212);
    const surface = Color(0xFF1E1E1E);

    return MaterialApp(
      title: 'رفيق',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        brightness: Brightness.dark,
        scaffoldBackgroundColor: bg,
        colorScheme: const ColorScheme.dark(
          primary: gold,
          secondary: gold,
          surface: surface,
        ),
        useMaterial3: true,
        fontFamily: 'Tahoma',
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.black,
          foregroundColor: gold,
          centerTitle: true,
          elevation: 0,
        ),
        cardTheme: CardThemeData(
          color: surface,
          elevation: 0,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        ),
        navigationBarTheme: NavigationBarThemeData(
          backgroundColor: Colors.black,
          indicatorColor: gold.withOpacity(0.25),
          labelTextStyle: WidgetStateProperty.all(const TextStyle(color: gold, fontSize: 11)),
          iconTheme: WidgetStateProperty.all(const IconThemeData(color: gold)),
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(backgroundColor: gold, foregroundColor: Colors.black),
        ),
      ),
      builder: (context, child) {
        return Directionality(textDirection: TextDirection.rtl, child: child!);
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
    MoreScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [Text('🕌 '), Text('رفيق')],
        ),
      ),
      body: IndexedStack(index: _tabIndex, children: _screens),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _tabIndex,
        onDestinationSelected: (i) => setState(() => _tabIndex = i),
        destinations: const [
          NavigationDestination(icon: Icon(Icons.access_time), label: 'الصلاة'),
          NavigationDestination(icon: Icon(Icons.explore), label: 'القبلة'),
          NavigationDestination(icon: Icon(Icons.fingerprint), label: 'الأذكار'),
          NavigationDestination(icon: Icon(Icons.menu_book), label: 'الأدعية'),
          NavigationDestination(icon: Icon(Icons.grid_view), label: 'المزيد'),
        ],
      ),
    );
  }
}
