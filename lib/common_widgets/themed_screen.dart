import 'package:flutter/material.dart';
import 'package:smart_expense_tracker/app/theme/app_theme.dart';

/// A wrapper widget that automatically handles dark mode for any screen
/// Provides isDark flag and consistent background color
class ThemedScreen extends StatelessWidget {
  final Widget Function(BuildContext context, bool isDark) builder;
  final PreferredSizeWidget? appBar;
  final Widget? floatingActionButton;
  final FloatingActionButtonLocation? floatingActionButtonLocation;
  final Widget? bottomNavigationBar;
  final Widget? drawer;
  
  const ThemedScreen({
    Key? key,
    required this.builder,
    this.appBar,
    this.floatingActionButton,
    this.floatingActionButtonLocation,
    this.bottomNavigationBar,
    this.drawer,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: appBar,
      floatingActionButton: floatingActionButton,
      floatingActionButtonLocation: floatingActionButtonLocation,
      bottomNavigationBar: bottomNavigationBar,
      drawer: drawer,
      body: Container(
        decoration: BoxDecoration(
          gradient: isDark
            ? LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  AppTheme.darkBackgroundGradientStart,
                  AppTheme.darkBackgroundGradientEnd,
                ],
              )
            : null,
          color: !isDark ? AppTheme.offWhite : null,
        ),
        child: builder(context, isDark),
      ),
    );
  }
}

/// Text helpers that automatically adapt to dark mode
class ThemedText {
  /// Section header text (e.g., "BUDGET TYPE", "CATEGORY")
  static TextStyle sectionHeader(bool isDark) {
    return TextStyle(
      fontSize: 12,
      fontWeight: FontWeight.w700,
      color: isDark ? Colors.white60 : Colors.grey[600],
      letterSpacing: 1.5,
    );
  }
  
  /// Primary text (titles, labels)
  static TextStyle primary(bool isDark, {double fontSize = 16, FontWeight? fontWeight}) {
    return TextStyle(
      fontSize: fontSize,
      fontWeight: fontWeight ?? FontWeight.w600,
      color: isDark ? Colors.white : AppTheme.darkGrey,
    );
  }
  
  /// Secondary text (subtitles, descriptions)
  static TextStyle secondary(bool isDark, {double fontSize = 14}) {
    return TextStyle(
      fontSize: fontSize,
      color: isDark ? Colors.white70 : Colors.grey[600],
    );
  }
  
  /// Hint text for inputs
  static TextStyle hint(bool isDark, {double fontSize = 16}) {
    return TextStyle(
      fontSize: fontSize,
      color: isDark ? Colors.white24 : Colors.grey[400],
    );
  }
  
  /// Tertiary/disabled text
  static TextStyle tertiary(bool isDark, {double fontSize = 12}) {
    return TextStyle(
      fontSize: fontSize,
      color: isDark ? Colors.white38 : Colors.grey[500],
    );
  }
}

/// Color helpers for dark mode
class ThemedColors {
  /// Card background color
  static Color card(bool isDark) {
    return isDark ? AppTheme.darkCard : Colors.white;
  }
  
  /// Surface/container color
  static Color surface(bool isDark) {
    return isDark ? AppTheme.darkSurface : Colors.grey[100]!;
  }
  
  /// Border color
  static Color border(bool isDark) {
    return isDark ? Colors.white24 : Colors.grey[300]!;
  }
  
  /// Divider color
  static Color divider(bool isDark) {
    return isDark ? Colors.white12 : Colors.grey[200]!;
  }
  
  /// Icon color
  static Color icon(bool isDark) {
    return isDark ? Colors.white60 : Colors.grey[600]!;
  }
}
