import 'package:flutter/material.dart';
import '../theme/app_colors.dart';

class StatusBadge extends StatelessWidget {
  final bool isAdequate;
  final double fontSize;
  final FontWeight fontWeight;
  
  const StatusBadge({
    Key? key,
    required this.isAdequate,
    this.fontSize = 12,
    this.fontWeight = FontWeight.bold,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      constraints: BoxConstraints(
        minWidth: 140, 
        minHeight: 36,
      ),
      decoration: BoxDecoration(
        gradient: isAdequate ? AppColors.adequateGradient : AppColors.inadequateGradient,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: (isAdequate ? AppColors.adequateColor : AppColors.inadequateColor).withOpacity(0.3),
            blurRadius: 4,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            isAdequate ? Icons.check_circle : Icons.cancel_outlined,
            color: Colors.white,
            size: fontSize + 4,
          ),
          SizedBox(width: 4),
          Text(
            isAdequate ? 'Mencukupi' : 'Tidak Mencukupi',
            style: TextStyle(
              color: Colors.white,
              fontSize: fontSize,
              fontWeight: fontWeight,
            ),
          ),
        ],
      ),
    );
  }
}

// Badge for school level (SD, SMP, SMA)
class LevelBadge extends StatelessWidget {
  final String level;
  final double fontSize;
  
  const LevelBadge({
    Key? key,
    required this.level,
    this.fontSize = 12,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final Color badgeColor = AppColors.getSchoolLevelColor(level);

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: badgeColor,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: badgeColor.withOpacity(0.3),
            blurRadius: 4,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.school,
            color: Colors.white,
            size: fontSize + 2,
          ),
          SizedBox(width: 4),
          Text(
            level,
            style: TextStyle(
              color: Colors.white,
              fontSize: fontSize,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}

// Badge for NPSN or other info
class InfoBadge extends StatelessWidget {
  final String text;
  final double fontSize;
  final IconData? icon;
  
  const InfoBadge({
    Key? key,
    required this.text,
    this.fontSize = 12,
    this.icon,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: AppColors.textSecondaryColor,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: AppColors.textSecondaryColor.withOpacity(0.2),
            blurRadius: 4,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Icon(
              icon,
              color: Colors.white,
              size: fontSize + 2,
            ),
            SizedBox(width: 4),
          ],
          Text(
            text,
            style: TextStyle(
              color: Colors.white,
              fontSize: fontSize,
            ),
          ),
        ],
      ),
    );
  }
}

