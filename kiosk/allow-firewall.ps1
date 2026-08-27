# Run as Administrator on each client PC after copying dist\GateWatch folder there.
# Allows GateWatch.exe network access via Windows Firewall (keeps antivirus scanning ON).
$ErrorActionPreference = "Stop"
$exe = Join-Path $PSScriptRoot "GateWatch.exe"

New-NetFirewallRule -DisplayName "GateWatch" -Direction Outbound -Program $exe -Action Allow
New-NetFirewallRule -DisplayName "GateWatch" -Direction Inbound -Program $exe -Action Allow

Write-Host "Firewall rules added for: $exe"
