import 'package:flutter/material.dart';

class AppColors {
  // Primary Colors
  static const Color primaryPurple = Color(0xFF6C5CE7);
  static const Color lightPurple = Color(0xFFA29BFE);
  static const Color darkPurple = Color(0xFF5F3DC4);

  // Success/Error/Warning
  static const Color successGreen = Color(0xFF00B894);
  static const Color errorRed = Color(0xFFD63031);
  static const Color warningYellow = Color(0xFFFDCB6E);

  // Backgrounds
  static const Color backgroundColor = Color(0xFFF5F6FA);
  static const Color cardBackground = Colors.white;

  // Text
  static const Color textPrimary = Color(0xFF2D3436);
  static const Color textSecondary = Color(0xFF636E72);
  static const Color textLight = Color(0xFFB2BEC3);

  // Gradients
  static const LinearGradient primaryGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [primaryPurple, lightPurple],
  );

  static const LinearGradient successGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [successGreen, Color(0xFF55EFC4)],
  );
}