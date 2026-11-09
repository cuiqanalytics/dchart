#!/bin/sh
# install.sh — install dchart into ~/.local (no root needed).
#
#   curl -fsSL https://cuiqanalytics.github.io/dchart/install.sh | sh
#
# Re-running it replaces the previous install (upgrade in place). DCHART_URL overrides the
# download location (a file:// URL works too, for testing a local build).
set -eu

repo="cuiqanalytics/dchart"
lib_dir="${HOME}/.local/lib/dchart"
bin_dir="${HOME}/.local/bin"
url="${DCHART_URL:-https://github.com/${repo}/releases/latest/download/dchart-cli-linux-x86_64.tar.gz}"

case "$(uname -s)/$(uname -m)" in
	Linux/x86_64) ;;
	*) echo "dchart ships a Linux x86_64 binary only. On Windows, run this in WSL."
	   exit 1 ;;
esac

echo "Downloading ${url}"
tmp=$(mktemp -d)
trap 'rm -rf "$tmp"' EXIT
curl -fsSL --retry 3 --retry-delay 2 "$url" | tar xz -C "$tmp"

rm -rf "$lib_dir"
mkdir -p "$(dirname "$lib_dir")"
mv "$tmp/dchart-cli-linux-x86_64" "$lib_dir"

mkdir -p "$bin_dir"
ln -sf "$lib_dir/dchart" "$bin_dir/dchart"

echo "Installed to $lib_dir"
echo "Linked $bin_dir/dchart -> $lib_dir/dchart"

case ":$PATH:" in
	*":$bin_dir:"*) ;;
	*) echo "Add $bin_dir to your PATH (e.g. in ~/.bashrc): export PATH=\"$bin_dir:\$PATH\"" ;;
esac

"$bin_dir/dchart" --version
echo "Try it: dchart --folder $lib_dir/examples/data   (then open http://localhost:4322)"
