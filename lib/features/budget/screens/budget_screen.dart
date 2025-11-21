import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:provider/provider.dart';
import 'package:smart_expense_tracker/app/theme/app_theme.dart';
import 'package:smart_expense_tracker/common_widgets/modern_card.dart';
import 'package:smart_expense_tracker/common_widgets/primary_button.dart';
import 'package:smart_expense_tracker/common_widgets/themed_background.dart';
import 'package:smart_expense_tracker/models/budget_model.dart';
import 'package:smart_expense_tracker/features/main/screens/main_screen.dart';
import 'package:smart_expense_tracker/models/expense_model.dart';
import 'package:smart_expense_tracker/models/category_model.dart';
import 'package:smart_expense_tracker/features/budget/screens/add_budget_screen.dart';
import 'package:smart_expense_tracker/features/budget/screens/edit_budget_screen.dart';
import 'package:smart_expense_tracker/features/budget/screens/add_category_budget_screen.dart';
import 'package:smart_expense_tracker/features/budget/screens/budget_history_screen.dart';
import 'package:smart_expense_tracker/services/firebase_auth_service.dart';

class BudgetScreen extends StatefulWidget {
  const BudgetScreen({super.key});

  @override
  State<BudgetScreen> createState() => _BudgetScreenState();
}

class _BudgetScreenState extends State<BudgetScreen> {
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
                // Get current user ID
                final currentUserId = context.read<AuthService>().currentUser?.uid;
                
                if (currentUserId == null) {
                  return _buildEmptyState(context);
                }
                
                final now = DateTime.now();
                final budgets = box.values.toList();

                // Filter budgets by current user
                final userBudgets = budgets.where((budget) => budget.userId == currentUserId).toList();

                // DEBUG: Print all budgets
                print('🔍 DEBUG: Total budgets in Hive: ${budgets.length}');
                print('🔍 DEBUG: User budgets: ${userBudgets.length} for user $currentUserId');
                for (var budget in userBudgets) {
                  print('   📊 Budget: ${budget.id} | Type: ${budget.budgetType} | Month: ${budget.month} | StartDate: ${budget.startDate}');
                }

                // Unified filtering for monthly and yearly
                List<Budget> currentBudgets;
                if (_selectedView == BudgetType.monthly) {
                  currentBudgets = userBudgets.where((budget) {
                    return budget.budgetType == BudgetType.monthly && budget.month.year == now.year && budget.month.month == now.month;
                  }).toList();
                  // Sort by startDate to get the most recent budget
                  if (currentBudgets.isNotEmpty) {
                    currentBudgets.sort((a, b) => b.startDate.compareTo(a.startDate)); // latest first
                    currentBudgets = [currentBudgets.first];
                  }
                } else {
                  // Yearly: filter for current year, then pick the latest by startDate
                  final yearlyBudgets = userBudgets.where((budget) {
                    return budget.budgetType == BudgetType.yearly && budget.startDate.year == now.year;
                  }).toList();
                  if (yearlyBudgets.isNotEmpty) {
                    yearlyBudgets.sort((a, b) => b.startDate.compareTo(a.startDate)); // latest first
                    currentBudgets = [yearlyBudgets.first];
                  } else {
                    currentBudgets = [];
                  }
                }

                if (currentBudgets.isEmpty) {
                  return _buildEmptyState(context);
                }

                final currentBudget = currentBudgets.first;

