import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:smart_expense_tracker/app/theme/app_theme.dart';
import 'package:smart_expense_tracker/common_widgets/modern_card.dart';
import 'package:smart_expense_tracker/common_widgets/primary_button.dart';
import 'package:smart_expense_tracker/common_widgets/themed_background.dart';
import 'package:smart_expense_tracker/models/budget_model.dart';
import 'package:smart_expense_tracker/models/category_model.dart';

class AddCategoryBudgetScreen extends StatefulWidget {
  final Budget mainBudget;
  final String? editingCategory;

  const AddCategoryBudgetScreen({
    Key? key,
    required this.mainBudget,
    this.editingCategory,
  }) : super(key: key);

  @override
  State<AddCategoryBudgetScreen> createState() => _AddCategoryBudgetScreenState();
}

class _AddCategoryBudgetScreenState extends State<AddCategoryBudgetScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _amountController;
  late String _selectedCategory;
  late Map<String, double> _categoryBudgets;

  List<Category> _categories = [];

  // Helper method to convert stored icon string back to IconData
  IconData _getIconFromString(String iconString) {
    try {
      return IconData(
        int.parse(iconString),
        fontFamily: 'MaterialIcons',
      );
    } catch (e) {
      return Icons.category_rounded;
    }
  }

  @override
  void initState() {
    super.initState();
    _categoryBudgets = Map.from(widget.mainBudget.categoryBudgets);

    // Debug logging
    print('🔍 AddCategoryBudgetScreen loaded with budget ID: ${widget.mainBudget.id}');
    print('🔍 Category budgets from mainBudget: ${widget.mainBudget.categoryBudgets}');
    print('🔍 Local _categoryBudgets copy: $_categoryBudgets');

    // Load categories from Hive
    final categoryBox = Hive.box<Category>('categories');
    _categories = categoryBox.values.toList();

    // If no categories in Hive, keep empty list
    if (_categories.isNotEmpty) {
      if (widget.editingCategory != null) {
        _selectedCategory = widget.editingCategory!;
        _amountController = TextEditingController(
          text: _categoryBudgets[_selectedCategory]?.toStringAsFixed(2) ?? '',
        );
      } else {
        _selectedCategory = _categories.first.name;
        _amountController = TextEditingController();
      }
    } else {
      // Fallback if no categories exist
      _selectedCategory = '';
      _amountController = TextEditingController();
    }
  }

  @override
  void dispose() {
    _amountController.dispose();
    super.dispose();
  }

  double get _totalCategoryBudgets {
    return _categoryBudgets.values.fold(0.0, (sum, amount) => sum + amount);
  }

  double get _remainingBudget {
    return widget.mainBudget.totalAmount - _totalCategoryBudgets;
  }

  double get _availableForSelectedCategory {
    final currentCategoryBudget = _categoryBudgets[_selectedCategory] ?? 0;
    return _remainingBudget + currentCategoryBudget;
  }

  // --- Accurate Category Budget Logic ---
  Future<void> _saveCategoryBudget() async {
    if (_formKey.currentState!.validate()) {
      final amount = double.tryParse(_amountController.text) ?? 0.0;
      if (amount <= 0) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Category "$_selectedCategory" must be greater than 0'),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }
      // Only check that the selected category budget does not exceed available/main budget
      if (amount > _availableForSelectedCategory) {
        _showBudgetExceededDialog(amount, _availableForSelectedCategory);
        return;
      }
      if (amount > widget.mainBudget.totalAmount) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Category budget exceeds main budget!'),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }
      try {
        final budgetBox = Hive.box<Budget>('budgets');
        final budgetKey = _findBudgetKey(budgetBox, widget.mainBudget);
        if (budgetKey == null) {
          throw Exception('Budget key not found');
        }
        _categoryBudgets[_selectedCategory] = amount;
        final updatedBudget = Budget(
          id: widget.mainBudget.id,
          totalAmount: widget.mainBudget.totalAmount,
          categoryBudgets: Map<String, double>.from(_categoryBudgets),
          month: widget.mainBudget.month,
          budgetType: widget.mainBudget.budgetType,
          startDate: widget.mainBudget.startDate,
          userId: widget.mainBudget.userId,
        );
        await budgetBox.put(budgetKey, updatedBudget);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(widget.editingCategory != null ? 'Category budget updated!' : 'Category budget added!'),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.pop(context, updatedBudget);
      } catch (e) {
        print('Error saving category budget: $e');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error saving category budget: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _removeCategoryBudget() {
    if (widget.editingCategory != null) {
      _categoryBudgets.remove(widget.editingCategory);
      _saveAfterRemoval();
    }
  }

  Future<void> _saveAfterRemoval() async {
    try {
      final budgetBox = Hive.box<Budget>('budgets');
      final budgetKey = _findBudgetKey(budgetBox, widget.mainBudget);
      if (budgetKey != null) {
        final updatedBudget = Budget(
          id: widget.mainBudget.id,
          totalAmount: widget.mainBudget.totalAmount,
          categoryBudgets: _categoryBudgets,
          month: widget.mainBudget.month,
          budgetType: widget.mainBudget.budgetType,
          startDate: widget.mainBudget.startDate,
          userId: widget.mainBudget.userId,
        );
        await budgetBox.put(budgetKey, updatedBudget);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Category budget removed!'),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.pop(context);
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error removing category budget: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  void _showBudgetExceededDialog(double requestedAmount, double availableAmount) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          'Budget Exceeded',
          style: GoogleFonts.poppins(
            fontWeight: FontWeight.w600,
            color: Colors.red,
          ),
        ),
        content: Text(
          'The requested amount of \$${requestedAmount.toStringAsFixed(2)} exceeds the available budget of \$${availableAmount.toStringAsFixed(2)}.\n\nPlease adjust the amount or modify other category budgets.',
          style: GoogleFonts.poppins(
            color: AppTheme.getTextColor(context),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('OK', style: GoogleFonts.poppins(color: AppTheme.primaryTeal)),
          ),
        ],
      ),
    );
  }

  void _showRemoveDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          'Remove Category Budget',
          style: GoogleFonts.poppins(
            fontWeight: FontWeight.w600,
            color: AppTheme.getTextColor(context),
          ),
        ),
        content: Text(
          'Are you sure you want to remove the budget for $_selectedCategory?',
          style: GoogleFonts.poppins(
            color: AppTheme.getTextColor(context),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel', style: GoogleFonts.poppins(color: AppTheme.getSecondaryTextColor(context))),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _removeCategoryBudget();
            },
            child: Text(
              'Remove',
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

  dynamic _findBudgetKey(Box<Budget> budgetBox, Budget budget) {
    final Map<dynamic, Budget> budgetMap = budgetBox.toMap();
    for (var entry in budgetMap.entries) {
      if (entry.value.id == budget.id) {
        return entry.key;
      }
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return ThemedBackground(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_rounded, size: 24, color: Colors.white),
            onPressed: () => Navigator.pop(context),
            tooltip: 'Back',
          ),
          title: Text(
            widget.editingCategory != null ? 'Edit Category Budget' : 'Add Category Budget',
            style: GoogleFonts.poppins(
              fontWeight: FontWeight.w600,
              color: Colors.white,
              fontSize: 20,
            ),
          ),
          backgroundColor: AppTheme.getHeaderPrimaryColor(context),
          elevation: 0,
          iconTheme: const IconThemeData(color: Colors.white),
        actions: widget.editingCategory != null
            ? [
          IconButton(
            onPressed: _showRemoveDialog,
            icon: const Icon(Icons.delete_outline_rounded, size: 24, color: Colors.white),
            tooltip: 'Remove Category Budget',
          ),
        ]
            : null,
      ),
      body: SafeArea(
        child: Form(
          key: _formKey,
          child: ListView(
            padding: const EdgeInsets.all(20.0),
            children: [
              _buildMainBudgetOverview(),
              const SizedBox(height: 24),
              _buildCategoryBudgetInputs(),
              const SizedBox(height: 40),
              PrimaryButton(
                text: widget.editingCategory != null ? 'Update Category Budget' : 'Add Category Budget',
                onPressed: _saveCategoryBudget,
              ),
              const SizedBox(height: 16),
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text(
                  'Cancel',
                  style: GoogleFonts.poppins(
                    fontSize: 16,
                    color: AppTheme.getSecondaryTextColor(context),
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
              ],
          ),
        ),
      ),
    ),
    );
  }

  Widget _buildMainBudgetOverview() {
    return ModernCard(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'MAIN BUDGET',
            style: GoogleFonts.poppins(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: AppTheme.getSecondaryTextColor(context),
              letterSpacing: 1,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Total Budget',
                    style: GoogleFonts.poppins(
                      fontSize: 14,
                      color: AppTheme.getSecondaryTextColor(context),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '\$${widget.mainBudget.totalAmount.toStringAsFixed(2)}',
                    style: GoogleFonts.poppins(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      color: AppTheme.getHeaderPrimaryColor(context),
                    ),
                  ),
                ],
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    'Remaining',
                    style: GoogleFonts.poppins(
                      fontSize: 14,
                      color: AppTheme.getSecondaryTextColor(context),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '\$${_remainingBudget.toStringAsFixed(2)}',
                    style: GoogleFonts.poppins(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      color: _remainingBudget >= 0 ? Colors.green : Colors.red,
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 12),
          LinearProgressIndicator(
            value: _totalCategoryBudgets / widget.mainBudget.totalAmount,
            backgroundColor: Theme.of(context).brightness == Brightness.dark
                ? AppTheme.darkSurface
                : Colors.grey[200],
            valueColor: AlwaysStoppedAnimation<Color>(AppTheme.accentOrange),
            borderRadius: BorderRadius.circular(5),
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Assigned: \$${_totalCategoryBudgets.toStringAsFixed(2)}',
                style: GoogleFonts.poppins(
                  fontSize: 12,
                  color: AppTheme.getSecondaryTextColor(context),
                ),
              ),
              Text(
                '${((_totalCategoryBudgets / widget.mainBudget.totalAmount) * 100).toStringAsFixed(1)}%',
                style: GoogleFonts.poppins(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: AppTheme.primaryTeal,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryBudgetInputs() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'CATEGORY BUDGETS',
          style: GoogleFonts.poppins(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: AppTheme.getSecondaryTextColor(context),
            letterSpacing: 1,
          ),
        ),
        const SizedBox(height: 16),
        ..._categories.map((category) {
          final isEditing = _selectedCategory == category.name;
          final hasBudget = (_categoryBudgets[category.name] ?? 0) > 0;
          final categoryColor = Color(category.color);
          
          return Padding(
            padding: const EdgeInsets.only(bottom: 16.0),
            child: ModernCard(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      // Category icon with gradient background
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              categoryColor.withOpacity(0.8),
                              categoryColor.withOpacity(0.6),
                            ],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          borderRadius: BorderRadius.circular(12),
                          boxShadow: [
                            BoxShadow(
                              color: categoryColor.withOpacity(0.3),
                              blurRadius: 8,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Icon(
                          _getIconFromString(category.icon),
                          size: 24,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              category.name,
                              style: GoogleFonts.poppins(
                                fontWeight: FontWeight.w700,
                                fontSize: 17,
                                color: AppTheme.getTextColor(context),
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              hasBudget 
                                ? 'Allocated: \$${_categoryBudgets[category.name]?.toStringAsFixed(2)}'
                                : 'No budget set',
                              style: GoogleFonts.poppins(
                                fontSize: 12,
                                color: hasBudget ? categoryColor : AppTheme.getSecondaryTextColor(context),
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ),
                      // Edit/Delete actions
                      if (!isEditing && hasBudget)
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              icon: Icon(Icons.edit_rounded, color: AppTheme.primaryTeal, size: 20),
                              tooltip: 'Edit',
                              onPressed: () {
                                setState(() {
                                  _selectedCategory = category.name;
                                  _amountController.text = _categoryBudgets[category.name]?.toStringAsFixed(2) ?? '';
                                });
                              },
                              padding: EdgeInsets.all(8),
                              constraints: BoxConstraints(),
                            ),
                            IconButton(
                              icon: Icon(Icons.delete_outline_rounded, color: Colors.red, size: 20),
                              tooltip: 'Remove',
                              onPressed: () {
                                setState(() {
                                  _selectedCategory = category.name;
                                });
                                _showRemoveDialog();
                              },
                              padding: EdgeInsets.all(8),
                              constraints: BoxConstraints(),
                            ),
                          ],
                        ),
                      if (!isEditing && !hasBudget)
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(
                            color: AppTheme.primaryTeal.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: InkWell(
                            onTap: () {
                              setState(() {
                                _selectedCategory = category.name;
                                _amountController.text = '';
                              });
                            },
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(Icons.add_rounded, size: 16, color: AppTheme.primaryTeal),
                                const SizedBox(width: 4),
                                Text(
                                  'Add',
                                  style: GoogleFonts.poppins(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w600,
                                    color: AppTheme.primaryTeal,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                    ],
                  ),
                  // Budget input field when editing
                  if (isEditing) ...[
                    const SizedBox(height: 20),
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            categoryColor.withOpacity(0.05),
                            categoryColor.withOpacity(0.02),
                          ],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: categoryColor.withOpacity(0.3),
                          width: 2,
                        ),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  color: categoryColor.withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Icon(
                                  Icons.account_balance_wallet_rounded,
                                  size: 20,
                                  color: categoryColor,
                                ),
                              ),
                              const SizedBox(width: 12),
                              Text(
                                'Budget Amount',
                                style: GoogleFonts.poppins(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                  color: AppTheme.getTextColor(context),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                '\$',
                                style: GoogleFonts.poppins(
                                  fontSize: 32,
                                  fontWeight: FontWeight.w800,
                                  color: categoryColor,
                                  height: 1.2,
                                ),
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: TextFormField(
                                  controller: _amountController,
                                  keyboardType: TextInputType.numberWithOptions(decimal: true),
                                  autofocus: true,
                                  style: GoogleFonts.poppins(
                                    fontSize: 32,
                                    fontWeight: FontWeight.w800,
                                    color: categoryColor,
                                    height: 1.2,
                                  ),
                                  decoration: InputDecoration(
                                    hintText: '0.00',
                                    hintStyle: GoogleFonts.poppins(
                                      fontSize: 32,
                                      fontWeight: FontWeight.w800,
                                      color: AppTheme.getSecondaryTextColor(context).withOpacity(0.5),
                                    ),
                                    border: InputBorder.none,
                                    enabledBorder: InputBorder.none,
                                    focusedBorder: InputBorder.none,
                                    errorBorder: InputBorder.none,
                                    focusedErrorBorder: InputBorder.none,
                                    contentPadding: EdgeInsets.zero,
                                    isDense: true,
                                  ),
                                  validator: (value) {
                                    if (value == null || value.isEmpty) {
                                      return 'Enter a budget amount';
                                    }
                                    final amount = double.tryParse(value);
                                    if (amount == null || amount <= 0) {
                                      return 'Enter a valid amount';
                                    }
                                    if (amount > _availableForSelectedCategory) {
                                      return 'Exceeds available budget';
                                    }
                                    if (amount > widget.mainBudget.totalAmount) {
                                      return 'Exceeds main budget';
                                    }
                                    return null;
                                  },
                                  onChanged: (value) {
                                    setState(() {
                                      _categoryBudgets[category.name] = double.tryParse(value) ?? 0.0;
                                    });
                                  },
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          // Available budget info
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: Theme.of(context).brightness == Brightness.dark
                                  ? AppTheme.darkSurface
                                  : Colors.blue.shade50,
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(
                                color: Theme.of(context).brightness == Brightness.dark
                                    ? AppTheme.darkPrimaryTeal.withOpacity(0.3)
                                    : Colors.blue.shade200,
                              ),
                            ),
                            child: Row(
                              children: [
                                Icon(
                                  Icons.info_outline_rounded, 
                                  size: 16, 
                                  color: Theme.of(context).brightness == Brightness.dark
                                      ? AppTheme.darkInfoBlue
                                      : Colors.blue,
                                ),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Text(
                                    'Available: \$${_availableForSelectedCategory.toStringAsFixed(2)}',
                                    style: GoogleFonts.poppins(
                                      fontSize: 12,
                                      color: AppTheme.getTextColor(context),
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 16),
                          // Action buttons - Right aligned with orange Save button
                          Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              TextButton.icon(
                                onPressed: () {
                                  setState(() {
                                    _selectedCategory = _categories.first.name;
                                    _amountController.clear();
                                  });
                                },
                                icon: Icon(Icons.close_rounded, size: 18),
                                label: Text(
                                  'Cancel',
                                  style: GoogleFonts.poppins(
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                style: TextButton.styleFrom(
                                  foregroundColor: AppTheme.getSecondaryTextColor(context),
                                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 12),
                              Container(
                                height: 48,
                                decoration: AppTheme.getGradientButtonDecoration(),
                                child: ElevatedButton.icon(
                                  onPressed: _saveCategoryBudget,
                                  icon: Icon(Icons.check_rounded, size: 18, color: Colors.white),
                                  label: Text(
                                    'Save',
                                    style: GoogleFonts.poppins(
                                      fontWeight: FontWeight.w600,
                                      color: Colors.white,
                                    ),
                                  ),
                                  style: AppTheme.getGradientButtonStyle(),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ],
              ),
            ),
          );
        }).toList(),
      ],
    );
  }
}