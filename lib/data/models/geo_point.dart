class GeoPoint {
  const GeoPoint({
    required this.latitude,
    required this.longitude,
  });

  final double latitude;
  final double longitude;

  factory GeoPoint.fromJson(List<dynamic> json) {
    return GeoPoint(
      latitude: (json[0] as num).toDouble(),
      longitude: (json[1] as num).toDouble(),
    );
  }
}
