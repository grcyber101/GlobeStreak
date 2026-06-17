# Map Assets

`natural_earth_110m.json` is generated from Natural Earth public-domain GeoJSON by:

```bash
python tools/build_globe_geometry.py --output assets/maps/natural_earth_110m.json
```

The generated format is intentionally compact:

- `land`: land polygon rings as `[latitude, longitude]` pairs.
- `borders`: country border lines as `[latitude, longitude]` pairs.
- `countries`: admin country polygons used to decide whether a guess is in another country.
- coordinates rounded to 2 decimal places.

Do not edit the generated JSON by hand. Update `tools/build_globe_geometry.py` and regenerate it.
