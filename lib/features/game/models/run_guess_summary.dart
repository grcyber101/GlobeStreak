import '../../../data/models/city.dart';

class RunGuessSummary {
  const RunGuessSummary({
    required this.target,
    required this.distanceKm,
    required this.success,
  });

  final City target;
  final double distanceKm;
  final bool success;
}
