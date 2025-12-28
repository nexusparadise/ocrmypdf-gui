#!/bin/bash
# Script to commit and push the Homebrew Cask PR

set -e

HOMEBREW_CASK_DIR="$HOME/homebrew-cask"
CASK_FILE="Casks/ocrmypdf-gui.rb"
BRANCH_NAME="add-ocrmypdf-gui"

if [ ! -d "$HOMEBREW_CASK_DIR" ]; then
    echo "❌ Error: $HOMEBREW_CASK_DIR not found"
    echo "   Run ./setup_homebrew_pr.sh first"
    exit 1
fi

cd "$HOMEBREW_CASK_DIR"

# Check if we're on the right branch
CURRENT_BRANCH=$(git branch --show-current)
if [ "$CURRENT_BRANCH" != "$BRANCH_NAME" ]; then
    echo "⚠️  Not on branch $BRANCH_NAME. Switching..."
    git checkout "$BRANCH_NAME" || git checkout -b "$BRANCH_NAME"
fi

# Add and commit
echo "📝 Staging changes..."
git add "$CASK_FILE"

echo "💾 Committing..."
git commit -m "Add ocrmypdf-gui"

# Get GitHub username from remote
GITHUB_USERNAME=$(git remote get-url origin | sed -E 's|.*github.com[:/]([^/]+)/.*|\1|')

echo ""
echo "🚀 Pushing to GitHub..."
git push origin "$BRANCH_NAME"

echo ""
echo "✅ Pushed successfully!"
echo ""
echo "🔗 Create PR at:"
echo "   https://github.com/Homebrew/homebrew-cask/compare/main...$GITHUB_USERNAME:$BRANCH_NAME"
echo ""
echo "📋 Use this PR description:"
echo "---"
cat << 'EOF'
**Important:** *This is a new cask. Please note that verifying a new cask submission may take 10-15 minutes.*

- [x] `brew audit --cask ocrmypdf-gui` passes
- [x] `brew style --fix Casks/ocrmypdf-gui.rb` passes
- [x] The submission is for a stable version (v0.8)
- [x] `sha256` sum matches the release: `de18fc892966776fa3581c9c15eb44aefe70c7b75d167c937d437cf37debf335`
- [x] The cask includes `depends_on` for required dependencies (`ocrmypdf` and `tesseract-lang`)

A modern GUI application for OCRMyPDF with drag-and-drop support and batch processing.

**Homepage:** https://github.com/nexusparadise/ocrmypdf-gui
**GitHub Releases:** https://github.com/nexusparadise/ocrmypdf-gui/releases
EOF
echo "---"

