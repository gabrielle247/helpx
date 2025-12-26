import 'package:flutter/material.dart';

// Color Tokens
// Purpose: Semantic color definitions. We don't use "Blue", we use "Accent".

class AppColors {
  // Backgrounds
  static const Color bgPrimary = Color(0xFF0A0A0A);   // Deepest Black
  static const Color bgSurface = Color(0xFF161616);   // Card Surface

  // Accents (The Greyway Blue)
  static const Color accent = Color(0xFF137FEC);
  static const Color accentHover = Color(0xFF0D5CB0);
  static const Color accentMuted = Color(0x33137FEC); // 20% Opacity

  // Text
  static const Color textPrimary = Colors.white;
  static Color textMuted = Colors.white.withAlpha(150); // ~60% Opacity
  static Color textSubtle = Colors.white.withAlpha(80); // ~30% Opacity

  // Borders & Dividers
  static Color borderSubtle = Colors.white.withAlpha(20);
  static Color borderAccent = accent.withAlpha(100);
}