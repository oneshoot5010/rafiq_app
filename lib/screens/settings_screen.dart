import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';
import '../services/notification_service.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});
  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool _notificationsEnabled = true;
  Map<String, bool> _perPrayer = {};
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadPrefs();
  }

  Future<void> _loadPrefs() async {
    final prefs = await SharedPreferences.getInstance();
    final map = <String, bool>{};
    for (final entry in NotificationService.prefKeys.entries) {
      map[entry.key] = prefs.getBool(entry.value) ?? true;
    }
    setState(() {
      _notificationsEnabled = prefs.getBool('notifications_enabled') ?? true;
      _perPrayer = map;
      _loading = false;
    });
  }

  Future<void> _setNotifications(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('notifications_enabled', value);
    setState(() => _notificationsEnabled = value);
    if (!value) {
      await NotificationService.cancelAll();
    }
  }

  Future<void> _setPrayerEnabled(String prayerName, bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(NotificationService.prefKeys[prayerName]!, value);
    setState(() => _perPrayer[prayerName] = value);
  }

  Future<void> _testAthan() async {
    try {
      await NotificationService.scheduleTest();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('هيوصلك إشعار تجريبي بصوت الأذان خلال 10 ثواني'),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('حصل خطأ: $e'),
            duration: const Duration(seconds: 8),
          ),
        );
      }
    }
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

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Center(child: CircularProgressIndicator());
    }
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
        ListTile(
          leading: const Icon(Icons.volume_up_outlined),
          title: const Text('اختبار صوت الأذان'),
          subtitle: const Text('يشغّل إشعارًا تجريبيًا بعد 10 ثوانٍ'),
          onTap: _testAthan,
        ),
        if (_notificationsEnabled) ...[
          const Padding(
            padding: EdgeInsets.fromLTRB(16, 14, 16, 2),
            child: Text('ضبط الأذان لكل صلاة',
                style: TextStyle(fontWeight: FontWeight.bold)),
          ),
          ..._perPrayer.entries.map(
            (e) => SwitchListTile(
              dense: true,
              title: Text(e.key),
              value: e.value,
              onChanged: (v) => _setPrayerEnabled(e.key, v),
            ),
          ),
        ],
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
