// booking_theme.dart
import 'package:flutter/material.dart';

class BookingTheme {
  static const Color primaryColor = Color(0xFF6FCF97);
  static const Color borderColor = Colors.grey;
  static const Color cardColor = Colors.white;
  static const Color textColor = Colors.black87;

  // Dark theme variants
  static const Color darkCardColor = Color(0xFF23272F);
  static const Color darkTextColor = Colors.white;
  static const Color darkBorderColor = Colors.white30;

  // Get theme-aware colors
  static Color getBorderColor(BuildContext context) {
    return Theme.of(context).brightness == Brightness.dark
        ? darkBorderColor
        : borderColor;
  }

  static Color getCardColor(BuildContext context) {
    return Theme.of(context).brightness == Brightness.dark
        ? darkCardColor
        : cardColor;
  }

  static Color getTextColor(BuildContext context) {
    return Theme.of(context).brightness == Brightness.dark
        ? darkTextColor
        : textColor;
  }
}