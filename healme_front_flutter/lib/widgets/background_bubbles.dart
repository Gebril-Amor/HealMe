import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import '../theme/app_colors.dart';

class BackgroundBubbles extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: Container(
        width: double.infinity,
        height: double.infinity,
        color: AppColors.background,
        child: Stack(
          children: [
            // Bubble 1 - Pink (exact CSS positions)
            Positioned(
              top: -100,
              left: -100,
              child: Container(
                width: 300,
                height: 300,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppColors.primary,
                ),
              ).blur(40).opacity(0.15),
            ),
            // Bubble 2 - Blue
            Positioned(
              bottom: -150,
              right: -100,
              child: Container(
                width: 400,
                height: 400,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppColors.secondary,
                ),
              ).blur(40).opacity(0.15),
            ),
            // Bubble 3 - Purple
            Positioned(
              top: MediaQuery.of(context).size.height * 0.5,
              left: MediaQuery.of(context).size.width * 0.3,
              child: Container(
                width: 200,
                height: 200,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppColors.tertiary,
                ),
              ).blur(40).opacity(0.15),
            ),
          ],
        ),
      ),
    );
  }
}

extension BlurExtension on Widget {
  Widget blur(double radius) {
    return ImageFiltered(
      imageFilter: ui.ImageFilter.blur(sigmaX: radius, sigmaY: radius),
      child: this,
    );
  }
  
  Widget opacity(double opacity) {
    return Opacity(opacity: opacity, child: this);
  }
}