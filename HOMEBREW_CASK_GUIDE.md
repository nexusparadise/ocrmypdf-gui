# Homebrew Cask Submission Guide

This guide explains how to submit `ocrmypdf-gui` to Homebrew Cask so users can install it with `brew install --cask ocrmypdf-gui`.

## Overview

**Difficulty: Easy to Moderate** ⭐⭐☆☆☆

The process is straightforward but requires:
1. A stable GitHub release (✅ you have this)
2. A properly formatted Cask file (✅ created in `Casks/ocrmypdf-gui.rb`)
3. Testing the cask locally
4. Submitting a PR to homebrew-cask

## Prerequisites

- ✅ GitHub repository with releases
- ✅ Stable version (v0.8)
- ✅ Downloadable zip file from GitHub releases
- ✅ Homebrew installed on your Mac

## Step-by-Step Process

### 1. Test the Cask Locally

First, test that the cask works on your machine:

```bash
# Install the cask from your local file
brew install --cask Casks/ocrmypdf-gui.rb

# Or test without installing
brew audit --cask Casks/ocrmypdf-gui.rb
brew style Casks/ocrmypdf-gui.rb
```

### 2. Get the SHA256 Checksum

Before submitting, you need the SHA256 checksum of your release zip file:

```bash
# Download the release file and get its checksum
curl -L -o /tmp/ocrmypdf-gui-v0.8.zip \
  https://github.com/nexusparadise/ocrmypdf-gui/releases/download/v0.8/ocrmypdf-gui-v0.8.zip

shasum -a 256 /tmp/ocrmypdf-gui-v0.8.zip
```

Then update the cask file:
```ruby
sha256 "YOUR_SHA256_HERE"  # Replace :no_check with the actual checksum
```

### 3. Fork and Clone homebrew-cask

```bash
# Fork https://github.com/Homebrew/homebrew-cask on GitHub first, then:
cd ~
git clone https://github.com/YOUR_USERNAME/homebrew-cask.git
cd homebrew-cask
```

### 4. Add Your Cask

```bash
# Copy your cask file to the Casks directory
cp /path/to/ocrmypdf-gui/Casks/ocrmypdf-gui.rb Casks/

# Test it
brew audit --cask Casks/ocrmypdf-gui.rb
brew style Casks/ocrmypdf-gui.rb
brew install --cask Casks/ocrmypdf-gui.rb
```

### 5. Create a Pull Request

```bash
# Create a new branch
git checkout -b add-ocrmypdf-gui

# Add and commit
git add Casks/ocrmypdf-gui.rb
git commit -m "Add ocrmypdf-gui"

# Push to your fork
git push origin add-ocrmypdf-gui
```

Then go to https://github.com/Homebrew/homebrew-cask and create a Pull Request.

### 6. PR Title Format

Use this format for your PR title:
```
Add ocrmypdf-gui
```

### 7. PR Description Template

```markdown
**Important:** *This is a new cask. Please note that verifying a new cask submission may take 10-15 minutes.*

- [x] `brew audit --cask Casks/ocrmypdf-gui.rb` passes
- [x] `brew style --fix Casks/ocrmypdf-gui.rb` passes
- [x] The submission is for a stable version
- [x] `sha256` sums match the release
- [x] The cask includes `depends_on` for required dependencies

A modern macOS GUI application for OCRMyPDF with drag-and-drop support and batch processing.

Homepage: https://github.com/nexusparadise/ocrmypdf-gui
```

## Important Notes

### Dependencies

Your cask correctly declares dependencies on `ocrmypdf` and `tesseract-lang`. Homebrew will automatically install these when users install your cask.

### Version Updates

When you release a new version:

1. Update the version in the cask file
2. Update the SHA256 checksum
3. Submit a new PR to homebrew-cask

You can automate this with:
```bash
brew bump-cask-pr --version 0.9 ocrmypdf-gui
```

### Common Issues

1. **SHA256 mismatch**: Make sure you're using the checksum from the actual GitHub release file
2. **Dependencies**: Ensure all dependencies are available in Homebrew core
3. **Naming**: Cask name must match the app name (lowercase, hyphens for spaces)

## Alternative: Create Your Own Tap

If you want more control or faster updates, you can create your own Homebrew tap:

```bash
# Create a new repository: homebrew-ocrmypdf-gui
# Then users can install with:
brew tap nexusparadise/ocrmypdf-gui
brew install ocrmypdf-gui
```

This is easier but requires users to add your tap first.

## Resources

- [Homebrew Cask Documentation](https://docs.brew.sh/Adding-Software-to-Homebrew)
- [Cask Cookbook](https://docs.brew.sh/Cask-Cookbook)
- [homebrew-cask Repository](https://github.com/Homebrew/homebrew-cask)

## Current Status

✅ Cask file created: `Casks/ocrmypdf-gui.rb`
⏳ Next step: Test locally, get SHA256, submit PR

