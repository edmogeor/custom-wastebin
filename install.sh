#!/bin/bash
#
# SPDX-FileCopyrightText: 2026 edmogeor
# SPDX-License-Identifier: GPL-3.0-or-later
#
# Install Custom Wastebin Plasmoid

PLUGIN_ID="org.kde.plasma.customwastebin"
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
TYPE="Plasma/Applet"

global=false
for arg in "$@"; do
    case "$arg" in
        --global) global=true ;;
    esac
done

if $global; then
    echo "Installing Custom Wastebin widget globally..."
    INSTALL_DIR="/usr/share/plasma/plasmoids/$PLUGIN_ID"
    GLOBAL_FLAG="-g"
    SUDO="sudo"
else
    echo "Installing Custom Wastebin widget for current user..."
    INSTALL_DIR="$HOME/.local/share/plasma/plasmoids/$PLUGIN_ID"
    GLOBAL_FLAG=""
    SUDO=""
fi

if [ -d "$INSTALL_DIR" ]; then
    echo "Existing installation found, upgrading..."
    $SUDO kpackagetool6 -t "$TYPE" $GLOBAL_FLAG -u "$SCRIPT_DIR"
else
    $SUDO kpackagetool6 -t "$TYPE" $GLOBAL_FLAG -i "$SCRIPT_DIR"
fi

if [ $? -eq 0 ]; then
    echo "Installation complete!"
    echo ""
    echo "To use the widget:"
    echo "1. Right-click on your panel or desktop"
    echo "2. Select 'Add Widgets...'"
    echo "3. Search for 'Custom Wastebin'"
    echo "4. Drag it to your panel or desktop"
    echo ""
    echo "You may need to restart Plasma for the widget to appear:"
    echo "  systemctl --user restart plasma-plasmashell.service"
else
    echo "Installation failed."
    exit 1
fi
