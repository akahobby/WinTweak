param (
    [switch]$CLI,
    [switch]$Silent,
    [switch]$Verbose,
    [switch]$Sysprep,
    [string]$LogPath,
    [string]$User,
    [switch]$NoRestartExplorer,
    [switch]$CreateRestorePoint,
    [switch]$RunAppsListGenerator,
    [switch]$RunDefaults,
    [switch]$RunDefaultsLite,
    [switch]$RunSavedSettings,
    [string]$Apps,
    [string]$AppRemovalTarget,
    [switch]$RemoveApps,
    [switch]$RemoveAppsCustom,
    [switch]$RemoveGamingApps,
    [switch]$RemoveCommApps,
    [switch]$RemoveHPApps,
    [switch]$RemoveW11Outlook,
    [switch]$ForceRemoveEdge,
    [switch]$DisableDVR,
    [switch]$DisableGameBarIntegration,
    [switch]$EnableWindowsSandbox,
    [switch]$EnableWindowsSubsystemForLinux,
    [switch]$DisableTelemetry,
    [switch]$DisableSearchHistory,
    [switch]$DisableFastStartup,
    [switch]$DisableBitlockerAutoEncryption,
    [switch]$DisableModernStandbyNetworking,
    [switch]$DisableUpdateASAP,
    [switch]$PreventUpdateAutoReboot,
    [switch]$DisableDeliveryOptimization,
    [switch]$DisableBing,
    [switch]$DisableDesktopSpotlight,
    [switch]$DisableLockscreenTips,
    [switch]$DisableSuggestions,
    [switch]$DisableLocationServices,
    [switch]$DisableEdgeAds,
    [switch]$DisableBraveBloat,
    [switch]$DisableSettings365Ads,
    [switch]$DisableSettingsHome,
    [switch]$ShowHiddenFolders,
    [switch]$ShowKnownFileExt,
    [switch]$HideDupliDrive,
    [switch]$EnableDarkMode,
    [switch]$DisableTransparency,
    [switch]$DisableAnimations,
    [switch]$TaskbarAlignLeft,
    [switch]$CombineTaskbarAlways, [switch]$CombineTaskbarWhenFull, [switch]$CombineTaskbarNever,
    [switch]$CombineMMTaskbarAlways, [switch]$CombineMMTaskbarWhenFull, [switch]$CombineMMTaskbarNever,
    [switch]$MMTaskbarModeAll, [switch]$MMTaskbarModeMainActive, [switch]$MMTaskbarModeActive,
    [switch]$HideSearchTb, [switch]$ShowSearchIconTb, [switch]$ShowSearchLabelTb, [switch]$ShowSearchBoxTb,
    [switch]$HideTaskview,
    [switch]$DisableStartRecommended,
    [switch]$DisableStartPhoneLink,
    [switch]$DisableCopilot,
    [switch]$DisableRecall,
    [switch]$DisableClickToDo,
    [switch]$DisablePaintAI,
    [switch]$DisableNotepadAI,
    [switch]$DisableEdgeAI,
    [switch]$DisableWidgets,
    [switch]$HideChat,
    [switch]$EnableEndTask,
    [switch]$EnableLastActiveClick,
    [switch]$ClearStart,
    [string]$ReplaceStart,
    [switch]$ClearStartAllUsers,
    [string]$ReplaceStartAllUsers,
    [switch]$RevertContextMenu,
    [switch]$DisableDragTray,
    [switch]$DisableMouseAcceleration,
    [switch]$DisableStickyKeys,
    [switch]$DisableWindowSnapping,
    [switch]$DisableSnapAssist,
    [switch]$DisableSnapLayouts,
    [switch]$HideTabsInAltTab, [switch]$Show3TabsInAltTab, [switch]$Show5TabsInAltTab, [switch]$Show20TabsInAltTab,
    [switch]$HideHome,
    [switch]$HideGallery,
    [switch]$ExplorerToHome,
    [switch]$ExplorerToThisPC,
    [switch]$ExplorerToDownloads,
    [switch]$ExplorerToOneDrive,
    [switch]$AddFoldersToThisPC,
    [switch]$HideOnedrive,
    [switch]$Hide3dObjects,
    [switch]$HideMusic,
    [switch]$HideIncludeInLibrary,
    [switch]$HideGiveAccessTo,
    [switch]$HideShare
)

