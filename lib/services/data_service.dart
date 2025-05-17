import 'dart:convert';
import 'dart:async';
import 'dart:math';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import '../models/school.dart';
import '../models/district.dart';

class DataService {  // Using only local JSON files instead of API
  final String apiBaseUrl = '';  // Empty since we're not using an API
  bool _isOnline = false;

  Future<bool> checkOnlineStatus() async {
    try {
      final response = await http.get(Uri.parse('https://www.google.com'))
          .timeout(const Duration(seconds: 3));
      _isOnline = response.statusCode == 200;
      return _isOnline;
    } catch (e) {
      _isOnline = false;
      return false;
    }
  }  Future<List<School>> getSchools() async {
    try {
      print('Menggunakan data lokal untuk schools');
      // Always use local data - skip API check
      final String response = await rootBundle.loadString('assets/data/sekolah.json');
      print('Berhasil membaca file JSON sekolah');
      
      final data = await json.decode(response);
      print('Berhasil mengkonversi JSON: ${data.length} items');
      
      List<School> schools = [];
      for (var item in data) {
        try {
          School school = School.fromJson(item);
          schools.add(school);
          print('Sekolah: ${school.name}, Lat: ${school.latitude}, Lng: ${school.longitude}');
        } catch (e) {
          print('Error processing school: ${item['nama']} - $e');
        }
      }
      
      print('Data sekolah lokal berhasil dimuat: ${schools.length} sekolah');
      return schools;
    } catch (e) {
      print('Fatal error loading schools: $e');
      // Return empty list instead of throwing exception to prevent app crash
      return [];
    }
  }  Future<List<District>> getDistricts() async {
    try {
      print('Menggunakan data lokal untuk kecamatan');
      // Always use local data - skip API check
      
      // Load district data
      final String districtResponse = await rootBundle.loadString('assets/data/kecukupan.json');
      final List<dynamic> districtData = await json.decode(districtResponse);
      print('Data kecukupan berhasil dimuat: ${districtData.length} entries');
      
      // Load GeoJSON data for coordinates
      final String geojsonResponse = await rootBundle.loadString('assets/data/kecamatan_surabaya.geojson');
      print('GeoJSON berhasil dimuat: ${geojsonResponse.length} characters');
      final geoJsonData = parseGeoJson(geojsonResponse);
      print('GeoJSON berhasil diparsing, featureCount: ${geoJsonData['features']?.length ?? 0}');
        // Create districts with coordinates
      List<District> districts = [];
      for (var item in districtData) {
        try {
          var district = District.fromJson(item);
          // Try to find matching geometry in GeoJSON
          if (geoJsonData.isNotEmpty) {
            List<List<List<double>>> coordinates = extractCoordinatesFromGeoJson(geoJsonData, district.name);
            districts.add(District(
              name: district.name,
              population: district.population,
              adequacy: district.adequacy,
              schoolStudentCapacity: district.schoolStudentCapacity,
              ratio: district.ratio,
              coordinates: coordinates,
            ));
          } else {
            districts.add(district);
          }
        } catch (e) {
          print('Error processing district: ${item['kecamatan']} - $e');
        }
      }
      
      return districts;
    } catch (e) {
      print('Error loading districts: $e');
      throw Exception('Failed to load districts: $e');
    }
  }
    // Helper method to extract coordinates from GeoJSON for a specific district
  List<List<List<double>>> extractCoordinatesFromGeoJson(Map<String, dynamic> geoJson, String districtName) {
    List<List<List<double>>> result = [];
    
    try {
      if (geoJson.containsKey('features')) {
        final features = geoJson['features'] as List;
        
        for (var feature in features) {
          String featureName = '';
          
          // Get the district name from properties - check for the kecamatan field
          if (feature['properties'] != null) {
            var properties = feature['properties'];
            featureName = properties['kecamatan']?.toString() ?? 
                          properties['name']?.toString() ?? 
                          properties['NAME']?.toString() ?? 
                          properties['Name']?.toString() ?? 
                          properties['NAMOBJ']?.toString() ?? 
                          '';
          }
          
          // Print for debugging
          print('Comparing: $featureName with $districtName');
          
          // Check if this feature is for the district we're looking for
          if (featureName.toLowerCase() == districtName.toLowerCase() &&
              feature['geometry'] != null) {
            
            var geometry = feature['geometry'];
            String geometryType = geometry['type']?.toString() ?? '';
            
            if (geometryType == 'Polygon' && geometry['coordinates'] is List) {
              var coordinates = geometry['coordinates'] as List;
              for (var ring in coordinates) {
                if (ring is List) {
                  List<List<double>> polygonPoints = [];
                  for (var point in ring) {
                    if (point is List && point.length >= 2) {
                      try {
                        polygonPoints.add([
                          double.parse(point[0].toString()),
                          double.parse(point[1].toString())
                        ]);
                      } catch (e) {
                        print('Error parsing point: $point - $e');
                      }
                    }
                  }
                  if (polygonPoints.isNotEmpty) {
                    result.add(polygonPoints);
                  }
                }
              }
            } else if (geometryType == 'MultiPolygon' && geometry['coordinates'] is List) {
              var multiPolygon = geometry['coordinates'] as List;
              for (var polygon in multiPolygon) {
                if (polygon is List) {
                  for (var ring in polygon) {
                    if (ring is List) {
                      List<List<double>> polygonPoints = [];                      for (var point in ring) {
                        if (point is List && point.length >= 2) {
                          try {
                            polygonPoints.add([
                              double.parse(point[0].toString()),
                              double.parse(point[1].toString())
                            ]);
                          } catch (e) {
                            print('Error parsing multipolygon point: $point - $e');
                          }
                        }
                      }
                      if (polygonPoints.isNotEmpty) {
                        result.add(polygonPoints);
                      }
                    }
                  }
                }
              }
            }
          }
        }
      }
      
      if (result.isEmpty) {
        print('No matching coordinates found for district: $districtName');
      } else {
        print('Found ${result.length} polygon rings for district: $districtName');
      }
    } catch (e) {
      print('Error extracting coordinates for $districtName: $e');
    }
    
    return result;
  }  Future<String> getGeoJson() async {
    try {
      // Always use local data - skip API check
      final String geoJsonData = await rootBundle.loadString('assets/data/kecamatan_surabaya.geojson');
      print('GeoJSON loaded, size: ${geoJsonData.length} bytes');
      return geoJsonData;
    } catch (e) {
      print('Failed to load GeoJSON: $e');
      return '{"type":"FeatureCollection","features":[]}'; // Return empty GeoJSON
    }
  }
  // Enhanced parse GeoJSON method
  Map<String, dynamic> parseGeoJson(String jsonStr) {
    try {
      final decoded = json.decode(jsonStr);
      if (decoded is Map<String, dynamic>) {
        return decoded;
      } else {
        print('GeoJSON is not a valid Map<String, dynamic>');
        return {};
      }
    } catch (e) {
      print('Failed to parse GeoJSON: $e');
      return {};
    }
  }
}