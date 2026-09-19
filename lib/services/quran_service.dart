import 'dart:convert';
import 'package:http/http.dart' as http;

class SurahInfo {
  final int number;
  final String name;
  final String englishName;
  final String englishNameTranslation;
  final int numberOfAyahs;
  final String revelationType;

  SurahInfo({
    required this.number,
    required this.name,
    required this.englishName,
    required this.englishNameTranslation,
    required this.numberOfAyahs,
    required this.revelationType,
  });

  factory SurahInfo.fromJson(Map<String, dynamic> json) {
    return SurahInfo(
      number: json['number'],
      name: json['name'],
      englishName: json['englishName'],
      englishNameTranslation: json['englishNameTranslation'],
      numberOfAyahs: json['numberOfAyahs'],
      revelationType: json['revelationType'],
    );
  }
}

class AyahData {
  final int numberInSurah;
  final String text;
  final String? audioUrl;

  AyahData({required this.numberInSurah, required this.text, this.audioUrl});
}

class QuranService {
  static const _base = 'https://api.alquran.cloud/v1'\;

  static Future<List<SurahInfo>> getSurahList() async {
    final res = await http.get(Uri.parse('$_base/surah'));
    if (res.statusCode != 200) throw Exception('فشل تحميل قائمة السور');
    final body = json.decode(utf8.decode(res.bodyBytes));
    final List list = body['data'];
    return list.map((e) => SurahInfo.fromJson(e)).toList();
  }

  static Future<List<AyahData>> getSurahText(int number) async {
    final res = await http.get(Uri.parse('$_base/surah/$number/quran-uthmani'));
    if (res.statusCode != 200) throw Exception('فشل تحميل نص السورة');
    final body = json.decode(utf8.decode(res.bodyBytes));
    final List ayahs = body['data']['ayahs'];
    return ayahs
        .map((e) => AyahData(numberInSurah: e['numberInSurah'], text: e['text']))
        .toList();
  }

  static Future<List<AyahData>> getSurahWithAudio(int number) async {
    final res = await http.get(Uri.parse('$_base/surah/$number/ar.alafasy'));
    if (res.statusCode != 200) throw Exception('فشل تحميل الصوت');
    final body = json.decode(utf8.decode(res.bodyBytes));
    final List ayahs = body['data']['ayahs'];
    return ayahs
        .map((e) => AyahData(
              numberInSurah: e['numberInSurah'],
              text: e['text'],
              audioUrl: e['audio'],
            ))
        .toList();
  }
}
