import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fl_chart/fl_chart.dart';

import '../../models/expense.dart';
import '../../providers/budget/expense_provider.dart';
import '../../theme/app_theme.dart';

class ChartsScreen extends ConsumerWidget {
  const ChartsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // 取得所有花費
    final expenses = ref.watch(expenseListProvider);
    final totalExpenses = ref.watch(currentMonthExpensesProvider);

    // 計算各類別加總
    final Map<ExpenseCategory, double> categorySums = {};
    for (var expense in expenses) {
      categorySums[expense.category] = (categorySums[expense.category] ?? 0) + expense.amount;
    }

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
        title: const Text('類別統計', style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: totalExpenses == 0
          ? const Center(child: Text("目前沒有任何花費紀錄"))
          : Column(
              children: [
                const SizedBox(height: 24),
                // Pie Chart 區域
                SizedBox(
                  height: 250,
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      PieChart(
                        PieChartData(
                          sectionsSpace: 2,
                          centerSpaceRadius: 60,
                          sections: ExpenseCategory.values.map((category) {
                            final value = categorySums[category] ?? 0;
                            final percentage = (value / totalExpenses) * 100;
                            return PieChartSectionData(
                              color: categoryColors[category],
                              value: value,
                              title: percentage > 5 ? '${percentage.toStringAsFixed(1)}%' : '',
                              radius: percentage > 5 ? 50 : 40,
                              titleStyle: const TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            );
                          }).toList()
                            ..removeWhere((section) => section.value == 0), // 移除沒有花費的區塊
                        ),
                      ),
                      // 中間顯示總金額
                      Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            "總花費",
                            style: TextStyle(
                              fontSize: 14,
                              color: Theme.of(context).colorScheme.outline,
                            ),
                          ),
                          Text(
                            "\$${totalExpenses.toStringAsFixed(0)}",
                            style: const TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 32),
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 24.0),
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      "各項明細",
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                // 列表區域
                Expanded(
                  child: ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0),
                    itemCount: ExpenseCategory.values.length,
                    itemBuilder: (context, index) {
                      final category = ExpenseCategory.values[index];
                      final sum = categorySums[category] ?? 0;
                      if (sum == 0) return const SizedBox.shrink(); // 不顯示 0 元項
                      
                      final percentage = (sum / totalExpenses) * 100;

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
                              color: categoryColors[category]!.withOpacity(0.15),
                              shape: BoxShape.circle,
                            ),
                            child: Icon(categoryIcons[category], color: categoryColors[category]),
                          ),
                          title: Row(
                            children: [
                              Text(
                                categoryTranslations[category]!,
                                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                              ),
                              const SizedBox(width: 8),
                              Text(
                                "${percentage.toStringAsFixed(1)}%",
                                style: TextStyle(
                                  color: Theme.of(context).colorScheme.outline,
                                  fontSize: 14,
                                ),
                              ),
                            ],
                          ),
                          trailing: Text(
                            "\$${sum.toStringAsFixed(0)}",
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 18,
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
    );
  }
}
