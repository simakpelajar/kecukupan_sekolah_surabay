import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/data_service.dart';
import '../services/location_service.dart';
import '../models/school.dart';
import '../models/district.dart';
import 'map_screen.dart';
import 'search_screen.dart';
import 'districts_list_screen.dart';
import 'district_detail_screen.dart';
import 'school_detail_screen.dart';
import '../widgets/school_item.dart';
import '../widgets/district_item.dart';
import 'dart:math';
import '../theme/app_colors.dart';

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;
  List<School> _schools = [];
  List<District> _districts = [];
  Map<String, dynamic> _userLocation = {};
  bool _isLoading = true;
  // Using AppColors from our theme instead of local colors
  // These local references are just for convenience
  Color get primaryColor => AppColors.primaryColor;
  Color get secondaryColor => AppColors.secondaryColor;
  Color get accentColor => AppColors.accentColor;
  Color get backgroundColor => AppColors.backgroundColor;
  Color get cardColor => AppColors.cardColor;
  Color get textColor => AppColors.textColor;
  Color get textSecondaryColor => AppColors.textSecondaryColor;

  // Improved method to find the district containing the user's location
  // Uses point-in-polygon algorithm for more accurate detection
  District? findNearestDistrict(
    double lat,
    double lng,
    List<District> districts,
  ) {
    if (districts.isEmpty) return null;

    // First, try to find if the point is inside any district polygon
    for (var district in districts) {
      if (district.coordinates.isEmpty) continue;

      // Check each polygon in the district
      for (var polygon in district.coordinates) {
        if (isPointInPolygon(lat, lng, polygon)) {
          print('Found user in district: ${district.name}');
          return district;
        }
      }
    }

    // If no containing polygon found, fall back to nearest center calculation
    print('No containing polygon found, using nearest center method');
    District? nearest;
    double minDistance = double.infinity;

    for (var district in districts) {
      if (district.coordinates.isNotEmpty &&
          district.coordinates[0].isNotEmpty) {
        // Get the "center" of the first polygon as a reference point
        double avgLat = 0;
        double avgLng = 0;
        final points = district.coordinates[0];

        for (var point in points) {
          if (point.length >= 2) {
            avgLat += point[1]; // Latitude is second element
            avgLng += point[0]; // Longitude is first element
          }
        }

        if (points.isNotEmpty) {
          avgLat /= points.length;
          avgLng /= points.length;

          // Calculate distance (using Haversine formula for more accuracy)
          double distance = calculateHaversineDistance(
            lat,
            lng,
            avgLat,
            avgLng,
          );

          if (distance < minDistance) {
            minDistance = distance;
            nearest = district;
          }
        }
      }
    }

    if (nearest != null) {
      print(
        'Found nearest district: ${nearest.name} at distance: ${minDistance.toStringAsFixed(2)} km',
      );
    }

    return nearest ??
        districts[0]; // Return the nearest or the first if no valid coordinates
  }

  // Check if point is inside polygon using ray casting algorithm
  bool isPointInPolygon(double lat, double lng, List<List<double>> polygon) {
    bool isInside = false;
    int i, j = polygon.length - 1;

    for (i = 0; i < polygon.length; i++) {
      // GeoJSON coordinates are [longitude, latitude]
      double polyLatI = polygon[i][1];
      double polyLngI = polygon[i][0];
      double polyLatJ = polygon[j][1];
      double polyLngJ = polygon[j][0];

      if (((polyLatI > lat) != (polyLatJ > lat)) &&
          (lng <
              (polyLngJ - polyLngI) * (lat - polyLatI) / (polyLatJ - polyLatI) +
                  polyLngI)) {
        isInside = !isInside;
      }

      j = i;
    }

    return isInside;
  }

  // Calculate distance between two points using Haversine formula (in kilometers)
  double calculateHaversineDistance(
    double lat1,
    double lon1,
    double lat2,
    double lon2,
  ) {
    const double earthRadius = 6371; // in kilometers

    double dLat = _toRadians(lat2 - lat1);
    double dLon = _toRadians(lon2 - lon1);

    double a =
        sin(dLat / 2) * sin(dLat / 2) +
        cos(_toRadians(lat1)) *
            cos(_toRadians(lat2)) *
            sin(dLon / 2) *
            sin(dLon / 2);

    double c = 2 * atan2(sqrt(a), sqrt(1 - a));
    return earthRadius * c;
  }

  double _toRadians(double degree) {
    return degree * (pi / 180);
  }

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    final dataService = Provider.of<DataService>(context, listen: false);
    final locationService = Provider.of<LocationService>(
      context,
      listen: false,
    );

    try {
      print('======== MEMULAI LOADING DATA ========');
      print('Memuat data sekolah...');
      final schools = await dataService.getSchools();
      print('Jumlah sekolah dimuat: ${schools.length}');

      if (schools.isNotEmpty) {
        print(
          'Contoh data sekolah pertama: ${schools[0].name}, ${schools[0].district}, (${schools[0].latitude}, ${schools[0].longitude})',
        );
      }

      print('Memuat data kecamatan...');
      final districts = await dataService.getDistricts();
      print('Jumlah kecamatan dimuat: ${districts.length}');
      if (districts.isEmpty) {
        print('PERINGATAN: Tidak ada data kecamatan yang ditemukan!');
      } else {
        // Tunjukkan contoh data kecamatan untuk debugging
        print('Contoh data kecamatan pertama:');
        print('  Nama: ${districts[0].name}');
        print('  Status Kecukupan (adequacy): ${districts[0].adequacy}');
        print(
          '  Jumlah dalam data (schoolStudentCapacity): ${districts[0].schoolStudentCapacity}',
        );
        print('  Rasio: ${districts[0].ratio}');
      }

      // Get user location
      print('Meminta izin lokasi...');
      await locationService.requestLocationPermission();
      print('Mendapatkan lokasi pengguna...');
      final position = await locationService.getCurrentLocation();
      print(
        'Lokasi pengguna: ${position.latitude}, ${position.longitude}',
      ); // Find the nearest district to the user's location
      District? userDistrict = findNearestDistrict(
        position.latitude,
        position.longitude,
        districts,
      );

      if (userDistrict == null) {
        print('Tidak bisa menemukan kecamatan untuk lokasi pengguna!');
        setState(() {
          _schools = schools;
          _districts = districts;
          _isLoading = false;
        });
        return;
      }
      print(
        'Kecamatan pengguna: ${userDistrict.name}, Adequacy: ${userDistrict.adequacy}',
      );

      // Jumlah sekolah sebenarnya (field schoolStudentCapacity di model District tampaknya berisi jumlah peserta didik)
      // Hitung perkiraan jumlah sekolah berdasarkan data yang masuk akal
      int schoolStudentCapacity;

      // Menghitung jumlah sekolah SMA di kecamatan tersebut dari dataset sekolah
      List<School> schoolsInDistrict =
          schools
              .where(
                (school) =>
                    school.district.toLowerCase() ==
                    userDistrict.name.toLowerCase(),
              )
              .toList();

      // Jika ditemukan di dataset, gunakan jumlah tersebut
      if (schoolsInDistrict.isNotEmpty) {
        schoolStudentCapacity = schoolsInDistrict.length;
        print(
          'Jumlah sekolah di ${userDistrict.name} dari dataset: $schoolStudentCapacity',
        );
      } else {
        // Jika tidak ditemukan, buat estimasi yang masuk akal
        // Di Surabaya biasanya hanya beberapa sekolah per kecamatan
        schoolStudentCapacity =
            3 +
            (userDistrict.adequacy == 1 ? 2 : 0); // 3-5 sekolah per kecamatan
        print(
          'Menggunakan estimasi jumlah sekolah untuk ${userDistrict.name}: $schoolStudentCapacity',
        );
      }
      setState(() {
        _schools = schools;
        _districts = districts;
        _userLocation = {
          'latitude': position.latitude,
          'longitude': position.longitude,
          'district': userDistrict.name,
          'adequacy': userDistrict.adequacy,
          'schoolStudentCapacity': schoolStudentCapacity,
          'status':
              userDistrict.adequacy == 1 ? 'Mencukupi' : 'Tidak Mencukupi',
        };
        _isLoading = false;
      });
      print('======== DATA BERHASIL DIMUAT ========');
    } catch (e) {
      print('ERROR LOADING DATA: $e');
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final List<Widget> _widgetOptions = <Widget>[
      _buildHomeTab(),
      MapScreen(
        schools: _schools,
        districts: _districts,
        userLocation: _userLocation,
      ),
    ];

    return Scaffold(
      backgroundColor: backgroundColor,
      body:
          _isLoading
              ? Center(child: CircularProgressIndicator(color: primaryColor))
              : _widgetOptions.elementAt(_selectedIndex),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 20,
              offset: Offset(0, -5),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(20),
            topRight: Radius.circular(20),
          ),
          child: BottomNavigationBar(
            items: <BottomNavigationBarItem>[
              BottomNavigationBarItem(
                icon: Container(
                  padding: EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    color:
                        _selectedIndex == 0
                            ? AppColors.primaryColor.withOpacity(0.1)
                            : Colors.transparent,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(Icons.home),
                ),
                label: 'Beranda',
              ),
              BottomNavigationBarItem(
                icon: Container(
                  padding: EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    color:
                        _selectedIndex == 1
                            ? AppColors.locationIconColor.withOpacity(0.1)
                            : Colors.transparent,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(Icons.map),
                ),
                label: 'Peta',
              ),
            ],
            currentIndex: _selectedIndex,
            selectedItemColor: AppColors.primaryColor,
            unselectedItemColor: AppColors.textSecondaryColor,
            backgroundColor: AppColors.cardColor,
            elevation: 0,
            onTap: (index) {
              setState(() {
                _selectedIndex = index;
              });
            },
          ),
        ),
      ),
    );
  }

  Widget _buildHomeTab() {
    return SafeArea(
      child: SingleChildScrollView(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(height: 20), // Header
            Container(
              padding: EdgeInsets.all(16),
              decoration: BoxDecoration(
                gradient: AppColors.primaryGradient,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Icon(
                          Icons.school,
                          color: Colors.white,
                          size: 28,
                        ),
                      ),
                      SizedBox(width: 12),
                      Text(
                        'SMA Surabaya',
                        style: TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 8),
                  Text(
                    'Visualisasi Kecukupan Sekolah Menengah',
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.9),
                      fontSize: 16,
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: 24),

            // User Location Card
            if (_userLocation.isNotEmpty) _buildUserLocationCard(),
            SizedBox(height: 24),

            // Dashboard Statistics
            _buildDashboardStats(),
            SizedBox(height: 24),

            // Districts List
            _buildDistrictsList(),
            SizedBox(height: 24),

            // Schools List
            _buildSchoolsList(),
          ],
        ),
      ),
    );
  }

  Widget _buildDashboardStats() {
    // Hitung jumlah kecamatan yang mencukupi dan tidak mencukupi
    int adequateDistricts = 0;
    int inadequateDistricts = 0;
    int totalSMAStudents = 0;
    int totalSMKStudents = 0;

    for (var district in _districts) {
      if (district.adequacy == 1) {
        adequateDistricts++;
      } else {
        inadequateDistricts++;
      }
    }

    // Hitung jumlah siswa berdasarkan jenjang (SMA/SMK)
    for (var school in _schools) {
      if (school.level.contains('SMA') || school.level.contains('MA')) {
        totalSMAStudents += school.studentCount;
      } else if (school.level.contains('SMK')) {
        totalSMKStudents += school.studentCount;
      }
    }

    return Container(
      padding: EdgeInsets.all(20),
      decoration: BoxDecoration(
         color: AppColors.cardColor, 
        gradient: LinearGradient(
        colors: [Colors.white, AppColors.darkCardColor.withOpacity(0.03)],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ), 
        // gradient: LinearGradient(
        //   colors: [
        //       //Color(0xFFF3F4F6),
        //     AppColors.primaryColor.withOpacity(0.03),
        //     AppColors.secondaryColor.withOpacity(0.05),
        //   ],
        //   begin: Alignment.topLeft,
        //   end: Alignment.bottomRight,
        // ),
        // color: AppColors.cardColor,
        // borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: //Colors.black.withOpacity(0.05),
            AppColors.darkCardColor.withOpacity(0.1),
           // AppColors.primaryColor.withOpacity(0.1),
            blurRadius: 15,
            offset: Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Dashboard Statistik',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: textColor,
            ),
          ),
          SizedBox(height: 20),

          // Status Kecukupan
          Row(
            children: [
              Expanded(child: _buildDashboardCard(
                icon: Icons.check_circle,
                iconColor: AppColors.adequateColor,
                title: 'Mencukupi',
                value: '$adequateDistricts',
                subtitle: 'Kecamatan',
              ), 
              ),
              SizedBox(width: 12),
              Expanded(child: _buildDashboardCard(
                icon: Icons.cancel,
                iconColor: AppColors.inadequateColor,
                title: 'Tidak Mencukupi',
                value: '$inadequateDistricts',
                subtitle: 'Kecamatan',
              ), 
              ),
            ],
          ),
          SizedBox(height: 12),

          // Statistik Siswa
          Row(
            children: [
              Expanded(child: _buildDashboardCard(
                icon: Icons.school,
                iconColor: primaryColor,
                title: 'SMA/MA',
                value: '${totalSMAStudents.toString()}',
                subtitle: 'Siswa',
                ), 
              ),
              SizedBox(width: 12),
              Expanded(
                child: _buildDashboardCard(
                icon: Icons.engineering,
                iconColor: Color(0xFF6366F1),
                title: 'SMK',
                value: '${totalSMKStudents.toString()}',
                subtitle: 'Siswa',
                ), 
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildDashboardCard({
    required IconData icon,
    required Color iconColor,
    required String title,
    required String value,
    required String subtitle,
  }) {
    return Container(
        padding: EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.cardColor,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: iconColor.withOpacity(0.1),
              blurRadius: 8,
              offset: Offset(0, 3),
            ),
          ],
          border: Border.all(color: iconColor.withOpacity(0.1)),
        ),
        child: Row(
          children: [
            Container(
              padding: EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: iconColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Icon(icon, color: iconColor, size: 24),
            ),
            SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(color: textSecondaryColor, fontSize: 12),
                  ),
                  Text(
                    value,
                    style: TextStyle(
                      color: textColor,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    subtitle,
                    style: TextStyle(color: textSecondaryColor, fontSize: 12),
                  ),
                ],
              ),
            ),
          ],
        ),
    );
  }

  Widget _buildUserLocationCard() {
    // Simplified status display - only showing one status
    bool isAdequate = _userLocation['adequacy'] == 1;

    return Container(
      padding: EdgeInsets.all(20),
      decoration: BoxDecoration(
         color: AppColors.cardColor, 
        gradient: LinearGradient(
        colors: [Colors.white, AppColors.darkCardColor.withOpacity(0.03)],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ),
        // gradient: LinearGradient(
        //   colors:
        //       isAdequate
        //           ? [
        //             AppColors.adequateColor.withOpacity(0.05),
        //             AppColors.adequateColor.withOpacity(0.1),
        //           ]
        //           : [
        //             AppColors.inadequateColor.withOpacity(0.05),
        //             AppColors.inadequateColor.withOpacity(0.1),
        //           ],
        //   begin: Alignment.topLeft,
        //   end: Alignment.bottomRight,
        // ),
        // color: AppColors.cardColor,
        // borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color:
                isAdequate
                    ? AppColors.adequateColor.withOpacity(0.1)
                    : AppColors.inadequateColor.withOpacity(0.1),
            blurRadius: 15,
            offset: Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppColors.locationIconColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(
                  Icons.location_on,
                  color: AppColors.locationIconColor,
                  size: 24,
                ),
              ),
              SizedBox(width: 8),
              Text(
                'Lokasi Anda',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: textColor,
                ),
              ),
            ],
          ),
          SizedBox(height: 16),

          // District name
          Text(
            'Kecamatan ${_userLocation['district'] ?? '-'}',
            style: TextStyle(
              color: textColor,
              fontSize: 16,
              fontWeight: FontWeight.w500,
            ),
            overflow: TextOverflow.ellipsis,
          ),
          SizedBox(height: 16),

          // Single status card with all info
          Container(
            padding: EdgeInsets.all(16),
            decoration: BoxDecoration(
              gradient:
                  _userLocation['adequacy'] == 1
                      ? AppColors.adequateGradient
                      : AppColors.inadequateGradient,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color:
                      _userLocation['adequacy'] == 1
                          ? AppColors.adequateColor.withOpacity(0.2)
                          : AppColors.inadequateColor.withOpacity(0.2),
                  blurRadius: 8,
                  offset: Offset(0, 3),
                ),
              ],
            ),
            child: Row(
              children: [
                Container(
                  padding: EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.3),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    _userLocation['adequacy'] == 1
                        ? Icons.check_circle
                        : Icons.warning_amber_rounded,
                    color: Colors.white,
                    size: 24,
                  ),
                ),
                SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(

                        _userLocation['adequacy'] == 1
                            ? 'Mencukupi'
                            : 'Tidak Mencukupi',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: 4),
                      Text(
                        'Jumlah Sekolah: ${_userLocation['schoolStudentCapacity'] != null && _userLocation['schoolStudentCapacity'] < 1000 ? _userLocation['schoolStudentCapacity'] : '-'}',
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.9),
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: 16),

          // Map button
          ElevatedButton(
            onPressed: () {
              setState(() {
                _selectedIndex = 1;
              });
            },
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.map,
                  color:
                      _userLocation['adequacy'] == 1
                          ? AppColors.adequateColor
                          : AppColors.inadequateColor,
                ),
                SizedBox(width: 8),
                Text(
                  'Lihat di Peta',
                  style: TextStyle(
                    color:
                        _userLocation['adequacy'] == 1
                            ? AppColors.adequateColor
                            : AppColors.inadequateColor,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.white,
              foregroundColor:
                  _userLocation['adequacy'] == 1
                      ? AppColors.adequateColor
                      : AppColors.inadequateColor,
              minimumSize: Size(double.infinity, 48),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              elevation: 0,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDistrictsList() {
    return Container(
      padding: EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.cardColor, 
        gradient: LinearGradient(
        colors: [Colors.white, AppColors.darkCardColor.withOpacity(0.03)],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ),
        // gradient: LinearGradient(
        //   colors: [Colors.white, AppColors.secondaryColor.withOpacity(0.03)],
        //   begin: Alignment.topLeft,
        //   end: Alignment.bottomRight,
        // ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: AppColors.darkCardColor.withOpacity(0.1),
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
              Text(
                'Kecamatan',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: textColor,
                ),
              ),
              TextButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder:
                          (context) => DistrictsListScreen(
                            districts: _districts,
                            schools: _schools,
                          ),
                    ),
                  );
                },
                style: TextButton.styleFrom(
                  backgroundColor: AppColors.primaryColor.withOpacity(0.1),
                  padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                ),
                child: Text(
                  'Lihat Semua',
                  style: TextStyle(
                    color: AppColors.primaryColor,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 12),
          Column(
            children:
                _districts.take(3).map((district) {
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 8.0),
                    child: DistrictItem(
                      district: district,
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder:
                                (context) => DistrictDetailScreen(
                                  district: district,
                                  schools: _schools,
                                ),
                          ),
                        );
                      },
                    ),
                  );
                }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildSchoolsList() {
    return Container(
      padding: EdgeInsets.all(0),
      decoration: BoxDecoration(
      color: AppColors.cardColor, 
      gradient: LinearGradient(
        colors: [Colors.white, AppColors.darkCardColor.withOpacity(0.03)],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        // gradient: LinearGradient(
        //   colors: [Colors.white, AppColors.accentColor.withOpacity(0.03)],
        //   begin: Alignment.topLeft,
        //   end: Alignment.bottomRight,
        ),// ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: AppColors.darkCardColor.withOpacity(0.1),
            blurRadius: 15,
            offset: Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: EdgeInsets.only(right: 20, left: 20, top: 20),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Sekolah',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: textColor,
                  ),
                ),
                TextButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => SearchScreen(schools: _schools),
                      ),
                    );
                  },
                  style: TextButton.styleFrom(
                    backgroundColor: AppColors.schoolIconColor.withOpacity(0.1),
                    padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                  ),
                  child: Text(
                    'Lihat Semua',
                    style: TextStyle(
                      color: AppColors.schoolIconColor,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: 12),
          Column(
            children:
                _schools.take(3).map((school) {
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 8.0),
                    child: SchoolItem(
                      school: school,
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder:
                                (context) => SchoolDetailScreen(school: school),
                          ),
                        );
                      },
                    ),
                  );
                }).toList(),
          ),
        ],
      ),
    );
  }
}
