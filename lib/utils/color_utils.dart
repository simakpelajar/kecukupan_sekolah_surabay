import 'package:flutter/material.dart';

class ColorUtils {
  static Color getAdequacyColor(int adequacy) {
    return adequacy == 1 ? Color(0xFF2563EB) : Color(0xFFDC2626);
  }
  
  static Color getAdequacyColorWithOpacity(int adequacy, double opacity) {
    return adequacy == 1 
        ? Color(0xFF2563EB).withOpacity(opacity) 
        : Color(0xFFDC2626).withOpacity(opacity);
  }
  
  static LinearGradient getHeaderGradient() {
    return LinearGradient(
      colors: [Color(0xFF22D3EE), Color(0xFF3B82F6)],
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
    );
  }
}