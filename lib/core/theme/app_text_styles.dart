import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../constants/app_colors.dart';

abstract class AppTextStyles {
  // Headings
  static TextStyle headlineLarge({bool isDark = true}) => GoogleFonts.outfit(
        fontSize: 28,
        fontWeight: FontWeight.bold,
        color: isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary,
      );

  static TextStyle headlineMedium({bool isDark = true}) => GoogleFonts.outfit(
        fontSize: 22,
        fontWeight: FontWeight.w600,
        color: isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary,
      );

  static TextStyle titleMedium({bool isDark = true}) => GoogleFonts.outfit(
        fontSize: 16,
        fontWeight: FontWeight.w600,
        color: isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary,
      );

  // Body Text
  static TextStyle bodyLarge({bool isDark = true}) => GoogleFonts.outfit(
        fontSize: 16,
        fontWeight: FontWeight.normal,
        height: 1.5,
        color: isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary,
      );

  static TextStyle bodyMedium({bool isDark = true}) => GoogleFonts.outfit(
        fontSize: 14,
        fontWeight: FontWeight.normal,
        height: 1.4,
        color: isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary,
      );

  static TextStyle bodySmall({bool isDark = true}) => GoogleFonts.outfit(
        fontSize: 12,
        fontWeight: FontWeight.normal,
        color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
      );

  // Buttons & Hints
  static TextStyle buttonText = GoogleFonts.outfit(
    fontSize: 14,
    fontWeight: FontWeight.w600,
    color: Colors.white,
  );

  static TextStyle hintText({bool isDark = true}) => GoogleFonts.outfit(
        fontSize: 14,
        color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
      );

  // Monospace / Code Block style
  static TextStyle codeBlock({bool isDark = true}) => GoogleFonts.robotoMono(
        fontSize: 13,
        height: 1.5,
        color: isDark ? const Color(0xFFE6EDE3) : const Color(0xFF24292E),
      );
}
