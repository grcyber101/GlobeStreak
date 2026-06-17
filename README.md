# GlobeStreak

GlobeStreak is a Flutter geography game where players build an endless streak by locating towns and cities on a globe.

The project is structured as a web-first, mobile-friendly Flutter app that also builds for Android and leaves room for future iOS support.

## Current Scope

- Custom draggable and tappable globe game board.
- Accurate Natural Earth 110m land, country border, and country polygon geometry.
- Run rules: start with 3 globe lives, lose one over 250km or in another country, gain one under 100km with no life cap.
- Seeded city dataset with difficulty and population metadata.
- Repository-based city access.
- Local persistence through `shared_preferences`.
- Statistics storage foundation.
- Daily challenge sequence foundation.
- Responsive mobile and desktop/tablet layouts.
- Centralized theme, palette, breakpoints, and game constants.

## Project Structure

```text
lib/
  main.dart
  core/
    constants/
    services/
    theme/
    utils/
  data/
    models/
    repositories/
    seed/
  features/
    game/
      controllers/
      models/
      screens/
      widgets/
    settings/
      controllers/
      models/
    stats/
      controllers/
      models/
  shared/
    layouts/
    widgets/
assets/
  maps/
```

## Run Locally

```bash
flutter pub get
flutter run -d chrome
flutter run -d android
```

## Verify

```bash
dart format lib
flutter analyze
flutter build web
flutter build apk --debug
```

## Deploy

The GitHub Actions workflow at `.github/workflows/deploy-web.yml` builds and deploys the web app to GitHub Pages on every push to `main`.

For the first deployment, enable GitHub Pages in the repository:

1. Open `Settings > Pages`.
2. Set `Build and deployment > Source` to `GitHub Actions`.
3. Re-run the latest `Deploy Flutter Web to GitHub Pages` workflow.

Public URL:

```text
https://grcyber101.github.io/GlobeStreak/
```

## Rebuild Globe Geometry

The globe uses a compact asset generated from Natural Earth GeoJSON.

```bash
python tools/build_globe_geometry.py --output assets/maps/natural_earth_110m.json
```

The script downloads Natural Earth 110m land/border data and Natural Earth 10m country polygon data, rounds coordinates, and writes app-ready JSON for Flutter.

## Platform Notes

- Web is the primary target.
- Android uses AndroidX and a current Gradle/Kotlin baseline.
- iOS is not scaffolded in this workspace yet, but the Dart architecture avoids platform-specific assumptions.
- The game board is local Flutter rendering with bundled Natural Earth geometry. It does not depend on Google Maps, Street View, paid tiles, or runtime map APIs.

See `ARCHITECTURE.md` for the foundation design and data/state flow.
