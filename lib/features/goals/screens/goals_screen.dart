import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:smart_expense_tracker/app/theme/app_theme.dart';
import 'package:smart_expense_tracker/common_widgets/modern_card.dart';
import 'package:smart_expense_tracker/features/main/screens/main_screen.dart';
import 'package:smart_expense_tracker/features/goals/screens/add_goal_screen.dart';
import 'package:smart_expense_tracker/features/goals/screens/update_goal_screen.dart';
import 'package:smart_expense_tracker/models/goal_model.dart';

class GoalsScreen extends StatefulWidget {
  const GoalsScreen({super.key});

  @override
  State<GoalsScreen> createState() => _GoalsScreenState();
}

class _GoalsScreenState extends State<GoalsScreen> {
  GoalFilter _selectedFilter = GoalFilter.all;
  List<String> _deletedGoalIds = []; // Track deleted goals for Dismissible

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.offWhite,
      body: Column(
        children: [
          // Enhanced Header Section
          _buildHeaderSection(),
          Expanded(
            child: ValueListenableBuilder<Box<Goal>>(
              valueListenable: Hive.box<Goal>('goals').listenable(),
              builder: (context, box, _) {
                final goals = box.values.toList().cast<Goal>();

                // Filter out deleted goals
                final filteredGoals = goals.where((goal) => !_deletedGoalIds.contains(goal.id)).toList();

                return filteredGoals.isEmpty
                    ? _buildEmptyState(context)
                    : _buildGoalsList(context, filteredGoals, box);
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (context) => const AddGoalScreen(),
            ),
          );
        },
        backgroundColor: AppTheme.accentOrange,
        foregroundColor: Colors.white,
        elevation: 4,
        icon: const Icon(Icons.add_chart_rounded),
        label: Text(
          'New Goal',
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
    return ValueListenableBuilder<Box<Goal>>(
      valueListenable: Hive.box<Goal>('goals').listenable(),
      builder: (context, box, _) {
        final goals = box.values.toList().cast<Goal>();
        final filteredGoals = goals.where((goal) => !_deletedGoalIds.contains(goal.id)).toList();
        final totalGoals = filteredGoals.length;
        final completedGoals = filteredGoals.where((goal) => goal.currentAmount >= goal.targetAmount).length;
        final totalTarget = filteredGoals.fold(0.0, (sum, goal) => sum + goal.targetAmount);
        final totalSaved = filteredGoals.fold(0.0, (sum, goal) => sum + goal.currentAmount);

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
            borderRadius: const BorderRadius.only(
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
                  IconButton(
                    onPressed: () {
                      Navigator.pushAndRemoveUntil(
                        context,
                        MaterialPageRoute(builder: (_) => const MainScreen()),
                            (route) => false,
                      );
                    },
                    icon: const Icon(Icons.arrow_back_rounded, color: Colors.white),
                    style: IconButton.styleFrom(
                      backgroundColor: Colors.white.withOpacity(0.2),
                      padding: const EdgeInsets.all(8),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Savings Goals',
                          style: GoogleFonts.poppins(
                            fontSize: 24,
                            fontWeight: FontWeight.w700,
                            color: Colors.white,
                            height: 1.2,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Track your progress and achieve your dreams',
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
              const SizedBox(height: 20),

              // Goals Stats
              _buildGoalsStats(totalGoals, completedGoals, totalSaved, totalTarget),
              const SizedBox(height: 16),

              // Goals Filter Toggle
              Container(
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    _buildFilterToggle('All Goals', GoalFilter.all),
                    const SizedBox(width: 4),
                    _buildFilterToggle('Active', GoalFilter.active),
                    const SizedBox(width: 4),
                    _buildFilterToggle('Completed', GoalFilter.completed),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildGoalsStats(int totalGoals, int completedGoals, double totalSaved, double totalTarget) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: [
        _buildStatItem(totalGoals.toString(), 'Goals', Icons.flag_rounded),
        _buildStatItem(completedGoals.toString(), 'Completed', Icons.check_circle_rounded),
        _buildStatItem('\$${totalSaved.toStringAsFixed(0)}', 'Saved', Icons.savings_rounded),
      ],
    );
  }

  Widget _buildStatItem(String value, String label, IconData icon) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.2),
            shape: BoxShape.circle,
          ),
          child: Icon(icon, size: 20, color: Colors.white),
        ),
        const SizedBox(height: 6),
        Text(
          value,
          style: GoogleFonts.poppins(
            fontSize: 16,
            fontWeight: FontWeight.w700,
            color: Colors.white,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          label,
          style: GoogleFonts.poppins(
            fontSize: 12,
            color: Colors.white.withOpacity(0.8),
          ),
        ),
      ],
    );
  }

  Widget _buildFilterToggle(String text, GoalFilter filter) {
    final isSelected = _selectedFilter == filter;
    return Expanded(
      child: GestureDetector(
        onTap: () {
          setState(() {
            _selectedFilter = filter;
          });
        },
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          decoration: BoxDecoration(
            color: isSelected ? Colors.white : Colors.transparent,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Text(
            text,
            textAlign: TextAlign.center,
            style: GoogleFonts.poppins(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: isSelected ? AppTheme.primaryTeal : Colors.white.withOpacity(0.8),
            ),
          ),
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
              Icons.flag_rounded,
              size: 60,
              color: Colors.grey[400],
            ),
          ),
          const SizedBox(height: 24),
          Text(
            'No Goals Yet',
            style: GoogleFonts.poppins(
              fontSize: 22,
              fontWeight: FontWeight.w700,
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 12),
          Text(
            'Set your financial goals and track your progress\nas you save towards your dreams.',
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

  Widget _buildGoalsList(BuildContext context, List<Goal> goals, Box<Goal> box) {
    final filteredGoals = _filterGoals(goals);

    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        // Goals Summary Card
        ModernCard(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'GOALS OVERVIEW',
                    style: GoogleFonts.poppins(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: Colors.grey[600],
                      letterSpacing: 1,
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: AppTheme.accentOrange.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          Icons.trending_up_rounded,
                          size: 14,
                          color: AppTheme.accentOrange,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          '${filteredGoals.length} GOALS',
                          style: GoogleFonts.poppins(
                            fontSize: 10,
                            fontWeight: FontWeight.w600,
                            color: AppTheme.accentOrange,
                            letterSpacing: 1,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  _buildSummaryItem(goals.length.toString(), 'Total'),
                  _buildSummaryItem(
                    goals.where((goal) => goal.currentAmount >= goal.targetAmount).length.toString(),
                    'Completed',
                  ),
                  _buildSummaryItem(
                    '\$${goals.fold(0.0, (sum, goal) => sum + goal.targetAmount).toStringAsFixed(0)}',
                    'Target',
                  ),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: 24),

        // Goals List Header
        Row(
          children: [
            Text(
              "YOUR GOALS",
              style: GoogleFonts.poppins(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: Colors.grey[600],
                letterSpacing: 0.5,
              ),
            ),
            const SizedBox(width: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
              decoration: BoxDecoration(
                color: AppTheme.primaryTeal.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                '${filteredGoals.length}',
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

        // Goals List with Swipe to Delete
        ...filteredGoals.map((goal) {
          return Padding(
            padding: const EdgeInsets.only(bottom: 16.0),
            child: Dismissible(
              key: Key(goal.id),
              direction: DismissDirection.endToStart,
              background: Container(
                decoration: BoxDecoration(
                  color: Colors.red.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: const Align(
                  alignment: Alignment.centerRight,
                  child: Padding(
                    padding: EdgeInsets.only(right: 20.0),
                    child: Icon(
                      Icons.delete_rounded,
                      color: Colors.red,
                    ),
                  ),
                ),
              ),
              confirmDismiss: (direction) async {
                return await _showDeleteConfirmation(goal);
              },
              onDismissed: (direction) {
                setState(() {
                  _deletedGoalIds.add(goal.id);
                });
                _deleteGoal(goal, box);
              },
              child: _buildGoalCard(goal, box),
            ),
          );
        }).toList(),
      ],
    );
  }

  Widget _buildGoalCard(Goal goal, Box<Goal> box) {
    final progress = goal.targetAmount > 0 ? (goal.currentAmount / goal.targetAmount).clamp(0.0, 1.0) : 0.0;
    final isCompleted = goal.currentAmount >= goal.targetAmount;

    return ModernCard(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          // Header with goal info and actions
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      goal.name,
                      style: GoogleFonts.poppins(
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                        color: AppTheme.darkGrey,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                          decoration: BoxDecoration(
                            color: _getGoalTypeColor(goal.goalType).withOpacity(0.1),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            goal.goalType,
                            style: GoogleFonts.poppins(
                              fontSize: 10,
                              fontWeight: FontWeight.w600,
                              color: _getGoalTypeColor(goal.goalType),
                            ),
                          ),
                        ),
                        if (goal.targetDate != null) ...[
                          const SizedBox(width: 8),
                          Icon(Icons.calendar_today_rounded, size: 12, color: Colors.grey[500]),
                          const SizedBox(width: 4),
                          Text(
                            '${goal.targetDate!.day}/${goal.targetDate!.month}/${goal.targetDate!.year}',
                            style: GoogleFonts.poppins(
                              fontSize: 10,
                              color: Colors.grey[500],
                            ),
                          ),
                        ],
                      ],
                    ),
                  ],
                ),
              ),
              // SINGLE Action Button - Just Edit
              IconButton(
                icon: Icon(Icons.edit_rounded, color: AppTheme.primaryTeal, size: 20),
                onPressed: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) => UpdateGoalScreen(goal: goal),
                    ),
                  );
                },
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Amount Display
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Current',
                    style: GoogleFonts.poppins(
                      fontSize: 12,
                      color: Colors.grey[500],
                    ),
                  ),
                  Text(
                    '\$${goal.currentAmount.toStringAsFixed(2)}',
                    style: GoogleFonts.poppins(
                      fontSize: 20,
                      fontWeight: FontWeight.w700,
                      color: AppTheme.primaryTeal,
                    ),
                  ),
                ],
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    'Target',
                    style: GoogleFonts.poppins(
                      fontSize: 12,
                      color: Colors.grey[500],
                    ),
                  ),
                  Text(
                    '\$${goal.targetAmount.toStringAsFixed(2)}',
                    style: GoogleFonts.poppins(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Progress Bar
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: LinearProgressIndicator(
              value: progress,
              minHeight: 12,
              backgroundColor: Colors.grey[200],
              valueColor: AlwaysStoppedAnimation<Color>(
                isCompleted ? Colors.green : AppTheme.primaryTeal,
              ),
            ),
          ),
          const SizedBox(height: 8),

          // Progress Info
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '${(progress * 100).toStringAsFixed(1)}% completed',
                style: GoogleFonts.poppins(
                  fontSize: 12,
                  color: Colors.grey[500],
                ),
              ),
              Text(
                isCompleted ? 'Goal Achieved! 🎉' : 'Keep saving!',
                style: GoogleFonts.poppins(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: isCompleted ? Colors.green : AppTheme.accentOrange,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryItem(String value, String label) {
    return Expanded(
      child: Column(
        children: [
          Text(
            value,
            style: GoogleFonts.poppins(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: AppTheme.primaryTeal,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: GoogleFonts.poppins(
              fontSize: 12,
              color: Colors.grey[500],
            ),
          ),
        ],
      ),
    );
  }

  List<Goal> _filterGoals(List<Goal> goals) {
    switch (_selectedFilter) {
      case GoalFilter.active:
        return goals.where((goal) => goal.currentAmount < goal.targetAmount).toList();
      case GoalFilter.completed:
        return goals.where((goal) => goal.currentAmount >= goal.targetAmount).toList();
      case GoalFilter.all:
      default:
        return goals;
    }
  }

  Color _getGoalTypeColor(String goalType) {
    switch (goalType) {
      case 'Travel':
        return Colors.blue;
      case 'Electronics':
        return Colors.purple;
      case 'Education':
        return Colors.orange;
      case 'Emergency':
        return Colors.red;
      case 'Home':
        return Colors.green;
      case 'Savings':
      default:
        return AppTheme.primaryTeal;
    }
  }

  Future<bool> _showDeleteConfirmation(Goal goal) async {
    return await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Delete Goal', style: GoogleFonts.poppins()),
        content: Text('Are you sure you want to delete "${goal.name}"?', style: GoogleFonts.poppins()),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text('Cancel', style: GoogleFonts.poppins()),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: Text('Delete', style: GoogleFonts.poppins(color: Colors.red)),
          ),
        ],
      ),
    ) ?? false;
  }

  void _deleteGoal(Goal goal, Box<Goal> box) {
    box.delete(goal.id);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Goal "${goal.name}" deleted'),
        backgroundColor: AppTheme.accentOrange,
      ),
    );
  }
}

enum GoalFilter { all, active, completed }