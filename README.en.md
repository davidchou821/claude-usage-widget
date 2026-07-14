# claude-usage-widget

English | [繁體中文](README.md)

A macOS menu bar widget (SwiftBar plugin) for monitoring your Claude usage.

Shows `CC 30% ⁄49` in the menu bar (5-hour window % ⁄ Fable weekly %) — orange at ≥60%, red at ≥85%, and a system notification at ≥90%. Click for details:

<img src="docs/screenshot.png" width="420" alt="widget menu expanded">


> ⚠️ Not an official Anthropic project. See [Disclaimer](#disclaimer).

## What it shows

**Plan limits** (same numbers as Claude Code's `/usage`)
- 5-hour window utilization + reset time
- Weekly limit (all models)
- Weekly limit (model-scoped, e.g. Fable)

> 💡 Subscription limits are **shared** across claude.ai web, the desktop app, and Claude Code — these percentages cover your usage on every surface, not just the CLI.

**Tokens / cost** (local stats, account-independent)
- Today's output tokens, cache reads, API-equivalent cost + per-model breakdown
- Month-to-date cost (⚠ reference price *as if* billed via API — not your actual subscription bill)

## Multiple accounts

In the "帳號" (accounts) section at the bottom of the menu:

1. Log into account A in Claude Code → click "**把目前登入存為新帳號…**" (save current login as a new account) and give it a name (e.g. `work`)
2. Switch Claude Code to account B → save again (e.g. `personal`)
3. Click an account name to switch which account is queried; "目前登入" (current login) always follows whatever Claude Code is logged into

Saved tokens live in Keychain entries named `claude-usage-widget:<name>` and are auto-renewed via refresh token — no re-login needed. Hold **⌥ (Option)** and click an account to remove it. When a named account is selected, the menu bar label changes from `CC` to that account's name.

⚠ The tokens/cost section comes from local logs and is unaffected by account selection.

## Usage notifications

When any limit (5-hour window / weekly) reaches **≥90%**, a macOS notification fires — once per reset window (keyed by `resets_at`), so it won't spam every refresh. Change the threshold via the `NOTIFY_AT` constant.

## Security & privacy

This widget reads **Claude Code's OAuth token** from your local Keychain (the `Claude Code-credentials` entry). You should know exactly what it does with it:

- **Reading requires your explicit consent**: macOS Keychain access control shows a system prompt on first read — deny it and the widget gets nothing
- **The token is only ever sent to `api.anthropic.com`** (Anthropic's official API) to query your own usage; it is never written to disk or sent to any third party
- The **multi-account feature** copies tokens into the widget's own Keychain entries (`claude-usage-widget:<name>`) — still Keychain, never plain files
- **The entire widget is one Python file** ([claude-usage.5m.py](claude-usage.5m.py), ~250 lines) with zero third-party dependencies — audit it yourself
- Token/cost stats are computed fully offline by [ccusage](https://github.com/ryoppippi/ccusage) from `~/.claude/projects/**/*.jsonl`

## Disclaimer

- This project is **not affiliated with Anthropic**
- The plan-limit data comes from `api.anthropic.com/api/oauth/usage` and the token-refresh endpoint, both **undocumented APIs** that Anthropic may change at any time, breaking this tool
- Cost figures are API list-price equivalents in USD — **not** your actual bill

## Architecture

```
claude-usage.5m.py   ← the plugin (the "5m" in the filename = refresh every 5 minutes)
```

Two data sources:
1. **Plan limits**: Claude Code's OAuth token from macOS Keychain → official `api.anthropic.com/api/oauth/usage`
2. **Tokens / cost**: ccusage parsing local logs

## Install

```bash
./install.sh
```

The script installs SwiftBar (brew cask), Node.js and ccusage (if missing) → sets `~/.swiftbar` as the SwiftBar plugin directory → symlinks the plugin → launches SwiftBar.

On first run macOS will ask for Keychain access → click "Always Allow". `install.sh` automatically adds SwiftBar as a login item, so the menu bar icon reappears after a restart/logout; if it's ever removed, re-add it in System Settings > General > Login Items.

> 💡 When the menu bar is crowded, macOS **silently hides** items that don't fit. If you don't see the widget, ⌘-drag a few unused icons off the menu bar first.

## Update

```bash
git pull
```

The plugin is symlinked into SwiftBar, so changes take effect on the next refresh — no reinstall needed.

## Uninstall

```bash
./uninstall.sh
```

Removes the plugin, config, and the widget's own Keychain entries. It does **not** touch Claude Code's credentials, nor remove SwiftBar/ccusage (the script prints how to remove those manually).

## Customization

- Refresh interval: rename the file (`5m`→`1m`, `30s`…) and recreate the symlink
- Color thresholds: the 85/60 in `color_for()`
- Notification threshold: `NOTIFY_AT` (default 90)
- Menu bar format: the `# ---- 輸出 ----` block at the end of the file

## Roadmap

- **Übersicht desktop card widget**: a weather-widget-style desktop dashboard reusing the same data logic, as a second display mode of this project
- **Standalone OAuth login**: the widget runs its own authorization flow instead of reading Claude Code's Keychain credentials — also enables users who don't have Claude Code installed

## License

[MIT](LICENSE)
