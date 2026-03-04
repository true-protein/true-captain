#!/bin/bash
#
# True Captain — Remote Installer
#
# One-liner install:
#   bash <(curl -s https://raw.githubusercontent.com/true-protein/true-captain/main/install-remote.sh)
#
# Clones the repo to a temp directory, runs the installer, then cleans up.
#

set -e

REPO_URL="https://github.com/true-protein/true-captain.git"
TEMP_DIR="$(mktemp -d)"

cleanup() {
    rm -rf "$TEMP_DIR"
}
trap cleanup EXIT

echo ""
echo "  Downloading True Captain..."
echo ""

git clone --quiet --depth 1 "$REPO_URL" "$TEMP_DIR"

"$TEMP_DIR/install.sh"
