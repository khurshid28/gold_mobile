import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import '../constants/app_colors.dart';
import '../constants/app_sizes.dart';

class AppTheme {
  AppTheme._();

  // Light Theme
  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      primaryColor: AppColors.primary,
      scaffoldBackgroundColor: AppColors.backgroundLight,
      
      // Color Scheme
      colorScheme: const ColorScheme.light(
        primary: AppColors.primary,
        secondary: AppColors.secondary,
        surface: AppColors.surfaceLight,
        error: AppColors.error,
        onPrimary: AppColors.textOnPrimary,
        onSecondary: AppColors.textOnPrimary,
        onSurface: AppColors.textDark,
        onError: Colors.white,
        brightness: Brightness.light,
      ),

      // AppBar Theme
      appBarTheme: AppBarTheme(
        elevation: 0,
        centerTitle: true,
        backgroundColor: AppColors.surfaceLight,
        foregroundColor: AppColors.textDark,
        surfaceTintColor: Colors.transparent,
        systemOverlayStyle: SystemUiOverlayStyle.dark,
        iconTheme: const IconThemeData(color: AppColors.textDark),
        titleTextStyle: GoogleFonts.playfairDisplay(
          fontSize: AppSizes.fontXXL,
          fontWeight: FontWeight.bold,
          color: AppColors.textDark,
        ),
      ),

      // Text Theme
      textTheme: TextTheme(
        displayLarge: GoogleFonts.playfairDisplay(
          fontSize: AppSizes.font6XL,
          fontWeight: FontWeight.bold,
          color: AppColors.textDark,
          height: 1.2,
        ),
        displayMedium: GoogleFonts.playfairDisplay(
          fontSize: AppSizes.font5XL,
          fontWeight: FontWeight.bold,
          color: AppColors.textDark,
          height: 1.2,
        ),
        displaySmall: GoogleFonts.playfairDisplay(
          fontSize: AppSizes.font4XL,
          fontWeight: FontWeight.bold,
          color: AppColors.textDark,
          height: 1.2,
        ),
        headlineLarge: GoogleFonts.poppins(
          fontSize: AppSizes.font3XL,
          fontWeight: FontWeight.w600,
          color: AppColors.textDark,
          height: 1.3,
        ),
        headlineMedium: GoogleFonts.poppins(
          fontSize: AppSizes.fontXXL,
          fontWeight: FontWeight.w600,
          color: AppColors.textDark,
          height: 1.3,
        ),
        headlineSmall: GoogleFonts.poppins(
          fontSize: AppSizes.fontXL,
          fontWeight: FontWeight.w600,
          color: AppColors.textDark,
          height: 1.3,
        ),
        titleLarge: GoogleFonts.poppins(
          fontSize: AppSizes.fontLG,
          fontWeight: FontWeight.w600,
          color: AppColors.textDark,
          height: 1.4,
        ),
        titleMedium: GoogleFonts.poppins(
          fontSize: AppSizes.fontMD,
          fontWeight: FontWeight.w500,
          color: AppColors.textDark,
          height: 1.4,
        ),
        titleSmall: GoogleFonts.poppins(
          fontSize: AppSizes.fontSM,
          fontWeight: FontWeight.w500,
          color: AppColors.textMedium,
          height: 1.4,
        ),
        bodyLarge: GoogleFonts.poppins(
          fontSize: AppSizes.fontLG,
          fontWeight: FontWeight.normal,
          color: AppColors.textDark,
          height: 1.5,
        ),
        bodyMedium: GoogleFonts.poppins(
          fontSize: AppSizes.fontMD,
          fontWeight: FontWeight.normal,
          color: AppColors.textMedium,
          height: 1.5,
        ),
        bodySmall: GoogleFonts.poppins(
          fontSize: AppSizes.fontSM,
          fontWeight: FontWeight.normal,
          color: AppColors.textLight,
          height: 1.5,
        ),
        labelLarge: GoogleFonts.poppins(
          fontSize: AppSizes.fontMD,
          fontWeight: FontWeight.w600,
          color: AppColors.textDark,
          letterSpacing: 0.5,
        ),
        labelMedium: GoogleFonts.poppins(
          fontSize: AppSizes.fontSM,
          fontWeight: FontWeight.w500,
          color: AppColors.textMedium,
          letterSpacing: 0.5,
        ),
        labelSmall: GoogleFonts.poppins(
          fontSize: AppSizes.fontXS,
          fontWeight: FontWeight.w500,
          color: AppColors.textLight,
          letterSpacing: 0.5,
        ),
      ),

