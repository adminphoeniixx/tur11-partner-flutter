import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppColors {
  static const bg = Color(0xFFEAE6DE);
  static const bg2 = Color(0xFFF2EFE9);
  static const white = Color(0xFFFAFAF7);
  static const dark = Color(0xFF1A1A10);
  static const dark2 = Color(0xFF2A2A1A);
  static const green = Color(0xFF3A6632);
  static const green2 = Color(0xFF4A7C3F);
  static const greenLt = Color(0xFFD4E8CE);
  static const greenBright = Color(0xFF6EC86E);
  static const muted = Color(0xFF78786A);
  static const muted2 = Color(0xFFA6A698);
  static const border = Color(0xFFDCDAD0);
  static const red = Color(0xFFB83228);
  static const redLt = Color(0xFFFCECEA);
  static const amber = Color(0xFF8A5C08);
  static const amberLt = Color(0xFFFEF0CC);
  static const blue = Color(0xFF1E4B8A);
  static const blueLt = Color(0xFFE0EAFF);
}

class AppTheme {
  static TextTheme get _textTheme => GoogleFonts.dmSansTextTheme();

  static ThemeData get theme => ThemeData(
        useMaterial3: true,
        textTheme: _textTheme,
        scaffoldBackgroundColor: AppColors.bg,

        colorScheme: const ColorScheme.light(
          primary: AppColors.green,
          secondary: AppColors.dark,
          surface: AppColors.white,
          error: AppColors.red,
        ),

        appBarTheme: AppBarTheme(
          backgroundColor: AppColors.white,
          foregroundColor: AppColors.dark,
          elevation: 0,
          surfaceTintColor: Colors.transparent, // ✅ fix for M3
          shadowColor: Colors.black.withOpacity(0.07),
          titleTextStyle: GoogleFonts.dmSans(
            fontSize: 16,
            fontWeight: FontWeight.w700,
            color: AppColors.dark,
          ),
        ),

        // ✅ FIXED
        cardTheme: CardThemeData(
          color: AppColors.white,
          elevation: 2,
          shadowColor: Colors.black.withOpacity(0.07),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
        ),

        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: AppColors.white,
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 12, vertical: 10),

          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide:
                const BorderSide(color: AppColors.border, width: 1.5),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide:
                const BorderSide(color: AppColors.border, width: 1.5),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide:
                const BorderSide(color: AppColors.green, width: 1.5),
          ),

          hintStyle:
              GoogleFonts.dmSans(color: AppColors.muted2, fontSize: 13),

          labelStyle: GoogleFonts.dmSans(
            fontSize: 11,
            fontWeight: FontWeight.w700,
            color: AppColors.muted,
            letterSpacing: 0.6,
          ),
        ),

        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.dark,
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(40),
            ),
            padding:
                const EdgeInsets.symmetric(horizontal: 16, vertical: 11),
            textStyle: GoogleFonts.dmSans(
              fontSize: 13,
              fontWeight: FontWeight.w700,
            ),
            elevation: 0, // ✅ smoother UI
          ),
        ),
      );
}
