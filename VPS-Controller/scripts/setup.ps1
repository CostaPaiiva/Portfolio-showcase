$ErrorActionPreference = "Stop"

Write-Host "VPS Controller - setup de desenvolvimento"

foreach ($project in @("backend", "agent", "monitor")) {
    Write-Host "Preparando $project..."
    Push-Location $project
    if (-not (Test-Path .env)) { Copy-Item .env.example .env }
    npm install
    npm run typecheck
    npm run build
    Pop-Location
}

Write-Host "Node OK."
Write-Host "Flutter: cd mobile; flutter create . --platforms=android,ios --project-name vps_controller; flutter pub get; flutter analyze; flutter test"
