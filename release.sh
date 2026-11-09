#!/usr/bin/env bash
# release.sh — build dist/dchart-cli-linux-x86_64.tar.gz, the tarball install.sh downloads.
# Upload it to a GitHub release of cuiqanalytics/dchart.
#
#   ./release.sh              build from source, then package
#   ./release.sh --no-build   package the binary already in $DCHART_SRC
#
# It also copies the source repo's examples/ here, so the page's links and the tarball match.
set -euo pipefail
cd "$(dirname "$0")"

SRC=${DCHART_SRC:-../dchart}
LIBDUCKDB=${LIBDUCKDB:-../vduckdb/src/thirdparty/libduckdb.so}
NAME=dchart-cli-linux-x86_64
OUT=dist/$NAME

version=$(cat VERSION)
src_version=$(sed -n "s/.*version: *'\([^']*\)'.*/\1/p" "$SRC/v.mod")
[[ "$version" == "$src_version" ]] || { echo "error: VERSION ($version) != v.mod ($src_version)" >&2; exit 1; }

[[ "${1:-}" == --no-build ]] || make -C "$SRC" build
[[ -x "$SRC/dchart" ]] || { echo "error: $SRC/dchart not found" >&2; exit 1; }
[[ -f "$LIBDUCKDB" ]] || { echo "error: libduckdb.so not found at $LIBDUCKDB" >&2; exit 1; }

rm -rf "$OUT" && mkdir -p "$OUT/bin"
cp "$SRC/dchart" "$OUT/bin/dchart"
cp "$LIBDUCKDB" "$OUT/bin/libduckdb.so"
python3 -c "import ctypes,sys; l=ctypes.CDLL(sys.argv[1]); l.duckdb_library_version.restype=ctypes.c_char_p; print(l.duckdb_library_version().decode())" \
  "$OUT/bin/libduckdb.so" > "$OUT/bin/DUCKDB_VERSION"

# The launcher points dchart at the bundled libduckdb.so, wherever the install lives.
cat > "$OUT/dchart" <<'LAUNCHER'
#!/bin/sh
self=$(readlink -f "$0")
dir=$(dirname "$self")
LIBDUCKDB_DIR="$dir/bin" LD_LIBRARY_PATH="$dir/bin${LD_LIBRARY_PATH:+:$LD_LIBRARY_PATH}" exec "$dir/bin/dchart" "$@"
LAUNCHER
chmod +x "$OUT/dchart" "$OUT/bin/dchart"

# examples: the source repo's copy is the one that's tested; keep this repo's in sync
rm -rf examples && cp -r "$SRC/examples" examples
rm -f examples/*.duckdb examples/*.duckdb.wal
cp -r examples "$OUT/examples"
cp README.md QUICK_REFERENCE.md LICENSE VERSION "$OUT/"

# smoke test: the staged launcher starts and reports the right version
"$OUT/dchart" --version | grep -q "$version" || { echo "error: staged dchart doesn't report $version" >&2; exit 1; }

tar -C dist -czf "dist/$NAME.tar.gz" "$NAME"
echo "Wrote dist/$NAME.tar.gz ($(du -h "dist/$NAME.tar.gz" | cut -f1)), DuckDB $(cat "$OUT/bin/DUCKDB_VERSION")"
