import 'dart:math' as math;

import 'package:flutter/material.dart';

double degToRad(double degrees) => degrees * math.pi / 180.0;
double radToDeg(double radians) => radians * 180.0 / math.pi;
double normalizeLng(double lng) => ((lng + 540) % 360) - 180;

double haversineKm(double lat1, double lon1, double lat2, double lon2) {
  const earthRadiusKm = 6371.0;
  final dLat = degToRad(lat2 - lat1);
  final dLon = degToRad(lon2 - lon1);
  final a = math.sin(dLat / 2) * math.sin(dLat / 2) +
      math.cos(degToRad(lat1)) *
          math.cos(degToRad(lat2)) *
          math.sin(dLon / 2) *
          math.sin(dLon / 2);
  return earthRadiusKm * 2 * math.atan2(math.sqrt(a), math.sqrt(1 - a));
}

Offset? latLngToScreen(
  double lat,
  double lng,
  Size size,
  double centerLat,
  double centerLng, {
  Offset? customCenter,
  double radiusScale = 0.5,
}) {
  final radius = math.min(size.width, size.height) * radiusScale;
  final center = customCenter ?? Offset(size.width / 2, size.height / 2);
  final phi = degToRad(lat);
  final lambda = degToRad(normalizeLng(lng - centerLng));
  final phi0 = degToRad(centerLat);
  final cosc = math.sin(phi0) * math.sin(phi) +
      math.cos(phi0) * math.cos(phi) * math.cos(lambda);
  if (cosc < 0) return null;
  final x = radius * math.cos(phi) * math.sin(lambda);
  final y = -radius *
      (math.cos(phi0) * math.sin(phi) -
          math.sin(phi0) * math.cos(phi) * math.cos(lambda));
  return Offset(center.dx + x, center.dy + y);
}

(double, double)? screenToLatLng(
  Offset point,
  Size size,
  double centerLat,
  double centerLng, {
  double radiusScale = 0.46,
}) {
  final radius = math.min(size.width, size.height) * radiusScale;
  final center = Offset(size.width / 2, size.height / 2);
  final x = (point.dx - center.dx) / radius;
  final y = -(point.dy - center.dy) / radius;
  final rho = math.sqrt(x * x + y * y);
  if (rho > 1) return null;
  final cc = math.asin(rho);
  final phi0 = degToRad(centerLat);
  final lat = rho == 0
      ? phi0
      : math.asin(
          math.cos(cc) * math.sin(phi0) +
              (y * math.sin(cc) * math.cos(phi0) / rho),
        );
  final lng = degToRad(centerLng) +
      math.atan2(
        x * math.sin(cc),
        rho * math.cos(phi0) * math.cos(cc) - y * math.sin(phi0) * math.sin(cc),
      );
  return (
    radToDeg(lat).clamp(-90.0, 90.0).toDouble(),
    normalizeLng(radToDeg(lng)),
  );
}
