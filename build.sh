#!/bin/sh
# Builds "Online or Offline.app" with the command-line Swift compiler and installs it in ~/Applications.
set -e
cd "$(dirname "$0")"
NAME="Online or Offline"
APP="build/$NAME.app"
rm -rf "$APP"
mkdir -p "$APP/Contents/MacOS"
swiftc -O -o "$APP/Contents/MacOS/$NAME" main.swift
cat > "$APP/Contents/Info.plist" <<PLIST
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
  <key>CFBundleName</key><string>$NAME</string>
  <key>CFBundleDisplayName</key><string>$NAME</string>
  <key>CFBundleExecutable</key><string>$NAME</string>
  <key>CFBundleIdentifier</key><string>local.online-or-offline</string>
  <key>CFBundleVersion</key><string>1</string>
  <key>CFBundleShortVersionString</key><string>1.0</string>
  <key>CFBundlePackageType</key><string>APPL</string>
  <key>LSMinimumSystemVersion</key><string>13.0</string>
  <key>LSUIElement</key><true/>
  <key>NSHighResolutionCapable</key><true/>
  <key>NSAppleEventsUsageDescription</key><string>Opens Terminal to run the full speed test.</string>
</dict>
</plist>
PLIST

# Install for this user only, replacing any running copy.
mkdir -p "$HOME/Applications"
pkill -x "$NAME" 2>/dev/null || true
rm -rf "$HOME/Applications/$NAME.app"
cp -R "$APP" "$HOME/Applications/"
open "$HOME/Applications/$NAME.app"
echo "Installed and started: ~/Applications/$NAME.app"
