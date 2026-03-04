# Creates bundle.zip in the project directory for embedding. Run from repo root.
param([string]$ProjectDir)
$ErrorActionPreference = 'Stop'
$dest = Join-Path $ProjectDir 'bundle.zip'
$items = @('Scripts','Assets','Regfiles','Schemas','Apps.json','DefaultSettings.json','WinTweak.ps1')
foreach ($item in $items) {
    if (-not (Test-Path $item)) { throw "Missing: $item" }
}
Compress-Archive -Path $items -DestinationPath $dest -Force
Write-Host "Created $dest"
