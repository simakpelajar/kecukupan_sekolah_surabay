class UserLocation {
  final double latitude;
  final double longitude;
  final String district;
  final int adequacy;
  final int schoolCount;
  final double ratio;

  UserLocation({
    required this.latitude,
    required this.longitude,
    required this.district,
    required this.adequacy,
    required this.schoolCount,
    required this.ratio,
  });
}