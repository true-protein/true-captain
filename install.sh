#!/bin/bash
#
# True Captain Installer
#
# Installs Claude Code skills to ~/.claude/skills/ so they work
# from any directory. Run this once after downloading.
#

set -e

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
SKILLS_SOURCE="$SCRIPT_DIR/.claude/skills"
SKILLS_TARGET="$HOME/.claude/skills"
VERSION_FILE="$SCRIPT_DIR/VERSION"

VERSION="unknown"
if [ -f "$VERSION_FILE" ]; then
    VERSION="$(cat "$VERSION_FILE" | tr -d '[:space:]')"
fi

echo ""
echo "  True Captain Installer  (v$VERSION)"
echo "  ========================"
echo ""

# Check source exists
if [ ! -d "$SKILLS_SOURCE" ]; then
    echo "  Error: Could not find skills in $SKILLS_SOURCE"
    echo "  Make sure you're running this from the true-captain directory."
    exit 1
fi

# Create target directory
mkdir -p "$SKILLS_TARGET"

# Copy each skill
SKILLS=(true triage mail reply reply-with-availability weekly)
INSTALLED=0

for skill in "${SKILLS[@]}"; do
    if [ -d "$SKILLS_SOURCE/$skill" ]; then
        if [ -d "$SKILLS_TARGET/$skill" ]; then
            echo "  Updating: /$skill"
        else
            echo "  Installing: /$skill"
        fi
        cp -r "$SKILLS_SOURCE/$skill" "$SKILLS_TARGET/"
        INSTALLED=$((INSTALLED + 1))
    fi
done

# Copy version file
cp "$VERSION_FILE" "$SKILLS_TARGET/.true-utils-version"

echo ""
echo "  Installed $INSTALLED skills (v$VERSION) to $SKILLS_TARGET"
echo ""
echo "  Next steps:"
echo "  1. Open Claude Code (from any directory)"
echo "  2. Run /true setup to configure your preferences"
echo "  3. Run /triage to start triaging your inbox"
echo "  4. Run /true to see all commands"
echo ""
