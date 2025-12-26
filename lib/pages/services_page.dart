import 'package:flutter/material.dart';
import 'package:help_x_web/widgets/sections.dart';
import '../core/all_constants.dart'; // Using the Section primitive for consistent layout
import 'bookings_page.dart';

class ServicesPage extends StatelessWidget {
  const ServicesPage({super.key});

  void _navigateToBooking(BuildContext context, String serviceName) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const BookingsPage()),
    );
  }

  @override
  Widget build(BuildContext context) {
    double sw = MediaQuery.of(context).size.width;
    bool isMobile = sw < Layout.mobileLimit;

    return Scaffold(
      backgroundColor: AppColors.bgPrimary,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        title: Text(
          "RESCUE PROTOCOLS",
          style: AppText.h3.copyWith(letterSpacing: 2),
        ),
        centerTitle: true,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            Section(
              child: _buildRow(
                context,
                isMobile,
                "Technical Rescue Session",
                "Your setup is broken, your tools are fighting you, and deadlines are close. We diagnose and fix environment issues, configuration errors, and tooling failures so you can run, build, and submit without friction — today.",
                "Fix My Setup",
                "assets/tech_rescue.jpg", // Visual Asset
                true,
              ),
            ),
            Section(
              child: _buildRow(
                context,
                isMobile,
                "Concept Clarity Session",
                "When assignments fail because the idea never clicked. We break down the exact concept blocking you — algorithms, data structures, or logic — until you can explain it and apply it confidently.",
                "Unblock This Concept",
                "assets/clarity.jpg", // Visual Asset
                false,
              ),
            ),
            Section(
              child: _buildRow(
                context,
                isMobile,
                "Course Survival Path",
                "For students falling behind or approaching assessment deadlines. Structured, course-specific support for WDD 130, CSE 121b, and related tracks, focused on passing — not endless tutoring.",
                "Stabilize My Course",
                "assets/help.jpg", // Visual Asset
                true,
              ),
            ),
            const SizedBox(height: Layout.sectionGap),
          ],
        ),
      ),
    );
  }

  Widget _buildRow(
    BuildContext context,
    bool isMobile,
    String title,
    String desc,
    String ctaText,
    String assetPath,
    bool imgLeft,
  ) {
    // Visual Image Container
    Widget imageSection = Container(
      width: isMobile ? double.infinity : 450,
      height: 320,
      decoration: BoxDecoration(
        color: AppColors.bgSurface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.borderSubtle),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(100),
            blurRadius: 20,
            offset: const Offset(0, 10),
          )
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: Image.asset(
          assetPath,
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) {
            return Center(
              child: Icon(Icons.image_not_supported, size: 50, color: AppColors.textMuted),
            );
          },
        ),
      ),
    );

    Widget textSection = Column(
      crossAxisAlignment:
          isMobile ? CrossAxisAlignment.center : CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: AppText.h2(isMobile),
          textAlign: isMobile ? TextAlign.center : TextAlign.start,
        ),
        const SizedBox(height: 16),
        Text(
          desc,
          style: AppText.body,
          textAlign: isMobile ? TextAlign.center : TextAlign.start,
        ),
        const SizedBox(height: 12),
        // Trust signal
        Row(
          mainAxisAlignment: isMobile ? MainAxisAlignment.center : MainAxisAlignment.start,
          children: [
            Icon(Icons.verified_user, size: 16, color: AppColors.accent),
            const SizedBox(width: 8),
            Text(
              "Used by students under active deadlines",
              style: AppText.label.copyWith(
                color: AppColors.accent.withAlpha(200),
                fontSize: 12,
                letterSpacing: 0.5,
              ),
            ),
          ],
        ),
        const SizedBox(height: 32),
        ElevatedButton.icon(
          onPressed: () => _navigateToBooking(context, title),
          icon: const Icon(Icons.arrow_forward, size: 18),
          label: Text(
            ctaText.toUpperCase(),
            style: AppText.button.copyWith(color: Colors.white, letterSpacing: 1.0),
          ),
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.accent,
            padding: const EdgeInsets.symmetric(horizontal: 36, vertical: 20),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            elevation: 10,
            shadowColor: AppColors.accent.withAlpha(100),
          ),
        ),
      ],
    );

    return Container(
      // Padding handled by Section, but internal spacing helps visual breathing room
      padding: const EdgeInsets.symmetric(vertical: 20), 
      child: isMobile
          ? Column(
              children: [
                imageSection,
                const SizedBox(height: 40),
                textSection,
              ],
            )
          : Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                if (imgLeft) ...[
                  imageSection,
                  const SizedBox(width: 80),
                ],
                Expanded(child: textSection),
                if (!imgLeft) ...[
                  const SizedBox(width: 80),
                  imageSection,
                ],
              ],
            ),
    );
  }
}