import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:smart_expense_tracker/app/theme/app_theme.dart';
import 'package:smart_expense_tracker/common_widgets/modern_card.dart';
import 'package:smart_expense_tracker/common_widgets/primary_button.dart';
import 'package:smart_expense_tracker/models/budget_model.dart';
import 'package:smart_expense_tracker/models/category_model.dart';
import 'package:uuid/uuid.dart';

class AddBudgetScreen extends StatefulWidget {
  const AddBudgetScreen({super.key});

  @override
  State<AddBudgetScreen> createState() => _AddBudgetScreenState();
}

class _AddBudgetScreenState extends State<AddBudgetScreen> {
  final _totalAmountController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  final Map<String, TextEditingController> _categoryControllers = {};

  double _categoryTotal = 0.0;
  BudgetType _selectedBudgetType = BudgetType.monthly;
  DateTime _selectedStartDate = DateTime.now();
  String _budgetPeriodLabel = 'This Month';

  @override
  void initState() {
    super.initState();
    _updateBudgetPeriodLabel();
  }

  @override
  void dispose() {
    _totalAmountController.dispose();
    for (var controller in _categoryControllers.values) {
      controller.dispose();
    }
    super.dispose();
  }

  void _updateCategoryTotal() {
    double total = 0.0;
    _categoryControllers.forEach((key, controller) {
      final amount = double.tryParse(controller.text) ?? 0.0;
      total += amount;
    });
    setState(() {
      _categoryTotal = total;
    });
  }

  void _updateBudgetPeriodLabel() {
    final now = DateTime.now();
    if (_selectedBudgetType == BudgetType.monthly) {
      setState(() {
        _budgetPeriodLabel = '${_getMonthName(_selectedStartDate.month)} ${_selectedStartDate.year}';
      });
    } else {
      setState(() {
        _budgetPeriodLabel = 'Year ${_selectedStartDate.year}';
      });
    }
  }

  String _getMonthName(int month) {
    const months = [
      'January', 'February', 'March', 'April', 'May', 'June',
      'July', 'August', 'September', 'October', 'November', 'December'
    ];
    return months[month - 1];
  }

