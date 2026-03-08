import 'package:isar/isar.dart';

part 'month_record.g.dart';

@collection
class MonthRecord {
  Id id = Isar.autoIncrement;

  // e.g., "2023-11"
  @Index(unique: true, replace: true)
  late String monthId;

  late double income;

  // 0.0 ~ 1.0, 預設 0.2
  late double savingRate;

  // income * savingRate
  late double savingTarget;
}
