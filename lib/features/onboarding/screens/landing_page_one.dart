import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:smart_expense_tracker/app/theme/app_theme.dart';

class LandingPageOne extends StatefulWidget {
  const LandingPageOne({super.key});

  @override
  State<LandingPageOne> createState() => _LandingPageOneState();
}

class _LandingPageOneState extends State<LandingPageOne>
    with TickerProviderStateMixin {
  late AnimationController _fadeController;
  late AnimationController _slideController;
  late AnimationController _scaleController;
  late AnimationController _logoController;
  
  // Continuous animation controllers
  late AnimationController _logoFloatController;
  late AnimationController _logoRotateController;
  late AnimationController _iconPulseController;
  
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;
  late Animation<double> _scaleAnimation;
  late Animation<double> _logoRotation;
  late Animation<double> _logoScale;
  
  // Continuous animations
  late Animation<double> _logoFloat;
  late Animation<double> _logoContinuousRotation;
  late Animation<double> _iconPulse;

  @override
  void initState() {
    super.initState();
    
    // Initialize entrance animation controllers
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );
    
    _slideController = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    );
    
    _scaleController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    
    _logoController = AnimationController(
      duration: const Duration(milliseconds: 2000),
      vsync: this,
    );
    
    // Initialize continuous animation controllers
    _logoFloatController = AnimationController(
      duration: const Duration(seconds: 3),
      vsync: this,
    );
    
    _logoRotateController = AnimationController(
      duration: const Duration(seconds: 8),
      vsync: this,
    );
    
    _iconPulseController = AnimationController(
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
      begin: const Offset(0, 0.5),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _slideController,
      curve: Curves.easeOutCubic,
    ));
    
    _scaleAnimation = Tween<double>(
      begin: 0.8,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _scaleController,
      curve: Curves.elasticOut,
    ));
    
    _logoRotation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _logoController,
      curve: Curves.elasticOut,
    ));
    
    _logoScale = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _logoController,
      curve: Curves.bounceOut,
    ));
    
    // Initialize continuous animations
    _logoFloat = Tween<double>(
      begin: -10.0,
      end: 10.0,
    ).animate(CurvedAnimation(
      parent: _logoFloatController,
      curve: Curves.easeInOut,
    ));
    
    _logoContinuousRotation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(_logoRotateController);
    
    _iconPulse = Tween<double>(
      begin: 1.0,
      end: 1.15,
    ).animate(CurvedAnimation(
      parent: _iconPulseController,
      curve: Curves.easeInOut,
    ));
    
    // Start animations with delays
    _startAnimations();
  }
  
  void _startAnimations() async {
    _logoController.forward();
    await Future.delayed(const Duration(milliseconds: 300));
    _fadeController.forward();
    await Future.delayed(const Duration(milliseconds: 200));
    _slideController.forward();
    _scaleController.forward();
    
    // Start continuous animations after entrance animations
    await Future.delayed(const Duration(milliseconds: 800));
    _logoFloatController.repeat(reverse: true);
    _logoRotateController.repeat();
    _iconPulseController.repeat(reverse: true);
  }

  @override
  void dispose() {
    _fadeController.dispose();
    _slideController.dispose();
    _scaleController.dispose();
    _logoController.dispose();
    _logoFloatController.dispose();
    _logoRotateController.dispose();
    _iconPulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final primaryColor = AppTheme.getPrimaryTealColor(context);
    
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: isDark
              ? [
                  AppTheme.darkBackground,
                  AppTheme.darkBackgroundGradientStart,
                  AppTheme.darkBackgroundGradientEnd,
                ]
              : [
                  AppTheme.offWhite,
                  Colors.white,
                  AppTheme.offWhite.withValues(alpha: 0.8),
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
                  const SizedBox(height: 40),
                  
                  // Hero Section
                  Flexible(
                    flex: 4,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 32),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          // Animated Logo Section with Continuous Movement
                          AnimatedBuilder(
                            animation: Listenable.merge([
                              _logoController,
                              _logoFloatController,
                              _logoRotateController,
                            ]),
                            builder: (context, child) {
                              return Transform.translate(
                                offset: Offset(0, _logoFloat.value),
                                child: Transform.scale(
                                  scale: _logoScale.value,
                                  child: Transform.rotate(
                                    angle: (_logoRotation.value * 0.1) + 
                                           (_logoContinuousRotation.value * 0.02),
                                    child: Container(
                                      width: 160,
                                      height: 160,
                                      decoration: BoxDecoration(
                                        gradient: RadialGradient(
                                          colors: [
                                            primaryColor.withValues(alpha: 0.15),
                                            primaryColor.withValues(alpha: 0.05),
                                            Colors.transparent,
                                          ],
                                          stops: const [0.3, 0.7, 1.0],
                                        ),
                                        shape: BoxShape.circle,
                                      ),
                                      child: Center(
                                        child: Container(
                                          width: 100,
                                          height: 100,
                                          decoration: BoxDecoration(
                                            gradient: LinearGradient(
                                              begin: Alignment.topLeft,
                                              end: Alignment.bottomRight,
                                              colors: [primaryColor, AppTheme.accentOrange],
                                            ),
                                            shape: BoxShape.circle,
                                            boxShadow: [
                                              BoxShadow(
                                                color: primaryColor.withValues(alpha: 0.3),
                                                blurRadius: 30,
                                                offset: const Offset(0, 15),
                                              ),
                                            ],
                                          ),
                                          child: const Icon(
                                            Icons.account_balance_wallet_rounded,
                                            size: 50,
                                            color: Colors.white,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              );
                            },
                          ),
                          
                          const SizedBox(height: 50),
                          
                          // Animated Main Title
                          SlideTransition(
                            position: _slideAnimation,
                            child: FadeTransition(
                              opacity: _fadeAnimation,
                              child: ScaleTransition(
                                scale: _scaleAnimation,
                                child: RichText(
                                  textAlign: TextAlign.center,
                                  text: TextSpan(
                                    children: [
                                      TextSpan(
                                        text: 'Smart Expense\n',
                                        style: GoogleFonts.poppins(
                                          fontSize: 40,
                                          fontWeight: FontWeight.w800,
                                          color: AppTheme.getTextColor(context),
                                          height: 1.1,
                                        ),
                                      ),
                                      TextSpan(
                                        text: 'Tracking',
                                        style: GoogleFonts.poppins(
                                          fontSize: 40,
                                          fontWeight: FontWeight.w800,
                                          foreground: Paint()
                                            ..shader = LinearGradient(
                                              colors: [primaryColor, AppTheme.accentOrange],
                                            ).createShader(const Rect.fromLTWH(0, 0, 200, 50)),
                                          height: 1.1,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ),
                          
                          const SizedBox(height: 24),
                          
                          // Animated Subtitle
                          SlideTransition(
                            position: Tween<Offset>(
                              begin: const Offset(0, 0.8),
                              end: Offset.zero,
                            ).animate(CurvedAnimation(
                              parent: _slideController,
                              curve: const Interval(0.3, 1.0, curve: Curves.easeOut),
                            )),
                            child: FadeTransition(
                              opacity: Tween<double>(
                                begin: 0.0,
                                end: 1.0,
                              ).animate(CurvedAnimation(
                                parent: _fadeController,
                                curve: const Interval(0.5, 1.0, curve: Curves.easeIn),
                              )),
                              child: Container(
                                padding: const EdgeInsets.symmetric(horizontal: 20),
                                child: Text(
                                  'Take control of your finances with intelligent expense tracking designed for students.',
                                  textAlign: TextAlign.center,
                                  style: GoogleFonts.poppins(
                                    fontSize: 16,
                                    color: AppTheme.getSecondaryTextColor(context),
                                    height: 1.6,
                                    letterSpacing: 0.2,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  
                  // Animated Feature Highlights
                  Flexible(
                    flex: 2,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 20),
                      child: Column(
                        children: [
                          SlideTransition(
                            position: Tween<Offset>(
                              begin: const Offset(0, 1.0),
                              end: Offset.zero,
                            ).animate(CurvedAnimation(
                              parent: _slideController,
                              curve: const Interval(0.6, 1.0, curve: Curves.elasticOut),
                            )),
                            child: FadeTransition(
                              opacity: Tween<double>(
                                begin: 0.0,
                                end: 1.0,
                              ).animate(CurvedAnimation(
                                parent: _fadeController,
                                curve: const Interval(0.7, 1.0, curve: Curves.easeIn),
                              )),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                children: [
                                  _buildAnimatedFeatureIcon(
                                    Icons.trending_up_rounded,
                                    'Track',
                                    context,
                                    0,
                                  ),
                                  _buildAnimatedFeatureIcon(
                                    Icons.pie_chart_rounded,
                                    'Analyze',
                                    context,
                                    200,
                                  ),
                                  _buildAnimatedFeatureIcon(
                                    Icons.savings_rounded,
                                    'Save',
                                    context,
                                    400,
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  
                  // Animated Page Indicators
                  Flexible(
                    flex: 1,
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 30),
                      child: SlideTransition(
                        position: Tween<Offset>(
                          begin: const Offset(0, 1.2),
                          end: Offset.zero,
                        ).animate(CurvedAnimation(
                          parent: _slideController,
                          curve: const Interval(0.8, 1.0, curve: Curves.bounceOut),
                        )),
                        child: FadeTransition(
                          opacity: Tween<double>(
                            begin: 0.0,
                            end: 1.0,
                          ).animate(CurvedAnimation(
                            parent: _fadeController,
                            curve: const Interval(0.8, 1.0, curve: Curves.easeIn),
                          )),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              _buildAnimatedDot(true, primaryColor, 0),
                              _buildAnimatedDot(false, primaryColor, 100),
                              _buildAnimatedDot(false, primaryColor, 200),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                  
                  // Animated Swipe Hint
                  Container(
                    padding: const EdgeInsets.only(bottom: 20),
                    child: SlideTransition(
                      position: Tween<Offset>(
                        begin: const Offset(0, 1.5),
                        end: Offset.zero,
                      ).animate(CurvedAnimation(
                        parent: _slideController,
                        curve: const Interval(0.9, 1.0, curve: Curves.easeOut),
                      )),
                      child: FadeTransition(
                        opacity: Tween<double>(
                          begin: 0.0,
                          end: 1.0,
                        ).animate(CurvedAnimation(
                          parent: _fadeController,
                          curve: const Interval(0.9, 1.0, curve: Curves.easeIn),
                        )),
                        child: TweenAnimationBuilder<double>(
                          duration: const Duration(seconds: 2),
                          tween: Tween<double>(begin: 0, end: 1),
                          builder: (context, value, child) {
                            return Transform.translate(
                              offset: Offset(10 * (value * 2 - 1).abs(), 0),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    Icons.swipe_left_rounded,
                                    color: AppTheme.getSecondaryTextColor(context),
                                    size: 20,
                                  ),
                                  const SizedBox(width: 8),
                                  Text(
                                    'Swipe to explore features',
                                    style: GoogleFonts.poppins(
                                      fontSize: 12,
                                      color: AppTheme.getSecondaryTextColor(context),
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ],
                              ),
                            );
                          },
                        ),
                      ),
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

  Widget _buildAnimatedFeatureIcon(IconData icon, String label, BuildContext context, int delay) {
    final primaryColor = AppTheme.getPrimaryTealColor(context);
    
    return TweenAnimationBuilder<double>(
      duration: Duration(milliseconds: 800 + delay),
      tween: Tween<double>(begin: 0, end: 1),
      curve: Curves.elasticOut,
      builder: (context, value, child) {
        return Transform.scale(
          scale: value,
          child: Transform.translate(
            offset: Offset(0, 20 * (1 - value)),
            child: Opacity(
              opacity: value.clamp(0.0, 1.0),
              child: AnimatedBuilder(
                animation: _iconPulseController,
                builder: (context, child) {
                  return Transform.scale(
                    scale: _iconPulse.value,
                    child: Column(
                      children: [
                        Container(
                          width: 60,
                          height: 60,
                          decoration: BoxDecoration(
                            color: primaryColor.withValues(alpha: 0.1),
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: primaryColor.withValues(alpha: 0.2),
                              width: 1,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: primaryColor.withValues(alpha: 0.1),
                                blurRadius: 10,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: Icon(
                            icon,
                            color: primaryColor,
                            size: 28,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          label,
                          style: GoogleFonts.poppins(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: AppTheme.getSecondaryTextColor(context),
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
          ),
        );
      },
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

  Widget _buildFeatureIcon(IconData icon, String label, BuildContext context) {
    final primaryColor = AppTheme.getPrimaryTealColor(context);
    
    return Column(
      children: [
        Container(
          width: 60,
          height: 60,
          decoration: BoxDecoration(
            color: primaryColor.withValues(alpha: 0.1),
            shape: BoxShape.circle,
            border: Border.all(
              color: primaryColor.withValues(alpha: 0.2),
              width: 1,
            ),
          ),
          child: Icon(
            icon,
            color: primaryColor,
            size: 28,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          label,
          style: GoogleFonts.poppins(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: AppTheme.getSecondaryTextColor(context),
          ),
        ),
      ],
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
      ),
    );
  }
}
