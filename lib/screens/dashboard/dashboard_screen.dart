import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../providers/budget/budget_provider.dart';
import '../../theme/app_theme.dart';

import '../../../models/expense.dart';
import '../settings/settings_screen.dart';
import 'widgets/expense_input_dialog.dart';

class DashboardScreen extends ConsumerWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final record = ref.watch(budgetStateProvider);
    final remaining = ref.watch(remainingBudgetProvider);
    final totalDisp = ref.watch(totalDispensableProvider);

    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.background,
      appBar: AppBar(
        title: const Text('本月預算', style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.settings_outlined),
            onPressed: () {
              Navigator.of(context).push(MaterialPageRoute(
                builder: (context) => const SettingsScreen(),
              ));
            },
          ),
          IconButton(
            icon: const Icon(Icons.cloud_sync_outlined),
            onPressed: () {
              // TODO: Navigate to sync screen
            },
          )
        ],
      ),
      body: record == null
          ? const Center(child: Text("尚未設定本月資料"))
          : SafeArea(
              child: CustomScrollView(
                slivers: [
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: DashboardHeader(
                        remainingBudget: remaining,
                        totalDispensable: totalDisp,
                        savingTarget: record.savingTarget,
                      ),
                    ),
                  ),
                  const SliverToBoxAdapter(
                    child: Padding(
                      padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                      child: Text(
                        "快速記帳",
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                  SliverPadding(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0),
                    sliver: SliverGrid(
                      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 3,
                        crossAxisSpacing: 12.0,
                        mainAxisSpacing: 12.0,
                        childAspectRatio: 0.9, // Adjust ratio to give more vertical space
                      ),
                      delegate: SliverChildListDelegate([
                        _buildCategoryButton(context, "食", ExpenseCategory.food, Icons.restaurant, AppColors.food),
                        _buildCategoryButton(context, "衣", ExpenseCategory.clothing, Icons.checkroom, AppColors.clothing),
                        _buildCategoryButton(context, "住", ExpenseCategory.housing, Icons.home, AppColors.housing),
                        _buildCategoryButton(context, "行", ExpenseCategory.transport, Icons.directions_car, AppColors.transport),
                        _buildCategoryButton(context, "育", ExpenseCategory.education, Icons.school, AppColors.education),
                        _buildCategoryButton(context, "樂", ExpenseCategory.entertainment, Icons.sports_esports, AppColors.entertainment),
                      ]),
                    ),
                  ),
                ],
              ),
            ),
    );
  }

  Widget _buildCategoryButton(BuildContext context, String title, ExpenseCategory category, IconData icon, Color color) {
    return Material(
      color: color.withOpacity(0.1),
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        onTap: () {
          showModalBottomSheet(
            context: context,
            isScrollControlled: true,
            backgroundColor: Theme.of(context).colorScheme.surface,
            shape: const RoundedRectangleBorder(
              borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
            ),
            builder: (context) => ExpenseInputDialog(
              category: category,
              categoryName: title,
              categoryColor: color,
              categoryIcon: icon,
            ),
          );
        },
        borderRadius: BorderRadius.circular(16),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: color.withOpacity(0.2),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: color, size: 24), // Reduced size slightly
            ),
            const SizedBox(height: 4), // Reduced spacing
            Flexible( // Use Flexible to prevent text overflow
              child: Text(
                title,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                  color: color.withOpacity(0.8),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class DashboardHeader extends StatelessWidget {
  final double remainingBudget;
  final double totalDispensable;
  final double savingTarget;

  const DashboardHeader({
    super.key,
    required this.remainingBudget,
    required this.totalDispensable,
    required this.savingTarget,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: AppColors.remainingBudgetGradient,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: AppColors.remainingBudgetGradient.colors.first.withOpacity(0.3),
            blurRadius: 15,
            offset: const Offset(0, 8),
          )
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "可用餘額",
            style: TextStyle(
              color: Colors.white.withOpacity(0.8),
              fontSize: 16,
            ),
          ),
          const SizedBox(height: 8),
          Row(
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: [
              const Text(
                "\$",
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(width: 4),
              Text(
                remainingBudget.toStringAsFixed(0),
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 48,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildInfoColumn("預計存款 (先存)", savingTarget),
              _buildInfoColumn("本月預算 (後花)", totalDispensable),
            ],
          )
        ],
      ),
    );
  }

  Widget _buildInfoColumn(String label, double amount) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            color: Colors.white.withOpacity(0.7),
            fontSize: 12,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          "\$${amount.toStringAsFixed(0)}",
          style: const TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }
}
