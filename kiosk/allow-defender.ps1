# Run as Administrator on each client PC after copying dist\GateWatch folder there.
# Adds a Windows Defender exclusion so it stops blocking the unsigned GateWatch.exe.
$ErrorActionPreference = "Stop"
$folder = $PSScriptRoot

Add-MpPreference -ExclusionPath $folder
Add-MpPreference -ExclusionProcess "$folder\GateWatch.exe"

Write-Host "Defender exclusion added for: $folder"
