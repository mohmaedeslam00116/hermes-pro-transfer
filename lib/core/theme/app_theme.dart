import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// Hermes App Theme - Modern Productivity App Design
/// Based on UI/UX Pro Max guidelines for productivity apps
class AppTheme {
  // Productivity App Color Palette (Teal + Orange Accent)
  static const Color primaryColor = Color(0xFF0D9488);      // Teal-600
  static const Color secondaryColor = Color(0xFF14B8A6);  // Teal-500
  static const Color accentColor = Color(0xFFEA580C);       // Orange-600 (Action)
  static const Color errorColor = Color(0xFFDC2626);       // Red-600
  static const Color successColor = Color(0xFF16A34A);       // Green-600
  
  // Light Theme Colors
  static const Color lightBackground = Color(0xFFF0FDFA);     // Teal-50
  static const Color lightSurface = Color(0xFFFFFFFF);
  static const Color lightForeground = Color(0xFF134E4A);     // Teal-900
  static const Color lightMuted = Color(0xFFE8F1F4);
  static const Color lightBorder = Color(0xFF99F6E4);        // Teal-300
  
  // Dark Theme Colors
  static const Color darkBackground = Color(0xFF0F172A);    // Slate-900
  static const Color darkSurface = Color(0xFF1E293B);          // Slate-800
  static const Color darkForeground = Color(0xFFF0FDFA);         // Teal-50
  static const Color darkMuted = Color(0xFF334155);           // Slate-700
  static const Color darkBorder = Color(0xFF0D9488);         // Teal-600

  /// Typography - Plus Jakarta Sans (Modern SaaS Font)
  static const String headingFont = 'Plus Jakarta Sans';
  static const String bodyFont = 'Plus Jakarta Sans';

  // Border Radius
  static const double radiusSmall = 8.0;
  static const double radiusMedium = 12.0;
  static const double radiusLarge = 16.0;
  static const double radiusXL = 24.0;

  // Spacing
  static const double spacingXS = 4.0;
  static const double spacingSM = 8.0;
  static const double spacingMD = 16.0;
  static const double spacingLG = 24.0;
  static const double spacingXL = 32.0;
  static const double spacingXXL = 48.0;

  /// Light Theme
  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      colorScheme: ColorScheme.light(
        primary: primaryColor,
        secondary: secondaryColor,
        tertiary: accentColor,
        error: errorColor,
        surface: lightSurface,
        onSurface: lightForeground,
        surfaceContainerHighest: lightMuted,
        outline: lightBorder,
      ),
      scaffoldBackgroundColor: lightBackground,
      
      // AppBar
      appBarTheme: const AppBarTheme(
        backgroundColor: lightSurface,
        foregroundColor: lightForeground,
        elevation: 0,
        centerTitle: true,
        systemOverlayStyle: SystemUiOverlayStyle.dark,
        titleTextStyle: TextStyle(
          fontFamily: headingFont,
          fontSize: 20,
          fontWeight: FontWeight.w600,
          color: lightForeground,
        ),
      ),
      
