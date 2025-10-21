import 'package:hive/hive.dart';

part 'budget_model.g.dart';

@HiveType(typeId: 5)
class Budget extends HiveObject {
  @HiveField(0)
  String id;

  @HiveField(1)
  double totalAmount;

  @HiveField(2)
  Map<String, double> categoryBudgets;

  @HiveField(3)
  DateTime month;

  @HiveField(4)
  BudgetType budgetType;

  @HiveField(5)
  DateTime startDate;

  Budget({
    required this.id,
    required this.totalAmount,
    required this.categoryBudgets,
    required this.month,
    BudgetType? budgetType, // Make optional for migration
    DateTime? startDate, // Make optional for migration
  })  : budgetType = budgetType ?? BudgetType.monthly, // Default value
        startDate = startDate ?? month; // Use month as default
}

@HiveType(typeId: 6)
enum BudgetType {
  @HiveField(0)
  monthly,

  @HiveField(1)
  yearly,
}