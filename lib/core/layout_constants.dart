// Layout & Spacing Contract
// Purpose: Enforce vertical rhythm and responsive breakpoints. No more magic numbers.

class Layout {
  // Breakpoints
  static const double mobileLimit = 900;
  static const double tabletLimit = 1200;

  // Max Widths for Content
  static const double contentMaxWidth = 1200;
  static const double narrowMaxWidth = 700;

  // Vertical Rhythm (The heartbeat of the layout)
  static const double sectionGap = 120;      // Large gap between major sections
  static const double sectionGapSmall = 80;  // Medium gap for tighter flows
  static const double itemGap = 30;          // Gap between grid items
  static const double elementGap = 16;       // Gap between text and button

  // Page Padding
  static const double pagePaddingMobile = 20;
  static const double pagePaddingDesktop = 60;
}