import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:smart_expense_tracker/app/theme/app_theme.dart';
import 'package:smart_expense_tracker/features/auth/screens/auth_checker.dart';

class LandingPageThree extends StatefulWidget {
  const LandingPageThree({super.key});

  @override
  State<LandingPageThree> createState() => _LandingPageThreeState();
}

class _LandingPageThreeState extends State<LandingPageThree>
    with TickerProviderStateMixin {
  late AnimationController _fadeController;
  late AnimationController _slideController;
  late AnimationController _buttonController;
  
  // Continuous animation controllers
  late AnimationController _cardFloatController;
  late AnimationController _iconPulseController;
  late AnimationController _coinRotateController;
  
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;
  late Animation<double> _buttonScale;
  
  // Continuous animations
  late Animation<double> _cardFloat;
  late Animation<double> _iconPulse;
  late Animation<double> _coinRotation;

  @override
  void initState() {
    super.initState();
    
    // Initialize entrance animation controllers
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );
    
    _slideController = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    );
    
    _buttonController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    
    // Initialize continuous animation controllers
    _cardFloatController = AnimationController(
      duration: const Duration(seconds: 3),
      vsync: this,
    );
    
    _iconPulseController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    );
    
    _coinRotateController = AnimationController(
      duration: const Duration(seconds: 8),
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
      begin: const Offset(0.5, 0),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _slideController,
      curve: Curves.easeOutCubic,
    ));
    
    _buttonScale = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _buttonController,
      curve: Curves.elasticOut,
    ));
    
    // Initialize continuous animations
    _cardFloat = Tween<double>(
      begin: -6.0,
      end: 6.0,
    ).animate(CurvedAnimation(
      parent: _cardFloatController,
      curve: Curves.easeInOut,
    ));
    
    _iconPulse = Tween<double>(
      begin: 1.0,
      end: 1.1,
    ).animate(CurvedAnimation(
      parent: _iconPulseController,
      curve: Curves.easeInOut,
    ));
    
    _coinRotation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(_coinRotateController);
    
    _startAnimations();
  }
  
  void _startAnimations() async {
    _fadeController.forward();
    await Future.delayed(const Duration(milliseconds: 300));
    _slideController.forward();
    await Future.delayed(const Duration(milliseconds: 600));
    _buttonController.forward();
    
    // Start continuous animations after entrance animations
    await Future.delayed(const Duration(milliseconds: 500));
    _cardFloatController.repeat(reverse: true);
    _iconPulseController.repeat(reverse: true);
    _coinRotateController.repeat();
  }

  @override
  void dispose() {
    _fadeController.dispose();
    _slideController.dispose();
    _buttonController.dispose();
    _cardFloatController.dispose();
    _iconPulseController.dispose();
    _coinRotateController.dispose();
    super.dispose();
  }

  Future<void> _navigateToAuth(BuildContext context) async {
    // Mark onboarding as seen
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('hasSeenOnboarding', true);
    
    // Navigate to auth checker which handles login/signup flow
    if (context.mounted) {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          builder: (context) => const AuthChecker(),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final primaryColor = AppTheme.getPrimaryTealColor(context);
    
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topRight,
          end: Alignment.bottomLeft,
          colors: isDark
              ? [
                  AppTheme.darkBackground,
                  AppTheme.darkBackgroundGradientEnd,
                  AppTheme.darkBackgroundGradientStart,
                ]
              : [
                  AppTheme.accentOrange.withValues(alpha: 0.03),
                  AppTheme.offWhite,
                  primaryColor.withValues(alpha: 0.05),
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
                  // Header with Goal Achievement Visualization
                  Flexible(
                    flex: 3,
                    child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 40),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Goal Achievement Dashboard with Continuous Movement
                    AnimatedBuilder(
                      animation: Listenable.merge([
                        _fadeController,
                        _cardFloatController,
                        _iconPulseController,
                        _coinRotateController,
                      ]),
                      builder: (context, child) {
                        return FadeTransition(
                          opacity: _fadeAnimation,
                          child: Transform.translate(
                            offset: Offset(0, _cardFloat.value),
                            child: Stack(
                              alignment: Alignment.center,
                              children: [
                                // Background pattern with subtle rotation
                                Transform.rotate(
                                  angle: _coinRotation.value * 0.05,
                                  child: Container(
                                    width: 240,
                                    height: 240,
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      gradient: LinearGradient(
                                        begin: Alignment.topLeft,
                                        end: Alignment.bottomRight,
                                        colors: [
                                          primaryColor.withValues(alpha: 0.05),
                                          AppTheme.accentOrange.withValues(alpha: 0.05),
                                        ],
                                      ),
                                      border: Border.all(
                                        color: primaryColor.withValues(alpha: 0.1),
                                        width: 2,
                                      ),
                                    ),
                                  ),
                                ),
                                
                                // Goal Cards with individual pulse animations
                                Positioned(
                                  top: 20,
                                  child: Transform.scale(
                                    scale: _iconPulse.value,
                                    child: _GoalCard(
                                      title: 'Laptop',
                                      progress: 0.85,
                                      amount: '\$850',
                                      target: '\$1000',
                                      color: primaryColor,
                                      icon: Icons.computer_rounded,
                                    ),
                                  ),
                                ),
                                Positioned(
                                  left: 10,
                                  child: Transform.scale(
                                    scale: _iconPulse.value * 0.98, // Slight variation
                                    child: _GoalCard(
                                      title: 'Vacation',
                                      progress: 0.45,
                                      amount: '\$900',
                                      target: '\$2000',
                                      color: Colors.blue,
                                      icon: Icons.flight_rounded,
                                    ),
                                  ),
                                ),
                                Positioned(
                                  right: 10,
                                  child: Transform.scale(
                                    scale: _iconPulse.value * 1.02, // Slight variation
                                    child: _GoalCard(
                                      title: 'Emergency',
                                      progress: 0.70,
                                      amount: '\$700',
                                      target: '\$1000',
                                      color: Colors.red,
                                      icon: Icons.emergency_rounded,
                                    ),
                                  ),
                                ),
                                
                                // Center Achievement Icon with pulse and rotation
                                Transform.scale(
                                  scale: _iconPulse.value * 1.05,
                                  child: Transform.rotate(
                                    angle: _coinRotation.value * 0.1,
                                    child: Container(
                                      padding: const EdgeInsets.all(20),
                                      decoration: BoxDecoration(
                                        gradient: LinearGradient(
                                          colors: [
                                            AppTheme.successGreen,
                                            AppTheme.successGreen.withValues(alpha: 0.8),
                                          ],
                                        ),
                                        shape: BoxShape.circle,
                                        boxShadow: [
                                          BoxShadow(
                                            color: AppTheme.successGreen.withValues(alpha: 0.3),
                                            blurRadius: 20,
                                            offset: const Offset(0, 8),
                                          ),
                                        ],
                                      ),
                                      child: Icon(
                                        Icons.emoji_events_rounded,
                                        size: 50,
                                        color: Colors.white,
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                    
                    const SizedBox(height: 40),
                    
                    // Title and Description
                    Text(
                      'Achieve Your',
                      style: GoogleFonts.poppins(
                        fontSize: 36,
                        fontWeight: FontWeight.w800,
                        color: AppTheme.getTextColor(context),
                        height: 1.1,
                      ),
                    ),
                    Text(
                      'Financial Dreams',
                      style: GoogleFonts.poppins(
                        fontSize: 36,
                        fontWeight: FontWeight.w800,
                        foreground: Paint()
                          ..shader = LinearGradient(
                            colors: [AppTheme.successGreen, AppTheme.accentOrange],
                          ).createShader(const Rect.fromLTWH(0, 0, 300, 40)),
                        height: 1.1,
                      ),
                    ),
                    
                    const SizedBox(height: 20),
                    
                    Text(
                      'Set meaningful goals, track your progress, and celebrate every milestone on your journey to financial success.',
                      textAlign: TextAlign.center,
                      style: GoogleFonts.poppins(
                        fontSize: 16,
                        color: AppTheme.getSecondaryTextColor(context),
                        height: 1.5,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            
            // Analytics Preview Section
            Flexible(
              flex: 2,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 30),
                child: Column(
                  children: [
                    // Analytics Dashboard Card
                    Container(
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
                          color: AppTheme.successGreen.withValues(alpha: 0.2),
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: AppTheme.successGreen.withValues(alpha: 0.1),
                            blurRadius: 20,
                            offset: const Offset(0, 10),
                          ),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(16),
                                decoration: BoxDecoration(
                                  gradient: LinearGradient(
                                    colors: [
                                      AppTheme.successGreen,
                                      AppTheme.successGreen.withValues(alpha: 0.8),
                                    ],
                                  ),
                                  borderRadius: BorderRadius.circular(16),
                                ),
                                child: Icon(
                                  Icons.analytics_rounded,
                                  color: Colors.white,
                                  size: 24,
                                ),
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Expense Reports & Insights',
                                      style: GoogleFonts.poppins(
                                        fontSize: 16,
                                        fontWeight: FontWeight.w700,
                                        color: AppTheme.getTextColor(context),
                                      ),
                                    ),
                                    Text(
                                      'View detailed spending reports',
                                      style: GoogleFonts.poppins(
                                        fontSize: 12,
                                        color: AppTheme.getSecondaryTextColor(context),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          
                          const SizedBox(height: 20),
                          
                          // Mini chart visualization
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: [
                              _MiniStat(
                                label: 'Saved',
                                value: '+\$340',
                                color: AppTheme.successGreen,
                                trend: Icons.trending_up_rounded,
                              ),
                              _MiniStat(
                                label: 'Spent',
                                value: '\$1,850',
                                color: AppTheme.accentOrange,
                                trend: Icons.remove_circle_outline_rounded,
                              ),
                              _MiniStat(
                                label: 'Goals',
                                value: '3/5',
                                color: primaryColor,
                                trend: Icons.flag_rounded,
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    
                    const SizedBox(height: 20),
                    
                    // Feature highlights
                    Row(
                      children: [
                        Expanded(
                          child: _FeatureHighlight(
                            icon: Icons.auto_graph_rounded,
                            title: 'Trends',
                            subtitle: 'Spot patterns early',
                            color: primaryColor,
                          ),
                        ),
                        const SizedBox(width: 15),
                        Expanded(
                          child: _FeatureHighlight(
                            icon: Icons.receipt_long_rounded,
                            title: 'Reports',
                            subtitle: 'Detailed breakdowns',
                            color: AppTheme.accentOrange,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            
            // Bottom with Get Started CTA
            Container(
              padding: const EdgeInsets.all(30),
              child: Column(
                children: [
                  ScaleTransition(
                    scale: _buttonScale,
                    child: Container(
                      width: double.infinity,
                      height: 56,
                      decoration: AppTheme.getGradientButtonDecoration(),
                      child: ElevatedButton.icon(
                        onPressed: () => _navigateToAuth(context),
                        icon: const Icon(Icons.rocket_launch_rounded, color: Colors.white),
                        label: Text(
                          'START YOUR JOURNEY',
                          style: GoogleFonts.poppins(
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                            color: Colors.white,
                            letterSpacing: 0.5,
                          ),
                        ),
                        style: AppTheme.getGradientButtonStyle(),
                      ),
                    ),
                  ),
                  
                  const SizedBox(height: 20),
                  
                  // Animated Page indicators
                  FadeTransition(
                    opacity: _fadeAnimation,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        _buildAnimatedDot(false, primaryColor, 0),
                        _buildAnimatedDot(false, primaryColor, 100),
                        _buildAnimatedDot(true, primaryColor, 200),
                      ],
                    ),
                  ),
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

  Widget _buildAnimatedDot(bool isActive, Color activeColor, int delay) {
    return TweenAnimationBuilder<double>(
      duration: Duration(milliseconds: 600 + delay),
      tween: Tween<double>(begin: 0, end: 1),
      curve: Curves.bounceOut,
      builder: (context, value, child) {
        return Transform.scale(
          scale: value,
          child: Container(
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
          ),
        );
      },
    );
  }

}

class _GoalCard extends StatelessWidget {
  final String title;
  final double progress;
  final String amount;
  final String target;
  final Color color;
  final IconData icon;

  const _GoalCard({
    required this.title,
    required this.progress,
    required this.amount,
    required this.target,
    required this.color,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return Container(
      width: 110,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: isDark
              ? [
                  AppTheme.darkCard.withValues(alpha: 0.9),
                  AppTheme.darkSurface.withValues(alpha: 0.95),
                ]
              : [
                  Colors.white,
                  Colors.white.withValues(alpha: 0.9),
                ],
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: color.withValues(alpha: 0.2),
        ),
        boxShadow: [
          BoxShadow(
            color: color.withValues(alpha: 0.1),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
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
              size: 16,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            title,
            style: GoogleFonts.poppins(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: AppTheme.getTextColor(context),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            '$amount/$target',
            style: GoogleFonts.poppins(
              fontSize: 9,
              color: AppTheme.getSecondaryTextColor(context),
            ),
          ),
          const SizedBox(height: 6),
          LinearProgressIndicator(
            value: progress,
            backgroundColor: color.withValues(alpha: 0.1),
            valueColor: AlwaysStoppedAnimation<Color>(color),
            minHeight: 3,
          ),
          const SizedBox(height: 4),
          Text(
            '${(progress * 100).toInt()}%',
            style: GoogleFonts.poppins(
              fontSize: 10,
              fontWeight: FontWeight.w600,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}

class _MiniStat extends StatelessWidget {
  final String label;
  final String value;
  final Color color;
  final IconData trend;

  const _MiniStat({
    required this.label,
    required this.value,
    required this.color,
    required this.trend,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(
            trend,
            color: color,
            size: 16,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          value,
          style: GoogleFonts.poppins(
            fontSize: 14,
            fontWeight: FontWeight.w700,
            color: AppTheme.getTextColor(context),
          ),
        ),
        Text(
          label,
          style: GoogleFonts.poppins(
            fontSize: 10,
            color: AppTheme.getSecondaryTextColor(context),
          ),
        ),
      ],
    );
  }
}

class _FeatureHighlight extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final Color color;

  const _FeatureHighlight({
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
