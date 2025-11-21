import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:smart_expense_tracker/app/theme/app_theme.dart';

class LandingPageTwo extends StatefulWidget {
  const LandingPageTwo({super.key});

  @override
  State<LandingPageTwo> createState() => _LandingPageTwoState();
}

class _LandingPageTwoState extends State<LandingPageTwo>
    with TickerProviderStateMixin {
  late AnimationController _fadeController;
  late AnimationController _slideController;
  late AnimationController _cardController;
  
  // Continuous animation controllers
  late AnimationController _budgetFloatController;
  late AnimationController _cardPulseController;
  
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;
  late Animation<double> _cardAnimation;
  
  // Continuous animations
  late Animation<double> _budgetFloat;
  late Animation<double> _cardPulse;

  @override
  void initState() {
    super.initState();
    
    // Initialize entrance animation controllers
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    );
    
    _slideController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );
    
    _cardController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );
    
    // Initialize continuous animation controllers
    _budgetFloatController = AnimationController(
      duration: const Duration(seconds: 4),
      vsync: this,
    );
    
    _cardPulseController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    );
    
    // Initialize entrance animations
    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _fadeController,
      curve: Curves.easeInOut,
    ));
    
    _slideAnimation = Tween<Offset>(
      begin: const Offset(-0.5, 0),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _slideController,
      curve: Curves.easeOutCubic,
    ));
    
    _cardAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _cardController,
      curve: Curves.elasticOut,
    ));
    
    // Initialize continuous animations
    _budgetFloat = Tween<double>(
      begin: -8.0,
      end: 8.0,
    ).animate(CurvedAnimation(
      parent: _budgetFloatController,
      curve: Curves.easeInOut,
    ));
    
    _cardPulse = Tween<double>(
      begin: 1.0,
      end: 1.08,
    ).animate(CurvedAnimation(
      parent: _cardPulseController,
      curve: Curves.easeInOut,
    ));
    
    _startAnimations();
  }
  
  void _startAnimations() async {
    _fadeController.forward();
    await Future.delayed(const Duration(milliseconds: 200));
    _slideController.forward();
    await Future.delayed(const Duration(milliseconds: 300));
    _cardController.forward();
    
    // Start continuous animations after entrance animations
    await Future.delayed(const Duration(milliseconds: 600));
    _budgetFloatController.repeat(reverse: true);
    _cardPulseController.repeat(reverse: true);
  }

  @override
  void dispose() {
    _fadeController.dispose();
    _slideController.dispose();
    _cardController.dispose();
    _budgetFloatController.dispose();
    _cardPulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final primaryColor = AppTheme.getPrimaryTealColor(context);
    
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: isDark
              ? [
                  AppTheme.darkBackgroundGradientStart,
                  AppTheme.darkBackground,
                  AppTheme.darkBackgroundGradientEnd,
                ]
              : [
                  primaryColor.withValues(alpha: 0.05),
                  AppTheme.offWhite,
                  Colors.white,
                ],
        ),
      ),
      child: SafeArea(
        child: SingleChildScrollView(
          child: ConstrainedBox(
            constraints: BoxConstraints(
              minHeight: MediaQuery.of(context).size.height * 0.85,
            ),
            child: IntrinsicHeight(
              child: Column(
                children: [
                  // Header with Budget Visualization
                  Flexible(
                    flex: 3,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 40),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          // Animated Budget Circle with Continuous Movement
                          FadeTransition(
                            opacity: _fadeAnimation,
                            child: AnimatedBuilder(
                              animation: _budgetFloatController,
                              builder: (context, child) {
                                return Transform.translate(
                                  offset: Offset(0, _budgetFloat.value),
                                  child: Stack(
                                    alignment: Alignment.center,
                                    children: [
                                      // Outer ring - Total budget
                                      Container(
                                        width: 220,
                                        height: 220,
                                        decoration: BoxDecoration(
                                          shape: BoxShape.circle,
                                          border: Border.all(
                                            color: primaryColor.withValues(alpha: 0.2),
                                            width: 8,
                                          ),
                                        ),
                                      ),
                                      
                                      // Progress ring - Spent amount
                                      SizedBox(
                                        width: 200,
                                        height: 200,
                                        child: CircularProgressIndicator(
                                          value: 0.65, // 65% spent
                                          strokeWidth: 12,
                                          backgroundColor: primaryColor.withValues(alpha: 0.1),
                                          valueColor: AlwaysStoppedAnimation<Color>(
                                            AppTheme.accentOrange,
                                          ),
                                        ),
                                      ),
                                      
                                      // Center content
                                      Column(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          Container(
                                            padding: const EdgeInsets.all(16),
                                            decoration: BoxDecoration(
                                              gradient: LinearGradient(
                                                colors: [primaryColor, AppTheme.accentOrange],
                                              ),
                                              shape: BoxShape.circle,
                                              boxShadow: [
                                                BoxShadow(
                                                  color: primaryColor.withValues(alpha: 0.3),
                                                  blurRadius: 20,
                                                  offset: const Offset(0, 8),
                                                ),
                                              ],
                                            ),
                                            child: Icon(
                                              Icons.account_balance_wallet_rounded,
                                              color: Colors.white,
                                              size: 32,
                                            ),
                                          ),
                                          const SizedBox(height: 16),
                                          Text(
                                            '\$1,625',
                                            style: GoogleFonts.poppins(
                                              fontSize: 28,
                                              fontWeight: FontWeight.w800,
                                              color: AppTheme.getTextColor(context),
                                            ),
                                          ),
                                          Text(
                                            'of \$2,500 spent',
                                            style: GoogleFonts.poppins(
                                              fontSize: 14,
                                              color: AppTheme.getSecondaryTextColor(context),
                                            ),
                                          ),
                                          const SizedBox(height: 8),
                                          Container(
                                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                                            decoration: BoxDecoration(
                                              color: AppTheme.successGreen.withValues(alpha: 0.1),
                                              borderRadius: BorderRadius.circular(12),
                                              border: Border.all(
                                                color: AppTheme.successGreen.withValues(alpha: 0.3),
                                              ),
                                            ),
                                            child: Text(
                                              '65% Used',
                                              style: GoogleFonts.poppins(
                                                fontSize: 11,
                                                fontWeight: FontWeight.w600,
                                                color: AppTheme.successGreen,
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                      
                                      // Floating budget categories with pulse animation
                                      AnimatedBuilder(
                                        animation: _cardPulseController,
                                        builder: (context, child) {
                                          return Stack(
                                            children: [
                                              Positioned(
                                                top: 20,
                                                right: 40,
                                                child: Transform.scale(
                                                  scale: _cardPulse.value,
                                                  child: _BudgetChip(
                                                    label: 'Food',
                                                    amount: '\$450',
                                                    color: Colors.red,
                                                    percentage: '18%',
                                                  ),
                                                ),
                                              ),
                                              Positioned(
                                                bottom: 30,
                                                left: 20,
                                                child: Transform.scale(
                                                  scale: _cardPulse.value * 0.98,
                                                  child: _BudgetChip(
                                                    label: 'Transport',
                                                    amount: '\$320',
                                                    color: Colors.blue,
                                                    percentage: '13%',
                                                  ),
                                                ),
                                              ),
                                              Positioned(
                                                top: 60,
                                                left: 10,
                                                child: Transform.scale(
                                                  scale: _cardPulse.value * 1.02,
                                                  child: _BudgetChip(
                                                    label: 'Entertainment',
                                                    amount: '\$180',
                                                    color: Colors.purple,
                                                    percentage: '7%',
                                                  ),
                                                ),
                                              ),
                                            ],
                                          );
                                        },
                                      ),
                                    ],
                                  ),
                                );
                              },
                            ),
                          ),
                          
                          const SizedBox(height: 40),
                          
                          // Animated Title and Description
                          SlideTransition(
                            position: _slideAnimation,
                            child: FadeTransition(
                              opacity: _fadeAnimation,
                              child: Column(
                                children: [
                                  Text(
                                    'Budget Control',
                                    style: GoogleFonts.poppins(
                                      fontSize: 36,
                                      fontWeight: FontWeight.w800,
                                      color: AppTheme.getTextColor(context),
                                      height: 1.1,
                                    ),
                                  ),
                                  TweenAnimationBuilder<double>(
                                    duration: const Duration(milliseconds: 1200),
                                    tween: Tween<double>(begin: 0, end: 1),
                                    curve: Curves.elasticOut,
                                    builder: (context, value, child) {
                                      return Transform.scale(
                                        scale: value,
                                        child: Text(
                                          'Made Simple',
                                          style: GoogleFonts.poppins(
                                            fontSize: 36,
                                            fontWeight: FontWeight.w800,
                                            foreground: Paint()
                                              ..shader = LinearGradient(
                                                colors: [AppTheme.accentOrange, primaryColor],
                                              ).createShader(const Rect.fromLTWH(0, 0, 200, 40)),
                                            height: 1.1,
                                          ),
                                        ),
                                      );
                                    },
                                  ),
                                  
                                  const SizedBox(height: 20),
                                  
                                  FadeTransition(
                                    opacity: Tween<double>(
                                      begin: 0.0,
                                      end: 1.0,
                                    ).animate(CurvedAnimation(
                                      parent: _fadeController,
                                      curve: const Interval(0.5, 1.0, curve: Curves.easeIn),
                                    )),
                                    child: Text(
                                      'Set smart budgets, track spending by category, and stay on top of your financial goals.',
                                      textAlign: TextAlign.center,
                                      style: GoogleFonts.poppins(
                                        fontSize: 16,
                                        color: AppTheme.getSecondaryTextColor(context),
                                        height: 1.5,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  
                  // Budget Benefits Cards
                  Flexible(
                    flex: 2,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 30),
                      child: Column(
                        children: [
                          // Monthly Budget Overview Card
                          ScaleTransition(
                            scale: _cardAnimation,
                            child: Container(
                              width: double.infinity,
                              padding: const EdgeInsets.all(20),
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                  colors: isDark
                                      ? [
                                          AppTheme.darkCard.withValues(alpha: 0.8),
                                          AppTheme.darkSurface.withValues(alpha: 0.9),
                                        ]
                                      : [
                                          Colors.white,
                                          Colors.white.withValues(alpha: 0.95),
                                        ],
                                ),
                                borderRadius: BorderRadius.circular(20),
                                border: Border.all(
                                  color: primaryColor.withValues(alpha: 0.2),
                                ),
                                boxShadow: [
                                  BoxShadow(
                                    color: primaryColor.withValues(alpha: 0.1),
                                    blurRadius: 20,
                                    offset: const Offset(0, 10),
                                  ),
                                ],
                              ),
                              child: Row(
                                children: [
                                  Container(
                                    padding: const EdgeInsets.all(16),
                                    decoration: BoxDecoration(
                                      gradient: LinearGradient(
                                        colors: [primaryColor, primaryColor.withValues(alpha: 0.8)],
                                      ),
                                      borderRadius: BorderRadius.circular(16),
                                    ),
                                    child: Icon(
                                      Icons.calendar_month_rounded,
                                      color: Colors.white,
                                      size: 32,
                                    ),
                                  ),
                                  const SizedBox(width: 20),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          'Monthly Budget Tracking',
                                          style: GoogleFonts.poppins(
                                            fontSize: 16,
                                            fontWeight: FontWeight.w700,
                                            color: AppTheme.getTextColor(context),
                                          ),
                                        ),
                                        const SizedBox(height: 4),
                                        Text(
                                          'Automatic categorization and real-time spending alerts',
                                          style: GoogleFonts.poppins(
                                            fontSize: 12,
                                            color: AppTheme.getSecondaryTextColor(context),
                                            height: 1.3,
                                          ),
                                        ),
                                        const SizedBox(height: 8),
                                        Row(
                                          children: [
                                            Icon(
                                              Icons.check_circle_rounded,
                                              size: 16,
                                              color: AppTheme.successGreen,
                                            ),
                                            const SizedBox(width: 4),
                                            Text(
                                              'Smart Alerts',
                                              style: GoogleFonts.poppins(
                                                fontSize: 11,
                                                fontWeight: FontWeight.w600,
                                                color: AppTheme.successGreen,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          
                          const SizedBox(height: 20),
                          
                          // Benefits Row
                          Row(
                            children: [
                              Expanded(
                                child: _BenefitCard(
                                  icon: Icons.category_rounded,
                                  title: 'Categories',
                                  subtitle: 'Organize by category',
                                  color: AppTheme.accentOrange,
                                ),
                              ),
                              const SizedBox(width: 15),
                              Expanded(
                                child: _BenefitCard(
                                  icon: Icons.notifications_active_rounded,
                                  title: 'Alerts',
                                  subtitle: 'Never overspend again',
                                  color: primaryColor,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                  
                  // Bottom Indicator
                  Container(
                    padding: const EdgeInsets.all(30),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        _buildDot(false, primaryColor),
                        _buildDot(true, primaryColor),
                        _buildDot(false, primaryColor),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDot(bool isActive, Color activeColor) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 4),
      width: isActive ? 24 : 8,
      height: 8,
      decoration: BoxDecoration(
        color: isActive ? activeColor : Colors.grey.shade300,
        borderRadius: BorderRadius.circular(4),
        boxShadow: isActive ? [
          BoxShadow(
            color: activeColor.withValues(alpha: 0.3),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ] : null,
      ),
    );
  }
}

class _BudgetChip extends StatelessWidget {
  final String label;
  final String amount;
  final String percentage;
  final Color color;

  const _BudgetChip({
    required this.label,
    required this.amount,
    required this.percentage,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
      decoration: BoxDecoration(
        color: isDark 
          ? AppTheme.darkCard.withValues(alpha: 0.9)
          : Colors.white.withValues(alpha: 0.95),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: color.withValues(alpha: 0.3),
        ),
        boxShadow: [
          BoxShadow(
            color: color.withValues(alpha: 0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 8,
            height: 8,
            decoration: BoxDecoration(
              color: color,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 6),
          Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: GoogleFonts.poppins(
                  fontSize: 9,
                  fontWeight: FontWeight.w600,
                  color: AppTheme.getTextColor(context),
                ),
              ),
              Text(
                '$amount ($percentage)',
                style: GoogleFonts.poppins(
                  fontSize: 8,
                  color: AppTheme.getSecondaryTextColor(context),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _BenefitCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final Color color;

  const _BenefitCard({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: isDark
              ? [
                  AppTheme.darkCard.withValues(alpha: 0.7),
                  AppTheme.darkSurface.withValues(alpha: 0.9),
                ]
              : [
                  Colors.white.withValues(alpha: 0.9),
                  Colors.white.withValues(alpha: 0.7),
                ],
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: color.withValues(alpha: 0.2),
        ),
        boxShadow: [
          BoxShadow(
            color: color.withValues(alpha: 0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              icon,
              color: color,
              size: 20,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            title,
            style: GoogleFonts.poppins(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: AppTheme.getTextColor(context),
            ),
          ),
          const SizedBox(height: 2),
          Text(
            subtitle,
            style: GoogleFonts.poppins(
              fontSize: 11,
              color: AppTheme.getSecondaryTextColor(context),
            ),
          ),
        ],
      ),
    );
  }
}
