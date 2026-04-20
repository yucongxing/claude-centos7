#!/bin/bash
set -euo pipefail

INSTALL_DIR="$HOME/.local/share/claude-centos7"
BIN_LINK="$HOME/.local/bin/claude"

if [ -L "$BIN_LINK" ] && [ "$(readlink "$BIN_LINK")" = "$INSTALL_DIR/claude" ]; then
    rm "$BIN_LINK"
    echo "Removed symlink: $BIN_LINK"
else
    echo "No symlink found at $BIN_LINK (may have been installed differently)"
fi

if [ -d "$INSTALL_DIR" ]; then
    rm -rf "$INSTALL_DIR"
    echo "Removed: $INSTALL_DIR"
else
    echo "No installation found at $INSTALL_DIR"
fi

echo "Claude Code (CentOS 7 patch) uninstalled."