      // Cards - Modern with subtle border
      cardTheme: CardThemeData(
        color: lightSurface,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(radiusLarge),
          side: BorderSide(color: lightBorder.withOpacity(0.5)),
        ),
        margin: const EdgeInsets.all(spacingSM),
      ),
      
      // Buttons
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primaryColor,
          foregroundColor: Colors.white,
          elevation: 0,
          padding: const EdgeInsets.symmetric(horizontal: spacingLG, vertical: spacingMD),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(radiusMedium),
          ),
          textStyle: const TextStyle(
            fontFamily: bodyFont,
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: primaryColor,
          side: const BorderSide(color: primaryColor, width: 1.5),
          padding: const EdgeInsets.symmetric(horizontal: spacingLG, vertical: spacingMD),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(radiusMedium),
          ),
          textStyle: const TextStyle(
            fontFamily: bodyFont,
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: primaryColor,
          textStyle: const TextStyle(
            fontFamily: bodyFont,
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      
      // Input Fields
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: lightSurface,
        contentPadding: const EdgeInsets.symmetric(horizontal: spacingMD, vertical: spacingMD),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(radiusMedium),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(radiusMedium),
          borderSide: BorderSide(color: lightBorder),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(radiusMedium),
          borderSide: const BorderSide(color: primaryColor, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(radiusMedium),
          borderSide: const BorderSide(color: errorColor),
        ),
        hintStyle: TextStyle(
          fontFamily: bodyFont,
          color: lightForeground.withOpacity(0.5),
        ),
      ),
      
      // Progress Indicators
      progressIndicatorTheme: const ProgressIndicatorThemeData(
        color: primaryColor,
        linearTrackColor: lightMuted,
      ),
      
      // Bottom Navigation
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: lightSurface,
        selectedItemColor: primaryColor,
        unselectedItemColor: lightMuted,
        type: BottomNavigationBarType.fixed,
        elevation: 8,
      ),
      
      // Floating Action Button
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: accentColor,
        foregroundColor: Colors.white,
        elevation: 4,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(radiusLarge),
        ),
      ),
      
      // Text Theme
      textTheme: const TextTheme(
        displayLarge: TextStyle(
          fontFamily: headingFont,
          fontSize: 57,
          fontWeight: FontWeight.w400,
          letterSpacing: -0.25,
          color: lightForeground,
        ),
        displayMedium: TextStyle(
          fontFamily: headingFont,
          fontSize: 45,
          fontWeight: FontWeight.w400,
          color: lightForeground,
        ),
        displaySmall: TextStyle(
          fontFamily: headingFont,
          fontSize: 36,
          fontWeight: FontWeight.w400,
          color: lightForeground,
        ),
        headlineLarge: TextStyle(
          fontFamily: headingFont,
          fontSize: 32,
          fontWeight: FontWeight.w600,
          color: lightForeground,
        ),
        headlineMedium: TextStyle(
          fontFamily: headingFont,
          fontSize: 28,
          fontWeight: FontWeight.w600,
          color: lightForeground,
        ),
        headlineSmall: TextStyle(
          fontFamily: headingFont,
          fontSize: 24,
          fontWeight: FontWeight.w600,
          color: lightForeground,
        ),
        titleLarge: TextStyle(
          fontFamily: headingFont,
          fontSize: 22,
          fontWeight: FontWeight.w600,
          color: lightForeground,
        ),
        titleMedium: TextStyle(
          fontFamily: bodyFont,
          fontSize: 16,
          fontWeight: FontWeight.w600,
          letterSpacing: 0.15,
          color: lightForeground,
        ),
        titleSmall: TextStyle(
          fontFamily: bodyFont,
          fontSize: 14,
          fontWeight: FontWeight.w600,
          letterSpacing: 0.1,
          color: lightForeground,
        ),
        bodyLarge: TextStyle(
          fontFamily: bodyFont,
          fontSize: 16,
          fontWeight: FontWeight.w400,
          letterSpacing: 0.5,
          color: lightForeground,
        ),
        bodyMedium: TextStyle(
          fontFamily: bodyFont,
          fontSize: 14,
          fontWeight: FontWeight.w400,
          letterSpacing: 0.25,
          color: lightForeground,
        ),
        bodySmall: TextStyle(
          fontFamily: bodyFont,
          fontSize: 12,
          fontWeight: FontWeight.w400,
          letterSpacing: 0.4,
          color: lightForeground,
        ),
        labelLarge: TextStyle(
          fontFamily: bodyFont,
          fontSize: 14,
          fontWeight: FontWeight.w600,
          letterSpacing: 0.1,
          color: lightForeground,
        ),
        labelMedium: TextStyle(
          fontFamily: bodyFont,
          fontSize: 12,
          fontWeight: FontWeight.w600,
          letterSpacing: 0.5,
          color: lightForeground,
        ),
        labelSmall: TextStyle(
          fontFamily: bodyFont,
          fontSize: 11,
          fontWeight: FontWeight.w600,
          letterSpacing: 0.5,
          color: lightForeground,
        ),
      ),
    );
  }

  /// Dark Theme
  static ThemeData get darkTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      colorScheme: ColorScheme.dark(
        primary: primaryColor,
        secondary: secondaryColor,
        tertiary: accentColor,
        error: errorColor,
        surface: darkSurface,
        onSurface: darkForeground,
        surfaceContainerHighest: darkMuted,
        outline: darkBorder,
      ),
      scaffoldBackgroundColor: darkBackground,
      
      // AppBar
      appBarTheme: const AppBarTheme(
        backgroundColor: darkSurface,
        foregroundColor: darkForeground,
        elevation: 0,
        centerTitle: true,
        systemOverlayStyle: SystemUiOverlayStyle.light,
        titleTextStyle: TextStyle(
          fontFamily: headingFont,
          fontSize: 20,
          fontWeight: FontWeight.w600,
          color: darkForeground,
        ),
      ),
      
      // Cards
      cardTheme: CardThemeData(
        color: darkSurface,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(radiusLarge),
          side: BorderSide(color: darkBorder.withOpacity(0.3)),
        ),
        margin: const EdgeInsets.all(spacingSM),
      ),
      
      // Buttons
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primaryColor,
          foregroundColor: Colors.white,
          elevation: 0,
          padding: const EdgeInsets.symmetric(horizontal: spacingLG, vertical: spacingMD),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(radiusMedium),
          ),
          textStyle: const TextStyle(
            fontFamily: bodyFont,
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: primaryColor,
          side: const BorderSide(color: primaryColor, width: 1.5),
          padding: const EdgeInsets.symmetric(horizontal: spacingLG, vertical: spacingMD),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(radiusMedium),
          ),
          textStyle: const TextStyle(
            fontFamily: bodyFont,
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: primaryColor,
          textStyle: const TextStyle(
            fontFamily: bodyFont,
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      
      // Input Fields
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: darkSurface,
        contentPadding: const EdgeInsets.symmetric(horizontal: spacingMD, vertical: spacingMD),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(radiusMedium),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(radiusMedium),
          borderSide: BorderSide(color: darkMuted),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(radiusMedium),
          borderSide: const BorderSide(color: primaryColor, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(radiusMedium),
          borderSide: const BorderSide(color: errorColor),
        ),
        hintStyle: TextStyle(
          fontFamily: bodyFont,
          color: darkForeground.withOpacity(0.5),
        ),
      ),
      
      // Progress Indicators
      progressIndicatorTheme: const ProgressIndicatorThemeData(
        color: secondaryColor,
        linearTrackColor: darkMuted,
      ),
      
      // Bottom Navigation
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: darkSurface,
        selectedItemColor: primaryColor,
        unselectedItemColor: darkMuted,
        type: BottomNavigationBarType.fixed,
        elevation: 8,
      ),
      
      // Floating Action Button
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: accentColor,
        foregroundColor: Colors.white,
        elevation: 4,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(radiusLarge),
        ),
      ),
      
      // Text Theme
      textTheme: const TextTheme(
        displayLarge: TextStyle(
          fontFamily: headingFont,
          fontSize: 57,
          fontWeight: FontWeight.w400,
          letterSpacing: -0.25,
          color: darkForeground,
        ),
        displayMedium: TextStyle(
          fontFamily: headingFont,
          fontSize: 45,
          fontWeight: FontWeight.w400,
          color: darkForeground,
        ),
        displaySmall: TextStyle(
          fontFamily: headingFont,
          fontSize: 36,
          fontWeight: FontWeight.w400,
          color: darkForeground,
        ),
        headlineLarge: TextStyle(
          fontFamily: headingFont,
          fontSize: 32,
          fontWeight: FontWeight.w600,
          color: darkForeground,
        ),
        headlineMedium: TextStyle(
          fontFamily: headingFont,
          fontSize: 28,
          fontWeight: FontWeight.w600,
          color: darkForeground,
        ),
        headlineSmall: TextStyle(
          fontFamily: headingFont,
          fontSize: 24,
          fontWeight: FontWeight.w600,
          color: darkForeground,
        ),
        titleLarge: TextStyle(
          fontFamily: headingFont,
          fontSize: 22,
          fontWeight: FontWeight.w600,
          color: darkForeground,
        ),
        titleMedium: TextStyle(
          fontFamily: bodyFont,
          fontSize: 16,
          fontWeight: FontWeight.w600,
          letterSpacing: 0.15,
          color: darkForeground,
        ),
        titleSmall: TextStyle(
          fontFamily: bodyFont,
          fontSize: 14,
          fontWeight: FontWeight.w600,
          letterSpacing: 0.1,
          color: darkForeground,
        ),
        bodyLarge: TextStyle(
          fontFamily: bodyFont,
          fontSize: 16,
          fontWeight: FontWeight.w400,
          letterSpacing: 0.5,
          color: darkForeground,
        ),
        bodyMedium: TextStyle(
          fontFamily: bodyFont,
          fontSize: 14,
          fontWeight: FontWeight.w400,
          letterSpacing: 0.25,
          color: darkForeground,
        ),
        bodySmall: TextStyle(
          fontFamily: bodyFont,
          fontSize: 12,
          fontWeight: FontWeight.w400,
          letterSpacing: 0.4,
          color: darkForeground,
        ),
        labelLarge: TextStyle(
          fontFamily: bodyFont,
          fontSize: 14,
          fontWeight: FontWeight.w600,
          letterSpacing: 0.1,
          color: darkForeground,
        ),
        labelMedium: TextStyle(
          fontFamily: bodyFont,
          fontSize: 12,
          fontWeight: FontWeight.w600,
          letterSpacing: 0.5,
          color: darkForeground,
        ),
        labelSmall: TextStyle(
          fontFamily: bodyFont,
          fontSize: 11,
          fontWeight: FontWeight.w600,
          letterSpacing: 0.5,
          color: darkForeground,
        ),
      ),
    );
  }
}