import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';
import '../services/gemini_service.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});
  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool _notificationsEnabled = true;
  bool _loading = true;
  String? _apiKey;

  @override
  void initState() {
    super.initState();
    _loadPrefs();
  }

  Future<void> _loadPrefs() async {
    final prefs = await SharedPreferences.getInstance();
    final key = await GeminiService.getApiKey();
    setState(() {
      _notificationsEnabled = prefs.getBool('notifications_enabled') ?? true;
      _apiKey = key;
      _loading = false;
    });
  }

  Future<void> _setNotifications(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('notifications_enabled', value);
    setState(() => _notificationsEnabled = value);
  }

  Future<void> _resetDhikrCounters() async {
    final prefs = await SharedPreferences.getInstance();
    final keys = prefs.getKeys().where((k) => k.startsWith('dhikr_'));
    for (final k in keys) {
      await prefs.remove(k);
    }
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('تم تصفير عدادات الأذكار')),
      );
    }
  }

  Future<void> _confirmReset() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('تصفير العدادات'),
        content: const Text('هل أنت متأكد من تصفير كل عدادات الأذكار؟'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('إلغاء'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('تصفير'),
          ),
        ],
      ),
    );
    if (confirmed == true) _resetDhikrCounters();
  }

  Future<void> _shareApp() async {
    final uri = Uri.parse('https://github.com/oneshoot5010/rafiq_app');
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  Future<void> _editApiKey() async {
    final controller = TextEditingController(text: _apiKey ?? '');
    final result = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('مفتاح Gemini API'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'يُستخدم لتشغيل مساعد الأسئلة الدينية الذكي. احصل عليه من aistudio.google.com/apikey',
              style: TextStyle(fontSize: 12),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: controller,
              obscureText: true,
              decoration: const InputDecoration(
                hintText: 'الصق المفتاح هنا',
                border: OutlineInputBorder(),
              ),
            ),
          ],
        ),
        actions: [
          if (_apiKey != null && _apiKey!.isNotEmpty)
            TextButton(
              onPressed: () => Navigator.pop(context, ''),
              child: const Text('حذف المفتاح',
                  style: TextStyle(color: Colors.red)),
            ),
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('إلغاء'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, controller.text.trim()),
            child: const Text('حفظ'),
          ),
        ],
      ),
    );

    if (result == null) return;
    if (result.isEmpty) {
      await GeminiService.clearApiKey();
      setState(() => _apiKey = null);
    } else {
      await GeminiService.setApiKey(result);
      setState(() => _apiKey = result);
    }
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content: Text(result.isEmpty ? 'تم حذف المفتاح' : 'تم حفظ المفتاح')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Center(child: CircularProgressIndicator());
    }
    final hasKey = _apiKey != null && _apiKey!.isNotEmpty;
    return ListView(
      padding: const EdgeInsets.symmetric(vertical: 8),
      children: [
        const Padding(
          padding: EdgeInsets.fromLTRB(16, 12, 16, 4),
          child: Text('عام', style: TextStyle(fontWeight: FontWeight.bold)),
        ),
        SwitchListTile(
          title: const Text('تنبيهات مواقيت الصلاة'),
          subtitle: const Text('تفعيل أو إيقاف إشعارات الصلاة'),
          value: _notificationsEnabled,
          onChanged: _setNotifications,
        ),
        const Divider(),
        const Padding(
          padding: EdgeInsets.fromLTRB(16, 12, 16, 4),
          child: Text('المساعد الذكي',
              style: TextStyle(fontWeight: FontWeight.bold)),
        ),
        ListTile(
          leading: Icon(Icons.vpn_key_outlined,
              color: hasKey ? Colors.green : null),
          title: const Text('مفتاح Gemini API'),
          subtitle: Text(hasKey ? 'تم إضافة المفتاح ✓' : 'لم تتم إضافة مفتاح بعد'),
          onTap: _editApiKey,
        ),
        const Divider(),
        const Padding(
          padding: EdgeInsets.fromLTRB(16, 12, 16, 4),
          child: Text('البيانات', style: TextStyle(fontWeight: FontWeight.bold)),
        ),
        ListTile(
          leading: const Icon(Icons.refresh),
          title: const Text('تصفير عدادات الأذكار'),
          onTap: _confirmReset,
        ),
        const Divider(),
        const Padding(
          padding: EdgeInsets.fromLTRB(16, 12, 16, 4),
          child: Text('عن التطبيق', style: TextStyle(fontWeight: FontWeight.bold)),
        ),
        ListTile(
          leading: const Icon(Icons.share_outlined),
          title: const Text('مشاركة التطبيق'),
          onTap: _shareApp,
        ),
        const ListTile(
          leading: Icon(Icons.info_outline),
          title: Text('الإصدار'),
          subtitle: Text('0.1.0'),
        ),
      ],
    );
  }
}
