# Win11Reclaim

A PowerShell toolkit for trimming down and reclaiming control over Windows 11. Remove bloatware, reduce telemetry and suggested content, and apply a curated set of privacy, UI, and performance tweaks—all through a simple GUI or optional CLI.

## Requirements

- **Windows 11** (some features may work on Windows 10)
- **PowerShell 5.1** or later
- **Run as Administrator** (required for system and app changes)

## Usage

> **Warning**  
> This tool modifies system and app settings. Create a restore point before use and proceed at your own risk.

### Run with Get.ps1 (recommended)

**Get.ps1** downloads the latest Win11Reclaim from this repo and runs it. No need to clone or unzip the whole project.

1. Open the [**Releases**](https://github.com/akahobby/Win11Reclaim/releases) page and download **`Get.ps1`** from the latest release.
2. Open **PowerShell as Administrator**, then run:

   ```powershell
   Set-ExecutionPolicy -ExecutionPolicy Bypass -Scope Process -Force
   cd C:\Path\To\Where\You\Saved\Get.ps1
   .\Get.ps1
   ```

3. Accept the UAC prompt. The script will download Win11Reclaim, run it, and optionally clean up afterward. You can pass CLI parameters to `Get.ps1` for automated runs.

### Run from a full download

If you prefer to keep a local copy of the project:

1. [Download the repo](https://github.com/akahobby/Win11Reclaim/archive/refs/heads/main.zip) or clone it, then extract to a folder.
2. Double‑click **`Run.bat`** (or run **`Win11Debloat.ps1`** in an elevated PowerShell).
3. Accept the UAC prompt and follow the on‑screen steps.

```powershell
# Open PowerShell as Administrator, then:
Set-ExecutionPolicy -ExecutionPolicy Bypass -Scope Process -Force
cd C:\Path\To\Win11Reclaim
.\Win11Debloat.ps1
```

## Features

- **App removal** — Remove pre‑installed and OEM apps from a recommended list or pick your own.
- **Privacy & suggested content** — Dial back telemetry, activity history, targeted ads, tips, and suggestions across Windows and Edge.
- **AI features** — Disable Copilot, Recall, and other AI options in Windows, Edge, Paint, and Notepad.
- **System behaviour** — Restore classic context menu, turn off mouse acceleration, disable fast startup, and more.
- **Windows Update** — Control when updates install and whether updates are shared with other PCs.
- **Appearance** — Dark mode, disable transparency and animations.
- **Start & taskbar** — Tweak Start layout, search, taskbar alignment, widgets, and taskbar behaviour.
- **File Explorer** — Default open location, show extensions and hidden files, customize navigation pane.
- **Multi‑tasking** — Configure snapping, Snap Assist, and Alt+Tab behaviour.
- **Optional features** — One‑click enable Windows Sandbox or WSL.

Advanced options: apply tweaks to another user profile or to the default user template (e.g. for Sysprep).

## Project structure

| Path | Purpose |
|------|---------|
| `Get.ps1` | One-file runner: downloads latest Win11Reclaim and runs it (use from [Releases](https://github.com/akahobby/Win11Reclaim/releases)) |
| `Run.bat` | Launches the script with execution policy bypass (when run from a full download) |
| `Win11Debloat.ps1` | Main entry point and GUI logic |
| `Apps.json` | App list and metadata for removal |
| `Schemas/` | XAML UI definitions (main window, dialogs) |
| `Scripts/` | GUI and theme helpers, app/tweak logic |

## License

MIT. See [LICENSE](LICENSE) for details.

## Links

- **Repository:** [github.com/akahobby/Win11Reclaim](https://github.com/akahobby/Win11Reclaim)  
- **Issues:** [Report a bug or request a feature](https://github.com/akahobby/Win11Reclaim/issues)
