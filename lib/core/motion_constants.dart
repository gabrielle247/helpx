import 'package:flutter/material.dart';

// Motion Constants
// Purpose: Consistent animation timing across the app.

class Motion {
  static const Duration fast = Duration(milliseconds: 150);
  static const Duration normal = Duration(milliseconds: 250);
  static const Duration slow = Duration(milliseconds: 400);

  static const Curve standard = Curves.easeOutCubic;
}