import 'package:flutter/material.dart';

import '../../core/theme/geo_streak_colors.dart';

class LoadingView extends StatelessWidget {
  const LoadingView({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const _LoadingGlobe(),
            const SizedBox(height: 18),
            Text(
              'GlobeStreak',
              style: theme.textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              'Loading world data...',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: GeoStreakColors.whiteText.withValues(alpha: 0.72),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _LoadingGlobe extends StatefulWidget {
  const _LoadingGlobe();

  @override
  State<_LoadingGlobe> createState() => _LoadingGlobeState();
}

class _LoadingGlobeState extends State<_LoadingGlobe>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return RotationTransition(
      turns: _controller,
      child: Container(
        width: 64,
        height: 64,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          gradient: const RadialGradient(
            center: Alignment(-0.35, -0.45),
            colors: [
              GeoStreakColors.globeBlue,
              GeoStreakColors.globeBlueDark,
            ],
          ),
          border: Border.all(
            color: GeoStreakColors.whiteText.withValues(alpha: 0.68),
            width: 3,
          ),
          boxShadow: [
            BoxShadow(
              color: GeoStreakColors.globeBlue.withValues(alpha: 0.28),
              blurRadius: 34,
            ),
          ],
        ),
        child: CustomPaint(painter: _LoadingGlobePainter()),
      ),
    );
  }
}

class _LoadingGlobePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = GeoStreakColors.whiteText.withValues(alpha: 0.28)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.shortestSide / 2;

    canvas.drawLine(
      Offset(center.dx, center.dy - radius),
      Offset(center.dx, center.dy + radius),
      paint,
    );
    canvas.drawLine(
      Offset(center.dx - radius, center.dy),
      Offset(center.dx + radius, center.dy),
      paint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
