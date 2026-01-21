#!/bin/bash

set -e

APP_NAME="Claude Usage"
BUNDLE_ID="com.example.ClaudeUsage"
EXECUTABLE_NAME="ClaudeUsage"

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
PROJECT_DIR="$(dirname "$SCRIPT_DIR")"
BUILD_DIR="$PROJECT_DIR/.build/release"
APP_DIR="$PROJECT_DIR/build/$APP_NAME.app"

echo "Building release..."
cd "$PROJECT_DIR"
swift build -c release

echo "Creating app bundle..."
rm -rf "$APP_DIR"
mkdir -p "$APP_DIR/Contents/MacOS"
mkdir -p "$APP_DIR/Contents/Resources"

# Copy executable
cp "$BUILD_DIR/$EXECUTABLE_NAME" "$APP_DIR/Contents/MacOS/"

# Copy app icon (convert PNG to icns)
ICONSET_DIR="$APP_DIR/Contents/Resources/AppIcon.iconset"
mkdir -p "$ICONSET_DIR"
sips -z 16 16     "$PROJECT_DIR/ClaudeUsage/Resources/AppIcon.png" --out "$ICONSET_DIR/icon_16x16.png" 2>/dev/null
sips -z 32 32     "$PROJECT_DIR/ClaudeUsage/Resources/AppIcon.png" --out "$ICONSET_DIR/icon_16x16@2x.png" 2>/dev/null
sips -z 32 32     "$PROJECT_DIR/ClaudeUsage/Resources/AppIcon.png" --out "$ICONSET_DIR/icon_32x32.png" 2>/dev/null
sips -z 64 64     "$PROJECT_DIR/ClaudeUsage/Resources/AppIcon.png" --out "$ICONSET_DIR/icon_32x32@2x.png" 2>/dev/null
sips -z 128 128   "$PROJECT_DIR/ClaudeUsage/Resources/AppIcon.png" --out "$ICONSET_DIR/icon_128x128.png" 2>/dev/null
sips -z 256 256   "$PROJECT_DIR/ClaudeUsage/Resources/AppIcon.png" --out "$ICONSET_DIR/icon_128x128@2x.png" 2>/dev/null
sips -z 256 256   "$PROJECT_DIR/ClaudeUsage/Resources/AppIcon.png" --out "$ICONSET_DIR/icon_256x256.png" 2>/dev/null
sips -z 512 512   "$PROJECT_DIR/ClaudeUsage/Resources/AppIcon.png" --out "$ICONSET_DIR/icon_256x256@2x.png" 2>/dev/null
sips -z 512 512   "$PROJECT_DIR/ClaudeUsage/Resources/AppIcon.png" --out "$ICONSET_DIR/icon_512x512.png" 2>/dev/null
sips -z 1024 1024 "$PROJECT_DIR/ClaudeUsage/Resources/AppIcon.png" --out "$ICONSET_DIR/icon_512x512@2x.png" 2>/dev/null
iconutil -c icns "$ICONSET_DIR" -o "$APP_DIR/Contents/Resources/AppIcon.icns"
rm -rf "$ICONSET_DIR"

# Create Info.plist
cat > "$APP_DIR/Contents/Info.plist" << EOF
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
    <key>CFBundleDevelopmentRegion</key>
    <string>en</string>
    <key>CFBundleExecutable</key>
    <string>$EXECUTABLE_NAME</string>
    <key>CFBundleIconFile</key>
    <string>AppIcon</string>
    <key>CFBundleIdentifier</key>
    <string>$BUNDLE_ID</string>
    <key>CFBundleInfoDictionaryVersion</key>
    <string>6.0</string>
    <key>CFBundleName</key>
    <string>$APP_NAME</string>
    <key>CFBundleDisplayName</key>
    <string>$APP_NAME</string>
    <key>CFBundlePackageType</key>
    <string>APPL</string>
    <key>CFBundleShortVersionString</key>
    <string>1.0</string>
    <key>CFBundleVersion</key>
    <string>1</string>
    <key>LSMinimumSystemVersion</key>
    <string>15.0</string>
    <key>LSUIElement</key>
    <true/>
    <key>NSHighResolutionCapable</key>
    <true/>
    <key>NSSupportsAutomaticTermination</key>
    <true/>
    <key>NSSupportsSuddenTermination</key>
    <true/>
</dict>
</plist>
EOF

echo "App bundle created at: $APP_DIR"
echo ""
echo "To install, run:"
echo "  cp -r \"$APP_DIR\" /Applications/"
echo ""
echo "Or open the build folder:"
echo "  open \"$PROJECT_DIR/build\""
