import 'package:flutter/material.dart';

class AppTheme {
  // Primary colors - Pink Peach theme
  static const Color primaryColor = Color(0xFFFF9A9E); // Pink Peach
  static const Color secondaryColor = Color(0xFFFAD0C4); // Coral Pink
  static const Color backgroundColor = Color(0xFFFFF8F6);
  static const Color cardColor = Color(0xFFFFF0ED);
  
  // Category card colors - Pink variations
  static const Color blueCategory = Color(0xFFFFE4E6); // Light pink
  static const Color greenCategory = Color(0xFFFFD6D9); // Soft coral
  static const Color pinkCategory = Color(0xFFFFC8CC); // Medium pink
  
  // Text colors
  static const Color textPrimary = Color(0xFF2D1B1B);
  static const Color textSecondary = Color(0xFF8B6B6B);
  
  // Icon colors - Pink theme variations
  static const Color iconBlue = Color(0xFFFF9A9E); // Pink Peach
  static const Color iconGreen = Color(0xFFFAD0C4); // Coral Pink
  static const Color iconPink = Color(0xFFFF6B7A); // Vibrant pink
  
  static ThemeData lightTheme = ThemeData(
    primaryColor: primaryColor,
    scaffoldBackgroundColor: backgroundColor,
    appBarTheme: const AppBarTheme(
      backgroundColor: backgroundColor,
      elevation: 0,
      iconTheme: IconThemeData(color: textPrimary),
      titleTextStyle: TextStyle(
        color: textPrimary,
        fontSize: 20,
        fontWeight: FontWeight.bold,
      ),
    ),
    cardTheme: CardThemeData(
      color: cardColor,
      elevation: 2,
      shadowColor: primaryColor.withOpacity(0.1),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: primaryColor,
        foregroundColor: Colors.white,
        elevation: 3,
        shadowColor: primaryColor.withOpacity(0.3),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
      ),
    ),
    floatingActionButtonTheme: const FloatingActionButtonThemeData(
      backgroundColor: primaryColor,
      foregroundColor: Colors.white,
      elevation: 6,
    ),
    inputDecorationTheme: InputDecorationTheme(
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: primaryColor.withOpacity(0.3)),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: primaryColor.withOpacity(0.3)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: primaryColor, width: 2),
      ),
      filled: true,
      fillColor: cardColor,
    ),
    textTheme: const TextTheme(
      displayLarge: TextStyle(
        fontSize: 24,
        fontWeight: FontWeight.bold,
        color: textPrimary,
      ),
      displayMedium: TextStyle(
        fontSize: 20,
        fontWeight: FontWeight.w500,
        color: textPrimary,
      ),
      bodyLarge: TextStyle(
        fontSize: 16,
        color: textPrimary,
      ),
      bodyMedium: TextStyle(
        fontSize: 14,
        color: textSecondary,
      ),
    ),
    colorScheme: ColorScheme.fromSwatch().copyWith(
      primary: primaryColor,
      secondary: secondaryColor,
      surface: cardColor,
      background: backgroundColor,
    ),
  );

  static ThemeData darkTheme = ThemeData.dark().copyWith(
    primaryColor: primaryColor,
    scaffoldBackgroundColor: const Color(0xFF121212),
    appBarTheme: const AppBarTheme(
      backgroundColor: Color(0xFF121212),
      elevation: 0,
      iconTheme: IconThemeData(color: Colors.white),
      titleTextStyle: TextStyle(
        color: Colors.white,
        fontSize: 20,
        fontWeight: FontWeight.bold,
      ),
    ),
    floatingActionButtonTheme: const FloatingActionButtonThemeData(
      backgroundColor: primaryColor,
      foregroundColor: Colors.white,
    ),
  );
}
