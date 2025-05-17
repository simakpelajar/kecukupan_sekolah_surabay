import 'package:flutter/material.dart';

class AppColors {
  // Primary brand colors
  static const Color primaryColor = Color(0xFF3E64FF);  // Royal Blue
  static const Color secondaryColor = Color(0xFF5EDFFF); // Cyan
  static const Color accentColor = Color(0xFFFFBD69);   // Light Orange
  
  // Semantic colors
  static const Color adequateColor = Color(0xFF00B894);  // Mint Green
  static const Color inadequateColor = Color(0xFFFF7675); // Coral Red
  static const Color warningColor = Color(0xFFFFD166);   // Warning Yellow
  
  // Background colors
  static const Color backgroundColor = Color(0xFFF5F7FC); // Light blue-gray background
  static const Color cardColor = Colors.white;
  static const Color darkCardColor = Color(0xFF30336B); // Deep Blue Purple
  
  // Text colors
  static const Color textColor = Color(0xFF2C3E50);      // Dark blue-gray text
  static const Color textSecondaryColor = Color(0xFF7F8C8D); // Medium gray text
  static const Color lightTextColor = Colors.white;
  
  // School level colors (for badges and icons)
  static const Color smaColor = Color(0xFF3498DB);    // Blue for SMA
  static const Color smkColor = Color(0xFF9B59B6);    // Purple for SMK
  static const Color maColor = Color(0xFF2ECC71);     // Green for MA
  
  // Icon colors
  static const Color locationIconColor = Color(0xFF3E64FF);  // Location/Map icons
  static const Color schoolIconColor = Color(0xFFFF7675);    // School icons
  static const Color infoIconColor = Color(0xFF00B894);      // Info icons
  static const Color peopleIconColor = Color(0xFFFFA62B);    // People/Student icons
  static const Color statsIconColor = Color(0xFF5EDFFF);     // Stats icons
  
  // Gradients
  static const LinearGradient primaryGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [
      Color(0xFF3E64FF),
      Color(0xFF5EDFFF),
    ],
  );
  
  static const LinearGradient adequateGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [
      Color(0xFF00B894),
      Color(0xFF55EFC4),
    ],
  );
  
  static const LinearGradient inadequateGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [
      Color(0xFFFF7675),
      Color(0xFFFF9FF3),
    ],
  );
  
  // Helper method to get color based on school level
  static Color getSchoolLevelColor(String level) {
    if (level.contains('SMA')) return smaColor;
    if (level.contains('SMK')) return smkColor;
    if (level.contains('MA')) return maColor;
    return primaryColor;
  }
}
