import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:provider/provider.dart';
import 'package:smart_expense_tracker/app/theme/app_theme.dart';
import 'package:smart_expense_tracker/common_widgets/glass_card.dart';
import 'package:smart_expense_tracker/models/budget_model.dart';
import 'package:smart_expense_tracker/services/firebase_auth_service.dart';
import 'package:uuid/uuid.dart';

class AddBudgetScreen extends StatefulWidget {
  final Budget? existingBudget; // For editing mode
  final dynamic budgetKey; // For updating Hive (can be String UUID or int)
  
  const AddBudgetScreen({
    super.key,
    this.existingBudget,
    this.budgetKey,
  });

  @override
  State<AddBudgetScreen> createState() => _AddBudgetScreenState();
}

class _AddBudgetScreenState extends State<AddBudgetScreen> {
  final _totalAmountController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  BudgetType _selectedBudgetType = BudgetType.monthly;
  DateTime _selectedStartDate = DateTime.now();
  String _budgetPeriodLabel = 'This Month';

  @override
  void initState() {
    super.initState();
    
    // Load existing budget data if editing
    if (widget.existingBudget != null) {
      print('🔄 ========== EDIT MODE LOADING ==========');
      print('   Budget ID: ${widget.existingBudget!.id}');
      print('   Budget Key: ${widget.budgetKey}');
      print('   Total Amount: ${widget.existingBudget!.totalAmount}');
      
      _totalAmountController.text = widget.existingBudget!.totalAmount.toStringAsFixed(2);
      _selectedBudgetType = widget.existingBudget!.budgetType;
      _selectedStartDate = widget.existingBudget!.budgetType == BudgetType.monthly 
        ? widget.existingBudget!.month 
        : widget.existingBudget!.startDate;
      
      print('   ✅ EDIT MODE LOADING COMPLETE');
      print('   ========================================');
    }
    
    _updateBudgetPeriodLabel();
  }

