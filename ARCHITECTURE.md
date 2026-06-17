# GlobeStreak Architecture

## Goals

The foundation separates UI, domain state, data access, persistence, and platform configuration so gameplay features can be added without growing `GameScreen` into the application layer.

## Folder Responsibilities

```text
core/
  constants/      Shared breakpoints, storage keys, and game tuning.
  services/       Cross-feature services such as storage and daily challenges.
  theme/          GlobeStreak palette and Material theme.
  utils/          Framework-light helpers such as geographic math.

data/
  models/         App-wide data models such as City.
  repositories/   Data access boundaries.
  seed/           Bundled seed data used before external/generated datasets exist.

features/
  game/           Game screen, controller, widgets, and game-specific models.
  stats/          Statistics model and persistence repository.
  settings/       Settings model and persistence repository.

shared/
  layouts/        Reusable responsive layout primitives.
  widgets/        Cross-feature widgets when needed.
```

## Data Flow

`citySeedData` provides the bundled city list. `CityRepository` is the only access point for city data and exposes loading, random selection, difficulty filtering, and population filtering. Future datasets or generated JSON should be hidden behind the same repository boundary.

```text
citySeedData -> CityRepository -> GameController -> GameScreen/widgets
```

`GlobeGeometryRepository` loads `assets/maps/natural_earth_110m.json`, a compact generated asset built from Natural Earth land, country-border, and country-polygon GeoJSON. `GlobeGuessWidget` receives this geometry and renders it through `GlobePainter`; `CountryLookupService` uses the country polygons for gameplay country checks.

```text
Natural Earth GeoJSON -> tools/build_globe_geometry.py -> assets/maps/natural_earth_110m.json -> GlobeGeometryRepository -> GlobePainter/CountryLookupService
```

## State Flow

`GameController` owns the active game loop:

- current target city
- current `GameState`
- threshold distance
- last guess and result
- status message

`GameScreen` is intentionally thin. It initializes the controller, passes controller values into widgets, and requests a rebuild after async controller actions.

```text
UI input -> GameController.submitGuess -> GameState/GuessResult -> StatisticsRepository -> shared_preferences
```

## Persistence

`LocalStorageService` wraps `shared_preferences` so feature repositories do not depend directly on plugin APIs.

Currently persisted:

- best streak
- games played
- total guesses
- correct guesses
- total distance
- longest life chain
- settings flags

`StatisticsRepository` stores aggregate stats now; stats UI can be added later without changing game storage.

## Daily Challenge Foundation

`DailyChallengeService.sequenceForDate` accepts a `DateTime` and returns a deterministic city sequence by seeding `dart:math.Random` from `yyyymmdd`. For example, `2026-06-15` will always produce the same city order for a fixed city dataset.

No daily challenge UI exists yet.

## Responsive Design

The breakpoint is centralized in `AppBreakpoints`:

- mobile: less than `800px`
- desktop/tablet: `800px` and above

`ResponsiveGameLayout` chooses:

- `MobileGameLayout`: prompt, HUD, globe, results stacked vertically.
- `DesktopGameLayout`: globe on the left, side panel on the right.

Widgets receive bounded layout constraints and avoid fixed full-screen assumptions except where a layout explicitly owns the width.

## Theme

`GeoStreakTheme` owns the Material theme. `GeoStreakColors` owns the palette:

- deep navy background
- globe blue accents
- white text
- green success
- red failure
- gold streak highlights

Game widgets should use theme values or `GeoStreakColors`, not local hardcoded colors.

## Globe Geometry

The current globe uses Natural Earth 110m data for rendering and Natural Earth 10m data for country lookup:

- land polygon rings
- land country-border lines
- admin country polygons for guess-country lookup
- coordinate precision rounded to 2 decimals

Regenerate it with:

```bash
python tools/build_globe_geometry.py --output assets/maps/natural_earth_110m.json
```

The 110m dataset is intentionally the default because it is small enough for web and mobile startup. Higher-detail 50m or 10m assets should be added as separate assets and selected by device capability or zoom level rather than replacing the baseline blindly.

## Expansion Points

- Replace `citySeedData` with generated city data behind `CityRepository`.
- Add 50m/10m map assets with level-of-detail switching for zoomed-in globe views.
- Add stats and settings screens under their existing feature folders.
- Add daily challenge routing and UI that consumes `DailyChallengeService`.
- Introduce a fuller state-management library only when controller ownership becomes too large for the current app size.
