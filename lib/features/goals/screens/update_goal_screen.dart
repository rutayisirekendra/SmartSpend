import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:smart_expense_tracker/app/theme/app_theme.dart';
import 'package:smart_expense_tracker/common_widgets/modern_card.dart';
import 'package:smart_expense_tracker/models/goal_model.dart';

class UpdateGoalScreen extends StatefulWidget {
  final Goal goal;

  const UpdateGoalScreen({Key? key, required this.goal}) : super(key: key);

  @override
  State<UpdateGoalScreen> createState() => _UpdateGoalScreenState();
}

class _UpdateGoalScreenState extends State<UpdateGoalScreen> {
  late TextEditingController _nameController;
  late TextEditingController _targetAmountController;
  late TextEditingController _currentAmountController;
  late TextEditingController _targetDateController;

  DateTime? _selectedTargetDate;
  String _selectedGoalType = 'Savings';

  final List<Map<String, dynamic>> _goalTypes = [
    {'icon': Icons.savings_rounded, 'label': 'Savings', 'color': AppTheme.primaryTeal},
    {'icon': Icons.flight_rounded, 'label': 'Travel', 'color': Colors.blue},
    {'icon': Icons.computer_rounded, 'label': 'Electronics', 'color': Colors.purple},
    {'icon': Icons.school_rounded, 'label': 'Education', 'color': Colors.orange},
    {'icon': Icons.emergency_rounded, 'label': 'Emergency', 'color': Colors.red},
    {'icon': Icons.home_rounded, 'label': 'Home', 'color': Colors.green},
  ];

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.goal.name);
    _targetAmountController = TextEditingController(text: widget.goal.targetAmount.toStringAsFixed(2));
    _currentAmountController = TextEditingController(text: widget.goal.currentAmount.toStringAsFixed(2));
    _targetDateController = TextEditingController(
        text: widget.goal.targetDate != null
            ? '${widget.goal.targetDate!.day}/${widget.goal.targetDate!.month}/${widget.goal.targetDate!.year}'
            : ''
    );
    _selectedTargetDate = widget.goal.targetDate;
    _selectedGoalType = widget.goal.goalType;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _targetAmountController.dispose();
    _currentAmountController.dispose();
    _targetDateController.dispose();
    super.dispose();
  }

  void _updateGoal() async {
    final goalName = _nameController.text.trim();
    final targetAmount = double.tryParse(_targetAmountController.text) ?? 0.0;
    final currentAmount = double.tryParse(_currentAmountController.text) ?? 0.0;

    if (goalName.isEmpty) {
      _showError('Please enter a goal name');
      return;
    }

    if (targetAmount <= 0) {
      _showError('Please enter a valid target amount');
      return;
    }

    if (currentAmount > targetAmount) {
      _showError('Current amount cannot be greater than target amount');
      return;
    }

    try {
      // FIX: Use the existing goal's key to update, not create new
      final updatedGoal = Goal(
        id: widget.goal.id, // CRITICAL: Use the same ID
        userId: widget.goal.userId,
        name: goalName,
        targetAmount: targetAmount,
        currentAmount: currentAmount,
        targetDate: _selectedTargetDate,
        goalType: _selectedGoalType,
      );

      final goalsBox = Hive.box<Goal>('goals');

      // This updates the existing goal instead of creating a new one
      await goalsBox.put(widget.goal.key, updatedGoal);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Goal "$goalName" updated successfully!'),
          backgroundColor: AppTheme.primaryTeal,
        ),
      );

      Navigator.of(context).pop();

    } catch (e) {
      print('Error updating goal: $e');
      _showError('Failed to update goal. Please try again.');
    }
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
      ),
    );
  }

  Future<void> _selectTargetDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedTargetDate ?? DateTime.now().add(const Duration(days: 30)),
      firstDate: DateTime.now(),
      lastDate: DateTime(2100),
    );

    if (picked != null) {
      setState(() {
        _selectedTargetDate = picked;
        _targetDateController.text = '${picked.day}/${picked.month}/${picked.year}';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.offWhite,
      appBar: AppBar(
        title: Text('Edit Goal', style: GoogleFonts.poppins()),
        backgroundColor: AppTheme.primaryTeal,
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: ListView(
          children: [
            // Goal Name
            ModernCard(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Goal Name',
                    style: GoogleFonts.poppins(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  TextField(
                    controller: _nameController,
                    decoration: const InputDecoration(
                      hintText: 'Enter goal name',
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Goal Type
            ModernCard(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Goal Type',
                    style: GoogleFonts.poppins(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Wrap(
                    spacing: 12,
                    runSpacing: 12,
                    children: _goalTypes.map((type) {
                      final isSelected = _selectedGoalType == type['label'];
                      return GestureDetector(
                        onTap: () {
                          setState(() {
                            _selectedGoalType = type['label'] as String;
                          });
                        },
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                          decoration: BoxDecoration(
                            color: isSelected ? (type['color'] as Color).withOpacity(0.1) : Colors.grey[100],
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(
                              color: isSelected ? type['color'] as Color : Colors.transparent,
                              width: 2,
                            ),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                type['icon'] as IconData,
                                size: 16,
                                color: isSelected ? type['color'] as Color : Colors.grey[600],
                              ),
                              const SizedBox(width: 6),
                              Text(
                                type['label'] as String,
                                style: GoogleFonts.poppins(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                  color: isSelected ? type['color'] as Color : Colors.grey[600],
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
            const SizedBox(height: 16),

            // Amounts
            ModernCard(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Amounts',
                    style: GoogleFonts.poppins(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: _targetAmountController,
                          keyboardType: TextInputType.number,
                          decoration: const InputDecoration(
                            labelText: 'Target Amount',
                            prefixText: '\$ ',
                          ),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: TextField(
                          controller: _currentAmountController,
                          keyboardType: TextInputType.number,
                          decoration: const InputDecoration(
                            labelText: 'Current Amount',
                            prefixText: '\$ ',
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Target Date
            ModernCard(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Target Date',
                    style: GoogleFonts.poppins(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 16),
                  GestureDetector(
                    onTap: _selectTargetDate,
                    child: Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey[300]!),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        children: [
                          Icon(Icons.calendar_today_rounded, size: 24, color: Colors.grey[500]),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              _targetDateController.text.isEmpty
                                  ? 'Select target date (optional)'
                                  : _targetDateController.text,
                              style: GoogleFonts.poppins(
                                color: _targetDateController.text.isEmpty ? Colors.grey[400] : AppTheme.darkGrey,
                                fontSize: 16,
                              ),
                            ),
                          ),
                          if (_targetDateController.text.isNotEmpty)
                            IconButton(
                              onPressed: () {
                                setState(() {
                                  _selectedTargetDate = null;
                                  _targetDateController.clear();
                                });
                              },
                              icon: Icon(Icons.clear_rounded, color: Colors.grey[500]),
                            ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: _updateGoal,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.accentOrange,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
              child: Text('UPDATE GOAL', style: GoogleFonts.poppins(fontWeight: FontWeight.w700)),
            ),
          ],
        ),
      ),
    );
  }
}