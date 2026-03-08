import 'package:flutter/material.dart';

/// App-wide color constants derived from the TechHive logo gradient.
class AppColors {
  AppColors._();

  // Primary gradient (logo cyan/teal)
  static const Color primary = Color(0xFF00BCD4);       // Cyan
  static const Color primaryDark = Color(0xFF0097A7);    // Darker teal
  static const Color primaryLight = Color(0xFF4DD0E1);   // Lighter cyan
  static const Color accent = Color(0xFF26C6DA);         // Accent cyan

  // Gradient used throughout the app
  static const List<Color> gradient = [Color(0xFF0097A7), Color(0xFF00BCD4)];
  static const List<Color> gradientLight = [Color(0xFF00BCD4), Color(0xFF4DD0E1)];
  static const List<Color> gradientWide = [Color(0xFF00838F), Color(0xFF00BCD4), Color(0xFF4DD0E1)];

  // Neutrals
  static const Color dark = Color(0xFF1A1A2E);
  static const Color textPrimary = Color(0xFF1A1A2E);
  static const Color textSecondary = Color(0xFF6B7280);
  static const Color surface = Color(0xFFF7FAFA);
  static const Color card = Colors.white;
  static const Color border = Color(0xFFE0E0E0);

  // Convenience
  static LinearGradient get primaryGradient => const LinearGradient(
    colors: gradient,
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static LinearGradient get wideGradient => const LinearGradient(
    colors: gradientWide,
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
}
