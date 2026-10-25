import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../constants/app_colors.dart';

class AppTheme {
  static ThemeData lightTheme = ThemeData(
    brightness: Brightness.light,
    scaffoldBackgroundColor: AppColors.lightBackground,
    primaryColor: AppColors.primary,
    useMaterial3: true,
    fontFamily: GoogleFonts.cairo().fontFamily,
    appBarTheme: AppBarTheme(
      centerTitle: true,
      backgroundColor: AppColors.lightBackground,
      elevation: 0,
      titleTextStyle: GoogleFonts.cairo(
        color: Colors.black,
        fontSize: 20,
        fontWeight: FontWeight.bold,
      ),
      iconTheme: const IconThemeData(color: Colors.black),
    ),
    cardColor: AppColors.lightCard,
  );

  static ThemeData darkTheme = ThemeData(
    brightness: Brightness.dark,
    scaffoldBackgroundColor: AppColors.darkBackground,
    primaryColor: AppColors.primary,
    useMaterial3: true,
    fontFamily: GoogleFonts.cairo().fontFamily,
    appBarTheme: AppBarTheme(
      centerTitle: true,
      backgroundColor: AppColors.darkBackground,
      elevation: 0,
      titleTextStyle: GoogleFonts.cairo(
        color: Colors.white,
        fontSize: 20,
        fontWeight: FontWeight.bold,
      ),
      iconTheme: const IconThemeData(color: Colors.white),
    ),
    cardColor: AppColors.darkCard,
  );
}