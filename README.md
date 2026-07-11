# claude-usage-widget

macOS 選單列的 Claude 用量監測 widget（SwiftBar plugin）。

選單列常駐顯示 `CC 30% ⁄49`（5小時窗口% ⁄ Fable 週限%），用量 ≥60% 橘字、≥85% 紅字。點開看明細。

## 顯示內容

**方案額度**（即 Claude Code `/usage` 的數據）
- 5 小時窗口使用率＋重置時間
- 週限額（全部模型）
- 週限額（Fable 專屬）

**Token／費用**（本機統計，不分帳號）
- 今日輸出 token、cache 讀取量、API 等值費用＋各模型明細
- 本月累計費用（⚠ 為「若走 API 計費」的參考價，不是訂閱實際帳單）

## 多帳號切換

選單最下方「帳號」區：

1. 在 Claude Code 登入帳號 A → 點「**把目前登入存為新帳號…**」取個名字（如 `work`）
2. 在 Claude Code 改登入帳號 B → 再存一次（如 `personal`）
3. 之後點帳號名稱即可切換查詢對象；「目前登入」則永遠跟隨 Claude Code 當下登入的帳號

已存帳號的 token 放在 Keychain 的 `claude-usage-widget:<名稱>` 條目，快過期時會用 refresh token 自動續期，不需重新登入。按住 **⌥（Option）** 點帳號名稱可移除。選中非「目前登入」帳號時，選單列的 `CC` 會換成該帳號名稱。

⚠ Token／費用區塊來自本機紀錄，跟選了哪個帳號無關。

## 用量通知

任一額度（5小時窗口／週限額）**≥90%** 時發 macOS 系統通知。同一個重置窗口只提醒一次（以 `resets_at` 判斷），重置後才會再提醒。門檻改 `NOTIFY_AT` 常數。

## 架構

```
claude-usage.5m.py   ← plugin 本體（檔名的 5m = 每 5 分鐘刷新）
```

兩個資料來源：
1. **方案額度**：從 macOS Keychain 讀 Claude Code 的 OAuth token（`Claude Code-credentials`），打官方 `api.anthropic.com/api/oauth/usage`。token 不落地、只送 Anthropic。
2. **Token／費用**：[ccusage](https://github.com/ryoppippi/ccusage) 解析 `~/.claude/projects/**/*.jsonl` 本機紀錄。

## 安裝

```bash
./install.sh
```

腳本會：裝 SwiftBar（brew cask）與 ccusage（npm -g）→ 設定 SwiftBar plugin 目錄為 `~/.swiftbar` → 把 plugin symlink 進去 → 啟動 SwiftBar。

首次執行 macOS 會問 Keychain 存取權 → 點「永久允許」。建議在 SwiftBar Preferences 勾 Launch at Login。

## 自訂

- 刷新頻率：改檔名（`5m`→`1m`、`30s`…），symlink 要重建
- 變色門檻：改 `color_for()` 的 85／60
- 通知門檻：改 `NOTIFY_AT`（預設 90）
- 選單列顯示格式：改檔尾 `# ---- 輸出 ----` 區塊
