class District {
  final String name;
  final int population;
  final int adequacy;
  final int schoolStudentCapacity;
  final double ratio;
  final List<List<List<double>>> coordinates;

  District({
    required this.name,
    required this.population,
    required this.adequacy,
    required this.schoolStudentCapacity,
    required this.ratio,
    required this.coordinates,
  });
  factory District.fromJson(Map<String, dynamic> json) {
    try {
      return District(
        name: json['kecamatan'] ?? '',
        population: json['penduduk_16_18'] ?? 0,
        adequacy: json['status_value'] ?? 0,
        schoolStudentCapacity: json['total_peserta'] ?? 0,
        ratio: (json['persen_kecukupan'] is num) 
            ? (json['persen_kecukupan'] as num).toDouble() 
            : 0.0,
        coordinates: [],
      );
    } catch (e) {
      print('Error creating District from JSON: $e - $json');
      return District(
        name: json['kecamatan'] ?? 'Unknown',
        population: 0,
        adequacy: 0,
        schoolStudentCapacity: 0,
        ratio: 0,
        coordinates: [],
      );
    }
  }

  static List<List<List<double>>> _parseCoordinates(List<dynamic> coords) {
    return coords.map<List<List<double>>>((polygon) {
      return polygon.map<List<double>>((point) {
        return [point[0].toDouble(), point[1].toDouble()];
      }).toList();
    }).toList();
  }
}