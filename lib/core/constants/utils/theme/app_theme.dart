import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  // Theme Type Enum
  static const String themeFriend = 'friend';
  static const String themeLove = 'love';

  // Love Theme Colors (Pink & Magenta)
  static const lovePrimary = Color(0xFFE91E63);
  static const loveSecondary = Color(0xFFFF4081);
  static const loveLight = Color(0xFFFCE4EC);

  // Friend Theme Colors (Blue & Teal)
  static const friendPrimary = Color(0xFF2196F3);
  static const friendSecondary = Color(0xFF00BCD4);
  static const friendLight = Color(0xFFE3F2FD);

  // Common Colors
  static const pureWhite = Color(0xFFFFFFFF);
  static const softGrey = Color(0xFFF8F9FA);
  static const textBlack = Color(0xFF1A1A1B);
  static const textGrey = Color(0xFF606770);

  static LinearGradient getSplashGradient(String themeType) {
    if (themeType == themeLove) {
      return const LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [Color(0xFFFE4A49), Color(0xFFE91E63)],
      );
    } else {
      return const LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [Color(0xFF4FACFE), Color(0xFF00F2FE)],
      );
    }
  }

  static ThemeData getTheme(String themeType) {
    return themeType == themeLove ? loveTheme : friendTheme;
  }

  static final loveTheme = _buildTheme(
    primary: lovePrimary,
    secondary: loveSecondary,
    light: loveLight,
    brightness: Brightness.light,
  );

  static final friendTheme = _buildTheme(
    primary: friendPrimary,
    secondary: friendSecondary,
    light: friendLight,
    brightness: Brightness.light,
  );

  static ThemeData _buildTheme({
    required Color primary,
    required Color secondary,
    required Color light,
    required Brightness brightness,
  }) {
    return ThemeData(
      brightness: brightness,
      primaryColor: primary,
      scaffoldBackgroundColor: pureWhite,
      appBarTheme: AppBarTheme(
        backgroundColor: pureWhite,
        elevation: 0,
        centerTitle: true,
        iconTheme: IconThemeData(color: primary, size: 28),
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
      colorScheme: ColorScheme.fromSeed(
        seedColor: primary,
        primary: primary,
        secondary: secondary,
        surface: pureWhite,
        brightness: brightness,
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primary,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 18),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(18),
          ),
          elevation: 4,
          shadowColor: primary.withOpacity(0.4),
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
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 24,
          vertical: 20,
        ),
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
          borderSide: BorderSide(color: primary, width: 2),
        ),
        hintStyle: GoogleFonts.inter(color: textGrey.withOpacity(0.5)),
      ),
    );
  }

  // Support for backward compatibility
  static final lightTheme = friendTheme;
  static const primaryPink = lovePrimary;
  static const heartPink = loveSecondary;
  static const lightPink = loveLight;

  static const cardBg = pureWhite;
  static const darkBg = softGrey;
  static const accentPurple = primaryPink;
  static const softPink = lightPink;

  static const primaryGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [lovePrimary, loveSecondary],
  );

  static const splashGradient = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [Color(0xFFFE4A49), Color(0xFFE91E63)],
  );
}
