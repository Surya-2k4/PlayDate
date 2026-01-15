import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  // Sharper Heart Pink & White Theme Colors
  static const primaryPink = Color(0xFFE91E63); // Sharper, deeper pink
  static const heartPink = Color(0xFFFF4081);
  static const lightPink = Color(0xFFFCE4EC);
  static const pureWhite = Color(0xFFFFFFFF);
  static const softGrey = Color(0xFFF8F9FA);
  static const textBlack = Color(0xFF1A1A1B);
  static const textGrey = Color(0xFF606770);

  static const splashGradient = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [
      Color(0xFFFE4A49), // Vibrant reddish-pink from image top
      Color(0xFFE91E63), // Sharp magenta-pink from image bottom
    ],
  );

  static const primaryGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFFE91E63), Color(0xFFFF4081)],
  );

  static BoxDecoration sharpShadow = BoxDecoration(
    color: Colors.white,
    borderRadius: BorderRadius.circular(20),
    boxShadow: [
      BoxShadow(
        color: primaryPink.withOpacity(0.12),
        blurRadius: 20,
        offset: const Offset(0, 10),
      ),
    ],
  );

  static final lightTheme = ThemeData(
    brightness: Brightness.light,
    primaryColor: primaryPink,
    scaffoldBackgroundColor: pureWhite,
    appBarTheme: AppBarTheme(
      backgroundColor: pureWhite,
      elevation: 0,
      centerTitle: true,
      iconTheme: const IconThemeData(color: primaryPink, size: 28),
      titleTextStyle: GoogleFonts.poppins(
        color: textBlack,
        fontSize: 20,
        fontWeight: FontWeight.bold,
      ),
    ),
    textTheme: TextTheme(
      displayLarge: GoogleFonts.poppins(
        fontSize: 34,
        fontWeight: FontWeight.w800,
        color: textBlack,
        letterSpacing: -0.5,
      ),
      displayMedium: GoogleFonts.poppins(
        fontSize: 26,
        fontWeight: FontWeight.w700,
        color: textBlack,
      ),
      bodyLarge: GoogleFonts.inter(
        fontSize: 16,
        color: textBlack,
        fontWeight: FontWeight.w500,
      ),
      bodyMedium: GoogleFonts.inter(
        fontSize: 14,
        color: textGrey,
        fontWeight: FontWeight.w400,
      ),
    ),
    colorScheme: ColorScheme.light(
      primary: primaryPink,
      secondary: heartPink,
      surface: pureWhite,
      error: const Color(0xFFD32F2F),
      onPrimary: Colors.white,
      onSecondary: Colors.white,
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: primaryPink,
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 18),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
        elevation: 4,
        shadowColor: primaryPink.withOpacity(0.4),
        textStyle: GoogleFonts.poppins(
          fontWeight: FontWeight.bold,
          fontSize: 16,
          letterSpacing: 1,
        ),
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: softGrey,
      contentPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(18),
        borderSide: BorderSide(color: Colors.grey.shade200, width: 1),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(18),
        borderSide: BorderSide(color: Colors.grey.shade200, width: 1),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(18),
        borderSide: const BorderSide(color: primaryPink, width: 2),
      ),
      hintStyle: GoogleFonts.inter(color: textGrey.withOpacity(0.5)),
    ),
  );

  // Legacy/Compatibility support (deprecated but kept to prevent breaking screens)
  static const cardBg = pureWhite;
  static const darkBg = softGrey;
  static const accentPurple = primaryPink;
  static const softPink = lightPink;
}
