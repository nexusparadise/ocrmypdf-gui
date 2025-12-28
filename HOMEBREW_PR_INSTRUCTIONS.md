# Homebrew Cask PR - Step by Step Instructions

## ✅ Step 1: Test Locally (COMPLETED)
- ✅ Cask file created and validated
- ✅ All style checks pass
- ✅ SHA256 checksum added: `de18fc892966776fa3581c9c15eb44aefe70c7b75d167c937d437cf37debf335`

## 📋 Step 2: Fork homebrew-cask (MANUAL - Do This First!)

1. Go to https://github.com/Homebrew/homebrew-cask
2. Click the **"Fork"** button in the top right
3. Wait for the fork to complete

## 🚀 Step 3: Run Setup Script

After forking, run this command (replace `nexusparadise` with your GitHub username if different):

```bash
cd /Users/ralf/Library/CloudStorage/Dropbox/Development/ocrmypdf-gui
./setup_homebrew_pr.sh nexusparadise
```

This script will:
- Clone your fork of homebrew-cask
- Set up upstream remote
- Create a branch
- Copy the cask file
- Verify everything works

## 💾 Step 4: Commit and Push

After the setup script completes successfully, run:

```bash
./commit_and_push.sh
```

This will:
- Commit the cask file
- Push to your fork
- Show you the PR link

## 🔗 Step 5: Create Pull Request

1. Click the link shown by the script, or go to:
   ```
   https://github.com/Homebrew/homebrew-cask/compare/main...YOUR_USERNAME:add-ocrmypdf-gui
   ```

2. Use this PR title:
   ```
   Add ocrmypdf-gui
   ```

3. Use this PR description:
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

4. Click **"Create Pull Request"**

## ⏳ Step 6: Wait for Review

- Homebrew maintainers typically review within 1-3 days
- They may ask for changes or merge directly
- You'll get notifications via GitHub

## 📝 Important Notes

- **SHA256 Update**: After you create the GitHub release v0.8, verify the SHA256 matches. If it's different, update the cask file and amend your commit.
- **Version Updates**: For future versions, use `brew bump-cask-pr --version X.X ocrmypdf-gui`

## 🆘 Troubleshooting

If the setup script fails:
1. Make sure you've forked homebrew-cask first
2. Check your GitHub username is correct
3. Ensure you have git configured: `git config --global user.name` and `git config --global user.email`

If you prefer manual steps, see `HOMEBREW_CASK_GUIDE.md` for detailed instructions.

