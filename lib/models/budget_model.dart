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
  DateTime month; // For monthly budgets

  @HiveField(4)
  BudgetType budgetType;

  @HiveField(5)
  DateTime startDate; // For both monthly/yearly

  Budget({
    required this.id,
    required this.totalAmount,
    required this.categoryBudgets,
    required this.month,
    required this.budgetType,
    required this.startDate,
  });

  // Helper method to check if this is the current budget
  bool isCurrentBudget() {
    final now = DateTime.now();
    if (budgetType == BudgetType.monthly) {
      return month.year == now.year && month.month == now.month;
    } else {
      return startDate.year == now.year;
    }
  }

  // Helper to get display period
  String get periodLabel {
    if (budgetType == BudgetType.monthly) {
      return '${_getMonthName(month.month)} ${month.year}';
    } else {
      return 'Year ${startDate.year}';
    }
  }

  String _getMonthName(int month) {
    const months = [
      'January', 'February', 'March', 'April', 'May', 'June',
      'July', 'August', 'September', 'October', 'November', 'December'
    ];
    return months[month - 1];
  }
}

@HiveType(typeId: 6)
enum BudgetType {
  @HiveField(0)
  monthly,

  @HiveField(1)
  yearly,
}