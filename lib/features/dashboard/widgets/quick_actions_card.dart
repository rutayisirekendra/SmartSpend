import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:smart_expense_tracker/app/theme/app_theme.dart';
import 'package:smart_expense_tracker/features/expenses/screens/add_expense_screen.dart';
import 'package:smart_expense_tracker/features/notes/screens/notes_list_screen.dart';
import 'package:smart_expense_tracker/features/simulator/screens/simulator_screen.dart';

class QuickActionsCard extends StatelessWidget {
  const QuickActionsCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      shadowColor: Colors.black.withOpacity(0.05),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 16.0),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildActionItem(
                  context,
                  icon: Icons.add_card_rounded,
                  label: 'Add Expense',
                  onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const AddExpenseScreen())),
                ),
                _buildActionItem(
                  context,
                  icon: Icons.calculate_rounded,
                  label: 'Simulator',
                  onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const SimulatorScreen())),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildActionItem(
                  context,
                  icon: Icons.account_balance_wallet_outlined,
                  label: 'Budget',
                  // This should ideally navigate to the budget tab, but for now a direct nav is fine
                  onTap: () { /* TODO: Navigate to Budget Tab */ },
                ),
                _buildActionItem(
                  context,
                  icon: Icons.edit_note_rounded,
                  label: 'Notes',
                  onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const NotesListScreen())),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionItem(BuildContext context, {required IconData icon, required String label, required VoidCallback onTap}) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 12.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppTheme.primaryTeal.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: AppTheme.primaryTeal, size: 28),
            ),
            const SizedBox(height: 8),
            Text(
              label,
              style: GoogleFonts.poppins(
                fontWeight: FontWeight.w500,
                color: AppTheme.darkGrey,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

