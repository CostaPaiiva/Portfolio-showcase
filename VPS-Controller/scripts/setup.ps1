$ErrorActionPreference = "Stop"

Write-Host "Installing backend..."
Push-Location backend
npm install
if (-not (Test-Path .env)) { Copy-Item .env.example .env }
Pop-Location

Write-Host "Installing agent..."
Push-Location agent
npm install
if (-not (Test-Path .env)) { Copy-Item .env.example .env }
Pop-Location

Write-Host "Installing monitor..."
Push-Location monitor
npm install
if (-not (Test-Path .env)) { Copy-Item .env.example .env }
Pop-Location

Write-Host "Node components installed."
Write-Host "For Flutter: cd mobile; flutter create . --platforms=android,ios; flutter pub get"
