import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:provider/provider.dart';
import 'package:smart_expense_tracker/app/theme/app_theme.dart';
import 'package:smart_expense_tracker/common_widgets/themed_background.dart';
import 'package:smart_expense_tracker/common_widgets/glassmorphic_card.dart';
import 'package:smart_expense_tracker/features/main/screens/main_screen.dart';
import 'package:smart_expense_tracker/features/expenses/widgets/expense_list_item.dart';
import 'package:smart_expense_tracker/models/expense_model.dart';
import 'package:smart_expense_tracker/services/firebase_auth_service.dart';

class ExpenseHistoryScreen extends StatefulWidget {
  const ExpenseHistoryScreen({super.key});

  @override
  State<ExpenseHistoryScreen> createState() => _ExpenseHistoryScreenState();
}

class _ExpenseHistoryScreenState extends State<ExpenseHistoryScreen> with SingleTickerProviderStateMixin {
  ExpenseFilter _selectedFilter = ExpenseFilter.all;
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 800),
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );
    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ThemedBackground(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: Column(
          children: [
            ValueListenableBuilder<Box<Expense>>(
              valueListenable: Hive.box<Expense>('expenses').listenable(),
              builder: (context, box, _) {
                // Get current user ID and filter expenses
                final currentUserId = context.read<AuthService>().currentUser?.uid;
                final allExpenses = box.values
                    .where((expense) => expense.userId == currentUserId)
                    .toList()
                    .cast<Expense>();
                    
                final totalExpenses = allExpenses.length;
                final now = DateTime.now();
                final todayExpenses = allExpenses.where((expense) =>
                expense.date.year == now.year &&
                    expense.date.month == now.month &&
                    expense.date.day == now.day).length;
                final totalAmount = allExpenses.fold(0.0, (sum, expense) => sum + expense.amount);

                return _buildHeaderSection(totalExpenses, todayExpenses, totalAmount);
              },
            ),
            Expanded(
              child: ValueListenableBuilder<Box<Expense>>(
                valueListenable: Hive.box<Expense>('expenses').listenable(),
                builder: (context, box, _) {
                  // Get current user ID and filter expenses
                  final currentUserId = context.read<AuthService>().currentUser?.uid;
                  final allExpenses = box.values
                      .where((expense) => expense.userId == currentUserId)
                      .toList()
                      .cast<Expense>();

                  // Sort expenses by date (newest first)
                  allExpenses.sort((a, b) => b.date.compareTo(a.date));

                  // Apply filter based on _selectedFilter
                  final filteredExpenses = _filterExpenses(allExpenses);

                  // Calculate stats based on allExpenses
                  final totalExpenses = allExpenses.length;
                  final now = DateTime.now();
                  final todayExpensesCount = allExpenses.where((expense) =>
                  expense.date.year == now.year &&
                      expense.date.month == now.month &&
                      expense.date.day == now.day).length;
                  final totalAmount = allExpenses.fold(0.0, (sum, expense) => sum + expense.amount);

                  return AnimatedBuilder(
                    animation: _fadeAnimation,
                    builder: (context, child) {
                      return Opacity(
                        opacity: _fadeAnimation.value,
                        child: child,
                      );
                    },
                    child: filteredExpenses.isEmpty
                        ? _buildEmptyState(context)
                        : _buildExpensesList(context, filteredExpenses, totalExpenses, todayExpensesCount, totalAmount),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeaderSection(int totalExpenses, int todayExpenses, double totalAmount) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.only(
        top: MediaQuery.of(context).padding.top + 16,
        bottom: 24,
        left: 20,
        right: 20,
      ),
      decoration: AppTheme.getGlassmorphicHeaderDecoration(context),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Back Button and Title Row
          Row(
            children: [
              Container(
                decoration: BoxDecoration(
                  color: AppTheme.getHeaderIconBackground(context),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: IconButton(
                  onPressed: () {
                    Navigator.pushAndRemoveUntil(
                      context,
                      MaterialPageRoute(builder: (_) => const MainScreen()),
                          (route) => false,
                    );
                  },
                  icon: Icon(
                    Icons.arrow_back_rounded, 
                    color: AppTheme.getHeaderTextColor(context)
                  ),
                  style: IconButton.styleFrom(padding: EdgeInsets.all(8)),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Expense History',
                      style: GoogleFonts.poppins(
                        fontSize: 24,
                        fontWeight: FontWeight.w700,
                        color: AppTheme.getHeaderTextColor(context),
                        height: 1.2,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Track and manage your spending history',
                      style: GoogleFonts.poppins(
                        fontSize: 14,
                        color: AppTheme.getHeaderTextColor(context).withValues(alpha: 0.8),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),

          // Expense Stats
          _buildExpenseStats(context, totalExpenses, todayExpenses, totalAmount),
          const SizedBox(height: 16),

          // Filter Toggle
          Container(
            padding: const EdgeInsets.all(4),
            decoration: BoxDecoration(
              color: AppTheme.getHeaderIconBackground(context),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                _buildFilterToggle(context, 'All', ExpenseFilter.all),
                const SizedBox(width: 4),
                _buildFilterToggle(context, 'Today', ExpenseFilter.today),
                const SizedBox(width: 4),
                _buildFilterToggle(context, 'This Week', ExpenseFilter.week),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildExpenseStats(BuildContext context, int totalExpenses, int todayExpenses, double totalAmount) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: [
        _buildStatItem(context, totalExpenses.toString(), 'Total Items', Icons.receipt_long_rounded),
        _buildStatItem(context, todayExpenses.toString(), 'Today\'s Items', Icons.today_rounded),
        _buildStatItem(context, '\$${totalAmount.toStringAsFixed(0)}', 'Total Spent', Icons.savings_rounded),
      ],
    );
  }

  Widget _buildStatItem(BuildContext context, String value, String label, IconData icon) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: AppTheme.getHeaderIconBackground(context),
            shape: BoxShape.circle,
            border: Border.all(
              color: AppTheme.getHeaderTextColor(context).withValues(alpha: 0.2),
              width: 1,
            ),
          ),
          child: Icon(
            icon, 
            size: 20, 
            color: AppTheme.getHeaderTextColor(context)
          ),
        ),
        const SizedBox(height: 6),
        Text(
          value,
          style: GoogleFonts.poppins(
            fontSize: 16,
            fontWeight: FontWeight.w700,
            color: Colors.white,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          label,
          style: GoogleFonts.poppins(
            fontSize: 12,
            color: AppTheme.getHeaderTextColor(context).withValues(alpha: 0.8),
          ),
        ),
      ],
    );
  }

  Widget _buildFilterToggle(BuildContext context, String text, ExpenseFilter filter) {
    final isSelected = _selectedFilter == filter;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return Expanded(
      child: GestureDetector(
        onTap: () {
          setState(() {
            _selectedFilter = filter;
          });
        },
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          decoration: BoxDecoration(
            color: isSelected 
              ? Colors.white.withValues(alpha: isDark ? 0.9 : 1.0)
              : Colors.transparent,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Text(
            text,
            textAlign: TextAlign.center,
            style: GoogleFonts.poppins(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: isSelected 
                ? (isDark ? AppTheme.darkPrimaryTeal : AppTheme.primaryTeal)
                : AppTheme.getHeaderTextColor(context).withValues(alpha: 0.8),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(32.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          AnimatedContainer(
            duration: Duration(milliseconds: 500),
            width: 160,
            height: 160,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [AppTheme.getSurfaceColor(context), AppTheme.getSurfaceColor(context).withOpacity(0.8)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: AppTheme.getSecondaryTextColor(context).withOpacity(0.2),
                  blurRadius: 15,
                  offset: Offset(0, 4),
                ),
              ],
            ),
            child: Icon(
              Icons.receipt_long_rounded,
              size: 70,
              color: AppTheme.getSecondaryTextColor(context),
            ),
          ),
          SizedBox(height: 32),
          Text(
            'No Expenses Yet 📭',
            style: GoogleFonts.poppins(
              fontSize: 24,
              fontWeight: FontWeight.w700,
              color: AppTheme.getTextColor(context),
            ),
          ),
          SizedBox(height: 12),
          Text(
            'Your expense history will appear here\nStart tracking to see the magic! ✨',
            textAlign: TextAlign.center,
            style: GoogleFonts.poppins(
              fontSize: 16,
              color: AppTheme.getSecondaryTextColor(context),
              height: 1.4,
            ),
          ),
          SizedBox(height: 32),
          AnimatedContainer(
            duration: Duration(milliseconds: 400),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [AppTheme.getAccentColor(context), AppTheme.getAccentColor(context).withOpacity(0.8)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: AppTheme.getAccentColor(context).withOpacity(0.4),
                  blurRadius: 10,
                  offset: Offset(0, 4),
                ),
              ],
            ),
            child: ElevatedButton.icon(
              onPressed: () {
                Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(builder: (_) => const MainScreen()),
                      (route) => false,
                );
              },
              icon: Icon(Icons.add_rounded, size: 20, color: Colors.white),
              label: Text(
                'Add Your First Expense 🚀',
                style: GoogleFonts.poppins(
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.transparent,
                shadowColor: Colors.transparent,
                padding: EdgeInsets.symmetric(horizontal: 24, vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildExpensesList(BuildContext context, List<Expense> filteredExpenses, int totalExpenses, int todayExpensesCount, double totalAmount) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return ListView(
      padding: EdgeInsets.all(20),
      children: [
        GlassmorphicCard(
          blur: 15,
          opacity: isDark ? 0.08 : 0.5,
          child: Padding(
            padding: EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'EXPENSES OVERVIEW 📊',
                      style: GoogleFonts.poppins(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: isDark 
                          ? AppTheme.getHeaderTextColor(context)
                          : AppTheme.getTextColor(context),
                        letterSpacing: 1,
                      ),
                    ),
                    Container(
                      padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [AppTheme.accentOrange, Color(0xFFFF8A50)],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [
                          BoxShadow(
                            color: AppTheme.accentOrange.withOpacity(0.3),
                            blurRadius: 8,
                            offset: Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Row(
                        children: [
                          Icon(
                            Icons.trending_up_rounded,
                            size: 14,
                            color: Colors.white,
                          ),
                          SizedBox(width: 4),
                          Text(
                            '${filteredExpenses.length} ${ _selectedFilter == ExpenseFilter.all ? 'ITEMS' : _selectedFilter == ExpenseFilter.today ? 'TODAY' : 'THIS WEEK'}',
                            style: GoogleFonts.poppins(
                              fontSize: 10,
                              fontWeight: FontWeight.w600,
                              color: Colors.white,
                              letterSpacing: 1,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 16),
                Row(
                  children: [
                    _buildSummaryItem(totalExpenses.toString(), 'Total Items', Icons.receipt_long_rounded),
                    _buildSummaryItem(
                      todayExpensesCount.toString(),
                      'Today\'s Items',
                      Icons.today_rounded,
                    ),
                    _buildSummaryItem(
                      '\$${totalAmount.toStringAsFixed(0)}',
                      'Total Spent',
                      Icons.attach_money_rounded,
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
        SizedBox(height: 24),
        Container(
          padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            color: Theme.of(context).brightness == Brightness.dark
                ? AppTheme.primaryTeal.withOpacity(0.05)
                : AppTheme.primaryTeal.withOpacity(0.15),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: Theme.of(context).brightness == Brightness.dark
                  ? AppTheme.primaryTeal.withOpacity(0.1)
                  : AppTheme.primaryTeal.withOpacity(0.3),
            ),
          ),
          child: Row(
            children: [
              Icon(
                Icons.history_rounded, 
                color: AppTheme.getPrimaryColor(context), 
                size: 20
              ),
              SizedBox(width: 8),
              Text(
                _selectedFilter == ExpenseFilter.all ? 'ALL EXPENSES' : _selectedFilter == ExpenseFilter.today ? 'TODAY\'S EXPENSES' : 'THIS WEEK\'S EXPENSES',
                style: GoogleFonts.poppins(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: AppTheme.getPrimaryColor(context),
                  letterSpacing: 0.5,
                ),
              ),
              SizedBox(width: 8),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: AppTheme.getPrimaryColor(context).withOpacity(0.15),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  '${filteredExpenses.length}',
                  style: GoogleFonts.poppins(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: AppTheme.getPrimaryColor(context),
                  ),
                ),
              ),
            ],
          ),
        ),
        SizedBox(height: 16),
        ...filteredExpenses.asMap().entries.map((entry) {
          final index = entry.key;
          final expense = entry.value;
          return AnimatedContainer(
            duration: Duration(milliseconds: 300 + (index * 100)),
            curve: Curves.easeOutBack,
            margin: EdgeInsets.only(bottom: 12),
            child: ExpenseListItem(expense: expense),
          );
        }).toList(),
      ],
    );
  }

  Widget _buildSummaryItem(String value, String label, IconData icon) {
    return Expanded(
      child: Column(
        children: [
          Container(
            padding: EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: AppTheme.getPrimaryColor(context).withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              icon, 
              size: 18, 
              color: AppTheme.getPrimaryColor(context),
            ),
          ),
          SizedBox(height: 8),
          Text(
            value,
            style: GoogleFonts.poppins(
              fontSize: 20,
              fontWeight: FontWeight.w700,
              color: AppTheme.getPrimaryColor(context), // Use theme-aware teal color
            ),
          ),
          SizedBox(height: 4),
          Text(
            label,
            style: GoogleFonts.poppins(
              fontSize: 11,
              color: AppTheme.getSecondaryTextColor(context),
            ),
          ),
        ],
      ),
    );
  }

  List<Expense> _filterExpenses(List<Expense> allExpenses) {
    final now = DateTime.now();
    switch (_selectedFilter) {
      case ExpenseFilter.today:
        return allExpenses.where((expense) =>
        expense.date.year == now.year &&
            expense.date.month == now.month &&
            expense.date.day == now.day).toList();
      case ExpenseFilter.week:
        final startOfWeek = now.subtract(Duration(days: now.weekday - 1));
        return allExpenses.where((expense) {
          return !expense.date.isBefore(DateTime(startOfWeek.year, startOfWeek.month, startOfWeek.day)) &&
              !expense.date.isAfter(now);
        }).toList();
      case ExpenseFilter.all:
      default:
        return allExpenses;
    }
  }
}

enum ExpenseFilter { all, today, week }