#!/bin/bash
set -euo pipefail

INSTALL_DIR="$HOME/.local/share/claude-centos7"
BIN_DIR="$HOME/.local/bin"
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

echo "Installing Claude Code (CentOS 7 patched) to $INSTALL_DIR ..."

mkdir -p "$INSTALL_DIR" "$BIN_DIR"

cp "$SCRIPT_DIR/claude-bin" "$INSTALL_DIR/"
chmod +x "$INSTALL_DIR/claude-bin"
cp -r "$SCRIPT_DIR/libs" "$INSTALL_DIR/"

cat > "$INSTALL_DIR/claude" << WRAPPER
#!/bin/bash
SCRIPT_DIR="$INSTALL_DIR"
exec env LD_LIBRARY_PATH="\$SCRIPT_DIR/libs\${LD_LIBRARY_PATH:+:\$LD_LIBRARY_PATH}" \
     "\$SCRIPT_DIR/libs/ld-musl-x86_64.so.1" \
     "\$SCRIPT_DIR/claude-bin" "\$@"
WRAPPER
chmod +x "$INSTALL_DIR/claude"

ln -sf "$INSTALL_DIR/claude" "$BIN_DIR/claude"

echo "Done! Installed to $INSTALL_DIR"
echo "Symlinked: $BIN_DIR/claude -> $INSTALL_DIR/claude"
echo ""
echo "Add ~/.local/bin to PATH if not already there:"
echo 'export PATH="$HOME/.local/bin:$PATH"'
echo ""
echo "Verify: claude --version"
