$ErrorActionPreference = "Stop"
Set-Location $PSScriptRoot

$python = "py"
$pythonArgs = @("-3")

if (-not (Test-Path "config.py")) {
    Write-Error "kiosk\config.py is missing. Copy config.example.py to config.py and fill in DB_PASSWORD first."
    exit 1
}

& $python @pythonArgs -m pip install -r requirements.txt
if ($LASTEXITCODE -ne 0) { throw "pip install -r requirements.txt failed" }

& $python @pythonArgs -m pip install pyinstaller
if ($LASTEXITCODE -ne 0) { throw "pip install pyinstaller failed" }

Remove-Item -Recurse -Force build, dist -ErrorAction SilentlyContinue

& $python @pythonArgs -m PyInstaller `
  --name GateWatch `
  --windowed `
  --noconfirm `
  --add-data "ui;ui" `
  --collect-all mysql.connector `
  app.py
if ($LASTEXITCODE -ne 0) { throw "PyInstaller build failed" }

Write-Host ""
Write-Host "Build complete: dist\GateWatch\GateWatch.exe"
Write-Host "Copy the entire dist\GateWatch folder to the target PC and run GateWatch.exe."
