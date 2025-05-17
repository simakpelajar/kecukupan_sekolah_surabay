import 'package:flutter/material.dart';
import '../models/district.dart';
import '../models/school.dart';
import '../widgets/school_item.dart';
import '../widgets/status_badge.dart';
import '../theme/app_colors.dart';

class DistrictDetailScreen extends StatefulWidget {
  final District district;
  final List<School> schools;

  const DistrictDetailScreen({
    Key? key,
    required this.district,
    required this.schools,
  }) : super(key: key);

  @override
  _DistrictDetailScreenState createState() => _DistrictDetailScreenState();
}

class _DistrictDetailScreenState extends State<DistrictDetailScreen> {
  late List<School> _schoolsInDistrict;

  @override
  void initState() {
    super.initState();
    _schoolsInDistrict =
        widget.schools
            .where(
              (school) =>
                  school.district.toLowerCase() ==
                  widget.district.name.toLowerCase(),
            )
            .toList();
  }

  @override
  Widget build(BuildContext context) {
    final bool isAdequate = widget.district.adequacy == 1;

    return Scaffold(
      appBar: AppBar(
        title: Text('Detail Kecamatan'),
        backgroundColor: AppColors.primaryColor,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [            // District Header
            Container(
              padding: EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: isAdequate ? 
                    [AppColors.adequateColor, AppColors.adequateColor.withOpacity(0.7)] : 
                    [AppColors.inadequateColor, AppColors.inadequateColor.withOpacity(0.7)],
                ),
                borderRadius: BorderRadius.circular(18),
                boxShadow: [
                  BoxShadow(
                    color: (isAdequate ? AppColors.adequateColor : AppColors.inadequateColor).withOpacity(0.2),
                    blurRadius: 15,
                    offset: Offset(0, 5),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          widget.district.name,
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      StatusBadge(
                        isAdequate: isAdequate,
                        fontSize: 13,
                      ),
                    ],
                  ),
                  SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: _buildInfoCard(
                          label: 'Jumlah Sekolah',
                          value: _schoolsInDistrict.length.toString(),
                        ),
                      ),
                      SizedBox(width: 8),
                      Expanded(
                        child: _buildInfoCard(
                          label: 'Jumlah Penduduk',
                          value: '${widget.district.population}',
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 8),
                  Row(
                    children: [
                      Expanded(
                        child: _buildInfoCard(
                          label: 'Daya Tampung Siswa',
                          value: widget.district.schoolStudentCapacity.toStringAsFixed(0),
                        ),
                      ),
                      SizedBox(width: 8),
                      Expanded(
                        child: _buildInfoCard(
                          label: 'Status Kecukupan',
                          value: isAdequate ? 'Mencukupi' : 'Tidak Mencukupi',
                          valueColor: isAdequate ? Colors.green : Colors.red,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            SizedBox(height: 24),            // Schools in District
            Text(
              'Sekolah di Kecamatan Ini',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: AppColors.textColor,
              ),
            ),
            SizedBox(height: 12),            if (_schoolsInDistrict.isEmpty)
              Center(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Text(
                    'Tidak ada data sekolah di kecamatan ini',
                    style: TextStyle(color: AppColors.textSecondaryColor),
                  ),
                ),
              )
            else
              Column(
                children:
                    _schoolsInDistrict
                        .map(
                          (school) => SchoolItem(
                            school: school,
                            onTap: () {
                              _showSchoolDetails(context, school);
                            },
                          ),
                        )
                        .toList(),
              ),
          ],
        ),
      ),
    );
  }  Widget _buildInfoCard({
    required String label,
    required String value,
    Color? valueColor,
  }) {
    // Assign different colors based on the label
    Color cardColor;
    IconData cardIcon;
    
    if (label.contains('Sekolah')) {
      cardColor = AppColors.schoolIconColor;
      cardIcon = Icons.school;
    } else if (label.contains('Penduduk')) {
      cardColor = AppColors.peopleIconColor;
      cardIcon = Icons.people;
    } else if (label.contains('Daya Tampung')) {
      cardColor = AppColors.statsIconColor;
      cardIcon = Icons.query_stats;
    } else if (label.contains('Status')) {
      cardColor = valueColor ?? AppColors.infoIconColor;
      cardIcon = value.contains('Mencukupi') ? Icons.check_circle : Icons.cancel;
    } else {
      cardColor = AppColors.infoIconColor;
      cardIcon = Icons.info;
    }
    
    return Container(
      padding: EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 5,
            offset: Offset(0, 3),
          ),
        ],
        border: Border.all(
          color: cardColor.withOpacity(0.1),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: cardColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  cardIcon, 
                  size: 14, 
                  color: cardColor
                ),
              ),
              SizedBox(width: 8),
              Text(
                label, 
                style: TextStyle(
                  color: AppColors.textSecondaryColor, 
                  fontSize: 12
                )
              ),
            ],
          ),
          SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(
              color: valueColor ?? AppColors.textColor,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
  void _showSchoolDetails(BuildContext context, School school) {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.backgroundColor,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) {
        return Container(
          padding: EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                school.name,
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textColor,
                ),
              ),
              SizedBox(height: 8),
              Row(
                children: [
                  LevelBadge(
                    level: school.level,
                  ),
                  SizedBox(width: 8),
                  InfoBadge(
                    text: "NPSN: ${school.npsn}",
                  ),
                ],
              ),              SizedBox(height: 16),
              Container(
                padding: EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppColors.cardColor,
                  borderRadius: BorderRadius.circular(8),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 4,
                      offset: Offset(0, 2),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    _buildInfoRow(
                      icon: Icons.location_on,
                      text: "Kecamatan ${school.district}",
                    ),
                    SizedBox(height: 10),
                    _buildInfoRow(
                      icon: Icons.people,
                      text: "Jumlah Peserta: ${school.studentCount}",
                    ),
                    SizedBox(height: 10),
                    _buildInfoRow(
                      icon: Icons.map,
                      text: "Koordinat: ${school.latitude}, ${school.longitude}",
                    ),
                  ],
                ),
              ),
              SizedBox(height: 16),
              ElevatedButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.close),
                    SizedBox(width: 8),
                    Text('Tutup'),
                  ],
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primaryColor,
                  foregroundColor: Colors.white,
                  minimumSize: Size(double.infinity, 48),
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );  }
    Widget _buildInfoRow({
    required IconData icon,
    required String text,
  }) {
    Color iconColor;
    
    // Choose different colors for different icons
    if (icon == Icons.location_on) {
      iconColor = AppColors.locationIconColor;
    } else if (icon == Icons.people) {
      iconColor = AppColors.peopleIconColor;
    } else if (icon == Icons.map) {
      iconColor = AppColors.infoIconColor;
    } else {
      iconColor = AppColors.primaryColor;
    }
    
    return Row(
      children: [
        Container(
          padding: EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: iconColor.withOpacity(0.1),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, size: 18, color: iconColor),
        ),
        SizedBox(width: 14),
        Expanded(
          child: Text(
            text,
            style: TextStyle(
              color: AppColors.textSecondaryColor,
              fontSize: 14,
            ),
          ),
        ),
      ],
    );
  }
}
