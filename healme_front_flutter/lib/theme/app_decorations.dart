import 'package:flutter/material.dart';
import 'app_colors.dart';

class AppDecorations {
  // Glass cards matching ion-card
  static BoxDecoration get glassCard => BoxDecoration(
    color: AppColors.glass,
    borderRadius: BorderRadius.circular(12),
    border: Border.all(
      color: Colors.white.withOpacity(0.05),
      width: 1,
    ),
  );
  
  static BoxDecoration get glassCardHover => BoxDecoration(
    color: AppColors.glass,
    borderRadius: BorderRadius.circular(12),
    border: Border.all(
      color: Colors.white.withOpacity(0.1),
      width: 1,
    ),
    boxShadow: [
      BoxShadow(
        color: Colors.black.withOpacity(0.2),
        blurRadius: 20,
        offset: Offset(0, 10),
      ),
    ],
  );
  
  // App bar background
  static BoxDecoration get appBar => BoxDecoration(
    color: AppColors.glass,
    border: Border(
      bottom: BorderSide(
        color: Colors.white.withOpacity(0.05),
        width: 1,
      ),
    ),
  );
  
  // Search bar
  static BoxDecoration get searchBar => BoxDecoration(
    color: AppColors.glass,
    borderRadius: BorderRadius.circular(8),
    border: Border.all(
      color: Colors.white.withOpacity(0.05),
      width: 1,
    ),
  );
  
  static BoxDecoration get searchBarFocused => BoxDecoration(
    color: AppColors.glass,
    borderRadius: BorderRadius.circular(8),
    border: Border.all(
      color: Colors.white.withOpacity(0.1),
      width: 1,
    ),
    boxShadow: [
      BoxShadow(
        color: AppColors.tertiary.withOpacity(0.2),
        blurRadius: 0,
        spreadRadius: 2,
      ),
    ],
  );
  
  // Navigation item
  static BoxDecoration get navItem => BoxDecoration(
    borderRadius: BorderRadius.circular(8),
    color: Colors.transparent,
  );
  
  static BoxDecoration get navItemActive => BoxDecoration(
    borderRadius: BorderRadius.circular(8),
    color: AppColors.highlight,
  );
  
  // Nav indicator (the left border gradient)
  static BoxDecoration get navIndicator => BoxDecoration(
    gradient: AppColors.navGradient,
  );
}