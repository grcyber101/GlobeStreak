import 'dart:convert';

import 'package:flutter/services.dart';

import '../models/globe_geometry.dart';

class GlobeGeometryRepository {
  const GlobeGeometryRepository({
    AssetBundle? assetBundle,
    this.assetPath = 'assets/maps/natural_earth_110m.json',
  }) : _assetBundle = assetBundle;

  final AssetBundle? _assetBundle;
  final String assetPath;

  Future<GlobeGeometry> loadGeometry() async {
    final bundle = _assetBundle ?? rootBundle;
    final raw = await bundle.loadString(assetPath);
    return GlobeGeometry.fromJson(jsonDecode(raw) as Map<String, dynamic>);
  }
}
