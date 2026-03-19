# wsl-image-clipboard-bridge

Bridge Windows clipboard images to WSL via AutoHotkey v2 + xclip.

WSLg only syncs text between Windows and WSL clipboards. This tool bridges the gap for **images** — press a hotkey to sync clipboard images from Windows to WSL's X11 clipboard (via `xclip`).

## How It Works

```
Windows Clipboard (image) → PowerShell → PNG file → xclip → X11 Clipboard (WSL)
```

1. **AutoHotkey v2** intercepts the hotkey on Windows
2. **PowerShell** reads the image from Windows clipboard and saves it as a PNG temp file
3. **wsl.exe** invokes `xclip` to load the PNG into WSL's X11 clipboard (`DISPLAY=:0`)

## Requirements

### Windows

- [AutoHotkey v2](https://www.autohotkey.com/)

### WSL

```bash
sudo apt install -y xclip
```

- WSLg must be enabled (default on Windows 11)

## Installation

1. Clone this repo or download `ClipboardToWSL.ahk`
2. Double-click `ClipboardToWSL.ahk` to run
3. (Optional) Add a shortcut to `shell:startup` for auto-start on boot

## Usage

| Hotkey | Action |
|--------|--------|
| `Win+Alt+V` | Sync clipboard image from Windows to WSL |

A tooltip will briefly appear to confirm the sync status.

### Verify in WSL

```bash
# Check clipboard formats
xclip -selection clipboard -t TARGETS -o
# Should show: image/png

# Save clipboard image to file
xclip -selection clipboard -t image/png -o > output.png
```

## Why?

WSLg's clipboard bridge (`wslg-clipboard`) only handles `text/plain` and `UTF8_STRING`. It does not forward binary MIME types like `image/png`. This tool fills that gap using PowerShell as the intermediary.

## License

[MIT](LICENSE)