                return ValueListenableBuilder<Box<Expense>>(
                  valueListenable: Hive.box<Expense>('expenses').listenable(),
                  builder: (context, expenseBox, _) {
                    // Filter expenses by current user
                    final allExpenses = expenseBox.values
                        .where((expense) => expense.userId == currentUserId)
                        .toList()
                        .cast<Expense>();
                    final totalSpent = _calculateTotalSpent(currentBudget, allExpenses);
                    final periodExpenses = _getExpensesForBudget(currentBudget, allExpenses);

                    // Always use the same UI for both views
                    return ListView(
                      padding: const EdgeInsets.all(20.0),
                      children: [
                        _buildBudgetOverviewCard(currentBudget, totalSpent, box),
                        const SizedBox(height: 24),
                        _buildCategoryBreakdownSection(currentBudget, periodExpenses, box),
                      ],
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
          heroTag: 'budget_fab', // Unique tag to avoid Hero conflicts
          onPressed: () => _showBudgetOptions(context),
          backgroundColor: AppTheme.getAccentColor(context),
          foregroundColor: Colors.white,
          elevation: 4,
          icon: const Icon(Icons.add_rounded),
          label: Text(
            'Add Budget',
            style: GoogleFonts.poppins(
              fontWeight: FontWeight.w600,
              fontSize: 14,
            ),
          ),
        ),
        floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
      ),
    );
  }

  // SIMPLIFIED: Show options for adding budget or category budget
  void _showBudgetOptions(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        margin: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppTheme.getCardColor(context),
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: isDark 
                  ? Colors.black.withOpacity(0.3)
                  : Colors.black.withOpacity(0.1),
              blurRadius: 20,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Header
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: AppTheme.getPrimaryColor(context).withOpacity(0.1),
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(20),
                  topRight: Radius.circular(20),
                ),
              ),
              child: Row(
                children: [
                  Icon(Icons.add_chart_rounded, color: AppTheme.getPrimaryColor(context)),
                  const SizedBox(width: 12),
                  Text(
                    'Create New',
                    style: GoogleFonts.poppins(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      color: AppTheme.getPrimaryColor(context),
                    ),
                  ),
                ],
              ),
            ),
            // Options
            ListTile(
              leading: Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppTheme.getPrimaryColor(context).withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(Icons.account_balance_wallet_rounded, color: AppTheme.getPrimaryColor(context)),
              ),
              title: Text(
                'Create Main Budget',
                style: GoogleFonts.poppins(
                  fontWeight: FontWeight.w600,
                  color: AppTheme.getTextColor(context),
                ),
              ),
              subtitle: Text(
                'Set up monthly or yearly budget',
                style: GoogleFonts.poppins(
                  color: AppTheme.getSecondaryTextColor(context),
                ),
              ),
              trailing: Icon(Icons.arrow_forward_ios_rounded, size: 16, color: AppTheme.getSecondaryTextColor(context)),
              onTap: () {
                Navigator.pop(context); // Close bottom sheet
                _navigateToAddBudget(context);
              },
            ),
            ListTile(
              leading: Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppTheme.getPrimaryColor(context).withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(Icons.category_rounded, color: AppTheme.getPrimaryColor(context)),
              ),
              title: Text(
                'Add Category Budget',
                style: GoogleFonts.poppins(
                  fontWeight: FontWeight.w600,
                  color: AppTheme.getTextColor(context),
                ),
              ),
              subtitle: Text(
                'Set budget for specific categories',
                style: GoogleFonts.poppins(
                  color: AppTheme.getSecondaryTextColor(context),
                ),
              ),
              trailing: Icon(Icons.arrow_forward_ios_rounded, size: 16, color: AppTheme.getSecondaryTextColor(context)),
              onTap: () {
                Navigator.pop(context); // Close bottom sheet
                _navigateToAddCategoryBudget(context);
              },
            ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }

  // UPDATED: Navigate to actual AddBudgetScreen
  void _navigateToAddBudget(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => AddBudgetScreen()),
    ).then((result) {
      print('📥 Returned from AddBudgetScreen with result: $result');
      setState(() {}); // Refresh when returning
    });
  }

  // UPDATED: Navigate to actual AddCategoryBudgetScreen
  void _navigateToAddCategoryBudget(BuildContext context) {
    final now = DateTime.now();
    final budgetBox = Hive.box<Budget>('budgets');
    final budgets = budgetBox.values.toList();

    List<Budget> currentBudgets;
    if (_selectedView == BudgetType.monthly) {
      currentBudgets = budgets.where((budget) {
        return budget.budgetType == BudgetType.monthly && budget.month.year == now.year && budget.month.month == now.month;
      }).toList();
      // Sort by startDate to get the most recent budget
      if (currentBudgets.isNotEmpty) {
        currentBudgets.sort((a, b) => b.startDate.compareTo(a.startDate)); // latest first
        currentBudgets = [currentBudgets.first];
      }
    } else {
      final yearlyBudgets = budgets.where((budget) {
        return budget.budgetType == BudgetType.yearly && budget.startDate.year == now.year;
      }).toList();
      if (yearlyBudgets.isNotEmpty) {
        yearlyBudgets.sort((a, b) => b.startDate.compareTo(a.startDate));
        currentBudgets = [yearlyBudgets.first];
      } else {
        currentBudgets = [];
      }
    }

    if (currentBudgets.isEmpty) {
      _showNoBudgetDialog(context);
    } else {
      final currentBudget = currentBudgets.first;
      
      print('🚀 ========== NAVIGATING TO ADD CATEGORY BUDGET ==========');
      print('   Current budget ID (before refresh): ${currentBudget.id}');
      print('   Current budget category budgets: ${currentBudget.categoryBudgets}');
      
      // Get the fresh budget from Hive to ensure we have latest category budgets
      final budgetKey = _findBudgetKey(budgetBox, currentBudget);
      print('   Found budget key: $budgetKey');
      
      final freshBudget = budgetKey != null ? budgetBox.get(budgetKey) : currentBudget;
      
      print('   Fresh budget ID: ${freshBudget?.id}');
      print('   Fresh budget category budgets: ${freshBudget?.categoryBudgets}');
      print('   Fresh budget is different from current? ${freshBudget != currentBudget}');
      print('   ==========================================================');
      
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => AddCategoryBudgetScreen(mainBudget: freshBudget ?? currentBudget),
        ),
      ).then((updatedBudget) {
        // If a budget was returned (updated), use it to refresh
        if (updatedBudget != null && updatedBudget is Budget) {
          print('✅ Returned from AddCategoryBudgetScreen with updated budget');
          print('   Updated category budgets: ${updatedBudget.categoryBudgets}');
        }
        setState(() {}); // Always refresh after returning
      });
    }
  }

  // UPDATED: Navigate to actual EditBudgetScreen or AddBudgetScreen in edit mode
  void _editBudget(Budget budget, Box<Budget> budgetBox) {
    print('🔧 ========== EDIT BUDGET CLICKED ==========');
    print('   Original budget ID: ${budget.id}');
    print('   Original budget category budgets: ${budget.categoryBudgets}');
    
    final budgetKey = _findBudgetKey(budgetBox, budget);
    print('   Found budget key: $budgetKey');
    
    if (budgetKey != null) {
      // Get the fresh budget from Hive to ensure we have latest data
      final freshBudget = budgetBox.get(budgetKey);
      
      print('   Fresh budget from Hive: ${freshBudget != null ? "FOUND" : "NOT FOUND"}');
      if (freshBudget != null) {
        print('   Fresh budget ID: ${freshBudget.id}');
        print('   Fresh budget total: ${freshBudget.totalAmount}');
        print('   Fresh budget category budgets: ${freshBudget.categoryBudgets}');
        print('   Fresh budget category budgets length: ${freshBudget.categoryBudgets.length}');
      }
      
      final budgetToEdit = freshBudget ?? budget;
      print('   Budget to edit has ${budgetToEdit.categoryBudgets.length} category budgets');
      print('   ==========================================');
      
      // Use AddBudgetScreen in edit mode to allow category budget editing
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => AddBudgetScreen(
            existingBudget: budgetToEdit,
            budgetKey: budgetKey, // Don't cast - let it be dynamic (String or int)
          ),
        ),
      ).then((_) {
        setState(() {}); // Refresh when returning
      });
    } else {
      _showErrorDialog('Could not find budget to edit');
    }
  }

  // UPDATED: Navigate to actual AddCategoryBudgetScreen in edit mode
  void _editCategoryBudget(Budget budget, String categoryName, Box<Budget> budgetBox) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => AddCategoryBudgetScreen(
          mainBudget: budget,
          editingCategory: categoryName,
        ),
      ),
    ).then((_) {
      setState(() {}); // Refresh when returning
    });
  }

  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          'Error',
          style: GoogleFonts.poppins(
            fontWeight: FontWeight.w600,
            color: Colors.red,
          ),
        ),
        content: Text(
          message,
          style: GoogleFonts.poppins(
            color: AppTheme.getSecondaryTextColor(context),
          ),
        ),
        actions: [
          PrimaryButton(
            text: 'OK',
            onPressed: () => Navigator.pop(context),
          ),
        ],
      ),
    );
  }

  void _showNoBudgetDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          'No Budget Found',
          style: GoogleFonts.poppins(
            fontWeight: FontWeight.w600,
            color: AppTheme.darkGrey,
          ),
        ),
        content: Text(
          'Please create a ${_selectedView == BudgetType.monthly ? 'monthly' : 'yearly'} budget first before adding category budgets.',
          style: GoogleFonts.poppins(
            color: AppTheme.getSecondaryTextColor(context),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel', style: GoogleFonts.poppins(color: AppTheme.getSecondaryTextColor(context))),
          ),
          PrimaryButton(
            text: 'Create Budget',
            onPressed: () {
              Navigator.pop(context); // Close alert
              _navigateToAddBudget(context);
            },
          ),
        ],
      ),
    );
  }

  // FIX: Support String and int keys for Hive budgetBox
  // Return key as dynamic (String or int)
  dynamic _findBudgetKey(Box<Budget> budgetBox, Budget budget) {
    final Map<dynamic, Budget> budgetMap = budgetBox.toMap();
    for (var entry in budgetMap.entries) {
      if (entry.value.id == budget.id) {
        return entry.key;
      }
    }
    return null;
  }

  // FIXED: Use correct fields for expense filtering
  double _calculateTotalSpent(Budget budget, List<Expense> allExpenses) {
    final periodExpenses = _getExpensesForBudget(budget, allExpenses);
    return periodExpenses.fold(0.0, (sum, expense) => sum + expense.amount);
  }

  double _calculateCategorySpent(String categoryName, List<Expense> periodExpenses) {
    final categoryExpenses = periodExpenses.where((expense) =>
    expense.category.toLowerCase() == categoryName.toLowerCase()
    ).toList();
    return categoryExpenses.fold(0.0, (sum, expense) => sum + expense.amount);
  }

  // FIXED: Use correct fields for expense period matching
  List<Expense> _getExpensesForBudget(Budget budget, List<Expense> allExpenses) {
    if (budget.budgetType == BudgetType.monthly) {
      return allExpenses.where((expense) =>
      expense.date.year == budget.month.year &&
          expense.date.month == budget.month.month
      ).toList();
    } else {
      return allExpenses.where((expense) =>
      expense.date.year == budget.startDate.year
      ).toList();
    }
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
                        color: AppTheme.getHeaderTextColor(context),
                        height: 1.2,
                      ),
                    ),
                    SizedBox(height: 4),
                    Text(
                      'Plan and track your financial goals',
                      style: GoogleFonts.poppins(
                        fontSize: 14,
                        color: AppTheme.getHeaderTextColor(context).withValues(alpha: 0.8),
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                decoration: BoxDecoration(
                  color: AppTheme.getHeaderIconBackground(context),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: IconButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const BudgetHistoryScreen()),
                    );
                  },
                  icon: Icon(
                    Icons.history_rounded, 
                    color: AppTheme.getHeaderTextColor(context)
                  ),
                  style: IconButton.styleFrom(padding: EdgeInsets.all(8)),
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
              color: isSelected ? AppTheme.getPrimaryColor(context) : Colors.white.withOpacity(0.8),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildBudgetOverviewCard(Budget budget, double totalSpent, Box<Budget> budgetBox) {
    final remaining = budget.totalAmount - totalSpent;
    final percentage = budget.totalAmount > 0 ? (totalSpent / budget.totalAmount) : 0.0;
    final isOverBudget = totalSpent > budget.totalAmount;

    return ModernCard(
      color: AppTheme.getCardColor(context),
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
                  color: AppTheme.getSecondaryTextColor(context),
                  letterSpacing: 1,
                ),
              ),
              Row(
                children: [
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: (isOverBudget ? Colors.red : AppTheme.getPrimaryColor(context)).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          isOverBudget ? Icons.warning_amber_rounded : Icons.check_circle_rounded,
                          size: 14,
                          color: isOverBudget ? Colors.red : AppTheme.getPrimaryColor(context),
                        ),
                        SizedBox(width: 4),
                        Text(
                          isOverBudget ? 'OVER BUDGET' : 'ON TRACK',
                          style: GoogleFonts.poppins(
                            fontSize: 10,
                            fontWeight: FontWeight.w600,
                            color: isOverBudget ? Colors.red : AppTheme.getPrimaryColor(context),
                            letterSpacing: 1,
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(width: 8),
                  // WORKING EDIT BUTTON
                  IconButton(
                    onPressed: () {
                      print('Edit budget button pressed');
                      _editBudget(budget, budgetBox);
                    },
                    icon: Icon(Icons.edit_rounded, size: 20),
                    color: AppTheme.getSecondaryTextColor(context),
                    padding: EdgeInsets.all(4),
                  ),
                ],
              ),
            ],
          ),
          SizedBox(height: 20),
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
                        color: AppTheme.getSecondaryTextColor(context),
                      ),
                    ),
                    SizedBox(height: 4),
                    Text(
                      '\$${remaining.toStringAsFixed(2)}',
                      style: GoogleFonts.poppins(
                        fontSize: 32,
                        fontWeight: FontWeight.w800,
                        color: isOverBudget ? Colors.red : AppTheme.getPrimaryColor(context),
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
                      color: AppTheme.getSecondaryTextColor(context),
                    ),
                  ),
                  SizedBox(height: 4),
                  Text(
                    '\$${budget.totalAmount.toStringAsFixed(2)}',
                    style: GoogleFonts.poppins(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      color: AppTheme.getTextColor(context),
                    ),
                  ),
                ],
              ),
            ],
          ),
          SizedBox(height: 24),
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: LinearProgressIndicator(
              value: percentage.clamp(0.0, 1.0),
              minHeight: 16,
              backgroundColor: (isOverBudget ? Colors.red : AppTheme.getPrimaryColor(context)).withOpacity(0.2),
              valueColor: AlwaysStoppedAnimation<Color>(
                isOverBudget ? Colors.red : AppTheme.getPrimaryColor(context),
              ),
            ),
          ),
          SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Spent: \$${totalSpent.toStringAsFixed(2)}',
                style: GoogleFonts.poppins(
                  fontSize: 14,
                  color: AppTheme.getSecondaryTextColor(context),
                  fontWeight: FontWeight.w500,
                ),
              ),
              Text(
                '${(percentage * 100).toStringAsFixed(1)}%',
                style: GoogleFonts.poppins(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: isOverBudget ? Colors.red : AppTheme.getPrimaryColor(context),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // Helper to get category from Hive
  Category? _getCategoryByName(String name) {
    final categoryBox = Hive.box<Category>('categories');
    return categoryBox.values.firstWhere(
      (cat) => cat.name == name,
      orElse: () => Category(
        id: '999',
        name: name,
        icon: Icons.category_rounded.codePoint.toString(),
        color: AppTheme.getPrimaryColor(context).value,
      ),
    );
  }

  // Build category breakdown section - ONLY show categories with budgets
  Widget _buildCategoryBreakdownSection(Budget budget, List<Expense> periodExpenses, Box<Budget> budgetBox) {
    print('DEBUG: categoryBudgets for budget ${budget.id}: ${budget.categoryBudgets}');
    print('DEBUG: categoryBudgets isEmpty: ${budget.categoryBudgets.isEmpty}');
    print('DEBUG: categoryBudgets length: ${budget.categoryBudgets.length}');
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              "CATEGORY BUDGETS",
              style: GoogleFonts.poppins(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: AppTheme.getSecondaryTextColor(context),
                letterSpacing: 0.5,
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        // Show empty state if no category budgets
        if (budget.categoryBudgets.isEmpty)
          _buildNoCategoryBudgetsState(context, budget, budgetBox)
        else
          // Only display categories that have budgets
          ...budget.categoryBudgets.entries.map((entry) {
          final category = _getCategoryByName(entry.key);
          final categoryColor = category?.color ?? AppTheme.getPrimaryColor(context).value;
          final categoryIcon = category?.icon != null ? IconData(int.parse(category!.icon), fontFamily: 'MaterialIcons') : Icons.category_rounded;
          final categoryName = category?.name ?? entry.key;
          final categoryBudget = entry.value;
          final categorySpent = _calculateCategorySpent(entry.key, periodExpenses);
          final percentage = categoryBudget > 0 ? (categorySpent / categoryBudget) : 0.0;
          final isOverBudget = categorySpent > categoryBudget;
          final remaining = categoryBudget - categorySpent;
          
          return Container(
            margin: const EdgeInsets.only(bottom: 12.0),
            decoration: BoxDecoration(
              color: AppTheme.getCardColor(context),
              borderRadius: BorderRadius.circular(16.0),
              boxShadow: [
                BoxShadow(
                  color: Theme.of(context).brightness == Brightness.dark
                      ? Colors.black.withOpacity(0.3)
                      : Colors.black.withOpacity(0.05),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                children: [
                  // Category Icon with Gradient
                  Container(
                    width: 56,
                    height: 56,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          Color(categoryColor).withOpacity(0.8),
                          Color(categoryColor).withOpacity(0.6),
                        ],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(16.0),
                      boxShadow: [
                        BoxShadow(
                          color: Color(categoryColor).withOpacity(0.3),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Icon(
                      categoryIcon,
                      color: Colors.white,
                      size: 28,
                    ),
                  ),
                  const SizedBox(width: 16),
                  // Category Details with Progress Bar
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(
                              child:                              Text(
                                categoryName,
                                style: GoogleFonts.poppins(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                  color: AppTheme.getTextColor(context),
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            Row(
                              children: [
                                Icon(Icons.trending_up_rounded, size: 14, color: AppTheme.getSecondaryTextColor(context).withOpacity(0.7)),
                                const SizedBox(width: 4),
                                Text(
                                  '${(percentage * 100).toStringAsFixed(0)}%',
                                  style: GoogleFonts.poppins(
                                    fontSize: 12,
                                    color: AppTheme.getSecondaryTextColor(context),
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  '\$${categorySpent.toStringAsFixed(2)}',
                                  style: GoogleFonts.poppins(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w700,
                                    color: isOverBudget ? Colors.red : Color(categoryColor),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                        const SizedBox(height: 6),
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                              decoration: BoxDecoration(
                                color: Color(categoryColor).withOpacity(0.1),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Text(
                                'Budget: \$${categoryBudget.toStringAsFixed(2)}',
                                style: GoogleFonts.poppins(
                                  fontSize: 11,
                                  color: Color(categoryColor),
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                            const Spacer(),
                            Text(
                              isOverBudget 
                                ? 'Over \$${(categorySpent - categoryBudget).toStringAsFixed(2)}'
                                : '\$${remaining.toStringAsFixed(2)} left',
                              style: GoogleFonts.poppins(
                                fontSize: 11,
                                color: isOverBudget ? Colors.red : AppTheme.getSecondaryTextColor(context),
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        // Progress Bar
                        ClipRRect(
                          borderRadius: BorderRadius.circular(4),
                          child: LinearProgressIndicator(
                            value: percentage.clamp(0.0, 1.0),
                            minHeight: 6,
                            backgroundColor: isOverBudget ? Colors.red.withOpacity(0.2) : Colors.grey[200],
                            valueColor: AlwaysStoppedAnimation<Color>(
                              isOverBudget ? Colors.red : Color(categoryColor),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 12),
                  // Edit and Delete Buttons
                  Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      InkWell(
                        onTap: () {
                          _editCategoryBudget(budget, entry.key, budgetBox);
                        },
                        borderRadius: BorderRadius.circular(8),
                        child: Container(
                          padding: const EdgeInsets.all(8.0),
                          decoration: BoxDecoration(
                            color: Theme.of(context).brightness == Brightness.dark
                                ? AppTheme.darkSurface
                                : Colors.grey[100],
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Icon(
                            Icons.edit_outlined,
                            color: AppTheme.getSecondaryTextColor(context),
                            size: 18,
                          ),
                        ),
                      ),
                      const SizedBox(height: 8),
                      InkWell(
                        onTap: () {
                          _showDeleteCategoryBudgetConfirmation(
                            context,
                            budget,
                            entry.key,
                            budgetBox,
                          );
                        },
                        borderRadius: BorderRadius.circular(8),
                        child: Container(
                          padding: const EdgeInsets.all(8.0),
                          decoration: BoxDecoration(
                            color: Theme.of(context).brightness == Brightness.dark
                                ? Colors.red.withOpacity(0.2)
                                : Colors.red[50],
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Icon(
                            Icons.delete_outline_rounded,
                            color: Colors.red[400],
                            size: 18,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          );
        }).toList(),
      ],
    );
  }

  Widget _buildNoCategoryBudgetsState(BuildContext context, Budget budget, Box<Budget> budgetBox) {
    return ModernCard(
      color: AppTheme.getCardColor(context),
      padding: EdgeInsets.all(24),
      child: Column(
        children: [
          Container(
            padding: EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: AppTheme.getPrimaryColor(context).withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.category_rounded,
              size: 48,
              color: AppTheme.getPrimaryColor(context),
            ),
          ),
          SizedBox(height: 20),
          Text(
            'No Category Budgets Yet',
            style: GoogleFonts.poppins(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: AppTheme.getTextColor(context),
            ),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: 8),
          Text(
            'Set budgets for individual categories to track your spending more effectively.',
            style: GoogleFonts.poppins(
              fontSize: 14,
              color: AppTheme.getSecondaryTextColor(context),
              height: 1.5,
            ),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: 24),
          Container(
            width: double.infinity,
            height: 56,
            decoration: AppTheme.getGradientButtonDecoration(),
            child: ElevatedButton.icon(
              onPressed: () => _navigateToAddCategoryBudget(context),
              icon: Icon(Icons.add_rounded, size: 20, color: Colors.white),
              label: Text(
                'Add Category Budget',
                style: GoogleFonts.poppins(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
              ),
              style: AppTheme.getGradientButtonStyle(),
            ),
          ),
        ],
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
              color: AppTheme.getSecondaryTextColor(context).withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.analytics_outlined,
              size: 60,
              color: AppTheme.getSecondaryTextColor(context),
            ),
          ),
          SizedBox(height: 24),
          Text(
            'No ${_selectedView == BudgetType.monthly ? 'Monthly' : 'Yearly'} Budget',
            style: GoogleFonts.poppins(
              fontSize: 22,
              fontWeight: FontWeight.w700,
              color: AppTheme.getSecondaryTextColor(context),
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
              color: AppTheme.getSecondaryTextColor(context).withOpacity(0.8),
              height: 1.4,
            ),
          ),
        ],
      ),
    );
  }

  void _showDeleteCategoryBudgetConfirmation(
    BuildContext context,
    Budget budget,
    String categoryName,
    Box<Budget> budgetBox,
  ) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        title: Text(
          'Delete Category Budget',
          style: GoogleFonts.poppins(
            fontWeight: FontWeight.w600,
            color: AppTheme.darkGrey,
          ),
        ),
        content: Text(
          'Are you sure you want to delete the budget for $categoryName? This action cannot be undone.',
          style: GoogleFonts.poppins(
            color: AppTheme.getTextColor(context),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'Cancel',
              style: GoogleFonts.poppins(
                color: AppTheme.getSecondaryTextColor(context),
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _deleteCategoryBudget(budget, categoryName, budgetBox);
            },
            child: Text(
              'Delete',
              style: GoogleFonts.poppins(
                color: Colors.red,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _deleteCategoryBudget(Budget budget, String categoryName, Box<Budget> budgetBox) {
    final budgetKey = _findBudgetKey(budgetBox, budget);
    if (budgetKey != null) {
      // Create a new map without the category
      final updatedCategoryBudgets = Map<String, double>.from(budget.categoryBudgets);
      updatedCategoryBudgets.remove(categoryName);

      // Create updated budget with new category budgets
      final updatedBudget = Budget(
        id: budget.id,
        totalAmount: budget.totalAmount,
        budgetType: budget.budgetType,
        month: budget.month,
        startDate: budget.startDate,
        categoryBudgets: updatedCategoryBudgets,
        userId: budget.userId,
      );

      // Save to Hive
      budgetBox.put(budgetKey, updatedBudget);

      setState(() {});

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Category budget deleted successfully',
            style: GoogleFonts.poppins(),
          ),
          backgroundColor: Colors.green,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
      );
    }
  }

  Widget _buildEmptyCategoriesState() {
    return ModernCard(
      padding: EdgeInsets.all(24),
      child: Column(
        children: [
          Icon(Icons.pie_chart_outline_rounded, size: 48, color: AppTheme.getSecondaryTextColor(context).withOpacity(0.5)),
          SizedBox(height: 16),
          Text(
            'No Category Budgets',
            style: GoogleFonts.poppins(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: AppTheme.getSecondaryTextColor(context),
            ),
          ),
          SizedBox(height: 8),
          Text(
            'Tap the + button above to add individual category budgets for detailed spending control.',
            textAlign: TextAlign.center,
            style: GoogleFonts.poppins(
              color: AppTheme.getSecondaryTextColor(context).withOpacity(0.8),
            ),
          ),
        ],
      ),
    );
  }

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
}


