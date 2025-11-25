import 'package:flutter/material.dart';
import 'package:smart_expense_tracker/features/onboarding/screens/landing_page_one.dart';
import 'package:smart_expense_tracker/features/onboarding/screens/landing_page_two.dart';
import 'package:smart_expense_tracker/features/onboarding/screens/landing_page_three.dart';
import 'package:smart_expense_tracker/features/auth/screens/auth_checker.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  late PageController _pageController;
  int _currentPage = 0;

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _onPageChanged(int page) {
    setState(() {
      _currentPage = page;
    });
  }

  void _skipToLogin() {
    // No need to mark as seen - we want to show landing pages every time
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(
        builder: (context) => const AuthChecker(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          PageView(
            controller: _pageController,
            onPageChanged: _onPageChanged,
            children: const [
              LandingPageOne(),
              LandingPageTwo(),
              LandingPageThree(),
            ],
          ),
          
          // Skip button with orange styling for both dark and light mode
          if (_currentPage < 2)
            Positioned(
              top: MediaQuery.of(context).padding.top + 20,
              right: 24,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  color: Colors.orange.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: Colors.orange,
                    width: 2,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.orange.withOpacity(0.2),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: TextButton(
                  onPressed: _skipToLogin,
                  style: TextButton.styleFrom(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    minimumSize: Size.zero,
                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  ),
                  child: const Text(
                    'Skip',
                    style: TextStyle(
                      color: Colors.orange,
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      letterSpacing: 0.5,
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
