import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../models/expense.dart';
import '../../providers/budget/expense_provider.dart';
import '../../theme/app_theme.dart';
import 'widgets/edit_expense_dialog.dart';

class ExpenseListScreen extends ConsumerWidget {
  const ExpenseListScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // 取得所有花費紀錄
    final expenses = ref.watch(expenseListProvider);
    
    // 根據日期由新到舊排序
    final sortedExpenses = List<Expense>.from(expenses)
      ..sort((a, b) => b.date.compareTo(a.date));

    final Map<ExpenseCategory, String> categoryTranslations = {
      ExpenseCategory.food: "食",
      ExpenseCategory.clothing: "衣",
      ExpenseCategory.housing: "住",
      ExpenseCategory.transport: "行",
      ExpenseCategory.education: "育",
      ExpenseCategory.entertainment: "樂",
    };

    final Map<ExpenseCategory, Color> categoryColors = {
      ExpenseCategory.food: AppColors.food,
      ExpenseCategory.clothing: AppColors.clothing,
      ExpenseCategory.housing: AppColors.housing,
      ExpenseCategory.transport: AppColors.transport,
      ExpenseCategory.education: AppColors.education,
      ExpenseCategory.entertainment: AppColors.entertainment,
    };

    final Map<ExpenseCategory, IconData> categoryIcons = {
      ExpenseCategory.food: Icons.restaurant,
      ExpenseCategory.clothing: Icons.checkroom,
      ExpenseCategory.housing: Icons.home,
      ExpenseCategory.transport: Icons.directions_car,
      ExpenseCategory.education: Icons.school,
      ExpenseCategory.entertainment: Icons.sports_esports,
    };

    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.background,
      appBar: AppBar(
        title: const Text('花費明細'),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: sortedExpenses.isEmpty
          ? const Center(child: Text('目前還沒有花費紀錄喔！'))
          : ListView.builder(
              padding: const EdgeInsets.all(16.0),
              itemCount: sortedExpenses.length,
              itemBuilder: (context, index) {
                final expense = sortedExpenses[index];
                final color = categoryColors[expense.category]!;
                final icon = categoryIcons[expense.category]!;
                final title = categoryTranslations[expense.category]!;
                
                final dateFormat = DateFormat('MM/dd HH:mm');

                return Card(
                  margin: const EdgeInsets.only(bottom: 12.0),
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                    side: BorderSide(
                      color: Theme.of(context).colorScheme.outline.withOpacity(0.1),
                    )
                  ),
                  child: ListTile(
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                    leading: Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: color.withOpacity(0.15),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(icon, color: color),
                    ),
                    title: Text(
                      title,
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                    ),
                    subtitle: Padding(
                      padding: const EdgeInsets.only(top: 4.0),
                      child: Text(
                        dateFormat.format(expense.date),
                        style: TextStyle(
                          color: Theme.of(context).colorScheme.outline,
                          fontSize: 12,
                        ),
                      ),
                    ),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          "-\$${expense.amount.toStringAsFixed(0)}",
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 18,
                          ),
                        ),
                        PopupMenuButton<String>(
                          icon: const Icon(Icons.more_vert),
                          onSelected: (value) {
                            if (value == 'edit') {
                              showModalBottomSheet(
                                context: context,
                                isScrollControlled: true,
                                backgroundColor: Theme.of(context).colorScheme.surface,
                                shape: const RoundedRectangleBorder(
                                  borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
                                ),
                                builder: (context) => EditExpenseDialog(expense: expense),
                              );
                            } else if (value == 'delete') {
                              showDialog(
                                context: context,
                                builder: (context) => AlertDialog(
                                  title: const Text('刪除花費'),
                                  content: const Text('確定要刪除這筆花費嗎？此動作無法復原。'),
                                  actions: [
                                    TextButton(
                                      onPressed: () => Navigator.of(context).pop(),
                                      child: const Text('取消'),
                                    ),
                                    TextButton(
                                      onPressed: () {
                                        ref.read(expenseListProvider.notifier).deleteExpense(expense);
                                        Navigator.of(context).pop();
                                        ScaffoldMessenger.of(context).showSnackBar(
                                          const SnackBar(content: Text('已刪除花費')),
                                        );
                                      },
                                      child: Text(
                                        '刪除',
                                        style: TextStyle(color: Theme.of(context).colorScheme.error),
                                      ),
                                    ),
                                  ],
                                ),
                              );
                            }
                          },
                          itemBuilder: (context) => [
                            const PopupMenuItem(
                              value: 'edit',
                              child: Row(
                                children: [
                                  Icon(Icons.edit, size: 20),
                                  SizedBox(width: 8),
                                  Text('編輯'),
                                ],
                              ),
                            ),
                            const PopupMenuItem(
                              value: 'delete',
                              child: Row(
                                children: [
                                  Icon(Icons.delete, size: 20, color: Colors.red),
                                  SizedBox(width: 8),
                                  Text('刪除', style: TextStyle(color: Colors.red)),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
    );
  }
}
