#!/bin/bash
set -e

echo "🔨 Building Mac Control AI (Release)..."
PROJECT_DIR="/Users/mk/Desktop/clicky-cua/Mac-Control-Ai"
cd "$PROJECT_DIR"

BUILD_DIR="$PROJECT_DIR/build"

xcodebuild -project cursor-buddy.xcodeproj \
           -scheme cursor-buddy \
           -configuration Release \
           -derivedDataPath "$BUILD_DIR" \
           build CODE_SIGN_IDENTITY="-" CODE_SIGNING_REQUIRED=NO CODE_SIGNING_ALLOWED=NO > /dev/null

BUILT_APP="$BUILD_DIR/Build/Products/Release/Mac Control AI.app"

if [ ! -d "$BUILT_APP" ]; then
    echo "❌ Build failed: $BUILT_APP not found"
    exit 1
fi

echo "🔏 Signing application ad-hoc..."
codesign --force --deep --sign - "$BUILT_APP" || true

echo "📦 Updating ~/Applications and Desktop..."
rm -rf ~/Applications/"Mac Control AI.app" ~/Desktop/"Mac Control AI.app"
cp -R "$BUILT_APP" ~/Applications/
cp -R "$BUILT_APP" ~/Desktop/

echo "💿 Creating Mac-Control-AI.dmg..."
TEMP_DMG_DIR=$(mktemp -d)
cp -R "$BUILT_APP" "$TEMP_DMG_DIR/"
ln -s /Applications "$TEMP_DMG_DIR/Applications"

rm -f ~/Desktop/"Mac-Control-AI.dmg"
hdiutil create -volname "Mac Control AI" -srcfolder "$TEMP_DMG_DIR" -ov -format UDZO ~/Desktop/"Mac-Control-AI.dmg" > /dev/null
rm -rf "$TEMP_DMG_DIR"

echo "✅ Success! Mac-Control-AI.dmg has been created on Desktop."
