import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  // --- Light Theme Colors --- //
  static const Color primaryTeal = Color(0xFF1A535C);
  static const Color accentOrange = Color(0xFFFF6B35);
  static const Color infoBlue = Color(0xFF2196F3);
  static const Color offWhite = Color(0xFFF7F7F7);
  static const Color darkGrey = Color(0xFF2B2B2B);
  static const Color successGreen = Color(0xFF4CAF50);
  static const Color brightSuccessGreen = Color(0xFF81C784); // Bright green for "on track"
  static const Color warningAmber = Color(0xFFFFA000);
  static const Color errorRed = Color(0xFFD32F2F);

  // --- Dark Theme Colors --- //
  // Rich, tinted backgrounds instead of plain black
  static const Color darkBackground = Color(0xFF0f1419);
  static const Color darkBackgroundGradientStart = Color(0xFF1a1a2e);
  static const Color darkBackgroundGradientEnd = Color(0xFF16213e);
  static const Color darkCard = Color(0xFF2d3047);
  static const Color darkSurface = Color(0xFF1f2137);
  
  // Dark theme accent colors - slightly adjusted for better contrast
  static const Color darkPrimaryTeal = Color(0xFF4ECDC4);
  static const Color darkAccentOrange = Color(0xFFFF6B35);
  static const Color darkInfoBlue = Color(0xFF64B5F6);
  static const Color darkSuccessGreen = Color(0xFF81C784);
  static const Color darkWarningAmber = Color(0xFFFFB74D);
  static const Color darkErrorRed = Color(0xFFCF6679);
  
  // Text colors for dark mode
  static const Color darkTextPrimary = Color(0xFFE8E8E8);
  static const Color darkTextSecondary = Color(0xFFB0B0B0);
  static const Color darkTextDisabled = Color(0xFF6D6D6D);

  // --- Text Styles --- //
  static final TextTheme _textTheme = TextTheme(
    displayLarge: GoogleFonts.poppins(fontSize: 34, fontWeight: FontWeight.bold),
    displayMedium: GoogleFonts.poppins(fontSize: 28, fontWeight: FontWeight.bold),
    displaySmall: GoogleFonts.poppins(fontSize: 24, fontWeight: FontWeight.bold),
    headlineMedium: GoogleFonts.poppins(fontSize: 20, fontWeight: FontWeight.bold),
    headlineSmall: GoogleFonts.poppins(fontSize: 18, fontWeight: FontWeight.w600),
    titleLarge: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.w600),
    titleMedium: GoogleFonts.poppins(fontSize: 14, fontWeight: FontWeight.w500),
    titleSmall: GoogleFonts.poppins(fontSize: 12, fontWeight: FontWeight.w500),
    bodyLarge: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.normal),
    bodyMedium: GoogleFonts.poppins(fontSize: 14, fontWeight: FontWeight.normal),
    bodySmall: GoogleFonts.poppins(fontSize: 12, fontWeight: FontWeight.normal),
    labelLarge: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.bold, letterSpacing: 1.2),
    labelMedium: GoogleFonts.poppins(fontSize: 14, fontWeight: FontWeight.w500),
    labelSmall: GoogleFonts.poppins(fontSize: 12, fontWeight: FontWeight.w500, letterSpacing: 0.5),
  );

  // --- Light Theme --- //
  static ThemeData get lightTheme {
    return ThemeData(
      brightness: Brightness.light,
      useMaterial3: true,
      primaryColor: primaryTeal,
      scaffoldBackgroundColor: offWhite,
      colorScheme: const ColorScheme.light(
        primary: primaryTeal,
        secondary: accentOrange,
        surface: offWhite,
        onPrimary: Colors.white,
        onSecondary: Colors.white,
        onSurface: darkGrey,
        error: errorRed,
        onError: Colors.white,
      ),
      textTheme: _textTheme.apply(
        bodyColor: darkGrey,
        displayColor: darkGrey,
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(color: primaryTeal),
        titleTextStyle: _textTheme.headlineMedium?.copyWith(color: primaryTeal),
        toolbarTextStyle: _textTheme.bodyMedium?.copyWith(color: darkGrey),
      ),
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: Colors.white,
        selectedItemColor: primaryTeal,
        unselectedItemColor: Color(0xFF666666),
        elevation: 4,
      ),
      floatingActionButtonTheme: const FloatingActionButtonThemeData(
        backgroundColor: accentOrange,
        foregroundColor: Colors.white,
        elevation: 6,
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primaryTeal,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
          elevation: 2,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          textStyle: _textTheme.labelLarge?.copyWith(color: Colors.white),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: primaryTeal,
          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: primaryTeal,
          side: const BorderSide(color: primaryTeal),
          padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          textStyle: _textTheme.labelLarge?.copyWith(color: primaryTeal),
        ),
      ),
      cardTheme: CardThemeData(
        color: Colors.white,
        elevation: 2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey.shade300),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey.shade300),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: primaryTeal, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: errorRed),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: errorRed, width: 2),
        ),
        labelStyle: _textTheme.bodyMedium?.copyWith(color: Color(0xFF666666)),
        hintStyle: _textTheme.bodyMedium?.copyWith(color: Color(0xFF9E9E9E)),
      ),
      dialogTheme: DialogThemeData(
        backgroundColor: Colors.white,
        elevation: 8,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        titleTextStyle: _textTheme.headlineMedium?.copyWith(color: darkGrey),
        contentTextStyle: _textTheme.bodyMedium?.copyWith(color: Color(0xFF666666)),
      ),
      dividerTheme: DividerThemeData(
        color: Colors.grey.shade300,
        thickness: 1,
        space: 1,
      ),
    );
  }

  // --- Dark Theme --- //
  static ThemeData get darkTheme {
    return ThemeData(
      brightness: Brightness.dark,
      useMaterial3: true,
      primaryColor: darkPrimaryTeal,
      scaffoldBackgroundColor: darkBackground,
      colorScheme: const ColorScheme.dark(
        primary: darkPrimaryTeal,
        secondary: darkAccentOrange,
        surface: darkSurface,
        onPrimary: darkBackground,
        onSecondary: darkBackground,
        onSurface: darkTextPrimary,
        error: darkErrorRed,
        onError: Colors.white,
      ),
      textTheme: _textTheme.apply(
        bodyColor: darkTextPrimary,
        displayColor: darkTextPrimary,
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(color: darkPrimaryTeal),
        titleTextStyle: _textTheme.headlineMedium?.copyWith(color: darkTextPrimary),
        toolbarTextStyle: _textTheme.bodyMedium?.copyWith(color: darkTextPrimary),
      ),
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: darkSurface,
        selectedItemColor: darkPrimaryTeal,
        unselectedItemColor: darkTextSecondary,
        elevation: 4,
      ),
      floatingActionButtonTheme: const FloatingActionButtonThemeData(
        backgroundColor: darkAccentOrange,
        foregroundColor: Colors.white,
        elevation: 6,
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: darkPrimaryTeal,
          foregroundColor: darkBackground,
          padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
          elevation: 2,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          textStyle: _textTheme.labelLarge?.copyWith(color: darkBackground),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: darkPrimaryTeal,
          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: darkPrimaryTeal,
          side: const BorderSide(color: darkPrimaryTeal),
          padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          textStyle: _textTheme.labelLarge?.copyWith(color: darkPrimaryTeal),
        ),
      ),
      cardTheme: CardThemeData(
        color: darkCard,
        elevation: 4,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: darkSurface,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: darkCard),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: darkCard),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: darkPrimaryTeal, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: darkErrorRed),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: darkErrorRed, width: 2),
        ),
        labelStyle: _textTheme.bodyMedium?.copyWith(color: darkTextSecondary),
        hintStyle: _textTheme.bodyMedium?.copyWith(color: darkTextDisabled),
      ),
      dialogTheme: DialogThemeData(
        backgroundColor: darkSurface,
        elevation: 8,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        titleTextStyle: _textTheme.headlineMedium?.copyWith(color: darkTextPrimary),
        contentTextStyle: _textTheme.bodyMedium?.copyWith(color: darkTextSecondary),
      ),
      dividerTheme: const DividerThemeData(
        color: darkCard,
        thickness: 1,
        space: 1,
      ),
      iconTheme: const IconThemeData(color: darkTextSecondary),
    );
  }

  // --- Helper Methods --- //
  
  // Get appropriate color based on theme
  static Color getCardColor(BuildContext context) {
    return Theme.of(context).brightness == Brightness.dark
        ? darkCard
        : Colors.white;
  }

  static Color getSurfaceColor(BuildContext context) {
    return Theme.of(context).brightness == Brightness.dark
        ? darkSurface
        : offWhite;
  }

  static Color getPrimaryColor(BuildContext context) {
    return Theme.of(context).brightness == Brightness.dark
        ? darkPrimaryTeal
        : primaryTeal;
  }

  static Color getAccentColor(BuildContext context) {
    return Theme.of(context).brightness == Brightness.dark
        ? darkAccentOrange
        : accentOrange;
  }

  // ORIGINAL ORANGE FOR BUTTONS - Always orange regardless of theme
  static Color getOriginalAccentColor(BuildContext context) {
    return accentOrange; // Always use original orange
  }

  // HEADER COLORS - Always use original green/teal for headers
  static Color getHeaderPrimaryColor(BuildContext context) {
    return primaryTeal; // Always use original green for headers
  }

  static Color getHeaderSecondaryColor(BuildContext context) {
    return primaryTeal.withOpacity(0.9); // Always use original green for headers
  }

  static Color getTextColor(BuildContext context) {
    return Theme.of(context).brightness == Brightness.dark
        ? darkTextPrimary
        : darkGrey;
  }

  static Color getSecondaryTextColor(BuildContext context) {
    return Theme.of(context).brightness == Brightness.dark
        ? darkTextSecondary
        : Colors.grey[600]!;
  }

  // Get success green color (for "on track" status)
  static Color getSuccessColor(BuildContext context) {
    return Theme.of(context).brightness == Brightness.dark
        ? brightSuccessGreen  // Use bright green in dark mode
        : successGreen;  // Use normal green in light mode
  }

  // Get warning color
  static Color getWarningColor(BuildContext context) {
    return Theme.of(context).brightness == Brightness.dark
        ? darkWarningAmber
        : warningAmber;
  }

  // Get error color
  static Color getErrorColor(BuildContext context) {
    return Theme.of(context).brightness == Brightness.dark
        ? darkErrorRed
        : errorRed;
  }
  
  // Glassmorphism background for dark mode
  static BoxDecoration getDarkGlassmorphicBackground() {
    return BoxDecoration(
      gradient: LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [
          darkBackgroundGradientStart,
          darkBackgroundGradientEnd,
          darkBackground,
        ],
        stops: const [0.0, 0.5, 1.0],
      ),
    );
  }

  // Glassmorphic card style for dark mode
  static BoxDecoration getDarkGlassmorphicCard({
    double opacity = 0.1,
    double blur = 10,
  }) {
    return BoxDecoration(
      color: Colors.white.withOpacity(opacity),
      borderRadius: BorderRadius.circular(16),
      border: Border.all(
        color: Colors.white.withOpacity(0.2),
        width: 1.5,
      ),
      boxShadow: [
        BoxShadow(
          color: Colors.black.withOpacity(0.3),
          blurRadius: blur,
          offset: const Offset(0, 4),
        ),
      ],
    );
  }

  // Helper method to create orange gradient button decoration
  static BoxDecoration getGradientButtonDecoration({bool enabled = true}) {
    return BoxDecoration(
      gradient: LinearGradient(
        colors: enabled 
            ? [accentOrange, const Color(0xFFFF6B35)]
            : [Colors.grey.shade400, Colors.grey.shade500],
        begin: Alignment.centerLeft,
        end: Alignment.centerRight,
      ),
      borderRadius: BorderRadius.circular(16),
      boxShadow: enabled ? [
        BoxShadow(
          color: accentOrange.withOpacity(0.4),
          blurRadius: 16,
          offset: const Offset(0, 8),
        ),
      ] : [],
    );
  }

  // Helper method to create gradient button style
  static ButtonStyle getGradientButtonStyle() {
    return ElevatedButton.styleFrom(
      backgroundColor: Colors.transparent,
      shadowColor: Colors.transparent,
      foregroundColor: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
    );
  }

  // Helper method to get card background color
  static Color cardBackground(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return isDark ? darkCard : Colors.white;
  }

  // Helper method to get primary surface color
  static Color getPrimarySurface(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return isDark ? darkBackground : primaryTeal;
  }

  // Glassmorphic header decoration for dark mode
  static BoxDecoration getGlassmorphicHeaderDecoration(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    if (isDark) {
      return BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            primaryTeal.withOpacity(0.15),
            primaryTeal.withOpacity(0.08),
          ],
        ),
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(24),
          bottomRight: Radius.circular(24),
        ),
        border: Border.all(
          color: primaryTeal.withOpacity(0.2),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: primaryTeal.withOpacity(0.1),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      );
    } else {
      // Keep original solid gradient for light mode
      return BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            primaryTeal,
            primaryTeal.withOpacity(0.9),
          ],
        ),
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(24),
          bottomRight: Radius.circular(24),
        ),
        boxShadow: [
          BoxShadow(
            color: primaryTeal.withOpacity(0.3),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      );
    }
  }

  // Get header text color that works with glassmorphic design
  static Color getHeaderTextColor(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return isDark ? darkPrimaryTeal : Colors.white; // Use bright teal in dark mode
  }

  // Get header icon background color for glassmorphic design
  static Color getHeaderIconBackground(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return isDark 
      ? primaryTeal.withOpacity(0.15)
      : Colors.white.withOpacity(0.2);
  }

  // Get primary teal color that adapts to dark mode
  static Color getPrimaryTealColor(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return isDark ? darkPrimaryTeal : primaryTeal;
  }

  static Color getBackgroundColor(BuildContext context) {
    return Theme.of(context).brightness == Brightness.dark
        ? darkBackground
        : offWhite;
  }
}
