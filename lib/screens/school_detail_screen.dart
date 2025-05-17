import 'package:flutter/material.dart';
import '../models/school.dart';
import '../theme/app_colors.dart';
import '../widgets/status_badge.dart';
import 'map_screen.dart';

class SchoolDetailScreen extends StatelessWidget {
  final School school;

  const SchoolDetailScreen({
    Key? key, 
    required this.school,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Detail Sekolah'),
        backgroundColor: AppColors.primaryColor,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [            // School Header
            Container(
              padding: EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    AppColors.getSchoolLevelColor(school.level),
                    AppColors.getSchoolLevelColor(school.level).withOpacity(0.7),
                  ],
                ),
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.getSchoolLevelColor(school.level).withOpacity(0.2),
                    blurRadius: 15,
                    offset: Offset(0, 5),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [                  Text(
                    school.name,
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  SizedBox(height: 8),
                  Row(
                    children: [
                      LevelBadge(
                        level: school.level,
                        fontSize: 13,
                      ),
                      SizedBox(width: 8),
                      InfoBadge(
                        text: "NPSN: ${school.npsn}",
                        fontSize: 13,
                      ),
                    ],
                  ),
                ],
              ),
            ),
            
            SizedBox(height: 24),
              // School Information
            Text(
              'Informasi Sekolah',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: AppColors.textColor,
              ),
            ),
            SizedBox(height: 12),
            _buildInfoCard(
              icon: Icons.location_on,
              title: 'Alamat',
              content: "Kecamatan ${school.district}",
            ),
            SizedBox(height: 8),
            _buildInfoCard(
              icon: Icons.people,
              title: 'Jumlah Peserta Didik',
              content: "${school.studentCount}",
            ),
            SizedBox(height: 8),
            _buildInfoCard(
              icon: Icons.map,
              title: 'Koordinat Lokasi',
              content: "Latitude: ${school.latitude}\nLongitude: ${school.longitude}",
            ),
            SizedBox(height: 24),            // View on Map Button
            SizedBox(height: 24),
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => MapScreen(
                      schools: [school],
                      districts: [],
                      userLocation: {
                        'latitude': school.latitude,
                        'longitude': school.longitude,
                        'focusSchool': school.id,
                        'isSchool': true, // Flag untuk membedakan lokasi sekolah dan lokasi pengguna
                      },
                    ),
                  ),
                );
              },
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.map),
                  SizedBox(width: 8),
                  Text('Lihat Lokasi di Peta'),
                ],
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primaryColor,
                foregroundColor: Colors.white,
                padding: EdgeInsets.symmetric(vertical: 16),
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
            
            // Back Button
            SizedBox(height: 12),
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.arrow_back, size: 16, color: AppColors.textSecondaryColor),
                  SizedBox(width: 8),
                  Text('Kembali', style: TextStyle(color: AppColors.textSecondaryColor)),
                ],
              ),
              style: TextButton.styleFrom(
                padding: EdgeInsets.symmetric(vertical: 12),
              ),
            ),
          ],
        ),
      ),
    );
  }
    Widget _buildInfoCard({
    required IconData icon,
    required String title,
    required String content,
  }) {
    return Container(
      padding: EdgeInsets.all(16),
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
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: AppColors.primaryColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: AppColors.primaryColor, size: 24),
          ),
          SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textColor,
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  content,
                  style: TextStyle(color: AppColors.textSecondaryColor),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
