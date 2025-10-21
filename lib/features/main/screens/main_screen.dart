import 'package:flutter/material.dart';
import 'package:smart_expense_tracker/app/theme/app_theme.dart';
import 'package:smart_expense_tracker/features/budget/screens/budget_screen.dart';
import 'package:smart_expense_tracker/features/dashboard/screens/dashboard_screen.dart';
import 'package:smart_expense_tracker/features/expenses/screens/add_expense_screen.dart';
import 'package:smart_expense_tracker/features/goals/screens/goals_screen.dart';
import 'package:smart_expense_tracker/features/notes/screens/notes_list_screen.dart';
// REMOVED: Duplicate import of budget_screen

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _selectedIndex = 0;

  // FIX: Updated the list of pages and removed const from non-const widgets
  static final List<Widget> _pages = <Widget>[
    const DashboardScreen(),
    const BudgetScreen(),
    const NotesListScreen(),
    GoalsScreen(), // This screen uses mock data, so its constructor cannot be const
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _pages.elementAt(_selectedIndex),
      floatingActionButton: FloatingActionButton(
        onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const AddExpenseScreen())),
        backgroundColor: AppTheme.accentOrange,
        foregroundColor: Colors.white,
        child: const Icon(Icons.add),
        elevation: 2.0,
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      bottomNavigationBar: BottomAppBar(
        shape: const CircularNotchedRectangle(),
        notchMargin: 8.0,
        child: SizedBox(
          height: 60,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              // FIX: Updated navigation items as requested
              _buildNavItem(icon: Icons.home_rounded, label: 'Home', index: 0),
              _buildNavItem(icon: Icons.account_balance_wallet_rounded, label: 'Budget', index: 1),
              const SizedBox(width: 40), // The space for the FAB
              _buildNavItem(icon: Icons.edit_note_rounded, label: 'Notes', index: 2),
              _buildNavItem(icon: Icons.flag_rounded, label: 'Goals', index: 3),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem({required IconData icon, required String label, required int index}) {
    final isSelected = _selectedIndex == index;
    final color = isSelected ? AppTheme.primaryTeal : Colors.grey;
    return Expanded(
      child: MaterialButton(
        minWidth: 40,
        onPressed: () => _onItemTapped(index),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: color),
            Text(
              label,
              style: TextStyle(
                  color: color,
                  fontSize: 12,
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.normal
              ),
            ),
          ],
        ),
      ),
    );
  }
}