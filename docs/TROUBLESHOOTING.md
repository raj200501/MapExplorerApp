# Troubleshooting

## CLI returns "Missing required argument"

All commands require explicit flags. Example:

```bash
./scripts/run.sh search --query "Central Park"
```

## "Data not found" or "Invalid data"

- Confirm that `Sources/MapExplorerCore/Resources/places.json` exists.
- If using `--data`, check the file path and JSON syntax.
- Run:

```bash
./scripts/run.sh validate --data ./my-dataset.json
```

## Swift toolchain issues

- Ensure `swift --version` reports 6.2+.
- If Swift is missing, install it from https://www.swift.org/install/.

## Route output is empty

If no route exists between the selected places:

- Check that the `routes` array connects the origin and destination IDs.
- Add more edges to the dataset or choose a different origin/destination.

## Formatting output for scripts

For programmatic use, prefer JSON format:

```bash
./scripts/run.sh route --from "Central Park" --to "Old Town Station" --format json
```
