import 'package:flutter/material.dart';
import 'package:smart_expense_tracker/app/theme/app_theme.dart';

class AuthToggleSwitch extends StatelessWidget {
  final bool isLogin;
  final VoidCallback onLoginTapped;
  final VoidCallback onSignUpTapped;

  const AuthToggleSwitch({
    super.key,
    required this.isLogin,
    required this.onLoginTapped,
    required this.onSignUpTapped,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return Container(
      width: 250,
      height: 50,
      decoration: BoxDecoration(
        color: isDark 
            ? AppTheme.darkCard.withOpacity(0.6)
            : AppTheme.darkGrey.withOpacity(0.1),
        borderRadius: BorderRadius.circular(25),
        border: Border.all(
          color: isDark 
              ? Colors.white.withOpacity(0.1)
              : Colors.grey.withOpacity(0.2),
          width: 1,
        ),
      ),
      child: Stack(
        children: [
          AnimatedAlign(
            alignment: isLogin ? Alignment.centerLeft : Alignment.centerRight,
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeInOut,
            child: Container(
              width: 125,
              height: 50,
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [AppTheme.accentOrange, Color(0xFFFF8A50)],
                  begin: Alignment.centerLeft,
                  end: Alignment.centerRight,
                ),
                borderRadius: BorderRadius.circular(25),
                boxShadow: [
                  BoxShadow(
                    color: AppTheme.accentOrange.withOpacity(0.4),
                    blurRadius: 12,
                    spreadRadius: 1,
                  )
                ],
              ),
            ),
          ),
          Row(
            children: [
              Expanded(
                child: GestureDetector(
                  onTap: onLoginTapped,
                  child: Center(
                    child: Text(
                      'Login',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 15,
                        color: isLogin 
                            ? Colors.white 
                            : (isDark ? Colors.white60 : AppTheme.darkGrey.withOpacity(0.6)),
                      ),
                    ),
                  ),
                ),
              ),
              Expanded(
                child: GestureDetector(
                  onTap: onSignUpTapped,
                  child: Center(
                    child: Text(
                      'Sign Up',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 15,
                        color: !isLogin 
                            ? Colors.white 
                            : (isDark ? Colors.white60 : AppTheme.darkGrey.withOpacity(0.6)),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
