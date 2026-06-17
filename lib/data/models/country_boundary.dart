import 'geo_point.dart';

class CountryBoundary {
  const CountryBoundary({
    required this.name,
    required this.polygons,
  });

  final String name;
  final List<List<List<GeoPoint>>> polygons;

  factory CountryBoundary.fromJson(Map<String, dynamic> json) {
    return CountryBoundary(
      name: json['name'] as String? ?? 'Unknown',
      polygons: (json['polygons'] as List<dynamic>)
          .map(
            (polygon) => (polygon as List<dynamic>)
                .map(
                  (ring) => (ring as List<dynamic>)
                      .map((point) => GeoPoint.fromJson(point as List<dynamic>))
                      .toList(growable: false),
                )
                .toList(growable: false),
          )
          .toList(growable: false),
    );
  }
}
