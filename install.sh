#!/bin/bash
set -euo pipefail

INSTALL_DIR="$HOME/.local/share/claude-centos7"
BIN_DIR="$HOME/.local/bin"
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

for f in claude-bin libs; do
    if [[ ! -e "$SCRIPT_DIR/$f" ]]; then
        echo "ERROR: '$f' not found next to install.sh." >&2
        echo "Run install.sh from inside the extracted release tarball." >&2
        exit 1
    fi
done

echo "Installing Claude Code (CentOS 7 patched) to $INSTALL_DIR ..."

mkdir -p "$INSTALL_DIR" "$BIN_DIR"

cp "$SCRIPT_DIR/claude-bin" "$INSTALL_DIR/"
chmod +x "$INSTALL_DIR/claude-bin"
cp -r "$SCRIPT_DIR/libs" "$INSTALL_DIR/"

cat > "$INSTALL_DIR/claude" << 'WRAPPER'
#!/bin/bash
SCRIPT_DIR="__INSTALL_DIR__"
exec env LD_LIBRARY_PATH="$SCRIPT_DIR/libs${LD_LIBRARY_PATH:+:$LD_LIBRARY_PATH}" \
     "$SCRIPT_DIR/libs/ld-musl-x86_64.so.1" \
     "$SCRIPT_DIR/claude-bin" "$@"
WRAPPER
sed -i "s|__INSTALL_DIR__|$INSTALL_DIR|" "$INSTALL_DIR/claude"
chmod +x "$INSTALL_DIR/claude"

ln -sf "$INSTALL_DIR/claude" "$BIN_DIR/claude"

echo "Done! Installed to $INSTALL_DIR"
echo "Symlinked: $BIN_DIR/claude -> $INSTALL_DIR/claude"
echo ""

if [[ ":$PATH:" != *":$BIN_DIR:"* ]]; then
    echo "Add ~/.local/bin to PATH — run this once:"
    echo "  echo 'export PATH=\"\$HOME/.local/bin:\$PATH\"' >> ~/.bashrc && source ~/.bashrc"
    echo ""
fi
echo "Verify: claude --version"
