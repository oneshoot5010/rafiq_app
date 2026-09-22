import 'dart:convert';
import 'package:http/http.dart' as http;

class GeminiMessage {
  final String role; // 'user' or 'model'
  final String text;
  GeminiMessage({required this.role, required this.text});
}

class GeminiService {
  // TODO: بعد نشر السيرفر على Render، حط رابطه هنا (بدون / في الآخر)
  static const String _serverUrl = 'https://rafiq-ai-server.vercel.app';

  /// يرسل المحادثة كاملة للسيرفر الوسيط ويرجع رد المساعد.
  /// يرمي [GeminiException] برسالة عربية واضحة عند أي خطأ.
  static Future<String> ask(List<GeminiMessage> history) async {
    final uri = Uri.parse('$_serverUrl/api/ask');

    final body = jsonEncode({
      'history': history
          .map((m) => {'role': m.role, 'text': m.text})
          .toList(),
    });

    http.Response res;
    try {
      res = await http
          .post(uri, headers: {'Content-Type': 'application/json'}, body: body)
          .timeout(const Duration(seconds: 40));
    } catch (e) {
      throw GeminiException('تعذر الاتصال بالخادم، تأكد من اتصالك بالإنترنت');
    }

    if (res.statusCode == 502 || res.statusCode == 500) {
      throw GeminiException('الخدمة غير متاحة حالياً، حاول بعد قليل');
    }
    if (res.statusCode != 200) {
      throw GeminiException('حدث خطأ غير متوقع (${res.statusCode})');
    }

    try {
      final data = jsonDecode(utf8.decode(res.bodyBytes));
      if (data['blocked'] == true || data['reply'] == null) {
        return 'لم يتمكن المساعد من الإجابة على هذا السؤال، حاول بصياغة أخرى';
      }
      return (data['reply'] as String).trim();
    } catch (e) {
      throw GeminiException('تعذر قراءة رد المساعد');
    }
  }
}

class GeminiException implements Exception {
  final String message;
  GeminiException(this.message);
  @override
  String toString() => message;
}
