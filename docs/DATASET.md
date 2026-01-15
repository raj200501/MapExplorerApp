# Dataset Schema

The Map Explorer CLI consumes a JSON dataset that describes places and their connections. The default dataset is bundled as `Sources/MapExplorerCore/Resources/places.json`.

## Top-Level Structure

```json
{
  "places": [ ... ],
  "routes": [ ... ]
}
```

### places

Each place record describes a named location in the map graph.

```json
{
  "id": "P0001",
  "name": "Central Park",
  "category": "Park",
  "description": "A sprawling green park with lakes and walking trails.",
  "coordinate": {
    "latitude": 37.0000,
    "longitude": -122.0000
  },
  "tags": ["park", "green", "landmark"]
}
```

**Fields**

- `id` (string): Unique identifier used by the routing graph. Must be unique across all places.
- `name` (string): Display name returned by search.
- `category` (string): Category label used by search scoring.
- `description` (string): Human-readable description shown in `show` output.
- `coordinate.latitude` / `coordinate.longitude` (number): Latitude and longitude in decimal degrees.
- `tags` (string array): Extra keywords for search.

### routes

Each route represents a directed edge in the routing graph.

```json
{
  "from": "P0001",
  "to": "P0002",
  "distanceKm": 0.92
}
```

**Fields**

- `from` (string): Place ID for the origin.
- `to` (string): Place ID for the destination.
- `distanceKm` (number | null): Optional override for edge distance. When `null`, the CLI calculates the distance using haversine distance between the origin and destination coordinates.

## Validation Rules

The `map-explorer validate` command (or `./scripts/run.sh validate`) enforces these rules:

1. `places` must be non-empty.
2. Every place ID must be unique.
3. Every route must refer to existing place IDs.

## Tips for Custom Datasets

- Keep IDs stable for better routing output.
- Provide `distanceKm` for transit routes that differ from straight-line distance.
- Add tags for common search terms (e.g. `"waterfront"`, `"transit"`).
- Use `--data <path>` to point the CLI to your file:

```bash
./scripts/run.sh search --query "market" --data ./my-dataset.json
```
