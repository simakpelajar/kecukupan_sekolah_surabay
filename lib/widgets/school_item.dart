import 'package:flutter/material.dart';
import '../models/school.dart';
import '../theme/app_colors.dart';
import '../widgets/status_badge.dart';

class SchoolItem extends StatelessWidget {
  final School school;
  final VoidCallback onTap;

  const SchoolItem({
    Key? key,
    required this.school,
    required this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final Color levelColor = AppColors.getSchoolLevelColor(school.level);
    
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: AppColors.cardColor,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: onTap,
          child: Padding(
            padding: EdgeInsets.symmetric(vertical: 14, horizontal: 14),
            child: Row(
              children: [
                Container(
                  width: 35,
                  height: 35,
                  decoration: BoxDecoration(
                    color: levelColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Center(
                    child: Icon(
                      _getSchoolIcon(school.level),
                      color: levelColor,
                      size: 18,
                    ),
                  ),
                ),
                SizedBox(width: 6),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        school.name,
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: AppColors.textColor,
                          fontSize: 16,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      SizedBox(height: 4),
                      Row(
                        children: [
                          Icon(
                            Icons.location_on,
                            color: AppColors.textSecondaryColor,
                            size: 10,
                          ),
                          SizedBox(width: 2),
                          Text(
                            "Kecamatan ${school.district}",
                            style: TextStyle(
                              color: AppColors.textSecondaryColor,
                              fontSize: 12,
                            ),
                          ),
                          SizedBox(width: 8),
                          Icon(
                            Icons.people,
                            color: AppColors.textSecondaryColor,
                            size: 12,
                          ),
                          SizedBox(width: 2),
                          Text(
                            "${school.studentCount}",
                            style: TextStyle(
                              color: AppColors.textSecondaryColor,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                SizedBox(width: 8),
                LevelBadge(level: school.level),
              ],
            ),
          ),
        ),
      ),
    );
  }
  
  IconData _getSchoolIcon(String level) {
    if (level.contains('SMA')) return Icons.school;
    if (level.contains('SMK')) return Icons.engineering;
    if (level.contains('MA')) return Icons.menu_book;
    return Icons.school;
  }
}
