#!/bin/bash
set -euo pipefail
cd "$(dirname "$0")"

app="Mira.app"
mkdir -p "$app/Contents/MacOS" "$app/Contents/Resources"
cp Resources/Info.plist "$app/Contents/Info.plist"
cp Assets/AppIcon.icns "$app/Contents/Resources/AppIcon.icns"
swiftc -target "$(uname -m)-apple-macosx11.0" \
    Sources/main.swift Sources/App/*.swift Sources/Editor/*.swift \
    -o "$app/Contents/MacOS/Mira" -framework Cocoa -framework UniformTypeIdentifiers
codesign --force --deep --sign - "$app"
printf 'Mira.app compilado com sucesso.\n'
