import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:smart_expense_tracker/app/theme/app_theme.dart';

class SavingsTree extends StatelessWidget {
  final String goalName;
  final double currentAmount;
  final double targetAmount;

  const SavingsTree({
    super.key,
    required this.goalName,
    required this.currentAmount,
    required this.targetAmount,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final percentage = (currentAmount / targetAmount).clamp(0.0, 1.0);

    return Column(
      children: [
        Text(
          goalName,
          style: theme.textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.bold),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 16),
        // This is a simplified visual representation of a growing tree
        Icon(
          _getTreeIcon(percentage),
          size: 80,
          color: AppTheme.primaryTeal,
        ),
        const SizedBox(height: 16),
        LinearProgressIndicator(
          value: percentage,
          backgroundColor: AppTheme.primaryTeal.withOpacity(0.2),
          valueColor: const AlwaysStoppedAnimation<Color>(AppTheme.primaryTeal),
          minHeight: 10,
          borderRadius: BorderRadius.circular(5),
        ),
        const SizedBox(height: 8),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              NumberFormat.currency(locale: 'en_US', symbol: '\$').format(currentAmount),
              style: theme.textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.w600),
            ),
            Text(
              NumberFormat.currency(locale: 'en_US', symbol: '\$').format(targetAmount),
              style: theme.textTheme.bodyMedium?.copyWith(color: Colors.grey[600]),
            ),
          ],
        ),
      ],
    );
  }

  IconData _getTreeIcon(double percentage) {
    if (percentage < 0.25) {
      return Icons.eco_rounded; // Sprout
    } else if (percentage < 0.75) {
      return Icons.park_rounded; // Small Tree
    } else {
      return Icons.forest_rounded; // Full Tree
    }
  }
}
