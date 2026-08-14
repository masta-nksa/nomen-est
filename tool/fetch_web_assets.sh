#!/usr/bin/env bash
# Fetches the sqlite3/drift WebAssembly files the web build needs.
# Keep DRIFT_VERSION in step with the drift version in pubspec.lock.
set -euo pipefail

DRIFT_VERSION="2.34.3"
BASE="https://github.com/simolus3/drift/releases/download/drift-${DRIFT_VERSION}"

cd "$(dirname "$0")/.."
curl -sSL --fail -o web/drift_worker.js "${BASE}/drift_worker.js"
curl -sSL --fail -o web/sqlite3.wasm "${BASE}/sqlite3.wasm"
echo "Fetched drift ${DRIFT_VERSION} web assets into web/"
