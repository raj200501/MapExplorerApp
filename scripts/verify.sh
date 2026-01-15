#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$ROOT_DIR"

swift build
swift test

SEARCH_OUTPUT=$(swift run map-explorer search --query "Central Park" --format json)
export SEARCH_OUTPUT
python - <<'PY'
import json, sys, os
payload = json.loads(os.environ["SEARCH_OUTPUT"])
if not payload:
    print("Search returned no results")
    sys.exit(1)
if payload[0]["name"] != "Central Park":
    print("Expected Central Park, got", payload[0]["name"])
    sys.exit(1)
PY

ROUTE_OUTPUT=$(swift run map-explorer route --from "Central Park" --to "Old Town Station" --format json)
export ROUTE_OUTPUT
python - <<'PY'
import json, sys, os
payload = json.loads(os.environ["ROUTE_OUTPUT"])
if payload.get("totalDistanceKm", 0) <= 0:
    print("Route distance is not positive")
    sys.exit(1)
if len(payload.get("steps", [])) == 0:
    print("Route has no steps")
    sys.exit(1)
PY

swift run map-explorer validate

printf "Verification complete.\n"
