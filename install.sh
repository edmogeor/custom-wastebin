#!/bin/bash

# Install Custom Wastebin Plasmoid

PLASMOID_DIR="$HOME/.local/share/plasma/plasmoids/org.kde.plasma.customwastebin"

echo "Installing Custom Wastebin widget..."

# Remove old installation if exists
if [ -d "$PLASMOID_DIR" ]; then
    echo "Removing old installation..."
    rm -rf "$PLASMOID_DIR"
fi

# Create directory
mkdir -p "$PLASMOID_DIR"

# Copy files
cp -r "$(dirname "$0")"/* "$PLASMOID_DIR/"

# Remove install script from installation
rm -f "$PLASMOID_DIR/install.sh"
rm -f "$PLASMOID_DIR/uninstall.sh"

echo "Installation complete!"
echo ""
echo "To use the widget:"
echo "1. Right-click on your panel or desktop"
echo "2. Select 'Add Widgets...'"
echo "3. Search for 'Custom Wastebin'"
echo "4. Drag it to your panel or desktop"
echo ""
echo "To configure custom icons:"
echo "1. Right-click on the widget"
echo "2. Select 'Configure Custom Wastebin...'"
echo "3. Click on the icon buttons to choose your icons"
echo ""
echo "You may need to restart Plasma for the widget to appear:"
echo "  kquitapp6 plasmashell && kstart plasmashell"
