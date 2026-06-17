import 'dart:math' as math;

import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';

import '../../../core/theme/geo_streak_colors.dart';
import '../../../core/utils/geo_math.dart';
import '../../../data/models/geo_point.dart';
import '../../../data/models/globe_geometry.dart';
import '../models/guess.dart';

class GlobeGuessWidget extends StatefulWidget {
  const GlobeGuessWidget({
    super.key,
    required this.geometry,
    required this.onGuessSelected,
    required this.enabled,
    this.pendingGuess,
    this.lastGuess,
  });

  final GlobeGeometry geometry;
  final void Function(double lat, double lng) onGuessSelected;
  final bool enabled;
  final GeoPoint? pendingGuess;
  final Guess? lastGuess;

  @override
  State<GlobeGuessWidget> createState() => _GlobeGuessWidgetState();
}

class _GlobeGuessWidgetState extends State<GlobeGuessWidget>
    with SingleTickerProviderStateMixin {
  static const double _minZoom = 0.75;
  static const double _maxZoom = 5;
  static const double _maxSegmentDegrees = 2;

  double centerLng = 0;
  double centerLat = 10;
  double zoom = 1;
  double _scaleStartZoom = 1;
  late final AnimationController _guessAnimationController;
  late final Animation<double> _guessAnimation;
  late _GlobeRenderGeometry _renderGeometry;

  @override
  void initState() {
    super.initState();
    _guessAnimationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2200),
    );
    _guessAnimation = CurvedAnimation(
      parent: _guessAnimationController,
      curve: Curves.easeOutCubic,
    );
    _renderGeometry = _GlobeRenderGeometry.fromGeometry(
      widget.geometry,
      maxSegmentDegrees: _maxSegmentDegrees,
    );
  }

  @override
  void didUpdateWidget(covariant GlobeGuessWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.geometry != oldWidget.geometry) {
      _renderGeometry = _GlobeRenderGeometry.fromGeometry(
        widget.geometry,
        maxSegmentDegrees: _maxSegmentDegrees,
      );
    }

    if (widget.lastGuess != null && widget.lastGuess != oldWidget.lastGuess) {
      _guessAnimationController
        ..value = 0
        ..forward();
    }
  }

  @override
  void dispose() {
    _guessAnimationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        return Semantics(
          label:
              'Interactive globe. Drag to rotate, pinch or scroll to zoom, and tap or click to guess.',
          child: Listener(
            onPointerSignal: _handlePointerSignal,
            child: GestureDetector(
              behavior: HitTestBehavior.opaque,
              onScaleStart: (details) {
                _scaleStartZoom = zoom;
              },
              onScaleUpdate: (details) {
                setState(() {
                  zoom = (_scaleStartZoom * details.scale)
                      .clamp(_minZoom, _maxZoom)
                      .toDouble();
                  centerLng = normalizeLng(
                    centerLng - details.focalPointDelta.dx * (0.45 / zoom),
                  );
                  centerLat =
                      (centerLat + details.focalPointDelta.dy * (0.25 / zoom))
                          .clamp(-60.0, 60.0);
                });
              },
              onTapUp: widget.enabled
                  ? (details) {
                      final size =
                          Size(constraints.maxWidth, constraints.maxHeight);
                      final latLng = screenToLatLng(
                        details.localPosition,
                        size,
                        centerLat,
                        centerLng,
                        radiusScale: 0.46 * zoom,
                      );
                      if (latLng != null) {
                        widget.onGuessSelected(latLng.$1, latLng.$2);
                      }
                    }
                  : null,
              child: RepaintBoundary(
                child: ClipRect(
                  child: CustomPaint(
                    size: Size.infinite,
                    painter: _GlobePainter(
                      centerLat: centerLat,
                      centerLng: centerLng,
                      zoom: zoom,
                      geometry: _renderGeometry,
                      guessAnimation: _guessAnimation,
                      pendingGuess: widget.pendingGuess,
                      lastGuess: widget.lastGuess,
                      enabled: widget.enabled,
                    ),
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  void _handlePointerSignal(PointerSignalEvent event) {
    if (event is! PointerScrollEvent) return;

    setState(() {
      final zoomFactor = math.exp(-event.scrollDelta.dy / 600);
      zoom = (zoom * zoomFactor).clamp(_minZoom, _maxZoom).toDouble();
    });
  }
}

class _GlobePainter extends CustomPainter {
  const _GlobePainter({
    required this.centerLat,
    required this.centerLng,
    required this.zoom,
    required this.enabled,
    required this.geometry,
    required this.guessAnimation,
    this.pendingGuess,
    this.lastGuess,
  }) : super(repaint: guessAnimation);

  final double centerLat;
  final double centerLng;
  final double zoom;
  final bool enabled;
  final _GlobeRenderGeometry geometry;
  final Animation<double> guessAnimation;
  final GeoPoint? pendingGuess;
  final Guess? lastGuess;

  @override
  void paint(Canvas canvas, Size size) {
    final baseRadius = math.min(size.width, size.height) * 0.46;
    final radius = baseRadius * zoom;
    final center = Offset(size.width / 2, size.height / 2);
    final globeRect = Rect.fromCircle(center: center, radius: radius);

    final ocean = Paint()
      ..shader = const RadialGradient(
        colors: [GeoStreakColors.globeBlue, GeoStreakColors.globeBlueDark],
        center: Alignment(-0.35, -0.45),
      ).createShader(globeRect);
    final glow = Paint()
      ..color = GeoStreakColors.globeBlue.withValues(alpha: 0.12)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 18);
    final border = Paint()
      ..color = GeoStreakColors.whiteText.withValues(alpha: 0.72)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;

    canvas.drawCircle(center, radius + 8, glow);
    canvas.drawCircle(center, radius, ocean);
    canvas.drawCircle(center, radius, border);

    canvas.save();
    canvas.clipPath(Path()..addOval(globeRect));
    _drawGrid(canvas, center, radius);
    _drawLand(canvas, center, radius);
    _drawBorders(canvas, center, radius);
    final guess = lastGuess;
    if (guess != null) {
      _drawGuessAnimation(canvas, center, radius, guess);
    }
    canvas.restore();

    if (guess != null) {
      _drawMarker(canvas, center, radius, guess.guessLat, guess.guessLng,
          GeoStreakColors.guessOrange, 8);
      _drawMarker(canvas, center, radius, guess.answerLat, guess.answerLng,
          GeoStreakColors.successGreen, 8);
    }

    final pending = pendingGuess;
    if (pending != null) {
      _drawMarker(canvas, center, radius, pending.latitude, pending.longitude,
          GeoStreakColors.streakGold, 9);
    }
  }

  void _drawGrid(
    Canvas canvas,
    Offset center,
    double radius,
  ) {
    final gridPaint = Paint()
      ..color = GeoStreakColors.whiteText.withValues(alpha: 0.23)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1;
    for (var lat = -60; lat <= 60; lat += 30) {
      _drawLatitude(
        canvas,
        center,
        radius,
        lat.toDouble(),
        gridPaint,
      );
    }
    for (var lng = -180; lng < 180; lng += 30) {
      _drawLongitude(
        canvas,
        center,
        radius,
        lng.toDouble(),
        gridPaint,
      );
    }
  }

  void _drawLand(Canvas canvas, Offset center, double radius) {
    final landPaint = Paint()
      ..color = GeoStreakColors.landGreen.withValues(alpha: 0.88)
      ..style = PaintingStyle.fill;
    final landStroke = Paint()
      ..color = GeoStreakColors.whiteText.withValues(alpha: 0.08)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1;

    for (final ring in geometry.landRings) {
      final path = _buildClippedPolygonPath(ring, center, radius);
      if (path == null) continue;
      canvas.drawPath(path, landPaint);
      canvas.drawPath(path, landStroke);
    }
  }

  void _drawBorders(Canvas canvas, Offset center, double radius) {
    final borderPaint = Paint()
      ..color = GeoStreakColors.whiteText.withValues(alpha: 0.18)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 0.8;

    for (final line in geometry.borderLines) {
      final path = _buildGeoPath(line, center, radius);
      if (path == null) continue;
      canvas.drawPath(path, borderPaint);
    }
  }

  void _drawGuessAnimation(
    Canvas canvas,
    Offset center,
    double radius,
    Guess guess,
  ) {
    final progress = guessAnimation.value.clamp(0.0, 1.0);
    if (progress <= 0) return;

    final totalDistanceKm = haversineKm(
      guess.guessLat,
      guess.guessLng,
      guess.answerLat,
      guess.answerLng,
    );
    final guessPoint = GeoPoint(
      latitude: guess.guessLat,
      longitude: guess.guessLng,
    );
    final answerPoint = GeoPoint(
      latitude: guess.answerLat,
      longitude: guess.answerLng,
    );
    final path = Path();
    Offset? labelOffset;
    var started = false;
    var drewSegment = false;
    final steps = math.max(2, (72 * progress).ceil());

    for (var step = 0; step <= steps; step++) {
      final t = progress * (step / steps);
      final point = _sphericalInterpolate(guessPoint, answerPoint, t);
      final offset = _projectVisible(point, center, radius);
      if (offset == null) {
        started = false;
        continue;
      }

      labelOffset = offset;
      if (!started) {
        path.moveTo(offset.dx, offset.dy);
        started = true;
      } else {
        path.lineTo(offset.dx, offset.dy);
        drewSegment = true;
      }
    }

    if (drewSegment) {
      final arcPaint = Paint()
        ..color = GeoStreakColors.streakGold
        ..style = PaintingStyle.stroke
        ..strokeCap = StrokeCap.round
        ..strokeJoin = StrokeJoin.round
        ..strokeWidth = 3.2;
      final glowPaint = Paint()
        ..color = GeoStreakColors.streakGold.withValues(alpha: 0.24)
        ..style = PaintingStyle.stroke
        ..strokeCap = StrokeCap.round
        ..strokeJoin = StrokeJoin.round
        ..strokeWidth = 9;

      canvas.drawPath(path, glowPaint);
      canvas.drawPath(path, arcPaint);
    }

    if (labelOffset != null) {
      _drawDistanceLabel(
        canvas,
        labelOffset,
        '${(totalDistanceKm * progress).round()} km',
      );
    }
  }

  void _drawDistanceLabel(Canvas canvas, Offset anchor, String text) {
    final textPainter = TextPainter(
      text: TextSpan(
        text: text,
        style: const TextStyle(
          color: GeoStreakColors.deepNavy,
          fontSize: 13,
          fontWeight: FontWeight.w800,
        ),
      ),
      textDirection: TextDirection.ltr,
    )..layout();

    final rect = Rect.fromLTWH(
      anchor.dx - textPainter.width / 2 - 8,
      anchor.dy - 34,
      textPainter.width + 16,
      textPainter.height + 8,
    );
    final rrect = RRect.fromRectAndRadius(rect, const Radius.circular(8));
    canvas.drawRRect(
      rrect,
      Paint()..color = GeoStreakColors.streakGold.withValues(alpha: 0.94),
    );
    textPainter.paint(
      canvas,
      Offset(rect.left + 8, rect.top + 4),
    );
  }

  Path? _buildGeoPath(List<GeoPoint> points, Offset center, double radius) {
    if (points.length < 2) return null;

    final path = Path();
    var started = false;
    var drewSegment = false;

    for (final point in points) {
      final offset = _projectVisible(point, center, radius);
      if (offset == null) {
        started = false;
        continue;
      }

      if (!started) {
        path.moveTo(offset.dx, offset.dy);
        started = true;
      } else {
        path.lineTo(offset.dx, offset.dy);
        drewSegment = true;
      }
    }

    return drewSegment ? path : null;
  }

  Path? _buildClippedPolygonPath(
    List<GeoPoint> points,
    Offset center,
    double radius,
  ) {
    if (points.length < 3) return null;

    final projected = <_ProjectedGeoPoint>[];
    for (final point in points) {
      projected.add(_projectGeoPoint(point));
    }

    final clipped = _clipToVisibleHemisphere(projected);
    if (clipped.length < 3) return null;

    final path = Path();
    final first = clipped.first;
    path.moveTo(center.dx + first.x * radius, center.dy + first.y * radius);

    var previous = first;
    for (final point in clipped.skip(1)) {
      _appendClippedPolygonEdge(path, previous, point, center, radius);
      previous = point;
    }

    _appendClippedPolygonEdge(path, previous, first, center, radius);
    path.close();
    return path;
  }

  void _appendClippedPolygonEdge(
    Path path,
    _ProjectedGeoPoint from,
    _ProjectedGeoPoint to,
    Offset center,
    double radius,
  ) {
    if (from.isOnHorizon && to.isOnHorizon) {
      _appendHorizonArc(path, from, to, center, radius);
      return;
    }

    path.lineTo(center.dx + to.x * radius, center.dy + to.y * radius);
  }

  void _appendHorizonArc(
    Path path,
    _ProjectedGeoPoint from,
    _ProjectedGeoPoint to,
    Offset center,
    double radius,
  ) {
    final startAngle = math.atan2(from.y, from.x);
    final endAngle = math.atan2(to.y, to.x);
    final delta = _shortestAngleDelta(startAngle, endAngle);
    final steps = math.max(4, (delta.abs() / (math.pi / 36)).ceil());

    for (var step = 1; step <= steps; step++) {
      final angle = startAngle + delta * (step / steps);
      path.lineTo(
        center.dx + math.cos(angle) * radius,
        center.dy + math.sin(angle) * radius,
      );
    }
  }

  double _shortestAngleDelta(double from, double to) {
    var delta = to - from;
    while (delta > math.pi) {
      delta -= math.pi * 2;
    }
    while (delta < -math.pi) {
      delta += math.pi * 2;
    }
    return delta;
  }

  List<_ProjectedGeoPoint> _clipToVisibleHemisphere(
    List<_ProjectedGeoPoint> points,
  ) {
    if (points.isEmpty) return const [];

    final clipped = <_ProjectedGeoPoint>[];
    var previous = points.last;
    var previousVisible = previous.isVisible;

    for (final current in points) {
      final currentVisible = current.isVisible;

      if (currentVisible != previousVisible) {
        clipped.add(_horizonIntersection(previous, current));
      }

      if (currentVisible) {
        clipped.add(current);
      }

      previous = current;
      previousVisible = currentVisible;
    }

    return clipped;
  }

  _ProjectedGeoPoint _horizonIntersection(
    _ProjectedGeoPoint from,
    _ProjectedGeoPoint to,
  ) {
    final denominator = from.z - to.z;
    final t = denominator.abs() < 0.000001 ? 0.0 : from.z / denominator;
    final x = from.x + (to.x - from.x) * t;
    final y = from.y + (to.y - from.y) * t;
    final length = math.sqrt(x * x + y * y);
    if (length == 0) {
      return const _ProjectedGeoPoint(x: 1, y: 0, z: 0);
    }

    return _ProjectedGeoPoint(
      x: x / length,
      y: y / length,
      z: 0,
    );
  }

  Offset? _projectVisible(GeoPoint point, Offset center, double radius) {
    return latLngToScreen(
      point.latitude,
      point.longitude,
      Size(radius * 2, radius * 2),
      centerLat,
      centerLng,
      customCenter: center,
    );
  }

  _ProjectedGeoPoint _projectGeoPoint(GeoPoint point) {
    final phi = degToRad(point.latitude);
    final lambda = degToRad(normalizeLng(point.longitude - centerLng));
    final phi0 = degToRad(centerLat);

    return _ProjectedGeoPoint(
      x: math.cos(phi) * math.sin(lambda),
      y: -(math.cos(phi0) * math.sin(phi) -
          math.sin(phi0) * math.cos(phi) * math.cos(lambda)),
      z: math.sin(phi0) * math.sin(phi) +
          math.cos(phi0) * math.cos(phi) * math.cos(lambda),
    );
  }

  GeoPoint _sphericalInterpolate(GeoPoint from, GeoPoint to, double t) {
    final fromVector = _GeoVector.fromGeoPoint(from);
    final toVector = _GeoVector.fromGeoPoint(to);
    final dot = fromVector.dot(toVector).clamp(-1.0, 1.0);
    final omega = math.acos(dot);
    final sinOmega = math.sin(omega);

    if (sinOmega.abs() < 0.000001) {
      return _GlobeRenderGeometry.interpolateGeoPoint(from, to, t);
    }

    final fromScale = math.sin((1 - t) * omega) / sinOmega;
    final toScale = math.sin(t * omega) / sinOmega;
    return (fromVector * fromScale + toVector * toScale).toGeoPoint();
  }

  void _drawMarker(Canvas canvas, Offset center, double radius, double lat,
      double lng, Color color, double markerRadius) {
    final point = latLngToScreen(
      lat,
      lng,
      Size(radius * 2, radius * 2),
      centerLat,
      centerLng,
      customCenter: center,
    );
    if (point == null) return;
    canvas.drawCircle(point, markerRadius + 4,
        Paint()..color = color.withValues(alpha: 0.22));
    canvas.drawCircle(point, markerRadius, Paint()..color = color);
  }

  void _drawLatitude(
      Canvas canvas, Offset center, double radius, double lat, Paint paint) {
    final path = Path();
    var started = false;
    for (double lng = -180; lng <= 180; lng += 4) {
      final point = latLngToScreen(
        lat,
        lng,
        Size(radius * 2, radius * 2),
        centerLat,
        centerLng,
        customCenter: center,
      );
      if (point == null) {
        started = false;
        continue;
      }
      if (!started) {
        path.moveTo(point.dx, point.dy);
        started = true;
      } else {
        path.lineTo(point.dx, point.dy);
      }
    }
    canvas.drawPath(path, paint);
  }

  void _drawLongitude(
      Canvas canvas, Offset center, double radius, double lng, Paint paint) {
    final path = Path();
    var started = false;
    for (double lat = -89; lat <= 89; lat += 3) {
      final point = latLngToScreen(
        lat,
        lng,
        Size(radius * 2, radius * 2),
        centerLat,
        centerLng,
        customCenter: center,
      );
      if (point == null) {
        started = false;
        continue;
      }
      if (!started) {
        path.moveTo(point.dx, point.dy);
        started = true;
      } else {
        path.lineTo(point.dx, point.dy);
      }
    }
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant _GlobePainter oldDelegate) {
    return centerLat != oldDelegate.centerLat ||
        centerLng != oldDelegate.centerLng ||
        zoom != oldDelegate.zoom ||
        enabled != oldDelegate.enabled ||
        geometry != oldDelegate.geometry ||
        guessAnimation != oldDelegate.guessAnimation ||
        pendingGuess != oldDelegate.pendingGuess ||
        lastGuess != oldDelegate.lastGuess;
  }
}

class _GlobeRenderGeometry {
  const _GlobeRenderGeometry({
    required this.landRings,
    required this.borderLines,
  });

  final List<List<GeoPoint>> landRings;
  final List<List<GeoPoint>> borderLines;

  factory _GlobeRenderGeometry.fromGeometry(
    GlobeGeometry geometry, {
    required double maxSegmentDegrees,
  }) {
    return _GlobeRenderGeometry(
      landRings: _densifyLines(
        geometry.landRings,
        maxSegmentDegrees: maxSegmentDegrees,
      ),
      borderLines: _densifyLines(
        geometry.borderLines,
        maxSegmentDegrees: maxSegmentDegrees,
      ),
    );
  }

  static List<List<GeoPoint>> _densifyLines(
    List<List<GeoPoint>> lines, {
    required double maxSegmentDegrees,
  }) {
    return lines
        .map(
          (line) => _densifyLine(
            line,
            maxSegmentDegrees: maxSegmentDegrees,
          ),
        )
        .toList(growable: false);
  }

  static List<GeoPoint> _densifyLine(
    List<GeoPoint> points, {
    required double maxSegmentDegrees,
  }) {
    if (points.length < 2) return points;

    final densified = <GeoPoint>[];
    for (var index = 0; index < points.length - 1; index++) {
      final from = points[index];
      final to = points[index + 1];
      final steps = _segmentSteps(
        from,
        to,
        maxSegmentDegrees: maxSegmentDegrees,
      );

      for (var step = 0; step <= steps; step++) {
        if (index > 0 && step == 0) continue;
        densified.add(interpolateGeoPoint(from, to, step / steps));
      }
    }

    return densified;
  }

  static int _segmentSteps(
    GeoPoint from,
    GeoPoint to, {
    required double maxSegmentDegrees,
  }) {
    final latDelta = (to.latitude - from.latitude).abs();
    final lngDelta = normalizeLng(to.longitude - from.longitude).abs();
    final degrees = math.max(latDelta, lngDelta);
    return math.max(1, (degrees / maxSegmentDegrees).ceil());
  }

  static GeoPoint interpolateGeoPoint(GeoPoint from, GeoPoint to, double t) {
    final lngDelta = normalizeLng(to.longitude - from.longitude);
    return GeoPoint(
      latitude: from.latitude + (to.latitude - from.latitude) * t,
      longitude: normalizeLng(from.longitude + lngDelta * t),
    );
  }
}

class _GeoVector {
  const _GeoVector({
    required this.x,
    required this.y,
    required this.z,
  });

  final double x;
  final double y;
  final double z;

  factory _GeoVector.fromGeoPoint(GeoPoint point) {
    final phi = degToRad(point.latitude);
    final lambda = degToRad(point.longitude);
    return _GeoVector(
      x: math.cos(phi) * math.cos(lambda),
      y: math.cos(phi) * math.sin(lambda),
      z: math.sin(phi),
    );
  }

  double dot(_GeoVector other) => x * other.x + y * other.y + z * other.z;

  GeoPoint toGeoPoint() {
    final length = math.sqrt(x * x + y * y + z * z);
    final nx = x / length;
    final ny = y / length;
    final nz = z / length;
    return GeoPoint(
      latitude: radToDeg(math.asin(nz)).clamp(-90.0, 90.0).toDouble(),
      longitude: normalizeLng(radToDeg(math.atan2(ny, nx))),
    );
  }

  _GeoVector operator *(double scale) {
    return _GeoVector(
      x: x * scale,
      y: y * scale,
      z: z * scale,
    );
  }

  _GeoVector operator +(_GeoVector other) {
    return _GeoVector(
      x: x + other.x,
      y: y + other.y,
      z: z + other.z,
    );
  }
}

class _ProjectedGeoPoint {
  const _ProjectedGeoPoint({
    required this.x,
    required this.y,
    required this.z,
  });

  final double x;
  final double y;
  final double z;

  bool get isVisible => z >= 0;
  bool get isOnHorizon => z.abs() < 0.000001;
}
