import 'package:flutter/material.dart';
import '../services/gemini_service.dart';

class AiQaScreen extends StatefulWidget {
  const AiQaScreen({super.key});
  @override
  State<AiQaScreen> createState() => _AiQaScreenState();
}

class _AiQaScreenState extends State<AiQaScreen> {
  final List<GeminiMessage> _messages = [];
  final TextEditingController _controller = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  bool _sending = false;
  bool _checkingKey = true;
  bool _hasKey = false;

  static const List<String> _suggestions = [
    'ما هي شروط صحة الصلاة؟',
    'ما حكم الجمع بين الصلاتين؟',
    'كيف أتوب توبة نصوحة؟',
    'ما فضل قراءة سورة الكهف يوم الجمعة؟',
  ];

  @override
  void initState() {
    super.initState();
    _checkKey();
  }

  Future<void> _checkKey() async {
    final key = await GeminiService.getApiKey();
    setState(() {
      _hasKey = key != null && key.isNotEmpty;
      _checkingKey = false;
    });
  }

  Future<void> _send([String? presetText]) async {
    final text = presetText ?? _controller.text.trim();
    if (text.isEmpty || _sending) return;

    setState(() {
      _messages.add(GeminiMessage(role: 'user', text: text));
      _sending = true;
      _controller.clear();
    });
    _scrollToBottom();

    try {
      final reply = await GeminiService.ask(_messages);
      setState(() {
        _messages.add(GeminiMessage(role: 'model', text: reply));
      });
    } on GeminiException catch (e) {
      setState(() {
        _messages.add(GeminiMessage(role: 'model', text: '⚠️ ${e.message}'));
      });
    } catch (e) {
      setState(() {
        _messages.add(
            GeminiMessage(role: 'model', text: '⚠️ حدث خطأ غير متوقع'));
      });
    } finally {
      setState(() => _sending = false);
      _scrollToBottom();
    }
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_checkingKey) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    if (!_hasKey) {
      return Scaffold(
        appBar: AppBar(title: const Text('مساعد الأسئلة الدينية')),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.vpn_key_outlined,
                    size: 56,
                    color: Theme.of(context).colorScheme.primary),
                const SizedBox(height: 16),
                const Text(
                  'لاستخدام المساعد الذكي، يجب إضافة مفتاح API أولاً من شاشة الإعدادات',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 16),
                ),
                const SizedBox(height: 20),
                ElevatedButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('الذهاب للإعدادات'),
                ),
              ],
            ),
          ),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(title: const Text('مساعد الأسئلة الدينية')),
      body: Column(
        children: [
          if (_messages.isEmpty)
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.mosque_outlined,
                        size: 48,
                        color:
                            Theme.of(context).colorScheme.primary.withOpacity(0.6)),
                    const SizedBox(height: 12),
                    const Text('اسأل عن أي أمر ديني',
                        style: TextStyle(fontSize: 17)),
                    const SizedBox(height: 4),
                    Text(
                      'إجابات مبسطة معتمدة على القرآن والسنة، مع توجيهك لسؤال أهل العلم في المسائل الدقيقة',
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                    const SizedBox(height: 24),
                    Wrap(
                      alignment: WrapAlignment.center,
                      spacing: 8,
                      runSpacing: 8,
                      children: _suggestions
                          .map((s) => ActionChip(
                                label: Text(s, style: const TextStyle(fontSize: 13)),
                                onPressed: () => _send(s),
                              ))
                          .toList(),
                    ),
                  ],
                ),
              ),
            )
          else
            Expanded(
              child: ListView.builder(
                controller: _scrollController,
                padding: const EdgeInsets.all(14),
                itemCount: _messages.length + (_sending ? 1 : 0),
                itemBuilder: (context, i) {
                  if (i == _messages.length) {
                    return _buildBubble(
                      context,
                      isUser: false,
                      child: const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      ),
                    );
                  }
                  final msg = _messages[i];
                  return _buildBubble(
                    context,
                    isUser: msg.role == 'user',
                    child: Text(
                      msg.text,
                      style: const TextStyle(fontSize: 15.5, height: 1.6),
                    ),
                  );
                },
              ),
            ),
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(12, 8, 12, 12),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _controller,
                      textInputAction: TextInputAction.send,
                      onSubmitted: (_) => _send(),
                      decoration: InputDecoration(
                        hintText: 'اكتب سؤالك هنا...',
                        filled: true,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(24),
                          borderSide: BorderSide.none,
                        ),
                        contentPadding: const EdgeInsets.symmetric(
                            horizontal: 18, vertical: 12),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  IconButton.filled(
                    onPressed: _sending ? null : () => _send(),
                    icon: const Icon(Icons.send),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBubble(BuildContext context,
      {required bool isUser, required Widget child}) {
    final theme = Theme.of(context);
    return Align(
      alignment: isUser ? Alignment.centerLeft : Alignment.centerRight,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 6),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        constraints: BoxConstraints(
            maxWidth: MediaQuery.of(context).size.width * 0.78),
        decoration: BoxDecoration(
          color: isUser
              ? theme.colorScheme.surface
              : theme.colorScheme.primary.withOpacity(0.15),
          borderRadius: BorderRadius.circular(16),
        ),
        child: child,
      ),
    );
  }
}
