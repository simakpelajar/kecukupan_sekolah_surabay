import 'dart:convert';
import 'dart:math';
import 'package:http/http.dart' as http;
import 'package:latlong2/latlong.dart';

class OSMRoutingService {
  // OpenRouteService API key
  // Get one at: https://openrouteservice.org/dev/#/signup
  static const String apiKey = '5b3ce3597851110001cf6248aa8b50b7105544e0b07aa4e4589ec0f0';
    // API endpoint for OpenRouteService directions
  static const String baseUrl = 'https://api.openrouteservice.org/v2/directions/';
  
  // Mode of transportation: driving-car, foot-walking, cycling-regular
  static const String profile = 'driving-car';

  /// Gets a route between two points following roads using OpenRouteService API
  static Future<List<LatLng>> getRoute(LatLng start, LatLng destination) async {
    print('OSMRoutingService.getRoute called from ${start.latitude},${start.longitude} to ${destination.latitude},${destination.longitude}');
    try {
      // OpenRouteService expects coordinates in [longitude,latitude] format
      final Uri uri = Uri.parse('$baseUrl$profile');
      
      print('Sending request to OpenRouteService API');
      
      // Prepare the request headers - Fix: Authorization header should use 'Authorization: Bearer <TOKEN>'
      final Map<String, String> headers = {
        'Authorization': 'Bearer $apiKey',
        'Content-Type': 'application/json; charset=utf-8',
        'Accept': 'application/json, application/geo+json, application/gpx+xml'
      };
      
      // Prepare the request body
      final Map<String, dynamic> body = {
        'coordinates': [
          [start.longitude, start.latitude],
          [destination.longitude, destination.latitude]
        ]
      };

      print('Request body: ${json.encode(body)}');
      
      // Make the POST request
      final response = await http.post(
        uri,
        headers: headers,
        body: json.encode(body)
      );
        if (response.statusCode == 200) {
        final data = json.decode(response.body);
        print('OpenRouteService API response received: ${response.body.substring(0, min(200, response.body.length))}...');
        
        if (data['features'] != null && 
            data['features'].isNotEmpty && 
            data['features'][0]['geometry'] != null &&
            data['features'][0]['geometry']['coordinates'] != null) {
          // Extract the route coordinates
          List<dynamic> coordinates = data['features'][0]['geometry']['coordinates'];
          List<LatLng> routePoints = [];
          
          // Convert coordinates to LatLng objects
          for (var coord in coordinates) {
            // OpenRouteService returns [longitude, latitude]
            if (coord is List && coord.length >= 2 && 
                coord[0] is num && coord[1] is num) {
              routePoints.add(LatLng(coord[1].toDouble(), coord[0].toDouble()));
            } else {
              print('Invalid coordinate format: $coord');
            }
          }
          
          print('Decoded ${routePoints.length} points from the route');
          if (routePoints.isNotEmpty) {
            // Debug first and last few coordinates
            print('First 3 points: ${routePoints.take(3).join(', ')}');
            print('Last 3 points: ${routePoints.reversed.take(3).toList().join(', ')}');
            return routePoints;
          } else {
            print('No valid route points found in response');
            return _getSimulatedRoute(start, destination);
          }
        } else {
          print('Invalid response format from API');
          print('Response structure: ${data.keys.join(', ')}');
          if (data.containsKey('error')) {
            print('Error message: ${data['error']}');
          }
          return _getSimulatedRoute(start, destination);
        }
      } else {
        print('Failed to get route: ${response.statusCode}');
        print('Error response: ${response.body}');
        return _getSimulatedRoute(start, destination);
      }
    } catch (e) {
      print('Error getting route: $e');
      return _getSimulatedRoute(start, destination);
    }
  }

  /// Creates a simulated route that follows main roads pattern
  /// This is used as a fallback when the API fails
  static List<LatLng> _getSimulatedRoute(LatLng start, LatLng destination) {
    print('Using simulated OSM-style route as fallback');
    List<LatLng> points = [];
    points.add(start);
    
    // For Surabaya's grid-like road network, we'll use a more realistic path simulation
    
    // Create intermediate waypoints that follow a grid pattern (like city streets)
    double startLat = start.latitude;
    double startLng = start.longitude;
    double endLat = destination.latitude;
    double endLng = destination.longitude;
      // Create a more detailed simulated route path that looks realistic
    // First travel mostly east/west
    double midLng = startLng + (endLng - startLng) * 0.6;
    
    int horizontalSteps = 10; // More detailed route
    double horizontalStepSize = (midLng - startLng) / horizontalSteps;
    for (int i = 1; i <= horizontalSteps; i++) {
      // Add some small variations to simulate actual roads
      double jitter = (Random().nextDouble() - 0.5) * 0.0003;
      points.add(LatLng(startLat + jitter, startLng + i * horizontalStepSize));
    }
    
    // Then travel north/south
    int verticalSteps = 10; // More detailed route
    double verticalStepSize = (endLat - startLat) / verticalSteps;
    for (int i = 1; i <= verticalSteps; i++) {
      double jitter = (Random().nextDouble() - 0.5) * 0.0003;
      points.add(LatLng(startLat + i * verticalStepSize, midLng + jitter));
    }
    
    // Finally travel remaining east/west distance
    int finalSteps = 8; // More detailed route
    double finalStepSize = (endLng - midLng) / finalSteps;
    for (int i = 1; i <= finalSteps; i++) {
      double jitter = (Random().nextDouble() - 0.5) * 0.0003;
      points.add(LatLng(endLat + jitter, midLng + i * finalStepSize));
    }
    
    // Add more realistic road-like pattern with slight curves
    for (int i = 1; i < points.length - 1; i++) {
      // Add slight random variations to make the route look more realistic
      if (Random().nextDouble() > 0.7) { // 30% chance to add a slight curve
        double curveJitterLat = (Random().nextDouble() - 0.5) * 0.0008;
        double curveJitterLng = (Random().nextDouble() - 0.5) * 0.0008;
        
        // Add a point slightly off the direct path
        points.insert(i, LatLng(
          (points[i-1].latitude + points[i].latitude) / 2 + curveJitterLat,
          (points[i-1].longitude + points[i].longitude) / 2 + curveJitterLng
        ));
      }
    }
    
    points.add(destination);
    
    return points;
  }
}
