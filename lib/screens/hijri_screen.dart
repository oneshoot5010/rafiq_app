import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../services/hijri_service.dart';

class HijriScreen extends StatelessWidget {
  const HijriScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final now = DateTime.now();
    final hijriText = HijriService.formatToday(now);
    final gregorianText = DateFormat('EEEE، d MMMM yyyy', 'ar').format(now);

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('التاريخ الهجري', style: theme.textTheme.titleLarge),
            const SizedBox(height: 24),
            Text(
              hijriText,
              style: theme.textTheme.headlineSmall
                  ?.copyWith(color: theme.colorScheme.primary, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(gregorianText, style: theme.textTheme.bodyMedium),
            const SizedBox(height: 24),
            const Text(
              'ملحوظة: هذا تحويل حسابي تقريبي. لمواعيد رسمية مثل بداية\n'
              'رمضان أو الأعياد، يُفضّل ربطه لاحقًا بإعلان رسمي.',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 12, color: Colors.grey),
            ),
          ],
        ),
      ),
    );
  }
}
