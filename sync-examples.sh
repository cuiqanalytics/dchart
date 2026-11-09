#!/usr/bin/env bash
# sync-examples.sh — copy the source repo's examples/ here, so the page's links match what
# the release archives ship. Binaries are built by CI in cuiqanalytics/dchart-src
# (.github/workflows/release.yml), not here.
set -euo pipefail
cd "$(dirname "$0")"
SRC=${DCHART_SRC:-../dchart}
rm -rf examples && cp -r "$SRC/examples" examples
rm -f examples/*.duckdb examples/*.duckdb.wal
echo "Synced examples/ from $SRC"
