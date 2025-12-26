import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'color_tokens.dart';

// Typography Scale
// Purpose: A strict type hierarchy. No random font sizes allowed.

class AppText {
  // Hero / Display
  static TextStyle h1(bool isMobile) => GoogleFonts.inter(
    fontSize: isMobile ? 40 : 72,
    fontWeight: FontWeight.w900,
    height: 1.1,
    letterSpacing: -1.5,
    color: AppColors.textPrimary,
  );

  // Section Headers
  static TextStyle h2(bool isMobile) => GoogleFonts.inter(
    fontSize: isMobile ? 28 : 36,
    fontWeight: FontWeight.w900,
    letterSpacing: -0.5,
    color: AppColors.textPrimary,
  );

  // Card Titles
  static const TextStyle h3 = TextStyle(
    fontSize: 22,
    fontWeight: FontWeight.bold,
    color: AppColors.textPrimary,
  );

  // Body Text
  static TextStyle body = TextStyle(
    fontSize: 16,
    height: 1.6,
    color: AppColors.textMuted,
  );

  // Labels / Overlines
  static TextStyle label = const TextStyle(
    fontSize: 12,
    fontWeight: FontWeight.w900,
    letterSpacing: 2.0,
    color: AppColors.accent,
  );
  
  // Button Text
  static const TextStyle button = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w800,
    letterSpacing: 0.5,
  );
}
