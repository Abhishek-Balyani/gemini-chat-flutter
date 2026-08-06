import 'package:flutter/material.dart';

/// ChatGPT-inspired color palette for Light and Dark themes.
abstract class AppColors {
  // Brand / Accent Colors
  static const Color primary = Color(0xFF10A37F); // OpenAI Accent Green
  static const Color primaryLight = Color(0xFF1AD1A5);
  static const Color primaryDark = Color(0xFF0D8A6C);
  
  // Dark Theme Palette
  static const Color darkBackground = Color(0xFF171717);
  static const Color darkSidebar = Color(0xFF202123);
  static const Color darkSurface = Color(0xFF2A2B32);
  static const Color darkCard = Color(0xFF2D2D37);
  static const Color darkInput = Color(0xFF2F2F38);
  static const Color darkUserBubble = Color(0xFF2F2F38);
  static const Color darkAiBubble = Color(0xFF202123);
  static const Color darkTextPrimary = Color(0xFFECECF1);
  static const Color darkTextSecondary = Color(0xFF8E8EA0);
  static const Color darkBorder = Color(0xFF3E3F4B);

  // Light Theme Palette
  static const Color lightBackground = Color(0xFFFFFFFF);
  static const Color lightSidebar = Color(0xFFF9F9FB);
  static const Color lightSurface = Color(0xFFF7F7F8);
  static const Color lightCard = Color(0xFFF0F0F2);
  static const Color lightInput = Color(0xFFF0F0F2);
  static const Color lightUserBubble = Color(0xFFF0F0F2);
  static const Color lightAiBubble = Color(0xFFF9F9FB);
  static const Color lightTextPrimary = Color(0xFF202123);
  static const Color lightTextSecondary = Color(0xFF6E6E80);
  static const Color lightBorder = Color(0xFFE5E5E7);

  // General Status Colors
  static const Color error = Color(0xFFEF4444);
  static const Color warning = Color(0xFFF59E0B);
  static const Color success = Color(0xFF10B981);
  static const Color codeBackgroundDark = Color(0xFF1E1E1E);
  static const Color codeBackgroundLight = Color(0xFF282C34);
}
