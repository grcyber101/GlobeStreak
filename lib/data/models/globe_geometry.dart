import 'country_boundary.dart';
import 'geo_point.dart';

class GlobeGeometry {
  const GlobeGeometry({
    required this.source,
    required this.landRings,
    required this.borderLines,
    required this.countries,
  });

  final String source;
  final List<List<GeoPoint>> landRings;
  final List<List<GeoPoint>> borderLines;
  final List<CountryBoundary> countries;

  factory GlobeGeometry.fromJson(Map<String, dynamic> json) {
    return GlobeGeometry(
      source: json['source'] as String? ?? 'Unknown',
      landRings: _parseLines(json['land'] as List<dynamic>),
      borderLines: _parseLines(json['borders'] as List<dynamic>),
      countries: (json['countries'] as List<dynamic>? ?? const [])
          .map((country) =>
              CountryBoundary.fromJson(country as Map<String, dynamic>))
          .toList(growable: false),
    );
  }

  static List<List<GeoPoint>> _parseLines(List<dynamic> lines) {
    return lines
        .map(
          (line) => (line as List<dynamic>)
              .map((point) => GeoPoint.fromJson(point as List<dynamic>))
              .toList(growable: false),
        )
        .toList(growable: false);
  }
}
