#!/bin/bash
set -euo pipefail
cd "$(dirname "$0")/.."

./compilar.sh
mkdir -p dist
pkgbuild --component Mira.app \
    --install-location /Applications \
    --identifier br.com.mira.capturas.instalador \
    --version 1.0 \
    dist/Mira-1.0.pkg
printf 'Instalador criado em dist/Mira-1.0.pkg.\n'
