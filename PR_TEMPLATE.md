# Homebrew Cask PR Template

Use this template when creating your PR to homebrew-cask.

## PR Title
```
Add ocrmypdf-gui
```

## PR Description

```markdown
**Important:** *This is a new cask. Please note that verifying a new cask submission may take 10-15 minutes.*

- [x] `brew audit --cask ocrmypdf-gui` passes
- [x] `brew style --fix Casks/ocrmypdf-gui.rb` passes
- [x] The submission is for a stable version (v0.8)
- [x] `sha256` sum matches the release: `de18fc892966776fa3581c9c15eb44aefe70c7b75d167c937d437cf37debf335`
- [x] The cask includes `depends_on` for required dependencies (`ocrmypdf` and `tesseract-lang`)

A modern GUI application for OCRMyPDF with drag-and-drop support and batch processing.

**Homepage:** https://github.com/nexusparadise/ocrmypdf-gui
**GitHub Releases:** https://github.com/nexusparadise/ocrmypdf-gui/releases
```

## Quick Commands

After forking and cloning homebrew-cask:

```bash
# Copy the cask file
cp /Users/ralf/Library/CloudStorage/Dropbox/Development/ocrmypdf-gui/Casks/ocrmypdf-gui.rb ~/homebrew-cask/Casks/

# Verify it works
cd ~/homebrew-cask
brew audit --cask ocrmypdf-gui
brew style Casks/ocrmypdf-gui.rb

# Create branch and commit
git checkout -b add-ocrmypdf-gui
git add Casks/ocrmypdf-gui.rb
git commit -m "Add ocrmypdf-gui"

# Push and create PR
git push origin add-ocrmypdf-gui
```

