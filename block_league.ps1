# League of Legends Nuclear Blocker - Windows Edition
# This script blocks League of Legends at multiple levels
# Must be run as Administrator

#Requires -RunAsAdministrator

Write-Host "🚫 League of Legends Nuclear Blocker (Windows)" -ForegroundColor Red
Write-Host "===============================================" -ForegroundColor Red
Write-Host ""

$ErrorActionPreference = "Stop"

$HOSTS_FILE = "$env:SystemRoot\System32\drivers\etc\hosts"
$BACKUP_DIR = "$env:ProgramData\QuitLoL"
$HOSTS_MARKER = "# QUITLOL_BLOCK_START"
$HOSTS_MARKER_END = "# QUITLOL_BLOCK_END"
$GUARDIAN_SCRIPT = "$BACKUP_DIR\guardian.ps1"
$TASK_NAME = "QuitLoL_Guardian"

# Create backup directory
Write-Host "📁 Step 1: Creating backup directory..." -ForegroundColor Yellow
if (-not (Test-Path $BACKUP_DIR)) {
    New-Item -ItemType Directory -Path $BACKUP_DIR -Force | Out-Null
}

# Backup hosts file
Write-Host "📝 Step 2: Backing up hosts file..." -ForegroundColor Yellow
$timestamp = Get-Date -Format "yyyyMMdd_HHmmss"
Copy-Item $HOSTS_FILE "$BACKUP_DIR\hosts.backup.$timestamp"

# Remove old blocks if they exist
Write-Host "🔒 Step 3: Adding domain blocks to hosts file..." -ForegroundColor Yellow
$hostsContent = Get-Content $HOSTS_FILE
$newContent = @()
$inBlock = $false

foreach ($line in $hostsContent) {
    if ($line -match [regex]::Escape($HOSTS_MARKER)) {
        $inBlock = $true
        continue
    }
    if ($line -match [regex]::Escape($HOSTS_MARKER_END)) {
        $inBlock = $false
        continue
    }
    if (-not $inBlock) {
        $newContent += $line
    }
}

# Write cleaned content
$newContent | Set-Content $HOSTS_FILE

# Add comprehensive League/Riot blocks
$blocksToAdd = @"

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
"@

Add-Content -Path $HOSTS_FILE -Value $blocksToAdd

# Flush DNS cache
Write-Host "🔄 Step 4: Flushing DNS cache..." -ForegroundColor Yellow
ipconfig /flushdns | Out-Null

# Create the guardian script
Write-Host "⚙️  Step 5: Creating process killer guardian..." -ForegroundColor Yellow

$guardianScript = @'
# QuitLoL Guardian - Continuously kills League processes
# If you're reading this trying to disable it, ask yourself: is this really how you want to spend your time?

while ($true) {
    # Kill League of Legends processes
    Get-Process | Where-Object {
        $_.ProcessName -match "League" -or
        $_.ProcessName -match "Riot" -or
        $_.ProcessName -match "LeagueClient" -or
        $_.ProcessName -match "RiotClientServices" -or
        $_.ProcessName -match "RiotClientUx"
    } | Stop-Process -Force -ErrorAction SilentlyContinue

    # Common League installation paths
    $leaguePaths = @(
        "C:\Riot Games\League of Legends",
        "C:\Program Files\Riot Games\League of Legends",
        "C:\Program Files (x86)\Riot Games\League of Legends",
        "$env:LOCALAPPDATA\Riot Games\League of Legends"
    )

    # Make League files inaccessible (change permissions)
    foreach ($path in $leaguePaths) {
        if (Test-Path $path) {
            try {
                # Find and deny execute permissions on League executables
                Get-ChildItem -Path $path -Recurse -Include "*.exe" -ErrorAction SilentlyContinue | ForEach-Object {
                    $acl = Get-Acl $_.FullName
                    $accessRule = New-Object System.Security.AccessControl.FileSystemAccessRule(
                        "$env:USERNAME", "ExecuteFile", "Deny"
                    )
                    $acl.AddAccessRule($accessRule)
                    Set-Acl $_.FullName $acl -ErrorAction SilentlyContinue
                }
            } catch {
                # Silently continue if we can't modify permissions
            }
        }
    }

    Start-Sleep -Seconds 2
}
'@

$guardianScript | Set-Content -Path $GUARDIAN_SCRIPT

# Create scheduled task
Write-Host "🔧 Step 6: Creating scheduled task for persistent blocking..." -ForegroundColor Yellow

# Remove existing task if it exists
Unregister-ScheduledTask -TaskName $TASK_NAME -Confirm:$false -ErrorAction SilentlyContinue

