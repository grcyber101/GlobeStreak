import '../../data/models/country_boundary.dart';
import '../../data/models/geo_point.dart';

class CountryLookupService {
  const CountryLookupService(this._countries);

  final List<CountryBoundary> _countries;

  String? countryFor({required double latitude, required double longitude}) {
    for (final country in _countries) {
      if (_contains(country, latitude, longitude)) {
        return normalizeCountryName(country.name);
      }
    }
    return null;
  }

  bool isSameCountry({
    required double latitude,
    required double longitude,
    required String targetCountry,
  }) {
    final guessedCountry = countryFor(latitude: latitude, longitude: longitude);
    return guessedCountry == normalizeCountryName(targetCountry);
  }

  static String normalizeCountryName(String country) {
    return switch (country.trim().toLowerCase()) {
      'united states of america' => 'united states',
      'russian federation' => 'russia',
      'republic of korea' => 'south korea',
      'korea, republic of' => 'south korea',
      _ => country.trim().toLowerCase(),
    };
  }

  bool _contains(CountryBoundary country, double latitude, double longitude) {
    for (final polygon in country.polygons) {
      if (polygon.isEmpty) continue;

      final outerRing = polygon.first;
      if (!_ringContains(outerRing, latitude, longitude)) continue;

      final inHole = polygon
          .skip(1)
          .any((hole) => _ringContains(hole, latitude, longitude));
      if (!inHole) return true;
    }

    return false;
  }

  bool _ringContains(List<GeoPoint> ring, double latitude, double longitude) {
    if (ring.length < 3) return false;

    var inside = false;
    var previous = ring.last;
    final crossesAntimeridian = _crossesAntimeridian(ring);
    final testLongitude =
        crossesAntimeridian && longitude < 0 ? longitude + 360 : longitude;

    for (final current in ring) {
      final currentLng = _unwrapLongitude(
        current.longitude,
        crossesAntimeridian: crossesAntimeridian,
      );
      final previousLng = _unwrapLongitude(
        previous.longitude,
        crossesAntimeridian: crossesAntimeridian,
      );
      final currentLat = current.latitude;
      final previousLat = previous.latitude;

      final crossesLatitude =
          (currentLat > latitude) != (previousLat > latitude);
      if (crossesLatitude) {
        final intersectLng = (previousLng - currentLng) *
                (latitude - currentLat) /
                (previousLat - currentLat) +
            currentLng;
        if (testLongitude < intersectLng) {
          inside = !inside;
        }
      }

      previous = current;
    }

    return inside;
  }

  bool _crossesAntimeridian(List<GeoPoint> ring) {
    var minLongitude = 180.0;
    var maxLongitude = -180.0;

    for (final point in ring) {
      if (point.longitude < minLongitude) minLongitude = point.longitude;
      if (point.longitude > maxLongitude) maxLongitude = point.longitude;
    }

    return maxLongitude - minLongitude > 180;
  }

  double _unwrapLongitude(
    double longitude, {
    required bool crossesAntimeridian,
  }) {
    if (!crossesAntimeridian || longitude >= 0) return longitude;
    return longitude + 360;
  }
}
