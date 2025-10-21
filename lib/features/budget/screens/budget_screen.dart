import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:smart_expense_tracker/app/theme/app_theme.dart';
import 'package:smart_expense_tracker/common_widgets/modern_card.dart';
import 'package:smart_expense_tracker/features/budget/screens/add_budget_screen.dart';
import 'package:smart_expense_tracker/models/budget_model.dart';
import 'package:smart_expense_tracker/features/main/screens/main_screen.dart';

class BudgetScreen extends StatefulWidget {
  const BudgetScreen({super.key});

  @override
  State<BudgetScreen> createState() => _BudgetScreenState();
}

class _BudgetScreenState extends State<BudgetScreen> {
  BudgetType _selectedView = BudgetType.monthly;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.offWhite,
      body: Column(
        children: [
          // Enhanced Header Section
          _buildHeaderSection(),
          Expanded(
            child: ValueListenableBuilder<Box<Budget>>(
              valueListenable: Hive.box<Budget>('budgets').listenable(),
              builder: (context, box, _) {
                final now = DateTime.now();
                final budgets = box.values.toList();

                final currentBudgets = budgets.where((budget) {
                  if (budget.budgetType != _selectedView) return false;

                  if (_selectedView == BudgetType.monthly) {
                    return budget.startDate.year == now.year && budget.startDate.month == now.month;
                  } else {
                    return budget.startDate.year == now.year;
                  }
                }).toList();

                if (currentBudgets.isEmpty) {
                  return _buildEmptyState(context);
                }

                final currentBudget = currentBudgets.first;
                final totalSpent = _calculateTotalSpent(currentBudget);

                return ListView(
                  padding: const EdgeInsets.all(20.0),
                  children: [
                    _buildBudgetOverviewCard(currentBudget, totalSpent),
                    const SizedBox(height: 24),
                    _buildCategoryBreakdownSection(currentBudget),
                  ],
                );
              },
            ),
          ),
        ],
      ),
      // Floating Action Button positioned better
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const AddBudgetScreen())),
        backgroundColor: AppTheme.accentOrange,
        foregroundColor: Colors.white,
        elevation: 4,
        icon: Icon(Icons.add_chart_rounded),
        label: Text(
          'Create Budget',
          style: GoogleFonts.poppins(
            fontWeight: FontWeight.w600,
            fontSize: 14,
          ),
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
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
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppTheme.primaryTeal,
            AppTheme.primaryTeal.withOpacity(0.9),
          ],
        ),
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(24),
          bottomRight: Radius.circular(24),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Back Button and Title Row
          Row(
            children: [
              // Fixed Back Button - Navigate to MainScreen with bottom nav
              IconButton(
                onPressed: () {
                  // Navigate to MainScreen which will show Dashboard with bottom nav
                  Navigator.pushAndRemoveUntil(
                    context,
                    MaterialPageRoute(builder: (_) => const MainScreen()),
                        (route) => false,
                  );
                },
                icon: Icon(Icons.arrow_back_rounded, color: Colors.white),
                style: IconButton.styleFrom(
                  backgroundColor: Colors.white.withOpacity(0.2),
                  padding: EdgeInsets.all(8),
                ),
              ),
              SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Budget Planner',
                      style: GoogleFonts.poppins(
                        fontSize: 24,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                        height: 1.2,
                      ),
                    ),
                    SizedBox(height: 4),
                    Text(
                      'Manage your spending and savings',
                      style: GoogleFonts.poppins(
                        fontSize: 14,
                        color: Colors.white.withOpacity(0.8),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          SizedBox(height: 20),

          // Budget Type Toggle - Centered
          Container(
            padding: EdgeInsets.all(4),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.15),
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
            color: isSelected ? Colors.white : Colors.transparent,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Text(
            text,
            textAlign: TextAlign.center,
            style: GoogleFonts.poppins(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: isSelected ? AppTheme.primaryTeal : Colors.white.withOpacity(0.8),
            ),
          ),
        ),
      ),
    );
  }

  // ... (keep all your existing methods below exactly as they are)
  // _buildBudgetOverviewCard, _buildCategoryBreakdownSection, _buildCategoryBudgetCard,
  // _buildEmptyState, _buildEmptyCategoriesState, and all helper methods remain unchanged

  Widget _buildBudgetOverviewCard(Budget budget, double totalSpent) {
    final remaining = budget.totalAmount - totalSpent;
    final percentage = budget.totalAmount > 0 ? (totalSpent / budget.totalAmount) : 0.0;
    final isOverBudget = totalSpent > budget.totalAmount;

    return ModernCard(
      padding: EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'BUDGET OVERVIEW',
                style: GoogleFonts.poppins(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: Colors.grey[600],
                  letterSpacing: 1,
                ),
              ),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: isOverBudget ? Colors.red.withOpacity(0.1) : AppTheme.primaryTeal.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    Icon(
                      isOverBudget ? Icons.warning_amber_rounded : Icons.check_circle_rounded,
                      size: 14,
                      color: isOverBudget ? Colors.red : AppTheme.primaryTeal,
                    ),
                    SizedBox(width: 4),
                    Text(
                      isOverBudget ? 'OVER BUDGET' : 'ON TRACK',
                      style: GoogleFonts.poppins(
                        fontSize: 10,
                        fontWeight: FontWeight.w600,
                        color: isOverBudget ? Colors.red : AppTheme.primaryTeal,
                        letterSpacing: 1,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          SizedBox(height: 20),

          // Budget Amounts
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Remaining',
                      style: GoogleFonts.poppins(
                        fontSize: 14,
                        color: Colors.grey[600],
                      ),
                    ),
                    SizedBox(height: 4),
                    Text(
                      '\$${remaining.toStringAsFixed(2)}',
                      style: GoogleFonts.poppins(
                        fontSize: 32,
                        fontWeight: FontWeight.w800,
                        color: isOverBudget ? Colors.red : AppTheme.primaryTeal,
                        height: 1,
                      ),
                    ),
                  ],
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    'Total Budget',
                    style: GoogleFonts.poppins(
                      fontSize: 14,
                      color: Colors.grey[600],
                    ),
                  ),
                  SizedBox(height: 4),
                  Text(
                    '\$${budget.totalAmount.toStringAsFixed(2)}',
                    style: GoogleFonts.poppins(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      color: AppTheme.darkGrey,
                    ),
                  ),
                ],
              ),
            ],
          ),
          SizedBox(height: 24),

          // Progress Bar
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: LinearProgressIndicator(
              value: percentage.clamp(0.0, 1.0),
              minHeight: 16,
              backgroundColor: isOverBudget ? Colors.red.withOpacity(0.2) : AppTheme.primaryTeal.withOpacity(0.2),
              valueColor: AlwaysStoppedAnimation<Color>(
                isOverBudget ? Colors.red : AppTheme.primaryTeal,
              ),
            ),
          ),
          SizedBox(height: 12),

          // Progress Details
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Spent: \$${totalSpent.toStringAsFixed(2)}',
                style: GoogleFonts.poppins(
                  fontSize: 14,
                  color: Colors.grey[600],
                  fontWeight: FontWeight.w500,
                ),
              ),
              Text(
                '${(percentage * 100).toStringAsFixed(1)}%',
                style: GoogleFonts.poppins(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: isOverBudget ? Colors.red : AppTheme.primaryTeal,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryBreakdownSection(Budget budget) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              "CATEGORY BREAKDOWN",
              style: GoogleFonts.poppins(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: Colors.grey[600],
                letterSpacing: 0.5,
              ),
            ),
            SizedBox(width: 8),
            Container(
              padding: EdgeInsets.symmetric(horizontal: 8, vertical: 2),
              decoration: BoxDecoration(
                color: AppTheme.primaryTeal.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                '${budget.categoryBudgets.length}',
                style: GoogleFonts.poppins(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: AppTheme.primaryTeal,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),

        if (budget.categoryBudgets.isEmpty)
          _buildEmptyCategoriesState()
        else
          ...budget.categoryBudgets.entries.map((entry) {
            final categoryName = entry.key;
            final categoryBudget = entry.value;
            final categorySpent = _calculateCategorySpent(categoryName);
            return _buildCategoryBudgetCard(categoryName, categoryBudget, categorySpent);
          }).toList(),
      ],
    );
  }

  Widget _buildCategoryBudgetCard(String categoryName, double budget, double spent) {
    final percentage = budget > 0 ? (spent / budget) : 0.0;
    final isOverBudget = spent > budget;
    final icon = _getCategoryIcon(categoryName);

    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: ModernCard(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: AppTheme.primaryTeal.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(icon, color: AppTheme.primaryTeal, size: 20),
                ),
                SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        categoryName,
                        style: GoogleFonts.poppins(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: AppTheme.darkGrey,
                        ),
                      ),
                      SizedBox(height: 2),
                      Text(
                        'Category Budget',
                        style: GoogleFonts.poppins(
                          fontSize: 12,
                          color: Colors.grey[500],
                        ),
                      ),
                    ],
                  ),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      '\$${spent.toStringAsFixed(0)}',
                      style: GoogleFonts.poppins(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: isOverBudget ? Colors.red : AppTheme.primaryTeal,
                      ),
                    ),
                    Text(
                      'of \$${budget.toStringAsFixed(0)}',
                      style: GoogleFonts.poppins(
                        fontSize: 12,
                        color: Colors.grey[500],
                      ),
                    ),
                  ],
                ),
              ],
            ),
            SizedBox(height: 12),
            LinearProgressIndicator(
              value: percentage.clamp(0.0, 1.0),
              backgroundColor: isOverBudget ? Colors.red.withOpacity(0.2) : Colors.grey[200],
              valueColor: AlwaysStoppedAnimation<Color>(
                isOverBudget ? Colors.red : AppTheme.accentOrange,
              ),
              borderRadius: BorderRadius.circular(5),
            ),
            SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '${(percentage * 100).toStringAsFixed(1)}% of budget',
                  style: GoogleFonts.poppins(
                    fontSize: 12,
                    color: Colors.grey[500],
                  ),
                ),
                Text(
                  isOverBudget ? 'Over by \$${(spent - budget).toStringAsFixed(2)}' : 'On track',
                  style: GoogleFonts.poppins(
                    fontSize: 12,
                    color: isOverBudget ? Colors.red : Colors.green,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ],
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
          Container(
            width: 140,
            height: 140,
            decoration: BoxDecoration(
              color: Colors.grey[100],
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.analytics_outlined,
              size: 60,
              color: Colors.grey[400],
            ),
          ),
          SizedBox(height: 24),
          Text(
            'No ${_selectedView == BudgetType.monthly ? 'Monthly' : 'Yearly'} Budget',
            style: GoogleFonts.poppins(
              fontSize: 22,
              fontWeight: FontWeight.w700,
              color: Colors.grey[600],
            ),
          ),
          SizedBox(height: 12),
          Text(
            _selectedView == BudgetType.monthly
                ? 'Create your first monthly budget to start tracking expenses and saving money effectively.'
                : 'Plan your annual budget to achieve long-term financial goals and track yearly progress.',
            textAlign: TextAlign.center,
            style: GoogleFonts.poppins(
              fontSize: 16,
              color: Colors.grey[500],
              height: 1.4,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyCategoriesState() {
    return ModernCard(
      padding: EdgeInsets.all(24),
      child: Column(
        children: [
          Icon(Icons.pie_chart_outline_rounded, size: 48, color: Colors.grey[300]),
          SizedBox(height: 16),
          Text(
            'No Category Budgets',
            style: GoogleFonts.poppins(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Colors.grey[500],
            ),
          ),
          SizedBox(height: 8),
          Text(
            'Set individual category budgets for detailed spending control and better insights.',
            textAlign: TextAlign.center,
            style: GoogleFonts.poppins(
              color: Colors.grey[400],
            ),
          ),
        ],
      ),
    );
  }

  // Helper methods
  String _getMonthName(int month) {
    const months = [
      'January', 'February', 'March', 'April', 'May', 'June',
      'July', 'August', 'September', 'October', 'November', 'December'
    ];
    return months[month - 1];
  }

  IconData _getCategoryIcon(String categoryName) {
    final iconMap = {
      'Food': Icons.restaurant_rounded,
      'Food & Drink': Icons.restaurant_rounded,
      'Transport': Icons.directions_car_rounded,
      'Shopping': Icons.shopping_bag_rounded,
      'Entertainment': Icons.movie_rounded,
      'Bills': Icons.receipt_long_rounded,
      'Health': Icons.health_and_safety_rounded,
      'Education': Icons.school_rounded,
    };
    return iconMap[categoryName] ?? Icons.category_rounded;
  }

  double _calculateTotalSpent(Budget budget) => 1231.95; // Placeholder
  double _calculateCategorySpent(String categoryName) => 250.0; // Placeholder
}