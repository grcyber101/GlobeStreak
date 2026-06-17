import 'package:flutter/material.dart';

import 'geo_streak_colors.dart';

class GeoStreakTheme {
  const GeoStreakTheme._();

  static ThemeData dark() {
    final scheme = ColorScheme.fromSeed(
      seedColor: GeoStreakColors.globeBlue,
      brightness: Brightness.dark,
      surface: GeoStreakColors.navySurface,
      primary: GeoStreakColors.globeBlue,
      error: GeoStreakColors.failureRed,
    );

    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      colorScheme: scheme,
      scaffoldBackgroundColor: GeoStreakColors.deepNavy,
      cardTheme: CardThemeData(
        color: GeoStreakColors.navySurface,
        elevation: 0,
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
          side: BorderSide(
              color: GeoStreakColors.whiteText.withValues(alpha: 0.08)),
        ),
      ),
      chipTheme: ChipThemeData(
        backgroundColor: GeoStreakColors.streakGold.withValues(alpha: 0.14),
        labelStyle: const TextStyle(
          color: GeoStreakColors.streakGold,
          fontWeight: FontWeight.w700,
        ),
        side: BorderSide(
            color: GeoStreakColors.streakGold.withValues(alpha: 0.32)),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: GeoStreakColors.globeBlue,
          foregroundColor: GeoStreakColors.deepNavy,
          textStyle: const TextStyle(fontWeight: FontWeight.w800),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        ),
      ),
      iconTheme: const IconThemeData(color: GeoStreakColors.globeBlue),
      textTheme: Typography.whiteMountainView.apply(
        bodyColor: GeoStreakColors.whiteText,
        displayColor: GeoStreakColors.whiteText,
      ),
    );
  }
}
