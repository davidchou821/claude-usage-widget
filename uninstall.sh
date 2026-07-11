#!/bin/bash
# claude-usage-widget 移除：plugin symlink、設定檔、widget 自存的 Keychain 帳號 token
# 不會動到 Claude Code 本身的憑證，也不移除 SwiftBar／ccusage（共用工具）
set -uo pipefail

rm -f ~/.swiftbar/claude-usage.5m.py && echo "已移除 plugin symlink"

# 刪掉 widget 自存的帳號 token（claude-usage-widget:<名稱>）
/usr/bin/python3 - <<'EOF'
import json, os, subprocess
try:
    with open(os.path.expanduser("~/.config/claude-usage-widget/state.json")) as f:
        accounts = json.load(f).get("accounts", [])
except Exception:
    accounts = []
for name in accounts:
    subprocess.run(
        ["security", "delete-generic-password", "-s", f"claude-usage-widget:{name}"],
        capture_output=True,
    )
    print(f"已刪除 Keychain 條目：claude-usage-widget:{name}")
EOF

rm -rf ~/.config/claude-usage-widget && echo "已移除設定檔"

open -g "swiftbar://refreshallplugins" 2>/dev/null || true

echo "✅ 移除完成。SwiftBar 與 ccusage 未移除，若也不需要："
echo "   brew uninstall --cask swiftbar && npm uninstall -g ccusage"