# Require FullLanguage mode
if ($ExecutionContext.SessionState.LanguageMode -ne "FullLanguage") {
    Write-Host "Error: Win11Reclaim cannot run. PowerShell execution is restricted by security policies." -ForegroundColor Red
    Write-Output ""
    Write-Output "Press enter to exit..."
    Read-Host | Out-Null
    Exit
}

Clear-Host
Write-Output "-------------------------------------------------------------------------------------------"
Write-Output " Win11Reclaim - Get"
Write-Output "-------------------------------------------------------------------------------------------"

Write-Output "> Downloading Win11Reclaim..."

$zipPath = "$env:TEMP\win11reclaim.zip"
$extractPath = "$env:TEMP\Win11Reclaim"

try {
    # Use main branch archive (works without GitHub Releases)
    $archiveUri = "https://github.com/akahobby/Win11Reclaim/archive/refs/heads/main.zip"
    Invoke-RestMethod -Uri $archiveUri -OutFile $zipPath -ErrorAction Stop
}
catch {
    Write-Host "Error: Could not download from GitHub. Check your internet connection and try again." -ForegroundColor Red
    Write-Output ""
    Write-Output "Press enter to exit..."
    Read-Host | Out-Null
    if (Test-Path $zipPath) { Remove-Item $zipPath -Force }
    Exit
}

# Preserve user data when cleaning an existing install
$exclude = @('CustomAppsList', 'LastUsedSettings.json', 'Win11Reclaim.log', 'Logs')
if (Test-Path $extractPath) {
    Write-Output ""
    Write-Output "> Cleaning previous Win11Reclaim folder..."
    Get-ChildItem -Path $extractPath -Exclude $exclude | Remove-Item -Recurse -Force -ErrorAction SilentlyContinue
}

Write-Output ""
Write-Output "> Unpacking..."

# Extract (zip contains root folder Win11Reclaim-main)
Expand-Archive -Path $zipPath -DestinationPath $extractPath -Force
Remove-Item $zipPath -Force -ErrorAction SilentlyContinue

# Move contents of Win11Reclaim-main into extract path
$archiveRoot = Join-Path $extractPath "Win11Reclaim-main"
if (Test-Path $archiveRoot) {
    Get-ChildItem -Path $archiveRoot | Move-Item -Destination $extractPath -Force
    Remove-Item $archiveRoot -Recurse -Force -ErrorAction SilentlyContinue
}

# Build argument list for main script
$arguments = $($PSBoundParameters.GetEnumerator() | ForEach-Object {
    if ($_.Value -eq $true) {
        "-$($_.Key)"
    } else {
        "-$($_.Key) ""$($_.Value)"""
    }
})

Write-Output ""
Write-Output "> Running Win11Reclaim..."

$windowStyle = if ($arguments.Count -eq 0) { "Minimized" } else { "Normal" }
$scriptPath = Join-Path $extractPath "Win11Debloat.ps1"

$debloatProcess = Start-Process powershell.exe -WindowStyle $windowStyle -PassThru -ArgumentList "-ExecutionPolicy Bypass -File `"$scriptPath`" $arguments" -Verb RunAs

if ($null -ne $debloatProcess) {
    $debloatProcess.WaitForExit()
}

# Optional cleanup of script files (keep user data)
if (Test-Path $extractPath) {
    Write-Output ""
    Write-Output "> Cleaning up..."
    Get-ChildItem -Path $extractPath -Exclude $exclude | Remove-Item -Recurse -Force -ErrorAction SilentlyContinue
}

Write-Output ""
