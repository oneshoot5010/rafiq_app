import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class GeminiMessage {
  final String role; // 'user' or 'model'
  final String text;
  GeminiMessage({required this.role, required this.text});
}

class GeminiService {
  static const String _apiKeyPrefsKey = 'gemini_api_key';
  static const String _model = 'gemini-2.0-flash';

  static const String _systemInstruction =
      'أنت مساعد ديني إسلامي داخل تطبيق "رفيق". مهمتك الإجابة على الأسئلة '
      'الدينية بأسلوب مبسط وواضح باللهجة العربية الفصحى السهلة، معتمداً على '
      'القرآن الكريم والسنة النبوية الصحيحة وأقوال العلماء المعتبرين من أهل '
      'السنة والجماعة. التزم بالقواعد التالية بدقة:\n'
      '1. إذا كان السؤال فقهياً خلافياً بين المذاهب، اذكر الآراء المختلفة '
      'باختصار دون ترجيح متعصب، ونبّه أن الأفضل سؤال عالم موثوق للفتوى '
      'الشخصية.\n'
      '2. لا تُصدر فتوى قاطعة في مسائل حساسة أو معقدة (كالطلاق، الميراث '
      'المعقد، القضايا الطبية الحرجة)، بل وجّه السائل لسؤال دار إفتاء أو '
      'عالم مختص.\n'
      '3. إذا لم تكن متأكداً من صحة حديث أو معلومة، صرّح بذلك ولا تختلق '
      'مصدراً.\n'
      '4. حافظ على أسلوب لطيف متواضع، وابدأ الإجابات المهمة بالدليل من '
      'القرآن أو السنة عند الإمكان.\n'
      '5. لا تخض في الخلافات المذهبية الحادة أو السياسية أو الطائفية، '
      'وركّز على ما يجمع المسلمين.\n'
      '6. اجعل إجاباتك مختصرة ومركزة (فقرة إلى فقرتين) ما لم يطلب السائل '
      'تفصيلاً أكبر.';

  static Future<String?> getApiKey() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_apiKeyPrefsKey);
  }

  static Future<void> setApiKey(String key) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_apiKeyPrefsKey, key.trim());
  }

  static Future<void> clearApiKey() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_apiKeyPrefsKey);
  }

  /// Sends the conversation history and returns the model's reply.
  /// Throws a [GeminiException] with a user-friendly Arabic message on failure.
  static Future<String> ask(List<GeminiMessage> history) async {
    final apiKey = await getApiKey();
    if (apiKey == null || apiKey.isEmpty) {
      throw GeminiException(
          'لم يتم إضافة مفتاح API بعد. من فضلك أضفه من شاشة الإعدادات.');
    }

    final uri = Uri.parse(
        'https://generativelanguage.googleapis.com/v1beta/models/$_model:generateContent?key=$apiKey');

    final contents = history
        .map((m) => {
              'role': m.role,
              'parts': [
                {'text': m.text}
              ],
            })
        .toList();

    final body = jsonEncode({
      'system_instruction': {
        'parts': [
          {'text': _systemInstruction}
        ],
      },
      'contents': contents,
      'generationConfig': {
        'temperature': 0.4,
        'maxOutputTokens': 800,
      },
      'safetySettings': [
        {
          'category': 'HARM_CATEGORY_HARASSMENT',
          'threshold': 'BLOCK_MEDIUM_AND_ABOVE'
        },
        {
          'category': 'HARM_CATEGORY_HATE_SPEECH',
          'threshold': 'BLOCK_MEDIUM_AND_ABOVE'
        },
      ],
    });

    http.Response res;
    try {
      res = await http
          .post(uri,
              headers: {'Content-Type': 'application/json'}, body: body)
          .timeout(const Duration(seconds: 30));
    } catch (e) {
      throw GeminiException('تعذر الاتصال بالخادم، تأكد من اتصالك بالإنترنت');
    }

    if (res.statusCode == 400) {
      throw GeminiException(
          'مفتاح API غير صالح. تأكد منه في شاشة الإعدادات');
    }
    if (res.statusCode == 429) {
      throw GeminiException('تم تجاوز الحد المسموح من الطلبات، حاول لاحقاً');
    }
    if (res.statusCode != 200) {
      throw GeminiException('حدث خطأ غير متوقع (${res.statusCode})');
    }

    try {
      final data = jsonDecode(utf8.decode(res.bodyBytes));
      final candidates = data['candidates'] as List?;
      if (candidates == null || candidates.isEmpty) {
        throw GeminiException(
            'لم يتمكن المساعد من الإجابة على هذا السؤال، حاول بصياغة أخرى');
      }
      final parts = candidates[0]['content']?['parts'] as List?;
      if (parts == null || parts.isEmpty) {
        throw GeminiException('لم يصل رد من المساعد، حاول مرة أخرى');
      }
      return parts.map((p) => p['text'] ?? '').join().trim();
    } catch (e) {
      if (e is GeminiException) rethrow;
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
