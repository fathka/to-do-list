import 'package:flutter/material.dart';

enum AppTheme { blue, pink, purple }

class AppThemes {
  // =====================
  // BLUE THEME (DEFAULT)
  // =====================
  static final ThemeData blueTheme = ThemeData(
    scaffoldBackgroundColor: const Color(0xFFD8E1E8),
    primaryColor: const Color(0xFF304674),
    appBarTheme: const AppBarTheme(
      backgroundColor: Color(0xFF304674),
      foregroundColor: Colors.white,
    ),
    colorScheme: ColorScheme.light(
      primary: const Color(0xFF304674),
      secondary: const Color(0xFFB2CBDE),
      background: const Color(0xFFD8E1E8),
      onPrimary: Colors.white,
      onSecondary: const Color(0xFF304674),
    ),
    floatingActionButtonTheme: const FloatingActionButtonThemeData(
      backgroundColor: Color(0xFF304674),
      foregroundColor: Colors.white,
    ),
    iconTheme: const IconThemeData(color: Color(0xFF304674)),
    textTheme: const TextTheme(
      bodyMedium: TextStyle(color: Color(0xFF304674)),
      titleLarge: TextStyle(color: Color(0xFF304674)),
    ),
  );

  // =====================
  // PINK THEME
  // =====================
  static final ThemeData pinkTheme = ThemeData(
    scaffoldBackgroundColor: const Color(0xFFFFE9EF),
    primaryColor: const Color(0xFFFC809F),
    appBarTheme: const AppBarTheme(
      backgroundColor: Color(0xFFFC809F),
      foregroundColor: Colors.white,
    ),
    colorScheme: ColorScheme.light(
      primary: const Color(0xFFFC809F),
      secondary: const Color(0xFFFFBCCD),
      background: const Color(0xFFFFE9EF),
      onPrimary: Colors.white,
      onSecondary: const Color(0xFFFC809F),
    ),
    floatingActionButtonTheme: const FloatingActionButtonThemeData(
      backgroundColor: Color(0xFFFC809F),
      foregroundColor: Colors.white,
    ),
    iconTheme: const IconThemeData(color: Color(0xFFFC809F)),
    textTheme: const TextTheme(
      bodyMedium: TextStyle(color: Color(0xFF3A3A3A)),
      titleLarge: TextStyle(color: Color(0xFFFC809F)),
    ),
  );

  // =====================
  // PURPLE THEME
  // =====================
  static final ThemeData purpleTheme = ThemeData(
    scaffoldBackgroundColor: const Color(0xFFD4BEE4),
    primaryColor: const Color(0xFF3B1E54),
    appBarTheme: const AppBarTheme(
      backgroundColor: Color(0xFF3B1E54),
      foregroundColor: Colors.white,
    ),
    colorScheme: ColorScheme.light(
      primary: const Color(0xFF3B1E54),
      secondary: const Color(0xFF9B7EBD),
      background: const Color(0xFFD4BEE4),
      onPrimary: Colors.white,
      onSecondary: const Color(0xFF3B1E54),
    ),
    floatingActionButtonTheme: const FloatingActionButtonThemeData(
      backgroundColor: Color(0xFF3B1E54),
      foregroundColor: Colors.white,
    ),
    iconTheme: const IconThemeData(color: Color(0xFF3B1E54)),
    textTheme: const TextTheme(
      bodyMedium: TextStyle(color: Color(0xFF3B1E54)),
      titleLarge: TextStyle(color: Color(0xFF3B1E54)),
    ),
  );
}
