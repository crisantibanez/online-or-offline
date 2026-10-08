# Online or Offline

Public on GitHub (crisantibanez/online-or-offline), MIT licence. Everything here is AI-written
and `README.md` says so; keep that statement when editing it.

A tiny native Mac menu bar app: one dot, refreshed every 5 seconds, that says whether the
internet really works (a real HTTPS request to 1.1.1.1 by IP; a captive portal reads as offline).
It replaces the SwiftBar script kept in `reference/`, which holds the proven logic and thresholds.

- Everything is in `main.swift` (AppKit, no dependencies, no Xcode project); `icon.png` is the app icon.
- `./build.sh` compiles with `swiftc`, writes the app bundle to `build/` (ignored by git),
  installs it in `~/Applications` for this user only, and relaunches it. No signing, no notarising.
- Menu bar only (no Dock icon), almost no CPU or data between checks.
- No personal data and no keys in this repository.
