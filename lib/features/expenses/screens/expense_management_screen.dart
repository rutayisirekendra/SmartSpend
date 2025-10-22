import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:smart_expense_tracker/app/theme/app_theme.dart';
import 'package:smart_expense_tracker/features/expenses/screens/add_expense_screen.dart';
import 'package:smart_expense_tracker/features/expenses/screens/expense_history_screen.dart'; // Import history screen

// This screen acts as a container for Expense History and the Add Expense button
class ExpenseManagementScreen extends StatelessWidget {
  const ExpenseManagementScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // We use ExpenseHistoryScreen directly as the body
      // ExpenseHistoryScreen already has its own header and list logic.
      body: const ExpenseHistoryScreen(),

      // Add a FAB specifically for navigating to the Add Expense screen
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          // Navigate to the screen where users can add a new expense
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const AddExpenseScreen()),
          );
        },
        backgroundColor: AppTheme.accentOrange,
        foregroundColor: Colors.white,
        elevation: 4,
        icon: const Icon(Icons.add_card_rounded), // Icon for adding expense
        label: Text(
          'Add Expense',
          style: GoogleFonts.poppins(
            fontWeight: FontWeight.w600,
            fontSize: 14,
          ),
        ),
      ),
      // Center the FAB
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
  }
}