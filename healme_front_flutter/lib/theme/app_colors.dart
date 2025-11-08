import 'package:flutter/material.dart';

class AppColors {
  // Exact colors from your CSS
  static const primary = Color(0xFFFF64FF);
  static const secondary = Color(0xFF64C8FF);
  static const tertiary = Color(0xFFB450DC);
  static const quadra = Color.fromARGB(255, 252, 178, 67); // rgba(255, 252, 178, 0.67)
  // Text colors
  static const text = Color.fromARGB(255, 255, 255, 255); // rgba(255, 255, 255, 0.85)
  static const textSecondary = Color.fromARGB(255, 255, 255, 255); // rgba(255, 255, 255, 0.6)
  
  // Background & Glass
  static const background = Color(0xFF0A0A12);
  static const glass = Color(0x33141428); // rgba(20, 20, 40, 0.2)
  static const highlight = Color(0x4DFFFFFF); // rgba(255, 255, 255, 0.3)
  
  // Gradients matching your CSS
  static const primaryGradient = LinearGradient(
    colors: [primary, tertiary],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
  
  static const textGradient = LinearGradient(
    colors: [text, textSecondary],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
  
  static const navGradient = LinearGradient(
    colors: [primary, secondary],
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
  );
}