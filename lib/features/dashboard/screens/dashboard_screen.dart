import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:smart_expense_tracker/app/theme/app_theme.dart';
import 'package:smart_expense_tracker/common_widgets/themed_background.dart';
import 'package:smart_expense_tracker/features/dashboard/widgets/budget_summary_card.dart';
import 'package:smart_expense_tracker/features/dashboard/widgets/financial_fact_card.dart';
import 'package:smart_expense_tracker/features/dashboard/widgets/quick_actions_card.dart';
import 'package:smart_expense_tracker/features/notifications/screens/notification_screen.dart';
import 'package:smart_expense_tracker/features/profile/screens/profile_screen.dart';
import 'package:smart_expense_tracker/models/budget_model.dart';
import 'package:smart_expense_tracker/models/category_model.dart';
import 'package:smart_expense_tracker/models/expense_model.dart';
import 'package:smart_expense_tracker/models/user_model.dart';
import 'package:smart_expense_tracker/services/firebase_auth_service.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  int _currentStreak = 0;

  @override
  void initState() {
    super.initState();
    _initializeStreak();
  }

  Future<void> _initializeStreak() async {
    final streak = await _calculateCurrentStreak();
    setState(() {
      _currentStreak = streak;
    });
  }

  Future<int> _calculateCurrentStreak() async {
    final prefs = await SharedPreferences.getInstance();
    final user = context.read<AuthService>().currentUser;
    final userId = user?.uid ?? 'guest';
    
    // Use user-specific keys for streak tracking
    final lastLoginKey = 'lastLoginDate_$userId';
    final streakKey = 'currentStreak_$userId';
    
    final lastLoginString = prefs.getString(lastLoginKey);
    final currentDate = DateTime.now();
    final today = DateTime(currentDate.year, currentDate.month, currentDate.day);

    // If first time user, initialize with streak of 1
    if (lastLoginString == null) {
      await prefs.setString(lastLoginKey, today.toIso8601String());
      await prefs.setInt(streakKey, 1);
      return 1;
    }

    final lastLogin = DateTime.parse(lastLoginString);
    final lastLoginDate = DateTime(lastLogin.year, lastLogin.month, lastLogin.day);

    // Check if already logged in today
    if (lastLoginDate.isAtSameMomentAs(today)) {
      return prefs.getInt(streakKey) ?? 1;
    }

    // Check if consecutive day (yesterday)
    final yesterday = today.subtract(const Duration(days: 1));
    if (lastLoginDate.isAtSameMomentAs(yesterday)) {
      // Consecutive day - increment streak
      final newStreak = (prefs.getInt(streakKey) ?? 1) + 1;
      await prefs.setInt(streakKey, newStreak);
      await prefs.setString(lastLoginKey, today.toIso8601String());
      return newStreak;
    } else {
      // Streak broken - reset to 1
      await prefs.setInt(streakKey, 1);
      await prefs.setString(lastLoginKey, today.toIso8601String());
      return 1;
    }
  }

  Widget _buildStreakBadge() {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: AppTheme.getAccentColor(context).withOpacity(isDark ? 0.2 : 0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: AppTheme.getAccentColor(context).withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.local_fire_department,
            color: AppTheme.getAccentColor(context),
            size: 16,
          ),
          const SizedBox(width: 4),
          Text(
            '$_currentStreak',
            style: GoogleFonts.poppins(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: AppTheme.getAccentColor(context),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final user = context.read<AuthService>().currentUser;
    final userName = user?.displayName ?? user?.email?.split('@').first ?? 'User';

    return ThemedBackground(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: SafeArea(
          child: ListView(
            padding: const EdgeInsets.all(16.0),
            children: [
              _buildHeader(context, userName),
              const SizedBox(height: 24),
              _buildBudgetSummary(),
              const SizedBox(height: 24),
              FinancialFactCard(
                fact: _getDailyFact(),
                author: _getDailyAuthor(),
              ),
              const SizedBox(height: 24),
              Text(
                "Quick Actions",
                style: GoogleFonts.poppins(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.getTextColor(context),
                ),
              ),
              const SizedBox(height: 16),
              const QuickActionsCard(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context, String fallbackUserName) {
    final currentUser = context.read<AuthService>().currentUser;

    return ValueListenableBuilder<Box<UserModel>>(
      valueListenable: Hive.box<UserModel>('user').listenable(),
      builder: (context, box, _) {
        // Safe access to Hive box
        if (!box.isOpen) {
          // Fallback to Firebase auth data only
          final String userName = currentUser?.displayName ??
              currentUser?.email?.split('@').first ??
              'User';
          final String? imageUrl = currentUser?.photoURL;
          final String firstName = userName.split(' ').first;

          return _buildHeaderContent(context, firstName, imageUrl, userName);
        }

        // Use Hive data if available
        final UserModel? user = box.values.isNotEmpty ? box.values.first : null;
        final String userName = user?.fullName ??
            currentUser?.displayName ??
            fallbackUserName;
        final String? imageUrl = currentUser?.photoURL;
        final String firstName = userName.split(' ').first;

        return _buildHeaderContent(context, firstName, imageUrl, userName);
      },
    );
  }

  Widget _buildHeaderContent(BuildContext context, String firstName, String? imageUrl, String userName) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Hey, $firstName',
              style: GoogleFonts.poppins(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: AppTheme.getTextColor(context),
              ),
            ),
            Text(
              'Welcome back!',
              style: GoogleFonts.poppins(
                fontSize: 14,
                color: AppTheme.getSecondaryTextColor(context),
              ),
            ),
          ],
        ),
        Row(
          children: [
            // Streak Badge
            _buildStreakBadge(),
            const SizedBox(width: 8),

            // Notification Icon with potential badge
            Stack(
              children: [
                IconButton(
                  onPressed: () => Navigator.push(context,
                      MaterialPageRoute(builder: (_) => const NotificationsScreen())),
                  icon: Icon(
                    Icons.notifications_none_rounded,
                    color: AppTheme.getSecondaryTextColor(context),
                    size: 28,
                  ),
                ),
                // Optional notification badge
                Positioned(
                  right: 8,
                  top: 8,
                  child: Container(
                    padding: const EdgeInsets.all(2),
                    decoration: BoxDecoration(
                      color: Colors.red,
                      borderRadius: BorderRadius.circular(6),
                    ),
                    constraints: const BoxConstraints(
                      minWidth: 12,
                      minHeight: 12,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(width: 8),
            GestureDetector(
              onTap: () => Navigator.push(context,
                  MaterialPageRoute(builder: (_) => const ProfileScreen())),
              child: CircleAvatar(
                backgroundColor: imageUrl != null
                    ? AppTheme.getPrimaryColor(context).withOpacity(0.1)
                    : AppTheme.getAccentColor(context),
                backgroundImage: (imageUrl != null && imageUrl.isNotEmpty)
                    ? NetworkImage(imageUrl)
                    : null,
                child: (imageUrl == null || imageUrl.isEmpty)
                    ? Text(
                  userName.isNotEmpty ? userName[0].toUpperCase() : 'U',
                  style: const TextStyle(
                      color: Colors.white, fontWeight: FontWeight.bold),
                )
                    : null,
              ),
            ),
          ],
        ),
      ],
    );
  }

  String _getDailyFact() {
    final quotes = [
      'A budget is telling your money where to go instead of wondering where it went',
      'Do not save what is left after spending, but spend what is left after saving',
      'The habit of saving is itself an education; it fosters every virtue, teaches self-denial, cultivates the sense of order, trains to forethought, and so broadens the mind',
      'Beware of little expenses; a small leak will sink a great ship',
      'Annual income twenty pounds, annual expenditure nineteen six, result happiness. Annual income twenty pounds, annual expenditure twenty pound ought and six, result misery',
      'It\'s not how much money you make, but how much money you keep, how hard it works for you, and how many generations you keep it for',
      'The goal isn\'t more money. The goal is living life on your terms',
      'Wealth consists not in having great possessions, but in having few wants',
      'The money you have gives you freedom; the money you pursue enslaves you',
      'Financial freedom is available to those who learn about it and work for it',
    ];

    final day = DateTime.now().day;
    return quotes[day % quotes.length];
  }

  String _getDailyAuthor() {
    final authors = [
      'John C. Maxwell',
      'Warren Buffett',
      'T.T. Munger',
      'Benjamin Franklin',
      'Charles Dickens',
      'Robert Kiyosaki',
      'Chris Brogan',
      'Epictetus',
      'Jean-Jacques Rousseau',
      'Robert Kiyosaki',
    ];

    final day = DateTime.now().day;
    return authors[day % authors.length];
  }

  Widget _buildBudgetSummary() {
    // Get current user ID
    final currentUserId = context.read<AuthService>().currentUser?.uid;
    
    if (currentUserId == null) {
      return _buildErrorCard('Please log in to view your budget');
    }
    
    // Check if boxes exist before using them
    if (!Hive.isBoxOpen('budgets') ||
        !Hive.isBoxOpen('expenses') ||
        !Hive.isBoxOpen('categories')) {
      return _buildErrorCard('Data loading...');
    }

    return ValueListenableBuilder<Box<Budget>>(
      valueListenable: Hive.box<Budget>('budgets').listenable(),
      builder: (context, budgetBox, _) {
        if (!budgetBox.isOpen) {
          return _buildErrorCard('Budget data not available');
        }

        return ValueListenableBuilder<Box<Expense>>(
          valueListenable: Hive.box<Expense>('expenses').listenable(),
          builder: (context, expenseBox, _) {
            if (!expenseBox.isOpen) {
              return _buildErrorCard('Expense data not available');
            }

            return ValueListenableBuilder<Box<Category>>(
              valueListenable: Hive.box<Category>('categories').listenable(),
              builder: (context, categoryBox, _) {
                if (!categoryBox.isOpen) {
                  return _buildErrorCard('Category data not available');
                }

                final now = DateTime.now();
                double monthlyBudget = 0.0;
                double spentSoFar = 0.0;

                // 1. Get Budget with safe access - FILTER BY USER ID
                try {
                  final currentBudget = budgetBox.values.firstWhere(
                        (budget) =>
                    budget.userId == currentUserId &&
                    budget.budgetType == BudgetType.monthly &&
                        budget.month.year == now.year &&
                        budget.month.month == now.month,
                  );
                  monthlyBudget = currentBudget.totalAmount;
                } catch (e) {
                  monthlyBudget = 0.0; // Default if no budget found
                }

                // 2. Get Expenses with safe access - FILTER BY USER ID
                final List<Expense> expensesThisMonth = expenseBox.values
                    .where((expense) =>
                expense.userId == currentUserId &&
                expense.date.year == now.year &&
                    expense.date.month == now.month)
                    .toList();

                spentSoFar = expensesThisMonth.fold(
                    0.0, (sum, expense) => sum + expense.amount);

                // 3. Prepare Chart Data
                final chartData = _prepareChartData(
                    expensesThisMonth, categoryBox, spentSoFar);

                return BudgetSummaryCard(
                  totalBudget: monthlyBudget,
                  totalSpent: spentSoFar,
                  pieChartSections: chartData['sections'] as List<PieChartSectionData>,
                  categoryIndicators: chartData['indicators'] as List<Widget>,
                );
              },
            );
          },
        );
      },
    );
  }

  Map<String, dynamic> _prepareChartData(
      List<Expense> expenses, Box<Category> categoryBox, double totalSpent) {

    if (totalSpent == 0) {
      return {'sections': <PieChartSectionData>[], 'indicators': <Widget>[]};
    }

    // Your Expense model uses category names, not IDs
    final Map<String, double> categoryTotals = {};
    for (var expense in expenses) {
      // Use the category name from your Expense model
      final categoryName = expense.category;
      categoryTotals.update(
        categoryName,
            (value) => value + expense.amount,
        ifAbsent: () => expense.amount,
      );
    }

    final List<PieChartSectionData> sections = [];
    final List<Widget> indicators = [];

    // Sort categories by amount
    final sortedCategories = categoryTotals.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    final topCategories = sortedCategories.take(3);
    double otherTotal = 0.0;

    if (sortedCategories.length > 3) {
      otherTotal = sortedCategories.skip(3).fold(0.0, (sum, e) => sum + e.value);
    }

    final colors = [Colors.cyan, Colors.amber, Colors.pink, Colors.green];

    // Create sections for top categories
    int colorIndex = 0;
    for (var entry in topCategories) {
      final categoryName = entry.key;
      final color = colors[colorIndex % colors.length];
      colorIndex++;

      // Calculate percentage for this category
      final double percentage = (entry.value / totalSpent) * 100;

      sections.add(PieChartSectionData(
        value: entry.value,
        color: color,
        showTitle: true, // Changed to true to show percentage
        title: '${percentage.toStringAsFixed(0)}%', // Add percentage label
        radius: 50,
        titleStyle: GoogleFonts.poppins(
          fontSize: 14.0,
          fontWeight: FontWeight.bold,
          color: Colors.white, // White text for better contrast
        ),
        titlePositionPercentageOffset: 0.6, // Position the text inside the segment
      ));

      // Build indicator with only category name and percentage (no money amount)
      indicators.add(_buildCategoryIndicator(color, categoryName, percentage));
    }

    // Add "Other" section
    if (otherTotal > 0) {
      final double percentage = (otherTotal / totalSpent) * 100;
      final otherColor = colors[3]; // Use green for "Other"

      sections.add(PieChartSectionData(
        value: otherTotal,
        color: otherColor,
        showTitle: true, // Changed to true to show percentage
        title: '${percentage.toStringAsFixed(0)}%', // Add percentage label
        radius: 50,
        titleStyle: GoogleFonts.poppins(
          fontSize: 14.0,
          fontWeight: FontWeight.bold,
          color: Colors.white, // White text for better contrast
        ),
        titlePositionPercentageOffset: 0.6, // Position the text inside the segment
      ));

      indicators.add(_buildCategoryIndicator(otherColor, 'Other', percentage));
    }

    return {'sections': sections, 'indicators': indicators};
  }

  // Updated method to create indicators with only category name and percentage (no money)
  Widget _buildCategoryIndicator(Color color, String text, double percentage) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: Row(
        children: [
          Container(
            width: 16,
            height: 16,
            decoration: BoxDecoration(
              color: color,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                text,
                style: GoogleFonts.poppins(
                  color: AppTheme.getTextColor(context),
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
              ),
              Text(
                '${percentage.toStringAsFixed(1)}%',
                style: GoogleFonts.poppins(
                  color: AppTheme.getSecondaryTextColor(context),
                  fontSize: 12,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildErrorCard(String message) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppTheme.getCardColor(context),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Theme.of(context).brightness == Brightness.dark
                ? Colors.black.withOpacity(0.3)
                : Colors.grey.withOpacity(0.08),
            blurRadius: 30,
            spreadRadius: 5,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        children: [
          Icon(
            Icons.schedule, 
            color: AppTheme.getSecondaryTextColor(context), 
            size: 40
          ),
          const SizedBox(height: 16),
          Text(
            message,
            style: GoogleFonts.poppins(
              color: AppTheme.getTextColor(context),
              fontSize: 16,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}