      // Card Theme
      cardTheme: CardThemeData(
        elevation: AppSizes.elevationSM,
        color: AppColors.surfaceLight,
        surfaceTintColor: Colors.transparent,
        shadowColor: AppColors.shadow,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppSizes.radiusMD),
        ),
      ),

      // Elevated Button Theme
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          elevation: 0,
          backgroundColor: AppColors.primary,
          foregroundColor: AppColors.textOnPrimary,
          shadowColor: Colors.transparent,
          padding: EdgeInsets.symmetric(
            horizontal: AppSizes.paddingLG,
            vertical: AppSizes.paddingMD,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppSizes.radiusMD),
          ),
          textStyle: GoogleFonts.poppins(
            fontSize: AppSizes.fontMD,
            fontWeight: FontWeight.w600,
            letterSpacing: 0.5,
          ),
        ).copyWith(
          overlayColor: MaterialStateProperty.all(Colors.white.withOpacity(0.1)),
        ),
      ),

      // Outlined Button Theme
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColors.primary,
          side: const BorderSide(color: AppColors.primary, width: 2),
          padding: EdgeInsets.symmetric(
            horizontal: AppSizes.paddingLG,
            vertical: AppSizes.paddingMD,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppSizes.radiusMD),
          ),
          textStyle: GoogleFonts.poppins(
            fontSize: AppSizes.fontMD,
            fontWeight: FontWeight.w600,
            letterSpacing: 0.5,
          ),
        ),
      ),

      // Text Button Theme
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: AppColors.primary,
          padding: EdgeInsets.symmetric(
            horizontal: AppSizes.paddingMD,
            vertical: AppSizes.paddingSM,
          ),
          textStyle: GoogleFonts.poppins(
            fontSize: AppSizes.fontMD,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),

      // Input Decoration Theme
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.surfaceLight,
        contentPadding: EdgeInsets.all(AppSizes.paddingMD),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppSizes.radiusMD),
          borderSide: const BorderSide(color: AppColors.borderLight),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppSizes.radiusMD),
          borderSide: const BorderSide(color: AppColors.borderLight),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppSizes.radiusMD),
          borderSide: const BorderSide(color: AppColors.primary, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppSizes.radiusMD),
          borderSide: const BorderSide(color: AppColors.error),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppSizes.radiusMD),
          borderSide: const BorderSide(color: AppColors.error, width: 2),
        ),
        labelStyle: GoogleFonts.poppins(
          fontSize: AppSizes.fontMD,
          color: AppColors.textMedium,
        ),
        hintStyle: GoogleFonts.poppins(
          fontSize: AppSizes.fontMD,
          color: AppColors.textLight,
        ),
      ),

      // Bottom Navigation Bar Theme
      bottomNavigationBarTheme: BottomNavigationBarThemeData(
        backgroundColor: AppColors.surfaceLight,
        selectedItemColor: AppColors.primary,
        unselectedItemColor: AppColors.textLight,
        selectedLabelStyle: GoogleFonts.poppins(
          fontSize: AppSizes.fontXS,
          fontWeight: FontWeight.w600,
        ),
        unselectedLabelStyle: GoogleFonts.poppins(
          fontSize: AppSizes.fontXS,
          fontWeight: FontWeight.normal,
        ),
        type: BottomNavigationBarType.fixed,
        elevation: 8,
      ),

      // Divider Theme
      dividerTheme: const DividerThemeData(
        color: AppColors.dividerLight,
        thickness: 1,
        space: 1,
      ),

      // Icon Theme
      iconTheme:  IconThemeData(
        color: AppColors.textDark,
        size: AppSizes.iconMD,
      ),

      // Floating Action Button Theme
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: AppColors.primary,
        foregroundColor: AppColors.textOnPrimary,
        elevation: AppSizes.elevationMD,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppSizes.radiusLG),
        ),
      ),

      // Chip Theme
      chipTheme: ChipThemeData(
        backgroundColor: AppColors.cardBackgroundLight,
        selectedColor: AppColors.primary,
        secondarySelectedColor: AppColors.primaryLight,
        padding: EdgeInsets.symmetric(
          horizontal: AppSizes.paddingSM,
          vertical: AppSizes.paddingXS,
        ),
        labelStyle: GoogleFonts.poppins(
          fontSize: AppSizes.fontSM,
          fontWeight: FontWeight.w500,
        ),
        secondaryLabelStyle: GoogleFonts.poppins(
          fontSize: AppSizes.fontSM,
          fontWeight: FontWeight.w500,
          color: AppColors.textOnPrimary,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppSizes.radiusSM),
        ),
      ),

      // Page Transitions Theme
      pageTransitionsTheme: const PageTransitionsTheme(
        builders: {
          TargetPlatform.android: CupertinoPageTransitionsBuilder(),
          TargetPlatform.iOS: CupertinoPageTransitionsBuilder(),
        },
      ),
    );
  }

  // Dark Theme
  static ThemeData get darkTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      primaryColor: AppColors.primary,
      scaffoldBackgroundColor: AppColors.backgroundDark,
      
      // Color Scheme
      colorScheme: const ColorScheme.dark(
        primary: AppColors.primary,
        secondary: AppColors.secondary,
        surface: AppColors.surfaceDark,
        error: AppColors.error,
        onPrimary: AppColors.textDark,
        onSecondary: AppColors.textOnPrimary,
        onSurface: AppColors.textDarkOnDark,
        onError: Colors.white,
        brightness: Brightness.dark,
      ),

      // AppBar Theme
      appBarTheme: AppBarTheme(
        elevation: 0,
        centerTitle: true,
        backgroundColor: AppColors.surfaceDark,
        foregroundColor: AppColors.textDarkOnDark,
        surfaceTintColor: Colors.transparent,
        systemOverlayStyle: SystemUiOverlayStyle.light,
        iconTheme: const IconThemeData(color: AppColors.textDarkOnDark),
        titleTextStyle: GoogleFonts.playfairDisplay(
          fontSize: AppSizes.fontXXL,
          fontWeight: FontWeight.bold,
          color: AppColors.textDarkOnDark,
        ),
      ),

      // Text Theme
      textTheme: TextTheme(
        displayLarge: GoogleFonts.playfairDisplay(
          fontSize: AppSizes.font6XL,
          fontWeight: FontWeight.bold,
          color: AppColors.textDarkOnDark,
          height: 1.2,
        ),
        displayMedium: GoogleFonts.playfairDisplay(
          fontSize: AppSizes.font5XL,
          fontWeight: FontWeight.bold,
          color: AppColors.textDarkOnDark,
          height: 1.2,
        ),
        displaySmall: GoogleFonts.playfairDisplay(
          fontSize: AppSizes.font4XL,
          fontWeight: FontWeight.bold,
          color: AppColors.textDarkOnDark,
          height: 1.2,
        ),
        headlineLarge: GoogleFonts.poppins(
          fontSize: AppSizes.font3XL,
          fontWeight: FontWeight.w600,
          color: AppColors.textDarkOnDark,
          height: 1.3,
        ),
        headlineMedium: GoogleFonts.poppins(
          fontSize: AppSizes.fontXXL,
          fontWeight: FontWeight.w600,
          color: AppColors.textDarkOnDark,
          height: 1.3,
        ),
        headlineSmall: GoogleFonts.poppins(
          fontSize: AppSizes.fontXL,
          fontWeight: FontWeight.w600,
          color: AppColors.textDarkOnDark,
          height: 1.3,
        ),
        titleLarge: GoogleFonts.poppins(
          fontSize: AppSizes.fontLG,
          fontWeight: FontWeight.w600,
          color: AppColors.textDarkOnDark,
          height: 1.4,
        ),
        titleMedium: GoogleFonts.poppins(
          fontSize: AppSizes.fontMD,
          fontWeight: FontWeight.w500,
          color: AppColors.textDarkOnDark,
          height: 1.4,
        ),
        titleSmall: GoogleFonts.poppins(
          fontSize: AppSizes.fontSM,
          fontWeight: FontWeight.w500,
          color: AppColors.textMediumOnDark,
          height: 1.4,
        ),
        bodyLarge: GoogleFonts.poppins(
          fontSize: AppSizes.fontLG,
          fontWeight: FontWeight.normal,
          color: AppColors.textDarkOnDark,
          height: 1.5,
        ),
        bodyMedium: GoogleFonts.poppins(
          fontSize: AppSizes.fontMD,
          fontWeight: FontWeight.normal,
          color: AppColors.textMediumOnDark,
          height: 1.5,
        ),
        bodySmall: GoogleFonts.poppins(
          fontSize: AppSizes.fontSM,
          fontWeight: FontWeight.normal,
          color: AppColors.textLightOnDark,
          height: 1.5,
        ),
        labelLarge: GoogleFonts.poppins(
          fontSize: AppSizes.fontMD,
          fontWeight: FontWeight.w600,
          color: AppColors.textDarkOnDark,
          letterSpacing: 0.5,
        ),
        labelMedium: GoogleFonts.poppins(
          fontSize: AppSizes.fontSM,
          fontWeight: FontWeight.w500,
          color: AppColors.textMediumOnDark,
          letterSpacing: 0.5,
        ),
        labelSmall: GoogleFonts.poppins(
          fontSize: AppSizes.fontXS,
          fontWeight: FontWeight.w500,
          color: AppColors.textLightOnDark,
          letterSpacing: 0.5,
        ),
      ),

      // Card Theme
      cardTheme: CardThemeData(
        elevation: AppSizes.elevationSM,
        color: AppColors.surfaceDark,
        surfaceTintColor: Colors.transparent,
        shadowColor: AppColors.shadowDark,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppSizes.radiusMD),
        ),
      ),

      // Elevated Button Theme
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          elevation: 0,
          backgroundColor: AppColors.primary,
          foregroundColor: AppColors.textDark,
          shadowColor: Colors.transparent,
          padding: EdgeInsets.symmetric(
            horizontal: AppSizes.paddingLG,
            vertical: AppSizes.paddingMD,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppSizes.radiusMD),
          ),
          textStyle: GoogleFonts.poppins(
            fontSize: AppSizes.fontMD,
            fontWeight: FontWeight.w600,
            letterSpacing: 0.5,
          ),
        ).copyWith(
          overlayColor: MaterialStateProperty.all(Colors.black.withOpacity(0.1)),
        ),
      ),

      // Outlined Button Theme
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColors.primary,
          side: const BorderSide(color: AppColors.primary, width: 2),
          padding: EdgeInsets.symmetric(
            horizontal: AppSizes.paddingLG,
            vertical: AppSizes.paddingMD,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppSizes.radiusMD),
          ),
          textStyle: GoogleFonts.poppins(
            fontSize: AppSizes.fontMD,
            fontWeight: FontWeight.w600,
            letterSpacing: 0.5,
          ),
        ),
      ),

      // Text Button Theme
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: AppColors.primary,
          padding: EdgeInsets.symmetric(
            horizontal: AppSizes.paddingMD,
            vertical: AppSizes.paddingSM,
          ),
          textStyle: GoogleFonts.poppins(
            fontSize: AppSizes.fontMD,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),

      // Input Decoration Theme
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.cardBackgroundDark,
        contentPadding: EdgeInsets.all(AppSizes.paddingMD),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppSizes.radiusMD),
          borderSide: const BorderSide(color: AppColors.borderDark),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppSizes.radiusMD),
          borderSide: const BorderSide(color: AppColors.borderDark),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppSizes.radiusMD),
          borderSide: const BorderSide(color: AppColors.primary, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppSizes.radiusMD),
          borderSide: const BorderSide(color: AppColors.error),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppSizes.radiusMD),
          borderSide: const BorderSide(color: AppColors.error, width: 2),
        ),
        labelStyle: GoogleFonts.poppins(
          fontSize: AppSizes.fontMD,
          color: AppColors.textMediumOnDark,
        ),
        hintStyle: GoogleFonts.poppins(
          fontSize: AppSizes.fontMD,
          color: AppColors.textLightOnDark,
        ),
      ),

      // Bottom Navigation Bar Theme
      bottomNavigationBarTheme: BottomNavigationBarThemeData(
        backgroundColor: AppColors.surfaceDark,
        selectedItemColor: AppColors.primary,
        unselectedItemColor: AppColors.textLightOnDark,
        selectedLabelStyle: GoogleFonts.poppins(
          fontSize: AppSizes.fontXS,
          fontWeight: FontWeight.w600,
        ),
        unselectedLabelStyle: GoogleFonts.poppins(
          fontSize: AppSizes.fontXS,
          fontWeight: FontWeight.normal,
        ),
        type: BottomNavigationBarType.fixed,
        elevation: 8,
      ),

      // Divider Theme
      dividerTheme: const DividerThemeData(
        color: AppColors.dividerDark,
        thickness: 1,
        space: 1,
      ),

      // Icon Theme
      iconTheme:  IconThemeData(
        color: AppColors.textDarkOnDark,
        size: AppSizes.iconMD,
      ),

      // Floating Action Button Theme
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: AppColors.primary,
        foregroundColor: AppColors.textDark,
        elevation: AppSizes.elevationMD,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppSizes.radiusLG),
        ),
      ),

      // Chip Theme
      chipTheme: ChipThemeData(
        backgroundColor: AppColors.cardBackgroundDark,
        selectedColor: AppColors.primary,
        secondarySelectedColor: AppColors.primaryLight,
        padding: EdgeInsets.symmetric(
          horizontal: AppSizes.paddingSM,
          vertical: AppSizes.paddingXS,
        ),
        labelStyle: GoogleFonts.poppins(
          fontSize: AppSizes.fontSM,
          fontWeight: FontWeight.w500,
        ),
        secondaryLabelStyle: GoogleFonts.poppins(
          fontSize: AppSizes.fontSM,
          fontWeight: FontWeight.w500,
          color: AppColors.textDark,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppSizes.radiusSM),
        ),
      ),

      // Page Transitions Theme
      pageTransitionsTheme: const PageTransitionsTheme(
        builders: {
          TargetPlatform.android: CupertinoPageTransitionsBuilder(),
          TargetPlatform.iOS: CupertinoPageTransitionsBuilder(),
        },
      ),
    );
  }
}
