import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:provider/provider.dart';
import 'package:smart_expense_tracker/app/theme/app_theme.dart';
import 'package:smart_expense_tracker/common_widgets/glassmorphic_card.dart';
import 'package:smart_expense_tracker/common_widgets/modern_text_field.dart';
import 'package:smart_expense_tracker/common_widgets/themed_background.dart';
import 'package:smart_expense_tracker/models/expense_model.dart';
import 'package:smart_expense_tracker/models/category_model.dart';
import 'package:smart_expense_tracker/models/budget_model.dart';
import 'package:smart_expense_tracker/services/firebase_auth_service.dart';
import 'package:uuid/uuid.dart';

class AddExpenseScreen extends StatefulWidget {
  final Expense? editingExpense;
  const AddExpenseScreen({Key? key, this.editingExpense}) : super(key: key);

  @override
  State<AddExpenseScreen> createState() => _AddExpenseScreenState();
}

class _AddExpenseScreenState extends State<AddExpenseScreen> with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _amountController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _vendorController = TextEditingController();

  String? _selectedCategoryId;
  DateTime _selectedDate = DateTime.now();
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeOut),
    );
    _animationController.forward();
    
    // If editing, pre-fill fields
    if (widget.editingExpense != null) {
      final exp = widget.editingExpense!;
      _amountController.text = exp.amount.toStringAsFixed(2);
      _descriptionController.text = exp.description;
      _vendorController.text = exp.vendor;
      _selectedDate = exp.date;
      
      // Find category id by name
      final categoryBox = Hive.box<Category>('categories');
      final cat = categoryBox.values.firstWhere(
        (c) => c.name == exp.category,
        orElse: () => Category(
          id: '999',
          name: exp.category,
          icon: Icons.category_rounded.codePoint.toString(),
          color: AppTheme.primaryTeal.value,
        ),
      );
      _selectedCategoryId = cat.id;
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    _amountController.dispose();
    _descriptionController.dispose();
    _vendorController.dispose();
    super.dispose();
  }

  void _saveExpense() {
    if (_formKey.currentState!.validate()) {
      final amount = double.tryParse(_amountController.text);
      final description = _descriptionController.text.trim();
      final vendor = _vendorController.text.trim();

      if (amount != null && _selectedCategoryId != null) {
        final expenseBox = Hive.box<Expense>('expenses');
        final budgetBox = Hive.box<Budget>('budgets');
        final now = DateTime.now();
        // Find current budget for selected view
        final budgets = budgetBox.values.toList();
        Budget? currentBudget;
        for (var budget in budgets) {
          if (budget.budgetType == BudgetType.monthly && budget.month.year == now.year && budget.month.month == now.month) {
            currentBudget = budget;
            break;
          }
        }
        if (currentBudget == null) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('No active monthly budget found.'),
              backgroundColor: Colors.red,
            ),
          );
          return;
        }
        // Validate against category budget
        final categoryBudget = currentBudget.categoryBudgets[_selectedCategoryId!] ?? 0.0;
        // Calculate spent in this category for this month
        final expenses = expenseBox.values.where((e) =>
          e.category == _selectedCategoryId &&
          e.date.year == currentBudget!.month.year &&
          e.date.month == currentBudget.month.month
        ).toList();
        final spent = expenses.fold(0.0, (sum, e) => sum + e.amount);
        // Allow adding expense even if category budget is zero
        if (categoryBudget > 0 && spent + amount > categoryBudget) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Total expenses for this category this month will exceed its budget!'),
              backgroundColor: Colors.red,
            ),
          );
          return;
        }
        // Optionally, warn if expense exceeds main budget
        if (amount > currentBudget.totalAmount) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Expense amount exceeds main budget!'),
              backgroundColor: Colors.red,
            ),
          );
          return;
        }
        final selectedCategory = Hive.box<Category>('categories').get(_selectedCategoryId);
        final categoryName = selectedCategory?.name ?? _selectedCategoryId!;
        if (widget.editingExpense != null) {
          // Update existing expense by creating a new object and saving it
          final exp = widget.editingExpense!;
          final updatedExpense = Expense(
            id: exp.id,
            userId: exp.userId,
            category: categoryName,
            description: description.isNotEmpty ? description : 'No description',
            amount: amount,
            date: _selectedDate,
            vendor: vendor.isNotEmpty ? vendor : 'General',
          );
          expenseBox.put(exp.id, updatedExpense);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Row(
                children: [
                  Icon(Icons.edit_rounded, color: Colors.white),
                  SizedBox(width: 8),
                  Text('Expense updated!'),
                ],
              ),
              backgroundColor: AppTheme.getPrimaryColor(context),
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
          );
          Navigator.of(context).pop();
        } else {
          // Add expense - Get current user ID
          final currentUserId = context.read<AuthService>().currentUser?.uid ?? 'guest';
          
          final newExpense = Expense(
            id: const Uuid().v4(),
            userId: currentUserId,
            category: categoryName, // Use category name for matching
            description: description.isNotEmpty ? description : 'No description',
            amount: amount,
            date: _selectedDate,
            vendor: vendor.isNotEmpty ? vendor : 'General',
          );
          expenseBox.put(newExpense.id, newExpense);
          _animationController.reverse().then((_) {
            _animationController.forward();
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Row(
                  children: [
                    Icon(Icons.celebration_rounded, color: Colors.white),
                    SizedBox(width: 8),
                    Text('Expense added! 💫'),
                  ],
                ),
                backgroundColor: AppTheme.getPrimaryColor(context),
                behavior: SnackBarBehavior.floating,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
            );
            Navigator.of(context).pop();
          });
        }
      } else if (_selectedCategoryId == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Please select a category.'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return Scaffold(
      body: ThemedBackground(
        child: Column(
          children: [
            _buildHeader(context, isDark),
            Expanded(
              child: FadeTransition(
                opacity: _fadeAnimation,
                child: _buildForm(context, isDark),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context, bool isDark) {
    return Container(
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
              Material(
                color: AppTheme.getHeaderIconBackground(context),
                borderRadius: BorderRadius.circular(12),
                child: InkWell(
                  onTap: () => Navigator.pop(context),
                  borderRadius: BorderRadius.circular(12),
                  child: Padding(
                    padding: const EdgeInsets.all(10),
                    child: Icon(
                      Icons.arrow_back_rounded, 
                      color: AppTheme.getHeaderTextColor(context), 
                      size: 22,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.editingExpense == null ? 'Add Expense' : 'Edit Expense',
                      style: GoogleFonts.poppins(
                        fontSize: 26,
                        fontWeight: FontWeight.w700,
                        color: AppTheme.getHeaderTextColor(context),
                        letterSpacing: -0.5,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Track your spending efficiently',
                      style: GoogleFonts.poppins(
                        fontSize: 13,
                        color: isDark 
                          ? AppTheme.getHeaderTextColor(context).withValues(alpha: 0.7)
                          : Colors.white.withValues(alpha: 0.85),
                        letterSpacing: 0.2,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildForm(BuildContext context, bool isDark) {
    return Form(
      key: _formKey,
      child: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          _buildAmountField(context, isDark),
          const SizedBox(height: 16),
          _buildCategorySelector(context, isDark),
          const SizedBox(height: 16),
          _buildDescriptionField(context, isDark),
          const SizedBox(height: 16),
          _buildVendorField(context, isDark),
          const SizedBox(height: 16),
          _buildDateSelector(context, isDark),
          const SizedBox(height: 32),
          _buildSaveButton(context, isDark),
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  Widget _buildAmountField(BuildContext context, bool isDark) {
    return GlassmorphicCard(
      blur: 15,
      opacity: isDark ? 0.08 : 0.5,
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        AppTheme.getPrimaryColor(context),
                        AppTheme.getPrimaryColor(context).withOpacity(0.7),
                      ],
                    ),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(Icons.attach_money_rounded, size: 18, color: Colors.white),
                ),
                const SizedBox(width: 12),
                Text(
                  'AMOUNT',
                  style: GoogleFonts.poppins(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    color: AppTheme.getSecondaryTextColor(context),
                    letterSpacing: 1.2,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            ModernTextField(
              controller: _amountController,
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              prefixText: '\$ ',
              hintText: '0.00',
              validator: (value) {
                if (value == null || value.isEmpty) return 'Enter amount';
                final amount = double.tryParse(value);
                if (amount == null || amount <= 0) return 'Enter valid amount';
                return null;
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCategorySelector(BuildContext context, bool isDark) {
    return GlassmorphicCard(
      blur: 15,
      opacity: isDark ? 0.08 : 0.5,
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        AppTheme.accentOrange,
                        AppTheme.accentOrange.withOpacity(0.7),
                      ],
                    ),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(Icons.category_rounded, size: 18, color: Colors.white),
                ),
                const SizedBox(width: 12),
                Text(
                  'CATEGORY',
                  style: GoogleFonts.poppins(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    color: AppTheme.getSecondaryTextColor(context),
                    letterSpacing: 1.2,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            ValueListenableBuilder<Box<Category>>(
              valueListenable: Hive.box<Category>('categories').listenable(),
              builder: (context, box, _) {
                final categories = box.values.toList();
                if (categories.isEmpty) {
                  return Text(
                    'No categories available',
                    style: GoogleFonts.poppins(
                      color: AppTheme.getSecondaryTextColor(context),
                      fontSize: 14,
                    ),
                  );
                }
                
                return Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: categories.map((cat) {
                    final isSelected = _selectedCategoryId == cat.id;
                    final color = Color(cat.color);
                    
                    return Material(
                      color: isSelected
                          ? color.withOpacity(0.15)
                          : (isDark ? Colors.white.withOpacity(0.05) : Colors.grey.shade100),
                      borderRadius: BorderRadius.circular(16),
                      child: InkWell(
                        onTap: () => setState(() => _selectedCategoryId = cat.id),
                        borderRadius: BorderRadius.circular(16),
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                          decoration: BoxDecoration(
                            border: Border.all(
                              color: isSelected ? color : Colors.transparent,
                              width: 2,
                            ),
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                IconData(int.parse(cat.icon), fontFamily: 'MaterialIcons'),
                                size: 16,
                                color: isSelected ? color : AppTheme.getSecondaryTextColor(context),
                              ),
                              const SizedBox(width: 6),
                              Text(
                                cat.name,
                                style: GoogleFonts.poppins(
                                  fontSize: 12,
                                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                                  color: isSelected ? color : AppTheme.getTextColor(context),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  }).toList(),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDescriptionField(BuildContext context, bool isDark) {
    return GlassmorphicCard(
      blur: 15,
      opacity: isDark ? 0.08 : 0.5,
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        AppTheme.infoBlue,
                        AppTheme.infoBlue.withOpacity(0.7),
                      ],
                    ),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(Icons.description_rounded, size: 18, color: Colors.white),
                ),
                const SizedBox(width: 12),
                Text(
                  'DESCRIPTION',
                  style: GoogleFonts.poppins(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    color: AppTheme.getSecondaryTextColor(context),
                    letterSpacing: 1.2,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            ModernTextField(
              controller: _descriptionController,
              hintText: 'What did you spend on?',
              maxLines: 2,
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Enter description';
                }
                return null;
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildVendorField(BuildContext context, bool isDark) {
    return GlassmorphicCard(
      blur: 15,
      opacity: isDark ? 0.08 : 0.5,
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        Colors.purple,
                        Colors.purple.withOpacity(0.7),
                      ],
                    ),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(Icons.store_rounded, size: 18, color: Colors.white),
                ),
                const SizedBox(width: 12),
                Text(
                  'VENDOR',
                  style: GoogleFonts.poppins(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    color: AppTheme.getSecondaryTextColor(context),
                    letterSpacing: 1.2,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            ModernTextField(
              controller: _vendorController,
              hintText: 'Where did you buy?',
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Enter vendor name';
                }
                return null;
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDateSelector(BuildContext context, bool isDark) {
    // Create a controller for the date field
    final dateController = TextEditingController();
    dateController.text = '${_selectedDate.day}/${_selectedDate.month}/${_selectedDate.year}';
    
    return GlassmorphicCard(
      blur: 15,
      opacity: isDark ? 0.08 : 0.5,
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: AppTheme.successGreen.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    Icons.calendar_today_rounded,
                    size: 16,
                    color: AppTheme.successGreen,
                  ),
                ),
                const SizedBox(width: 12),
                Text(
                  'EXPENSE DATE',
                  style: GoogleFonts.poppins(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: AppTheme.getTextColor(context).withOpacity(0.6),
                    letterSpacing: 1,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            ModernDateField(
              controller: dateController,
              hintText: 'Select expense date',
              initialDate: _selectedDate,
              firstDate: DateTime(2020),
              lastDate: DateTime.now(),
              onDateSelected: (DateTime? date) {
                if (date != null) {
                  setState(() {
                    _selectedDate = date;
                    dateController.text = '${date.day}/${date.month}/${date.year}';
                  });
                }
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSaveButton(BuildContext context, bool isDark) {
    return Container(
      height: 56,
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [AppTheme.accentOrange, Color(0xFFFF8A50)],
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: AppTheme.accentOrange.withOpacity(0.4),
            blurRadius: 16,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: ElevatedButton(
        onPressed: _saveExpense,
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.transparent,
          shadowColor: Colors.transparent,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.check_circle_rounded, size: 24, color: Colors.white),
            const SizedBox(width: 12),
            Text(
              widget.editingExpense == null ? 'ADD EXPENSE' : 'UPDATE EXPENSE',
              style: GoogleFonts.poppins(
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: Colors.white,
                letterSpacing: 0.5,
              ),
            ),
          ],
        ),
      ),
    );
  }
}