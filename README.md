# QuitLoL - Nuclear League of Legends Blocker

A comprehensive, multi-layered blocking system for macOS that makes playing League of Legends extremely difficult.

## What This Does

This blocker implements multiple layers of protection:

1. **Network Blocking**: Blocks all League of Legends and Riot Games domains via `/etc/hosts`
2. **Process Killer**: A daemon that continuously monitors and kills League processes
3. **File Permissions**: Makes League installation directories non-executable
4. **Auto-Start**: Guardian daemon runs on system boot
5. **Cleanup**: Removes existing League installations

## Installation

**WARNING**: This will immediately block League of Legends. Make sure you're ready.

```bash
chmod +x block_league.sh
sudo ./block_league.sh
```

You'll need to enter your admin password.

## What Gets Blocked

- All Riot Games domains (riotgames.com, riot.com, etc.)
- All League of Legends domains (all regions)
- Update and patch servers
- Authentication servers
- API and support sites

## Blocked Processes

The guardian daemon kills these processes every 2 seconds:

- League
- LeagueClient
- RiotClient
- Riot Client
- LeagueOfLegends

## How Hard Is It To Reverse?

**Moderately difficult** - requires technical knowledge but not impossible:

- You'll need to use Terminal and sudo commands
- Requires editing system files
- Need to understand LaunchDaemons

This creates enough friction to make you think twice, but won't brick your system.

## Uninstallation

If you really want to undo this (think carefully):

```bash
chmod +x uninstall_block.sh
sudo ./uninstall_block.sh
```

Or manually:

```bash
# Stop the daemon
sudo launchctl unload /Library/LaunchDaemons/com.quitlol.guardian.plist

# Remove daemon files
sudo rm /Library/LaunchDaemons/com.quitlol.guardian.plist
sudo rm /usr/local/bin/quitlol_guardian.sh

# Edit hosts file and remove QUITLOL_BLOCK section
sudo nano /etc/hosts
```

## Files Created

- `/etc/hosts` - Modified with domain blocks
- `/Library/LaunchDaemons/com.quitlol.guardian.plist` - Daemon config
- `/usr/local/bin/quitlol_guardian.sh` - Process killer script
- `/var/quitlol_backup/` - Backup directory

## Philosophy

This tool is for people who genuinely want to quit League of Legends but struggle with impulse control. It creates enough friction to give you time to reconsider, without being truly irreversible.

If you're trying to disable this blocker, ask yourself: **Why did you install it?**

## Notes

- The daemon runs with root privileges (required to modify system files)
- Backups of your hosts file are stored in `/var/quitlol_backup/`
- The guardian daemon logs to `/tmp/quitlol_guardian.out` and `.err`
- Works on macOS (tested on modern versions)

## Troubleshooting

**"Permission denied" errors**: Run with `sudo`

**Daemon not starting**: Check `/tmp/quitlol_guardian.err` for errors

**Already installed League after blocking**: The daemon will continuously kill it and make the app non-executable

## Good Luck

You've made the right choice. Stay strong.
