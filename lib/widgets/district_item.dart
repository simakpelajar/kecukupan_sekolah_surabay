import 'package:flutter/material.dart';
import '../models/district.dart';
import '../theme/app_colors.dart';
import '../widgets/status_badge.dart';

class DistrictItem extends StatelessWidget {
  final District district;
  final VoidCallback onTap;

  const DistrictItem({
    Key? key,
    required this.district,
    required this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final bool isAdequate = district.adequacy == 1;
    
    return Container(
      margin: EdgeInsets.only(bottom: 12),
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
          onTap: onTap,
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: isAdequate ? 
                          AppColors.adequateColor.withOpacity(0.1) : 
                          AppColors.inadequateColor.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Center(
                        child: Icon(
                          Icons.location_city,
                          color: isAdequate ? 
                            AppColors.adequateColor : 
                            AppColors.inadequateColor,
                          size: 22,
                        ),
                      ),
                    ),
                    SizedBox(width: 12),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          district.name,
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: AppColors.textColor,
                            fontSize: 16,
                          ),
                        ),
                        SizedBox(height: 4),
                        Text(
                          'Rasio: ${district.ratio.toStringAsFixed(2)}',
                          style: TextStyle(
                            color: AppColors.textSecondaryColor,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                 StatusBadge(isAdequate: isAdequate),
              ],
            ),
          ),
        ),
      ),
    );
  }
}