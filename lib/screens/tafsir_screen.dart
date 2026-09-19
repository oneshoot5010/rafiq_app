import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class TafsirScreen extends StatefulWidget {
  const TafsirScreen({super.key});
  @override
  State<TafsirScreen> createState() => _TafsirScreenState();
}

class _TafsirScreenState extends State<TafsirScreen> {
  List<dynamic> _surahs = [];
  bool _loading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadSurahs();
  }

  Future<void> _loadSurahs() async {
    try {
      final res = await http
          .get(Uri.parse('https://api.alquran.cloud/v1/surah'))
          .timeout(const Duration(seconds: 15));
      final data = jsonDecode(res.body);
      setState(() {
        _surahs = data['data'];
        _loading = false;
      });
    } catch (e) {
      setState(() {
        _error = 'تعذر تحميل قائمة السور، تأكد من الاتصال بالإنترنت';
        _loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Center(child: CircularProgressIndicator());
    }
    if (_error != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(_error!, textAlign: TextAlign.center),
              const SizedBox(height: 12),
              ElevatedButton(
                onPressed: () {
                  setState(() => _loading = true);
                  _loadSurahs();
                },
                child: const Text('إعادة المحاولة'),
              ),
            ],
          ),
        ),
      );
    }
    return ListView.separated(
      itemCount: _surahs.length,
      separatorBuilder: (_, __) => const Divider(height: 1),
      itemBuilder: (context, i) {
        final s = _surahs[i];
        return ListTile(
          leading: CircleAvatar(child: Text('${s['number']}')),
          title: Text(s['name'], style: const TextStyle(fontSize: 18)),
          subtitle: Text('${s['englishName']} • ${s['numberOfAyahs']} آية'),
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => TafsirAyahScreen(
                  surahNumber: s['number'],
                  surahName: s['name'],
                ),
              ),
            );
          },
        );
      },
    );
  }
}

class TafsirAyahScreen extends StatefulWidget {
  final int surahNumber;
  final String surahName;
  const TafsirAyahScreen(
      {super.key, required this.surahNumber, required this.surahName});

  @override
  State<TafsirAyahScreen> createState() => _TafsirAyahScreenState();
}

class _TafsirAyahScreenState extends State<TafsirAyahScreen> {
  List<dynamic>? _ayahs;
  List<dynamic>? _tafsir;
  bool _loading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    try {
      final quranRes = await http
          .get(Uri.parse(
              'https://api.alquran.cloud/v1/surah/${widget.surahNumber}/quran-uthmani'))
          .timeout(const Duration(seconds: 15));
      final tafsirRes = await http
          .get(Uri.parse(
              'https://api.alquran.cloud/v1/surah/${widget.surahNumber}/ar.muyassar'))
          .timeout(const Duration(seconds: 15));
      final quranData = jsonDecode(quranRes.body);
      final tafsirData = jsonDecode(tafsirRes.body);
      setState(() {
        _ayahs = quranData['data']['ayahs'];
        _tafsir = tafsirData['data']['ayahs'];
        _loading = false;
      });
    } catch (e) {
      setState(() {
        _error = 'تعذر تحميل التفسير، تأكد من الاتصال بالإنترنت';
        _loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('تفسير ${widget.surahName}')),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
              ? Center(
                  child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(_error!, textAlign: TextAlign.center),
                        const SizedBox(height: 12),
                        ElevatedButton(
                          onPressed: () {
                            setState(() => _loading = true);
                            _load();
                          },
                          child: const Text('إعادة المحاولة'),
                        ),
                      ],
                    ),
                  ),
                )
              : ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: _ayahs!.length,
                  itemBuilder: (context, i) {
                    final ayah = _ayahs![i];
                    final tafsir = _tafsir![i];
                    return Card(
                      margin: const EdgeInsets.only(bottom: 12),
                      child: Padding(
                        padding: const EdgeInsets.all(14),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              '${ayah['text']} ﴿${ayah['numberInSurah']}﴾',
                              style: const TextStyle(
                                  fontSize: 20, height: 1.8),
                            ),
                            const Divider(height: 20),
                            Text(
                              tafsir['text'],
                              style: TextStyle(
                                  fontSize: 15,
                                  color: Theme.of(context)
                                      .colorScheme
                                      .primary),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
    );
  }
}
