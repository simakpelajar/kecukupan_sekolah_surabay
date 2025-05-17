import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:geolocator/geolocator.dart';
import 'package:provider/provider.dart';
import '../models/school.dart';
import '../models/district.dart';
import '../services/location_service.dart';
import '../widgets/map_controls.dart';
import '../theme/app_colors.dart';
import 'dart:convert';
import 'dart:math';

class MapScreen extends StatefulWidget {
  final List<School> schools;
  final List<District> districts;
  final Map<String, dynamic> userLocation;

  MapScreen({
    required this.schools,
    required this.districts,
    required this.userLocation,
  });

  @override
  _MapScreenState createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  final MapController _mapController = MapController();
  bool _showSchools = true;
  bool _showDistricts = true;
  bool _showFilterPanel = false;
  bool _showLegend = true; // Control the visibility of the legend
  late Map<String, dynamic> _userLocation;
  
  @override
  void initState() {
    super.initState();
    // Inisialisasi _userLocation dengan data dari widget.userLocation
    _userLocation = Map<String, dynamic>.from(widget.userLocation);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Map
          FlutterMap(
            mapController: _mapController,
            options: MapOptions(
              center: LatLng(-7.2575, 112.7521), // Surabaya center
              zoom: 12.0,
              maxZoom: 18.0,
              minZoom: 10.0,
            ),
            children: [
              // Base tile layer - using OpenStreetMap
              TileLayer(
                urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                userAgentPackageName: 'com.example.app',
              ),
              
              // Districts polygons
              if (_showDistricts) ...[
                PolygonLayer(polygons: _buildDistrictPolygons()),
                MarkerLayer(markers: _buildDistrictLabels()),
              ],

              // School markers
              if (_showSchools) MarkerLayer(markers: _buildSchoolMarkers()),              // User location marker
              MarkerLayer(
                markers: [
                  if (_userLocation.isNotEmpty && 
                      _userLocation['latitude'] != null && 
                      _userLocation['longitude'] != null)
                    Marker(
                      width: 36.0,
                      height: 36.0,
                      point: LatLng(
                        _userLocation['latitude'],
                        _userLocation['longitude'],
                      ),
                      builder: (ctx) => Container(
                        child: Icon(
                          Icons.my_location,
                          color: Colors.white,
                          size: 24,
                        ),                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              AppColors.locationIconColor, 
                              AppColors.locationIconColor.withOpacity(0.7)
                            ],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: AppColors.locationIconColor.withOpacity(0.5),
                              spreadRadius: 2,
                              blurRadius: 8,
                              offset: Offset(0, 3),
                            ),
                          ],
                        ),
                      ),
                    ),
                ],
              ),
            ],
          ),
          // Map Controls
          MapControls(
            showFilterPanel: _showFilterPanel,
            onFilterToggle: () {
              setState(() {
                _showFilterPanel = !_showFilterPanel;
              });
            },
            onSearchTap: () {
              Navigator.pushNamed(context, '/search');
            },
            showSchools: _showSchools,
            showDistricts: _showDistricts,
            showLegend: _showLegend,
            onShowSchoolsChanged: (value) {
              setState(() {
                _showSchools = value;
              });
            },
            onShowDistrictsChanged: (value) {
              setState(() {
                _showDistricts = value;
              });
            },
            onShowLegendChanged: (value) {
              setState(() {
                _showLegend = value;
              });
            },
          ),          // Legend
          if (_showLegend)
            Positioned(
              bottom: 20,
              right: 20,
              child: Container(
                padding: EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.95),
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.primaryColor.withOpacity(0.2),
                      blurRadius: 15,
                      spreadRadius: 1,
                      offset: Offset(0, 5),
                    ),
                  ],
                  border: Border.all(
                    color: AppColors.primaryColor.withOpacity(0.1),
                    width: 1.5,
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [                    Row(
                      children: [
                        Icon(
                          Icons.info,
                          color: AppColors.infoIconColor,
                          size: 18,
                        ),
                        SizedBox(width: 8),
                        Text(
                          'Legenda:',
                          style: TextStyle(
                            color: AppColors.textColor,
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 12),
                    _buildLegendItem(
                      color: AppColors.adequateColor,
                      label: 'Zona Mencukupi',
                    ),
                    SizedBox(height: 6),
                    _buildLegendItem(
                      color: AppColors.inadequateColor,
                      label: 'Zona Tidak Mencukupi',
                    ),                    SizedBox(height: 6),
                    _buildLegendItem(icon: Icons.school, color: AppColors.smaColor, label: 'SMA'),
                    SizedBox(height: 6),
                    _buildLegendItem(icon: Icons.engineering, color: AppColors.smkColor, label: 'SMK'),
                    SizedBox(height: 6),
                    _buildLegendItem(icon: Icons.menu_book, color: AppColors.maColor, label: 'MA'),
                    SizedBox(height: 6),
                    _buildLegendItem(
                      icon: Icons.my_location,
                      color: AppColors.locationIconColor,
                      label: 'Lokasi Anda',
                    ),
                  ],
                ),
              ),
            ),
          // Find My Location Button
          Positioned(
            bottom: 24,
            left: 0,
            right: 0,
            child: Center(
              child: ElevatedButton.icon(
                onPressed: _goToUserLocation,
                icon: Icon(Icons.my_location),
                label: Text('Lokasi Saya Sekarang'),                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.locationIconColor,
                  foregroundColor: Colors.white,
                  padding: EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 14,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                  elevation: 5,
                  shadowColor: AppColors.locationIconColor.withOpacity(0.5),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  List<Marker> _buildSchoolMarkers() {
    print('Building school markers. Total schools: ${widget.schools.length}');
    if (widget.schools.isEmpty) {
      print('WARNING: No schools data available!');
      return [];
    }

    // Print more detailed debug info
    if (widget.schools.isNotEmpty) {
      for (int i = 0; i < min(5, widget.schools.length); i++) {
        final school = widget.schools[i];
        print(
          'School $i: ${school.name}, coords: (${school.latitude}, ${school.longitude})',
        );

        // Check if coordinates are valid
        if (school.latitude == 0.0 || school.longitude == 0.0) {
          print('WARNING: Invalid coordinates for ${school.name}!');
        }
      }
    }

    return widget.schools
        .map((school) {
          // Skip markers with invalid coordinates
          if (school.latitude == 0 && school.longitude == 0) {
            print('Skipping marker for ${school.name} - invalid coordinates');
            return null;
          }

          return Marker(
            width: 48.0, // Larger size for better visibility
            height: 48.0,
            point: LatLng(school.latitude, school.longitude),
            builder: (ctx) => GestureDetector(
              onTap: () {
                _showSchoolInfo(school);
              },
              child: Container(                decoration: BoxDecoration(
                  color: AppColors.getSchoolLevelColor(school.level),
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.white, width: 2),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.3),
                      spreadRadius: 2,
                      blurRadius: 5,
                      offset: Offset(0, 2),
                    ),
                  ],
                ),
                child: Icon(
                  Icons.school,
                  color: Colors.white,
                  size: 28, // Larger icon
                ),
              ),
            ),
          );
        })
        .where((marker) => marker != null)
        .cast<Marker>()
        .toList();
  }

  List<Polygon> _buildDistrictPolygons() {
    print(
      'Building district polygons. Total districts: ${widget.districts.length}',
    );
    List<Polygon> polygons = [];

    int districtsWithCoordinates = 0;
    int totalPolygons = 0;

    for (var district in widget.districts) {
      // Skip districts without coordinate data
      if (district.coordinates.isEmpty) {
        print('District ${district.name} has no coordinates');
        continue;
      }

      districtsWithCoordinates++;
      print(
        'Processing district ${district.name} with ${district.coordinates.length} polygons',
      );

      // Process each polygon in the district
      for (var polygonCoords in district.coordinates) {
        List<LatLng> polygonPoints = [];

        // Convert coordinate points to LatLng objects
        for (var point in polygonCoords) {
          if (point.length >= 2) {
            // GeoJSON coordinates are in the format [longitude, latitude]
            // But LatLng needs (latitude, longitude)
            try {
              polygonPoints.add(LatLng(point[1], point[0]));
            } catch (e) {
              print('Error adding point: $e');
            }
          }
        }

        // Only add valid polygons with at least 3 points
        if (polygonPoints.length >= 3) {
          totalPolygons++;
          polygons.add(
            Polygon(
              points: polygonPoints,              color:
                  district.adequacy == 1
                      ? AppColors.adequateColor.withOpacity(0.3) // Adequate zones
                      : AppColors.inadequateColor.withOpacity(0.3), // Inadequate zones
              borderColor: Colors.black,
              borderStrokeWidth: 2.0, // Thick border for good visibility
              isFilled: true, // Ensure polygons are filled
            ),
          );
        } else {
          print(
            'Skipping invalid polygon for ${district.name}: not enough points (${polygonPoints.length})',
          );
        }
      }
    }

    print(
      'Districts with coordinates: $districtsWithCoordinates, Total polygons rendered: $totalPolygons',
    );
    return polygons;
  }
  
  List<Marker> _buildDistrictLabels() {
    List<Marker> labels = [];

    for (var district in widget.districts) {
      // Skip districts without coordinate data
      if (district.coordinates.isEmpty) {
        continue;
      }

      // For each district, calculate the center point for the label
      if (district.coordinates.isNotEmpty &&
          district.coordinates[0].isNotEmpty) {
        // Calculate center of the first polygon (if multiple exist)
        var polygonCoords = district.coordinates[0];

        // Simple calculation of center point by averaging all points
        double sumLat = 0.0;
        double sumLng = 0.0;
        int validPoints = 0;

        for (var point in polygonCoords) {
          if (point.length >= 2) {
            // GeoJSON coordinates are [longitude, latitude]
            sumLat += point[1];
            sumLng += point[0];
            validPoints++;
          }
        }

        if (validPoints > 0) {
          double centerLat = sumLat / validPoints;
          double centerLng = sumLng / validPoints;

          // Create a text marker for the district name
          labels.add(
            Marker(
              width: 100.0,
              height: 40.0,
              point: LatLng(centerLat, centerLng),
              builder: (ctx) => Container(
                alignment: Alignment.center,                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.85),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(
                    color: district.adequacy == 1 ? 
                      AppColors.adequateColor.withOpacity(0.7) : 
                      AppColors.inadequateColor.withOpacity(0.7), 
                    width: 1.5
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.15),
                      blurRadius: 4,
                      offset: Offset(0, 2),
                    ),
                  ],
                ),
                padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                child: Text(
                  district.name,
                  textAlign: TextAlign.center,                  style: TextStyle(
                    color: district.adequacy == 1 ? 
                      AppColors.adequateColor : 
                      AppColors.inadequateColor,
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                  ),
                ),
              ),
            ),
          );
        }
      }
    }

    return labels;
  }

  void _showSchoolInfo(School school) {
    showModalBottomSheet(
      context: context,      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) {
        return Container(
          padding: EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 50,
                    height: 50,
                    decoration: BoxDecoration(
                      color: AppColors.getSchoolLevelColor(school.level).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Center(
                      child: Icon(
                        school.level.contains('SMK') ? Icons.engineering :
                        school.level.contains('MA') ? Icons.menu_book : 
                        Icons.school,
                        color: AppColors.getSchoolLevelColor(school.level),
                        size: 28,
                      ),
                    ),
                  ),
                  SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          school.name,
                          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.textColor),
                        ),
                        SizedBox(height: 6),
                        Row(
                          children: [
                            Container(
                              padding: EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                              decoration: BoxDecoration(
                                color: AppColors.getSchoolLevelColor(school.level),
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Text(
                                school.level,
                                style: TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold),
                              ),
                            ),
                            SizedBox(width: 8),
                            Container(
                              padding: EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                              decoration: BoxDecoration(
                                color: AppColors.infoIconColor.withOpacity(0.8),
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Text(
                                "NPSN: ${school.npsn}",
                                style: TextStyle(color: Colors.white, fontSize: 12),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),              SizedBox(height: 20),
              Container(
                padding: EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.backgroundColor,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: AppColors.locationIconColor.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Icon(Icons.location_on, size: 16, color: AppColors.locationIconColor),
                        ),
                        SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            "Kecamatan ${school.district}",
                            style: TextStyle(
                              color: AppColors.textSecondaryColor,
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 12),
                    Row(
                      children: [
                        Container(
                          padding: EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: AppColors.peopleIconColor.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Icon(Icons.people, size: 16, color: AppColors.peopleIconColor),
                        ),
                        SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            "Jumlah Peserta: ${school.studentCount}",
                            style: TextStyle(
                              color: AppColors.textSecondaryColor,
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              SizedBox(height: 16),
              ElevatedButton(
                onPressed: () {
                  // Close the bottom sheet
                  Navigator.pop(context);
                },
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.close),
                    SizedBox(width: 8),
                    Text('Tutup'),
                  ],
                ),                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.getSchoolLevelColor(school.level),
                  foregroundColor: Colors.white,
                  minimumSize: Size(double.infinity, 50),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  elevation: 2,
                ),
              ),
            ],
          ),
        );
      },
    );
  }  void _goToUserLocation() async {
    try {
      // Selalu coba dapatkan lokasi baru ketika tombol ditekan
      final locationService = Provider.of<LocationService>(
        context,
        listen: false,
      );
      
      // Tampilkan indikator loading
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              SizedBox(
                height: 20, 
                width: 20, 
                child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white)
              ),
              SizedBox(width: 16),
              Text('Mencari lokasi Anda...'),
            ],
          ),
          duration: Duration(seconds: 2),
        ),
      );
      
      // Dapatkan lokasi saat ini
      final position = await locationService.getCurrentLocation();
      
      // Pindah peta ke lokasi pengguna
      _mapController.move(
        LatLng(position.latitude, position.longitude),
        15.0,
      );
      
      // Update state dengan menambahkan marker lokasi baru
      setState(() {
        // Update _userLocation dengan lokasi yang baru didapatkan
        _userLocation['latitude'] = position.latitude;
        _userLocation['longitude'] = position.longitude;
      });
      
      // Tampilkan konfirmasi
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Lokasi ditemukan: ${position.latitude.toStringAsFixed(4)}, ${position.longitude.toStringAsFixed(4)}'),
          backgroundColor: Color(0xFF06B6D4),
        ),
      );
    } catch (e) {
      // Tampilkan pesan error jika gagal mendapatkan lokasi
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Tidak dapat menemukan lokasi Anda: $e'),
          backgroundColor: Colors.red,
          duration: Duration(seconds: 4),
        ),
      );
    }
  }

  // Helper method to build legend items
  Widget _buildLegendItem({
    Color? color,
    IconData? icon,
    required String label,
  }) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 2),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (color != null)
            Container(
              width: 20,
              height: 20,
              decoration: BoxDecoration(
                color: color,
                border: Border.all(color: Colors.black, width: 1.5),
                borderRadius: BorderRadius.circular(4),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black12,
                    blurRadius: 2,
                    offset: Offset(0, 1),
                  ),
                ],
              ),
            ),
          if (icon != null)
            Container(
              width: 20,
              height: 20,
              decoration: BoxDecoration(
                color: color,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black12,
                    blurRadius: 2,
                    offset: Offset(0, 1),
                  ),
                ],
              ),
              child: Icon(icon, color: Colors.white, size: 14),
            ),
          SizedBox(width: 10),
          Text(
            label,
            style: TextStyle(
              color: Colors.black87,
              fontSize: 13,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}
