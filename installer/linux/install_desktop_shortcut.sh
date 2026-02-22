#!/usr/bin/env bash
set -euo pipefail

APP_NAME="Alyaa Florist"
APP_ID="com.alyaa.florist"
ICON_SOURCE="$(cd "$(dirname "$0")/../.." && pwd)/assets/logo_main.png"
EXEC_PATH="${1:-$(cd "$(dirname "$0")/../.." && pwd)/build/linux/x64/release/bundle/alyaa_florist}"

mkdir -p "$HOME/.local/share/icons/hicolor/256x256/apps"
cp -f "$ICON_SOURCE" "$HOME/.local/share/icons/hicolor/256x256/apps/${APP_ID}.png"

mkdir -p "$HOME/.local/share/applications"
cat > "$HOME/.local/share/applications/${APP_ID}.desktop" <<EOF
[Desktop Entry]
Name=${APP_NAME}
Comment=Aplikasi kwitansi Alyaa Florist
Exec=${EXEC_PATH}
Icon=${APP_ID}
Terminal=false
Type=Application
Categories=Office;
StartupNotify=true
EOF

chmod +x "$HOME/.local/share/applications/${APP_ID}.desktop"
update-desktop-database "$HOME/.local/share/applications" >/dev/null 2>&1 || true

echo "Desktop shortcut installed: $HOME/.local/share/applications/${APP_ID}.desktop"
