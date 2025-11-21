import 'package:flutter/material.dart';
import 'package:smart_expense_tracker/app/theme/app_theme.dart';

class ThemedBackground extends StatelessWidget {
  final Widget child;
  final bool useGradient;

  const ThemedBackground({
    Key? key,
    required this.child,
    this.useGradient = true,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    if (!useGradient) {
      return Container(
        color: isDark ? AppTheme.darkBackground : AppTheme.offWhite,
        child: child,
      );
    }

    return Container(
      decoration: BoxDecoration(
        gradient: isDark
            ? LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  AppTheme.darkBackgroundGradientStart,
                  AppTheme.darkBackgroundGradientEnd,
                  AppTheme.darkBackground,
                ],
                stops: const [0.0, 0.5, 1.0],
              )
            : LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  AppTheme.offWhite,
                  Colors.white.withOpacity(0.95),
                  AppTheme.offWhite,
                ],
              ),
      ),
      child: child,
    );
  }
}
