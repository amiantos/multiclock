# MultiClock for Windows

This folder contains the Windows port of MultiClock, written in C# with WPF on .NET 8. It is a faithful port of the macOS screensaver: the same 24 clocks, the same hand and dial designs, the same animations at the same speed, and the same five settings.

## How Windows screensavers work

A `.scr` file is just a renamed `.exe`. Windows launches it with a flag:

| Flag | Meaning |
|------|---------|
| `/s` | Run the actual screensaver, fullscreen on every monitor |
| `/c` | Show the settings dialog |
| `/p <hwnd>` | Draw a preview inside the thumbnail in Screen Saver Settings |
| `/w` | (Ours, not standard) Run in a 1280×720 window for development |

Running the exe with no arguments opens the settings dialog.

## One-time setup on your Windows machine

1. Install the .NET 8 SDK (in an Administrator PowerShell or via the installer from <https://dotnet.microsoft.com/download/dotnet/8.0>):

   ```powershell
   winget install Microsoft.DotNet.SDK.8
   ```

2. Install git if you don't have it (`winget install Git.Git`), then clone the repo and check out the branch:

   ```powershell
   git clone https://github.com/amiantos/multiclock.git
   cd multiclock
   git checkout windows-support
   ```

## Everyday development loop

Pull the latest work, then from the repo root:

```powershell
git pull

# Windowed test mode — easiest way to see it working; Esc closes it
dotnet run --project windows -- /w

# Real fullscreen mode — move the mouse or press any key to exit
dotnet run --project windows -- /s

# Settings dialog
dotnet run --project windows -- /c
```

In windowed test mode the keyboard shortcuts from the macOS development app work too, for trying out animations:

| Key | Animation |
|-----|-----------|
| `T` | Show the current time as digits |
| `R` | Show the current time on every clock |
| `P` | Spin every hand a full turn |
| `Q` | Print "1234", then the inward-pointing pattern |
| `O` | Horizontal lines pattern, then back to the time |
| `W`, `X`, `C` | Move every hand to a fixed position |

## Where things live on disk

| Thing | Path |
|-------|------|
| Settings | `%APPDATA%\MultiClock\settings.json` |
| Log file | `%LOCALAPPDATA%\MultiClock\multiclock.log` |

Paste those into the Explorer address bar as-is. If something misbehaves, check the log — a screensaver has no console, so the log is the only place errors go. Deleting `settings.json` restores the defaults.

## Building the actual screensaver (.scr)

```powershell
pwsh windows/publish.ps1
```

That publishes a self-contained single-file build, renames it to `.scr`, and writes `windows\dist\MultiClock-1.0.0-Windows.zip` — the file to share. The version in the name comes from `<Version>` in `MultiClock.csproj`, so bump it there for a release.

To install a build locally:

1. Copy `MultiClock.scr` somewhere permanent (e.g. `C:\Screensavers\`) — Windows remembers the path of an installed screensaver, so don't leave it in `dist\` or the build folder, and don't move it afterwards.
2. Right-click it → **Install**. On Windows 11 that may be hidden behind **Show more options** (or press Shift+F10 instead of right-clicking).
3. That opens the Screen Saver Settings dialog with MultiClock selected; set your idle timeout and hit OK. The **Settings...** button there opens the MultiClock settings dialog.

The first launch after install pauses briefly while the single-file executable unpacks itself to a temp folder; later launches are cached.

Self-contained publish means users don't need .NET installed; the tradeoff is a large file (around 150 MB, much smaller zipped).

Unsigned downloaded executables trigger a SmartScreen warning ("Windows protected your PC"). Users click "More info" → "Run anyway".

## How the port is organized

| Folder | Contents | macOS counterpart |
|--------|----------|-------------------|
| `Core/` | Patterns, animations and the controller that sequences them. Plain C# with no Windows dependency. | `Shared/Scene/` |
| `UI/` | Drawing the clocks, the screensaver window and the settings dialog. | `Shared/Nodes/`, `macOS Screensaver/` |
| `Assets/` | The hand and dial artwork as 1024×1024 PNGs. | `Shared/Nodes/Assets.xcassets` |

### Adding animations

Animations are written the same way as on macOS (see the main README), with C# naming:

```csharp
Queue(
    ClockAnimation.Display(Patterns.InwardPoint),
    ClockAnimation.Wait(5),
    ClockAnimation.SpinBothHands(by: 180),
    ClockAnimation.CurrentTimePrint());
```

Add new ones to `Core/ClockController.cs`, mirroring `Shared/Scene/ClockController.swift` so both platforms stay in step.

### Regenerating the artwork

The PNGs in `Assets/` are rasterized from the PDFs in `Shared/Nodes/Assets.xcassets`. If a design changes or a new one is added, regenerate on a Mac with poppler installed (`brew install poppler`):

```sh
pdftocairo -png -transp -singlefile -scale-to 1024 path/to/design.pdf windows/Assets/designName
```

The file name must match the asset name used on macOS (e.g. `modernHourHand.png`), and a new design needs an entry in the `HandDesign` or `DialDesign` enum in `Settings.cs` and in the lists at the top of `UI/ConfigWindow.cs`.

## Differences from macOS

- **Very wide screens.** On a screen wider than 8:3 the macOS version lets the clocks run off the top and bottom; here the grid shrinks to fit the height instead. On ordinary screens the layout is identical.
- **24-hour time** follows the short time format in Windows' regional settings.
- **Settings** are stored in `settings.json` instead of macOS `UserDefaults`, and colors are picked with the standard Windows color dialog.