# Create new task
$action = New-ScheduledTaskAction -Execute "powershell.exe" -Argument "-WindowStyle Hidden -ExecutionPolicy Bypass -File `"$GUARDIAN_SCRIPT`""
$trigger = New-ScheduledTaskTrigger -AtStartup
$principal = New-ScheduledTaskPrincipal -UserId "SYSTEM" -LogonType ServiceAccount -RunLevel Highest
$settings = New-ScheduledTaskSettingsSet -AllowStartIfOnBatteries -DontStopIfGoingOnBatteries -StartWhenAvailable -RestartCount 999 -RestartInterval (New-TimeSpan -Minutes 1)

Register-ScheduledTask -TaskName $TASK_NAME -Action $action -Trigger $trigger -Principal $principal -Settings $settings -Description "QuitLoL Guardian - Blocks League of Legends" | Out-Null

# Start the task immediately
Write-Host "🚀 Step 7: Starting guardian task..." -ForegroundColor Yellow
Start-ScheduledTask -TaskName $TASK_NAME

# Try to uninstall League
Write-Host "🗑️  Step 8: Attempting to uninstall League of Legends..." -ForegroundColor Yellow

# Kill any running processes first
Get-Process | Where-Object {
    $_.ProcessName -match "League" -or $_.ProcessName -match "Riot"
} | Stop-Process -Force -ErrorAction SilentlyContinue

Start-Sleep -Seconds 2

# Try to run uninstaller if it exists
$uninstallers = @(
    "C:\Riot Games\League of Legends\LeagueClient.exe",
    "C:\Program Files\Riot Games\League of Legends\LeagueClient.exe",
    "C:\Program Files (x86)\Riot Games\League of Legends\LeagueClient.exe"
)

$foundLeague = $false
foreach ($uninstaller in $uninstallers) {
    if (Test-Path $uninstaller) {
        $foundLeague = $true
        $leagueDir = Split-Path $uninstaller
        Write-Host "   Found League at: $leagueDir" -ForegroundColor Cyan

        # Just delete the entire directory
        try {
            Remove-Item -Path $leagueDir -Recurse -Force -ErrorAction Stop
            Write-Host "   ✓ Removed League installation" -ForegroundColor Green
        } catch {
            Write-Host "   ⚠ Could not fully remove League (may be in use)" -ForegroundColor Yellow
        }
    }
}

# Also try to remove Riot Client
$riotClientPaths = @(
    "C:\Riot Games\Riot Client",
    "C:\Program Files\Riot Games\Riot Client",
    "C:\Program Files (x86)\Riot Games\Riot Client"
)

foreach ($path in $riotClientPaths) {
    if (Test-Path $path) {
        try {
            Remove-Item -Path $path -Recurse -Force -ErrorAction Stop
            Write-Host "   ✓ Removed Riot Client" -ForegroundColor Green
        } catch {
            Write-Host "   ⚠ Could not fully remove Riot Client" -ForegroundColor Yellow
        }
    }
}

if (-not $foundLeague) {
    Write-Host "   ℹ League of Legends not found (already uninstalled?)" -ForegroundColor Cyan
}

Write-Host ""
Write-Host "✅ League of Legends has been BLOCKED" -ForegroundColor Green
Write-Host ""
Write-Host "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━" -ForegroundColor Cyan
Write-Host "What's been done:" -ForegroundColor White
Write-Host "  • All League/Riot domains blocked in hosts file" -ForegroundColor Gray
Write-Host "  • Process killer scheduled task installed and running" -ForegroundColor Gray
Write-Host "  • League installation removed (if found)" -ForegroundColor Gray
Write-Host "  • Guardian task will auto-start on boot" -ForegroundColor Gray
Write-Host ""
Write-Host "To undo (requires technical knowledge):" -ForegroundColor Yellow
Write-Host "  1. Run uninstall_block.ps1 as Administrator" -ForegroundColor Gray
Write-Host "  OR manually:" -ForegroundColor Gray
Write-Host "  2. Open Task Scheduler and delete 'QuitLoL_Guardian'" -ForegroundColor Gray
Write-Host "  3. Edit C:\Windows\System32\drivers\etc\hosts" -ForegroundColor Gray
Write-Host "  4. Remove the QUITLOL_BLOCK section" -ForegroundColor Gray
Write-Host ""
Write-Host "But ask yourself: is that really what you want?" -ForegroundColor Red
Write-Host "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━" -ForegroundColor Cyan
Write-Host ""
Write-Host "Press any key to exit..." -ForegroundColor Gray
$null = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")
