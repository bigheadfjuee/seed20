import 'package:isar/isar.dart';

part 'expense.g.dart';

enum ExpenseCategory {
  food, // 食
  clothing, // 衣
  housing, // 住
  transport, // 行
  education, // 育
  entertainment // 樂
}

@collection
class Expense {
  Id id = Isar.autoIncrement;

  @enumerated
  late ExpenseCategory category;

  late double amount;

  late DateTime date;

  // 用來關聯這個花費是屬於哪個月的紀錄 (e.g. '2023-11')
  @Index()
  late String monthId;
}
