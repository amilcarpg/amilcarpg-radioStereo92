import 'package:flutter/material.dart';

class AppStyles {
  // Primary Colors
  static const Color primaryRed = Colors.red; // Or a specific shade e.g. Color(0xFFD32F2F)
  static const Color accentRed = Colors.redAccent; // Or a specific shade

  // Background Colors
  static const Color primaryBackground = Colors.black;
  static const Color dialogBackground = Colors.white; // Example for dialogs

  // Text Colors
  static const Color textOnPrimaryBackground = Colors.white;
  static const Color textOnDialogBackground = Colors.black;
  static const Color textOnPrimaryRed = Colors.white;

  // Specific Text Styles (examples, can be expanded or replaced by Theme.textTheme)
  static const TextStyle radioTitleStyle = TextStyle(
    color: textOnPrimaryBackground,
    fontSize: 24,
    fontWeight: FontWeight.bold,
  );

  static const TextStyle generalTextStyle = TextStyle(
    color: textOnPrimaryBackground,
    fontSize: 16,
  );
   static const TextStyle timerTextStyle = TextStyle(
    color: Colors.white70, 
    fontSize: 16
  );


  // Helper to create MaterialColor for primarySwatch
  static MaterialColor createMaterialColor(Color color) {
    List<int> strengths = <int>[50, 100, 200, 300, 400, 500, 600, 700, 800, 900];
    Map<int, Color> swatch = <int, Color>{};
    final int r = color.red, g = color.green, b = color.blue;

    for (int strength in strengths) {
      final double ds = 0.5 - strength / 1000.0;
      swatch[strength] = Color.fromRGBO(
        r + ((ds < 0 ? r : (255 - r)) * ds).round(),
        g + ((ds < 0 ? g : (255 - g)) * ds).round(),
        b + ((ds < 0 ? b : (255 - b)) * ds).round(),
        1,
      );
    }
    return MaterialColor(color.value, swatch);
  }
}
