import 'package:flutter/material.dart';
import '../services/quran_service.dart';
import 'surah_detail_screen.dart';

class QuranScreen extends StatefulWidget {
  const QuranScreen({super.key});
  @override
  State<QuranScreen> createState() => _QuranScreenState();
}

class _QuranScreenState extends State<QuranScreen> {
  List<SurahInfo>? _surahs;
  String? _error;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    try {
      final list = await QuranService.getSurahList();
      setState(() => _surahs = list);
    } catch (_) {
      setState(() => _error = 'تعذّر تحميل قائمة السور — تأكد من اتصال الإنترنت');
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    if (_error != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.wifi_off, size: 48, color: Colors.grey),
              const SizedBox(height: 12),
              Text(_error!, textAlign: TextAlign.center, style: theme.textTheme.bodyMedium),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () {
                  setState(() => _error = null);
                  _load();
                },
                child: const Text('إعادة المحاولة'),
              ),
            ],
          ),
        ),
      );
    }
    if (_surahs == null) {
      return const Center(child: CircularProgressIndicator());
    }
    return ListView.builder(
      padding: const EdgeInsets.all(12),
      itemCount: _surahs!.length,
      itemBuilder: (context, i) {
        final s = _surahs![i];
        return Card(
          margin: const EdgeInsets.symmetric(vertical: 4),
          child: ListTile(
            leading: CircleAvatar(
              backgroundColor: theme.colorScheme.primary.withOpacity(0.15),
              child: Text('${s.number}', style: TextStyle(color: theme.colorScheme.primary)),
            ),
            title: Text(s.name, style: theme.textTheme.titleMedium),
            subtitle: Text('${s.englishNameTranslation} • ${s.numberOfAyahs} آية • ${s.revelationType == 'Meccan' ? 'مكية' : 'مدنية'}'),
            onTap: () {
              Navigator.push(context, MaterialPageRoute(
                builder: (_) => SurahDetailScreen(surahNumber: s.number, surahName: s.name),
              ));
            },
          ),
        );
      },
    );
  }
}
