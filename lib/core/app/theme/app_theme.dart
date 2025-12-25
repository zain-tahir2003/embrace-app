import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  // --- COLORS (Light) ---
  static const Color lightPrimary = Color(0xFF6B4EFF);
  static const Color lightBackground = Color(0xFFF3F4F6);
  static const Color lightSurface = Colors.white;
  static const Color lightText = Color(0xFF1F2937);

  // --- COLORS (Dark) ---
  static const Color darkPrimary = Color(0xFF9F8BFF);
  static const Color darkBackground = Color(0xFF121212);
  static const Color darkSurface = Color(0xFF1E1E24);
  static const Color darkText = Color(0xFFF9FAFB);

  // --- LIGHT THEME ---
  static final ThemeData lightTheme = ThemeData(
    useMaterial3: true,
    brightness: Brightness.light,
    primaryColor: lightPrimary,
    scaffoldBackgroundColor: lightBackground,
    cardColor: lightSurface,
    
    textTheme: GoogleFonts.poppinsTextTheme().apply(
      bodyColor: lightText,
      displayColor: lightText,
    ),

    colorScheme: const ColorScheme.light(
      primary: lightPrimary,
      secondary: Color(0xFF00C896),
      surface: lightSurface,
      // REMOVED: background: lightBackground (Deprecated)
      onPrimary: Colors.white,
      onSurface: lightText,
    ),

    appBarTheme: const AppBarTheme(
      backgroundColor: Colors.transparent,
      elevation: 0,
      centerTitle: true,
      iconTheme: IconThemeData(color: lightText),
      titleTextStyle: TextStyle(
        color: lightText, 
        fontSize: 20, 
        fontWeight: FontWeight.bold,
      ),
    ),

    floatingActionButtonTheme: FloatingActionButtonThemeData(
      backgroundColor: lightPrimary,
      foregroundColor: Colors.white,
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
    ),

    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: Colors.white,
      hintStyle: GoogleFonts.poppins(color: Colors.grey[400]),
      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: BorderSide.none,
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: BorderSide.none,
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: const BorderSide(color: lightPrimary, width: 2),
      ),
    ),
  );

  // --- DARK THEME ---
  static final ThemeData darkTheme = ThemeData(
    useMaterial3: true,
    brightness: Brightness.dark,
    primaryColor: darkPrimary,
    scaffoldBackgroundColor: darkBackground,
    cardColor: darkSurface,
    
    textTheme: GoogleFonts.poppinsTextTheme().apply(
      bodyColor: darkText,
      displayColor: darkText,
    ),

    colorScheme: const ColorScheme.dark(
      primary: darkPrimary,
      secondary: Color(0xFF00E676),
      surface: darkSurface,
      // REMOVED: background: darkBackground (Deprecated)
      onPrimary: Colors.white,
      onSurface: darkText,
    ),

    appBarTheme: const AppBarTheme(
      backgroundColor: Colors.transparent,
      elevation: 0,
      centerTitle: true,
      iconTheme: IconThemeData(color: darkText),
      titleTextStyle: TextStyle(
        color: darkText, 
        fontSize: 20, 
        fontWeight: FontWeight.bold,
      ),
    ),

    floatingActionButtonTheme: FloatingActionButtonThemeData(
      backgroundColor: darkPrimary,
      foregroundColor: Colors.black,
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
    ),

    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: const Color(0xFF2C2C35),
      hintStyle: GoogleFonts.poppins(color: Colors.grey[500]),
      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: BorderSide.none,
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: BorderSide.none,
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: const BorderSide(color: darkPrimary, width: 2),
      ),
    ),
  );
}