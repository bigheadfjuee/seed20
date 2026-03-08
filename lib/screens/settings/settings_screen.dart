import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../providers/budget/budget_provider.dart';

class SettingsScreen extends ConsumerStatefulWidget {
  const SettingsScreen({super.key});

  @override
  ConsumerState<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends ConsumerState<SettingsScreen> {
  final _incomeController = TextEditingController();
  double _savingRate = 0.2; // 預設 20%

  @override
  void initState() {
    super.initState();
    // 取得當前設定
    final currentRecord = ref.read(budgetStateProvider);
    if (currentRecord != null) {
      _incomeController.text = currentRecord.income.toStringAsFixed(0);
      _savingRate = currentRecord.savingRate;
    }
  }

  @override
  void dispose() {
    _incomeController.dispose();
    super.dispose();
  }

  void _saveSettings() {
    final incomeText = _incomeController.text;
    if (incomeText.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('請輸入月收入')),
      );
      return;
    }

    final income = double.tryParse(incomeText);
    if (income == null || income <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('請輸入有效的金額')),
      );
      return;
    }

    // Update state and database via Provider
    ref.read(budgetStateProvider.notifier).updateMonthRecord(income, _savingRate);
    
    // 暫時用 SnackBar 提示
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('設定已儲存')),
    );
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.background,
      appBar: AppBar(
        title: const Text('本月設定'),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "第一步：輸入月收入",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _incomeController,
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w600),
              decoration: InputDecoration(
                prefixText: "\$ ",
                labelText: "本月薪資/可用資金",
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                filled: true,
                fillColor: Theme.of(context).colorScheme.surface,
              ),
            ),
            const SizedBox(height: 48),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  "第二步：設定儲蓄比例",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                Text(
                  "${(_savingRate * 100).toInt()}%",
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              "先支付給未來的自己，剩下的才是可支配預算。",
              style: TextStyle(color: Theme.of(context).colorScheme.outline),
            ),
            const SizedBox(height: 24),
            Slider(
              value: _savingRate,
              min: 0.0,
              max: 1.0,
              divisions: 20, // 每格 5%
              label: "${(_savingRate * 100).toInt()}%",
              onChanged: (value) {
                setState(() {
                  _savingRate = value;
                });
              },
            ),
            const SizedBox(height: 8),
            _buildCalculationPreview(),
            const SizedBox(height: 48),
            SizedBox(
              width: double.infinity,
              height: 56,
              child: FilledButton(
                onPressed: _saveSettings,
                style: FilledButton.styleFrom(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
                child: const Text('儲存並開始記帳', style: TextStyle(fontSize: 18)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCalculationPreview() {
    final income = double.tryParse(_incomeController.text) ?? 0.0;
    final savingTarget = income * _savingRate;
    final dispensable = income - savingTarget;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceVariant.withOpacity(0.5),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Theme.of(context).colorScheme.outline.withOpacity(0.2)),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text("預計存款 (先存)"),
              Text(
                "\$${savingTarget.toStringAsFixed(0)}",
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
            ],
          ),
          const Divider(height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text("可支配餘額 (後花)", style: TextStyle(fontWeight: FontWeight.bold)),
              Text(
                "\$${dispensable.toStringAsFixed(0)}",
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                  color: Theme.of(context).colorScheme.primary,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
