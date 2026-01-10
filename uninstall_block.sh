#!/bin/bash

# League of Legends Blocker - Uninstall Script
# You shouldn't be running this. But if you must...

set -e

echo "🤔 League of Legends Blocker - Uninstall"
echo "========================================"
echo ""
echo "Are you SURE you want to remove the blocker?"
echo "Think about why you installed it in the first place."
echo ""
read -p "Type 'I WANT TO WASTE MY TIME' to continue: " confirmation

if [ "$confirmation" != "I WANT TO WASTE MY TIME" ]; then
    echo "❌ Uninstallation cancelled. Good choice."
    exit 1
fi

# Check if running as root
if [ "$EUID" -ne 0 ]; then
    echo "❌ This script must be run as root (use sudo)"
    exit 1
fi

echo ""
echo "😔 Removing blocker..."

# Unload daemon
echo "  • Unloading guardian daemon..."
launchctl unload /Library/LaunchDaemons/com.quitlol.guardian.plist 2>/dev/null || true

# Remove daemon files
echo "  • Removing daemon files..."
rm -f /Library/LaunchDaemons/com.quitlol.guardian.plist
rm -f /usr/local/bin/quitlol_guardian.sh

# Remove hosts file entries
echo "  • Removing hosts file blocks..."
HOSTS_FILE="/etc/hosts"
HOSTS_MARKER="# QUITLOL_BLOCK_START"
HOSTS_MARKER_END="# QUITLOL_BLOCK_END"

cp "$HOSTS_FILE" "$HOSTS_FILE.backup"
sed -i '' "/$HOSTS_MARKER/,/$HOSTS_MARKER_END/d" "$HOSTS_FILE"

echo ""
echo "✓ Blocker removed."
echo ""
echo "Remember: You had a good reason for installing this."
echo "Are you making the right choice?"
