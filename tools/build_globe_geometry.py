#!/usr/bin/env python3
"""Build compact globe geometry assets from Natural Earth GeoJSON.

The Flutter app should not load full Natural Earth GeoJSON directly. This script
downloads stable 110m source files and emits a smaller JSON format optimized for
the globe painter: latitude/longitude pairs rounded to a fixed precision.
"""

from __future__ import annotations

import argparse
import json
import urllib.request
from pathlib import Path
from typing import Any


LAND_URL = (
    "https://raw.githubusercontent.com/nvkelso/natural-earth-vector/master/"
    "geojson/ne_110m_land.geojson"
)
BORDERS_URL = (
    "https://raw.githubusercontent.com/nvkelso/natural-earth-vector/master/"
    "geojson/ne_110m_admin_0_boundary_lines_land.geojson"
)
COUNTRIES_URL = (
    "https://raw.githubusercontent.com/nvkelso/natural-earth-vector/master/"
    "geojson/ne_10m_admin_0_countries.geojson"
)


def fetch_json(url: str) -> dict[str, Any]:
    with urllib.request.urlopen(url, timeout=60) as response:
        return json.loads(response.read().decode("utf-8"))


def quantize(value: float, precision: int) -> float:
    return round(float(value), precision)


def convert_position(position: list[float], precision: int) -> list[float]:
    longitude, latitude = position[:2]
    return [quantize(latitude, precision), quantize(longitude, precision)]


def convert_ring(ring: list[list[float]], precision: int) -> list[list[float]]:
    converted = [convert_position(position, precision) for position in ring]
    deduped: list[list[float]] = []
    for point in converted:
        if not deduped or point != deduped[-1]:
            deduped.append(point)
    return deduped


def extract_polygon_rings(geometry: dict[str, Any], precision: int) -> list[list[list[float]]]:
    geometry_type = geometry["type"]
    coordinates = geometry["coordinates"]

    if geometry_type == "Polygon":
        return [convert_ring(ring, precision) for ring in coordinates]

    if geometry_type == "MultiPolygon":
        rings: list[list[list[float]]] = []
        for polygon in coordinates:
            rings.extend(convert_ring(ring, precision) for ring in polygon)
        return rings

    return []


def extract_country_polygons(
    geometry: dict[str, Any], precision: int
) -> list[list[list[list[float]]]]:
    geometry_type = geometry["type"]
    coordinates = geometry["coordinates"]

    if geometry_type == "Polygon":
        return [[convert_ring(ring, precision) for ring in coordinates]]

    if geometry_type == "MultiPolygon":
        return [
            [convert_ring(ring, precision) for ring in polygon]
            for polygon in coordinates
        ]

    return []


def extract_line_rings(geometry: dict[str, Any], precision: int) -> list[list[list[float]]]:
    geometry_type = geometry["type"]
    coordinates = geometry["coordinates"]

    if geometry_type == "LineString":
        return [convert_ring(coordinates, precision)]

    if geometry_type == "MultiLineString":
        return [convert_ring(line, precision) for line in coordinates]

    return []


def build_geometry(precision: int) -> dict[str, Any]:
    land_geojson = fetch_json(LAND_URL)
    borders_geojson = fetch_json(BORDERS_URL)
    countries_geojson = fetch_json(COUNTRIES_URL)

    land: list[list[list[float]]] = []
    for feature in land_geojson["features"]:
        land.extend(extract_polygon_rings(feature["geometry"], precision))

    borders: list[list[list[float]]] = []
    for feature in borders_geojson["features"]:
        borders.extend(extract_line_rings(feature["geometry"], precision))

    countries: list[dict[str, Any]] = []
    for feature in countries_geojson["features"]:
        properties = feature["properties"]
        countries.append(
            {
                "name": properties.get("ADMIN")
                or properties.get("NAME_LONG")
                or properties.get("NAME"),
                "polygons": extract_country_polygons(feature["geometry"], precision),
            }
        )

    return {
        "source": "Natural Earth 110m land/borders, 10m countries",
        "license": "Public domain",
        "precision": precision,
        "land": land,
        "borders": borders,
        "countries": countries,
    }


def main() -> None:
    parser = argparse.ArgumentParser()
    parser.add_argument(
        "--output",
        default="assets/maps/natural_earth_110m.json",
        help="Output JSON asset path.",
    )
    parser.add_argument(
        "--precision",
        type=int,
        default=2,
        help="Coordinate decimal precision. 2 ~= 1.1km at the equator.",
    )
    args = parser.parse_args()

    output = Path(args.output)
    output.parent.mkdir(parents=True, exist_ok=True)

    geometry = build_geometry(args.precision)
    output.write_text(
        json.dumps(geometry, separators=(",", ":")),
        encoding="utf-8",
    )

    print(
        f"Wrote {output} with {len(geometry['land'])} land rings "
        f"{len(geometry['borders'])} border lines, and "
        f"{len(geometry['countries'])} countries."
    )


if __name__ == "__main__":
    main()
