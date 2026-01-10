# QuitLoL - Nuclear League of Legends Blocker

A comprehensive, multi-layered blocking system for **Windows and macOS** that makes playing League of Legends extremely difficult.

## Platform Support

- ✅ **Windows** (PowerShell scripts)
- ✅ **macOS** (Bash scripts)

## What This Does

This blocker implements multiple layers of protection:

1. **Network Blocking**: Blocks all League of Legends and Riot Games domains via hosts file
2. **Process Killer**: A background service that continuously monitors and kills League processes
3. **File Permissions**: Makes League installation directories non-executable (or removes execute permissions)
4. **Auto-Start**: Guardian service runs on system boot
5. **Cleanup**: Removes existing League installations

## Installation

**WARNING**: This will immediately block League of Legends. Make sure you're ready.

### Windows

1. **Right-click** on `block_league.ps1`
2. Select **"Run with PowerShell"** (as Administrator)
3. If you get an execution policy error, run this first in PowerShell (as Admin):
   ```powershell
   Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope CurrentUser
   ```

Alternatively, from an Administrator PowerShell:
```powershell
.\block_league.ps1
```

### macOS

```bash
chmod +x block_league.sh
sudo ./block_league.sh
```

You'll need to enter your admin password.

## What Gets Blocked

- All Riot Games domains (riotgames.com, riot.com, etc.)
- All League of Legends domains (all regions: NA, EUW, EUNE, KR, etc.)
- Update and patch servers
- Authentication servers
- API and support sites

**40+ domains blocked in total**

## Blocked Processes

The guardian continuously kills these processes every 2 seconds:

**Windows:**
- League.exe
- LeagueClient.exe
- RiotClientServices.exe
- RiotClientUx.exe

**macOS:**
- League
- LeagueClient
- RiotClient
- Riot Client
- LeagueOfLegends

## How Hard Is It To Reverse?

**Moderately difficult** - requires technical knowledge but not impossible:

- **Windows**: Need to use Task Scheduler, edit hosts file, understand system services
- **macOS**: Need to use Terminal, sudo commands, understand LaunchDaemons

This creates enough friction to make you think twice, but won't brick your system.

## Uninstallation

If you really want to undo this (think carefully):

### Windows

**Right-click** on `uninstall_block.ps1` and select **"Run with PowerShell"** (as Administrator)

Or manually:
1. Open **Task Scheduler**
2. Delete the task named `QuitLoL_Guardian`
3. Open Notepad **as Administrator**
4. Open `C:\Windows\System32\drivers\etc\hosts`
5. Delete the section between `# QUITLOL_BLOCK_START` and `# QUITLOL_BLOCK_END`
6. Save the file

### macOS

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

### Windows
- `C:\Windows\System32\drivers\etc\hosts` - Modified with domain blocks
- `C:\ProgramData\QuitLoL\guardian.ps1` - Process killer script
- Task Scheduler: `QuitLoL_Guardian` - Scheduled task
- `C:\ProgramData\QuitLoL\hosts.backup.*` - Backup files

### macOS
- `/etc/hosts` - Modified with domain blocks
- `/Library/LaunchDaemons/com.quitlol.guardian.plist` - Daemon config
- `/usr/local/bin/quitlol_guardian.sh` - Process killer script
- `/var/quitlol_backup/` - Backup directory

## Philosophy

This tool is for people who genuinely want to quit League of Legends but struggle with impulse control. It creates enough friction to give you time to reconsider, without being truly irreversible.

If you're trying to disable this blocker, ask yourself: **Why did you install it?**

## Technical Details

### Windows Implementation
- Uses PowerShell scripts with execution policy bypass
- Creates a Windows Scheduled Task that runs at startup with SYSTEM privileges
- Modifies ACLs to deny execute permissions on League executables
- Runs continuously in the background with auto-restart on failure

### macOS Implementation
- Uses Bash scripts with root privileges
- Creates a LaunchDaemon that runs at boot
- Uses chmod to remove execute permissions
- Runs as a persistent background process

## Troubleshooting

### Windows

**"Cannot be loaded because running scripts is disabled"**:
```powershell
Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope CurrentUser
```

**"Access Denied"**: Right-click PowerShell and select "Run as Administrator"

**Task not running**: Open Task Scheduler and check the QuitLoL_Guardian task status

### macOS

**"Permission denied" errors**: Run with `sudo`

**Daemon not starting**: Check `/tmp/quitlol_guardian.err` for errors

**Already installed League after blocking**: The daemon will continuously kill it and make the app non-executable

## Contributing

Feel free to submit issues or pull requests if you want to improve the blocker or add support for other platforms (Linux?).

## Star This Repo

If this helped you quit League, give it a star! Help others break free.

## Good Luck

You've made the right choice. Stay strong.

Remember: The game is designed to be addictive. Breaking free takes courage.
