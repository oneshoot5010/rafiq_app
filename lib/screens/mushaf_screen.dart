import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class MushafScreen extends StatefulWidget {
  const MushafScreen({super.key});
  @override
  State<MushafScreen> createState() => _MushafScreenState();
}

class _MushafScreenState extends State<MushafScreen> {
  static const int _totalPages = 604;
  static const String _lastPageKey = 'mushaf_last_page';

  final Map<int, Future<List<dynamic>>> _cache = {};
  PageController? _controller;
  bool _ready = false;

  @override
  void initState() {
    super.initState();
    _restoreLastPage();
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

  Future<void> _restoreLastPage() async {
    final prefs = await SharedPreferences.getInstance();
    final saved = (prefs.getInt(_lastPageKey) ?? 1).clamp(1, _totalPages);
    if (!mounted) return;
    setState(() {
      _controller = PageController(initialPage: saved - 1);
      _ready = true;
    });
  }

  Future<void> _savePage(int page) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_lastPageKey, page);
  }

  Future<List<dynamic>> _fetchPage(int page) async {
    final res = await http
        .get(Uri.parse('https://api.alquran.cloud/v1/page/$page/quran-uthmani'))
        .timeout(const Duration(seconds: 20));
    if (res.statusCode != 200) throw Exception('فشل تحميل الصفحة $page');
    final body = jsonDecode(utf8.decode(res.bodyBytes));
    return body['data']['ayahs'] as List<dynamic>;
  }

  Future<List<dynamic>> _loadPage(int page) {
    final future = _cache[page] ??= _fetchPage(page);
    future.catchError((_) {
      _cache.remove(page);
      return <dynamic>[];
    });
    return future;
  }

  String _ar(int n) {
    const digits = ['٠', '١', '٢', '٣', '٤', '٥', '٦', '٧', '٨', '٩'];
    return n.toString().split('').map((c) => digits[int.parse(c)]).join();
  }

  Widget _buildPageText(List<dynamic> ayahs) {
    final primary = Theme.of(context).colorScheme.primary;
    final widgets = <Widget>[];
    final buf = StringBuffer();

    void flush() {
      if (buf.isEmpty) return;
      widgets.add(Text(
        buf.toString().trim(),
        textAlign: TextAlign.justify,
        textDirection: TextDirection.rtl,
        style: const TextStyle(fontSize: 22, height: 2.0),
      ));
      buf.clear();
    }

    for (final raw in ayahs) {
      final a = raw as Map;
      if (a['numberInSurah'] == 1) {
        flush();
        final surahName = (a['surah'] as Map?)?['name'] ?? '';
        widgets.add(Container(
          width: double.infinity,
          margin: const EdgeInsets.symmetric(vertical: 10),
          padding: const EdgeInsets.symmetric(vertical: 6),
          decoration: BoxDecoration(
            border: Border.symmetric(
              horizontal: BorderSide(color: primary),
            ),
          ),
          child: Text(
            surahName.toString(),
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 18, color: primary),
          ),
        ));
      }
      buf.write('${a['text']} ﴿${_ar(a['numberInSurah'] as int)}﴾ ');
    }
    flush();

    return ListView(
      padding: const EdgeInsets.all(16),
      children: widgets,
    );
  }

  @override
  Widget build(BuildContext context) {
    if (!_ready || _controller == null) {
      return const Center(child: CircularProgressIndicator());
    }
    return PageView.builder(
      controller: _controller,
      reverse: true,
      itemCount: _totalPages,
      onPageChanged: (i) => _savePage(i + 1),
      itemBuilder: (context, i) {
        final page = i + 1;
        return Column(
          children: [
            Expanded(
              child: FutureBuilder<List<dynamic>>(
                future: _loadPage(page),
                builder: (context, snap) {
                  if (snap.connectionState != ConnectionState.done) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  if (snap.hasError || snap.data == null || snap.data!.isEmpty) {
                    return Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Text('تعذّر تحميل الصفحة، تأكد من الإنترنت'),
                          const SizedBox(height: 12),
                          ElevatedButton(
                            onPressed: () => setState(() {}),
                            child: const Text('إعادة المحاولة'),
                          ),
                        ],
                      ),
                    );
                  }
                  return _buildPageText(snap.data!);
                },
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Text(
                'صفحة ${_ar(page)} من ${_ar(_totalPages)}',
                style: const TextStyle(fontSize: 13),
              ),
            ),
          ],
        );
      },
    );
  }
}
