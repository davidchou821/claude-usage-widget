#!/bin/bash
# claude-usage-widget 一鍵安裝
set -euo pipefail
cd "$(dirname "$0")"

command -v brew >/dev/null || { echo "需要 Homebrew：https://brew.sh"; exit 1; }

if ! ls /Applications | grep -qi swiftbar; then
  echo "安裝 SwiftBar…"
  brew install --cask swiftbar
fi

if ! command -v ccusage >/dev/null && ! ls ~/.nvm/versions/node/*/bin/ccusage >/dev/null 2>&1; then
  echo "安裝 ccusage…"
  npm install -g ccusage
fi

mkdir -p ~/.swiftbar
ln -sf "$PWD/claude-usage.5m.py" ~/.swiftbar/claude-usage.5m.py
chmod +x claude-usage.5m.py

defaults write com.ameba.SwiftBar PluginDirectory "$HOME/.swiftbar"
open -a SwiftBar

echo "✅ 完成。首次執行請在 Keychain 彈窗點「永久允許」。"
