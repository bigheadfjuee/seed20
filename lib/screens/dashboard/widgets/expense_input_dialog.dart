import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../models/expense.dart';
import '../../../providers/budget/expense_provider.dart';

class ExpenseInputDialog extends ConsumerStatefulWidget {
  final ExpenseCategory category;
  final String categoryName;
  final Color categoryColor;
  final IconData categoryIcon;

  const ExpenseInputDialog({
    super.key,
    required this.category,
    required this.categoryName,
    required this.categoryColor,
    required this.categoryIcon,
  });

  @override
  ConsumerState<ExpenseInputDialog> createState() => _ExpenseInputDialogState();
}

class _ExpenseInputDialogState extends ConsumerState<ExpenseInputDialog> {
  final _amountController = TextEditingController();
  final _focusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    // 自動獲取焦點並開啟鍵盤
    Future.delayed(const Duration(milliseconds: 100), () {
      _focusNode.requestFocus();
    });
  }

  @override
  void dispose() {
    _amountController.dispose();
    _focusNode.dispose();
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
      ref.read(expenseListProvider.notifier).addExpense(widget.category, amount);
    }
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      // 處理鍵盤遮擋
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
                  color: widget.categoryColor.withOpacity(0.2),
                  shape: BoxShape.circle,
                ),
                child: Icon(widget.categoryIcon, color: widget.categoryColor, size: 28),
              ),
              const SizedBox(width: 16),
              Text(
                "新增「${widget.categoryName}」花費",
                style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
            ],
          ),
          const SizedBox(height: 24),
          TextField(
            controller: _amountController,
            focusNode: _focusNode,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            style: const TextStyle(fontSize: 32, fontWeight: FontWeight.bold),
            textAlign: TextAlign.center,
            decoration: InputDecoration(
              hintText: "0",
              prefixText: "\$ ",
              prefixStyle: TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).colorScheme.primary),
              border: InputBorder.none,
            ),
            onSubmitted: (_) => _submit(),
          ),
          const SizedBox(height: 24),
          SizedBox(
            width: double.infinity,
            height: 56,
            child: FilledButton(
              style: FilledButton.styleFrom(
                backgroundColor: widget.categoryColor,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
              onPressed: _submit,
              child: const Text('確認新增', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            ),
          ),
          const SizedBox(height: 32),
        ],
      ),
    );
  }
}
