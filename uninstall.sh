#!/bin/bash

# Uninstall Custom Wastebin Plasmoid

PLASMOID_DIR="$HOME/.local/share/plasma/plasmoids/org.kde.plasma.customwastebin"

echo "Uninstalling Custom Wastebin widget..."

if [ -d "$PLASMOID_DIR" ]; then
    rm -rf "$PLASMOID_DIR"
    echo "Widget removed."
    echo ""
    echo "Restart Plasma to complete removal:"
    echo "  kquitapp6 plasmashell && kstart plasmashell"
else
    echo "Widget not found at $PLASMOID_DIR"
fi
