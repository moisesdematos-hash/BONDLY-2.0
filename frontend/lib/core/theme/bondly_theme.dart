import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class BondlyTheme {
  // Colors - Premium Palette
  static const Color primary = Color(0xFF818CF8); // Indigo soft
  static const Color secondary = Color(0xFF2DD4BF); // Teal
  static const Color background = Color(0xFF020617); // Slate 950 (deeper)
  static const Color surface = Color(0xFF1E293B); // Slate 800
  static const Color accent = Color(0xFFF472B6); // Pink
  static const Color error = Color(0xFFFB7185); // Rose
  
  // Gradients
  static const LinearGradient mainGradient = LinearGradient(
    colors: [Color(0xFF020617), Color(0xFF0F172A)],
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
  );

  static const LinearGradient glassGradient = LinearGradient(
    colors: [Colors.white10, Colors.white05],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  // Theme Data
  static ThemeData get darkTheme {
    return ThemeData.dark().copyWith(
      scaffoldBackgroundColor: background,
      primaryColor: primary,
      colorScheme: const ColorScheme.dark(
        primary: primary,
        secondary: secondary,
        surface: surface,
        error: error,
      ),
      textTheme: GoogleFonts.outfitTextTheme(ThemeData.dark().textTheme).copyWith(
        displayLarge: const TextStyle(fontSize: 32, fontWeight: FontWeight.bold, letterSpacing: -1),
        headlineMedium: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, letterSpacing: -0.5),
        bodyLarge: const TextStyle(fontSize: 16, color: Colors.white70, height: 1.5),
        bodyMedium: const TextStyle(fontSize: 14, color: Colors.white60),
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        titleTextStyle: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
      ),
      cardTheme: CardTheme(
        color: Colors.white.withOpacity(0.04),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(28),
          side: BorderSide(color: Colors.white.withOpacity(0.08)),
        ),
        elevation: 0,
      ),
    );
  }

  // Deluxe Glassmorphism
  static BoxDecoration glassDecoration({
    double opacity = 0.05, 
    double blur = 12,
    double borderRadius = 28,
    bool showBorder = true,
  }) {
    return BoxDecoration(
      color: Colors.white.withOpacity(opacity),
      borderRadius: BorderRadius.circular(borderRadius),
      border: showBorder ? Border.all(color: Colors.white.withOpacity(0.12), width: 1) : null,
      boxShadow: [
        BoxShadow(
          color: Colors.black.withOpacity(0.2),
          blurRadius: 20,
          offset: const Offset(0, 10),
        )
      ],
    );
  }

  // Animation Constants
  static const Duration quickAction = Duration(milliseconds: 200);
  static const Duration pageTransition = Duration(milliseconds: 400);
}
