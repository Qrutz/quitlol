# League of Legends Blocker - Uninstall Script (Windows)
# You shouldn't be running this. But if you must...

#Requires -RunAsAdministrator

Write-Host "🤔 League of Legends Blocker - Uninstall (Windows)" -ForegroundColor Yellow
Write-Host "====================================================" -ForegroundColor Yellow
Write-Host ""
Write-Host "Are you SURE you want to remove the blocker?" -ForegroundColor Red
Write-Host "Think about why you installed it in the first place." -ForegroundColor Red
Write-Host ""

$confirmation = Read-Host "Type 'I WANT TO WASTE MY TIME' to continue"

if ($confirmation -ne "I WANT TO WASTE MY TIME") {
    Write-Host "❌ Uninstallation cancelled. Good choice." -ForegroundColor Green
    Start-Sleep -Seconds 2
    exit 1
}

Write-Host ""
Write-Host "😔 Removing blocker..." -ForegroundColor Yellow

$ErrorActionPreference = "Continue"

$HOSTS_FILE = "$env:SystemRoot\System32\drivers\etc\hosts"
$BACKUP_DIR = "$env:ProgramData\QuitLoL"
$HOSTS_MARKER = "# QUITLOL_BLOCK_START"
$HOSTS_MARKER_END = "# QUITLOL_BLOCK_END"
$TASK_NAME = "QuitLoL_Guardian"

# Stop and remove scheduled task
Write-Host "  • Stopping guardian task..." -ForegroundColor Gray
Stop-ScheduledTask -TaskName $TASK_NAME -ErrorAction SilentlyContinue

Write-Host "  • Removing guardian task..." -ForegroundColor Gray
Unregister-ScheduledTask -TaskName $TASK_NAME -Confirm:$false -ErrorAction SilentlyContinue

# Remove guardian script
Write-Host "  • Removing guardian files..." -ForegroundColor Gray
if (Test-Path $BACKUP_DIR) {
    Remove-Item -Path "$BACKUP_DIR\guardian.ps1" -Force -ErrorAction SilentlyContinue
}

# Remove hosts file entries
Write-Host "  • Removing hosts file blocks..." -ForegroundColor Gray

# Backup first
$timestamp = Get-Date -Format "yyyyMMdd_HHmmss"
Copy-Item $HOSTS_FILE "$env:TEMP\hosts.backup.$timestamp" -ErrorAction SilentlyContinue

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

$newContent | Set-Content $HOSTS_FILE

# Flush DNS
Write-Host "  • Flushing DNS cache..." -ForegroundColor Gray
ipconfig /flushdns | Out-Null

Write-Host ""
Write-Host "✓ Blocker removed." -ForegroundColor Green
Write-Host ""
Write-Host "Remember: You had a good reason for installing this." -ForegroundColor Yellow
Write-Host "Are you making the right choice?" -ForegroundColor Red
Write-Host ""
Write-Host "Press any key to exit..." -ForegroundColor Gray
$null = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")
