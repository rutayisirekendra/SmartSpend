import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:smart_expense_tracker/app/theme/app_theme.dart';
import 'package:smart_expense_tracker/common_widgets/modern_card.dart';
import 'package:smart_expense_tracker/features/budget/screens/budget_screen.dart';
import 'package:smart_expense_tracker/features/expenses/screens/add_expense_screen.dart';
import 'package:smart_expense_tracker/features/notes/screens/notes_list_screen.dart';
import 'package:smart_expense_tracker/features/simulator/screens/simulator_screen.dart';

class QuickActionsCard extends StatelessWidget {
  const QuickActionsCard({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return ModernCard(
      color: AppTheme.getCardColor(context),
      padding: const EdgeInsets.all(20.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppTheme.getPrimaryColor(context).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(
                  Icons.flash_on_rounded,
                  color: AppTheme.getPrimaryColor(context),
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Text(
                'Quick Actions',
                style: GoogleFonts.poppins(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: AppTheme.getTextColor(context),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          // Action Items Grid
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: _buildActionItem(
                  context,
                  icon: Icons.add_card_rounded,
                  label: 'Add Expense',
                  color: const Color(0xFFFF9800), // Orange
                  onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const AddExpenseScreen())),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildActionItem(
                  context,
                  icon: Icons.calculate_rounded,
                  label: 'Simulator',
                  color: const Color(0xFF9C27B0), // Purple
                  onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const SimulatorScreen())),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: _buildActionItem(
                  context,
                  icon: Icons.account_balance_wallet_rounded,
                  label: 'Budget',
                  color: const Color(0xFF2196F3), // Blue
                  onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const BudgetScreen())),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildActionItem(
                  context,
                  icon: Icons.edit_note_rounded,
                  label: 'Notes',
                  color: const Color(0xFF4CAF50), // Green
                  onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const NotesListScreen())),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildActionItem(
    BuildContext context, {
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: isDark 
                ? color.withOpacity(0.15)
                : color.withOpacity(0.08),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: color.withOpacity(0.3),
              width: 1,
            ),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: isDark
                      ? color.withOpacity(0.25)
                      : color.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(14),
                  boxShadow: [
                    BoxShadow(
                      color: color.withOpacity(0.2),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Icon(
                  icon,
                  color: color,
                  size: 28,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                label,
                textAlign: TextAlign.center,
                style: GoogleFonts.poppins(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: isDark 
                      ? AppTheme.getTextColor(context)
                      : color.withOpacity(0.9),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}