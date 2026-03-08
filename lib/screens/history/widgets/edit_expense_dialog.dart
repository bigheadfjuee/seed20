import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../models/expense.dart';
import '../../../providers/budget/expense_provider.dart';
import '../../../theme/app_theme.dart';

class EditExpenseDialog extends ConsumerStatefulWidget {
  final Expense expense;

  const EditExpenseDialog({
    super.key,
    required this.expense,
  });

  @override
  ConsumerState<EditExpenseDialog> createState() => _EditExpenseDialogState();
}

class _EditExpenseDialogState extends ConsumerState<EditExpenseDialog> {
  late ExpenseCategory _selectedCategory;
  late TextEditingController _amountController;

  final Map<ExpenseCategory, String> _categoryTranslations = {
    ExpenseCategory.food: "食",
    ExpenseCategory.clothing: "衣",
    ExpenseCategory.housing: "住",
    ExpenseCategory.transport: "行",
    ExpenseCategory.education: "育",
    ExpenseCategory.entertainment: "樂",
  };

  final Map<ExpenseCategory, Color> _categoryColors = {
    ExpenseCategory.food: AppColors.food,
    ExpenseCategory.clothing: AppColors.clothing,
    ExpenseCategory.housing: AppColors.housing,
    ExpenseCategory.transport: AppColors.transport,
    ExpenseCategory.education: AppColors.education,
    ExpenseCategory.entertainment: AppColors.entertainment,
  };

  final Map<ExpenseCategory, IconData> _categoryIcons = {
    ExpenseCategory.food: Icons.restaurant,
    ExpenseCategory.clothing: Icons.checkroom,
    ExpenseCategory.housing: Icons.home,
    ExpenseCategory.transport: Icons.directions_car,
    ExpenseCategory.education: Icons.school,
    ExpenseCategory.entertainment: Icons.sports_esports,
  };

  @override
  void initState() {
    super.initState();
    _selectedCategory = widget.expense.category;
    _amountController = TextEditingController(text: widget.expense.amount.toStringAsFixed(0));
  }

  @override
  void dispose() {
    _amountController.dispose();
    super.dispose();
  }

  void _submit() {
    final amountText = _amountController.text;
    if (amountText.isEmpty) {
      Navigator.of(context).pop();
      return;
    }

    final amount = double.tryParse(amountText);
    if (amount != null && amount > 0) {
      final updatedExpense = Expense()
        ..id = widget.expense.id
        ..category = _selectedCategory
        ..amount = amount
        ..date = widget.expense.date
        ..monthId = widget.expense.monthId;

      ref.read(expenseListProvider.notifier).updateExpense(updatedExpense);
      
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('已更新該筆花費')),
      );
    }
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
        top: 24,
        left: 24,
        right: 24,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: _categoryColors[_selectedCategory]!.withOpacity(0.2),
                  shape: BoxShape.circle,
                ),
                child: Icon(_categoryIcons[_selectedCategory], color: _categoryColors[_selectedCategory], size: 28),
              ),
              const SizedBox(width: 16),
              const Text(
                "修改花費明細",
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
            ],
          ),
          const SizedBox(height: 24),
          DropdownButtonFormField<ExpenseCategory>(
            value: _selectedCategory,
            decoration: InputDecoration(
              labelText: '類別',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
              ),
            ),
            items: ExpenseCategory.values.map((category) {
              return DropdownMenuItem(
                value: category,
                child: Row(
                  children: [
                    Icon(_categoryIcons[category], color: _categoryColors[category], size: 20),
                    const SizedBox(width: 12),
                    Text(_categoryTranslations[category]!),
                  ],
                ),
              );
            }).toList(),
            onChanged: (newValue) {
              if (newValue != null) {
                setState(() {
                  _selectedCategory = newValue;
                });
              }
            },
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _amountController,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            decoration: InputDecoration(
              labelText: '金額',
              prefixText: "\$ ",
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
              ),
            ),
          ),
          const SizedBox(height: 24),
          SizedBox(
            width: double.infinity,
            height: 56,
            child: FilledButton(
              style: FilledButton.styleFrom(
                backgroundColor: Theme.of(context).colorScheme.primary,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
              onPressed: _submit,
              child: const Text('儲存修改', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            ),
          ),
          const SizedBox(height: 32),
        ],
      ),
    );
  }
}
