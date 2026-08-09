#!/usr/bin/env bash
set -euo pipefail
for project in backend agent monitor; do
  echo "Preparando $project..."
  cd "$project"
  [ -f .env ] || cp .env.example .env
  npm install
  npm run typecheck
  npm run build
  cd ..
done
echo "Node OK."
echo "Flutter: cd mobile && flutter create . --platforms=android,ios --project-name vps_controller && flutter pub get && flutter analyze && flutter test"
