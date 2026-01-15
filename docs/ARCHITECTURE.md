# Architecture Overview

This project is a Swift Package that exposes both a reusable core library and a CLI executable.

## Targets

- **MapExplorerCore** (library)
  - `Coordinate`, `Place`, and `Route` models.
  - `PlaceDataStore` for loading and validating datasets.
  - `PlaceIndex` for search scoring.
  - `RoutePlanner` for shortest-path routing.
  - `OutputFormatter` for table and JSON output.

- **MapExplorerCLI** (executable)
  - `main.swift` parses CLI arguments and delegates to the core library.
  - The CLI is intentionally dependency-free to keep the tool portable.

## Data Flow

1. CLI parses arguments and resolves options (`--query`, `--from`, `--to`, `--name`, `--format`, `--data`).
2. `MapExplorerService` loads the dataset (default or custom) via `PlaceDataStore`.
3. `PlaceIndex` performs search by name, category, and tags.
4. `RoutePlanner` computes shortest paths using Dijkstra’s algorithm on the directed graph.
5. `OutputFormatter` renders results in table or JSON format.

## Testing Strategy

Unit tests in `Tests/MapExplorerCoreTests` cover:

- Dataset loading and validation.
- Search results and ranking.
- Routing correctness and error handling.
- Output formatting in table and JSON modes.

Integration verification lives in `scripts/verify.sh`, which exercises real CLI commands.
