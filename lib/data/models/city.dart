class City {
  const City({
    required this.name,
    required this.country,
    required this.latitude,
    required this.longitude,
    required this.population,
    required this.difficulty,
    this.region,
  });

  final String name;
  final String country;
  final double latitude;
  final double longitude;
  final int population;
  final int difficulty;
  final String? region;

  String get displayName {
    final region = this.region;
    if (region == null || region.isEmpty) return '$name, $country';
    return '$name, $region, $country';
  }
}
