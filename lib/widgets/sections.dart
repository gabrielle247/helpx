import 'package:flutter/material.dart';
import 'package:help_x_web/core/all_constants.dart';

class Section extends StatelessWidget {
  final Widget child;
  final bool constrained;
  final bool fullWidth; // Add this if you ever need a background to stretch
  final Color? backgroundColor;

  const Section({
    super.key,
    required this.child,
    this.constrained = true,
    this.fullWidth = false,
    this.backgroundColor,
  });

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final isMobile = width < Layout.mobileLimit;

    Widget content = Padding(
      padding: EdgeInsets.symmetric(
        vertical: Layout.sectionGap,
        horizontal: isMobile
            ? Layout.pagePaddingMobile
            : Layout.pagePaddingDesktop,
      ),
      child: Center(
        child: constrained
            ? ConstrainedBox(
                constraints: const BoxConstraints(
                  maxWidth: Layout.contentMaxWidth,
                ),
                child: child,
              )
            : child,
      ),
    );

    if (fullWidth || backgroundColor != null) {
      return Container(
        color: backgroundColor,
        width: double.infinity,
        child: content,
      );
    }

    return content;
  }
}