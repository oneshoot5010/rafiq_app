import 'package:flutter/material.dart';
import 'package:audioplayers/audioplayers.dart';
import '../services/quran_service.dart';

class SurahDetailScreen extends StatefulWidget {
  final int surahNumber;
  final String surahName;
  const SurahDetailScreen({super.key, required this.surahNumber, required this.surahName});

  @override
  State<SurahDetailScreen> createState() => _SurahDetailScreenState();
}

class _SurahDetailScreenState extends State<SurahDetailScreen> {
  List<AyahData>? _ayahs;
  String? _error;
  final AudioPlayer _player = AudioPlayer();
  int? _playingIndex;

  @override
  void initState() {
    super.initState();
    _load();
    _player.onPlayerComplete.listen((_) {
      if (mounted) setState(() => _playingIndex = null);
    });
  }

  @override
  void dispose() {
    _player.dispose();
    super.dispose();
  }

  Future<void> _load() async {
    try {
      final list = await QuranService.getSurahWithAudio(widget.surahNumber);
      setState(() => _ayahs = list);
    } catch (_) {
      setState(() => _error = 'تعذّر تحميل السورة — تأكد من اتصال الإنترنت');
    }
  }

  Future<void> _toggleAudio(int index, String? url) async {
    if (url == null) return;
    if (_playingIndex == index) {
      await _player.stop();
      setState(() => _playingIndex = null);
    } else {
      await _player.stop();
      await _player.play(UrlSource(url));
      setState(() => _playingIndex = index);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(title: Text(widget.surahName)),
      body: _error != null
          ? Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.wifi_off, size: 48, color: Colors.grey),
                    const SizedBox(height: 12),
                    Text(_error!, textAlign: TextAlign.center),
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
            )
          : _ayahs == null
              ? const Center(child: CircularProgressIndicator())
              : ListView.builder(
                  padding: const EdgeInsets.all(12),
                  itemCount: _ayahs!.length,
                  itemBuilder: (context, i) {
                    final ayah = _ayahs![i];
                    final isPlaying = _playingIndex == i;
                    return Card(
                      margin: const EdgeInsets.symmetric(vertical: 4),
                      child: Padding(
                        padding: const EdgeInsets.all(12),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            Row(
                              children: [
                                CircleAvatar(
                                  radius: 14,
                                  backgroundColor: theme.colorScheme.primary.withOpacity(0.15),
                                  child: Text('${ayah.numberInSurah}',
                                      style: TextStyle(color: theme.colorScheme.primary, fontSize: 12)),
                                ),
                                const Spacer(),
                                IconButton(
                                  icon: Icon(isPlaying ? Icons.pause_circle_filled : Icons.play_circle_fill,
                                      color: theme.colorScheme.primary, size: 30),
                                  onPressed: () => _toggleAudio(i, ayah.audioUrl),
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            Text(
                              ayah.text,
                              textAlign: TextAlign.right,
                              style: theme.textTheme.headlineSmall?.copyWith(height: 1.8),
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
