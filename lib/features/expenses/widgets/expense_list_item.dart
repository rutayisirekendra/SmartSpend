import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:smart_expense_tracker/app/theme/app_theme.dart';
import 'package:smart_expense_tracker/models/expense_model.dart';

class ExpenseListItem extends StatelessWidget {
  final Expense expense;

  const ExpenseListItem({
    super.key,
    required this.expense,
  });

  IconData _getCategoryIcon(String category) {
    switch (category.toLowerCase()) {
      case 'food & drink':
        return Icons.fastfood_rounded;
      case 'transport':
        return Icons.directions_bus_rounded;
      case 'shopping':
        return Icons.shopping_bag_rounded;
      case 'entertainment':
        return Icons.movie_rounded;
      default:
        return Icons.category_rounded;
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Card(
      elevation: 1,
      margin: const EdgeInsets.symmetric(vertical: 8.0),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15.0),
      ),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: AppTheme.primaryTeal.withOpacity(0.1),
          child: Icon(
            _getCategoryIcon(expense.category),
            color: AppTheme.primaryTeal,
          ),
        ),
        title: Text(
          expense.description,
          style: theme.textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.w600),
        ),
        subtitle: Text(
          DateFormat('MMMM d, yyyy').format(expense.date),
          style: theme.textTheme.bodyMedium?.copyWith(color: Colors.grey[600]),
        ),
        trailing: Text(
          NumberFormat.currency(locale: 'en_US', symbol: '\$').format(expense.amount),
          style: theme.textTheme.bodyLarge?.copyWith(
            fontWeight: FontWeight.bold,
            color: AppTheme.primaryTeal,
          ),
        ),
      ),
    );
  }
}
