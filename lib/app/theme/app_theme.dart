import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  // --- Colors --- //
  static const Color primaryTeal = Color(0xFF1A535C);
  static const Color accentOrange = Color(0xFFFF6B35);
  static const Color infoBlue = Color(0xFF2196F3); // Added the blue color
  static const Color offWhite = Color(0xFFF7F7F7);
  static const Color darkGrey = Color(0xFF2B2B2B);

  // --- Text Styles --- //
  // We use the Poppins font for a modern and friendly look.
  static final TextTheme _textTheme = TextTheme(
    displayLarge: GoogleFonts.poppins(fontSize: 34, fontWeight: FontWeight.bold),
    displayMedium: GoogleFonts.poppins(fontSize: 28, fontWeight: FontWeight.bold),
    displaySmall: GoogleFonts.poppins(fontSize: 24, fontWeight: FontWeight.bold),
    headlineMedium: GoogleFonts.poppins(fontSize: 20, fontWeight: FontWeight.bold),
    bodyLarge: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.normal),
    bodyMedium: GoogleFonts.poppins(fontSize: 14, fontWeight: FontWeight.normal),
    labelLarge: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.bold, letterSpacing: 1.2),
  );

  // --- Light Theme --- //
  static ThemeData get lightTheme {
    return ThemeData(
      brightness: Brightness.light,
      primaryColor: primaryTeal,
      scaffoldBackgroundColor: offWhite,
      colorScheme: const ColorScheme.light(
        primary: primaryTeal,
        secondary: accentOrange,
        background: offWhite,
        surface: Colors.white,
        onPrimary: Colors.white,
        onSecondary: Colors.white,
        onBackground: darkGrey,
        onSurface: darkGrey,
      ),
      textTheme: _textTheme.apply(bodyColor: darkGrey, displayColor: darkGrey),
      appBarTheme: AppBarTheme(
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(color: primaryTeal),
        titleTextStyle: _textTheme.headlineMedium?.copyWith(color: primaryTeal),
      ),
      floatingActionButtonTheme: const FloatingActionButtonThemeData(
        backgroundColor: accentOrange,
        foregroundColor: Colors.white,
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: accentOrange,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          textStyle: _textTheme.labelLarge,
        ),
      ),
    );
  }

// --- Dark Theme --- //
// (We can implement this later if desired)
}