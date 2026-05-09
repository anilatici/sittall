#!/bin/bash
set -e

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
cd "$SCRIPT_DIR"

echo "Building SitTall - Fix Your Posture..."
swift build 2>&1

BINARY=".build/debug/SitTall"
APP="SitTall - Fix Your Posture.app"

echo "Creating app bundle..."
rm -rf "$APP"
mkdir -p "$APP/Contents/MacOS"
mkdir -p "$APP/Contents/Resources"

cp "$BINARY" "$APP/Contents/MacOS/SitTall"

cat > "$APP/Contents/Info.plist" << 'EOF'
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
    <key>CFBundleExecutable</key>
    <string>SitTall</string>
    <key>CFBundleIdentifier</key>
    <string>app.sittall.SitTall</string>
    <key>CFBundleName</key>
    <string>SitTall - Fix Your Posture</string>
    <key>CFBundleDisplayName</key>
    <string>SitTall - Fix Your Posture</string>
    <key>CFBundleVersion</key>
    <string>1</string>
    <key>CFBundleShortVersionString</key>
    <string>1.0</string>
    <key>CFBundlePackageType</key>
    <string>APPL</string>
    <key>LSMinimumSystemVersion</key>
    <string>14.0</string>
    <key>LSUIElement</key>
    <true/>
    <key>NSMotionUsageDescription</key>
    <string>SitTall - Fix Your Posture uses your AirPods' built-in motion sensor to track head position and alert you when your posture needs attention.</string>
    <key>NSPrincipalClass</key>
    <string>NSApplication</string>
</dict>
</plist>
EOF

echo "Launching SitTall - Fix Your Posture..."
open "$APP"
