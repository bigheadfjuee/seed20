import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../models/month_record.dart';
import 'expense_provider.dart';

part 'budget_provider.g.dart';

@riverpod
class BudgetState extends _$BudgetState {
  @override
  MonthRecord? build() {
    // TODO: Load from Isar database
    // Returning dummy data for UI testing right now
    return MonthRecord()
      ..monthId = "2023-11"
      ..income = 80000
      ..savingRate = 0.2
      ..savingTarget = 16000;
  }

  void updateMonthRecord(double income, double savingRate) {
    if (state == null) return;
    
    // Create new instance to trigger rebuild
    final updatedRecord = MonthRecord()
      ..monthId = state!.monthId
      ..income = income
      ..savingRate = savingRate
      ..savingTarget = income * savingRate;

    // TODO: Save to database via repository
    
    state = updatedRecord;
  }
}

// 可支配金額 (Income - SavingTarget)
@riverpod
double totalDispensable(TotalDispensableRef ref) {
  final record = ref.watch(budgetStateProvider);
  if (record == null) return 0.0;
  return record.income - record.savingTarget;
}

// 剩餘預算 (Total Dispensable - Current Expenses)
@riverpod
double remainingBudget(RemainingBudgetRef ref) {
  final record = ref.watch(budgetStateProvider);
  if (record == null) return 0.0;
  
  final currentExpenses = ref.watch(currentMonthExpensesProvider);
  
  return (record.income - record.savingTarget) - currentExpenses;
}
