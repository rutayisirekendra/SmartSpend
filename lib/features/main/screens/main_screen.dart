import 'package:flutter/material.dart';
import 'package:smart_expense_tracker/app/theme/app_theme.dart';
import 'package:smart_expense_tracker/features/budget/screens/budget_screen.dart';
import 'package:smart_expense_tracker/features/dashboard/screens/dashboard_screen.dart';
// REMOVED: Direct import of AddExpenseScreen from FAB
// import 'package:smart_expense_tracker/features/expenses/screens/add_expense_screen.dart';
import 'package:smart_expense_tracker/features/goals/screens/goals_screen.dart';
import 'package:smart_expense_tracker/features/notes/screens/notes_list_screen.dart';
// ADDED: Import for the Expense Management screen (which contains history + add button)
import 'package:smart_expense_tracker/features/expenses/screens/expense_management_screen.dart';


class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _selectedIndex = 0;

  // List of main pages accessible via BottomNavigationBar
  static final List<Widget> _pages = <Widget>[
    const DashboardScreen(),
    const BudgetScreen(),
    const NotesListScreen(),
    GoalsScreen(), // Cannot be const due to stateful logic inside
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return Scaffold(
      body: _pages.elementAt(_selectedIndex),
      floatingActionButton: FloatingActionButton(
        // MODIFIED: Navigate to ExpenseManagementScreen instead of AddExpenseScreen
        onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const ExpenseManagementScreen())),
        backgroundColor: AppTheme.getOriginalAccentColor(context),
        foregroundColor: Colors.white,
        // CHANGED ICON: Use a more general 'list' or 'receipt' icon for history view
        child: const Icon(Icons.receipt_long, size: 24),
        elevation: 3.0,
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          boxShadow: [
            BoxShadow(
              color: isDark 
                  ? Colors.black.withValues(alpha: 0.3)
                  : Colors.black.withValues(alpha: 0.1),
              blurRadius: 10,
              offset: const Offset(0, -2),
            ),
          ],
        ),
        child: BottomAppBar(
          color: isDark ? AppTheme.darkCard : Colors.white,
          elevation: 0,
          shape: const CircularNotchedRectangle(),
          notchMargin: 8.0,
          height: 65,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: <Widget>[
                _buildNavItem(icon: Icons.home_rounded, label: 'Home', index: 0),
                _buildNavItem(icon: Icons.account_balance_wallet_rounded, label: 'Budget', index: 1),
                const SizedBox(width: 56), // Space for the FAB
                _buildNavItem(icon: Icons.edit_note_rounded, label: 'Notes', index: 2),
                _buildNavItem(icon: Icons.flag_rounded, label: 'Goals', index: 3),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem({required IconData icon, required String label, required int index}) {
    final isSelected = _selectedIndex == index;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    // Use turquoise for selected items in dark mode, primary teal for light mode
    final selectedColor = AppTheme.getPrimaryTealColor(context);
    final unselectedColor = isDark 
        ? Colors.grey.shade600 
        : Colors.grey.shade500;
    final color = isSelected ? selectedColor : unselectedColor;
    
    return SizedBox(
      width: 50,
      child: InkWell(
        onTap: () => _onItemTapped(index),
        borderRadius: BorderRadius.circular(8),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon, 
              color: color, 
              size: 22,
            ),
            const SizedBox(height: 3),
            Text(
              label,
              style: TextStyle(
                color: color,
                fontSize: 10,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                letterSpacing: -0.3,
                height: 1.0,
              ),
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.center,
              maxLines: 1,
            ),
          ],
        ),
      ),
    );
  }
}