  @override
  void dispose() {
    _totalAmountController.dispose();
    super.dispose();
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

  Future<void> _saveBudget() async {
    if (_formKey.currentState?.validate() ?? false) {
      final totalAmount = double.tryParse(_totalAmountController.text);
      if (totalAmount == null) return;

      // Get current user ID
      final currentUserId = context.read<AuthService>().currentUser?.uid;
      if (currentUserId == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: User not logged in'),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
          ),
        );
        return;
      }

      final budgetBox = Hive.box<Budget>('budgets');

      // Debug logging
      print('💾 ========== SAVING BUDGET ==========');
      print('   User ID: $currentUserId');
      print('   Total amount: \$${totalAmount.toStringAsFixed(2)}');

      // Check if we're editing or creating
      if (widget.existingBudget != null && widget.budgetKey != null) {
        // Update existing budget - preserve existing category budgets and userId
        final updatedBudget = Budget(
          id: widget.existingBudget!.id,
          totalAmount: totalAmount,
          categoryBudgets: widget.existingBudget!.categoryBudgets, // Preserve existing category budgets
          month: DateTime(_selectedStartDate.year, _selectedStartDate.month),
          budgetType: _selectedBudgetType,
          startDate: _selectedStartDate,
          userId: widget.existingBudget!.userId, // Preserve userId
        );

        budgetBox.put(widget.budgetKey, updatedBudget);
        
        print('✅ Budget UPDATED at key ${widget.budgetKey}');

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Budget updated successfully! 🎉'),
            backgroundColor: AppTheme.primaryTeal,
            behavior: SnackBarBehavior.floating,
          ),
        );
      } else {
        // Create new budget with empty category budgets and current userId
        final newBudget = Budget(
          id: const Uuid().v4(),
          totalAmount: totalAmount,
          categoryBudgets: {}, // Empty - category budgets added separately
          month: DateTime(_selectedStartDate.year, _selectedStartDate.month),
          budgetType: _selectedBudgetType,
          startDate: _selectedStartDate,
          userId: currentUserId, // Add current user's ID
        );

        budgetBox.put(newBudget.id, newBudget);
        
        print('✅ Budget CREATED at key ${newBudget.id} for user $currentUserId');

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${_selectedBudgetType == BudgetType.monthly ? 'Monthly' : 'Yearly'} budget created successfully! 🎉'),
            backgroundColor: AppTheme.primaryTeal,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }

      // Force Hive to notify listeners
      await budgetBox.flush();
      
      if (mounted) {
        Navigator.of(context).pop(true); // Return true to indicate success
      }
    }
  }

  // All your existing UI methods remain exactly the same:
  // _buildHeaderSection, _buildBudgetTypeSection, _buildBudgetTypeOption,
  // _buildPeriodSection, _buildOverallBudgetSection, _buildCategoryBudgetSection,
  // _buildEmptyCategoriesState, _buildCategoryInputs, _buildSaveButton

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Container(
        decoration: BoxDecoration(
          gradient: isDark
            ? LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  AppTheme.darkBackgroundGradientStart,
                  AppTheme.darkBackgroundGradientEnd,
                ],
              )
            : null,
          color: !isDark ? AppTheme.offWhite : null,
        ),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              // Custom AppBar
              _buildGradientAppBar(context, isDark),
              Expanded(
                child: ListView(
                  padding: const EdgeInsets.all(20.0),
                  children: [
                    _buildBudgetTypeSection(isDark),
                    SizedBox(height: 20),
                    _buildPeriodSection(isDark),
                    SizedBox(height: 20),
                    _buildOverallBudgetSection(isDark),
                    SizedBox(height: 32),
                    
                    // Centered Create Budget Button
                    Container(
                      height: 56,
                      decoration: AppTheme.getGradientButtonDecoration(),
                      child: ElevatedButton.icon(
                        onPressed: _saveBudget,
                        icon: Icon(
                          widget.existingBudget != null
                              ? Icons.check_circle_rounded
                              : Icons.add_circle_rounded,
                          color: Colors.white,
                          size: 20,
                        ),
                        label: Text(
                          widget.existingBudget != null
                              ? 'UPDATE BUDGET'
                              : 'CREATE BUDGET',
                          style: GoogleFonts.poppins(
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                            color: Colors.white,
                          ),
                        ),
                        style: AppTheme.getGradientButtonStyle(),
                      ),
                    ),
                    SizedBox(height: 20),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildGradientAppBar(BuildContext context, bool isDark) {
    return Container(
      decoration: AppTheme.getGlassmorphicHeaderDecoration(context),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(8, 12, 16, 16),
          child: Row(
            children: [
              IconButton(
                icon: Icon(Icons.arrow_back_rounded, 
                  color: AppTheme.getHeaderTextColor(context), size: 24),
                onPressed: () => Navigator.of(context).pop(),
                style: IconButton.styleFrom(
                  backgroundColor: AppTheme.getHeaderIconBackground(context),
                ),
              ),
              SizedBox(width: 8),
              Text(
                widget.existingBudget != null ? 'Edit Budget' : 'Create Budget',
                style: GoogleFonts.poppins(
                  fontSize: 20,
                  fontWeight: FontWeight.w600,
                  color: AppTheme.getHeaderTextColor(context),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBudgetTypeSection(bool isDark) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 4, bottom: 12),
          child: Text(
            'BUDGET TYPE',
            style: GoogleFonts.poppins(
              fontSize: 12,
              fontWeight: FontWeight.w700,
              color: isDark ? Colors.white60 : Colors.grey[600],
              letterSpacing: 1.5,
            ),
          ),
        ),
        Row(
          children: [
            Expanded(
              child: _buildBudgetTypeOption(
                type: BudgetType.monthly,
                title: 'Monthly',
                subtitle: 'Track month by month',
                icon: Icons.calendar_month_rounded,
                gradient: [
                  AppTheme.primaryTeal,
                  AppTheme.primaryTeal.withOpacity(0.7),
                ],
                isDark: isDark,
              ),
            ),
            SizedBox(width: 16),
            Expanded(
              child: _buildBudgetTypeOption(
                type: BudgetType.yearly,
                title: 'Yearly',
                subtitle: 'Annual overview',
                icon: Icons.calendar_today_rounded,
                gradient: [
                  AppTheme.accentOrange,
                  AppTheme.accentOrange.withOpacity(0.7),
                ],
                isDark: isDark,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildBudgetTypeOption({
    required BudgetType type,
    required String title,
    required String subtitle,
    required IconData icon,
    required List<Color> gradient,
    required bool isDark,
  }) {
    final isSelected = _selectedBudgetType == type;
    final primaryColor = gradient.first;
    
    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedBudgetType = type;
          _updateBudgetPeriodLabel();
        });
      },
      child: AnimatedContainer(
        duration: Duration(milliseconds: 200),
        child: isSelected
            ? Container(
                // Solid color for selected state
                padding: EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: primaryColor,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: primaryColor,
                    width: 1.5,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: primaryColor.withOpacity(0.3),
                      blurRadius: 12,
                      offset: Offset(0, 4),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    Icon(
                      icon,
                      color: Colors.white,
                      size: 32,
                    ),
                    SizedBox(height: 8),
                    Text(
                      title,
                      style: GoogleFonts.poppins(
                        fontWeight: FontWeight.w600,
                        fontSize: 15,
                        color: Colors.white,
                      ),
                    ),
                    SizedBox(height: 2),
                    Text(
                      subtitle,
                      style: GoogleFonts.poppins(
                        fontSize: 11,
                        color: Colors.white.withOpacity(0.85),
                        fontWeight: FontWeight.w400,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              )
            : GlassCard(
                // Glassmorphism for unselected state
                padding: EdgeInsets.all(16),
                borderRadius: 16,
                child: Column(
                  children: [
                    Icon(
                      icon,
                      color: primaryColor,
                      size: 32,
                    ),
                    SizedBox(height: 8),
                    Text(
                      title,
                      style: GoogleFonts.poppins(
                        fontWeight: FontWeight.w600,
                        fontSize: 15,
                        color: isDark ? Colors.white : AppTheme.darkGrey,
                      ),
                    ),
                    SizedBox(height: 2),
                    Text(
                      subtitle,
                      style: GoogleFonts.poppins(
                        fontSize: 11,
                        color: isDark ? Colors.white60 : Colors.grey[600],
                        fontWeight: FontWeight.w400,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
      ),
    );
  }

  Widget _buildPeriodSection(bool isDark) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 4, bottom: 12),
          child: Text(
            'BUDGET PERIOD',
            style: GoogleFonts.poppins(
              fontSize: 12,
              fontWeight: FontWeight.w700,
              color: isDark ? Colors.white60 : Colors.grey[600],
              letterSpacing: 1.5,
            ),
          ),
        ),
        GlassCard(
          padding: EdgeInsets.all(16),
          borderRadius: 16,
          child: InkWell(
            onTap: () => _selectStartDate(context),
            borderRadius: BorderRadius.circular(16),
            child: Row(
              children: [
                Container(
                  padding: EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppTheme.primaryTeal.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    _selectedBudgetType == BudgetType.monthly
                        ? Icons.calendar_month_rounded
                        : Icons.calendar_today_rounded,
                    color: AppTheme.primaryTeal,
                    size: 24,
                  ),
                ),
                SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _budgetPeriodLabel,
                        style: GoogleFonts.poppins(
                          fontWeight: FontWeight.w600,
                          fontSize: 16,
                          color: isDark ? Colors.white : AppTheme.darkGrey,
                        ),
                      ),
                      SizedBox(height: 2),
                      Text(
                        'Tap to change period',
                        style: GoogleFonts.poppins(
                          fontSize: 12,
                          color: isDark ? Colors.white60 : Colors.grey[500],
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                    ],
                  ),
                ),
                Icon(
                  Icons.arrow_forward_ios_rounded,
                  size: 16,
                  color: isDark ? Colors.white38 : Colors.grey[400],
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildOverallBudgetSection(bool isDark) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 4, bottom: 12),
          child: Text(
            'TOTAL BUDGET AMOUNT',
            style: GoogleFonts.poppins(
              fontSize: 12,
              fontWeight: FontWeight.w700,
              color: isDark ? Colors.white60 : Colors.grey[600],
              letterSpacing: 1.5,
            ),
          ),
        ),
        Container(
          decoration: BoxDecoration(
            color: AppTheme.primaryTeal.withOpacity(isDark ? 0.1 : 0.05),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: AppTheme.primaryTeal.withOpacity(isDark ? 0.3 : 0.15),
              width: 1.5,
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                GlassBadge(
                  padding: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  borderRadius: 12,
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        _selectedBudgetType == BudgetType.monthly
                            ? Icons.calendar_month_rounded
                            : Icons.calendar_today_rounded,
                        size: 14,
                        color: AppTheme.primaryTeal,
                      ),
                      SizedBox(width: 6),
                      Text(
                        _selectedBudgetType == BudgetType.monthly ? 'MONTHLY' : 'YEARLY',
                        style: GoogleFonts.poppins(
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          color: AppTheme.primaryTeal,
                          letterSpacing: 0.8,
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 20),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(top: 6),
                      child: Text(
                        '\$',
                        style: GoogleFonts.poppins(
                          fontSize: 32,
                          fontWeight: FontWeight.w700,
                          color: AppTheme.primaryTeal,
                          height: 1,
                        ),
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
                          fontWeight: FontWeight.w700,
                          color: AppTheme.primaryTeal,
                          height: 1.1,
                        ),
                        decoration: InputDecoration(
                          hintText: '0.00',
                          hintStyle: GoogleFonts.poppins(
                            fontSize: 42,
                            fontWeight: FontWeight.w700,
                            color: AppTheme.primaryTeal.withOpacity(0.2),
                            height: 1.1,
                          ),
                          border: InputBorder.none,
                          focusedBorder: InputBorder.none,
                          enabledBorder: InputBorder.none,
                          errorBorder: InputBorder.none,
                          focusedErrorBorder: InputBorder.none,
                          contentPadding: EdgeInsets.zero,
                          isDense: true,
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
                SizedBox(height: 16),
                GlassCard(
                  padding: EdgeInsets.all(12),
                  borderRadius: 10,
                  blur: 5,
                  child: Row(
                    children: [
                      Icon(
                        Icons.info_outline_rounded,
                        size: 16,
                        color: AppTheme.accentOrange,
                      ),
                      SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          'This is your total spending limit for ${_selectedBudgetType == BudgetType.monthly ? 'the month' : 'the year'}',
                          style: GoogleFonts.poppins(
                            fontSize: 12,
                            color: isDark ? Colors.white70 : Colors.grey[700],
                            fontWeight: FontWeight.w400,
                            height: 1.3,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}