#!/bin/bash
#
# SPDX-FileCopyrightText: 2026 edmogeor
# SPDX-License-Identifier: GPL-3.0-or-later
#
# Uninstall Custom Wastebin Plasmoid

PLUGIN_ID="org.kde.plasma.customwastebin"
TYPE="Plasma/Applet"
LOCAL_DIR="$HOME/.local/share/plasma/plasmoids/$PLUGIN_ID"
GLOBAL_DIR="/usr/share/plasma/plasmoids/$PLUGIN_ID"

found=false

if [ -d "$LOCAL_DIR" ]; then
    echo "Removing user-local installation..."
    kpackagetool6 -t "$TYPE" -r "$PLUGIN_ID"
    found=true
fi

if [ -d "$GLOBAL_DIR" ]; then
    echo "Removing global installation..."
    sudo kpackagetool6 -t "$TYPE" -g -r "$PLUGIN_ID"
    found=true
fi

if $found; then
    echo "Widget removed."
    echo ""
    echo "Restart Plasma to complete removal:"
    echo "  systemctl --user restart plasma-plasmashell.service"
else
    echo "Widget not found."
fi
