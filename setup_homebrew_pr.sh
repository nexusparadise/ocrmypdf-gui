#!/bin/bash
# Script to set up Homebrew Cask PR for ocrmypdf-gui

set -e

echo "🚀 Setting up Homebrew Cask PR for ocrmypdf-gui"
echo ""

# Check if GitHub username is provided
if [ -z "$1" ]; then
    echo "❌ Error: GitHub username required"
    echo ""
    echo "Usage: ./setup_homebrew_pr.sh YOUR_GITHUB_USERNAME"
    echo ""
    echo "First, make sure you've forked https://github.com/Homebrew/homebrew-cask"
    echo "Then run this script with your GitHub username"
    exit 1
fi

GITHUB_USERNAME=$1
HOMEBREW_CASK_DIR="$HOME/homebrew-cask"
CASK_FILE="Casks/ocrmypdf-gui.rb"

echo "📋 Configuration:"
echo "   GitHub Username: $GITHUB_USERNAME"
echo "   Clone Directory: $HOMEBREW_CASK_DIR"
echo ""

# Check if already cloned
if [ -d "$HOMEBREW_CASK_DIR" ]; then
    echo "⚠️  Directory $HOMEBREW_CASK_DIR already exists"
    read -p "   Remove and re-clone? (y/N) " -n 1 -r
    echo
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        rm -rf "$HOMEBREW_CASK_DIR"
    else
        echo "   Using existing directory"
    fi
fi

# Clone if needed
if [ ! -d "$HOMEBREW_CASK_DIR" ]; then
    echo "📥 Cloning your fork..."
    git clone "https://github.com/$GITHUB_USERNAME/homebrew-cask.git" "$HOMEBREW_CASK_DIR"
else
    echo "📂 Using existing clone"
fi

# Navigate to directory
cd "$HOMEBREW_CASK_DIR"

# Update remote to include upstream
echo ""
echo "🔄 Setting up upstream remote..."
git remote remove upstream 2>/dev/null || true
git remote add upstream https://github.com/Homebrew/homebrew-cask.git
git fetch upstream

# Create branch
BRANCH_NAME="add-ocrmypdf-gui"
echo ""
echo "🌿 Creating branch: $BRANCH_NAME"
git checkout -b "$BRANCH_NAME" 2>/dev/null || git checkout "$BRANCH_NAME"

# Copy cask file
echo ""
echo "📋 Copying cask file..."
PROJECT_DIR="/Users/ralf/Library/CloudStorage/Dropbox/Development/ocrmypdf-gui"
cp "$PROJECT_DIR/$CASK_FILE" "$CASK_FILE"

# Verify cask
echo ""
echo "✅ Verifying cask..."
brew audit --cask "$CASK_FILE" || {
    echo "❌ Audit failed. Please check the errors above."
    exit 1
}

brew style "$CASK_FILE" || {
    echo "❌ Style check failed. Please check the errors above."
    exit 1
}

echo ""
echo "✅ Cask verification passed!"
echo ""

# Show git status
echo "📊 Git status:"
git status --short

echo ""
echo "🎉 Setup complete!"
echo ""
echo "Next steps:"
echo "1. Review the changes: git diff"
echo "2. Commit: git add $CASK_FILE && git commit -m 'Add ocrmypdf-gui'"
echo "3. Push: git push origin $BRANCH_NAME"
echo "4. Create PR: Visit https://github.com/Homebrew/homebrew-cask/compare/main...$GITHUB_USERNAME:$BRANCH_NAME"
echo ""
echo "Or run: ./commit_and_push.sh"

