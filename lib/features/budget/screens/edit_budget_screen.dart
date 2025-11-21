import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:smart_expense_tracker/app/theme/app_theme.dart';
import 'package:smart_expense_tracker/common_widgets/modern_card.dart';
import 'package:smart_expense_tracker/common_widgets/themed_background.dart';
import 'package:smart_expense_tracker/models/budget_model.dart';
import 'package:smart_expense_tracker/models/category_model.dart';

class EditBudgetScreen extends StatefulWidget {
  final Budget budget;
  final int budgetKey;

  const EditBudgetScreen({
    Key? key,
    required this.budget,
    required this.budgetKey,
  }) : super(key: key);

  @override
  State<EditBudgetScreen> createState() => _EditBudgetScreenState();
}

class _EditBudgetScreenState extends State<EditBudgetScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _amountController;
  late BudgetType _selectedType;
  late DateTime _selectedMonth;
  late DateTime _selectedYear;

  @override
  void initState() {
    super.initState();
    _amountController = TextEditingController(
      text: widget.budget.totalAmount.toStringAsFixed(2),
    );
    _selectedType = widget.budget.budgetType;
    _selectedMonth = widget.budget.month;
    _selectedYear = widget.budget.startDate;
  }

  @override
  void dispose() {
    _amountController.dispose();
    super.dispose();
  }

  double get _totalCategoryBudgets {
    return widget.budget.categoryBudgets.values.fold(0.0, (sum, amount) => sum + amount);
  }

  double get _remainingAfterUpdate {
    final newTotal = double.tryParse(_amountController.text) ?? widget.budget.totalAmount;
    return newTotal - _totalCategoryBudgets;
  }

  Future<void> _updateBudget() async {
    if (_formKey.currentState!.validate()) {
      final newAmount = double.parse(_amountController.text);

      // Check if the new amount can cover existing category budgets
      if (newAmount < _totalCategoryBudgets) {
        _showInsufficientBudgetDialog(newAmount, _totalCategoryBudgets);
        return;
      }

      try {
        final budgetBox = Hive.box<Budget>('budgets');

        final updatedBudget = Budget(
          id: widget.budget.id,
          totalAmount: newAmount,
          categoryBudgets: widget.budget.categoryBudgets,
          month: _selectedType == BudgetType.monthly ? _selectedMonth : DateTime(_selectedYear.year, _selectedYear.month, 1),
          budgetType: _selectedType,
          startDate: _selectedType == BudgetType.yearly ? _selectedYear : DateTime(_selectedMonth.year, _selectedMonth.month, 1),
          userId: widget.budget.userId,
        );

        await budgetBox.put(widget.budgetKey, updatedBudget);

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Budget updated successfully!'),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.pop(context);
      } catch (e) {
        print('Error updating budget: $e');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error updating budget: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _showInsufficientBudgetDialog(double newAmount, double requiredAmount) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          'Insufficient Budget',
          style: GoogleFonts.poppins(
            fontWeight: FontWeight.w600,
            color: Colors.red,
          ),
        ),
        content: Text(
          'The new budget amount of \$${newAmount.toStringAsFixed(2)} is insufficient to cover the existing category budgets of \$${requiredAmount.toStringAsFixed(2)}.\n\nPlease increase the budget amount or remove some category budgets.',
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

  Future<void> _selectMonth(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedMonth,
      firstDate: DateTime(2020),
      lastDate: DateTime(2030),
      initialDatePickerMode: DatePickerMode.year,
    );

    if (picked != null && picked != _selectedMonth) {
      setState(() {
        _selectedMonth = DateTime(picked.year, picked.month, 1);
      });
    }
  }

  Future<void> _selectYear(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedYear,
      firstDate: DateTime(2020),
      lastDate: DateTime(2030),
      initialDatePickerMode: DatePickerMode.year,
    );

    if (picked != null && picked != _selectedYear) {
      setState(() {
        _selectedYear = DateTime(picked.year, 1, 1);
      });
    }
  }

  void _showDeleteDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          'Delete Budget',
          style: GoogleFonts.poppins(
            fontWeight: FontWeight.w600,
            color: AppTheme.getTextColor(context),
          ),
        ),
        content: Text(
          'Are you sure you want to delete this budget? This action cannot be undone.',
          style: GoogleFonts.poppins(
            color: AppTheme.getSecondaryTextColor(context),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel', style: GoogleFonts.poppins(color: AppTheme.getSecondaryTextColor(context))),
          ),
          TextButton(
            onPressed: _deleteBudget,
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

  Future<void> _deleteBudget() async {
    try {
      final budgetBox = Hive.box<Budget>('budgets');
      await budgetBox.delete(widget.budgetKey);

      Navigator.pop(context); // Close dialog
      Navigator.pop(context); // Close edit screen

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Budget deleted successfully!'),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      Navigator.pop(context); // Close dialog
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error deleting budget: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Widget _buildBudgetTypeSection() {
    return ModernCard(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'BUDGET TYPE',
            style: GoogleFonts.poppins(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: AppTheme.getSecondaryTextColor(context),
              letterSpacing: 1,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              _buildTypeOption('Monthly', BudgetType.monthly),
              const SizedBox(width: 12),
              _buildTypeOption('Yearly', BudgetType.yearly),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTypeOption(String text, BudgetType type) {
    final isSelected = _selectedType == type;
    return Expanded(
      child: GestureDetector(
        onTap: () {
          setState(() {
            _selectedType = type;
          });
        },
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
          decoration: BoxDecoration(
            color: isSelected ? AppTheme.getHeaderPrimaryColor(context).withOpacity(0.1) : Colors.transparent,
            border: Border.all(
              color: isSelected ? AppTheme.getHeaderPrimaryColor(context) : AppTheme.getSecondaryTextColor(context).withOpacity(0.3),
              width: 2,
            ),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            children: [
              Icon(
                type == BudgetType.monthly ? Icons.calendar_today_rounded : Icons.calendar_view_month_rounded,
                color: isSelected ? AppTheme.getHeaderPrimaryColor(context) : AppTheme.getSecondaryTextColor(context),
                size: 24,
              ),
              const SizedBox(height: 8),
              Text(
                text,
                style: GoogleFonts.poppins(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: isSelected ? AppTheme.getHeaderPrimaryColor(context) : AppTheme.getSecondaryTextColor(context),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAmountSection() {
    return ModernCard(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'BUDGET AMOUNT',
            style: GoogleFonts.poppins(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: AppTheme.getSecondaryTextColor(context),
              letterSpacing: 1,
            ),
          ),
          const SizedBox(height: 16),
          TextFormField(
            controller: _amountController,
            keyboardType: TextInputType.numberWithOptions(decimal: true),
            decoration: InputDecoration(
              prefixText: '\$ ',
              prefixStyle: GoogleFonts.poppins(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: AppTheme.getHeaderPrimaryColor(context),
              ),
              hintText: '0.00',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: AppTheme.getSecondaryTextColor(context).withOpacity(0.3)),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: AppTheme.getHeaderPrimaryColor(context), width: 2),
              ),
            ),
            style: GoogleFonts.poppins(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: AppTheme.getTextColor(context),
            ),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please enter budget amount';
              }
              final amount = double.tryParse(value);
              if (amount == null || amount <= 0) {
                return 'Please enter a valid amount greater than 0';
              }
              return null;
            },
          ),
          const SizedBox(height: 12),
          Text(
            'Existing category budgets: \$${_totalCategoryBudgets.toStringAsFixed(2)}',
            style: GoogleFonts.poppins(
              fontSize: 14,
              color: AppTheme.getTextColor(context),
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Remaining after update: \$${_remainingAfterUpdate.toStringAsFixed(2)}',
            style: GoogleFonts.poppins(
              fontSize: 14,
              color: _remainingAfterUpdate >= 0 ? Colors.green : Colors.red,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDateSection() {
    return ModernCard(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            _selectedType == BudgetType.monthly ? 'SELECT MONTH' : 'SELECT YEAR',
            style: GoogleFonts.poppins(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: AppTheme.getSecondaryTextColor(context),
              letterSpacing: 1,
            ),
          ),
          const SizedBox(height: 16),
          ListTile(
            onTap: () => _selectedType == BudgetType.monthly ? _selectMonth(context) : _selectYear(context),
            leading: Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppTheme.getHeaderPrimaryColor(context).withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.calendar_today_rounded,
                color: AppTheme.getHeaderPrimaryColor(context),
                size: 20,
              ),
            ),
            title: Text(
              _selectedType == BudgetType.monthly
                  ? '${_getMonthName(_selectedMonth.month)} ${_selectedMonth.year}'
                  : '${_selectedYear.year}',
              style: GoogleFonts.poppins(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: AppTheme.getTextColor(context),
              ),
            ),
            subtitle: Text(
              _selectedType == BudgetType.monthly ? 'Monthly Budget' : 'Yearly Budget',
              style: GoogleFonts.poppins(
                color: AppTheme.getSecondaryTextColor(context),
              ),
            ),
            trailing: Icon(Icons.arrow_forward_ios_rounded, size: 16, color: AppTheme.getSecondaryTextColor(context)),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
              side: BorderSide(color: AppTheme.getSecondaryTextColor(context).withOpacity(0.3)),
            ),
          ),
        ],
      ),
    );
  }

  Category? _getCategoryByName(String name) {
    final categoryBox = Hive.box<Category>('categories');
    return categoryBox.values.firstWhere(
      (cat) => cat.name == name,
      orElse: () => Category(
        id: '999',
        name: name,
        icon: Icons.category_rounded.codePoint.toString(),
        color: AppTheme.primaryTeal.value,
      ),
    );
  }

  Widget _buildCategoryBudgetsPreview() {
    if (widget.budget.categoryBudgets.isEmpty) {
      return ModernCard(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            Icon(Icons.category_outlined, size: 48, color: AppTheme.getSecondaryTextColor(context).withOpacity(0.5)),
            const SizedBox(height: 16),
            Text(
              'No Category Budgets',
              style: GoogleFonts.poppins(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: AppTheme.getSecondaryTextColor(context),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Add individual category budgets to track specific spending areas.',
              textAlign: TextAlign.center,
              style: GoogleFonts.poppins(
                color: AppTheme.getSecondaryTextColor(context).withOpacity(0.7),
              ),
            ),
          ],
        ),
      );
    }

    return ModernCard(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
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
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: AppTheme.getHeaderPrimaryColor(context).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  '${widget.budget.categoryBudgets.length}',
                  style: GoogleFonts.poppins(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: AppTheme.getHeaderPrimaryColor(context),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          ...widget.budget.categoryBudgets.entries.map((entry) {
            final categoryBox = Hive.box<Category>('categories');
            final category = categoryBox.values.firstWhere(
              (cat) => cat.name == entry.key,
              orElse: () => Category(
                id: '999',
                name: entry.key,
                icon: Icons.category_rounded.codePoint.toString(),
                color: AppTheme.primaryTeal.value,
              ),
            );
            final categoryColor = category.color;
            final categoryIcon = IconData(int.parse(category.icon), fontFamily: 'MaterialIcons');
            final categoryName = category.name;
            return Padding(
              padding: const EdgeInsets.only(bottom: 12.0),
              child: ListTile(
                leading: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Color(categoryColor).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    categoryIcon,
                    color: Color(categoryColor),
                    size: 20,
                  ),
                ),
                title: Text(
                  categoryName,
                  style: GoogleFonts.poppins(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: AppTheme.getTextColor(context),
                  ),
                ),
                trailing: Text(
                  '\$${entry.value.toStringAsFixed(2)}',
                  style: GoogleFonts.poppins(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: AppTheme.getHeaderPrimaryColor(context),
                  ),
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                  side: BorderSide(color: AppTheme.getSecondaryTextColor(context).withOpacity(0.2)),
                ),
              ),
            );
          }).toList(),
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

  @override
  Widget build(BuildContext context) {
    return ThemedBackground(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          title: Text(
            'Edit Budget',
            style: GoogleFonts.poppins(
              fontWeight: FontWeight.w600,
              color: Colors.white,
            ),
          ),
          backgroundColor: AppTheme.getHeaderPrimaryColor(context),
          foregroundColor: Colors.white,
          elevation: 0,
          leading: IconButton(
            icon: Icon(Icons.arrow_back_rounded),
            onPressed: () => Navigator.pop(context),
          ),
          actions: [
            IconButton(
              onPressed: _showDeleteDialog,
              icon: Icon(Icons.delete_outline_rounded),
              tooltip: 'Delete Budget',
            ),
          ],
        ),
        body: SafeArea(
          child: Form(
            key: _formKey,
            child: ListView(
              padding: const EdgeInsets.all(20.0),
              children: [
                _buildBudgetTypeSection(),
                const SizedBox(height: 24),
                _buildAmountSection(),
                const SizedBox(height: 24),
                _buildDateSection(),
                const SizedBox(height: 32),
                _buildCategoryBudgetsPreview(),
                const SizedBox(height: 40),
                // Centered Update Button with Gradient
                Container(
                  height: 56,
                  decoration: AppTheme.getGradientButtonDecoration(),
                  child: ElevatedButton.icon(
                    onPressed: _updateBudget,
                    icon: const Icon(Icons.check_circle_rounded, size: 20, color: Colors.white),
                    label: Text(
                      'UPDATE BUDGET',
                      style: GoogleFonts.poppins(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                      ),
                    ),
                    style: AppTheme.getGradientButtonStyle(),
                  ),
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
}