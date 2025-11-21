import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:provider/provider.dart';
import 'package:smart_expense_tracker/app/theme/app_theme.dart';
import 'package:smart_expense_tracker/common_widgets/glassmorphic_card.dart';
import 'package:smart_expense_tracker/common_widgets/modern_text_field.dart';
import 'package:smart_expense_tracker/common_widgets/themed_background.dart';
import 'package:smart_expense_tracker/models/goal_model.dart';
import 'package:smart_expense_tracker/services/firebase_auth_service.dart';

class AddGoalScreen extends StatefulWidget {
  const AddGoalScreen({super.key});

  @override
  State<AddGoalScreen> createState() => _AddGoalScreenState();
}

class _AddGoalScreenState extends State<AddGoalScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _goalNameController = TextEditingController();
  final TextEditingController _targetAmountController = TextEditingController();
  final TextEditingController _currentAmountController = TextEditingController();
  final TextEditingController _targetDateController = TextEditingController();

  DateTime? _selectedTargetDate;

  String _selectedGoalType = 'Savings';

  @override
  void dispose() {
    _goalNameController.dispose();
    _targetAmountController.dispose();
    _currentAmountController.dispose();
    _targetDateController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ThemedBackground(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: Column(
          children: [
            _buildHeaderSection(),
            Expanded(
              child: _buildGoalForm(),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _createGoal() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    final goalName = _goalNameController.text.trim();
    final targetAmount = double.tryParse(_targetAmountController.text) ?? 0.0;
    final currentAmount = double.tryParse(_currentAmountController.text) ?? 0.0;

    if (currentAmount > targetAmount) {
      _showError('Current amount cannot be greater than target amount');
      return;
    }

    // Get current user ID
    final currentUserId = context.read<AuthService>().currentUser?.uid;
    if (currentUserId == null) {
      _showError('User not authenticated');
      return;
    }

    try {
      final newGoal = Goal(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        userId: currentUserId, // Use actual user ID
        name: goalName,
        targetAmount: targetAmount,
        currentAmount: currentAmount,
        targetDate: _selectedTargetDate,
        goalType: _selectedGoalType,
      );

      final goalsBox = Hive.box<Goal>('goals');
      await goalsBox.add(newGoal);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Goal "$goalName" created successfully!'),
            backgroundColor: AppTheme.getPrimaryTealColor(context),
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          ),
        );

        Navigator.of(context).pop();
      }
    } catch (e) {
      if (mounted) {
        _showError('Failed to create goal. Please try again.');
      }
    }
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
    );
  }

  Widget _buildHeaderSection() {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return Container(
      width: double.infinity,
      padding: EdgeInsets.only(
        top: MediaQuery.of(context).padding.top + 16,
        bottom: 20,
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
              IconButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                icon: Icon(
                  Icons.arrow_back_rounded, 
                  color: AppTheme.getHeaderTextColor(context),
                ),
                style: IconButton.styleFrom(
                  backgroundColor: AppTheme.getHeaderIconBackground(context),
                  padding: const EdgeInsets.all(8),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Create New Goal',
                      style: GoogleFonts.poppins(
                        fontSize: 24,
                        fontWeight: FontWeight.w700,
                        color: AppTheme.getHeaderTextColor(context),
                        height: 1.2,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Set your financial target and track progress',
                      style: GoogleFonts.poppins(
                        fontSize: 14,
                        color: isDark 
                          ? AppTheme.getHeaderTextColor(context).withValues(alpha: 0.7)
                          : Colors.white.withValues(alpha: 0.8),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Quick Tips
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: AppTheme.getHeaderIconBackground(context),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  Icons.lightbulb_rounded, 
                  size: 16, 
                  color: AppTheme.getHeaderTextColor(context),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  'Set realistic goals and track your progress regularly',
                  style: GoogleFonts.poppins(
                    fontSize: 12,
                    color: isDark 
                      ? AppTheme.getHeaderTextColor(context).withValues(alpha: 0.8)
                      : Colors.white.withValues(alpha: 0.9),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildGoalForm() {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return Padding(
      padding: const EdgeInsets.all(20.0),
      child: Form(
        key: _formKey,
        child: ListView(
          children: [
            // Goal Name Card
            GlassmorphicCard(
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
                            color: AppTheme.getPrimaryTealColor(context).withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Icon(
                            Icons.flag_rounded,
                            size: 16,
                            color: AppTheme.getPrimaryTealColor(context),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Text(
                          'GOAL NAME',
                          style: GoogleFonts.poppins(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: AppTheme.getTextColor(context).withValues(alpha: 0.6),
                            letterSpacing: 1,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    ModernTextField(
                      controller: _goalNameController,
                      labelText: 'Goal Name',
                      hintText: 'e.g., New Laptop, Vacation, Emergency Fund...',
                      prefixIcon: const Icon(Icons.flag_rounded),
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Please enter a goal name';
                        }
                        return null;
                      },
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Goal Type Selection
            GlassmorphicCard(
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
                            color: AppTheme.accentOrange.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Icon(
                            Icons.category_rounded,
                            size: 16,
                            color: AppTheme.accentOrange,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Text(
                          'GOAL TYPE',
                          style: GoogleFonts.poppins(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: AppTheme.getTextColor(context).withValues(alpha: 0.6),
                            letterSpacing: 1,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Wrap(
                      spacing: 12,
                      runSpacing: 12,
                      children: _getGoalTypes(context).map((type) {
                        final isSelected = _selectedGoalType == type['label'];
                        final typeColor = type['color'] as Color;
                        return GestureDetector(
                          onTap: () {
                            setState(() {
                              _selectedGoalType = type['label'] as String;
                            });
                          },
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                            decoration: BoxDecoration(
                              gradient: isSelected 
                                ? LinearGradient(
                                    colors: [
                                      typeColor.withValues(alpha: 0.2),
                                      typeColor.withValues(alpha: 0.1),
                                    ],
                                  )
                                : null,
                              color: !isSelected
                                ? isDark 
                                    ? AppTheme.darkCard.withValues(alpha: 0.5)
                                    : Colors.grey[100]
                                : null,
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(
                                color: isSelected ? typeColor : Colors.transparent,
                                width: 2,
                              ),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  type['icon'] as IconData,
                                  size: 16,
                                  color: isSelected 
                                    ? typeColor 
                                    : AppTheme.getSecondaryTextColor(context),
                                ),
                                const SizedBox(width: 6),
                                Text(
                                  type['label'] as String,
                                  style: GoogleFonts.poppins(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w600,
                                    color: isSelected 
                                      ? typeColor 
                                      : AppTheme.getSecondaryTextColor(context),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Amounts Card
            GlassmorphicCard(
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
                            color: AppTheme.getSuccessColor(context).withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Icon(
                            Icons.attach_money_rounded,
                            size: 16,
                            color: AppTheme.getSuccessColor(context),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Text(
                          'AMOUNTS',
                          style: GoogleFonts.poppins(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: AppTheme.getTextColor(context).withValues(alpha: 0.6),
                            letterSpacing: 1,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(
                          child: ModernTextField(
                            controller: _targetAmountController,
                            labelText: 'Target Amount',
                            hintText: '0.00',
                            prefixIcon: const Icon(Icons.account_balance_wallet_rounded),
                            keyboardType: const TextInputType.numberWithOptions(decimal: true),
                            prefixText: '\$ ',
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Please enter target amount';
                              }
                              if (double.tryParse(value) == null || double.parse(value) <= 0) {
                                return 'Please enter a valid amount';
                              }
                              return null;
                            },
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: ModernTextField(
                            controller: _currentAmountController,
                            labelText: 'Current Amount',
                            hintText: '0.00',
                            prefixIcon: const Icon(Icons.savings_rounded),
                            keyboardType: const TextInputType.numberWithOptions(decimal: true),
                            prefixText: '\$ ',
                            validator: (value) {
                              if (value != null && value.isNotEmpty) {
                                if (double.tryParse(value) == null || double.parse(value) < 0) {
                                  return 'Please enter a valid amount';
                                }
                              }
                              return null;
                            },
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Target Date Card
            GlassmorphicCard(
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
                            color: Colors.blue.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Icon(
                            Icons.calendar_today_rounded,
                            size: 16,
                            color: Colors.blue,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Text(
                          'TARGET DATE',
                          style: GoogleFonts.poppins(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: AppTheme.getTextColor(context).withValues(alpha: 0.6),
                            letterSpacing: 1,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    ModernDateField(
                      controller: _targetDateController,
                      labelText: 'Target Date (Optional)',
                      hintText: 'Select your goal deadline...',
                      onDateSelected: (date) {
                        setState(() {
                          _selectedTargetDate = date;
                          if (date != null) {
                            _targetDateController.text = '${date.day}/${date.month}/${date.year}';
                          }
                        });
                      },
                      initialDate: DateTime.now(),
                      firstDate: DateTime.now(),
                      lastDate: DateTime(2030),
                      onClear: () {
                        setState(() {
                          _selectedTargetDate = null;
                          _targetDateController.clear();
                        });
                      },
                    ),
                    if (_targetDateController.text.isNotEmpty) ...[
                      const SizedBox(height: 12),
                      Text(
                        'Having a target date helps you stay motivated and track progress!',
                        style: GoogleFonts.poppins(
                          fontSize: 12,
                          color: AppTheme.getSuccessColor(context),
                          fontStyle: FontStyle.italic,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),

            // Create Goal Button with Orange Gradient
            Container(
              height: 56,
              decoration: AppTheme.getGradientButtonDecoration(),
              child: ElevatedButton.icon(
                onPressed: _createGoal,
                icon: const Icon(Icons.add_task_rounded, size: 20, color: Colors.white),
                label: Text(
                  'CREATE GOAL',
                  style: GoogleFonts.poppins(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                  ),
                ),
                style: AppTheme.getGradientButtonStyle(),
              ),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  // Get goal types with theme-aware colors
  List<Map<String, dynamic>> _getGoalTypes(BuildContext context) {
    return [
      {
        'icon': Icons.savings_rounded,
        'label': 'Savings',
        'color': AppTheme.getPrimaryTealColor(context), // Theme-aware teal
      },
      {
        'icon': Icons.flight_rounded,
        'label': 'Travel',
        'color': Colors.blue,
      },
      {
        'icon': Icons.computer_rounded,
        'label': 'Electronics',
        'color': Colors.purple,
      },
      {
        'icon': Icons.school_rounded,
        'label': 'Education',
        'color': AppTheme.accentOrange,
      },
      {
        'icon': Icons.emergency_rounded,
        'label': 'Emergency',
        'color': Colors.red,
      },
      {
        'icon': Icons.home_rounded,
        'label': 'Home',
        'color': AppTheme.successGreen,
      },
    ];
  }
}