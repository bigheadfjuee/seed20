import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../models/expense.dart';
import 'budget_provider.dart';

part 'expense_provider.g.dart';

@riverpod
class ExpenseList extends _$ExpenseList {
  @override
  List<Expense> build() {
    // TODO: Load from Database via Repository
    // 預設回傳空列表，用於 UI 測試
    return [];
  }

  int _mockIdCounter = 1;

  void addExpense(ExpenseCategory category, double amount) {
    final currentMonth = ref.read(budgetStateProvider);
    if (currentMonth == null) return;

    final newExpense = Expense()
      ..id = _mockIdCounter++ // Mock ID for testing
      ..category = category
      ..amount = amount
      ..date = DateTime.now()
      ..monthId = currentMonth.monthId;

    // TODO: Save to Database via Repository

    // Update State
    state = [...state, newExpense];
  }

  void updateExpense(Expense updatedExpense) {
    // TODO: Update in Database via Repository
    
    // Update State
    state = [
      for (final expense in state)
        if (expense.id == updatedExpense.id) updatedExpense else expense,
    ];
  }

  void deleteExpense(Expense targetExpense) {
    // TODO: Delete from Database via Repository
    
    // Update State
    state = state.where((e) => e.id != targetExpense.id).toList();
  }
}

@riverpod
double currentMonthExpenses(CurrentMonthExpensesRef ref) {
  final expenses = ref.watch(expenseListProvider);
  return expenses.fold(0.0, (sum, item) => sum + item.amount);
}
