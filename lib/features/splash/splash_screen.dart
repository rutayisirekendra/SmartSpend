import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:smart_expense_tracker/app/theme/app_theme.dart';
import 'package:smart_expense_tracker/features/auth/screens/auth_checker.dart';
import 'package:smart_expense_tracker/features/onboarding/screens/onboarding_screen.dart';

/// Initial screen that determines whether to show onboarding or go straight to auth
class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _checkFirstTime();
  }

  Future<void> _checkFirstTime() async {
    // Wait a bit for splash effect
    await Future.delayed(const Duration(seconds: 2));

    if (!mounted) return;

    final prefs = await SharedPreferences.getInstance();
    
    // ALWAYS SHOW ONBOARDING - Force reset for testing
    await prefs.setBool('hasSeenOnboarding', false);
    final hasSeenOnboarding = prefs.getBool('hasSeenOnboarding') ?? false;

    if (!mounted) return;

    if (hasSeenOnboarding) {
      // Go directly to auth checker
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => const AuthChecker()),
      );
    } else {
      // Show onboarding
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => const OnboardingScreen()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return Scaffold(
      backgroundColor: isDark ? AppTheme.darkBackground : AppTheme.offWhite,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // App Icon/Logo
            Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [AppTheme.primaryTeal, AppTheme.accentOrange],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(30),
                boxShadow: [
                  BoxShadow(
                    color: AppTheme.primaryTeal.withOpacity(0.3),
                    blurRadius: 20,
                    offset: const Offset(0, 10),
                  ),
                ],
              ),
              child: const Icon(
                Icons.account_balance_wallet,
                size: 60,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 24),
            
            // App Name
            Text(
              'SmartSpend',
              style: TextStyle(
                fontSize: 32,
                fontWeight: FontWeight.bold,
                color: isDark ? Colors.white : AppTheme.darkGrey,
                letterSpacing: 1.2,
              ),
            ),
            const SizedBox(height: 8),
            
            Text(
              'Track • Save • Grow',
              style: TextStyle(
                fontSize: 16,
                color: isDark ? Colors.white70 : AppTheme.darkGrey,
                letterSpacing: 2,
              ),
            ),
            const SizedBox(height: 40),
            
            // Loading indicator
            CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(
                isDark ? AppTheme.primaryTeal : AppTheme.accentOrange,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
