import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:smart_expense_tracker/app/theme/app_theme.dart';
import 'package:smart_expense_tracker/common_widgets/themed_background.dart';
import 'package:smart_expense_tracker/models/budget_model.dart';
import 'package:smart_expense_tracker/models/expense_model.dart';
import 'package:smart_expense_tracker/models/category_model.dart';
import 'package:intl/intl.dart';

class BudgetHistoryScreen extends StatefulWidget {
  const BudgetHistoryScreen({super.key});

  @override
  State<BudgetHistoryScreen> createState() => _BudgetHistoryScreenState();
}

class _BudgetHistoryScreenState extends State<BudgetHistoryScreen> {
  BudgetType _selectedView = BudgetType.monthly;

  @override
  Widget build(BuildContext context) {
    return ThemedBackground(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: Column(
          children: [
            _buildHeaderSection(),
            Expanded(
            child: ValueListenableBuilder<Box<Budget>>(
              valueListenable: Hive.box<Budget>('budgets').listenable(),
              builder: (context, box, _) {
                final allBudgets = box.values.toList();
                
                // Filter budgets by type
                final filteredBudgets = allBudgets
                    .where((b) => b.budgetType == _selectedView)
                    .toList();
                
                // Sort by date (most recent first)
                filteredBudgets.sort((a, b) => b.startDate.compareTo(a.startDate));

                if (filteredBudgets.isEmpty) {
                  return _buildEmptyState();
                }

                return ValueListenableBuilder<Box<Expense>>(
                  valueListenable: Hive.box<Expense>('expenses').listenable(),
                  builder: (context, expenseBox, _) {
                    final allExpenses = expenseBox.values.toList();
                    
                    return ListView.builder(
                      padding: const EdgeInsets.all(20),
                      itemCount: filteredBudgets.length,
                      itemBuilder: (context, index) {
                        final budget = filteredBudgets[index];
                        final periodExpenses = _getExpensesForBudget(budget, allExpenses);
                        final totalSpent = periodExpenses.fold<double>(
                          0.0,
                          (sum, expense) => sum + expense.amount,
                        );
                        
                        return _buildBudgetCard(budget, totalSpent, periodExpenses);
                      },
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    ),
    );
  }

    Widget _buildHeaderSection() {
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
          Row(
            children: [
              Container(
                decoration: BoxDecoration(
                  color: AppTheme.getHeaderIconBackground(context),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: Icon(
                    Icons.arrow_back_rounded, 
                    color: AppTheme.getHeaderTextColor(context)
                  ),
                  style: IconButton.styleFrom(padding: EdgeInsets.all(8)),
                ),
              ),
              SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Budget History',
                      style: GoogleFonts.poppins(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: AppTheme.getHeaderTextColor(context),
                      ),
                    ),
                    SizedBox(height: 4),
                    Text(
                      'Track your budget performance',
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
          SizedBox(height: 20),
          Container(
            padding: EdgeInsets.all(4),
            decoration: BoxDecoration(
              color: AppTheme.getHeaderIconBackground(context),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                _buildViewToggle('Monthly', BudgetType.monthly),
                SizedBox(width: 4),
                _buildViewToggle('Yearly', BudgetType.yearly),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildViewToggle(String text, BudgetType type) {
    final isSelected = _selectedView == type;
    final headerTextColor = AppTheme.getHeaderTextColor(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return Expanded(
      child: GestureDetector(
        onTap: () {
          setState(() {
            _selectedView = type;
          });
        },
        child: Container(
          padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
          decoration: BoxDecoration(
            color: isSelected 
              ? Colors.white.withValues(alpha: isDark ? 0.15 : 0.9) 
              : Colors.transparent,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Text(
            text,
            textAlign: TextAlign.center,
            style: GoogleFonts.poppins(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: isSelected 
                ? (isDark ? AppTheme.darkPrimaryTeal : AppTheme.primaryTeal)
                : Colors.white.withValues(alpha: 0.8),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildBudgetCard(Budget budget, double totalSpent, List<Expense> expenses) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final remaining = budget.totalAmount - totalSpent;
    final percentage = budget.totalAmount > 0 ? (totalSpent / budget.totalAmount) : 0.0;
    final isOverBudget = totalSpent > budget.totalAmount;
    
    final dateFormatter = DateFormat('MMMM yyyy');
    final yearFormatter = DateFormat('yyyy');
    
    final periodLabel = budget.budgetType == BudgetType.monthly
        ? dateFormatter.format(budget.month)
        : 'Year ${yearFormatter.format(budget.startDate)}';

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: isDark
              ? [AppTheme.darkCard, AppTheme.darkCard]
              : [Colors.white, Colors.grey.shade50],
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isOverBudget 
              ? Colors.red.withOpacity(0.3)
              : AppTheme.getPrimaryTealColor(context).withOpacity(0.2),
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: isOverBudget
                ? Colors.red.withOpacity(isDark ? 0.2 : 0.1)
                : AppTheme.getPrimaryTealColor(context).withOpacity(isDark ? 0.2 : 0.08),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(20),
          onTap: () => _showBudgetDetails(budget, totalSpent, expenses, isDark),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        periodLabel,
                        style: GoogleFonts.poppins(
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                          color: isDark ? Colors.white : AppTheme.darkGrey,
                        ),
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
                      decoration: BoxDecoration(
                        color: isOverBudget ? Colors.red : AppTheme.successGreen,
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [
                          BoxShadow(
                            color: (isOverBudget ? Colors.red : AppTheme.successGreen)
                                .withOpacity(0.3),
                            blurRadius: 8,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            isOverBudget ? Icons.warning_rounded : Icons.check_circle_rounded,
                            size: 14,
                            color: Colors.white,
                          ),
                          const SizedBox(width: 6),
                          Text(
                            isOverBudget ? 'OVER BUDGET' : 'ON TRACK',
                            style: GoogleFonts.poppins(
                              fontSize: 10,
                              fontWeight: FontWeight.w700,
                              color: Colors.white,
                              letterSpacing: 1,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                // Stat Cards Row
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Container(
                        height: 70,
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: AppTheme.getPrimaryTealColor(context).withOpacity(isDark ? 0.15 : 0.08),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: AppTheme.getPrimaryTealColor(context).withOpacity(0.2),
                          ),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Row(
                              children: [
                                Icon(
                                  Icons.account_balance_wallet_rounded,
                                  size: 14,
                                  color: AppTheme.getPrimaryTealColor(context),
                                ),
                                const SizedBox(width: 4),
                                Flexible(
                                  child: Text(
                                    'Budget',
                                    style: GoogleFonts.poppins(
                                      fontSize: 11,
                                      fontWeight: FontWeight.w600,
                                      color: AppTheme.getPrimaryTealColor(context),
                                    ),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              ],
                            ),
                            FittedBox(
                              fit: BoxFit.scaleDown,
                              child: Text(
                                '\$${budget.totalAmount.toStringAsFixed(2)}',
                                style: GoogleFonts.poppins(
                                  fontSize: 18,
                                  fontWeight: FontWeight.w700,
                                  color: isDark ? Colors.white : AppTheme.darkGrey,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Container(
                        height: 70,
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: (isOverBudget ? Colors.red : AppTheme.accentOrange)
                              .withOpacity(isDark ? 0.15 : 0.08),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: (isOverBudget ? Colors.red : AppTheme.accentOrange)
                                .withOpacity(0.2),
                          ),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Row(
                              children: [
                                Icon(
                                  Icons.trending_up_rounded,
                                  size: 14,
                                  color: isOverBudget ? Colors.red : AppTheme.accentOrange,
                                ),
                                const SizedBox(width: 4),
                                Flexible(
                                  child: Text(
                                    'Spent',
                                    style: GoogleFonts.poppins(
                                      fontSize: 11,
                                      fontWeight: FontWeight.w600,
                                      color: isOverBudget ? Colors.red : AppTheme.accentOrange,
                                    ),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              ],
                            ),
                            FittedBox(
                              fit: BoxFit.scaleDown,
                              child: Text(
                                '\$${totalSpent.toStringAsFixed(2)}',
                                style: GoogleFonts.poppins(
                                  fontSize: 18,
                                  fontWeight: FontWeight.w700,
                                  color: isOverBudget ? Colors.red : AppTheme.accentOrange,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Container(
                        height: 70,
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: (isOverBudget ? Colors.red : AppTheme.successGreen)
                              .withOpacity(isDark ? 0.15 : 0.08),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: (isOverBudget ? Colors.red : AppTheme.successGreen)
                                .withOpacity(0.2),
                          ),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Row(
                              children: [
                                Icon(
                                  isOverBudget ? Icons.warning_rounded : Icons.savings_rounded,
                                  size: 14,
                                  color: isOverBudget ? Colors.red : AppTheme.successGreen,
                                ),
                                const SizedBox(width: 4),
                                Flexible(
                                  child: Text(
                                    isOverBudget ? 'Over' : 'Left',
                                    style: GoogleFonts.poppins(
                                      fontSize: 11,
                                      fontWeight: FontWeight.w600,
                                      color: isOverBudget ? Colors.red : AppTheme.successGreen,
                                    ),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              ],
                            ),
                            FittedBox(
                              fit: BoxFit.scaleDown,
                              child: Text(
                                '\$${remaining.abs().toStringAsFixed(2)}',
                                style: GoogleFonts.poppins(
                                  fontSize: 18,
                                  fontWeight: FontWeight.w700,
                                  color: isOverBudget ? Colors.red : AppTheme.successGreen,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                // Progress Bar
                ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: LinearProgressIndicator(
                    value: percentage.clamp(0.0, 1.0),
                    minHeight: 8,
                    backgroundColor: isDark 
                        ? Colors.grey.shade800
                        : Colors.grey.shade200,
                    valueColor: AlwaysStoppedAnimation<Color>(
                      isOverBudget ? Colors.red : AppTheme.getPrimaryTealColor(context),
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: (isOverBudget ? Colors.red : AppTheme.getPrimaryTealColor(context))
                            .withOpacity(isDark ? 0.2 : 0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        '${(percentage * 100).toStringAsFixed(1)}% used',
                        style: GoogleFonts.poppins(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: isOverBudget ? Colors.red : AppTheme.getPrimaryTealColor(context),
                        ),
                      ),
                    ),
                    Row(
                      children: [
                        Icon(
                          Icons.touch_app_rounded,
                          size: 14,
                          color: isDark ? Colors.white38 : Colors.grey[400],
                        ),
                        const SizedBox(width: 4),
                        Text(
                          'Tap for details',
                          style: GoogleFonts.poppins(
                            fontSize: 11,
                            color: isDark ? Colors.white38 : Colors.grey[500],
                            fontStyle: FontStyle.italic,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _showBudgetDetails(Budget budget, double totalSpent, List<Expense> expenses, bool isDark) {
    final remaining = budget.totalAmount - totalSpent;
    final percentage = budget.totalAmount > 0 ? (totalSpent / budget.totalAmount) : 0.0;
    final isOverBudget = totalSpent > budget.totalAmount;
    
    final dateFormatter = DateFormat('MMMM yyyy');
    final yearFormatter = DateFormat('yyyy');
    final periodLabel = budget.budgetType == BudgetType.monthly
        ? dateFormatter.format(budget.month)
        : 'Year ${yearFormatter.format(budget.startDate)}';
    
    showModalBottomSheet(
      context: this.context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.8,
        minChildSize: 0.5,
        maxChildSize: 0.95,
        builder: (context, scrollController) {
          return Container(
            decoration: BoxDecoration(
              color: isDark ? AppTheme.darkSurface : Colors.white,
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(28),
                topRight: Radius.circular(28),
              ),
            ),
            child: Column(
              children: [
                // Drag Handle
                Container(
                  margin: const EdgeInsets.only(top: 12),
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: isDark ? Colors.white24 : Colors.grey[300],
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                // Header with glassmorphic design
                Container(
                  margin: const EdgeInsets.all(20),
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: isDark 
                      ? Colors.white.withValues(alpha: 0.05)
                      : Colors.white.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: isDark 
                        ? Colors.white.withValues(alpha: 0.1)
                        : Colors.white.withValues(alpha: 0.2),
                      width: 1,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: isDark ? 0.3 : 0.1),
                        blurRadius: 20,
                        offset: const Offset(0, 8),
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              color: AppTheme.getPrimaryTealColor(context).withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: AppTheme.getPrimaryTealColor(context).withValues(alpha: 0.3),
                                width: 1,
                              ),
                            ),
                            child: Icon(
                              Icons.analytics_rounded, 
                              color: AppTheme.getPrimaryTealColor(context), 
                              size: 24
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              'Budget Overview',
                              style: GoogleFonts.poppins(
                                fontSize: 20,
                                fontWeight: FontWeight.w700,
                                color: isDark ? Colors.white : AppTheme.darkGrey,
                              ),
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                            decoration: BoxDecoration(
                              color: isOverBudget 
                                  ? Colors.red.withValues(alpha: 0.2)
                                  : AppTheme.successGreen.withValues(alpha: 0.2),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: isOverBudget 
                                  ? Colors.red.withValues(alpha: 0.5)
                                  : AppTheme.successGreen.withValues(alpha: 0.5),
                                width: 1,
                              ),
                            ),
                            child: Text(
                              isOverBudget ? 'OVER' : 'ON TRACK',
                              style: GoogleFonts.poppins(
                                fontSize: 10,
                                fontWeight: FontWeight.w700,
                                color: isOverBudget ? Colors.red : AppTheme.successGreen,
                                letterSpacing: 1,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),
                      // Stats Cards
                      Row(
                        children: [
                          Expanded(
                            child: _buildStatCard(
                              'Budget',
                              '\$${budget.totalAmount.toStringAsFixed(2)}',
                              Icons.account_balance_wallet_rounded,
                              AppTheme.primaryTeal, // Budget - Teal
                              isDark,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: _buildStatCard(
                              'Spent',
                              '\$${totalSpent.toStringAsFixed(2)}',
                              Icons.trending_up_rounded,
                              AppTheme.accentOrange, // Spent - Orange
                              isDark,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: _buildStatCard(
                              isOverBudget ? 'Over' : 'Left',
                              '\$${remaining.abs().toStringAsFixed(2)}',
                              isOverBudget ? Icons.warning_rounded : Icons.savings_rounded,
                              isOverBudget ? Colors.red : Colors.green, // Over - Red, Left - Green
                              isDark,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      // Progress Bar
                      ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: LinearProgressIndicator(
                          value: percentage.clamp(0.0, 1.0),
                          minHeight: 8,
                          backgroundColor: isDark 
                            ? Colors.white.withValues(alpha: 0.1)
                            : Colors.grey.withValues(alpha: 0.2),
                          valueColor: AlwaysStoppedAnimation<Color>(
                            isOverBudget ? Colors.red : AppTheme.getPrimaryTealColor(context),
                          ),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        '${(percentage * 100).toStringAsFixed(1)}% of budget used',
                        style: GoogleFonts.poppins(
                          fontSize: 12,
                          color: isDark ? Colors.white70 : Colors.grey[600],
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
                // Expenses Section
                Expanded(
                  child: ListView(
                    controller: scrollController,
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'EXPENSES',
                            style: GoogleFonts.poppins(
                              fontSize: 12,
                              fontWeight: FontWeight.w700,
                              color: isDark ? Colors.white60 : Colors.grey[600],
                              letterSpacing: 1.2,
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                            decoration: BoxDecoration(
                              color: AppTheme.getPrimaryTealColor(context).withOpacity(0.1),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              '${expenses.length} items',
                              style: GoogleFonts.poppins(
                                fontSize: 11,
                                fontWeight: FontWeight.w600,
                                color: AppTheme.getPrimaryTealColor(context),
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      if (expenses.isEmpty)
                        Center(
                          child: Padding(
                            padding: const EdgeInsets.all(40),
                            child: Column(
                              children: [
                                Icon(
                                  Icons.receipt_long_rounded,
                                  size: 64,
                                  color: isDark ? Colors.white24 : Colors.grey[300],
                                ),
                                const SizedBox(height: 16),
                                Text(
                                  'No expenses recorded',
                                  style: GoogleFonts.poppins(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                    color: isDark ? Colors.white60 : Colors.grey[600],
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  'Start tracking your spending',
                                  style: GoogleFonts.poppins(
                                    fontSize: 14,
                                    color: isDark ? Colors.white38 : Colors.grey[400],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        )
                      else
                        ...expenses.map((expense) => _buildExpenseItem(expense, isDark)),
                      const SizedBox(height: 20),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildStatCard(String label, String value, IconData icon, Color accentColor, bool isDark) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: accentColor.withValues(alpha: isDark ? 0.15 : 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: accentColor.withValues(alpha: 0.3),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            icon, 
            color: accentColor, 
            size: 16
          ),
          const SizedBox(height: 8),
          FittedBox(
            fit: BoxFit.scaleDown,
            child: Text(
              value,
              style: GoogleFonts.poppins(
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: isDark ? Colors.white : AppTheme.darkGrey,
              ),
            ),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: GoogleFonts.poppins(
              fontSize: 10,
              fontWeight: FontWeight.w600,
              color: accentColor.withValues(alpha: 0.8),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailRow(String label, String value, bool isDark) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: GoogleFonts.poppins(
              fontSize: 14,
              color: isDark ? Colors.white70 : Colors.grey[700],
            ),
          ),
          Text(
            value,
            style: GoogleFonts.poppins(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: isDark ? Colors.white : AppTheme.darkGrey,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildExpenseItem(Expense expense, bool isDark) {
    final category = _getCategoryByName(expense.category);
    final categoryIcon = category != null
        ? IconData(int.parse(category.icon), fontFamily: 'MaterialIcons')
        : Icons.category_rounded;
    final categoryColor = category != null ? Color(category.color) : AppTheme.getPrimaryTealColor(context);

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: isDark ? AppTheme.darkCard : Colors.grey[50],
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: categoryColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(categoryIcon, color: categoryColor, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  expense.description,
                  style: GoogleFonts.poppins(
                    fontWeight: FontWeight.w600,
                    color: isDark ? Colors.white : AppTheme.darkGrey,
                  ),
                ),
                Text(
                  DateFormat('MMM dd, yyyy').format(expense.date),
                  style: GoogleFonts.poppins(
                    fontSize: 12,
                    color: isDark ? Colors.white60 : Colors.grey[600],
                  ),
                ),
              ],
            ),
          ),
          Text(
            '\$${expense.amount.toStringAsFixed(2)}',
            style: GoogleFonts.poppins(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: isDark ? Colors.white : AppTheme.darkGrey,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.history_rounded,
            size: 80,
            color: isDark ? Colors.white24 : Colors.grey[300],
          ),
          const SizedBox(height: 16),
          Text(
            'No Budget History',
            style: GoogleFonts.poppins(
              fontSize: 20,
              fontWeight: FontWeight.w600,
              color: isDark ? Colors.white60 : Colors.grey[600],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Start by creating your first budget',
            style: GoogleFonts.poppins(
              color: isDark ? Colors.white38 : Colors.grey[400],
            ),
          ),
        ],
      ),
    );
  }

  List<Expense> _getExpensesForBudget(Budget budget, List<Expense> allExpenses) {
    if (budget.budgetType == BudgetType.monthly) {
      return allExpenses.where((expense) {
        return expense.date.year == budget.month.year &&
            expense.date.month == budget.month.month;
      }).toList();
    } else {
      return allExpenses.where((expense) {
        return expense.date.year == budget.startDate.year;
      }).toList();
    }
  }

  Category? _getCategoryByName(String name) {
    final categoryBox = Hive.box<Category>('categories');
    try {
      return categoryBox.values.firstWhere((cat) => cat.name == name);
    } catch (e) {
      return null;
    }
  }
}