  Future<void> _selectStartDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedStartDate,
      firstDate: DateTime(2020),
      lastDate: DateTime(2030),
    );
    if (picked != null && picked != _selectedStartDate) {
      setState(() {
        _selectedStartDate = picked;
        _updateBudgetPeriodLabel();
      });
    }
  }

  void _saveBudget() {
    if (_formKey.currentState?.validate() ?? false) {
      final totalAmount = double.tryParse(_totalAmountController.text);
      if (totalAmount == null) return;

      if (_categoryTotal > totalAmount) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Category budgets exceed total budget!'),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
          ),
        );
        return;
      }

      final Map<String, double> categoryBudgets = {};
      _categoryControllers.forEach((key, controller) {
        final amount = double.tryParse(controller.text);
        if (amount != null && amount > 0) {
          categoryBudgets[key] = amount;
        }
      });

      final budgetBox = Hive.box<Budget>('budgets');
      final newBudget = Budget(
        id: const Uuid().v4(),
        totalAmount: totalAmount,
        categoryBudgets: categoryBudgets,
        month: DateTime(_selectedStartDate.year, _selectedStartDate.month),
        budgetType: _selectedBudgetType,
        startDate: _selectedStartDate,
      );

      budgetBox.put(newBudget.id, newBudget);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('${_selectedBudgetType == BudgetType.monthly ? 'Monthly' : 'Yearly'} budget created successfully! 🎉'),
          backgroundColor: AppTheme.primaryTeal,
          behavior: SnackBarBehavior.floating,
        ),
      );

      Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.offWhite,
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(Icons.arrow_back_rounded, color: Colors.white),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(
          'Create Budget',
          style: GoogleFonts.poppins(
            fontWeight: FontWeight.w600,
          ),
        ),
        backgroundColor: AppTheme.primaryTeal,
        foregroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
      ),
      body: Form(
        key: _formKey,
        child: Column(
          children: [
            Expanded(
              child: ListView(
                padding: const EdgeInsets.all(20.0),
                children: [
                  _buildHeaderSection(),
                  const SizedBox(height: 24),
                  _buildBudgetTypeSection(),
                  const SizedBox(height: 16),
                  _buildPeriodSection(),
                  const SizedBox(height: 24),
                  _buildOverallBudgetSection(),
                  const SizedBox(height: 24),
                  _buildCategoryBudgetSection(),
                ],
              ),
            ),
            _buildSaveButton(),
          ],
        ),
      ),
    );
  }

  Widget _buildHeaderSection() {
    return ModernCard(
      padding: EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppTheme.primaryTeal.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.account_balance_wallet_rounded,
                  color: AppTheme.primaryTeal,
                  size: 24,
                ),
              ),
              SizedBox(width: 12),
              Expanded(
                child: Text(
                  'Budget Planner',
                  style: GoogleFonts.poppins(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: AppTheme.primaryTeal,
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 12),
          Text(
            'Plan your ${_selectedBudgetType == BudgetType.monthly ? 'monthly' : 'yearly'} spending and track your financial goals effectively.',
            style: GoogleFonts.poppins(
              fontSize: 14,
              color: Colors.grey[600],
              height: 1.4,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBudgetTypeSection() {
    return ModernCard(
      padding: EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'BUDGET TYPE',
            style: GoogleFonts.poppins(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: Colors.grey[600],
              letterSpacing: 1,
            ),
          ),
          SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _buildBudgetTypeOption(
                  type: BudgetType.monthly,
                  title: 'Monthly',
                  subtitle: 'Plan month by month',
                  icon: Icons.calendar_month_rounded,
                ),
              ),
              SizedBox(width: 12),
              Expanded(
                child: _buildBudgetTypeOption(
                  type: BudgetType.yearly,
                  title: 'Yearly',
                  subtitle: 'Annual overview',
                  icon: Icons.calendar_today_rounded,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildBudgetTypeOption({
    required BudgetType type,
    required String title,
    required String subtitle,
    required IconData icon,
  }) {
    final isSelected = _selectedBudgetType == type;
    return InkWell(
      onTap: () {
        setState(() {
          _selectedBudgetType = type;
          _updateBudgetPeriodLabel();
        });
      },
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isSelected ? AppTheme.primaryTeal.withOpacity(0.1) : Colors.grey[50],
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? AppTheme.primaryTeal : Colors.grey[300]!,
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Column(
          children: [
            Icon(
              icon,
              color: isSelected ? AppTheme.primaryTeal : Colors.grey[600],
              size: 24,
            ),
            SizedBox(height: 8),
            Text(
              title,
              style: GoogleFonts.poppins(
                fontWeight: FontWeight.w600,
                color: isSelected ? AppTheme.primaryTeal : AppTheme.darkGrey,
              ),
            ),
            SizedBox(height: 4),
            Text(
              subtitle,
              style: GoogleFonts.poppins(
                fontSize: 11,
                color: isSelected ? AppTheme.primaryTeal : Colors.grey[500],
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPeriodSection() {
    return ModernCard(
      padding: EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'BUDGET PERIOD',
            style: GoogleFonts.poppins(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: Colors.grey[600],
              letterSpacing: 1,
            ),
          ),
          SizedBox(height: 12),
          InkWell(
            onTap: () => _selectStartDate(context),
            borderRadius: BorderRadius.circular(12),
            child: Container(
              padding: EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.grey[50],
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.grey[300]!),
              ),
              child: Row(
                children: [
                  Icon(
                    _selectedBudgetType == BudgetType.monthly
                        ? Icons.calendar_month_rounded
                        : Icons.calendar_today_rounded,
                    color: AppTheme.primaryTeal,
                  ),
                  SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          _budgetPeriodLabel,
                          style: GoogleFonts.poppins(
                            fontWeight: FontWeight.w600,
                            color: AppTheme.darkGrey,
                          ),
                        ),
                        SizedBox(height: 2),
                        Text(
                          _selectedBudgetType == BudgetType.monthly
                              ? 'Monthly Budget Period'
                              : 'Yearly Budget Period',
                          style: GoogleFonts.poppins(
                            fontSize: 12,
                            color: Colors.grey[500],
                          ),
                        ),
                      ],
                    ),
                  ),
                  Icon(Icons.arrow_forward_ios_rounded, size: 16, color: Colors.grey[500]),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOverallBudgetSection() {
    return ModernCard(
      padding: EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'OVERALL BUDGET',
                style: GoogleFonts.poppins(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: Colors.grey[600],
                  letterSpacing: 1,
                ),
              ),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: AppTheme.primaryTeal.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  _selectedBudgetType == BudgetType.monthly ? 'MONTHLY' : 'YEARLY',
                  style: GoogleFonts.poppins(
                    fontSize: 10,
                    fontWeight: FontWeight.w600,
                    color: AppTheme.primaryTeal,
                    letterSpacing: 1,
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 16),
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                '\$',
                style: GoogleFonts.poppins(
                  fontSize: 32,
                  fontWeight: FontWeight.w700,
                  color: AppTheme.primaryTeal.withOpacity(0.6),
                  height: 1,
                ),
              ),
              SizedBox(width: 8),
              Expanded(
                child: TextFormField(
                  controller: _totalAmountController,
                  textAlign: TextAlign.start,
                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                  style: GoogleFonts.poppins(
                    fontSize: 42,
                    fontWeight: FontWeight.w800,
                    color: AppTheme.primaryTeal,
                    height: 1,
                  ),
                  decoration: InputDecoration(
                    hintText: '0.00',
                    hintStyle: GoogleFonts.poppins(
                      fontSize: 42,
                      fontWeight: FontWeight.w800,
                      color: AppTheme.primaryTeal.withOpacity(0.2),
                      height: 1,
                    ),
                    border: InputBorder.none,
                    focusedBorder: InputBorder.none,
                    enabledBorder: InputBorder.none,
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter your total budget';
                    }
                    if ((double.tryParse(value) ?? 0) <= 0) {
                      return 'Budget must be greater than 0';
                    }
                    return null;
                  },
                ),
              ),
            ],
          ),
          SizedBox(height: 8),
          Divider(color: Colors.grey[200]),
          SizedBox(height: 8),
          Text(
            'This is your total spending limit for the ${_selectedBudgetType == BudgetType.monthly ? 'month' : 'year'}',
            style: GoogleFonts.poppins(
              fontSize: 13,
              color: Colors.grey[500],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryBudgetSection() {
    return ValueListenableBuilder<Box<Category>>(
      valueListenable: Hive.box<Category>('categories').listenable(),
      builder: (context, box, _) {
        final categories = box.values.toList();

        for (var category in categories) {
          if (!_categoryControllers.containsKey(category.name)) {
            _categoryControllers[category.name] = TextEditingController();
          }
        }

        return ModernCard(
          padding: EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'CATEGORY BUDGETS',
                    style: GoogleFonts.poppins(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: Colors.grey[600],
                      letterSpacing: 1,
                    ),
                  ),
                  Text(
                    'Total: \$$_categoryTotal',
                    style: GoogleFonts.poppins(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: _categoryTotal == 0 ? Colors.grey : AppTheme.accentOrange,
                    ),
                  ),
                ],
              ),
              SizedBox(height: 8),
              Text(
                'Set individual limits for each category (optional)',
                style: GoogleFonts.poppins(
                  fontSize: 13,
                  color: Colors.grey[500],
                ),
              ),
              SizedBox(height: 20),

              if (categories.isEmpty)
                _buildEmptyCategoriesState()
              else
                ..._buildCategoryInputs(categories),
            ],
          ),
        );
      },
    );
  }

  Widget _buildEmptyCategoriesState() {
    return Container(
      padding: EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.orange[50],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.orange[100]!),
      ),
      child: Row(
        children: [
          Icon(Icons.info_outline_rounded, color: Colors.orange),
          SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'No Categories Found',
                  style: GoogleFonts.poppins(
                    fontWeight: FontWeight.w600,
                    color: Colors.orange[800],
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  'Create expense categories first to set individual budgets.',
                  style: GoogleFonts.poppins(
                    fontSize: 13,
                    color: Colors.orange[700],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  List<Widget> _buildCategoryInputs(List<Category> categories) {
    return categories.map((category) {
      return Padding(
        padding: const EdgeInsets.only(bottom: 16.0),
        child: Container(
          padding: EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.grey[50],
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.grey[200]!),
          ),
          child: Row(
            children: [
              Container(
                padding: EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppTheme.primaryTeal.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  IconData(int.parse(category.icon), fontFamily: 'MaterialIcons'),
                  size: 20,
                  color: AppTheme.primaryTeal,
                ),
              ),
              SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      category.name,
                      style: GoogleFonts.poppins(
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
              SizedBox(
                width: 120,
                child: TextFormField(
                  controller: _categoryControllers[category.name],
                  textAlign: TextAlign.right,
                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                  onChanged: (value) => _updateCategoryTotal(),
                  style: GoogleFonts.poppins(
                    fontWeight: FontWeight.w600,
                    color: AppTheme.primaryTeal,
                  ),
                  decoration: InputDecoration(
                    prefixText: '\$ ',
                    prefixStyle: GoogleFonts.poppins(
                      fontWeight: FontWeight.w600,
                      color: AppTheme.primaryTeal.withOpacity(0.6),
                    ),
                    border: InputBorder.none,
                    hintText: '0.00',
                    hintStyle: TextStyle(color: Colors.grey[400]),
                    isDense: true,
                    contentPadding: EdgeInsets.zero,
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    }).toList();
  }

  Widget _buildSaveButton() {
    return Container(
      padding: EdgeInsets.fromLTRB(20, 16, 20, 32),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 8,
            offset: Offset(0, -2),
          ),
        ],
      ),
      child: PrimaryButton(
        text: 'CREATE ${_selectedBudgetType == BudgetType.monthly ? 'MONTHLY' : 'YEARLY'} BUDGET',
        onPressed: _saveBudget,
      ),
    );
  }
}