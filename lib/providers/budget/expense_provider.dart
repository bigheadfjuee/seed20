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

  void addExpense(ExpenseCategory category, double amount) {
    final currentMonth = ref.read(budgetStateProvider);
    if (currentMonth == null) return;

    final newExpense = Expense()
      ..category = category
      ..amount = amount
      ..date = DateTime.now()
      ..monthId = currentMonth.monthId;

    // TODO: Save to Database via Repository

    // Update State
    state = [...state, newExpense];
  }
}

@riverpod
double currentMonthExpenses(CurrentMonthExpensesRef ref) {
  final expenses = ref.watch(expenseListProvider);
  return expenses.fold(0.0, (sum, item) => sum + item.amount);
}
