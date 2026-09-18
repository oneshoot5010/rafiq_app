import 'package:flutter/material.dart';

class KhushooScreen extends StatefulWidget {
  const KhushooScreen({super.key});
  @override
  State<KhushooScreen> createState() => _KhushooScreenState();
}

class _KhushooScreenState extends State<KhushooScreen> {
  bool _active = false;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              _active ? Icons.self_improvement : Icons.self_improvement_outlined,
              size: 72,
              color: _active ? theme.colorScheme.primary : Colors.grey,
            ),
            const SizedBox(height: 20),
            Text('وضع الخشوع', style: theme.textTheme.titleLarge),
            const SizedBox(height: 12),
            Text(
              _active
                  ? 'الوضع مفعّل — حاول تقليل استخدام الهاتف وقت الصلاة'
                  : 'فعّل هذا الوضع كتذكير لنفسك بالتركيز وقت الصلاة',
              textAlign: TextAlign.center,
              style: theme.textTheme.bodyMedium?.copyWith(color: Colors.grey),
            ),
            const SizedBox(height: 24),
            Switch(
              value: _active,
              onChanged: (v) => setState(() => _active = v),
            ),
            const SizedBox(height: 12),
            const Text(
              'ملحوظة: هذا تذكير داخل التطبيق فقط، ولا يوقف تنبيهات الهاتف الأخرى حاليًا.',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 11, color: Colors.grey),
            ),
          ],
        ),
      ),
    );
  }
}
