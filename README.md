# Notchly

A macOS menu bar app that puts Claude Code right in your MacBook's notch. Hover over the notch or click the menu bar icon to open a floating terminal panel with embedded sessions.

Based on [Notchy](https://github.com/adamlyttleapps/notchy) by Adam Lyttle.

## Features

- **Notch integration** — hover over the MacBook notch to reveal the terminal panel
- **Multi-session tabs** — run multiple Claude Code sessions side by side
- **Split panes** — split any terminal horizontally or vertically for side-by-side workflows
- **Tab reordering** — drag tabs or use Cmd+Shift+Arrow to reorder
- **Live status in the notch** — animated pill shows whether Claude is working, waiting, or done
- **Git checkpoints** — Cmd+S to snapshot your project before Claude makes changes
- **Working directory persistence** — terminals remember where you were across restarts
- **Native notifications** — macOS alerts when Claude finishes or needs input
- **Centered resize** — panel grows equally from both sides, size persists across sessions
- **Adjustable font size** — Cmd+/Cmd- to resize terminal text

## Installation

### Download

Download the latest `Notchly.dmg` from [Releases](https://github.com/javierpr0/Notchly/releases).

### Important: unsigned app

Notchly is not code-signed with an Apple Developer certificate. On first launch macOS will block it. To allow it:

1. Open the DMG and drag **Notchly.app** to **Applications**
2. Try to open Notchly — macOS will show "cannot be opened because the developer cannot be verified"
3. Go to **System Settings → Privacy & Security**
4. Scroll down — you'll see a message about Notchly being blocked
5. Click **"Open Anyway"**
6. Notchly will launch and you won't need to do this again

### Build from source

Requires macOS 26.0+ and Xcode with the macOS 26 SDK.

```bash
xcodebuild -project Notchy.xcodeproj -scheme Notchy -configuration Release build
```

Or open `Notchy.xcodeproj` in Xcode and build (Cmd+B).

## Keyboard Shortcuts

| Shortcut | Action |
|----------|--------|
| `` ` `` (backtick) | Toggle panel |
| Cmd+D | Split pane right |
| Cmd+Shift+D | Split pane down |
| Cmd+Shift+W | Close focused pane |
| Cmd+] / Cmd+[ | Navigate between panes |
| Cmd+1-9 | Jump to nth tab |
| Cmd+Shift+Left/Right | Move tab left/right |
| Cmd+T | New terminal session |
| Cmd+S | Save checkpoint |
| Cmd+= / Cmd+- | Increase / decrease font |
| Cmd+0 | Reset font size |

## Dependencies

- [SwiftTerm](https://github.com/migueldeicaza/SwiftTerm) — terminal emulator view (via Swift Package Manager)

## License

[MIT](LICENSE)
