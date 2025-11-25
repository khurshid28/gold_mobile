import 'package:flutter/material.dart';

class AppColors {
  AppColors._();

  // Primary Colors - Gold theme
  static const Color primary = Color(0xFFD4AF37); // Classic Gold
  static const Color gold = Color(0xFFD4AF37); // Alias for primary
  static const Color primaryDark = Color(0xFFB8941E);
  static const Color primaryLight = Color(0xFFE8D68A);
  static const Color lightGold = Color(0xFFFFE55C);
  
  // Secondary Colors
  static const Color secondary = Color(0xFF1A1A1A); // Dark Elegance
  static const Color secondaryLight = Color(0xFF2D2D2D);
  
  // Light Theme Colors
  static const Color backgroundLight = Color(0xFFFAFAFA);
  static const Color surfaceLight = Color(0xFFFFFFFF);
  static const Color cardBackgroundLight = Color(0xFFF5F5F5);
  
  // Dark Theme Colors  
  static const Color backgroundDark = Color(0xFF121212);
  static const Color surfaceDark = Color(0xFF1E1E1E);
  static const Color cardBackgroundDark = Color(0xFF2C2C2C);
  
  // Text Colors - Light Theme
  static const Color textDark = Color(0xFF1A1A1A);
  static const Color textMedium = Color(0xFF757575);
  static const Color textLight = Color(0xFF9E9E9E);
  static const Color textOnPrimary = Color(0xFFFFFFFF);
  
  // Text Colors - Dark Theme
  static const Color textDarkOnDark = Color(0xFFE0E0E0);
  static const Color textMediumOnDark = Color(0xFFB0B0B0);
  static const Color textLightOnDark = Color(0xFF808080);
  
  // Accent Colors
  static const Color accent = Color(0xFFFFD700); // Bright Gold
  static const Color success = Color(0xFF4CAF50);
  static const Color error = Color(0xFFE53935);
  static const Color warning = Color(0xFFFFA726);
  static const Color info = Color(0xFF29B6F6);
  
  // Neutral Colors
  static const Color grey = Color(0xFFBDBDBD);
  static const Color greyLight = Color(0xFFE0E0E0);
  static const Color greyDark = Color(0xFF616161);
  
  // Divider & Border
  static const Color dividerLight = Color(0xFFE0E0E0);
  static const Color borderLight = Color(0xFFE0E0E0);
  static const Color dividerDark = Color(0xFF3A3A3A);
  static const Color borderDark = Color(0xFF3A3A3A);
  
  // Shadow
  static const Color shadow = Color(0x1A000000);
  static const Color shadowDark = Color(0x40000000);
  
  // Shimmer Colors - Light
  static const Color shimmerBaseLight = Color(0xFFE0E0E0);
  static const Color shimmerHighlightLight = Color(0xFFF5F5F5);
  
  // Shimmer Colors - Dark
  static const Color shimmerBaseDark = Color(0xFF2C2C2C);
  static const Color shimmerHighlightDark = Color(0xFF3A3A3A);
  
  // Legacy aliases for compatibility
  static const Color background = backgroundLight;
  static const Color surface = surfaceLight;
  static const Color cardBackground = cardBackgroundLight;
  static const Color textPrimary = textDark;
  static const Color textSecondary = textMedium;
  static const Color divider = dividerLight;
  static const Color border = borderLight;
  static const Color shimmerBase = shimmerBaseLight;
  static const Color shimmerHighlight = shimmerHighlightLight;
}
