import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:smart_expense_tracker/app/theme/app_theme.dart';
import 'package:smart_expense_tracker/common_widgets/modern_card.dart';
import 'package:smart_expense_tracker/features/main/screens/main_screen.dart';

class SimulatorScreen extends StatefulWidget {
  const SimulatorScreen({Key? key}) : super(key: key);

  @override
  State<SimulatorScreen> createState() => _SimulatorScreenState();
}

class _SimulatorScreenState extends State<SimulatorScreen> with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final _itemNameController = TextEditingController();
  final _itemAmountController = TextEditingController();

  String? _resultMessage;
  Color? _resultColor;
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;
  bool _showResult = false;

  // Mock data for simulation
  final double _monthlyBudget = 500.0;
  final double _spentSoFar = 200.0;
  final int _daysInMonth = DateTime(DateTime.now().year, DateTime.now().month + 1, 0).day;
  final int _dayOfMonth = DateTime.now().day;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 600),
    );
    _scaleAnimation = Tween<double>(begin: 0.8, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.elasticOut),
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    _itemNameController.dispose();
    _itemAmountController.dispose();
    super.dispose();
  }

  void _runSimulation() {
    if (_formKey.currentState!.validate()) {
      final itemAmount = double.parse(_itemAmountController.text);

      // Financial simulation logic
      final daysLeft = _daysInMonth - _dayOfMonth;
      final dailyAverageSpending = _spentSoFar / _dayOfMonth;
      final projectedFutureSpending = dailyAverageSpending * daysLeft;
      final totalProjectedSpending = _spentSoFar + itemAmount + projectedFutureSpending;
      final difference = totalProjectedSpending - _monthlyBudget;

      setState(() {
        if (difference <= 0) {
          _resultMessage = "🎉 Go for it! Buying this item keeps you on track and you're projected to be \$${(-difference).toStringAsFixed(2)} under budget.";
          _resultColor = AppTheme.primaryTeal;
        } else {
          _resultMessage = "⚠️ Warning: This purchase will put you on track to be \$${difference.toStringAsFixed(2)} over budget this month. Consider if it's essential.";
          _resultColor = AppTheme.accentOrange;
        }
        _showResult = true;
      });

      _animationController.forward(from: 0.0);
    }
  }

  void _resetSimulation() {
    setState(() {
      _showResult = false;
      _resultMessage = null;
      _itemNameController.clear();
      _itemAmountController.clear();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.offWhite,
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

                    // Quick Stats Card
                    _buildStatsSection(),
                    const SizedBox(height: 24),

                    // Action Buttons
                    _buildActionButtons(),
                    const SizedBox(height: 24),

                    // Results Section
                    if (_showResult) _buildResultsSection(),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
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

          // Quick Tips
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
                  color: Colors.grey[600],
                  letterSpacing: 1,
                ),
              ),
            ],
          ),
          SizedBox(height: 20),

          // Item Name Field
          TextFormField(
            controller: _itemNameController,
            decoration: InputDecoration(
              labelText: 'What are you thinking of buying? 🛍️',
              labelStyle: GoogleFonts.poppins(color: Colors.grey[600]),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: Colors.grey[300]!),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: AppTheme.primaryTeal),
              ),
              filled: true,
              fillColor: Colors.grey[50],
              contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 16),
            ),
            style: GoogleFonts.poppins(fontSize: 16),
            validator: (value) => value == null || value.isEmpty ? 'Please enter a name 📝' : null,
          ),
          SizedBox(height: 16),

          // Item Amount Field
          TextFormField(
            controller: _itemAmountController,
            keyboardType: TextInputType.numberWithOptions(decimal: true),
            decoration: InputDecoration(
              labelText: 'How much does it cost? 💰',
              labelStyle: GoogleFonts.poppins(color: Colors.grey[600]),
              prefixText: '\$ ',
              prefixStyle: GoogleFonts.poppins(
                color: AppTheme.darkGrey,
                fontWeight: FontWeight.w600,
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: Colors.grey[300]!),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: AppTheme.primaryTeal),
              ),
              filled: true,
              fillColor: Colors.grey[50],
              contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 16),
            ),
            style: GoogleFonts.poppins(fontSize: 16),
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

  Widget _buildStatsSection() {
    final daysLeft = _daysInMonth - _dayOfMonth;
    final dailyBudget = (_monthlyBudget - _spentSoFar) / daysLeft;

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
                  color: AppTheme.accentOrange.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: AppTheme.accentOrange),
                ),
                child: Icon(Icons.analytics_rounded, size: 20, color: AppTheme.accentOrange),
              ),
              SizedBox(width: 12),
              Text(
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
              _buildStatItem('\$$_monthlyBudget', 'Monthly Budget', Icons.account_balance_wallet_rounded),
              _buildStatItem('\$$_spentSoFar', 'Spent So Far', Icons.shopping_cart_rounded),
              _buildStatItem('\$${dailyBudget.toStringAsFixed(2)}', 'Daily Budget', Icons.today_rounded),
            ],
          ),
          SizedBox(height: 12),
          Container(
            padding: EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppTheme.primaryTeal.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppTheme.infoBlue.withOpacity(0.3)),
            ),
            child: Row(
              children: [
                Icon(Icons.info_rounded, color: AppTheme.infoBlue, size: 16),
                SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'You have $daysLeft days left this month with \$${dailyBudget.toStringAsFixed(2)} available per day',
                    style: GoogleFonts.poppins(
                      fontSize: 12,
                      color: AppTheme.infoBlue,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem(String value, String label, IconData icon) {
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
              fontSize: 14,
              fontWeight: FontWeight.w700,
              color: AppTheme.primaryTeal,
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

  Widget _buildResultsSection() {
    return AnimatedBuilder(
      animation: _scaleAnimation,
      builder: (context, child) {
        return Transform.scale(
          scale: _scaleAnimation.value,
          child: child,
        );
      },
      child: ModernCard(
        padding: EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: _resultColor!.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: _resultColor!),
                  ),
                  child: Icon(
                    _resultColor == AppTheme.infoBlue ? Icons.check_circle_rounded : Icons.warning_rounded,
                    color: _resultColor,
                    size: 20,
                  ),
                ),
                SizedBox(width: 12),
                Text(
                  _resultColor == AppTheme.infoBlue ? 'GOOD NEWS! 🎉' : 'CONSIDER THIS ⚠️',
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
            Text(
              _resultMessage!,
              style: GoogleFonts.poppins(
                fontSize: 16,
                color: _resultColor,
                fontWeight: FontWeight.w500,
                height: 1.4,
              ),
            ),
            SizedBox(height: 16),
            Container(
              padding: EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: _resultColor!.withOpacity(0.05),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: _resultColor!.withOpacity(0.2)),
              ),
              child: Row(
                children: [
                  Icon(
                    _resultColor == AppTheme.infoBlue ? Icons.thumb_up_rounded : Icons.lightbulb_rounded,
                    color: _resultColor,
                    size: 16,
                  ),
                  SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      _resultColor == AppTheme.infoBlue
                          ? 'This purchase aligns well with your budget goals!'
                          : 'Consider waiting or looking for alternatives to stay on track.',
                      style: GoogleFonts.poppins(
                        fontSize: 12,
                        color: _resultColor,
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