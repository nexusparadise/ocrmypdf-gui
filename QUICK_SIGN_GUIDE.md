# Quick Code Signing Guide (Command Line)

## Important: Sandbox is NOT Required

**You don't need App Sandbox for code signing!** Your app will work fine without it. In fact, for an app that runs shell commands like yours, you typically **don't want** App Sandbox enabled.

## Prerequisites

1. **Apple Developer Account** ($99/year)
2. **Developer ID Application** certificate (not "Mac Development")
3. **App-specific password** for notarization

## Step 1: Get Your Developer ID Certificate

1. Go to https://developer.apple.com/account/resources/certificates/list
2. Click **+** to create a new certificate
3. Select **Developer ID Application** (NOT "Mac Development")
4. Follow the steps to create and download the certificate
5. Double-click to install it in Keychain

## Step 2: Find Your Certificate Identity

```bash
# List available signing identities
security find-identity -v -p codesigning

# Look for something like:
# "Developer ID Application: Your Name (TEAM_ID)"
```

## Step 3: Build and Sign

### Option A: Using the Script

1. Edit `sign_app.sh` and update:
   - `IDENTITY` - Your Developer ID certificate name
   - `TEAM_ID` - Your Apple Developer Team ID
   - `APPLE_ID` - Your Apple ID email
   - `APP_SPECIFIC_PASSWORD` - App-specific password (from appleid.apple.com)

2. Run:
   ```bash
   ./sign_app.sh
   ```

### Option B: Manual Steps

```bash
# 1. Build the app
xcodebuild -project ocrmypdf-gui.xcodeproj \
  -scheme ocrmypdf-gui \
  -configuration Release \
  CODE_SIGN_IDENTITY="Developer ID Application: Your Name (TEAM_ID)" \
  CODE_SIGN_STYLE=Manual \
  DEVELOPMENT_TEAM="YOUR_TEAM_ID" \
  ENABLE_HARDENED_RUNTIME=YES

# 2. Sign the app
codesign --force --deep --sign "Developer ID Application: Your Name (TEAM_ID)" \
  --options runtime \
  --entitlements ocrmypdf-gui/ocrmypdf-gui.entitlements \
  build/Release/ocrmypdf-gui.app

# 3. Verify
codesign --verify --verbose build/Release/ocrmypdf-gui.app
```

## Step 4: Notarize (Optional but Recommended)

```bash
# Create zip
zip -r ocrmypdf-gui.zip build/Release/ocrmypdf-gui.app

# Submit for notarization
xcrun notarytool submit ocrmypdf-gui.zip \
  --apple-id "your-email@example.com" \
  --team-id "YOUR_TEAM_ID" \
  --password "app-specific-password" \
  --wait

# Staple the ticket
xcrun stapler staple build/Release/ocrmypdf-gui.app
```

## Verify Everything Works

```bash
# Check signature
codesign -dv --verbose=4 build/Release/ocrmypdf-gui.app

# Check notarization (if you notarized)
spctl -a -vv build/Release/ocrmypdf-gui.app
```

## Common Issues

### "No signing certificate found"
- Make sure you have **Developer ID Application** (not Mac Development)
- Check: `security find-identity -v -p codesigning`

### "Sandbox not activated" error
- **This is fine!** You don't need sandbox for code signing
- Your app will work without it
- Sandbox is only needed for App Store distribution

### Hardened Runtime errors
- Already enabled in your project (`ENABLE_HARDENED_RUNTIME = YES`)
- If you get specific errors, you may need to add entitlements

## Notes

- **Sandbox is NOT required** for code signing or notarization
- Your app needs to run shell commands, so sandbox would actually break it
- Command line signing works exactly the same as Xcode signing
- The empty entitlements file is fine - you don't need to add sandbox

