#!/bin/bash

# League of Legends Nuclear Blocker
# This script blocks League of Legends at multiple levels

set -e

echo "🚫 League of Legends Nuclear Blocker"
echo "===================================="
echo ""

# Check if running as root
if [ "$EUID" -ne 0 ]; then
    echo "❌ This script must be run as root (use sudo)"
    exit 1
fi

BACKUP_DIR="/var/quitlol_backup"
HOSTS_FILE="/etc/hosts"
HOSTS_MARKER="# QUITLOL_BLOCK_START"
HOSTS_MARKER_END="# QUITLOL_BLOCK_END"

# Create backup directory
mkdir -p "$BACKUP_DIR"
chmod 700 "$BACKUP_DIR"

echo "📝 Step 1: Backing up current hosts file..."
cp "$HOSTS_FILE" "$BACKUP_DIR/hosts.backup.$(date +%s)"

echo "🔒 Step 2: Adding League of Legends domain blocks to hosts file..."

# Remove old blocks if they exist
sed -i '' "/$HOSTS_MARKER/,/$HOSTS_MARKER_END/d" "$HOSTS_FILE"

# Add comprehensive League/Riot blocks
cat >> "$HOSTS_FILE" << 'EOF'

# QUITLOL_BLOCK_START - DO NOT REMOVE THIS LINE
# League of Legends / Riot Games Server Blocks
# Removing these entries will only delay your progress. You chose this.

# North America
127.0.0.1 riotgames.com
127.0.0.1 www.riotgames.com
127.0.0.1 leagueoflegends.com
127.0.0.1 www.leagueoflegends.com
127.0.0.1 na.leagueoflegends.com
127.0.0.1 signup.leagueoflegends.com
127.0.0.1 signup.na.leagueoflegends.com

# Riot Client & Services
127.0.0.1 riot.com
127.0.0.1 www.riot.com
127.0.0.1 auth.riotgames.com
127.0.0.1 authenticate.riotgames.com
127.0.0.1 ledge.leagueoflegends.com
127.0.0.1 status.leagueoflegends.com
127.0.0.1 maestro.riotgames.com
127.0.0.1 clientconfig.rpg.riotgames.com

# Regional Servers
127.0.0.1 euw.leagueoflegends.com
127.0.0.1 eune.leagueoflegends.com
127.0.0.1 kr.leagueoflegends.com
127.0.0.1 br.leagueoflegends.com
127.0.0.1 tr.leagueoflegends.com
127.0.0.1 ru.leagueoflegends.com
127.0.0.1 lan.leagueoflegends.com
127.0.0.1 las.leagueoflegends.com
127.0.0.1 oce.leagueoflegends.com
127.0.0.1 jp.leagueoflegends.com

# Patch & Update Servers
127.0.0.1 l3cdn.riotgames.com
127.0.0.1 worldwide.l3cdn.riotgames.com
127.0.0.1 lol.secure.dyn.riotcdn.net
127.0.0.1 lolstatic-a.akamaihd.net

# API & Support
127.0.0.1 developer.riotgames.com
127.0.0.1 support.riotgames.com
127.0.0.1 support-leagueoflegends.riotgames.com

# QUITLOL_BLOCK_END - DO NOT REMOVE THIS LINE
EOF

echo "⚙️  Step 3: Creating process killer daemon..."

# Create the process killer script
cat > /usr/local/bin/quitlol_guardian.sh << 'SCRIPTEOF'
#!/bin/bash

# QuitLoL Guardian - Continuously kills League processes
# If you're reading this trying to disable it, ask yourself: is this really how you want to spend your time?

while true; do
    # Kill League of Legends processes
    pkill -9 -f "League" 2>/dev/null
    pkill -9 -f "LeagueClient" 2>/dev/null
    pkill -9 -f "RiotClient" 2>/dev/null
    pkill -9 -f "Riot Client" 2>/dev/null
    pkill -9 -f "LeagueOfLegends" 2>/dev/null

    # Check for League installation and make it unexecutable
    if [ -d "/Applications/League of Legends.app" ]; then
        chmod -R 000 "/Applications/League of Legends.app" 2>/dev/null
    fi

    if [ -d "$HOME/Applications/League of Legends.app" ]; then
        chmod -R 000 "$HOME/Applications/League of Legends.app" 2>/dev/null
    fi

    sleep 2
done
SCRIPTEOF

chmod +x /usr/local/bin/quitlol_guardian.sh

echo "🔧 Step 4: Creating LaunchDaemon for persistent blocking..."

# Create LaunchDaemon plist
cat > /Library/LaunchDaemons/com.quitlol.guardian.plist << 'PLISTEOF'
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
    <key>Label</key>
    <string>com.quitlol.guardian</string>
    <key>ProgramArguments</key>
    <array>
        <string>/usr/local/bin/quitlol_guardian.sh</string>
    </array>
    <key>RunAtLoad</key>
    <true/>
    <key>KeepAlive</key>
    <true/>
    <key>StandardErrorPath</key>
    <string>/tmp/quitlol_guardian.err</string>
    <key>StandardOutPath</key>
    <string>/tmp/quitlol_guardian.out</string>
</dict>
</plist>
PLISTEOF

chmod 644 /Library/LaunchDaemons/com.quitlol.guardian.plist
chown root:wheel /Library/LaunchDaemons/com.quitlol.guardian.plist

echo "🚀 Step 5: Loading the guardian daemon..."
launchctl load /Library/LaunchDaemons/com.quitlol.guardian.plist 2>/dev/null || true

echo "🗑️  Step 6: Attempting to remove League installation..."
if [ -d "/Applications/League of Legends.app" ]; then
    chmod -R 755 "/Applications/League of Legends.app"
    rm -rf "/Applications/League of Legends.app"
    echo "   ✓ Removed /Applications/League of Legends.app"
fi

if [ -d "$HOME/Applications/League of Legends.app" ]; then
    chmod -R 755 "$HOME/Applications/League of Legends.app"
    rm -rf "$HOME/Applications/League of Legends.app"
    echo "   ✓ Removed $HOME/Applications/League of Legends.app"
fi

# Remove Riot Client too
if [ -d "/Applications/Riot Client.app" ]; then
    rm -rf "/Applications/Riot Client.app"
    echo "   ✓ Removed /Applications/Riot Client.app"
fi

echo ""
echo "✅ League of Legends has been BLOCKED"
echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "What's been done:"
echo "  • All League/Riot domains blocked in /etc/hosts"
echo "  • Process killer daemon installed and running"
echo "  • League installation removed (if found)"
echo "  • Guardian daemon will auto-start on boot"
echo ""
echo "To undo (requires technical knowledge):"
echo "  1. sudo launchctl unload /Library/LaunchDaemons/com.quitlol.guardian.plist"
echo "  2. sudo rm /Library/LaunchDaemons/com.quitlol.guardian.plist"
echo "  3. sudo rm /usr/local/bin/quitlol_guardian.sh"
echo "  4. sudo vi /etc/hosts (remove QUITLOL_BLOCK section)"
echo ""
echo "But ask yourself: is that really what you want?"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
