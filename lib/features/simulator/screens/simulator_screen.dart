import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:smart_expense_tracker/app/theme/app_theme.dart';
import 'package:smart_expense_tracker/common_widgets/modern_card.dart';
import 'package:smart_expense_tracker/common_widgets/themed_background.dart';
import 'package:smart_expense_tracker/features/main/screens/main_screen.dart';
import 'package:smart_expense_tracker/models/budget_model.dart';
import 'package:smart_expense_tracker/models/expense_model.dart';

class SimulatorScreen extends StatefulWidget {
  const SimulatorScreen({Key? key}) : super(key: key);

  @override
  State<SimulatorScreen> createState() => _SimulatorScreenState();
}

// *** ADDED AnimationController for the result icon ***
class _SimulatorScreenState extends State<SimulatorScreen>
    with TickerProviderStateMixin { // Changed to TickerProviderStateMixin
  final _formKey = GlobalKey<FormState>();
  final _itemNameController = TextEditingController();
  final _itemAmountController = TextEditingController();

  String? _resultMessage;
  Color? _resultColor;
  IconData? _resultIconData; // To store the big result icon
  late AnimationController _cardAnimationController; // Renamed for clarity
  late Animation<double> _scaleAnimation;
  // *** ADDED AnimationController and Animation for the result icon ***
  late AnimationController _iconAnimationController;
  late Animation<double> _iconScaleAnimation;
  bool _showResult = false;

  @override
  void initState() {
    super.initState();
    // Card animation
    _cardAnimationController = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 600),
    );
    _scaleAnimation = Tween<double>(begin: 0.8, end: 1.0).animate(
      CurvedAnimation(parent: _cardAnimationController, curve: Curves.elasticOut),
    );

    // *** ADDED Icon animation setup ***
    _iconAnimationController = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 400), // Faster animation for the icon
    );
    _iconScaleAnimation = Tween<double>(begin: 0.5, end: 1.0).animate(
      CurvedAnimation(parent: _iconAnimationController, curve: Curves.easeOutBack),
    );
  }

  @override
  void dispose() {
    _cardAnimationController.dispose();
    _iconAnimationController.dispose(); // Dispose the new controller
    _itemNameController.dispose();
    _itemAmountController.dispose();
    super.dispose();
  }

  void _runSimulation() {
    if (_formKey.currentState!.validate()) {
      final itemAmount = double.parse(_itemAmountController.text);

      final budgetBox = Hive.box<Budget>('budgets');
      final expenseBox = Hive.box<Expense>('expenses');
      final now = DateTime.now();

      Budget? currentBudget;
      try {
        currentBudget = budgetBox.values.firstWhere(
              (budget) =>
          budget.budgetType == BudgetType.monthly &&
              budget.month.year == now.year &&
              budget.month.month == now.month,
        );
      } catch (e) {
        setState(() {
          _resultMessage =
          "⚠️ Error: No monthly budget found for the current month. Please set one first.";
          _resultColor = Colors.redAccent;
          _resultIconData = Icons.error_outline_rounded; // Set error icon
          _showResult = true;
        });
        _cardAnimationController.forward(from: 0.0);
        _iconAnimationController.forward(from: 0.0); // Trigger icon animation
        print("Budget fetch error: $e");
        return;
      }

      final double monthlyBudget = currentBudget.totalAmount;

      final expensesThisMonth = expenseBox.values.where(
            (expense) =>
        expense.date.year == now.year && expense.date.month == now.month,
      );
      final double spentSoFar =
      expensesThisMonth.fold(0.0, (sum, expense) => sum + expense.amount);

      final int daysInMonth = DateTime(now.year, now.month + 1, 0).day;
      final int dayOfMonth = now.day;

      final double dailyAverageSpending =
      (dayOfMonth > 0 && spentSoFar > 0) ? spentSoFar / dayOfMonth : 0.0;

      final int daysLeft =
      (daysInMonth - dayOfMonth) > 0 ? (daysInMonth - dayOfMonth) : 0;

      final projectedFutureSpending = dailyAverageSpending * daysLeft;
      final totalProjectedSpending =
          spentSoFar + itemAmount + projectedFutureSpending;
      final difference = totalProjectedSpending - monthlyBudget;

      setState(() {
        if (difference <= 0) {
          _resultMessage =
          "🎉 Go for it! Buying this item keeps you on track and you're projected to be \$${(-difference).toStringAsFixed(2)} under budget.";
          _resultColor = AppTheme.primaryTeal;
          _resultIconData = Icons.check_circle_outline_rounded; // Set success icon
        } else {
          _resultMessage =
          "⚠️ Warning: This purchase will put you on track to be \$${difference.toStringAsFixed(2)} over budget this month. Consider if it's essential.";
          _resultColor = AppTheme.accentOrange;
          _resultIconData = Icons.warning_amber_rounded; // Set warning icon
        }
        _showResult = true;
      });

      _cardAnimationController.forward(from: 0.0);
      _iconAnimationController.forward(from: 0.0); // Trigger icon animation
    }
  }

  void _resetSimulation() {
    _cardAnimationController.reverse().then((_) { // Animate out before resetting
      setState(() {
        _showResult = false;
        _resultMessage = null;
        _resultIconData = null;
        _itemNameController.clear();
        _itemAmountController.clear();
      });
    });
    _iconAnimationController.reset(); // Reset icon animation controller
  }

  // --- BUILD METHOD and HEADER remain the same ---
  @override
  Widget build(BuildContext context) {
    return ThemedBackground(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: Column(
        children: [
          // Enhanced Header Section
          _buildHeaderSection(),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20.0),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Simulation Input Card
                    _buildInputSection(),
                    const SizedBox(height: 24),

                    // Quick Stats Card - Now uses ValueListenableBuilder
                    _buildStatsSection(),
                    const SizedBox(height: 24),

                    // Action Buttons
                    _buildActionButtons(),
                    const SizedBox(height: 24),

                    // Results Section
                    if (_showResult) _buildResultsSection(),
                  ], // Close Column children (Form child)
                ), // Close Column (Form child)
              ), // Close Form
            ), // Close SingleChildScrollView  
          ), // Close Expanded
        ], // Close Column children (Scaffold body)
        ), // Close Column (Scaffold body)
      ), // Close Scaffold
    ); // Close ThemedBackground
  }

  Widget _buildHeaderSection() {
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
            AppTheme.getHeaderPrimaryColor(context),
            AppTheme.getHeaderSecondaryColor(context),
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
                  Navigator.of(context).pop();
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
                      'Affordability Simulator',
                      style: GoogleFonts.poppins(
                        fontSize: 24,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                        height: 1.2,
                      ),
                    ),
                    SizedBox(height: 4),
                    Text(
                      'Test purchases before you make them',
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
          // Quick Tips (remains the same)
          Row(
            children: [
              Container(
                padding: EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(Icons.lightbulb_rounded, size: 16, color: Colors.white),
              ),
              SizedBox(width: 8),
              Expanded(
                child: Text(
                  'Make informed spending decisions with real-time budget analysis',
                  style: GoogleFonts.poppins(
                    fontSize: 12,
                    color: Colors.white.withOpacity(0.9),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
  // --- INPUT SECTION remains the same ---
  Widget _buildInputSection() {
    return ModernCard(
      padding: EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppTheme.primaryTeal.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: AppTheme.primaryTeal),
                ),
                child: Icon(Icons.shopping_cart_rounded, size: 20, color: AppTheme.primaryTeal),
              ),
              SizedBox(width: 12),
              Text(
                'PURCHASE DETAILS',
                style: GoogleFonts.poppins(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: AppTheme.getSecondaryTextColor(context),
                  letterSpacing: 1,
                ),
              ),
            ],
          ),
          SizedBox(height: 20),

          // Item Name Field
          TextFormField(
            controller: _itemNameController,
            style: GoogleFonts.poppins(
              fontSize: 16,
              color: AppTheme.getTextColor(context),
            ),
            decoration: InputDecoration(
              labelText: 'What are you thinking of buying? 🛍️',
              labelStyle: GoogleFonts.poppins(
                color: AppTheme.getSecondaryTextColor(context),
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(
                  color: Theme.of(context).brightness == Brightness.dark
                      ? AppTheme.darkCard
                      : Colors.grey[300]!,
                ),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(
                  color: Theme.of(context).brightness == Brightness.dark
                      ? AppTheme.darkCard
                      : Colors.grey[300]!,
                ),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: AppTheme.getPrimaryColor(context), width: 2),
              ),
              filled: true,
              fillColor: Theme.of(context).brightness == Brightness.dark
                  ? AppTheme.darkSurface
                  : Colors.grey[50],
              contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 16),
            ),
            validator: (value) => value == null || value.isEmpty ? 'Please enter a name 📝' : null,
          ),
          SizedBox(height: 16),

          // Item Amount Field
          TextFormField(
            controller: _itemAmountController,
            keyboardType: TextInputType.numberWithOptions(decimal: true),
            style: GoogleFonts.poppins(
              fontSize: 16,
              color: AppTheme.getTextColor(context),
            ),
            decoration: InputDecoration(
              labelText: 'How much does it cost? 💰',
              labelStyle: GoogleFonts.poppins(
                color: AppTheme.getSecondaryTextColor(context),
              ),
              prefixText: '\$ ',
              prefixStyle: GoogleFonts.poppins(
                color: AppTheme.getTextColor(context),
                fontWeight: FontWeight.w600,
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(
                  color: Theme.of(context).brightness == Brightness.dark
                      ? AppTheme.darkCard
                      : Colors.grey[300]!,
                ),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(
                  color: Theme.of(context).brightness == Brightness.dark
                      ? AppTheme.darkCard
                      : Colors.grey[300]!,
                ),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: AppTheme.getPrimaryColor(context), width: 2),
              ),
              filled: true,
              fillColor: Theme.of(context).brightness == Brightness.dark
                  ? AppTheme.darkSurface
                  : Colors.grey[50],
              contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 16),
            ),
            validator: (value) {
              if (value == null || value.isEmpty) return 'Please enter an amount 💵';
              if (double.tryParse(value) == null) return 'Please enter a valid number 🔢';
              return null;
            },
          ),
        ],
      ),
    );
  }
  // --- MODIFIED Stats Section & Stat Item ---
  Widget _buildStatsSection() {
    return ValueListenableBuilder<Box<Budget>>(
      valueListenable: Hive.box<Budget>('budgets').listenable(),
      builder: (context, budgetBox, _) {
        return ValueListenableBuilder<Box<Expense>>(
          valueListenable: Hive.box<Expense>('expenses').listenable(),
          builder: (context, expenseBox, _) {
            final now = DateTime.now();
            Budget? currentBudget;
            double monthlyBudget = 0.0;
            try {
              currentBudget = budgetBox.values.firstWhere(
                    (budget) =>
                budget.budgetType == BudgetType.monthly &&
                    budget.month.year == now.year &&
                    budget.month.month == now.month,
              );
              monthlyBudget = currentBudget.totalAmount;
            } catch (e) {
              monthlyBudget = 0.0;
            }

            final expensesThisMonth = expenseBox.values.where(
                  (expense) =>
              expense.date.year == now.year &&
                  expense.date.month == now.month,
            );
            final double spentSoFar = expensesThisMonth.fold(
                0.0, (sum, expense) => sum + expense.amount);

            final int daysInMonth = DateTime(now.year, now.month + 1, 0).day;
            final int dayOfMonth = now.day;
            final int daysLeft = (daysInMonth - dayOfMonth) > 0 ? (daysInMonth - dayOfMonth) : 0;
            final double remainingBudget = monthlyBudget - spentSoFar;
            final double dailyBudget = (daysLeft > 0) ? remainingBudget / daysLeft : remainingBudget;

            return ModernCard(
              padding: EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container( /* ... Icon container ... */
                        padding: EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: AppTheme.accentOrange.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(color: AppTheme.accentOrange),
                        ),
                        child: Icon(Icons.analytics_rounded, size: 20, color: AppTheme.accentOrange),
                      ),
                      SizedBox(width: 12),
                      Text( /* ... Title ... */
                        'CURRENT BUDGET STATUS',
                        style: GoogleFonts.poppins(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: Colors.grey[600],
                          letterSpacing: 1,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 16),
                  Row(
                    children: [
                      _buildStatItem('\$${monthlyBudget.toStringAsFixed(0)}',
                          'Monthly Budget', Icons.account_balance_wallet_rounded),
                      _buildStatItem('\$${spentSoFar.toStringAsFixed(0)}',
                          'Spent So Far', Icons.shopping_cart_rounded),
                      // *** MODIFIED Daily Budget Stat Item ***
                      _buildStatItem(
                          dailyBudget.isFinite && dailyBudget >= 0
                              ? '\$${dailyBudget.toStringAsFixed(2)}'
                              : (remainingBudget > 0 ? '\$${remainingBudget.toStringAsFixed(2)} Left' : '\$0.00'),
                          'Daily Budget', Icons.today_rounded,
                          isHighlighted: true // Flag to highlight this item
                      ),
                    ],
                  ),
                  SizedBox(height: 12),
                  Container( /* ... Info container ... */
                    padding: EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: AppTheme.primaryTeal.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: AppTheme.infoBlue.withOpacity(0.3)),
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.info_rounded, color: remainingBudget >= 0 ? AppTheme.infoBlue : AppTheme.accentOrange, size: 16),
                        SizedBox(width: 8),
                        Expanded(
                          child: Text( /* ... Info text ... */
                            daysLeft > 0 && dailyBudget.isFinite && dailyBudget >= 0
                                ? 'You have $daysLeft days left this month with \$${dailyBudget.toStringAsFixed(2)} available per day'
                                : (remainingBudget >= 0 ? 'Today is the last day. You have \$${remainingBudget.toStringAsFixed(2)} remaining.' : 'You are \$${(-remainingBudget).toStringAsFixed(2)} over budget.'),
                            style: GoogleFonts.poppins(
                              fontSize: 12,
                              color: remainingBudget >= 0 ? AppTheme.infoBlue : AppTheme.accentOrange,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  // *** MODIFIED _buildStatItem to accept isHighlighted ***
  Widget _buildStatItem(String value, String label, IconData icon, {bool isHighlighted = false}) {
    return Expanded(
      child: Column(
        children: [
          Container(
            padding: EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: AppTheme.primaryTeal.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, size: 18, color: AppTheme.primaryTeal),
          ),
          SizedBox(height: 8),
          Text(
            value,
            style: GoogleFonts.poppins(
              fontSize: isHighlighted ? 16 : 14, // Larger font if highlighted
              fontWeight: isHighlighted ? FontWeight.w800 : FontWeight.w700, // Bolder if highlighted
              color: isHighlighted ? AppTheme.accentOrange : AppTheme.primaryTeal, // Orange if highlighted
            ),
          ),
          SizedBox(height: 4),
          Text(
            label,
            style: GoogleFonts.poppins(
              fontSize: 10,
              color: Colors.grey[500],
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
  // --- END MODIFIED Stats Section ---

  // --- ACTION BUTTONS remain the same ---
  Widget _buildActionButtons() {
    return Row(
      children: [
        Expanded(
          child: Container(
            decoration: BoxDecoration(
              color: AppTheme.accentOrange,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: AppTheme.accentOrange.withOpacity(0.3),
                  blurRadius: 8,
                  offset: Offset(0, 4),
                ),
              ],
            ),
            child: ElevatedButton.icon(
              onPressed: _runSimulation,
              icon: Icon(Icons.rocket_launch_rounded, size: 20, color: Colors.white),
              label: Text(
                'RUN SIMULATION 🚀',
                style: GoogleFonts.poppins(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                ),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.transparent,
                shadowColor: Colors.transparent,
                padding: EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
            ),
          ),
        ),
        if (_showResult) ...[
          SizedBox(width: 12),
          Container(
            decoration: BoxDecoration(
              border: Border.all(color: AppTheme.primaryTeal),
              borderRadius: BorderRadius.circular(16),
            ),
            child: ElevatedButton.icon(
              onPressed: _resetSimulation,
              icon: Icon(Icons.refresh_rounded, size: 20, color: AppTheme.primaryTeal),
              label: Text(
                'RESET',
                style: GoogleFonts.poppins(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: AppTheme.primaryTeal,
                ),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.transparent,
                shadowColor: Colors.transparent,
                padding: EdgeInsets.symmetric(vertical: 16, horizontal: 20),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
            ),
          ),
        ],
      ],
    );
  }

  // --- MODIFIED Results Section ---
  Widget _buildResultsSection() {
    IconData largeResultIcon = Icons.info_outline_rounded; // Default
    if (_resultIconData == Icons.check_circle_outline_rounded) {
      largeResultIcon = Icons.check_circle_outline_rounded;
    } else if (_resultIconData == Icons.warning_amber_rounded) {
      largeResultIcon = Icons.warning_amber_rounded;
    } else if (_resultIconData == Icons.error_outline_rounded){
      largeResultIcon = Icons.error_outline_rounded;
    }

    // Determine titles and advice based on the main icon data
    String resultTitle = 'SIMULATION RESULT';
    String adviceText = '';
    if (_resultIconData == Icons.check_circle_outline_rounded) {
      resultTitle = 'GOOD NEWS! 🎉';
      adviceText = 'This purchase aligns well with your budget goals!';
    } else if (_resultIconData == Icons.warning_amber_rounded) {
      resultTitle = 'CONSIDER THIS ⚠️';
      adviceText = 'Consider waiting or looking for alternatives to stay on track.';
    } else if (_resultIconData == Icons.error_outline_rounded){
      resultTitle = 'BUDGET ERROR ⚠️';
      adviceText = 'Please create a budget for the current month first.';
    }


    return AnimatedBuilder(
      animation: _cardAnimationController, // Use card animation controller
      builder: (context, child) {
        return Transform.scale(
          scale: _scaleAnimation.value,
          child: Opacity( // Added opacity fade in
              opacity: _cardAnimationController.value,
              child: child
          ),
        );
      },
      child: ModernCard(
        padding: EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center, // Center items
          children: [
            // *** ADDED Large Result Icon with Animation ***
            ScaleTransition(
              scale: _iconScaleAnimation,
              child: Icon(
                largeResultIcon,
                color: _resultColor ?? AppTheme.infoBlue,
                size: 70.0, // Make it significantly larger
              ),
            ),
            SizedBox(height: 16), // Spacing below large icon

            // Row for the small icon and title (remains similar)
            Row(
              mainAxisAlignment: MainAxisAlignment.center, // Center this row
              children: [
                // Optionally keep the small icon here too, or remove it
                /* Container(
                  padding: EdgeInsets.all(8),
                   decoration: BoxDecoration(
                     color: (_resultColor ?? AppTheme.infoBlue).withOpacity(0.1),
                     borderRadius: BorderRadius.circular(10),
                     border: Border.all(color: _resultColor ?? AppTheme.infoBlue),
                   ),
                  child: Icon(
                    _resultIconData ?? Icons.info_outline_rounded, // Use the stored icon data
                    color: _resultColor ?? AppTheme.infoBlue,
                    size: 20,
                  ),
                 ),
                 SizedBox(width: 12), */
                Text(
                  resultTitle,
                  style: GoogleFonts.poppins(
                    fontSize: 14, // Slightly larger title
                    fontWeight: FontWeight.w700, // Bolder title
                    color: _resultColor ?? AppTheme.darkGrey, // Use result color
                    letterSpacing: 0.5,
                  ),
                ),
              ],
            ),
            SizedBox(height: 12), // Adjusted spacing

            if (_resultMessage != null)
              Text(
                _resultMessage!,
                textAlign: TextAlign.center, // Center align the message
                style: GoogleFonts.poppins(
                  fontSize: 16,
                  color: _resultColor ?? AppTheme.darkGrey,
                  fontWeight: FontWeight.w500,
                  height: 1.4,
                ),
              ),
            SizedBox(height: 16),

            if (adviceText.isNotEmpty) // Advice container (remains similar)
              Container(
                padding: EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: (_resultColor ?? AppTheme.infoBlue).withOpacity(0.05),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: (_resultColor ?? AppTheme.infoBlue).withOpacity(0.2)),
                ),
                child: Row(
                  children: [
                    Icon(
                      _resultIconData == Icons.check_circle_outline_rounded ? Icons.thumb_up_rounded : Icons.lightbulb_rounded,
                      color: _resultColor ?? AppTheme.infoBlue,
                      size: 16,
                    ),
                    SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        adviceText,
                        style: GoogleFonts.poppins(
                          fontSize: 12,
                          color: _resultColor ?? AppTheme.infoBlue,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }
}