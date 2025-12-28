#!/bin/bash
# Script to sign and notarize the app from command line

set -e

APP_PATH="build/Release/ocrmypdf-gui.app"
IDENTITY="Developer ID Application: Your Name (TEAM_ID)"
TEAM_ID="YOUR_TEAM_ID"
APPLE_ID="your-email@example.com"
APP_SPECIFIC_PASSWORD="your-app-specific-password"

echo "🔨 Building the app..."
xcodebuild -project ocrmypdf-gui.xcodeproj \
  -scheme ocrmypdf-gui \
  -configuration Release \
  -derivedDataPath build/DerivedData \
  CODE_SIGN_IDENTITY="$IDENTITY" \
  CODE_SIGN_STYLE=Manual \
  DEVELOPMENT_TEAM="$TEAM_ID" \
  ENABLE_HARDENED_RUNTIME=YES

echo ""
echo "✅ Build complete"
echo ""

# Find the built app
if [ ! -d "$APP_PATH" ]; then
  APP_PATH="build/DerivedData/Build/Products/Release/ocrmypdf-gui.app"
fi

if [ ! -d "$APP_PATH" ]; then
  echo "❌ Error: App not found. Please check the build path."
  exit 1
fi

echo "📝 Signing the app..."
echo "   App: $APP_PATH"
echo "   Identity: $IDENTITY"
echo ""

# Sign the app
codesign --force --deep --sign "$IDENTITY" \
  --options runtime \
  --entitlements ocrmypdf-gui/ocrmypdf-gui.entitlements \
  "$APP_PATH"

echo ""
echo "✅ Signing complete"
echo ""

# Verify signature
echo "🔍 Verifying signature..."
codesign -dv --verbose=4 "$APP_PATH"
echo ""

# Check if signature is valid
if codesign --verify --verbose "$APP_PATH" 2>&1 | grep -q "valid on disk"; then
  echo "✅ Signature is valid"
else
  echo "❌ Signature verification failed"
  exit 1
fi

echo ""
echo "📦 Creating zip for notarization..."
ZIP_PATH="ocrmypdf-gui-signed.zip"
cd "$(dirname "$APP_PATH")"
zip -r "$(pwd)/$ZIP_PATH" "$(basename "$APP_PATH")"
cd - > /dev/null

echo ""
echo "📤 Submitting for notarization..."
echo "   This may take a few minutes..."
echo ""

# Submit for notarization
SUBMISSION_ID=$(xcrun notarytool submit "$ZIP_PATH" \
  --apple-id "$APPLE_ID" \
  --team-id "$TEAM_ID" \
  --password "$APP_SPECIFIC_PASSWORD" \
  --wait \
  --timeout 30m 2>&1 | grep -i "id:" | awk '{print $NF}')

if [ -z "$SUBMISSION_ID" ]; then
  echo "❌ Notarization submission failed"
  exit 1
fi

echo ""
echo "✅ Notarization complete!"
echo ""

# Staple the ticket
echo "📎 Stapling notarization ticket..."
xcrun stapler staple "$APP_PATH"

echo ""
echo "🎉 Done! Your app is signed and notarized."
echo ""
echo "📋 Next steps:"
echo "   1. Verify: spctl -a -vv $APP_PATH"
echo "   2. Create zip: zip -r ocrmypdf-gui-v0.8-signed.zip $APP_PATH"
echo "   3. Get SHA256: shasum -a 256 ocrmypdf-gui-v0.8-signed.zip"
echo "   4. Create GitHub release with the signed zip"

