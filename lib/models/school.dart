class School {
  final int id;
  final String name;
  final String district; // kecamatan
  final String level; // jenjang
  final double latitude;
  final double longitude;
  final int studentCount; // jumlah_peserta
  final String npsn;

  School({
    required this.id,
    required this.name,
    required this.district,
    required this.level,
    required this.latitude,
    required this.longitude,
    required this.studentCount,
    required this.npsn,
  });
  factory School.fromJson(Map<String, dynamic> json) {
    double lat = 0.0;
    double lng = 0.0;

    try {
      var latValue = json['latitude'];
      var lngValue = json['longitude'];
      
      if (latValue != null) {
        lat = latValue is double ? latValue : double.tryParse(latValue.toString()) ?? 0.0;
      }
      
      if (lngValue != null) {
        lng = lngValue is double ? lngValue : double.tryParse(lngValue.toString()) ?? 0.0;
      }
    } catch (e) {
      print('Error parsing coordinates for ${json['nama_sekolah']}: $e');
    }
    
    return School(
      id: json['id'] ?? 0,
      name: json['nama_sekolah'] ?? 'Unknown School',
      district: json['kecamatan'] ?? 'Unknown District',
      level: json['jenjang'] ?? 'Unknown Level',
      latitude: lat,
      longitude: lng,
      studentCount: json['jumlah_peserta'] ?? 0,
      npsn: json['NPSN'] ?? '',
    );
  }
}