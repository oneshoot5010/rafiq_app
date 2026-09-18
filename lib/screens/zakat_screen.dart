import 'package:flutter/material.dart';

class ZakatScreen extends StatefulWidget {
  const ZakatScreen({super.key});
  @override
  State<ZakatScreen> createState() => _ZakatScreenState();
}

class _ZakatScreenState extends State<ZakatScreen> {
  final _cashController = TextEditingController();
  final _goldController = TextEditingController();
  final _goldPriceController = TextEditingController();
  final _debtController = TextEditingController();
  double? _result;

  void _calculate() {
    final cash = double.tryParse(_cashController.text) ?? 0;
    final goldGrams = double.tryParse(_goldController.text) ?? 0;
    final goldPrice = double.tryParse(_goldPriceController.text) ?? 0;
    final debt = double.tryParse(_debtController.text) ?? 0;

    final goldValue = goldGrams * goldPrice;
    final totalWealth = cash + goldValue - debt;
    final nisab = 85 * goldPrice;

    setState(() {
      if (totalWealth >= nisab && totalWealth > 0) {
        _result = totalWealth * 0.025;
      } else {
        _result = 0;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Text('حاسبة الزكاة', style: theme.textTheme.titleLarge, textAlign: TextAlign.center),
        const SizedBox(height: 8),
        Text(
          'الزكاة تجب إذا بلغ المال النصاب (قيمة 85 جرام ذهب) وحال عليه الحول.',
          style: theme.textTheme.bodySmall?.copyWith(color: Colors.grey),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 24),
        TextField(
          controller: _cashController,
          keyboardType: TextInputType.number,
          decoration: const InputDecoration(labelText: 'النقود والمدخرات (جنيه)', border: OutlineInputBorder()),
        ),
        const SizedBox(height: 12),
        TextField(
          controller: _goldController,
          keyboardType: TextInputType.number,
          decoration: const InputDecoration(labelText: 'الذهب المملوك (جرام)', border: OutlineInputBorder()),
        ),
        const SizedBox(height: 12),
        TextField(
          controller: _goldPriceController,
          keyboardType: TextInputType.number,
          decoration: const InputDecoration(labelText: 'سعر جرام الذهب الحالي (جنيه)', border: OutlineInputBorder()),
        ),
        const SizedBox(height: 12),
        TextField(
          controller: _debtController,
          keyboardType: TextInputType.number,
          decoration: const InputDecoration(labelText: 'الديون المستحقة عليك (جنيه)', border: OutlineInputBorder()),
        ),
        const SizedBox(height: 24),
        ElevatedButton(
          onPressed: _calculate,
          style: ElevatedButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 16)),
          child: const Text('احسب الزكاة'),
        ),
        if (_result != null) ...[
          const SizedBox(height: 24),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  Text(
                    _result! > 0 ? 'مقدار الزكاة الواجبة' : 'لا تجب عليك زكاة',
                    style: theme.textTheme.titleMedium,
                  ),
                  const SizedBox(height: 8),
                  if (_result! > 0)
                    Text(
                      '${_result!.toStringAsFixed(2)} جنيه',
                      style: theme.textTheme.headlineMedium?.copyWith(
                        color: theme.colorScheme.primary,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                ],
              ),
            ),
          ),
        ],
      ],
    );
  }
}
