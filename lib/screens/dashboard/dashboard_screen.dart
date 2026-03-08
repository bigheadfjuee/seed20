import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../providers/budget/budget_provider.dart';
import '../../providers/budget/expense_provider.dart';
import '../../theme/app_theme.dart';

import '../../../models/expense.dart';
import '../history/expense_list_screen.dart';
import '../settings/settings_screen.dart';
import '../stats/charts_screen.dart';

class DashboardScreen extends ConsumerStatefulWidget {
  const DashboardScreen({super.key});

  @override
  ConsumerState<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends ConsumerState<DashboardScreen> {
  String _amountInput = "0";
  ExpenseCategory _selectedCategory = ExpenseCategory.food;

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

  void _onKeyPress(String key) {
    setState(() {
      if (_amountInput == "0" && key != ".") {
        _amountInput = key;
      } else if (key == "." && _amountInput.contains(".")) {
        return; // Prevent multiple dots
      } else {
        _amountInput += key;
      }
    });
  }

  void _onBackspace() {
    setState(() {
      if (_amountInput.length > 1) {
        _amountInput = _amountInput.substring(0, _amountInput.length - 1);
      } else {
        _amountInput = "0";
      }
    });
  }

  void _submit() {
    final amount = double.tryParse(_amountInput);
    if (amount != null && amount > 0) {
      ref.read(expenseListProvider.notifier).addExpense(_selectedCategory, amount);
      setState(() {
        _amountInput = "0";
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('已記錄 \$${amount.toStringAsFixed(0)} 於 ${_categoryTranslations[_selectedCategory]}')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
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
            icon: const Icon(Icons.pie_chart),
            onPressed: () {
              Navigator.of(context).push(MaterialPageRoute(
                builder: (context) => const ChartsScreen(),
              ));
            },
          ),
          IconButton(
            icon: const Icon(Icons.list_alt),
            onPressed: () {
              Navigator.of(context).push(MaterialPageRoute(
                builder: (context) => const ExpenseListScreen(),
              ));
            },
          ),
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
              child: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: DashboardHeader(
                      remainingBudget: remaining,
                      totalDispensable: totalDisp,
                      savingTarget: record.savingTarget,
                    ),
                  ),
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
                      decoration: BoxDecoration(
                        color: Theme.of(context).colorScheme.surface,
                        borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.05),
                            blurRadius: 10,
                            offset: const Offset(0, -5),
                          )
                        ],
                      ),
                      child: Column(
                        children: [
                          // Category Dropdown and Amount Display
                          Row(
                            children: [
                              Container(
                                decoration: BoxDecoration(
                                  color: _categoryColors[_selectedCategory]!.withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(16),
                                ),
                                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                                child: DropdownButtonHideUnderline(
                                  child: DropdownButton<ExpenseCategory>(
                                    value: _selectedCategory,
                                    icon: Icon(Icons.keyboard_arrow_down, color: _categoryColors[_selectedCategory]),
                                    items: ExpenseCategory.values.map((category) {
                                      return DropdownMenuItem(
                                        value: category,
                                        child: Row(
                                          children: [
                                            Icon(_categoryIcons[category], color: _categoryColors[category], size: 20),
                                            const SizedBox(width: 8),
                                            Text(
                                              _categoryTranslations[category]!,
                                              style: TextStyle(
                                                fontWeight: FontWeight.bold,
                                                color: _categoryColors[category],
                                              ),
                                            ),
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
                                ),
                              ),
                              const Spacer(),
                              Text(
                                "\$ $_amountInput",
                                style: const TextStyle(
                                  fontSize: 32,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),
                          const Divider(),
                          const SizedBox(height: 8),
                          // Keypad
                          Expanded(
                            child: LayoutBuilder(
                              builder: (context, constraints) {
                                return Column(
                                  children: [
                                    Expanded(child: _buildKeypadRow(["1", "2", "3"])),
                                    Expanded(child: _buildKeypadRow(["4", "5", "6"])),
                                    Expanded(child: _buildKeypadRow(["7", "8", "9"])),
                                    Expanded(
                                      child: Row(
                                        crossAxisAlignment: CrossAxisAlignment.stretch,
                                        children: [
                                          Expanded(child: _buildKeypadButton(".", onTap: () => _onKeyPress("."))),
                                          Expanded(child: _buildKeypadButton("0", onTap: () => _onKeyPress("0"))),
                                          Expanded(child: _buildKeypadButton("⌫", onTap: _onBackspace)),
                                        ],
                                      ),
                                    ),
                                    const SizedBox(height: 12),
                                    SizedBox(
                                      width: double.infinity,
                                      height: 56,
                                      child: FilledButton(
                                        style: FilledButton.styleFrom(
                                          backgroundColor: _categoryColors[_selectedCategory],
                                          shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.circular(16),
                                          ),
                                        ),
                                        onPressed: _submit,
                                        child: const Text('新增花費', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                                      ),
                                    )
                                  ],
                                );
                              }
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
    );
  }

  Widget _buildKeypadRow(List<String> keys) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: keys.map((key) {
        return Expanded(
          child: _buildKeypadButton(key, onTap: () => _onKeyPress(key)),
        );
      }).toList(),
    );
  }

  Widget _buildKeypadButton(String text, {required VoidCallback onTap}) {
    return Padding(
      padding: const EdgeInsets.all(4.0),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(12),
          child: Center(
            child: Text(
              text,
              style: TextStyle(
                fontSize: text == "⌫" ? 20 : 28,
                fontWeight: FontWeight.w500,
                color: Theme.of(context).colorScheme.onBackground,
              ),
            ),
          ),
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
