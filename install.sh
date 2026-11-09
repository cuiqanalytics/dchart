#!/bin/sh
# install.sh — install dchart into ~/.local (no root needed). Linux and macOS, x86-64 or arm64.
#
#   curl -fsSL https://cuiqanalytics.github.io/dchart/install.sh | sh
#
# Re-running it replaces the previous install (upgrade in place). DCHART_URL overrides the
# download location (a file:// URL works too, for testing a local build).
# On Windows, use install.ps1 instead.
set -eu

repo="cuiqanalytics/dchart"
lib_dir="${HOME}/.local/lib/dchart"
bin_dir="${HOME}/.local/bin"

case "$(uname -s)/$(uname -m)" in
	Linux/x86_64|Linux/amd64)   platform=linux-x86_64 ;;
	Linux/aarch64|Linux/arm64)  platform=linux-arm64 ;;
	Darwin/arm64)               platform=macos-arm64 ;;
	Darwin/x86_64)              platform=macos-x86_64 ;;
	*) echo "dchart has no build for $(uname -s) $(uname -m)."
	   echo "Builds exist for Linux and macOS (x86-64, arm64) and Windows x86-64 (install.ps1)."
	   exit 1 ;;
esac
name="dchart-cli-${platform}"
url="${DCHART_URL:-https://github.com/${repo}/releases/latest/download/${name}.tar.gz}"

echo "Downloading ${url}"
tmp=$(mktemp -d)
trap 'rm -rf "$tmp"' EXIT
curl -fsSL --retry 3 --retry-delay 2 "$url" | tar xz -C "$tmp"

rm -rf "$lib_dir"
mkdir -p "$(dirname "$lib_dir")"
mv "$tmp/$name" "$lib_dir"

# dchart finds its libduckdb next to the real binary, so a plain symlink is enough
mkdir -p "$bin_dir"
ln -sf "$lib_dir/dchart" "$bin_dir/dchart"

echo "Installed to $lib_dir"
echo "Linked $bin_dir/dchart -> $lib_dir/dchart"

case ":$PATH:" in
	*":$bin_dir:"*) ;;
	*) echo "Add $bin_dir to your PATH (e.g. in ~/.bashrc or ~/.zshrc): export PATH=\"$bin_dir:\$PATH\"" ;;
esac

"$bin_dir/dchart" --version
echo "Try it: dchart --folder $lib_dir/examples/data   (then open http://localhost:4322)"
