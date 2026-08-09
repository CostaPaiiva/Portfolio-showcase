#!/usr/bin/env bash
set -euo pipefail
for project in backend agent monitor; do
  echo "Installing $project..."
  (cd "$project" && npm install && [ -f .env ] || cp .env.example .env)
done
echo "Node components installed."
echo "For Flutter: cd mobile && flutter create . --platforms=android,ios && flutter pub get"
