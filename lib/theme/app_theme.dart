import 'package:flutter/material.dart';

const ColorScheme lightColorScheme = ColorScheme(
  brightness: Brightness.light,
  primary: Color(0xFF006C4C),
  onPrimary: Color(0xFFFFFFFF),
  primaryContainer: Color(0xFF8CF8C7),
  onPrimaryContainer: Color(0xFF002114),
  secondary: Color(0xFF4C6357),
  onSecondary: Color(0xFFFFFFFF),
  secondaryContainer: Color(0xFFCEE9D9),
  onSecondaryContainer: Color(0xFF092016),
  tertiary: Color(0xFF3D6373),
  onTertiary: Color(0xFFFFFFFF),
  tertiaryContainer: Color(0xFFC1E8FB),
  onTertiaryContainer: Color(0xFF001F29),
  error: Color(0xFFBA1A1A),
  onError: Color(0xFFFFFFFF),
  errorContainer: Color(0xFFFFDAD6),
  onErrorContainer: Color(0xFF410002),
  background: Color(0xFFFBFDF9),
  onBackground: Color(0xFF191C1A),
  surface: Color(0xFFFBFDF9),
  onSurface: Color(0xFF191C1A),
  surfaceVariant: Color(0xFFDBE5DD),
  onSurfaceVariant: Color(0xFF404943),
  outline: Color(0xFF707973),
  shadow: Color(0xFF000000),
);

// Semantic colors for the app
class AppColors {
  // Expense Categories
  static const Color food = Color(0xFFFF9800);
  static const Color clothing = Color(0xFFE91E63);
  static const Color housing = Color(0xFF795548);
  static const Color transport = Color(0xFF2196F3);
  static const Color education = Color(0xFF9C27B0);
  static const Color entertainment = Color(0xFF00BCD4);
  
  static const Color success = Color(0xFF4CAF50);
  static const Color warning = Color(0xFFFFC107);
  static const Color danger = Color(0xFFF44336);
  
  // Dashboard Gradients
  static const LinearGradient remainingBudgetGradient = LinearGradient(
    colors: [Color(0xFF006C4C), Color(0xFF004D36)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
}
