# Map Explorer App

A Swift-based Map Explorer CLI that lets you search a curated map dataset, inspect place details, and compute routes between locations. The repository also contains the original iOS storyboard and controller prototypes, but the runnable artifact in this workspace is the Swift command-line tool backed by a deterministic dataset.

## Features

- Search for places by name, category, or tags.
- View details for a single place.
- Compute shortest routes between two locations using a graph-based planner.
- Validate custom datasets for correctness.

## Requirements

- Swift 6.0+ (verified with Swift 6.2.3 locally and Swift 6.0 in CI)
- Bash (for the helper scripts)

## Dataset

The CLI ships with a bundled dataset describing the fictional city of **Metroville**:

- 400 places on a 20x20 grid.
- 1,520 route edges connecting adjacent districts.
- Hand-authored landmark names like "Central Park" and "North Harbor".

You can replace the dataset with your own JSON file using `--data <path>`. See the schema overview in `docs/DATASET.md`.

## Usage

### Search for places

```bash
./scripts/run.sh search --query "Central Park"
```

### Show a place

```bash
./scripts/run.sh show --name "Civic Center"
```

### Route between places

```bash
./scripts/run.sh route --from "Central Park" --to "Old Town Station"
```

### Validate a dataset

```bash
./scripts/run.sh validate
```

### JSON output

Add `--format json` to any command:

```bash
./scripts/run.sh search --query harbor --format json
```

## Verified Quickstart (exact commands run)

```bash
swift --version
./scripts/run.sh search --query "Central Park" --format json
./scripts/run.sh route --from "Central Park" --to "Old Town Station" --format json
./scripts/run.sh show --name "Civic Center"
```

## Verified Verification (exact command run)

```bash
./scripts/verify.sh
```

The verification script builds the package, runs unit tests, and executes an integration smoke test that exercises search and routing.

## Project Layout

- `Sources/MapExplorerCore/` — Core models, dataset loader, search, routing, and formatting.
- `Sources/MapExplorerCLI/` — CLI entrypoint and argument parsing.
- `Tests/MapExplorerCoreTests/` — Unit tests for dataset loading, search, routing, and formatting.
- `scripts/` — Helper scripts for running and verifying the project.
- `docs/` — Dataset schema and operational notes.
- `MapExplorerApp/` — Legacy iOS prototype files (not built by SwiftPM).

## Troubleshooting

- **"Error: Data not found"** — Ensure `places.json` is present in `Sources/MapExplorerCore/Resources/` or pass `--data <path>`.
- **"Missing required argument"** — All CLI commands use explicit `--query`, `--from`, `--to`, or `--name` flags. Run `./scripts/run.sh help` for usage.
- **Swift not found** — Install Swift 6.2+ and re-run the verification script.

## Notes on the iOS Prototype

The storyboard files and `MapExplorerApp/*.swift` controllers remain in the repository for reference. They are not compiled in this Swift Package setup, because MapKit and UIKit are unavailable in this Linux environment. The CLI is the supported, reproducible artifact for this repository.
