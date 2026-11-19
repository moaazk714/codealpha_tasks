import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  // Brand color palette from Stitch design specifications
  static const Color deepEmerald = Color(0xFF173F35);
  static const Color warmCream = Color(0xFFF7F4EC);
  static const Color softGreen = Color(0xFFDDE9DF);
  static const Color softGreenLight = Color(0xFFEDF4EE);
  static const Color softGreenBadge = Color(0xFFE4EDE5);
  static const Color mutedGold = Color(0xFFC99B55);
  static const Color mutedGoldLight = Color(0xFFFAF3E8);
  static const Color mutedGoldBorder = Color(0xFFEEDEC8);
  static const Color darkCharcoal = Color(0xFF242824);
  static const Color subtleGrey = Color(0xFF737C75);
  static const Color cardWhite = Color(0xFFFFFFFF);
  static const Color dividerColor = Color(0xFFE5E0D5);
  static const Color borderLight = Color(0xFFEBE6DC);

  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      scaffoldBackgroundColor: warmCream,
      colorScheme: ColorScheme.fromSeed(
        seedColor: deepEmerald,
        primary: deepEmerald,
        secondary: mutedGold,
        surface: cardWhite,
      ),
      textTheme: GoogleFonts.poppinsTextTheme().copyWith(
        displayLarge: GoogleFonts.newsreader(
          color: deepEmerald,
          fontSize: 32,
          fontWeight: FontWeight.w700,
          letterSpacing: -0.5,
        ),
        displayMedium: GoogleFonts.newsreader(
          color: deepEmerald,
          fontSize: 28,
          fontWeight: FontWeight.w700,
          letterSpacing: -0.3,
        ),
        titleLarge: GoogleFonts.newsreader(
          color: deepEmerald,
          fontSize: 24,
          fontWeight: FontWeight.w600,
        ),
        bodyLarge: GoogleFonts.poppins(color: darkCharcoal, fontSize: 16),
        bodyMedium: GoogleFonts.poppins(color: subtleGrey, fontSize: 14),
        labelLarge: GoogleFonts.poppins(
          fontWeight: FontWeight.w600,
          fontSize: 14,
        ),
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0,
      ),
    );
  }

  // Quote serif styling
  static TextStyle quoteTextStyle({
    double fontSize = 22,
    FontStyle fontStyle = FontStyle.normal,
  }) {
    return GoogleFonts.newsreader(
      color: darkCharcoal,
      fontSize: fontSize,
      fontWeight: FontWeight.w500,
      fontStyle: fontStyle,
      height: 1.45,
    );
  }

  // Brand serif styling
  static TextStyle brandTextStyle({double fontSize = 22}) {
    return GoogleFonts.newsreader(
      color: deepEmerald,
      fontSize: fontSize,
      fontWeight: FontWeight.w700,
      letterSpacing: -0.3,
    );
  }
}
