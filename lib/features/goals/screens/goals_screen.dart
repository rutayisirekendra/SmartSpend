import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:smart_expense_tracker/app/theme/app_theme.dart';
import 'package:smart_expense_tracker/common_widgets/modern_card.dart';
import 'package:smart_expense_tracker/features/main/screens/main_screen.dart';
import 'package:smart_expense_tracker/features/goals/screens/add_goal_screen.dart'; // Add this import
import 'package:smart_expense_tracker/features/goals/widgets/savings_tree_widget.dart';
import 'package:smart_expense_tracker/models/goal_model.dart';

class GoalsScreen extends StatefulWidget {
  GoalsScreen({super.key});

  @override
  State<GoalsScreen> createState() => _GoalsScreenState();
}

class _GoalsScreenState extends State<GoalsScreen> {
  GoalFilter _selectedFilter = GoalFilter.all;

  // We'll create a mock goal to display in the UI for now.
  final List<Goal> mockGoals = [
    Goal(
      id: '1',
      userId: 'mockUser',
      name: 'New Laptop',
      targetAmount: 1500.00,
      currentAmount: 450.00,
    ),
    Goal(
      id: '2',
      userId: 'mockUser',
      name: 'Summer Trip',
      targetAmount: 800.00,
      currentAmount: 750.00,
    ),
    Goal(
      id: '3',
      userId: 'mockUser',
      name: 'Emergency Fund',
      targetAmount: 3000.00,
      currentAmount: 1200.00,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.offWhite,
      body: Column(
        children: [
          // Enhanced Header Section
          _buildHeaderSection(),
          Expanded(
            child: mockGoals.isEmpty
                ? _buildEmptyState(context)
                : _buildGoalsList(context),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          // Navigate to Add Goal Screen
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (context) => AddGoalScreen(), // Updated to use AddGoalScreen
            ),
          );
        },
        backgroundColor: AppTheme.accentOrange,
        foregroundColor: Colors.white,
        elevation: 4,
        icon: Icon(Icons.add_chart_rounded),
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
    final totalGoals = mockGoals.length;
    final completedGoals = mockGoals.where((goal) => goal.currentAmount >= goal.targetAmount).length;
    final totalTarget = mockGoals.fold(0.0, (sum, goal) => sum + goal.targetAmount);
    final totalSaved = mockGoals.fold(0.0, (sum, goal) => sum + goal.currentAmount);

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
              IconButton(
                onPressed: () {
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
                      'Savings Goals',
                      style: GoogleFonts.poppins(
                        fontSize: 24,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                        height: 1.2,
                      ),
                    ),
                    SizedBox(height: 4),
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
          SizedBox(height: 20),

          // Goals Stats
          _buildGoalsStats(totalGoals, completedGoals, totalSaved, totalTarget),
          SizedBox(height: 16),

          // Goals Filter Toggle
          Container(
            padding: EdgeInsets.all(4),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.15),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                _buildFilterToggle('All Goals', GoalFilter.all),
                SizedBox(width: 4),
                _buildFilterToggle('Active', GoalFilter.active),
                SizedBox(width: 4),
                _buildFilterToggle('Completed', GoalFilter.completed),
              ],
            ),
          ),
        ],
      ),
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
          padding: EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.2),
            shape: BoxShape.circle,
          ),
          child: Icon(icon, size: 20, color: Colors.white),
        ),
        SizedBox(height: 6),
        Text(
          value,
          style: GoogleFonts.poppins(
            fontSize: 16,
            fontWeight: FontWeight.w700,
            color: Colors.white,
          ),
        ),
        SizedBox(height: 2),
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
          padding: EdgeInsets.symmetric(horizontal: 16, vertical: 10),
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
          SizedBox(height: 24),
          Text(
            'No Goals Yet',
            style: GoogleFonts.poppins(
              fontSize: 22,
              fontWeight: FontWeight.w700,
              color: Colors.grey[600],
            ),
          ),
          SizedBox(height: 12),
          Text(
            'Set your financial goals and track your progress\nas you save towards your dreams.',
            textAlign: TextAlign.center,
            style: GoogleFonts.poppins(
              fontSize: 16,
              color: Colors.grey[500],
              height: 1.4,
            ),
          ),
          SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) => AddGoalScreen(),
                ),
              );
            },
            icon: Icon(Icons.add_rounded, size: 20),
            label: Text(
              'Create Your First Goal',
              style: TextStyle(fontWeight: FontWeight.w600),
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.accentOrange,
              foregroundColor: Colors.white,
              padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGoalsList(BuildContext context) {
    final filteredGoals = _filterGoals(mockGoals);

    return ListView(
      padding: EdgeInsets.all(20),
      children: [
        // Goals Summary Card
        ModernCard(
          padding: EdgeInsets.all(20),
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
                    padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
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
                        SizedBox(width: 4),
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
              SizedBox(height: 16),
              Row(
                children: [
                  _buildSummaryItem(mockGoals.length.toString(), 'Total'),
                  _buildSummaryItem(
                    mockGoals.where((goal) => goal.currentAmount >= goal.targetAmount).length.toString(),
                    'Completed',
                  ),
                  _buildSummaryItem(
                    '\$${mockGoals.fold(0.0, (sum, goal) => sum + goal.targetAmount).toStringAsFixed(0)}',
                    'Target',
                  ),
                ],
              ),
            ],
          ),
        ),
        SizedBox(height: 24),

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
            SizedBox(width: 8),
            Container(
              padding: EdgeInsets.symmetric(horizontal: 8, vertical: 2),
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
        SizedBox(height: 16),

        // Goals List
        ...filteredGoals.map((goal) {
          return Padding(
            padding: const EdgeInsets.only(bottom: 16.0),
            child: ModernCard(
              padding: EdgeInsets.all(20),
              child: Column(
                children: [
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
                            SizedBox(height: 4),
                            Text(
                              'Savings Goal',
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
                            '\$${goal.currentAmount.toStringAsFixed(0)}',
                            style: GoogleFonts.poppins(
                              fontSize: 20,
                              fontWeight: FontWeight.w700,
                              color: AppTheme.primaryTeal,
                            ),
                          ),
                          Text(
                            'of \$${goal.targetAmount.toStringAsFixed(0)}',
                            style: GoogleFonts.poppins(
                              fontSize: 12,
                              color: Colors.grey[500],
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  SizedBox(height: 16),
                  // Progress Bar
                  ClipRRect(
                    borderRadius: BorderRadius.circular(10),
                    child: LinearProgressIndicator(
                      value: goal.targetAmount > 0 ? (goal.currentAmount / goal.targetAmount).clamp(0.0, 1.0) : 0.0,
                      minHeight: 12,
                      backgroundColor: Colors.grey[200],
                      valueColor: AlwaysStoppedAnimation<Color>(
                        goal.currentAmount >= goal.targetAmount ? Colors.green : AppTheme.primaryTeal,
                      ),
                    ),
                  ),
                  SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        '${((goal.currentAmount / goal.targetAmount) * 100).toStringAsFixed(1)}% completed',
                        style: GoogleFonts.poppins(
                          fontSize: 12,
                          color: Colors.grey[500],
                        ),
                      ),
                      Text(
                        goal.currentAmount >= goal.targetAmount ? 'Goal Achieved! 🎉' : 'Keep saving!',
                        style: GoogleFonts.poppins(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: goal.currentAmount >= goal.targetAmount ? Colors.green : AppTheme.accentOrange,
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
          SizedBox(height: 4),
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
}

enum GoalFilter { all, active, completed }