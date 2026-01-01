// screens/app_theme.dart
import 'package:flutter/material.dart';

class AppTheme {
  // Light Theme Configuration
  static ThemeData lightTheme = ThemeData(
    brightness: Brightness.light,
    primarySwatch: Colors.green,
    primaryColor: const Color(0xFF34A853),
    scaffoldBackgroundColor: Colors.white,

    // AppBar Theme
    appBarTheme: const AppBarTheme(
      backgroundColor: Colors.white,
      foregroundColor: Colors.black,
      elevation: 0,
      iconTheme: IconThemeData(color: Colors.black),
      titleTextStyle: TextStyle(
        color: Colors.black,
        fontSize: 20,
        fontWeight: FontWeight.bold,
      ),
    ),

    // Text Theme
    textTheme: const TextTheme(
      // Headline styles
      displayLarge: TextStyle(
        color: Colors.black,
        fontSize: 32,
        fontWeight: FontWeight.bold,
      ),
      displayMedium: TextStyle(
        color: Colors.black,
        fontSize: 28,
        fontWeight: FontWeight.bold,
      ),
      displaySmall: TextStyle(
        color: Colors.black,
        fontSize: 24,
        fontWeight: FontWeight.bold,
      ),

      // Title styles
      headlineLarge: TextStyle(
        color: Colors.black,
        fontSize: 22,
        fontWeight: FontWeight.bold,
      ),
      headlineMedium: TextStyle(
        color: Colors.black,
        fontSize: 20,
        fontWeight: FontWeight.w600,
      ),
      headlineSmall: TextStyle(
        color: Colors.black,
        fontSize: 18,
        fontWeight: FontWeight.w600,
      ),

      // Body text styles
      bodyLarge: TextStyle(color: Colors.black, fontSize: 16),
      bodyMedium: TextStyle(color: Colors.black, fontSize: 14),
      bodySmall: TextStyle(color: Colors.black, fontSize: 12),

      // Label styles
      labelLarge: TextStyle(
        color: Colors.black,
        fontSize: 14,
        fontWeight: FontWeight.w500,
      ),
      labelMedium: TextStyle(
        color: Colors.black,
        fontSize: 12,
        fontWeight: FontWeight.w500,
      ),
      labelSmall: TextStyle(
        color: Colors.black,
        fontSize: 11,
        fontWeight: FontWeight.w500,
      ),
    ),

    // Card Theme
    cardTheme: CardThemeData(
      color: Colors.white,
      shadowColor: Colors.grey.withOpacity(0.1),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
    ),

    // Input Decoration Theme
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: Colors.grey[50],
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: Colors.grey),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: Colors.grey),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: Color(0xFF34A853)),
      ),
      hintStyle: TextStyle(color: Colors.grey[600]),
      labelStyle: const TextStyle(color: Colors.black),
    ),

    // Bottom Navigation Bar Theme
    bottomNavigationBarTheme: const BottomNavigationBarThemeData(
      backgroundColor: Colors.white,
      selectedItemColor: Color(0xFF34A853),
      unselectedItemColor: Colors.grey,
      type: BottomNavigationBarType.fixed,
    ),

    // Icon Theme
    iconTheme: const IconThemeData(color: Colors.black),

    // Divider Theme
    dividerTheme: DividerThemeData(color: Colors.grey[300]),

    // Color Scheme
    colorScheme: const ColorScheme.light(
      primary: Color(0xFF34A853),
      secondary: Color(0xFF6DC476),
      background: Colors.white,
      surface: Colors.white,
      onPrimary: Colors.white,
      onSecondary: Colors.white,
      onBackground: Colors.black,
      onSurface: Colors.black,
    ),
  );

  // Dark Theme Configuration
  static ThemeData darkTheme = ThemeData(
    brightness: Brightness.dark,
    primarySwatch: Colors.green,
    primaryColor: const Color(0xFF34A853),
    scaffoldBackgroundColor: Colors.black,

    // AppBar Theme
    appBarTheme: const AppBarTheme(
      backgroundColor: Colors.black,
      foregroundColor: Colors.white,
      elevation: 0,
      iconTheme: IconThemeData(color: Colors.white),
      titleTextStyle: TextStyle(
        color: Colors.white,
        fontSize: 20,
        fontWeight: FontWeight.bold,
      ),
    ),

    // Text Theme
    textTheme: const TextTheme(
      // Headline styles
      displayLarge: TextStyle(
        color: Colors.white,
        fontSize: 32,
        fontWeight: FontWeight.bold,
      ),
      displayMedium: TextStyle(
        color: Colors.white,
        fontSize: 28,
        fontWeight: FontWeight.bold,
      ),
      displaySmall: TextStyle(
        color: Colors.white,
        fontSize: 24,
        fontWeight: FontWeight.bold,
      ),

      // Title styles
      headlineLarge: TextStyle(
        color: Colors.white,
        fontSize: 22,
        fontWeight: FontWeight.bold,
      ),
      headlineMedium: TextStyle(
        color: Colors.white,
        fontSize: 20,
        fontWeight: FontWeight.w600,
      ),
      headlineSmall: TextStyle(
        color: Colors.white,
        fontSize: 18,
        fontWeight: FontWeight.w600,
      ),

      // Body text styles
      bodyLarge: TextStyle(color: Colors.white, fontSize: 16),
      bodyMedium: TextStyle(color: Colors.white, fontSize: 14),
      bodySmall: TextStyle(color: Colors.white, fontSize: 12),

      // Label styles
      labelLarge: TextStyle(
        color: Colors.white,
        fontSize: 14,
        fontWeight: FontWeight.w500,
      ),
      labelMedium: TextStyle(
        color: Colors.white,
        fontSize: 12,
        fontWeight: FontWeight.w500,
      ),
      labelSmall: TextStyle(
        color: Colors.white,
        fontSize: 11,
        fontWeight: FontWeight.w500,
      ),
    ),

    // Card Theme
    cardTheme: CardThemeData(
      color: Colors.grey[900],
      shadowColor: Colors.black.withOpacity(0.3),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
    ),

    // Input Decoration Theme
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: Colors.grey[800],
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: BorderSide(color: Colors.grey[600]!),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: BorderSide(color: Colors.grey[600]!),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: Color(0xFF34A853)),
      ),
      hintStyle: TextStyle(color: Colors.grey[500]),
      labelStyle: const TextStyle(color: Colors.white),
    ),

    // Bottom Navigation Bar Theme
    bottomNavigationBarTheme: BottomNavigationBarThemeData(
      backgroundColor: Colors.black,
      selectedItemColor: const Color(0xFF34A853),
      unselectedItemColor: Colors.grey[400],
      type: BottomNavigationBarType.fixed,
    ),

    // Icon Theme
    iconTheme: const IconThemeData(color: Colors.white),

    // Divider Theme
    dividerTheme: DividerThemeData(color: Colors.grey[700]),

    // Color Scheme
    colorScheme: const ColorScheme.dark(
      primary: Color(0xFF34A853),
      secondary: Color(0xFF6DC476),
      background: Colors.black,
      surface: Colors.black,
      onPrimary: Colors.white,
      onSecondary: Colors.white,
      onBackground: Colors.white,
      onSurface: Colors.white,
    ),
  );

  // Helper method to get current theme colors
  static bool isDarkMode(BuildContext context) {
    return Theme.of(context).brightness == Brightness.dark;
  }

  // Helper method to get background color
  static Color getBackgroundColor(BuildContext context) {
    return isDarkMode(context) ? Colors.black : Colors.white;
  }

  // Helper method to get text color
  static Color getTextColor(BuildContext context) {
    return isDarkMode(context) ? Colors.white : Colors.black;
  }

  // Helper method to get secondary text color
  static Color getSecondaryTextColor(BuildContext context) {
    return isDarkMode(context) ? Colors.grey[400]! : Colors.grey[600]!;
  }

  // Helper method to get card color
  static Color getCardColor(BuildContext context) {
    return isDarkMode(context) ? Colors.grey[900]! : Colors.white;
  }

  // Helper method to get border color
  static Color getBorderColor(BuildContext context) {
    return isDarkMode(context) ? Colors.grey[600]! : Colors.grey[300]!;
  }

  // Helper method to get input field color
  static Color getInputFieldColor(BuildContext context) {
    return isDarkMode(context) ? Colors.grey[800]! : Colors.grey[50]!;
  }

  // Helper method to get shadow color
  static Color getShadowColor(BuildContext context) {
    return isDarkMode(context)
        ? Colors.black.withOpacity(0.3)
        : Colors.grey.withOpacity(0.1);
  }

  // Gradient colors for buttons (these remain the same for both themes)
  static const LinearGradient primaryGradient = LinearGradient(
    colors: [Color(0xFF6DC476), Color(0xFF388E3C)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  // Service card colors for different themes
  static Color getServiceCardBackground(BuildContext context) {
    return isDarkMode(context) ? Colors.grey[850]! : Colors.white;
  }

  static Color getServiceCardBorder(BuildContext context) {
    return isDarkMode(context) ? Colors.grey[700]! : Colors.grey[200]!;
  }
}
